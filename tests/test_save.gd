extends "res://tests/test_case.gd"
## SaveManager: defaults, round trip, damaged files.

const SaveManagerScript = preload("res://scripts/autoload/save_manager.gd")
const TEST_PATH: String = "user://test_save.json"


func _make() -> SaveManagerScript:
	_cleanup()
	var manager: SaveManagerScript = SaveManagerScript.new()
	manager.save_path = TEST_PATH
	return manager


func _cleanup() -> void:
	for path: String in [TEST_PATH, TEST_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func test_missing_file_gives_defaults() -> void:
	var manager: SaveManagerScript = _make()
	check(not manager.load_game(), "load_game should return false without a file")
	check_eq(manager.data["memories"], 0, "memories:")
	check_eq(manager.get_setting("language"), "ro", "language:")
	manager.free()


func test_round_trip() -> void:
	var manager: SaveManagerScript = _make()
	manager.load_game()
	manager.data["player_name"] = "Relax"
	manager.data["memories"] = 42
	manager.set_setting("language", "en")
	check(manager.save_game(), "save_game failed")

	var other: SaveManagerScript = SaveManagerScript.new()
	other.save_path = TEST_PATH
	check(other.load_game(), "load_game should return true")
	check_eq(other.data["player_name"], "Relax", "name:")
	check_eq(other.data["memories"], 42, "memories:")
	check(other.data["memories"] is int, "memories should load as int")
	check_eq(other.get_setting("language"), "en", "language:")
	manager.free()
	other.free()
	_cleanup()


func test_damaged_file_falls_back_to_defaults() -> void:
	var manager: SaveManagerScript = _make()
	var file: FileAccess = FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("{ this is not json")
	file.close()
	check(not manager.load_game(), "damaged file should not load")
	check_eq(manager.data["memories"], 0, "memories:")
	check(FileAccess.file_exists(manager.backup_path()), "damaged file should be backed up")
	manager.free()
	_cleanup()


func test_merge_fixes_types_and_keeps_new_defaults() -> void:
	var loaded: Dictionary = {
		"memories": 12.0,
		"player_name": 5,
		"unlocks": {"talisman_x": true},
		"settings": {"language": "en"},
		"old_field": true,
	}
	var merged: Dictionary = SaveManagerScript.merge_with_defaults(loaded, SaveManagerScript.default_data())
	check_eq(merged["memories"], 12, "memories:")
	check(merged["memories"] is int, "memories should be int")
	check_eq(merged["player_name"], "", "wrong type falls back to default:")
	check_eq(merged["settings"]["language"], "en", "language:")
	check_eq(merged["settings"]["volume"], SaveManagerScript.DEFAULT_VOLUME, "missing volume gets default:")
	check(merged["unlocks"].has("talisman_x"), "free-key dictionaries are kept")
	check(not merged.has("old_field"), "unknown fields are dropped")


func test_discoveries_are_saved() -> void:
	var manager: SaveManagerScript = _make()
	manager.load_game()
	check(not manager.has_discovery("old_words", "alu"), "alu should not be known at start")
	check(manager.add_discovery("old_words", "alu"), "first discovery should return true")
	check(not manager.add_discovery("old_words", "alu"), "second discovery should return false")

	var other: SaveManagerScript = SaveManagerScript.new()
	other.save_path = TEST_PATH
	other.load_game()
	check(other.has_discovery("old_words", "alu"), "discovery should survive a reload")
	check(not other.has_discovery("words", "alu"), "categories are separate")
	check(manager.add_discovery("spells", "winter"), "spells are a discovery category")
	manager.free()
	other.free()
	_cleanup()


func test_stats_keep_float_scores() -> void:
	var loaded: Dictionary = {"stats": {"best_cast_score": 1250, "best_trial": 3.0}}
	var merged: Dictionary = SaveManagerScript.merge_with_defaults(loaded, SaveManagerScript.default_data())
	check(merged["stats"]["best_cast_score"] is float, "best_cast_score should be float")
	check_eq(merged["stats"]["best_cast_score"], 1250.0, "best_cast_score:")
	check(merged["stats"]["best_trial"] is int, "best_trial should be int")
