extends Control
## The Book of Runes (from the pause menu), on two pages:
##   Runes: the 24 runes by Kin, each with its historical meaning, role in the grammar,
##          Position, Power and Voice;
##   Table of Spells (docs/GRAMATICA.md 5): an 8 × 8 grid, Elements in columns and Targets
##          in rows; discovered spells show their name (the mouse card tells the effect),
##          the others "?" (a Torn Page from the Market adds its verse); under it the 8
##          Actions, learned or not;
##   Words: every Word with the highest level it ever reached; hidden ones stay "???".

signal closed

const MiniStone = preload("res://scripts/ui/mini_stone.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")
const Progress = preload("res://scripts/core/progress.gd")

const PANEL_SIZE: Vector2 = Vector2(1680, 980)
const RUNE_COLUMNS: int = 4
const ENTRY_WIDTH: float = 390.0
const CELL_SIZE: Vector2 = Vector2(170, 58)
const HEADER_WIDTH: float = 210.0
const PAGES: Array[String] = ["runes", "spells", "words"]
const TORN_COLOR: Color = Color("#e9d3a0")

var _title: Label
var _hint: Label
var _content: VBoxContainer
var _scroll: ScrollContainer
var _close_button: Button
var _tabs: HBoxContainer
var _page: String = "runes"


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
	_tabs = HBoxContainer.new()
	_tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	_tabs.add_theme_constant_override("separation", 12)
	box.add_child(_tabs)
	for page: String in PAGES:
		var tab: Button = Button.new()
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(300, 56)
		tab.pressed.connect(_show_page.bind(page))
		_tabs.add_child(tab)
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


func open(page: String = "runes") -> void:
	_page = page
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


func _show_page(page: String) -> void:
	_page = page
	_build()
	_scroll.scroll_vertical = 0


func _build() -> void:
	_title.text = Loc.t("rune_book_title")
	_hint.text = Loc.t("rune_book_hint")
	_close_button.text = Loc.t("rune_book_close")
	for i: int in PAGES.size():
		var tab: Button = _tabs.get_child(i)
		tab.text = Loc.t("rune_book_tab_" + PAGES[i])
		tab.button_pressed = PAGES[i] == _page
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	match _page:
		"spells":
			_build_table()
		"words":
			_build_words()
		_:
			_build_runes()


func _build_runes() -> void:
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


## The Table of Spells and the Actions under it.
func _build_table() -> void:
	var elements: Array[String] = []
	var targets: Array[String] = []
	var found: int = 0
	var total: int = 0
	for id: String in GameData.spells:
		var spell: Dictionary = GameData.spells[id]
		if not elements.has(str(spell["element"])):
			elements.append(str(spell["element"]))
		if not targets.has(str(spell["target"])):
			targets.append(str(spell["target"]))
		if bool(spell.get("enabled", false)):
			total += 1
			if SaveManager.has_discovery("spells", id):
				found += 1
	var count: Label = _label(_content, Loc.t("rune_book_spells", {"n": found, "total": total}), 36, &"TitleLabel")
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var grid: GridContainer = GridContainer.new()
	grid.columns = elements.size() + 1
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_content.add_child(grid)
	var corner: Label = _label(grid, Loc.t("rune_book_table_corner"), 18, &"SecondaryLabel")
	corner.custom_minimum_size = Vector2(HEADER_WIDTH, 0)
	corner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for element: String in elements:
		grid.add_child(_header(element, true))
	for target: String in targets:
		grid.add_child(_header(target, false))
		for element: String in elements:
			grid.add_child(_cell("%s_%s" % [element, target]))
	_label(_content, Loc.t("rune_book_actions"), 36, &"TitleLabel")
	var actions: GridContainer = GridContainer.new()
	actions.columns = RUNE_COLUMNS
	actions.add_theme_constant_override("h_separation", 10)
	actions.add_theme_constant_override("v_separation", 10)
	_content.add_child(actions)
	for action_id: String in GameData.spell_actions:
		actions.add_child(_action_entry(action_id))


## A column (Element) or row (Target) heading: the rune and its phrase.
func _header(rune_id: String, column: bool) -> Control:
	var rune: Dictionary = GameData.runes.get(rune_id, {})
	var box: BoxContainer = VBoxContainer.new() if column else HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.custom_minimum_size = Vector2(CELL_SIZE.x, 0) if column else Vector2(HEADER_WIDTH, CELL_SIZE.y)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.tooltip_text = "%s · %s" % [Loc.text(rune.get("name", {})), Loc.text(rune.get("phrase", {}))]
	var mini: MiniStone = MiniStone.new()
	mini.rune_id = rune_id
	mini.show_role = true
	mini.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mini.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(mini)
	var label: Label = _label(box, Loc.text(rune.get("phrase", {})), 19, &"SecondaryLabel")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(CELL_SIZE.x - 8.0, 0) if column else Vector2(HEADER_WIDTH - 60.0, 0)
	return box


