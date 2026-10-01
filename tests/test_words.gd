extends "res://tests/test_case.gd"
## Word recognition (3.4) and Spell detection (3.15).

const Fixtures = preload("res://tests/fixtures.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const SpellDetector = preload("res://scripts/core/spell_detector.gd")


func _word(ids: Array) -> Dictionary:
	return WordDetector.detect(Fixtures.stones(ids), Fixtures.data()["words"])


func _scoring(ids: Array) -> Array:
	return _word(ids)["scoring"]


func test_single_scores_highest_position() -> void:
	check_eq(_word(["uruz", "kenaz", "fehu"])["word"], "single", "word:")
	check_eq(_scoring(["uruz", "kenaz", "fehu"]), [1], "kenaz (position 6) scores:")


func test_pair_and_two_pairs() -> void:
	check_eq(_word(["fehu", "isaz", "hagalaz"])["word"], "pair", "pair:")
	check_eq(_scoring(["fehu", "isaz", "hagalaz"]), [0, 2], "only the pair scores:")
	var two: Array = ["fehu", "uruz", "hagalaz", "naudiz", "isaz"]
	check_eq(_word(two)["word"], "two_pairs", "two pairs:")
	check_eq(_scoring(two), [0, 1, 2, 3], "the kicker does not score:")


func test_triad_family_four_and_ancient_word() -> void:
	check_eq(_word(["fehu", "hagalaz", "tiwaz"])["word"], "triad", "triad:")
	check_eq(_word(["fehu", "hagalaz", "tiwaz", "uruz", "naudiz"])["word"], "family", "family:")
	check_eq(_word(["fehu", "hagalaz", "tiwaz", "fehu", "isaz"])["word"], "four", "four:")
	check_eq(_scoring(["fehu", "hagalaz", "tiwaz", "fehu", "isaz"]), [0, 1, 2, 3], "four scoring:")
	check_eq(_word(["fehu", "hagalaz", "tiwaz", "fehu", "hagalaz"])["word"], "ancient_word", "ancient word:")


func test_row_kin_and_chant() -> void:
	check_eq(_word(["fehu", "naudiz", "ehwaz", "ansuz", "raidho"])["word"], "row", "row of mixed kins:")
	check_eq(_word(["fehu", "uruz", "ansuz", "gebo", "wunjo"])["word"], "kin", "kin:")
	var futhar: Dictionary = _word(["fehu", "uruz", "thurisaz", "ansuz", "raidho"])
	check_eq(futhar["word"], "chant", "F-U-Þ-A-R is a chant:")
	check_eq(futhar["kin"], "fehu", "chant kin:")


func test_row_needs_no_wrapping() -> void:
	check_eq(_word(["sowilo", "fehu", "naudiz", "ehwaz", "ansuz"])["word"], "single", "8-1-2-3-4 is not a row:")


func test_laguz_counts_as_any_kin() -> void:
	check_eq(_word(["fehu", "uruz", "ansuz", "gebo", "laguz"])["word"], "kin", "laguz completes a fehu kin:")
	check_eq(_word(["fehu", "uruz", "thurisaz", "ansuz", "laguz"])["word"], "chant", "laguz completes F-U-Þ-A-?:")


func test_order_changes_scoring_indices_not_word() -> void:
	check_eq(_word(["isaz", "fehu", "hagalaz"])["word"], "pair", "pair in any order:")
	check_eq(_scoring(["isaz", "fehu", "hagalaz"]), [1, 2], "scoring follows hand order:")


func test_available_in_hand() -> void:
	var hand: Array = ["fehu", "hagalaz", "tiwaz", "uruz", "naudiz", "isaz", "ansuz", "raidho"]
	var found: Array[String] = WordDetector.available_in_hand(Fixtures.stones(hand))
	for word: String in ["single", "pair", "two_pairs", "triad", "family", "row"]:
		check(found.has(word), "%s should be available" % word)
	check(not found.has("four"), "four should not be available")


func test_winter_spell_with_a_triad() -> void:
	var cast: Array = ["hagalaz", "fehu", "tiwaz", "isaz", "naudiz"]
	check_eq(_word(cast)["word"], "triad", "three stones on position 1:")
	var spells: Array[String] = SpellDetector.detect(Fixtures.stones(cast), Fixtures.data()["spells"])
	check(spells.has("winter"), "isaz + hagalaz + naudiz should cast Winter")


func test_spell_order_does_not_matter_and_laguz_is_not_wild() -> void:
	var spells: Dictionary = Fixtures.data()["spells"]
	check(SpellDetector.detect(Fixtures.stones(["gebo", "isaz", "fehu"]), spells).has("market"), "gebo + fehu = market")
	check(not SpellDetector.detect(Fixtures.stones(["gebo", "laguz"]), spells).has("market"), "laguz is not fehu")


func test_inactive_spells_are_skipped() -> void:
	var spells: Dictionary = Fixtures.data()["spells"]
	var flood: Array = ["laguz", "uruz"]
	check(not SpellDetector.detect(Fixtures.stones(flood), spells).has("flood"), "flood has no actions yet")
	check(SpellDetector.detect(Fixtures.stones(flood), spells, false).has("flood"), "flood exists as data")
