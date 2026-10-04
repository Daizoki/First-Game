extends Control
## The Book of Words: every Word from the strongest to the most common, each with an example
## drawn in small stones, its description, its current level and Power × Resonance.
## The Ancient Word stays "???" until discovered. Opens from the round screen (button or key).

signal closed

const MiniStone = preload("res://scripts/ui/mini_stone.gd")

const PANEL_SIZE: Vector2 = Vector2(1320, 940)

var _title: Label
var _hint: Label
var _rows: VBoxContainer
var _close_button: Button
## word id -> level (from the round).
var _levels: Dictionary = {}


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0196078, 0.0235294, 0.0392157, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(_on_dim_input)
	add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	center.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	_title = Label.new()
	_title.theme_type_variation = &"TitleLabel"
	_title.add_theme_font_size_override("font_size", 56)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)
	_hint = Label.new()
	_hint.theme_type_variation = &"SecondaryLabel"
	_hint.add_theme_font_size_override("font_size", 22)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_hint)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 6)
	scroll.add_child(_rows)
	_close_button = Button.new()
	_close_button.custom_minimum_size = Vector2(320, 64)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close_button.pressed.connect(close)
	box.add_child(_close_button)
	Loc.language_changed.connect(func(_language: String) -> void:
		if visible:
			_build())


## Opens the book with the round's current Word levels.
func open(levels: Dictionary) -> void:
	_levels = levels
	_build()
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


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		close()


func _build() -> void:
	_title.text = Loc.t("word_book_title")
	_hint.text = Loc.t("word_book_hint")
	_close_button.text = Loc.t("word_book_close")
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	var ids: Array = GameData.words.keys()
	ids.sort_custom(func(a: String, b: String) -> bool:
		return int(GameData.words[a]["rank"]) > int(GameData.words[b]["rank"]))
	for id: String in ids:
		_rows.add_child(_row(id))


func _row(word_id: String) -> Control:
	var word: Dictionary = GameData.words[word_id]
	var known: bool = not bool(word.get("hidden", false)) or SaveManager.has_discovery("words", word_id)
	var level: int = int(_levels.get(word_id, 1))
	var power: float = float(word["base_power"]) + float(word["level_power"]) * (level - 1)
	var res: float = float(word["base_res"]) + float(word["level_res"]) * (level - 1)
	var row: PanelContainer = PanelContainer.new()
	row.theme_type_variation = &"TooltipPanel"
	var line: HBoxContainer = HBoxContainer.new()
	line.add_theme_constant_override("separation", 18)
	row.add_child(line)
	var name_label: Label = _label(Loc.text(word["name"]) if known else Loc.t("word_hidden"), 32, &"TitleLabel")
	name_label.custom_minimum_size = Vector2(250, 0)
	line.add_child(name_label)
	var stones: HBoxContainer = HBoxContainer.new()
	stones.custom_minimum_size = Vector2(5 * 50, 0)
	stones.add_theme_constant_override("separation", 4)
	line.add_child(stones)
	for id: Variant in word.get("example", []):
		var mini: MiniStone = MiniStone.new()
		mini.rune_id = str(id)
		mini.blank = not known
		stones.add_child(mini)
	var description: Label = _label(Loc.text(word["description"]) if known else Loc.t("word_hidden"), 23, &"")
	description.custom_minimum_size = Vector2(400, 0)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(description)
	var values: VBoxContainer = VBoxContainer.new()
	values.custom_minimum_size = Vector2(190, 0)
	values.add_theme_constant_override("separation", -2)
	line.add_child(values)
	values.add_child(_label(Loc.t("circle_level", {"n": level}), 20, &"SecondaryLabel"))
	values.add_child(_label(Loc.t("word_book_values", {"power": Loc.number(power), "res": Loc.number(res)})
		if known else Loc.t("word_hidden"), 28, &""))
	return row


func _label(text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return label