## One spell of the table: its name once discovered, "?" before, dim while it sleeps.
func _cell(spell_id: String) -> Control:
	var spell: Dictionary = GameData.spells.get(spell_id, {})
	var cell: PanelContainer = PanelContainer.new()
	cell.theme_type_variation = &"TooltipPanel"
	cell.custom_minimum_size = CELL_SIZE
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	var label: Label = _label(cell, "?", 22, &"")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var sentence: String = SpellText.sentence([spell.get("element", ""), spell.get("target", "")])
	if not bool(spell.get("enabled", false)):
		cell.modulate.a = 0.35
		label.text = "·"
		cell.tooltip_text = "%s\n%s" % [sentence, Loc.t("sentence_dormant")]
	elif SaveManager.has_discovery("spells", spell_id):
		label.text = Loc.text(spell["name"])
		label.add_theme_color_override("font_color", Color.html(str(spell.get("color", "#e9e3d2"))))
		cell.tooltip_text = "%s\n%s: %s" % [sentence, Loc.text(spell["name"]), SpellText.effect(spell)]
	elif SaveManager.has_discovery("torn_pages", spell_id):
		label.text = Loc.t("rune_book_torn")
		label.add_theme_color_override("font_color", TORN_COLOR)
		cell.tooltip_text = "%s\n„%s”" % [sentence, Loc.text(spell.get("verse", {}))]
	else:
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
		cell.tooltip_text = "%s\n%s" % [sentence, Loc.t("sentence_unknown")]
	return cell


## The Words from the strongest down, each with the highest level it reached in any exam.
func _build_words() -> void:
	var ids: Array = GameData.words.keys()
	ids.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(GameData.words[a].get("rank", 0)) > int(GameData.words[b].get("rank", 0)))
	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	_content.add_child(grid)
	for id: Variant in ids:
		grid.add_child(_word_entry(str(id)))


func _word_entry(word_id: String) -> Control:
	var word: Dictionary = GameData.words[word_id]
	var entry: PanelContainer = PanelContainer.new()
	entry.theme_type_variation = &"TooltipPanel"
	entry.custom_minimum_size = Vector2(ENTRY_WIDTH * 4.0 / 3.0, 0)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	entry.add_child(box)
	if bool(word.get("hidden", false)) and not SaveManager.has_discovery("words", word_id):
		_label(box, "???", 30, &"TitleLabel")
		_wrapped(box, Loc.t("rune_book_word_hidden"), 20, &"SecondaryLabel")
		return entry
	_label(box, Loc.text(word["name"]), 30, &"TitleLabel")
	_wrapped(box, Loc.text(word["description"]), 19, &"")
	var example: HBoxContainer = HBoxContainer.new()
	example.add_theme_constant_override("separation", 4)
	box.add_child(example)
	for rune_id: Variant in word.get("example", []):
		var mini: MiniStone = MiniStone.new()
		mini.rune_id = str(rune_id)
		example.add_child(mini)
	_label(box, Loc.t("rune_book_word_values", {"power": word["base_power"], "res": Loc.number(float(word["base_res"]))}),
		19, &"SecondaryLabel")
	var best: Label = _label(box, Loc.t("rune_book_word_best", {"n": Progress.best_word_level(SaveManager.data, word_id)}),
		22, &"")
	best.add_theme_color_override("font_color", TORN_COLOR)
	return entry


func _action_entry(action_id: String) -> Control:
	var rune: Dictionary = GameData.runes.get(action_id, {})
	var learned: bool = SaveManager.has_discovery("actions", action_id)
	var entry: PanelContainer = PanelContainer.new()
	entry.theme_type_variation = &"TooltipPanel"
	entry.custom_minimum_size = Vector2(ENTRY_WIDTH, 0)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	entry.add_child(row)
	var mini: MiniStone = MiniStone.new()
	mini.rune_id = action_id
	mini.show_role = true
	mini.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(mini)
	var text: VBoxContainer = VBoxContainer.new()
	text.add_theme_constant_override("separation", 0)
	row.add_child(text)
	_label(text, Loc.text(rune.get("phrase", {})), 28, &"TitleLabel")
	var effect: String = Loc.text((GameData.spell_actions[action_id] as Dictionary).get("effect", {})) if learned \
		else Loc.t("rune_book_action_unknown")
	_wrapped(text, effect, 20, &"" if learned else &"SecondaryLabel")
	return entry


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
	_label(text, Loc.t("card_role", {"role": Loc.t("role_" + str(rune.get("role", ""))),
		"phrase": Loc.text(rune.get("phrase", {}))}), 19, &"SecondaryLabel")
	_wrapped(text, Loc.text(rune["meaning"]), 20, &"")
	_wrapped(text, Loc.t("card_voice", {"voice": Loc.text(rune["voice"])}), 19, &"SecondaryLabel")
	return entry


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
