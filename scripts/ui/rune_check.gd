extends Control
## Check screen: all 24 runes drawn from code, one row per kin, so Relax can compare the
## shapes with a reference table. Hover a rune to read its meaning and Voice.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")
const GLYPH_SIZE: Vector2 = Vector2(124, 124)

@onready var _title: Label = %Title
@onready var _hint: Label = %Hint
@onready var _rows: VBoxContainer = %Rows
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_back_button.pressed.connect(_go_back)
	Loc.language_changed.connect(_on_language_changed)
	_refresh()
	_back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _refresh() -> void:
	_title.text = Loc.t("rune_check_title")
	_hint.text = Loc.t("rune_check_hint")
	_back_button.text = Loc.t("settings_back")
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	for kin_id: String in GameData.kins:
		_rows.add_child(_make_kin_row(kin_id))


func _make_kin_row(kin_id: String) -> Control:
	var kin: Dictionary = GameData.kins[kin_id]
	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var kin_label: Label = Label.new()
	kin_label.text = Loc.text(kin["name"])
	kin_label.add_theme_color_override("font_color", GameData.kin_color(kin_id))
	kin_label.theme_type_variation = &"TitleLabel"
	kin_label.add_theme_font_size_override("font_size", 36)
	row.add_child(kin_label)

	var runes_box: HBoxContainer = HBoxContainer.new()
	runes_box.add_theme_constant_override("separation", 56)
	for rune: Dictionary in GameData.runes_in_kin(kin_id):
		runes_box.add_child(_make_rune_cell(rune))
	row.add_child(runes_box)
	return row


func _make_rune_cell(rune: Dictionary) -> Control:
	var cell: VBoxContainer = VBoxContainer.new()
	cell.add_theme_constant_override("separation", 0)

	var glyph: RuneGlyphScript = RuneGlyphScript.new()
	glyph.custom_minimum_size = GLYPH_SIZE
	glyph.rune_id = rune["id"]
	glyph.tooltip_text = Loc.t("rune_tooltip", {
		"meaning": Loc.text(rune["meaning"]),
		"does": SpellText.rune_role(str(rune["id"])),
	})
	cell.add_child(glyph)

	var name_label: Label = Label.new()
	name_label.text = Loc.text(rune["name"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
	cell.add_child(name_label)

	var position_label: Label = Label.new()
	position_label.text = Loc.t("role_" + str(rune.get("role", "")))
	position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	position_label.theme_type_variation = &"SecondaryLabel"
	position_label.add_theme_font_size_override("font_size", 22)
	cell.add_child(position_label)
	return cell


func _go_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_language_changed(_language: String) -> void:
	_refresh()
