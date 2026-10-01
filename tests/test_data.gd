extends "res://tests/test_case.gd"
## Loading and validation of data/*.json.

const GameDataScript = preload("res://scripts/autoload/game_data.gd")
const DataValidator = preload("res://scripts/core/data_validator.gd")


func _valid_rune() -> Dictionary:
	return {
		"id": "fehu",
		"name": {"ro": "Fehu", "en": "Fehu"},
		"glyph": "ᚠ",
		"kin": "fehu",
		"position": 1,
		"base_power": 3,
		"meaning": {"ro": "vite, avere", "en": "cattle, wealth"},
		"voice": {"ro": "+1 Monedă când punctează.", "en": "+1 Coin when it scores."},
		"segments": [[0.35, 0.05, 0.35, 0.95], [0.35, 0.3, 0.7, 0.08]],
	}


func test_real_data_loads_without_errors() -> void:
	var game_data: GameDataScript = GameDataScript.new()
	var ok: bool = game_data.load_all("res://data/")
	check(ok, "data/ has errors:\n" + "\n".join(PackedStringArray(game_data.errors)))
	check_eq(game_data.kins.size(), 3, "kins:")
	check_eq(game_data.runes.size(), 24, "runes:")
	check_eq(game_data.words.size(), 10, "words:")
	check_eq(game_data.spells.size(), 17, "spells:")
	check(game_data.spells.has("winter"), "spells.json should contain winter (Iarna)")
	check(game_data.characters.has("ilinca"), "characters.json should contain ilinca")
	check(game_data.characters.has("vera"), "characters.json should contain vera")
	check_eq(game_data.rule("hand_size"), 8, "hand size:")
	check(game_data.ui_text.has("menu_play"), "ui_text.json should contain menu_play")
	game_data.free()


func test_each_kin_has_eight_runes_in_order() -> void:
	var game_data: GameDataScript = GameDataScript.new()
	game_data.load_all("res://data/")
	for kin_id: String in game_data.kins:
		var runes: Array[Dictionary] = game_data.runes_in_kin(kin_id)
		check_eq(runes.size(), 8, "%s runes:" % kin_id)
		for i: int in runes.size():
			check_eq(runes[i]["position"], i + 1, "%s position:" % kin_id)
	var fehu_row: Array[Dictionary] = game_data.runes_in_kin("fehu")
	var first_five: String = ""
	for i: int in 5:
		first_five += str(fehu_row[i]["glyph"])
	check_eq(first_five, "ᚠᚢᚦᚨᚱ", "the Fehu kin should start with F-U-Þ-A-R:")
	game_data.free()


func test_numbers_become_ints() -> void:
	var game_data: GameDataScript = GameDataScript.new()
	game_data.load_all("res://data/")
	var fehu: Dictionary = game_data.runes["fehu"]
	check(fehu["position"] is int, "position should be an int after loading")
	game_data.free()


func test_valid_rune_has_no_errors() -> void:
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("runes.json", [_valid_rune()], "rune")
	check(validator.errors.is_empty(), "unexpected: " + "\n".join(PackedStringArray(validator.errors)))


func test_missing_field_is_reported() -> void:
	var rune: Dictionary = _valid_rune()
	rune.erase("base_power")
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("runes.json", [rune], "rune")
	check(has_error(validator.errors, ["data/runes.json", "[fehu]", "missing field \"base_power\""]),
		"missing base_power not reported: %s" % [validator.errors])


func test_missing_language_is_reported() -> void:
	var rune: Dictionary = _valid_rune()
	rune["voice"] = {"ro": "+1 Monedă"}
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("runes.json", [rune], "rune")
	check(has_error(validator.errors, ["[fehu]", "\"voice\"", "\"en\""]),
		"missing en text not reported: %s" % [validator.errors])


func test_duplicate_and_bad_ids_are_reported() -> void:
	var bad: Dictionary = _valid_rune()
	bad["id"] = "Bad Id"
	var validator: DataValidator = DataValidator.new()
	var result: Dictionary = validator.validate_collection("runes.json", [_valid_rune(), _valid_rune(), bad], "rune")
	check(has_error(validator.errors, ["[fehu]", "duplicate id"]), "duplicate not reported")
	check(has_error(validator.errors, ["[Bad Id]", "a-z"]), "bad id not reported")
	check_eq(result.size(), 1, "valid entries:")


