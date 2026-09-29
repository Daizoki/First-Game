extends Node
## Loads every JSON file from data/ at startup, validates it and exposes the content.
## Problems never crash the game: they are collected in `errors` (file + id + what is wrong)
## and shown on the main menu.

signal data_loaded(ok: bool)

const DataValidator = preload("res://scripts/core/data_validator.gd")

const DATA_DIR: String = "res://data/"
const UI_TEXT_FILE: String = "ui_text.json"

## Collection name -> [file name, schema name]
const COLLECTIONS: Dictionary = {
	"gods": ["gods.json", "god"],
	"cards": ["cards.json", "card"],
	"enemies": ["enemies.json", "enemy"],
	"blessings": ["blessings.json", "blessing"],
	"trials": ["trials.json", "trial"],
	"events": ["events.json", "event"],
	"dialogs": ["dialogs.json", "dialog"],
}

var errors: Array[String] = []

## Each collection maps id -> entry (Dictionary), in the same order as in the file.
var gods: Dictionary = {}
var cards: Dictionary = {}
var enemies: Dictionary = {}
var blessings: Dictionary = {}
var trials: Dictionary = {}
var events: Dictionary = {}
var dialogs: Dictionary = {}
## key -> {"ro": "...", "en": "..."}
var ui_text: Dictionary = {}


func _ready() -> void:
	load_all(DATA_DIR)


## Loads and validates everything. Returns true when there are no errors.
func load_all(data_dir: String) -> bool:
	var validator: DataValidator = DataValidator.new()
	var loaded: Dictionary = {}
	for collection: String in COLLECTIONS:
		var info: Array = COLLECTIONS[collection]
		var raw: Variant = _read_json(data_dir, info[0], validator)
		if raw == null:
			loaded[collection] = {}
		else:
			loaded[collection] = validator.validate_collection(info[0], raw, info[1])

	var raw_ui: Variant = _read_json(data_dir, UI_TEXT_FILE, validator)
	ui_text = {} if raw_ui == null else validator.validate_text_table(UI_TEXT_FILE, raw_ui)

	validator.check_references(loaded)

	gods = loaded["gods"]
	cards = loaded["cards"]
	enemies = loaded["enemies"]
	blessings = loaded["blessings"]
	trials = loaded["trials"]
	events = loaded["events"]
	dialogs = loaded["dialogs"]
	errors = validator.errors

	for message: String in errors:
		push_error(message)
	data_loaded.emit(errors.is_empty())
	return errors.is_empty()


func has_errors() -> bool:
	return not errors.is_empty()


func get_god(id: String) -> Dictionary:
	return _get_entry(gods, "gods", id)


func get_card(id: String) -> Dictionary:
	return _get_entry(cards, "cards", id)


func get_enemy(id: String) -> Dictionary:
	return _get_entry(enemies, "enemies", id)


func get_blessing(id: String) -> Dictionary:
	return _get_entry(blessings, "blessings", id)


func get_dialog(id: String) -> Dictionary:
	return _get_entry(dialogs, "dialogs", id)


## Gods the player can choose as divine parent, in file order.
func playable_gods() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in gods:
		var god: Dictionary = gods[id]
		var playable: Variant = god.get("playable", false)
		if playable is bool and playable:
			result.append(god)
	return result


## Placeholder color for anything tied to a god (falls back to grey).
func god_color(god_id: String) -> Color:
	var god: Dictionary = gods.get(god_id, {})
	return Color.html(str(god.get("color", "#808080")))


func _get_entry(table: Dictionary, collection: String, id: String) -> Dictionary:
	if not table.has(id):
		push_error("GameData: no entry \"%s\" in %s" % [id, collection])
		return {}
	return table[id]


func _read_json(data_dir: String, file_name: String, validator: DataValidator) -> Variant:
	var path: String = data_dir.path_join(file_name)
	if not FileAccess.file_exists(path):
		validator.add_error(file_name, "", "file not found (%s)" % path)
		return null
	var json: JSON = JSON.new()
	var result: Error = json.parse(FileAccess.get_file_as_string(path))
	if result != OK:
		validator.add_error(file_name, "", "invalid JSON at line %d: %s" % [
			json.get_error_line(), json.get_error_message()])
		return null
	return DataValidator.normalize_numbers(json.data)
