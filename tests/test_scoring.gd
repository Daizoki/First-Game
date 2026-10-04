extends "res://tests/test_case.gd"
## Power × Resonance (3.3), the Voices of the runes (some read the casting order), a whole round.

const Fixtures = preload("res://tests/fixtures.gd")
const Stone = preload("res://scripts/core/stone.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const Scorer = preload("res://scripts/core/scorer.gd")
const RoundState = preload("res://scripts/core/round_state.gd")


func _score(ids: Array, held_ids: Array = [], extra: Dictionary = {}) -> Dictionary:
	var data: Dictionary = Fixtures.data()
	var cast: Array[Stone] = Fixtures.stones(ids)
	var held: Array[Stone] = Fixtures.stones(held_ids)
	var ctx: Dictionary = {
		"cast": cast, "held": held, "word": WordDetector.detect(cast, data["words"]),
		"words": data["words"], "runes": data["runes"], "word_level": 1, "cast_index": 1,
		"is_last_cast": false, "voices_awake": true, "lessons_used": 0,
		"talismans": 0, "once_used": [], "rng": Fixtures.rng(),
	}
	ctx.merge(extra, true)
	return Scorer.score_cast(ctx)


func _word_values(word_id: String) -> Array:
	var word: Dictionary = Fixtures.data()["words"][word_id]
	return [float(word["base_power"]), float(word["base_res"])]


func test_hagalaz_scores_twice_and_fehu_pays() -> void:
	var base: Array = _word_values("pair")
	var result: Dictionary = _score(["fehu", "hagalaz"])
	check_eq(result["power"], base[0] + 3.0 + 3.0 + 3.0, "power (fehu once, hagalaz twice):")
	check_eq(result["res"], base[1], "res:")
	check_eq(result["score"], (base[0] + 9.0) * base[1], "score:")
	check_eq(result["money"], 1, "fehu gives 1 coin:")


func test_uruz_doubles_its_base_power() -> void:
	var base: Array = _word_values("single")
	check_eq(_score(["uruz"])["power"], base[0] + 8.0, "uruz power 4 doubled:")


func test_tiwaz_doubles_only_when_cast_first() -> void:
	var base: Array = _word_values("pair")
	check_eq(_score(["tiwaz", "fehu"])["res"], base[1] * 2.0, "tiwaz cast first:")
	check_eq(_score(["fehu", "tiwaz"])["res"], base[1], "tiwaz cast second:")


func test_isaz_in_hand_adds_resonance() -> void:
	var base: Array = _word_values("single")
	check_eq(_score(["fehu"], ["isaz"])["res"], base[1] + 3.0, "isaz held:")
	check_eq(_score(["fehu"], ["isaz", "isaz"])["res"], base[1] + 6.0, "two isaz held:")


func test_ehwaz_makes_the_next_cast_stone_score_again() -> void:
	var base: Array = _word_values("pair")
	var result: Dictionary = _score(["ehwaz", "thurisaz"])
	check_eq(result["power"], base[0] + 5.0 + 5.0 + 5.0, "thurisaz, cast after ehwaz, scores twice:")
	check_eq(result["res"], base[1] + 8.0, "thurisaz voice twice:")
	var before: Dictionary = _score(["thurisaz", "ehwaz"])
	check_eq(before["power"], base[0] + 10.0, "cast before ehwaz, thurisaz scores once:")


func test_gebo_copies_the_voice_cast_before_it() -> void:
	var base: Array = _word_values("pair")
	var result: Dictionary = _score(["dagaz", "gebo"], [], {"cast_index": 0})
	check_eq(result["res"], base[1] * 4.0, "dagaz ×2, gebo copies it ×2:")
	check_eq(_score(["gebo", "dagaz"], [], {"cast_index": 0})["res"], base[1] * 2.0, "gebo cast first copies nothing:")
	# The stone before Gebo need not score: here Thurisaz is cast but only the Pair of 7s scores.
	var single: Dictionary = _score(["dagaz", "thurisaz", "gebo"])
	check_eq(single["res"], base[1] + 4.0, "gebo copies thurisaz (+4) though it does not score:")


func test_conditions_last_and_first_cast() -> void:
	var base: Array = _word_values("single")
	check_eq(_score(["naudiz"], [], {"is_last_cast": true})["res"], base[1] * 2.0, "naudiz on the last cast:")
	check_eq(_score(["naudiz"])["res"], base[1], "naudiz on another cast:")
	check_eq(_score(["dagaz"], [], {"cast_index": 0})["res"], base[1] * 2.0, "dagaz on the first cast:")


func test_ansuz_raises_the_word_level() -> void:
	var word: Dictionary = Fixtures.data()["words"]["single"]
	var result: Dictionary = _score(["ansuz"])
	check_eq(result["power"], float(word["base_power"]) + float(word["level_power"]) + 6.0, "level 2 power:")
	check_eq(result["res"], float(word["base_res"]) + float(word["level_res"]), "level 2 res:")


func test_wunjo_sowilo_and_star_bonus() -> void:
	var pair: Array = _word_values("pair")
	check_eq(_score(["wunjo", "sowilo"])["res"], (pair[1] + 2.0) * 1.5, "wunjo +2 (2 stones), sowilo ×1.5:")
	var mods: Dictionary = {"res_mults": [2.0], "add_power": 10.0}
	var boosted: Dictionary = _score(["fehu"], [], {"spell_mods": mods})
	check_eq(boosted["res"], _word_values("single")[1] * 2.0, "a spell's ×2:")
	check_eq(boosted["power"], _word_values("single")[0] + 3.0 + 10.0, "a spell's +10 Power:")


func test_voices_can_sleep() -> void:
	var base: Array = _word_values("pair")
	check_eq(_score(["fehu", "hagalaz"], [], {"voices_awake": false})["power"], base[0] + 6.0, "no voices:")


func test_events_end_with_total() -> void:
	var events: Array = _score(["fehu", "hagalaz"])["events"]
	check_eq(events[0]["type"], "word", "first event:")
	check_eq(events[events.size() - 1]["type"], "total", "last event:")


func _round(target: float = 600.0) -> RoundState:
	var round_state: RoundState = RoundState.new()
	round_state.setup(Fixtures.data(), Fixtures.rng(42), target)
	round_state.start()
	return round_state


func _put_in_hand(round_state: RoundState, ids: Array) -> void:
	round_state.hand = Fixtures.stones(ids)


func test_round_draws_casts_and_swaps() -> void:
	var round_state: RoundState = _round()
	check_eq(round_state.hand.size(), 8, "hand:")
	check_eq(round_state.bag.remaining(), 40, "bag after drawing:")
	check(round_state.swap([0, 1]), "swap should work")
	check_eq(round_state.swaps_left, 2, "swaps left:")
	check_eq(round_state.hand.size(), 8, "hand refilled after swap:")
	var result: Dictionary = round_state.cast([0, 1, 2])
	check(not result.is_empty(), "cast should work")
	check_eq(round_state.casts_left, 3, "casts left:")
	check_eq(round_state.hand.size(), 8, "hand refilled after cast:")
	check(round_state.score > 0.0, "score should grow")


func test_same_seed_same_round() -> void:
	var a: RoundState = _round()
	var b: RoundState = _round()
	for i: int in a.hand.size():
		check_eq(a.hand[i].rune_id, b.hand[i].rune_id, "stone %d:" % i)


func test_winter_is_ice_on_the_target_in_that_order() -> void:
	var round_state: RoundState = _round(1000.0)
	_put_in_hand(round_state, ["isaz", "tiwaz", "fehu", "uruz", "naudiz", "dagaz", "sowilo", "hagalaz"])
	var result: Dictionary = round_state.cast([0, 1])
	check_eq(result["spells"], ["isaz_tiwaz"] as Array[String], "Ice on the Target:")
	check_eq(round_state.target, 850.0, "target -15%:")
	var backwards: RoundState = _round(1000.0)
	_put_in_hand(backwards, ["isaz", "tiwaz", "fehu"])
	check_eq(backwards.cast([1, 0])["spells"], [] as Array[String], "Tiwaz then Isaz is no spell:")
	check_eq(backwards.target, 1000.0, "target unchanged:")


func test_the_lesson_spell_levels_up_the_word() -> void:
	var round_state: RoundState = _round(100000.0)
	_put_in_hand(round_state, ["isaz", "ansuz", "fehu"])
	var result: Dictionary = round_state.cast([0, 1])
	check_eq(round_state.word_level(result["word"]), 2, "the cast word goes up a level:")


func test_the_hearth_adds_a_stone_to_the_hand() -> void:
	var round_state: RoundState = _round(100000.0)
	_put_in_hand(round_state, ["kenaz", "mannaz", "isaz"])
	round_state.cast([0, 1])
	check_eq(round_state.hand.size(), 9, "8 + 1 stones after Fire into the Hand:")


func test_ingwaz_grows_when_held_at_round_end() -> void:
	var round_state: RoundState = _round()
	_put_in_hand(round_state, ["ingwaz", "isaz"])
	var before: int = round_state.hand[0].bonus_power
	var finished: Dictionary = round_state.finish()
	check_eq(round_state.hand[0].bonus_power, before + 10, "ingwaz +10 power:")
	check_eq((finished["grown"] as Array).size(), 1, "one stone grew:")


func test_round_is_won_and_lost() -> void:
	var round_state: RoundState = _round(1.0)
	round_state.cast([0])
	check(round_state.is_won(), "any cast beats a target of 1")
	var hard: RoundState = _round(1.0e12)
	for i: int in 4:
		hard.cast([0])
	check(hard.is_lost(), "4 casts cannot reach a huge target")