func test_bad_segments_are_reported() -> void:
	var rune: Dictionary = _valid_rune()
	rune["segments"] = [[0.1, 0.2, 0.3], [0.0, 0.0, 1.5, 0.5]]
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("runes.json", [rune], "rune")
	check(has_error(validator.errors, ["segments[0]", "exactly 4 numbers"]), "3-number line not reported")
	check(has_error(validator.errors, ["segments[1]", "between 0 and 1"]), "out-of-range line not reported")


func test_position_out_of_range_and_unknown_field() -> void:
	var rune: Dictionary = _valid_rune()
	rune["position"] = 9
	rune["powr"] = 3
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("runes.json", [rune], "rune")
	check(has_error(validator.errors, ["\"position\" must be between 1 and 8"]), "position 9 not reported")
	check(has_error(validator.errors, ["unknown field \"powr\""]), "typo field not reported")


func test_broken_reference_is_reported() -> void:
	var rune: Dictionary = _valid_rune()
	rune["kin"] = "nope"
	var validator: DataValidator = DataValidator.new()
	var runes: Dictionary = validator.validate_collection("runes.json", [rune], "rune")
	validator.check_references({"runes": runes, "kins": {"fehu": {}}})
	check(has_error(validator.errors, ["data/runes.json", "[fehu]", "nope", "kins.json"]),
		"broken kin reference not reported: %s" % [validator.errors])


func test_kin_gaps_and_clashes_are_reported() -> void:
	var second: Dictionary = _valid_rune()
	second["id"] = "copy"
	var validator: DataValidator = DataValidator.new()
	var runes: Dictionary = validator.validate_collection("runes.json", [_valid_rune(), second], "rune")
	validator.check_runes("runes.json", runes, {"fehu": {}})
	check(has_error(validator.errors, ["[copy]", "already has a rune on position 1"]), "position clash not reported")
	check(has_error(validator.errors, ["no rune on position 2"]), "missing position not reported")


func test_rules_file_is_checked() -> void:
	var validator: DataValidator = DataValidator.new()
	validator.validate_single("rules.json", {"hand_size": 0}, "rules")
	check(has_error(validator.errors, ["data/rules.json", "missing field \"casts_per_round\""]), "missing rule not reported")
	check(has_error(validator.errors, ["\"hand_size\" must be at least 1"]), "hand_size 0 not reported")


func test_normalize_numbers() -> void:
	var value: Variant = DataValidator.normalize_numbers({"a": 6.0, "b": [2.0, 0.5]})
	var dict: Dictionary = value
	check(dict["a"] is int, "6.0 should become int")
	var list: Array = dict["b"]
	check(list[0] is int, "2.0 should become int")
	check(list[1] is float, "0.5 should stay float")


func _spell(id: String, runes: Array) -> Dictionary:
	return {
		"id": id,
		"name": {"ro": id, "en": id},
		"runes": runes,
		"logic": {"ro": "a + b", "en": "a + b"},
		"effect": {"ro": "+6 Monede.", "en": "+6 Coins."},
		"moment": "after_score",
		"category": "economy",
	}


func test_spell_rune_count_and_moment_are_checked() -> void:
	var bad: Dictionary = _spell("solo", ["fehu"])
	bad["moment"] = "later"
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("spells.json", [bad, _spell("big", ["fehu", "gebo", "isaz", "jera"])], "spell")
	check(has_error(validator.errors, ["[solo]", "must have 2 or 3 runes (got 1)"]), "1-rune spell not reported")
	check(has_error(validator.errors, ["[big]", "(got 4)"]), "4-rune spell not reported")
	check(has_error(validator.errors, ["[solo]", "\"moment\" must be one of"]), "bad moment not reported")


func test_spells_with_same_runes_are_reported() -> void:
	var validator: DataValidator = DataValidator.new()
	var spells: Dictionary = validator.validate_collection("spells.json",
		[_spell("market", ["fehu", "gebo"]), _spell("copy", ["gebo", "fehu"])], "spell")
	validator.check_spells("spells.json", spells)
	check(has_error(validator.errors, ["[copy]", "same runes as spell \"market\""]), "duplicate spell not reported")


func test_spell_unknown_rune_is_reported() -> void:
	var validator: DataValidator = DataValidator.new()
	var spells: Dictionary = validator.validate_collection("spells.json", [_spell("odd", ["fehu", "zap"])], "spell")
	validator.check_references({"spells": spells, "runes": {"fehu": {}}})
	check(has_error(validator.errors, ["[odd]", "zap", "runes.json"]), "unknown rune not reported")
