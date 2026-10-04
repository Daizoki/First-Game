extends RefCounted
## Shared test helpers: real game data (loaded once) and stones built from rune ids.

const GameDataScript = preload("res://scripts/autoload/game_data.gd")
const Stone = preload("res://scripts/core/stone.gd")

static var _data: Dictionary = {}


## {"runes", "words", "spells", "spell_actions", "rules", "economy", "tutorial", "hints", "characters",
## "trials", "examiners", "talismans"}
## from data/, loaded once per test run.
static func data() -> Dictionary:
	if _data.is_empty():
		var game_data: GameDataScript = GameDataScript.new()
		game_data.load_all("res://data/")
		_data = {
			"runes": game_data.runes, "words": game_data.words,
			"spells": game_data.spells, "spell_actions": game_data.spell_actions, "rules": game_data.rules,
			"economy": game_data.economy, "tutorial": game_data.tutorial,
			"hints": game_data.hints, "characters": game_data.characters, "trials": game_data.trials,
			"examiners": game_data.examiners, "talismans": game_data.talismans,
		}
		game_data.free()
	return _data


## Stones for the given rune ids, in that order.
static func stones(ids: Array) -> Array[Stone]:
	var runes: Dictionary = data()["runes"]
	var result: Array[Stone] = []
	for i: int in ids.size():
		result.append(Stone.from_rune(runes[ids[i]], i + 1))
	return result


static func rng(seed_value: int = 7) -> RandomNumberGenerator:
	var generator: RandomNumberGenerator = RandomNumberGenerator.new()
	generator.seed = seed_value
	return generator
