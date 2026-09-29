extends Control
## Settings: language and volume. Every change is saved in user://save.json.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"

@onready var _title: Label = %Title
@onready var _language_label: Label = %LanguageLabel
@onready var _language_option: OptionButton = %LanguageOption
@onready var _volume_label: Label = %VolumeLabel
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_value: Label = %VolumeValue
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
	_back_button.pressed.connect(_go_back)
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
	for i: int in Loc.LANGUAGES.size():
		_language_option.set_item_text(i, Loc.t("language_" + str(Loc.LANGUAGES[i])))
	_update_volume_text()


func _update_volume_text() -> void:
	_volume_value.text = Loc.t("settings_volume_value", {"value": roundi(_volume_slider.value * 100.0)})


func _on_language_selected(index: int) -> void:
	var code: String = Loc.LANGUAGES[index]
	Loc.set_language(code)
	SaveManager.set_setting("language", code)


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
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_language_changed(_language: String) -> void:
	_refresh_texts()
