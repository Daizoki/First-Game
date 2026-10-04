extends "res://tests/test_case.gd"
## The full exam (DESIGN 3.8): trials, rounds, targets, Coins, the examiners and their rules,
## and the spells against the Examiner.

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _exam(seed_value: int = 11) -> ExamState:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), seed_value)
	return exam


## A round under this examiner's rule ("" = no rule), with a huge target.
func _round(examiner_id: String = "", target: float = 1.0e9, seed_value: int = 42) -> RoundState:
	var state: RoundState = RoundState.new()
	var options: Dictionary = {"money": 10}
	if not examiner_id.is_empty():
		options["rule"] = Fixtures.data()["examiners"][examiner_id]
	state.setup(Fixtures.data(), Fixtures.rng(seed_value), target, options)
	state.start()
	return state


## Puts these runes first in hand and casts them in this order.
func _cast(state: RoundState, ids: Array) -> Dictionary:
	_put(state, ids)
	var order: Array[int] = []
	for i: int in ids.size():
		order.append(i)
	return state.cast(order)


func _put(state: RoundState, ids: Array) -> void:
	var stones: Array[Stone] = Fixtures.stones(ids)
	stones.append_array(state.hand.slice(0, maxi(0, state.hand.size() - stones.size())))
	state.hand = stones


## Wins the current round of the exam without playing it.
func _win(exam: ExamState) -> Dictionary:
	var state: RoundState = exam.new_round()
	state.score = state.target
	state.finish()
	return exam.finish_round(state)


func test_eight_trials_with_seven_examiners_then_aeva() -> void:
	var exam: ExamState = _exam()
	check_eq(exam.trial_count(), 8, "trials:")
	check_eq(exam.examiners.size(), 8, "one examiner per trial:")
	check_eq(exam.examiners[7], "aeva", "Aeva is always last:")
	var seen: Dictionary = {}
	for id: String in exam.examiners.slice(0, 7):
		check(not seen.has(id), "%s comes twice" % id)
		check(id != "aeva", "Aeva only at the end")
		seen[id] = true
	check_eq(_exam().examiners, exam.examiners, "the same seed, the same examiners:")
	check(_exam(12).examiners != exam.examiners or _exam(13).examiners != exam.examiners, "other seeds differ")


func test_targets_grow_by_round_and_trial() -> void:
	var exam: ExamState = _exam()
	var base: float = float(Fixtures.data()["trials"]["trial_1"]["base_target"])
	check_eq(exam.target(), base, "small question:")
	check_eq(exam.round_kind(), "small", "kind:")
	check(exam.rule().is_empty(), "no rule in the small question")
	_win(exam)
	check_eq(exam.target(), roundf(base * 1.5), "big question:")
	_win(exam)
	check_eq(exam.round_kind(), "examiner", "then the examiner:")
	check(not exam.rule().is_empty(), "with a rule")
	_win(exam)
	check_eq(exam.trial_index, 1, "trial 2:")
	check(exam.target() > base, "a harder trial")


func test_a_won_round_pays_coins() -> void:
	var exam: ExamState = _exam()
	var start: int = exam.money
	var state: RoundState = exam.new_round()
	state.score = state.target
	state.finish()
	var casts: int = state.casts_left
	var summary: Dictionary = exam.finish_round(state)
	var economy: Dictionary = Fixtures.data()["economy"]
	var expected: int = int(economy["reward_small"]) + int(economy["reward_per_cast_left"]) * casts \
		+ mini(start / int(economy["interest_per"]), int(economy["interest_max"]))
	check(summary["won"], "won")
	check_eq(summary["reward"]["total"], expected, "round + Casts left + interest:")
	check_eq(exam.money, start + expected, "Coins:")


func test_interest_has_a_cap() -> void:
	var exam: ExamState = _exam()
	var state: RoundState = exam.new_round()
	state.money = 1000
	check_eq(exam.reward_for(state)["interest"], int(Fixtures.data()["economy"]["interest_max"]), "capped:")


func test_a_lost_round_ends_the_exam() -> void:
	var exam: ExamState = _exam()
	var state: RoundState = exam.new_round()
	state.casts_left = 0
	state.finish()
	var summary: Dictionary = exam.finish_round(state)
	check(not summary["won"], "lost")
	check(exam.is_over() and not exam.passed, "the exam is over, failed")


func test_twenty_four_rounds_pass_the_exam() -> void:
	var exam: ExamState = _exam()
	var last: Dictionary = {}
	for i: int in 24:
		check(not exam.is_over(), "round %d still on" % (i + 1))
		last = _win(exam)
	check(exam.is_over() and exam.passed, "passed")
	check(last["exam_passed"], "the last summary says so")
	check_eq(exam.defeated.size(), 8, "every examiner beaten:")


func test_the_bag_and_the_word_levels_stay_between_rounds() -> void:
	var exam: ExamState = _exam()
	var first: RoundState = exam.new_round()
	check(first.bag == exam.bag, "the exam's bag")
	exam.bag.add_copy_of(exam.bag.stones[0])
	first.word_levels["pair"] = 3
	first.score = first.target
	first.finish()
	exam.finish_round(first)
	var second: RoundState = exam.new_round()
	check_eq(second.bag.size(), 49, "the copy is still there:")
	check_eq(second.word_level("pair"), 3, "the Pair keeps its level:")


