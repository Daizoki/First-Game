extends PanelContainer
## The player's picks that spells ask for (RoundState.pending): a panel above the hand with
## the spell's name and what to pick. Stones from the hand are picked in the hand itself
## (the panel counts them and confirms); a price is two buttons; stones from the bag (The
## Omen) or freshly drawn (The Choice) are shown on the panel and clicked.

## The answer for RoundState.answer(). For picks from the hand the round screen adds
## "stones" (the hand's selection) before answering.
signal answered(reply: Dictionary)

const Stone = preload("res://scripts/core/stone.gd")
const MiniStone = preload("res://scripts/ui/mini_stone.gd")

const WIDTH: float = 760.0
## The panel's bottom edge sits this far above the parent's bottom (over the hand).
const BOTTOM_GAP: float = 400.0
const BONE: Color = Color("#e9e3d2")

var _title: Label
var _text: Label
var _count: Label
var _stones: HBoxContainer
var _kins: HBoxContainer
var _buttons: HBoxContainer
var _confirm: Button

var _choice: Dictionary = {}
var _limits: Dictionary = {}
var _picked_in_hand: int = 0
var _kin: String = ""
var _rune: String = ""
var _runes: HBoxContainer
## Positions (in the shown stones) clicked so far, for The Omen.
var _order: Array[int] = []
var _stone_buttons: Array[Button] = []


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_meta("tutorial_id", "choice")
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	_title = _label(box, 40, &"TitleLabel")
	_text = _label(box, 25, &"")
	_text.custom_minimum_size = Vector2(WIDTH - 40.0, 0)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stones = HBoxContainer.new()
	_stones.alignment = BoxContainer.ALIGNMENT_CENTER
	_stones.add_theme_constant_override("separation", 10)
	box.add_child(_stones)
	_runes = HBoxContainer.new()
	_runes.alignment = BoxContainer.ALIGNMENT_CENTER
	_runes.add_theme_constant_override("separation", 8)
	box.add_child(_runes)
	_kins = HBoxContainer.new()
	_kins.alignment = BoxContainer.ALIGNMENT_CENTER
	_kins.add_theme_constant_override("separation", 10)
	box.add_child(_kins)
	_count = _label(box, 22, &"SecondaryLabel")
	_buttons = HBoxContainer.new()
	_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons.add_theme_constant_override("separation", 16)
	box.add_child(_buttons)
	for label: Label in [_title, _text, _count]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## Shows a pick. limits: RoundState.pick_limits(). ctx: {"money": int, "stones": Array[Stone]
