extends Node
## Loads every JSON file from data/ at startup, validates it and exposes the content.
## Problems never crash the game: they are collected in `errors` (file + id + what is wrong)
## and shown on the main menu.

signal data_loaded(ok: bool)

const DataValidator = preload("res://scripts/core/data_validator.gd")

const DATA_DIR: String = "res://data/"
const UI_TEXT_FILE: String = "ui_text.json"
const RULES_FILE: String = "rules.json"
const RUNE_ART_PATH: String = "res://art/runes/%s.png"

## Collection name -> [file name, schema name]
const COLLECTIONS: Dictionary = {
	"kins": ["kins.json", "kin"],
	"runes": ["runes.json", "rune"],
	"words": ["words.json", "word"],
	"spells": ["spells.json", "spell"],
	"characters": ["characters.json", "character"],
	"dialogs": ["dialogs.json", "dialog"],
}

var errors: Array[String] = []

## Each collection maps id -> entry (Dictionary), in the same order as in the file.
## The 3 kins (Neamuri) of the Elder Futhark.
var kins: Dictionary = {}
## The 24 runes.
var runes: Dictionary = {}
## Word types (Pereche, Șir, ...).
var words: Dictionary = {}
## Secret rune combinations with unique effects.
var spells: Dictionary = {}
## Every named god, human and demigod.
var characters: Dictionary = {}
var dialogs: Dictionary = {}
## Round rules (hand size, casts, swaps, ...).
var rules: Dictionary = {}
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

	var raw_rules: Variant = _read_json(data_dir, RULES_FILE, validator)
	rules = {} if raw_rules == null else validator.validate_single(RULES_FILE, raw_rules, "rules")

	var raw_ui: Variant = _read_json(data_dir, UI_TEXT_FILE, validator)
	ui_text = {} if raw_ui == null else validator.validate_text_table(UI_TEXT_FILE, raw_ui)

	validator.check_references(loaded)
	validator.check_runes(COLLECTIONS["runes"][0], loaded["runes"], loaded["kins"])
	validator.check_spells(COLLECTIONS["spells"][0], loaded["spells"])

	kins = loaded["kins"]
	runes = loaded["runes"]
	words = loaded["words"]
	spells = loaded["spells"]
	characters = loaded["characters"]
	dialogs = loaded["dialogs"]
	errors = validator.errors

	for message: String in errors:
		push_error(message)
	data_loaded.emit(errors.is_empty())
	return errors.is_empty()


func has_errors() -> bool:
	return not errors.is_empty()


func get_kin(id: String) -> Dictionary:
	return _get_entry(kins, "kins", id)


func get_rune(id: String) -> Dictionary:
	return _get_entry(runes, "runes", id)


func get_word(id: String) -> Dictionary:
	return _get_entry(words, "words", id)


func get_spell(id: String) -> Dictionary:
	return _get_entry(spells, "spells", id)


func get_character(id: String) -> Dictionary:
	return _get_entry(characters, "characters", id)


func get_dialog(id: String) -> Dictionary:
	return _get_entry(dialogs, "dialogs", id)


## The runes of one kin, ordered by position (1..8).
func runes_in_kin(kin_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in runes:
		var rune: Dictionary = runes[id]
		if str(rune.get("kin", "")) == kin_id:
			result.append(rune)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("position", 0)) < int(b.get("position", 0)))
	return result


## Glow color of a kin (grey if unknown).
func kin_color(kin_id: String) -> Color:
	var kin: Dictionary = kins.get(kin_id, {})
	return Color.html(str(kin.get("color", "#808080")))


## Relax's own drawing for a rune, or null when the rune is drawn from code.
func rune_texture(rune_id: String) -> Texture2D:
	var path: String = RUNE_ART_PATH % rune_id
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func rule(key: String, fallback: Variant = null) -> Variant:
	return rules.get(key, fallback)


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
