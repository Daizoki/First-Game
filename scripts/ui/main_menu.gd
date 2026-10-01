extends Control
## Main menu: Play / Runes / Settings / Quit. Also shows data errors found at startup.

const SETTINGS_SCENE: String = "res://scenes/settings.tscn"
const RUNE_CHECK_SCENE: String = "res://scenes/rune_check.tscn"
## Stage 2: Play opens a practice round. Stage 3-4 put the morning hub and the exam in between.
const ROUND_SCENE: String = "res://scenes/round.tscn"

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _motto: Label = %Motto
@onready var _play_button: Button = %PlayButton
@onready var _runes_button: Button = %RunesButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _notice: Label = %Notice
@onready var _version_label: Label = %VersionLabel
@onready var _error_panel: PanelContainer = %ErrorPanel
@onready var _error_title: Label = %ErrorTitle
@onready var _error_text: Label = %ErrorText
@onready var _error_close_button: Button = %ErrorCloseButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_runes_button.pressed.connect(_on_runes_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_error_close_button.pressed.connect(_on_error_close_pressed)
	Loc.language_changed.connect(_on_language_changed)

	# Quitting makes no sense inside a browser tab.
	_quit_button.visible = not OS.has_feature("web")
	_notice.visible = false
	_error_panel.visible = GameData.has_errors()
	_error_text.text = "\n".join(PackedStringArray(GameData.errors))

	_refresh_texts()
	if _error_panel.visible:
		_error_close_button.grab_focus()
	else:
		_play_button.grab_focus()


func _refresh_texts() -> void:
	_title.text = Loc.t("game_title")
	_subtitle.text = Loc.t("game_subtitle")
	_motto.text = Loc.t("game_motto")
	_play_button.text = Loc.t("menu_play")
	_runes_button.text = Loc.t("menu_runes")
	_settings_button.text = Loc.t("menu_settings")
	_quit_button.text = Loc.t("menu_quit")
	_notice.text = Loc.t("menu_play_soon")
	_version_label.text = Loc.t("version", {"version": ProjectSettings.get_setting("application/config/version", "")})
	_error_title.text = Loc.t("data_errors_title", {"count": GameData.errors.size()})
	_error_close_button.text = Loc.t("data_errors_close")


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(ROUND_SCENE)


func _on_runes_pressed() -> void:
	get_tree().change_scene_to_file(RUNE_CHECK_SCENE)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_error_close_pressed() -> void:
	_error_panel.visible = false
	_play_button.grab_focus()


func _on_language_changed(_language: String) -> void:
	_refresh_texts()
