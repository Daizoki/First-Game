extends Control
## The player writes their name (used by the characters, e.g. Master Ilinca's first line).
## Then the evening class starts if it was never finished or skipped.

const NAME_MAX_LENGTH: int = 20
const TUTORIAL_SCENE: String = "res://scenes/tutorial.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

@onready var _title: Label = %Title
@onready var _hint: Label = %Hint
@onready var _name_edit: LineEdit = %NameEdit
@onready var _ok_button: Button = %OkButton


func _ready() -> void:
	_name_edit.max_length = NAME_MAX_LENGTH
	_name_edit.text = str(SaveManager.data.get("player_name", ""))
	_name_edit.text_changed.connect(func(_text: String) -> void: _refresh_button())
	_name_edit.text_submitted.connect(func(_text: String) -> void: _confirm())
	_ok_button.pressed.connect(_confirm)
	Loc.language_changed.connect(func(_language: String) -> void: _refresh_texts())
	_refresh_texts()
	_name_edit.grab_focus()


func _refresh_texts() -> void:
	_title.text = Loc.t("name_title")
	_hint.text = Loc.t("name_hint")
	_name_edit.placeholder_text = Loc.t("name_placeholder")
	_ok_button.text = Loc.t("name_ok")
	_refresh_button()


func _refresh_button() -> void:
	_ok_button.disabled = clean_name(_name_edit.text).is_empty()


func _confirm() -> void:
	var player_name: String = clean_name(_name_edit.text)
	if player_name.is_empty():
		return
	SaveManager.data["player_name"] = player_name
	SaveManager.save_game()
	var done: bool = bool(SaveManager.data.get("tutorial_done", false))
	get_tree().change_scene_to_file(MAIN_MENU_SCENE if done else TUTORIAL_SCENE)


## Trims spaces and limits the length.
static func clean_name(raw: String) -> String:
	return raw.strip_edges().left(NAME_MAX_LENGTH)
