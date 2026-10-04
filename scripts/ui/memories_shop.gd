extends Control
## Memories (DESIGN 3.11), opened from the Morning: spend Memories on the parents that cost
## them and on Talismans for the Night Market (only some are on sale at first).
## The rules are in scripts/core/progress.gd.

signal closed

const Portrait = preload("res://scripts/ui/portrait.gd")
const Progress = preload("res://scripts/core/progress.gd")

const PANEL_SIZE: Vector2 = Vector2(1640, 940)
const CARD_SIZE: Vector2 = Vector2(300, 300)
const MEMORY_COLOR: Color = Color("#b59be0")
const RARITY_COLORS: Dictionary = {
	"common": Color("#c9c2ad"), "rare": Color("#63c6f2"), "legendary": Color("#ffb347"),
}

var _memories: Label
var _content: VBoxContainer
var _close_button: Button


func _ready() -> void:
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.05, 0.85)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	center.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var title: Label = _label(box, Loc.t("unlocks_title"), 56, &"TitleLabel")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var text: Label = _label(box, Loc.t("unlocks_text"), 22, &"SecondaryLabel")
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_memories = _label(box, "", 34, &"TitleLabel")
	_memories.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_memories.add_theme_color_override("font_color", MEMORY_COLOR)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 14)
	scroll.add_child(_content)
	_close_button = Button.new()
	_close_button.text = Loc.t("close")
	_close_button.custom_minimum_size = Vector2(320, 64)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close_button.pressed.connect(close)
	box.add_child(_close_button)


func open() -> void:
	_refresh()
	visible = true
	_close_button.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _refresh() -> void:
	_memories.text = Loc.t("morning_memories", {"n": Progress.memories(SaveManager.data)})
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_label(_content, Loc.t("unlocks_parents"), 36, &"TitleLabel")
	var parents: HFlowContainer = _flow()
	for id: String in GameData.parents:
		var parent: Dictionary = GameData.parents[id]
		if str(parent["unlock"]) != "start":
			parents.add_child(_parent_card(parent))
	_label(_content, Loc.t("unlocks_talismans"), 36, &"TitleLabel")
	var talismans: HFlowContainer = _flow()
	for id: String in GameData.talismans:
		if int((GameData.talismans[id] as Dictionary).get("unlock", 0)) > 0:
			talismans.add_child(_talisman_card(id))


func _flow() -> HFlowContainer:
	var flow: HFlowContainer = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 14)
	flow.add_theme_constant_override("v_separation", 14)
	_content.add_child(flow)
	return flow


func _parent_card(parent: Dictionary) -> Control:
	var id: String = str(parent["id"])
	var box: VBoxContainer = _card()
	var portrait: Portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(96, 96)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait.character_id = id
	box.add_child(portrait)
	_label(box, Loc.text((GameData.characters.get(id, {}) as Dictionary).get("name", {})), 28, &"TitleLabel")
	_wrapped(box, Loc.text(parent["bonus"]), 19)
	var available: bool = Progress.parent_available(SaveManager.data, parent)
	if available:
		_status(box, Loc.t("unlocks_owned"))
	elif str(parent["unlock"]) == "attempts":
		_status(box, Loc.t("unlocks_after_exam"))
	else:
		var buy: Button = _buy_button(box, int(parent["cost"]), Progress.can_buy_parent(SaveManager.data, parent))
		buy.pressed.connect(func() -> void:
			if Progress.buy_parent(SaveManager.data, parent):
				SaveManager.save_game()
				_refresh())
	return box.get_parent()


func _talisman_card(id: String) -> Control:
	var entry: Dictionary = GameData.talismans[id]
	var box: VBoxContainer = _card()
	var rarity: String = str(entry.get("rarity", "common"))
	var kind: Label = _label(box, Loc.t("rarity_" + rarity), 18, &"")
	kind.add_theme_color_override("font_color", RARITY_COLORS.get(rarity, Color.WHITE))
	var name_label: Label = _wrapped(box, Loc.text(entry.get("name", {})), 26)
	name_label.theme_type_variation = &"TitleLabel"
	var value: String = Loc.number(float(entry.get("value", 0)))
	_wrapped(box, Loc.text(entry.get("description", {}), {"value": value, "step": Loc.number(float(entry.get("step", 0))),
		"now": value}), 19)
	if Progress.talisman_unlocked(SaveManager.data, GameData.talismans, id):
		_status(box, Loc.t("unlocks_owned"))
	else:
		var buy: Button = _buy_button(box, int(entry["unlock"]), Progress.can_buy_talisman(SaveManager.data, GameData.talismans, id))
		buy.pressed.connect(func() -> void:
			if Progress.buy_talisman(SaveManager.data, GameData.talismans, id):
				SaveManager.save_game()
				_refresh())
	return box.get_parent()


func _card() -> VBoxContainer:
	var card: PanelContainer = PanelContainer.new()
	card.theme_type_variation = &"TooltipPanel"
	card.custom_minimum_size = CARD_SIZE
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)
	return box


func _buy_button(parent: Control, cost: int, affordable: bool) -> Button:
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(spacer)
	var button: Button = Button.new()
	button.text = Loc.t("unlocks_buy", {"n": cost})
	button.custom_minimum_size = Vector2(0, 52)
	button.disabled = not affordable
	parent.add_child(button)
	return button


func _status(parent: Control, text: String) -> void:
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(spacer)
	var label: Label = _label(parent, text, 22, &"SecondaryLabel")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _wrapped(parent: Control, text: String, font_size: int) -> Label:
	var label: Label = _label(parent, text, font_size, &"")
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
