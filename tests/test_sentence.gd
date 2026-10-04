extends "res://tests/test_case.gd"
## Reading the cast stones as sentences (docs/PROMPT_ETAPA5.md 5.2): Element → (0–2 Actions) →
## Target, one stone right after the other, up to 2 spells per Cast, bound stones as two runes.

const Fixtures = preload("res://tests/fixtures.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")


func _parse(stones: Array, max_spells: int = 2) -> Dictionary:
	return SentenceParser.parse(stones, Fixtures.data()["runes"], Fixtures.data()["spells"], max_spells)


func _spells(parsed: Dictionary) -> Array:
	var ids: Array = []
	for sentence: Dictionary in parsed["sentences"]:
		ids.append(sentence["spell"])
	return ids


func test_element_target() -> void:
	var parsed: Dictionary = _parse(["kenaz", "tiwaz"])
	check_eq(str(parsed["status"]), "spell", "status:")
	check_eq(_spells(parsed), ["kenaz_tiwaz"], "spell:")
	check_eq(parsed["indices"], [0, 1], "stones:")


func test_up_to_two_actions() -> void:
	check_eq(_spells(_parse(["kenaz", "ehwaz", "tiwaz"])), ["kenaz_tiwaz"], "one Action:")
	var two: Dictionary = _parse(["kenaz", "ehwaz", "eihwaz", "tiwaz"])
	check_eq(two["actions"], ["ehwaz", "eihwaz"], "two Actions:")
	var three: Dictionary = _parse(["kenaz", "ehwaz", "eihwaz", "jera", "tiwaz"])
	check_eq(_spells(three), [], "three Actions break the sentence:")
	check_eq(str(three["status"]), "interrupted", "why:")


func test_reasons_when_there_is_no_spell() -> void:
	check_eq(str(_parse(["tiwaz", "fehu"])["status"]), "none", "no Element:")
	check_eq(str(_parse(["kenaz", "ehwaz"])["status"]), "incomplete", "no Target:")
	check_eq(str(_parse(["tiwaz", "kenaz"])["status"]), "wrong_order", "Target first:")
	check_eq(str(_parse(["kenaz", "isaz", "tiwaz"])["status"]), "spell", "Ice → Enemy is still found:")


func test_two_spells_in_one_cast() -> void:
	var parsed: Dictionary = _parse(["kenaz", "tiwaz", "isaz", "ehwaz", "fehu"])
	check_eq(_spells(parsed), ["kenaz_tiwaz", "isaz_fehu"], "two spells:")
	check_eq(parsed["unused"], [], "every stone used:")
	check_eq(_spells(_parse(["kenaz", "tiwaz", "isaz", "fehu"], 1)), ["kenaz_tiwaz"], "the limit is respected:")


func test_stones_outside_a_spell_do_nothing() -> void:
	var parsed: Dictionary = _parse(["fehu", "kenaz", "tiwaz", "ehwaz"])
	check_eq(_spells(parsed), ["kenaz_tiwaz"], "spell:")
	check_eq(parsed["unused"], [0, 3], "unused stones:")


func test_a_bound_stone_reads_as_two_runes() -> void:
	var parsed: Dictionary = _parse([["kenaz", "ehwaz"], "tiwaz"])
	check_eq(_spells(parsed), ["kenaz_tiwaz"], "spell:")
	check_eq(parsed["actions"], ["ehwaz"], "the bound Action:")
	check_eq(parsed["indices"], [0, 1], "two stones:")
	var single: Dictionary = _parse([["sowilo", "tiwaz"]])
	check_eq(_spells(single), ["sowilo_tiwaz"], "a whole spell on one stone:")
