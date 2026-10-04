extends Control
## Choosing the divine parent before an exam (DESIGN 3.10): five cards with the parent's
## portrait, what they give and what they say. A locked parent says how it opens up.
## Choosing one starts the exam (scenes/exam.tscn) with that parent.

const Portrait = preload("res://scripts/ui/portrait.gd")
const Progress = preload("res://scripts/core/progress.gd")

const EXAM_SCENE: String = "res://scenes/exam.tscn"
const MORNING_SCENE: String = "res://scenes/morning.tscn"
const CARD_SIZE: Vector2 = Vector2(320, 620)

@onready var _content: Control = %Content


func _ready() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 50)
	_content.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(box)
	var title: Label = _label(box, Loc.t("parents_title"), 64, &"TitleLabel")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var aeva: Label = _label(box, "%s: „%s”" % [Loc.text((GameData.characters.get("aeva", {}) as Dictionary).get("name", {})),
		Loc.t("parents_aeva")], 26, &"SecondaryLabel")
	aeva.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	box.add_child(row)
	var first: Button = null
	for id: String in GameData.parents:
		var button: Button = _card(row, GameData.parents[id])
		if first == null and button != null:
			first = button
	var back: Button = Button.new()
	back.text = Loc.t("parents_back")
	back.custom_minimum_size = Vector2(320, 64)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_go_back)
	box.add_child(back)
	if first != null:
		first.grab_focus()
	else:
		back.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


## One parent's card. Returns its Choose button (null when the parent is locked).
func _card(row: Control, parent: Dictionary) -> Button:
	var id: String = str(parent["id"])
	var character: Dictionary = GameData.characters.get(id, {})
	var available: bool = Progress.parent_available(SaveManager.data, parent)
	var card: PanelContainer = PanelContainer.new()
	card.theme_type_variation = &"TooltipPanel"
	card.custom_minimum_size = CARD_SIZE
	row.add_child(card)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)
	# A locked parent fades, but the card stays solid over the background.
	if not available:
		box.modulate = Color(1, 1, 1, 0.5)
	var portrait: Portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(150, 150)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait.character_id = id
	box.add_child(portrait)
	var name_label: Label = _label(box, Loc.text(character.get("name", {})), 40, &"TitleLabel")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var domain: Label = _wrapped(box, "%s · %s" % [Loc.text(character.get("domain", {})), Loc.text(character.get("job", {}))],
		19, &"SecondaryLabel")
	domain.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bonus: Label = _wrapped(box, Loc.text(parent["bonus"]), 24, &"")
	bonus.add_theme_color_override("font_color", Color("#ffb347"))
	_wrapped(box, "„%s”" % Loc.text(parent["line"]), 20, &"SecondaryLabel")
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	if not available:
		var locked: String = Loc.t("parents_locked_attempts") if str(parent["unlock"]) == "attempts" \
			else Loc.t("parents_locked_memories", {"n": int(parent["cost"])})
		_wrapped(box, locked, 20, &"SecondaryLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return null
	var choose: Button = Button.new()
	choose.text = Loc.t("parents_choose")
	choose.custom_minimum_size = Vector2(0, 64)
	choose.theme_type_variation = &"CastButton"
	choose.pressed.connect(_choose.bind(id))
	box.add_child(choose)
	return choose


func _choose(parent_id: String) -> void:
	RunState.request_exam(parent_id, false)
	get_tree().change_scene_to_file(EXAM_SCENE)


func _go_back() -> void:
	get_tree().change_scene_to_file(MORNING_SCENE)


func _wrapped(parent: Control, text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = _label(parent, text, font_size, variation)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(CARD_SIZE.x - 30.0, 0)
	return label


func _label(parent: Control, text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
