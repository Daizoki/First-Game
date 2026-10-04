extends RefCounted
## Plays back the events of one Cast (FightState.cast) on screen, step by step: the spell's
## Power × Resonance, the bonuses of stones, spells and Talismans, the monster's weakness or
## resistance, then the hits that tear the life bar, the Element's nature, and the total.
## Speed ×1, ×2, ×4.

const StoneView = preload("res://scripts/ui/stone_view.gd")
const FloatLayer = preload("res://scripts/ui/float_layer.gd")
const HpBar = preload("res://scripts/ui/hp_bar.gd")
const Monster = preload("res://scripts/core/monster.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")

const STEP: float = 0.42
const POWER_COLOR: Color = Color("#63c6f2")
const RES_COLOR: Color = Color("#ff6a3d")
const MONEY_COLOR: Color = Color("#ebaa3c")
const BONE: Color = Color("#e9e3d2")
const HIT_COLOR: Color = Color("#ff4a3a")
const WEAK_COLOR: Color = Color("#ffb347")
const DULL_COLOR: Color = Color("#9a93a8")

var host: Node
var float_layer: FloatLayer
var power_label: Label
var res_label: Label
var spell_label: Label
var total_label: Label
## The monster's card and life bar (the hits land there).
var monster_card: Control
var hp_bar: HpBar
var monster: Monster
## The Talisman string (its cards glow when they act).
var talisman_string: Control
var speed: float = 1.0
## Called after every hit (the screen shakes on a big one): func(amount: float).
var on_hit: Callable

var _head: int = 0


## cast_views: the StoneViews of the cast stones, in casting order. Each phase is announced on
## the EventBus; listeners (the tutorial) may hold the animation.
func play(result: Dictionary, cast_views: Array[StoneView]) -> void:
	_head = monster.head
	for event: Dictionary in result["events"]:
		await _announce_phase(event)
		match str(event["type"]):
			"tick":
				# The Burn, the Future, lasting and ripened spells, before the new spells.
				_hit_bar(event)
				_float_monster(Loc.t("float_tick_" + str(event["kind"]), {"n": Loc.number(event["amount"])}),
					HIT_COLOR if float(event["amount"]) > 0.0 else DULL_COLOR)
				await _wait(STEP)
			"rule":
				if str(event["kind"]) == "struck":
					var index: int = int(event["index"])
					if index < cast_views.size():
						cast_views[index].dimmed = true
						_float_at(cast_views[index], Loc.t("float_rule_struck"), BONE)
				else:
					_float_center(Loc.t("float_rule_zero"), RES_COLOR)
				await _wait(STEP)
			"spell":
				var spell_id: String = str(event["spell"])
				spell_label.text = SpellText.spell_name(spell_id)
				_set_counters(event)
				_pop(spell_label)
				if int(event["index"]) == 0:
					for view: StoneView in cast_views:
						if not view.dimmed:
							view.flash = 1.0
				if bool(event.get("fizzled", false)):
					_float_center(Loc.t("float_fizzled"), DULL_COLOR)
				elif bool(event.get("gift", false)):
					_float_center(Loc.t("float_scroll"), BONE)
				await _wait(STEP)
			"bonus":
				_set_counters(event)
				var key: String = {"add_power": "float_power", "add_res": "float_add_res"}.get(
					str(event.get("kind", "")), "float_mul_res")
				var label: Label = power_label if key == "float_power" else res_label
				float_layer.spawn(Loc.t(key, {"n": Loc.number(event["value"])}),
					label.get_global_rect().get_center() - float_layer.global_position,
					POWER_COLOR if key == "float_power" else RES_COLOR, 44)
				_pop(label)
				await _wait(STEP * 0.8)
			"talisman":
				_set_counters(event)
				talisman_string.call("flash", int(event["slot"]))
				var kind: String = str(event.get("kind", ""))
				var key: String = {"add_power": "float_power", "power_per_bag_stone": "float_power",
					"mul_res_five": "float_mul_res", "growing_mul": "float_mul_res", "rain_hits": "float_hits"}.get(
					kind, "float_add_res")
				var color: Color = POWER_COLOR if key == "float_power" else (BONE if key == "float_hits" else RES_COLOR)
				var at: Vector2 = (talisman_string.call("slot_center", int(event["slot"])) as Vector2) \
					- float_layer.global_position + Vector2(0, 110)
				float_layer.spawn(Loc.t(key, {"n": Loc.number(event["value"])}), at, color, 36, 1.0 / speed + 0.3)
				_pop(power_label if color == POWER_COLOR else res_label)
				await _wait(STEP * 0.8)
			"mult":
				var reason: String = str(event["reason"])
				var color: Color = WEAK_COLOR
				if reason in ["resist", "immune"]:
					color = DULL_COLOR
				var text: String = Loc.t("float_mult_" + reason, {"n": Loc.number(event["value"])})
				if reason in ["weak", "resist", "immune"]:
					_float_monster(text, color)
				else:
					_float_center(text, color)
				await _wait(STEP)
			"hit":
				_hit_bar(event)
				var amount: float = float(event["amount"])
				_float_monster(Loc.t("float_hit", {"n": Loc.number(amount)}),
					GameData.element_color(str(event.get("element", ""))) if amount > 0.0 else DULL_COLOR,
					56 if amount > 0.0 else 40)
				if on_hit.is_valid():
					on_hit.call(amount)
				await _wait(STEP)
			"nature":
				_float_monster(Loc.t("float_nature_" + str(event["kind"]), {"n": Loc.number(event["value"])}), WEAK_COLOR)
				await _wait(STEP * 0.8)
			"later":
				_float_center(Loc.t("float_later_" + str(event["kind"]), {"n": Loc.number(event["amount"])}), BONE)
				await _wait(STEP)
			"total":
				total_label.text = Loc.t("circle_dealt", {"n": Loc.number(event["damage"])})
				total_label.modulate.a = 1.0
				_pop(total_label, 1.6)
				await _wait(STEP * 1.6)


