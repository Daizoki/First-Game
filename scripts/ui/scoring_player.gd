extends RefCounted
## Plays back the events of one scored Cast (from Scorer) on screen, step by step:
## each scoring stone flashes, its Power / Resonance flies out, the counters update,
## and at the end Power × Resonance multiply with a big pop. Speed ×1, ×2, ×4.

const StoneView = preload("res://scripts/ui/stone_view.gd")
const FloatLayer = preload("res://scripts/ui/float_layer.gd")

const STEP: float = 0.42
const POWER_COLOR: Color = Color("#63c6f2")
const RES_COLOR: Color = Color("#ff6a3d")
const MONEY_COLOR: Color = Color("#ebaa3c")
const BONE: Color = Color("#e9e3d2")

var host: Node
var float_layer: FloatLayer
var power_label: Label
var res_label: Label
var word_label: Label
var level_label: Label
var total_label: Label
## The Talisman string (its cards glow when they act).
var talisman_string: Control
var speed: float = 1.0

var _stone_phase_sent: bool = false


## cast_views / held_views: the StoneViews of the cast and held stones, same order as the scorer's.
## Each phase is announced on the EventBus; listeners (the tutorial) may hold the animation.
func play(result: Dictionary, cast_views: Array[StoneView], held_views: Array[StoneView]) -> void:
	_stone_phase_sent = false
	for event: Dictionary in result["events"]:
		await _announce_phase(event, cast_views, held_views)
		match str(event["type"]):
			"word":
				var word: Dictionary = GameData.words[event["word"]]
				word_label.text = Loc.text(word["name"])
				level_label.text = Loc.t("circle_level", {"n": event["level"]})
				_set_counters(event)
				_pop(word_label)
				await _wait(STEP)
			"stone":
				var view: StoneView = cast_views[event["index"]]
				view.flash = 1.0
				_float_at(view, Loc.t("float_power", {"n": Loc.number(event["power_add"])}), POWER_COLOR)
				_set_counters(event)
				_pop(power_label)
				await _wait(STEP)
			"voice":
				var view: StoneView = cast_views[event["index"]]
				if _show_voice(view, event):
					await _wait(STEP * 0.8)
			"held":
				var view: StoneView = held_views[event["index"]]
				view.flash = 1.0
				if _show_voice(view, event):
					await _wait(STEP * 0.8)
			"bonus":
				# Spells that change the Cast: +Power, +Resonance, ×Resonance, Resonance = 1.
				_set_counters(event)
				var key: String = {"add_power": "float_power", "add_res": "float_add_res",
					"set_res": "float_set_res"}.get(str(event.get("kind", "")), "float_mul_res")
				var label: Label = power_label if key == "float_power" else res_label
				float_layer.spawn(Loc.t(key, {"n": Loc.number(event["value"])}),
					label.get_global_rect().get_center() - float_layer.global_position,
					POWER_COLOR if key == "float_power" else RES_COLOR, 44)
				_pop(label)
				await _wait(STEP)
			"talisman":
				_set_counters(event)
				var kind: String = str(event.get("kind", ""))
				talisman_string.call("flash", int(event["slot"]))
				if kind == "retrigger":
					await _wait(STEP * 0.5)
					continue
				var key: String = {"add_power": "float_power", "add_res": "float_add_res", "mul_res": "float_mul_res",
					"add_money": "float_money"}.get(kind, "float_add_res")
				var color: Color = {"add_power": POWER_COLOR, "add_money": MONEY_COLOR}.get(kind, RES_COLOR)
				var at: Vector2 = (talisman_string.call("slot_center", int(event["slot"])) as Vector2) \
					- float_layer.global_position + Vector2(0, 110)
				float_layer.spawn(Loc.t(key, {"n": Loc.number(event["value"])}), at, color, 36, 1.0 / speed + 0.3)
				_pop(res_label if color == RES_COLOR else power_label)
				await _wait(STEP * 0.8)
			"rule":
				# The examiner's rule: a struck stone, or a Cast graded 0.
				if str(event.get("kind", "")) == "blocked":
					var struck: StoneView = cast_views[event["index"]]
					struck.dimmed = true
					_float_at(struck, Loc.t("float_rule_blocked"), BONE)
				else:
					float_layer.spawn(Loc.t("float_rule_zero"),
						total_label.get_global_rect().get_center() - float_layer.global_position, RES_COLOR, 44)
				await _wait(STEP)
			"total":
				total_label.text = "= " + Loc.number(event["score"])
				total_label.modulate.a = 1.0
				_pop(total_label, 1.6)
				await _wait(STEP * 1.6)


## Shows one Voice effect. Returns false when nothing visible happened.
func _show_voice(view: StoneView, event: Dictionary) -> bool:
	var value: String = Loc.number(event.get("value", 0))
	var text: String = ""
	var color: Color = RES_COLOR
	match str(event["kind"]):
		"add_power":
			text = Loc.t("float_power", {"n": value})
			color = POWER_COLOR
		"add_res":
			text = Loc.t("float_add_res", {"n": value})
		"mul_res":
			text = Loc.t("float_mul_res", {"n": value})
		"add_money", "add_money_at_round_end":
			text = Loc.t("float_money", {"n": value})
			color = MONEY_COLOR
		"add_swap":
			text = Loc.t("float_swap", {"n": value})
			color = BONE
		"grow_power":
			text = Loc.t("float_grow", {"n": value})
			color = POWER_COLOR
		"berkanan_copy":
			text = Loc.t("float_copy")
			color = BONE
		"algiz_ignore_rule":
			text = Loc.t("float_rule")
			color = BONE
		_:
			return false
	view.flash = 1.0
	_float_at(view, text, color)
	_set_counters(event)
	if color == RES_COLOR:
		_pop(res_label)
	return true


func _announce_phase(event: Dictionary, cast_views: Array[StoneView], held_views: Array[StoneView]) -> void:
	var type: String = str(event["type"])
	var rune_id: String = ""
	match type:
		"stone", "voice":
			rune_id = cast_views[event["index"]].stone.rune_id
		"held":
			rune_id = held_views[event["index"]].stone.rune_id
	match type:
		"word", "total":
			EventBus.scoring_phase.emit(type, "", "")
		"stone":
			EventBus.scoring_phase.emit("stone", rune_id, "first" if not _stone_phase_sent else "")
			_stone_phase_sent = true
		"voice", "held":
			EventBus.scoring_phase.emit("voice", rune_id, str(event.get("kind", "")))
	while EventBus.scoring_held():
		await EventBus.scoring_released


func _set_counters(event: Dictionary) -> void:
	power_label.text = Loc.number(event["power"])
	res_label.text = Loc.number(event["res"])


func _float_at(view: StoneView, text: String, color: Color) -> void:
	var at: Vector2 = view.get_global_rect().get_center() - float_layer.global_position + Vector2(0, -110)
	float_layer.spawn(text, at, color, 38, 1.0 / speed + 0.3)


func _pop(control: Control, strength: float = 1.25) -> void:
	control.pivot_offset = control.size / 2.0
	var tween: Tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2(strength, strength), 0.08 / speed)
	tween.tween_property(control, "scale", Vector2.ONE, 0.18 / speed)


func _wait(seconds: float) -> void:
	await host.get_tree().create_timer(seconds / speed).timeout
