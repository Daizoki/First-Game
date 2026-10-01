extends Node
## First screen of the game: decides where to go. A new player writes a name, then the
## evening class starts on its own; everyone else lands on the main menu. Data errors
## always go to the main menu, which shows them.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const NAME_SCENE: String = "res://scenes/name_entry.tscn"
const TUTORIAL_SCENE: String = "res://scenes/tutorial.tscn"


func _ready() -> void:
	get_tree().call_deferred("change_scene_to_file", next_scene())


static func next_scene() -> String:
	if GameData.has_errors():
		return MAIN_MENU_SCENE
	if str(SaveManager.data.get("player_name", "")).strip_edges().is_empty():
		return NAME_SCENE
	if not bool(SaveManager.data.get("tutorial_done", false)):
		return TUTORIAL_SCENE
	return MAIN_MENU_SCENE