## The life bar after a hit; a new head of the Balaur starts whole.
func _hit_bar(event: Dictionary) -> void:
	var head: int = int(event.get("head", _head))
	if head != _head:
		_head = head
		hp_bar.heads_left = maxi(0, monster.heads() - 1 - head)
		hp_bar.reset(monster.max_hp, monster.max_hp)
		_float_monster(Loc.t("float_new_head"), WEAK_COLOR)
	hp_bar.set_life(maxf(0.0, float(event["hp"])))


func _announce_phase(event: Dictionary) -> void:
	var type: String = str(event["type"])
	if type in ["spell", "hit", "total"]:
		EventBus.scoring_phase.emit(type, "", str(event.get("spell", "")))
	while EventBus.scoring_held():
		await EventBus.scoring_released


func _set_counters(event: Dictionary) -> void:
	power_label.text = Loc.number(event["power"])
	res_label.text = Loc.number(event["res"])


func _float_at(view: StoneView, text: String, color: Color) -> void:
	var at: Vector2 = view.get_global_rect().get_center() - float_layer.global_position + Vector2(0, -110)
	float_layer.spawn(text, at, color, 38, 1.0 / speed + 0.3)


## Over the monster's card, a little scattered so hits in a row do not cover each other.
func _float_monster(text: String, color: Color, font_size: int = 40) -> void:
	var at: Vector2 = monster_card.get_global_rect().get_center() - float_layer.global_position
	at += Vector2(randf_range(-90.0, 90.0), 150.0 + randf_range(-10.0, 30.0))
	float_layer.spawn(text, at, color, font_size, 1.0 / speed + 0.5)


func _float_center(text: String, color: Color) -> void:
	float_layer.spawn(text, total_label.get_global_rect().get_center() - float_layer.global_position, color, 40,
		1.0 / speed + 0.3)


func _pop(control: Control, strength: float = 1.25) -> void:
	control.pivot_offset = control.size / 2.0
	var tween: Tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2(strength, strength), 0.08 / speed)
	tween.tween_property(control, "scale", Vector2.ONE, 0.18 / speed)


func _wait(seconds: float) -> void:
	await host.get_tree().create_timer(seconds / speed).timeout
