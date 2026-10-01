extends "res://tests/test_case.gd"
## Power × Resonance (3.3), the Voices of the runes, and a whole round with Spells.

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
		"is_last_cast": false, "voices_awake": true, "res_mult": 1.0, "lessons_used": 0,
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


func test_tiwaz_doubles_only_when_leftmost() -> void:
	var base: Array = _word_values("pair")
	check_eq(_score(["tiwaz", "fehu"])["res"], base[1] * 2.0, "tiwaz first:")
	check_eq(_score(["fehu", "tiwaz"])["res"], base[1], "tiwaz second:")


func test_isaz_in_hand_adds_resonance() -> void:
	var base: Array = _word_values("single")
	check_eq(_score(["fehu"], ["isaz"])["res"], base[1] + 3.0, "isaz held:")
	check_eq(_score(["fehu"], ["isaz", "isaz"])["res"], base[1] + 6.0, "two isaz held:")


func test_ehwaz_makes_the_right_stone_score_again() -> void:
	var base: Array = _word_values("pair")
	var result: Dictionary = _score(["ehwaz", "thurisaz"])
	check_eq(result["power"], base[0] + 5.0 + 5.0 + 5.0, "thurisaz scores twice:")
	check_eq(result["res"], base[1] + 8.0, "thurisaz voice twice:")


func test_gebo_copies_the_left_voice() -> void:
	var base: Array = _word_values("pair")
	var result: Dictionary = _score(["dagaz", "gebo"], [], {"cast_index": 0})
	check_eq(result["res"], base[1] * 4.0, "dagaz ×2, gebo copies it ×2:")


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
	check_eq(_score(["fehu"], [], {"res_mult": 2.0})["res"], _word_values("single")[1] * 2.0, "star ×2:")


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


func test_winter_lowers_the_target_and_sunrise_refunds() -> void:
	var round_state: RoundState = _round(1000.0)
	_put_in_hand(round_state, ["hagalaz", "fehu", "tiwaz", "isaz", "naudiz", "dagaz", "sowilo", "uruz"])
	var result: Dictionary = round_state.cast([0, 1, 2, 3, 4])
	check_eq(result["word"], "triad", "word:")
	check((result["spells"] as Array).has("winter"), "winter cast")
	check_eq(round_state.target, 850.0, "target -15%:")
	_put_in_hand(round_state, ["dagaz", "sowilo", "uruz"])
	round_state.cast([0, 1])
	check_eq(round_state.casts_left, 3, "two casts, the second refunded by Sunrise (4 - 2 + 1):")


func test_lesson_spell_levels_up_the_word() -> void:
	var round_state: RoundState = _round(100000.0)
	_put_in_hand(round_state, ["ansuz", "mannaz", "isaz"])
	var result: Dictionary = round_state.cast([0, 1])
	check_eq(round_state.word_level(result["word"]), 2, "the cast word goes up a level:")


func test_road_spell_draws_more_stones() -> void:
	var round_state: RoundState = _round(100000.0)
	_put_in_hand(round_state, ["raidho", "ehwaz", "isaz"])
	round_state.cast([0, 1])
	check_eq(round_state.hand.size(), 11, "8 + 3 stones after the Road:")


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
