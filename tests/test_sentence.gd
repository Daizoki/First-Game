extends "res://tests/test_case.gd"
## The rune grammar (DESIGN 3.15): reading the cast stones as a sentence
## Element -> (up to 2 Actions) -> Target.

const Fixtures = preload("res://tests/fixtures.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")


func _parse(ids: Array) -> Dictionary:
	var rune_ids: Array[String] = []
	for id: Variant in ids:
		rune_ids.append(str(id))
	return SentenceParser.parse(rune_ids, Fixtures.data()["runes"], Fixtures.data()["spells"])


func test_every_rune_has_a_role_and_eight_of_each() -> void:
	var counts: Dictionary = {}
	for id: String in Fixtures.data()["runes"]:
		var role: String = Fixtures.data()["runes"][id]["role"]
		counts[role] = int(counts.get(role, 0)) + 1
	check_eq(counts, {"element": 8, "action": 8, "target": 8}, "roles:")


func test_every_element_and_target_make_one_spell() -> void:
	var runes: Dictionary = Fixtures.data()["runes"]
	for element: String in runes:
		for target: String in runes:
			if runes[element]["role"] == "element" and runes[target]["role"] == "target":
				check(not SentenceParser.spell_for(element, target, Fixtures.data()["spells"]).is_empty(),
					"%s -> %s has no spell" % [element, target])


func test_element_then_target() -> void:
	var found: Dictionary = _parse(["isaz", "tiwaz"])
	check_eq(found["status"], SentenceParser.SPELL, "status:")
	check_eq(found["spell"], "isaz_tiwaz", "Ice on the Target:")
	check_eq(found["actions"], [] as Array[String], "no Actions:")
	check_eq(found["indices"], [0, 1] as Array[int], "stones:")


func test_one_or_two_actions_in_the_middle() -> void:
	var one: Dictionary = _parse(["uruz", "ehwaz", "fehu"])
	check_eq(one["spell"], "uruz_fehu", "Strength runs twice into Coins:")
	check_eq(one["actions"], ["ehwaz"] as Array[String], "one Action:")
	var two: Dictionary = _parse(["isaz", "raidho", "ehwaz", "tiwaz"])
	check_eq(two["spell"], "isaz_tiwaz", "two Actions:")
	check_eq(two["actions"], ["raidho", "ehwaz"] as Array[String], "in order:")
	check_eq(_parse(["isaz", "raidho", "ehwaz", "jera", "tiwaz"])["status"], SentenceParser.INTERRUPTED,
		"three Actions are too many:")


func test_wrong_order_is_no_spell() -> void:
	check_eq(_parse(["tiwaz", "isaz"])["status"], SentenceParser.WRONG_ORDER, "Target first:")
	check_eq(_parse(["fehu", "hagalaz"])["status"], SentenceParser.WRONG_ORDER, "Fehu then Hagalaz:")
	check_eq(_parse(["hagalaz", "fehu"])["spell"], "hagalaz_fehu", "Hagalaz then Fehu:")


func test_unfinished_and_empty_sentences() -> void:
	var unfinished: Dictionary = _parse(["isaz", "raidho"])
	check_eq(unfinished["status"], SentenceParser.INCOMPLETE, "no Target yet:")
	check_eq(unfinished["parts"], ["isaz", "raidho"] as Array[String], "the sentence so far:")
	check_eq(_parse(["fehu", "tiwaz"])["status"], SentenceParser.NONE, "two Targets:")
	check_eq(_parse(["raidho"])["status"], SentenceParser.NONE, "one Action:")


func test_a_stone_in_between_breaks_the_sentence() -> void:
	# Isaz -> Raidho is broken by Hagalaz; the sentence that does stand is Hagalaz -> Tiwaz.
	check_eq(_parse(["isaz", "raidho", "hagalaz", "tiwaz"])["spell"], "hagalaz_tiwaz", "the later sentence:")
	check_eq(_parse(["isaz", "gebo", "raidho", "jera", "tiwaz"])["status"], SentenceParser.INTERRUPTED,
		"nothing stands:")
	check_eq(_parse(["isaz", "fehu", "tiwaz"])["spell"], "isaz_fehu", "Isaz -> Fehu, Tiwaz is extra:")


func test_only_the_first_sentence_counts() -> void:
	var first: Dictionary = _parse(["isaz", "tiwaz", "kenaz", "fehu"])
	check_eq(first["spell"], "isaz_tiwaz", "the first one:")
	check_eq(first["indices"], [0, 1] as Array[int], "its stones:")


func test_laguz_is_water_not_a_wildcard() -> void:
	check_eq(_parse(["laguz", "fehu"])["spell"], "laguz_fehu", "Water into Coins:")
	check_eq(_parse(["laguz", "isaz"])["status"], SentenceParser.INCOMPLETE, "two Elements, no Target:")


func test_talisman_and_examiner_spells_sleep_until_stage_3() -> void:
	var dormant: Dictionary = _parse(["isaz", "wunjo"])
	check_eq(dormant["status"], SentenceParser.DORMANT, "into the Talismans:")
	check_eq(dormant["spell"], "isaz_wunjo", "it is still read:")
	check_eq(_parse(["kenaz", "algiz"])["status"], SentenceParser.DORMANT, "against the Examiner:")
