extends Control
## Settings: language, volume, replaying the evening class, hints on / off, the player's name.
## Every change is saved in user://save.json.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const TUTORIAL_SCENE: String = "res://scenes/tutorial.tscn"
const NAME_SCENE: String = "res://scenes/name_entry.tscn"

@onready var _title: Label = %Title
@onready var _language_label: Label = %LanguageLabel
@onready var _language_option: OptionButton = %LanguageOption
@onready var _volume_label: Label = %VolumeLabel
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_value: Label = %VolumeValue
@onready var _tutorial_label: Label = %TutorialLabel
@onready var _replay_button: Button = %ReplayTutorialButton
@onready var _hints_label: Label = %HintsLabel
@onready var _hints_button: CheckButton = %HintsButton
@onready var _name_label: Label = %NameLabel
@onready var _name_button: Button = %NameButton
@onready var _back_button: Button = %BackButton

var _volume_dirty: bool = false


func _ready() -> void:
	_language_option.clear()
	for code: String in Loc.LANGUAGES:
		_language_option.add_item(code)
	_language_option.select(Loc.LANGUAGES.find(Loc.language))
	_volume_slider.value = float(SaveManager.get_setting("volume", SaveManager.DEFAULT_VOLUME))

	_language_option.item_selected.connect(_on_language_selected)
	_volume_slider.value_changed.connect(_on_volume_changed)
	_volume_slider.drag_ended.connect(_on_volume_drag_ended)
	_hints_button.button_pressed = bool(SaveManager.get_setting("hints_enabled", true))
	_hints_button.toggled.connect(_on_hints_toggled)
	_replay_button.pressed.connect(_on_replay_pressed)
	_back_button.pressed.connect(_go_back)
	_name_button.pressed.connect(func() -> void:
		RunState.renaming = true
		get_tree().change_scene_to_file(NAME_SCENE))
	Loc.language_changed.connect(_on_language_changed)

	_refresh_texts()
	_language_option.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _exit_tree() -> void:
	_save_volume_if_needed()


func _refresh_texts() -> void:
	_title.text = Loc.t("settings_title")
	_language_label.text = Loc.t("settings_language")
	_volume_label.text = Loc.t("settings_volume")
	_back_button.text = Loc.t("settings_back")
	_tutorial_label.text = Loc.t("settings_tutorial")
	_replay_button.text = Loc.t("settings_tutorial_replay")
	_hints_label.text = Loc.t("settings_hints")
	_name_label.text = Loc.t("settings_name", {"name": str(SaveManager.data.get("player_name", ""))})
	_name_button.text = Loc.t("settings_change_name")
	_hints_button.text = Loc.t("settings_on") if _hints_button.button_pressed else Loc.t("settings_off")
	for i: int in Loc.LANGUAGES.size():
		_language_option.set_item_text(i, Loc.t("language_" + str(Loc.LANGUAGES[i])))
	_update_volume_text()


func _update_volume_text() -> void:
	_volume_value.text = Loc.t("settings_volume_value", {"value": roundi(_volume_slider.value * 100.0)})


func _on_language_selected(index: int) -> void:
	var code: String = Loc.LANGUAGES[index]
	Loc.set_language(code)
	SaveManager.set_setting("language", code)


func _on_hints_toggled(on: bool) -> void:
	SaveManager.set_setting("hints_enabled", on)
	_refresh_texts()


func _on_replay_pressed() -> void:
	_save_volume_if_needed()
	get_tree().change_scene_to_file(TUTORIAL_SCENE)


func _on_volume_changed(value: float) -> void:
	SaveManager.set_setting("volume", value, false)
	SaveManager.apply_audio_settings()
	_volume_dirty = true
	_update_volume_text()


func _on_volume_drag_ended(_value_changed: bool) -> void:
	_save_volume_if_needed()


func _save_volume_if_needed() -> void:
	if _volume_dirty:
		_volume_dirty = false
		SaveManager.set_setting("volume", _volume_slider.value)


func _go_back() -> void:
	_save_volume_if_needed()
	var back: String = RunState.back_scene if not RunState.back_scene.is_empty() else MAIN_MENU_SCENE
	RunState.back_scene = ""
	get_tree().change_scene_to_file(back)


func _on_language_changed(_language: String) -> void:
	_refresh_texts()