func test_kaldor_wants_exactly_five_stones() -> void:
	var state: RoundState = _round("kaldor")
	check(not state.can_cast([0, 1]), "two stones are not enough")
	check(state.can_cast([0, 1, 2, 3, 4]), "five are")
	_put(state, ["algiz"])
	check(state.can_cast([0, 1]), "unless Algiz is cast: the rule keeps away")


func test_ignar_charges_for_swaps_and_aeva_after_three() -> void:
	var state: RoundState = _round("ignar")
	state.swap([0])
	check_eq(state.money, 9, "one Coin:")
	state.money = 0
	check(not state.can_swap([0]), "no Coins, no Swap")
	var aeva: RoundState = _round("aeva")
	check_eq(aeva.casts_left, 1, "a single Cast:")
	for i: int in 3:
		aeva.swap([0])
	check_eq(aeva.money, 10, "three free Swaps:")
	aeva.swap([0])
	check_eq(aeva.money, 9, "then one Coin each:")


func test_varr_and_gronn_keep_stones_from_scoring() -> void:
	var varr: RoundState = _round("varr")
	var result: Dictionary = _cast(varr, ["fehu", "hagalaz"])
	check_eq((result["blocked"] as Array).size(), 1, "one stone of the Pair is struck:")
	var gronn: RoundState = _round("gronn")
	var heavy: Dictionary = _cast(gronn, ["fehu", "hagalaz", "dagaz", "sowilo"])
	check_eq(heavy["blocked"], [0, 1] as Array[int], "Position 1 stones do not score:")
	var plain: RoundState = _round()
	check(float(heavy["score"]) < float(_cast(plain, ["fehu", "hagalaz", "dagaz", "sowilo"])["score"]),
		"so the Cast is worth less")


func test_morrah_and_ilinca_zero_the_score() -> void:
	var morrah: RoundState = _round("morrah")
	check(float(_cast(morrah, ["fehu", "hagalaz"])["score"]) > 0.0, "the first Pair scores")
	check_eq(float(_cast(morrah, ["uruz", "naudiz"])["score"]), 0.0, "the second Pair does not:")
	var ilinca: RoundState = _round("ilinca")
	check_eq(float(_cast(ilinca, ["fehu", "hagalaz"])["score"]), 0.0, "a Pair is graded 0:")
	check(float(_cast(ilinca, ["fehu", "hagalaz", "uruz", "naudiz"])["score"]) > 0.0, "Two Pairs pass")


func test_dara_raises_the_target_after_every_cast() -> void:
	var state: RoundState = _round("dara", 1000.0)
	_cast(state, ["wunjo"])
	check_eq(state.target, 1100.0, "+10%:")


func test_selvia_redraws_the_whole_hand() -> void:
	var state: RoundState = _round("selvia")
	var kept: Stone = state.hand[7]
	_cast(state, ["wunjo"])
	check(not state.hand.has(kept), "the held stones went back into the bag")
	check_eq(state.hand.size(), state.hand_limit(), "a full new hand:")


func test_lunet_draws_three_stones_face_down() -> void:
	var state: RoundState = _round("lunet")
	var hidden: int = 0
	for stone: Stone in state.hand:
		if stone.face_down:
			hidden += 1
	check_eq(hidden, 3, "face down:")
	state.cast([0])
	check(not state.hand.is_empty(), "drawing again")


func test_spells_against_the_examiner() -> void:
	var smoke: RoundState = _round("ilinca")
	check(float(_cast(smoke, ["kenaz", "algiz", "fehu", "hagalaz"])["score"]) > 0.0,
		"The Smoke: the rule does not touch this Cast")
	var frost: RoundState = _round("ilinca")
	_cast(frost, ["isaz", "algiz"])
	check_eq(frost.active_rule(), "", "The Frost: no rule for the rest of the round:")
	check(float(_cast(frost, ["fehu", "hagalaz"])["score"]) > 0.0, "a Pair scores again")
	var thorn: RoundState = _round("kaldor", 1000.0)
	_cast(thorn, ["thurisaz", "algiz", "fehu", "uruz", "ansuz"])
	check_eq(thorn.target, 800.0, "The Sting: the target -20%:")


func test_against_no_examiner_only_coins() -> void:
	var state: RoundState = _round()
	var money: int = state.money
	_cast(state, ["isaz", "algiz"])
	check_eq(state.money, money + int(Fixtures.data()["economy"]["examiner_spell_fallback_money"]), "+3 Coins:")


func test_water_against_the_examiner_swaps_the_rule() -> void:
	var state: RoundState = _round("ilinca")
	_cast(state, ["laguz", "algiz"])
	var choice: Dictionary = state.current_choice()
	check_eq(choice.get("kind"), "swap_rule", "a pick:")
	check_eq((choice["rules"] as Array).size(), 2, "between two rules:")
	check(not (choice["rules"] as Array).has("ilinca") and not (choice["rules"] as Array).has("aeva"),
		"never the same one, never the final")
	check(state.answer({"rule": choice["rules"][1]}), "picked")
	check_eq(str(state.rule["id"]), str(choice["rules"][1]), "the new rule:")
