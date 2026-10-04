extends Control
## The Collection (DESIGN 3.11), from the Morning: every Talisman, Engraving and examiner the
## player has seen at least once; the others stay "???". Saved in SaveManager.data["collection"]
## (scripts/core/progress.gd records what is seen).

const Portrait = preload("res://scripts/ui/portrait.gd")
const Progress = preload("res://scripts/core/progress.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")

const MORNING_SCENE: String = "res://scenes/morning.tscn"
const CARD_SIZE: Vector2 = Vector2(330, 260)
const RARITY_COLORS: Dictionary = {
	"common": Color("#c9c2ad"), "rare": Color("#63c6f2"), "legendary": Color("#ffb347"),
}
const RULE_COLOR: Color = Color("#ffb347")

@onready var _content: Control = %Content

var _page: String = "talismans"
var _tabs: HBoxContainer
var _count: Label
var _grid: HFlowContainer
var _scroll: ScrollContainer


func _ready() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 50)
	_content.add_child(margin)
	var panel: PanelContainer = PanelContainer.new()
	margin.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var title: Label = _label(box, Loc.t("collection_title"), 60, &"TitleLabel")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tabs = HBoxContainer.new()
	_tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	_tabs.add_theme_constant_override("separation", 12)
	box.add_child(_tabs)
	for page: String in Progress.COLLECTION:
		var tab: Button = Button.new()
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(300, 56)
		tab.text = Loc.t("collection_tab_" + page)
		tab.pressed.connect(_show.bind(page))
		_tabs.add_child(tab)
	_count = _label(box, "", 24, &"SecondaryLabel")
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(_scroll)
	_grid = HFlowContainer.new()
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	_scroll.add_child(_grid)
	var back: Button = Button.new()
	back.text = Loc.t("parents_back")
	back.custom_minimum_size = Vector2(320, 64)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_go_back)
	box.add_child(back)
	_show(_page)
	(_tabs.get_child(0) as Button).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _show(page: String) -> void:
	_page = page
	for i: int in Progress.COLLECTION.size():
		(_tabs.get_child(i) as Button).button_pressed = Progress.COLLECTION[i] == page
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	var table: Dictionary = _table(page)
	var seen: int = 0
	for id: String in table:
		var known: bool = Progress.has_seen(SaveManager.data, page, id)
		if known:
			seen += 1
		_grid.add_child(_card(page, id, table[id], known))
	_count.text = Loc.t("collection_count", {"n": seen, "total": table.size()})
	_scroll.scroll_vertical = 0


func _table(page: String) -> Dictionary:
	match page:
		"talismans":
			return GameData.talismans
		"engravings":
			return GameData.engravings
	return GameData.monsters


func _card(page: String, id: String, entry: Dictionary, known: bool) -> Control:
	var card: PanelContainer = PanelContainer.new()
	card.theme_type_variation = &"TooltipPanel"
	card.custom_minimum_size = CARD_SIZE
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)
	if not known:
		box.modulate = Color(1, 1, 1, 0.5)
		var unknown: Label = _label(box, Loc.t("collection_unknown"), 48, &"TitleLabel")
		unknown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_wrapped(box, Loc.t("collection_unknown_" + page), 20, &"SecondaryLabel").horizontal_alignment = \
			HORIZONTAL_ALIGNMENT_CENTER
		return card
	match page:
		"talismans":
			var rarity: String = str(entry.get("rarity", "common"))
			_label(box, Loc.t("rarity_" + rarity), 18, &"").add_theme_color_override("font_color",
				RARITY_COLORS.get(rarity, Color.WHITE))
			_wrapped(box, Loc.text(entry.get("name", {})), 26, &"TitleLabel")
			var value: String = Loc.number(float(entry.get("value", 0)))
			_wrapped(box, Loc.text(entry.get("description", {}), {"value": value, "now": value,
				"step": Loc.number(float(entry.get("step", 0)))}), 19, &"")
		"engravings":
			_label(box, Loc.t("consumable_engraving"), 18, &"").add_theme_color_override("font_color", RULE_COLOR)
			_wrapped(box, Loc.text(entry.get("name", {})), 26, &"TitleLabel")
			var values: Dictionary = {}
			for key: String in ["value", "count"]:
				if entry.has(key):
					values[key] = Loc.number(float(entry[key]))
			_wrapped(box, Loc.text(entry.get("text", {}), values), 19, &"")
		"monsters":
			var row: HBoxContainer = HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			box.add_child(row)
			var portrait: Portrait = Portrait.new()
			portrait.custom_minimum_size = Vector2(80, 80)
			portrait.character_id = id
			row.add_child(portrait)
			var who: VBoxContainer = VBoxContainer.new()
			row.add_child(who)
			_wrapped(who, Loc.text(entry.get("name", {})), 26, &"TitleLabel").custom_minimum_size.x = CARD_SIZE.x - 130.0
			_label(who, Loc.t("monster_kind_" + str(entry.get("kind", "small"))), 18, &"").add_theme_color_override(
				"font_color", RULE_COLOR)
			if entry.has("rule_text"):
				_wrapped(box, SpellText.rule_text(entry), 19, &"")
			_wrapped(box, Loc.text(entry.get("description", {})), 18, &"SecondaryLabel")
	return card


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