## (the bag's top for The Omen, the offer for The Choice), "kins": Array[String]}.
func ask(choice: Dictionary, limits: Dictionary, ctx: Dictionary) -> void:
	_choice = choice
	_limits = limits
	_picked_in_hand = 0
	_kin = ""
	_rune = ""
	_order.clear()
	_stone_buttons.clear()
	for row: Container in [_stones, _kins, _buttons, _runes]:
		for child: Node in row.get_children():
			row.remove_child(child)
			child.queue_free()
	var spell: Dictionary = GameData.spells.get(str(choice.get("spell", "")), {})
	if choice.has("engraving"):
		spell = {"name": (GameData.engravings.get(str(choice["engraving"]), {}) as Dictionary).get("name", {}),
			"color": "#ffb347"}
	_title.text = Loc.text(spell.get("name", {})) if not spell.is_empty() else Loc.t("choice_title")
	_title.add_theme_color_override("font_color", Color.html(str(spell.get("color", "#e9e3d2"))))
	var kind: String = str(choice.get("kind", ""))
	var count: int = int(choice.get("count", choice.get("cost", 1)))
	_text.text = Loc.t("choice_" + kind, {"n": count, "amount": choice.get("amount", 0),
		"money": choice.get("money", 0), "factor": Loc.number(float(choice.get("factor", 1.0)))})
	_count.text = ""
	_confirm = null
	match str(limits.get("source", "")):
		"option":
			var cast_button: Button = _button(Loc.t("choice_pay_cast", {"n": choice.get("casts", 1)}))
			cast_button.pressed.connect(func() -> void: answered.emit({"option": "cast"}))
			var money_button: Button = _button(Loc.t("choice_pay_money", {"n": choice.get("money", 0)}))
			money_button.disabled = int(ctx.get("money", 0)) < int(choice.get("money", 0))
			money_button.pressed.connect(func() -> void: answered.emit({"option": "money"}))
		"hand":
			if bool(limits.get("kin", false)):
				for kin_id: String in ctx.get("kins", []):
					var kin_button: Button = _button(Loc.text((GameData.kins.get(kin_id, {}) as Dictionary).get("name", {})), _kins)
					kin_button.toggle_mode = true
					kin_button.add_theme_color_override("font_color", GameData.kin_color(kin_id))
					kin_button.pressed.connect(_on_kin.bind(kin_id, kin_button))
			_confirm = _button(Loc.t("choice_confirm"))
			_confirm.theme_type_variation = &"CastButton"
			_confirm.pressed.connect(func() -> void: answered.emit({"kin": _kin, "rune": _rune}))
			set_hand_picks(0)
		"bag_top":
			_show_stones(ctx.get("stones", []))
			var keep: Button = _button(Loc.t("choice_keep_order"))
			keep.pressed.connect(func() -> void:
				var order: Array[int] = []
				for i: int in _stone_buttons.size():
					order.append(i)
				answered.emit({"order": order}))
			_confirm = _button(Loc.t("choice_confirm"))
			_confirm.theme_type_variation = &"CastButton"
			_confirm.disabled = true
			_confirm.pressed.connect(func() -> void: answered.emit({"order": _order.duplicate()}))
		"offer":
			_show_stones(ctx.get("stones", []))
		"talisman":
			# A spell into the Talismans: which one (the stones list holds the owned Talismans).
			var owned: Array = ctx.get("stones", [])
			for slot: int in owned.size():
				var entry: Dictionary = GameData.talismans.get(str(owned[slot]["id"]), {})
				var talisman_button: Button = _button(Loc.text(entry.get("name", {})))
				talisman_button.custom_minimum_size = Vector2(240, 64)
				talisman_button.add_theme_font_size_override("font_size", 20)
				talisman_button.tooltip_text = Loc.text(entry.get("description", {}))
				talisman_button.pressed.connect(func() -> void: answered.emit({"talisman": slot}))
		"rule":
			# Water against the Examiner: one of two other examiners' rules.
			for examiner_id: Variant in choice.get("rules", []):
				var entry: Dictionary = GameData.examiners.get(examiner_id, {})
				var rule_button: Button = _button(Loc.text(entry.get("title", {})))
				rule_button.custom_minimum_size = Vector2(320, 64)
				rule_button.tooltip_text = Loc.text(entry.get("text", {}))
				rule_button.pressed.connect(func() -> void: answered.emit({"rule": str(examiner_id)}))
	visible = true
	_place()


## Fits the panel to its content, centered above the hand.
func _place() -> void:
	size = get_combined_minimum_size()
	var parent_size: Vector2 = (get_parent() as Control).size
	position = Vector2((parent_size.x - size.x) * 0.5, parent_size.y - BOTTOM_GAP - size.y)


func _process(_delta: float) -> void:
	# Wrapped text settles a frame after it is set.
	if visible and not size.is_equal_approx(get_combined_minimum_size()):
		_place()


## The hand's selection changed while a pick from the hand is shown.
func set_hand_picks(count: int) -> void:
	_picked_in_hand = count
	if str(_limits.get("source", "")) != "hand":
		return
	_count.text = Loc.t("choice_picked", {"n": count, "max": _limits.get("max", 0)})
	_refresh_confirm()


## How many hand stones this pick takes at most (0 when it does not use the hand).
func hand_max() -> int:
	return int(_limits.get("max", 0)) if str(_limits.get("source", "")) == "hand" else 0


