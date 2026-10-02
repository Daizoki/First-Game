extends Control
## The Book of Runes (from the pause menu): the 24 runes by Kin, each with its historical
## meaning, Position, Power and Voice; then the Spells. A Spell shows its runes, name and
## effect once discovered; until then it is "???" with blank stones.

signal closed

const MiniStone = preload("res://scripts/ui/mini_stone.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")

const PANEL_SIZE: Vector2 = Vector2(1680, 980)
const RUNE_COLUMNS: int = 4
const ENTRY_WIDTH: float = 390.0

var _title: Label
var _hint: Label
var _content: VBoxContainer
var _scroll: ScrollContainer
var _close_button: Button


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0196078, 0.0235294, 0.0392157, 0.85)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	center.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	_title = _label(box, "", 56, &"TitleLabel")
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint = _label(box, "", 22, &"SecondaryLabel")
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(_scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 10)
	_scroll.add_child(_content)
	_close_button = Button.new()
	_close_button.custom_minimum_size = Vector2(320, 64)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close_button.pressed.connect(close)
	box.add_child(_close_button)
	Loc.language_changed.connect(func(_language: String) -> void:
		if visible:
			_build())


func open() -> void:
	_build()
	visible = true
	_scroll.scroll_vertical = 0
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


func _build() -> void:
	_title.text = Loc.t("rune_book_title")
	_hint.text = Loc.t("rune_book_hint")
	_close_button.text = Loc.t("rune_book_close")
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	for kin_id: String in GameData.kins:
		var kin: Dictionary = GameData.kins[kin_id]
		var heading: Label = _label(_content, Loc.text(kin["name"]), 36, &"TitleLabel")
		heading.add_theme_color_override("font_color", GameData.kin_color(kin_id))
		var grid: GridContainer = GridContainer.new()
		grid.columns = RUNE_COLUMNS
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		_content.add_child(grid)
		for rune: Dictionary in GameData.runes_in_kin(kin_id):
			grid.add_child(_rune_entry(rune))
	var found: int = 0
	for id: String in GameData.spells:
		if SaveManager.has_discovery("spells", id):
			found += 1
	_label(_content, Loc.t("rune_book_spells", {"n": found, "total": GameData.spells.size()}), 40, &"TitleLabel")
	for id: String in GameData.spells:
		_content.add_child(_spell_row(id))


func _rune_entry(rune: Dictionary) -> Control:
	var entry: PanelContainer = PanelContainer.new()
	entry.theme_type_variation = &"TooltipPanel"
	entry.custom_minimum_size = Vector2(ENTRY_WIDTH, 0)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	entry.add_child(row)
	var glyph: RuneGlyphScript = RuneGlyphScript.new()
	glyph.custom_minimum_size = Vector2(72, 72)
	glyph.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	glyph.rune_id = str(rune["id"])
	row.add_child(glyph)
	var text: VBoxContainer = VBoxContainer.new()
	text.add_theme_constant_override("separation", 0)
	row.add_child(text)
	_label(text, Loc.text(rune["name"]), 30, &"TitleLabel")
	_label(text, Loc.t("rune_book_position", {"n": rune["position"], "power": rune["base_power"]}), 19, &"SecondaryLabel")
	_wrapped(text, Loc.text(rune["meaning"]), 20, &"")
	_wrapped(text, Loc.t("card_voice", {"voice": Loc.text(rune["voice"])}), 19, &"SecondaryLabel")
	return entry


func _spell_row(spell_id: String) -> Control:
	var spell: Dictionary = GameData.spells[spell_id]
	var known: bool = SaveManager.has_discovery("spells", spell_id)
	var row: PanelContainer = PanelContainer.new()
	row.theme_type_variation = &"TooltipPanel"
	var line: HBoxContainer = HBoxContainer.new()
	line.add_theme_constant_override("separation", 18)
	row.add_child(line)
	var stones: HBoxContainer = HBoxContainer.new()
	stones.custom_minimum_size = Vector2(3 * 50, 0)
	stones.add_theme_constant_override("separation", 4)
	line.add_child(stones)
	for id: Variant in spell["runes"]:
		var mini: MiniStone = MiniStone.new()
		mini.rune_id = str(id)
		mini.blank = not known
		stones.add_child(mini)
	var name_label: Label = _label(line, Loc.text(spell["name"]) if known else Loc.t("word_hidden"), 32, &"TitleLabel")
	name_label.custom_minimum_size = Vector2(260, 0)
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if known:
		name_label.add_theme_color_override("font_color", Color.html(str(spell.get("color", "#e9e3d2"))))
	var text: VBoxContainer = VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text.add_theme_constant_override("separation", 0)
	line.add_child(text)
	if known:
		_wrapped(text, Loc.text(spell["logic"]), 20, &"SecondaryLabel")
		_wrapped(text, Loc.text(spell["effect"]), 24, &"")
	else:
		_wrapped(text, Loc.t("rune_book_spell_hidden"), 22, &"SecondaryLabel")
	return row


func _wrapped(parent: Control, text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = _label(parent, text, font_size, variation)
	label.custom_minimum_size = Vector2(ENTRY_WIDTH - 120.0, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _label(parent: Control, text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
