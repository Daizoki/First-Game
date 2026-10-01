extends Node
## Permanent progress and settings, stored in user://save.json.
## The run in progress is NOT saved (first version).

const SAVE_VERSION: int = 1
const DEFAULT_PATH: String = "user://save.json"
const DEFAULT_VOLUME: float = 0.8

var save_path: String = DEFAULT_PATH
var data: Dictionary = default_data()


func _ready() -> void:
	load_game()
	apply_audio_settings()


static func default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"player_name": "",
		"memories": 0,
		"attempts": 0,
		"unlocked_parents": ["varr"],
		## Free keys, e.g. Talismans unlocked for the Night Market.
		"unlocks": {},
		## What the player has seen at least once.
		"collection": {"talismans": [], "engravings": [], "examiners": []},
		## Permanent discoveries: Spells, hidden Words, old words (ALU, LAÞU, AUJA).
		"discoveries": {"spells": [], "words": [], "old_words": []},
		"stats": {"best_cast_score": 0.0, "best_trial": 0, "exams_passed": 0},
		## Story memory across attempts.
		"flags": {},
		## The exam in progress, saved after every round (empty = none).
		"current_exam": {},
		"settings": {
			"language": "ro",
			"volume": DEFAULT_VOLUME,
		},
	}


## Loads the save file. Returns false when there was nothing (valid) to load;
## in that case `data` holds the defaults. A damaged file is kept as save.json.bak.
func load_game() -> bool:
	data = default_data()
	if not FileAccess.file_exists(save_path):
		return false
	var text: String = FileAccess.get_file_as_string(save_path)
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		push_warning("SaveManager: %s is damaged, starting fresh (copy kept as %s)" % [save_path, backup_path()])
		_write_text(backup_path(), text)
		return false
	data = merge_with_defaults(json.data, default_data())
	return true


func save_game() -> bool:
	return _write_text(save_path, JSON.stringify(data, "\t"))


func has_discovery(category: String, id: String) -> bool:
	var discoveries: Dictionary = data.get("discoveries", {})
	var list: Variant = discoveries.get(category, [])
	return list is Array and (list as Array).has(id)


## Records a permanent discovery and saves. Returns false if it was already known.
func add_discovery(category: String, id: String) -> bool:
	if has_discovery(category, id):
		return false
	if not (data.get("discoveries") is Dictionary):
		data["discoveries"] = {}
	var discoveries: Dictionary = data["discoveries"]
	if not (discoveries.get(category) is Array):
		discoveries[category] = []
	var list: Array = discoveries[category]
	list.append(id)
	save_game()
	return true


func backup_path() -> String:
	return save_path + ".bak"


func get_setting(key: String, fallback: Variant = null) -> Variant:
	var settings: Dictionary = data.get("settings", {})
	return settings.get(key, fallback)


## Changes one setting and (by default) saves right away.
func set_setting(key: String, value: Variant, save_now: bool = true) -> void:
	if not (data.get("settings") is Dictionary):
		data["settings"] = {}
	var settings: Dictionary = data["settings"]
	settings[key] = value
	if save_now:
		save_game()


func apply_audio_settings() -> void:
	var volume: float = clampf(float(get_setting("volume", DEFAULT_VOLUME)), 0.0, 1.0)
	var bus: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(bus, volume <= 0.0)


## Keeps every loaded value whose type matches the default; missing or wrong values
## get the default. Numbers from JSON (floats) are turned back into ints where needed.
static func merge_with_defaults(loaded: Dictionary, defaults: Dictionary) -> Dictionary:
	var result: Dictionary = defaults.duplicate(true)
	for key: Variant in defaults:
		if not loaded.has(key):
			continue
		var default_value: Variant = defaults[key]
		var loaded_value: Variant = loaded[key]
		var loaded_is_number: bool = loaded_value is int or loaded_value is float
		if default_value is Dictionary:
			if not (loaded_value is Dictionary):
				continue
			var default_dict: Dictionary = default_value
			# An empty default dictionary means "free keys" (e.g. upgrades): keep as loaded.
			if default_dict.is_empty():
				result[key] = (loaded_value as Dictionary).duplicate(true)
			else:
				result[key] = merge_with_defaults(loaded_value, default_dict)
		elif default_value is int:
			if loaded_is_number:
				result[key] = int(loaded_value)
		elif default_value is float:
			if loaded_is_number:
				result[key] = float(loaded_value)
		elif typeof(loaded_value) == typeof(default_value):
			result[key] = loaded_value
	return result


func _write_text(path: String, text: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not write %s (error %d)" % [path, FileAccess.get_open_error()])
		return false
	file.store_string(text)
	file.close()
	return true
