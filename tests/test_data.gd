extends "res://tests/test_case.gd"
## Loading and validation of data/*.json.

const GameDataScript = preload("res://scripts/autoload/game_data.gd")
const DataValidator = preload("res://scripts/core/data_validator.gd")


func _valid_card() -> Dictionary:
	return {
		"id": "strike",
		"name": {"ro": "Lovitură", "en": "Strike"},
		"cost": 1,
		"type": "attack",
		"rarity": "starter",
		"pool": "neutral",
		"effects": [{"type": "damage", "value": 6, "target": "enemy"}],
	}


func test_real_data_loads_without_errors() -> void:
	var game_data: GameDataScript = GameDataScript.new()
	var ok: bool = game_data.load_all("res://data/")
	check(ok, "data/ has errors:\n" + "\n".join(PackedStringArray(game_data.errors)))
	check(game_data.gods.has("varr"), "gods.json should contain varr")
	check(game_data.cards.has("strike"), "cards.json should contain strike")
	check_eq(game_data.playable_gods().size(), 3, "playable gods:")
	check(game_data.ui_text.has("menu_play"), "ui_text.json should contain menu_play")
	game_data.free()


func test_numbers_become_ints() -> void:
	var game_data: GameDataScript = GameDataScript.new()
	game_data.load_all("res://data/")
	var varr: Dictionary = game_data.gods["varr"]
	check(varr["starting_hp"] is int, "starting_hp should be an int after loading")
	game_data.free()


func test_valid_card_has_no_errors() -> void:
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("cards.json", [_valid_card()], "card")
	check(validator.errors.is_empty(), "unexpected: " + "\n".join(PackedStringArray(validator.errors)))


func test_missing_field_is_reported() -> void:
	var card: Dictionary = _valid_card()
	card.erase("cost")
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("cards.json", [card], "card")
	check(has_error(validator.errors, ["data/cards.json", "[strike]", "missing field \"cost\""]),
		"missing cost not reported: %s" % [validator.errors])


func test_missing_language_is_reported() -> void:
	var card: Dictionary = _valid_card()
	card["name"] = {"ro": "Lovitură"}
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("cards.json", [card], "card")
	check(has_error(validator.errors, ["[strike]", "\"name\"", "\"en\""]),
		"missing en text not reported: %s" % [validator.errors])


func test_duplicate_and_bad_ids_are_reported() -> void:
	var bad: Dictionary = _valid_card()
	bad["id"] = "Bad Id"
	var validator: DataValidator = DataValidator.new()
	var result: Dictionary = validator.validate_collection("cards.json", [_valid_card(), _valid_card(), bad], "card")
	check(has_error(validator.errors, ["[strike]", "duplicate id"]), "duplicate not reported")
	check(has_error(validator.errors, ["[Bad Id]", "a-z"]), "bad id not reported")
	check_eq(result.size(), 1, "valid entries:")


func test_bad_effect_is_reported() -> void:
	var card: Dictionary = _valid_card()
	card["effects"] = [
		{"type": "explode", "value": 3},
		{"type": "damage", "value": 3, "target": "everyone"},
		{"type": "block"},
	]
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("cards.json", [card], "card")
	check(has_error(validator.errors, ["effects[0].type", "explode"]), "unknown effect type not reported")
	check(has_error(validator.errors, ["effects[1].target", "everyone"]), "bad target not reported")
	check(has_error(validator.errors, ["missing field \"effects[2].value\""]), "missing value not reported")


func test_unknown_field_and_non_integer_are_reported() -> void:
	var card: Dictionary = _valid_card()
	card["cots"] = 1
	card["cost"] = 1.5
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("cards.json", [card], "card")
	check(has_error(validator.errors, ["unknown field \"cots\""]), "typo field not reported")
	check(has_error(validator.errors, ["\"cost\" must be a whole number"]), "1.5 cost not reported")


func test_broken_reference_is_reported() -> void:
	var god: Dictionary = {
		"id": "varr",
		"name": {"ro": "Varr", "en": "Varr"},
		"domain": {"ro": "furtuna", "en": "storm"},
		"job": {"ro": "șofer", "en": "driver"},
		"personality": {"ro": "zgomotos", "en": "loud"},
		"color": "#e8c547",
		"playable": true,
		"starting_hp": 55,
		"signature_card": "no_such_card",
		"unlock": {"type": "default"},
	}
	var validator: DataValidator = DataValidator.new()
	var gods: Dictionary = validator.validate_collection("gods.json", [god], "god")
	check(validator.errors.is_empty(), "god itself should be valid: %s" % [validator.errors])
	validator.check_references({"gods": gods, "cards": {}})
	check(has_error(validator.errors, ["data/gods.json", "[varr]", "no_such_card", "cards.json"]),
		"broken signature_card not reported: %s" % [validator.errors])


func test_playable_god_needs_hp() -> void:
	var god: Dictionary = {
		"id": "selvia",
		"name": {"ro": "Selvia", "en": "Selvia"},
		"domain": {"ro": "mările", "en": "seas"},
		"job": {"ro": "salvamar", "en": "lifeguard"},
		"personality": {"ro": "calmă", "en": "calm"},
		"color": "#3f7fd9",
		"playable": true,
	}
	var validator: DataValidator = DataValidator.new()
	validator.validate_collection("gods.json", [god], "god")
	check(has_error(validator.errors, ["[selvia]", "starting_hp"]), "missing starting_hp not reported")


func test_normalize_numbers() -> void:
	var value: Variant = DataValidator.normalize_numbers({"a": 6.0, "b": [2.0, 0.5]})
	var dict: Dictionary = value
	check(dict["a"] is int, "6.0 should become int")
	var list: Array = dict["b"]
	check(list[0] is int, "2.0 should become int")
	check(list[1] is float, "0.5 should stay float")