func uses_hand() -> bool:
	return visible and str(_limits.get("source", "")) == "hand"


func close() -> void:
	visible = false
	_choice = {}
	_limits = {}


func _refresh_confirm() -> void:
	if _confirm == null:
		return
	var count_ok: bool = _picked_in_hand >= int(_limits.get("min", 0)) and _picked_in_hand <= int(_limits.get("max", 0))
	var kin_ok: bool = not bool(_limits.get("kin", false)) or _picked_in_hand == 0 or not _kin.is_empty()
	var rune_ok: bool = not bool(_limits.get("rune", false)) or not _rune.is_empty()
	_confirm.disabled = not (count_ok and kin_ok and rune_ok)


## The Reshaping: buttons for the runes the picked stone can become (empty: none picked).
func set_rune_options(rune_ids: Array[String]) -> void:
	if not bool(_limits.get("rune", false)):
		return
	for child: Node in _runes.get_children():
		_runes.remove_child(child)
		child.queue_free()
	_rune = ""
	for id: String in rune_ids:
		var rune: Dictionary = GameData.runes.get(id, {})
		var rune_button: Button = Button.new()
		rune_button.toggle_mode = true
		rune_button.text = "%s %s" % [str(rune.get("glyph", "")), Loc.text(rune.get("name", {}))]
		rune_button.add_theme_font_size_override("font_size", 20)
		rune_button.custom_minimum_size = Vector2(0, 52)
		rune_button.tooltip_text = Loc.text(rune.get("voice", {}))
		rune_button.pressed.connect(_on_rune.bind(id, rune_button))
		_runes.add_child(rune_button)
	_refresh_confirm()
	reset_size()


func _on_rune(rune_id: String, pressed_button: Button) -> void:
	_rune = rune_id
	for child: Node in _runes.get_children():
		(child as Button).button_pressed = child == pressed_button
	_refresh_confirm()


func _on_kin(kin_id: String, pressed_button: Button) -> void:
	_kin = kin_id
	for child: Node in _kins.get_children():
		(child as Button).button_pressed = child == pressed_button
	_refresh_confirm()


func _show_stones(stones: Array) -> void:
	for i: int in stones.size():
		var stone: Stone = stones[i]
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(76, 104)
		button.tooltip_text = "%s · %s" % [Loc.text((GameData.runes.get(stone.rune_id, {}) as Dictionary).get("name", {})),
			Loc.t("card_power", {"n": stone.base_power + stone.bonus_power})]
		var mini: MiniStone = MiniStone.new()
		mini.rune_id = stone.rune_id
		mini.show_role = true
		mini.position = Vector2(15, 30)
		button.add_child(mini)
		var number: Label = Label.new()
		number.name = "Number"
		number.position = Vector2(0, 0)
		number.size = Vector2(76, 30)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_size_override("font_size", 22)
		number.add_theme_color_override("font_color", Color("#ffb347"))
		button.add_child(number)
		button.pressed.connect(_on_stone.bind(i))
		_stones.add_child(button)
		_stone_buttons.append(button)


func _on_stone(index: int) -> void:
	if str(_limits.get("source", "")) == "offer":
		answered.emit({"pick": index})
		return
	# The Omen: click the stones in the order they should be drawn; a second click takes
	# a stone back out of the order.
	if _order.has(index):
		_order.erase(index)
	else:
		_order.append(index)
	for i: int in _stone_buttons.size():
		var number: Label = _stone_buttons[i].get_node("Number")
		number.text = str(_order.find(i) + 1) if _order.has(i) else ""
	if _confirm != null:
		_confirm.disabled = _order.size() != _stone_buttons.size()


func _button(text: String, parent: Container = null) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(220, 64)
	button.add_theme_font_size_override("font_size", 26)
	(parent if parent != null else _buttons).add_child(button)
	return button


func _label(parent: Control, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
