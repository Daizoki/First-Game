extends "res://tests/test_case.gd"
## The evening class: the step machine (TutorialFlow), fixed hands, and that every lesson
## ends the way data/tutorial.json describes it (and not without the lesson's move).

const Fixtures = preload("res://tests/fixtures.gd")
const TutorialFlow = preload("res://scripts/core/tutorial_flow.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _flow() -> TutorialFlow:
	var flow: TutorialFlow = TutorialFlow.new()
	flow.setup(Fixtures.data()["tutorial"])
	return flow


func _lesson(id: String) -> Dictionary:
	for lesson: Dictionary in Fixtures.data()["tutorial"]["lessons"]:
		if lesson["id"] == id:
			return lesson
	return {}


## A round set up exactly like the tutorial sets up this lesson.
func _round(lesson: Dictionary) -> RoundState:
	var rng: RandomNumberGenerator = Fixtures.rng(int(lesson["seed"]))
	var state: RoundState = RoundState.new()
	state.setup(Fixtures.data(), rng, float(lesson["target"]), lesson)
	state.start()
	return state


func _indices(state: RoundState, rune_ids: Array) -> Array[int]:
	var indices: Array[int] = []
	for id: Variant in rune_ids:
		for i: int in state.hand.size():
			if state.hand[i].rune_id == id and not indices.has(i):
				indices.append(i)
				break
	return indices


## Casts these runes (by id). Returns the cast result ({} if not possible).
func _cast(state: RoundState, rune_ids: Array) -> Dictionary:
	var indices: Array[int] = _indices(state, rune_ids)
	if indices.size() != rune_ids.size():
		return {}
	return state.cast(indices)


func _hand_ids(state: RoundState) -> Array[String]:
	var ids: Array[String] = []
	for stone: Stone in state.hand:
		ids.append(stone.rune_id)
	return ids


# --- RoundState with a fixed hand ---------------------------------------------------------

func test_fixed_hand_is_dealt_in_order() -> void:
	var state: RoundState = RoundState.new()
	var hand: Array[String] = ["fehu", "hagalaz", "gebo", "isaz", "raidho", "dagaz", "wunjo", "ingwaz"]
	state.setup(Fixtures.data(), Fixtures.rng(), 100.0, {"hand": hand, "bag_top": ["jera"], "casts": 2, "swaps": 1})
	state.start()
	check_eq(_hand_ids(state), hand, "hand in order:")
	check_eq(state.bag.peek(1)[0].rune_id, "jera", "bag_top is next:")
	check_eq(state.bag.remaining(), 40, "the rest of the full bag stays:")
	check_eq(state.casts_left, 2, "casts override:")
	check_eq(state.swaps_left, 1, "swaps override:")


func test_bag_only_holds_just_the_lesson_stones() -> void:
	var state: RoundState = RoundState.new()
	state.setup(Fixtures.data(), Fixtures.rng(), 100.0, {
		"hand": ["isaz", "ehwaz"], "bag_top": ["thurisaz"], "bag_only": true,
	})
	state.start()
	check_eq(_hand_ids(state), ["isaz", "ehwaz", "thurisaz"] as Array[String], "hand:")
	check_eq(state.bag.size(), 3, "bag size:")
	check_eq(state.bag.remaining(), 0, "nothing left to draw:")


# --- TutorialFlow ---------------------------------------------------------------------------

func _flow_with(steps: Array) -> TutorialFlow:
	var flow: TutorialFlow = TutorialFlow.new()
	flow.setup({"lessons": [{"id": "test", "steps": steps}, {"id": "next", "steps": [{"text": {}}]}]})
	return flow


func test_talk_steps_advance_on_click_only() -> void:
	var flow: TutorialFlow = _flow_with([{"text": {}}, {"text": {}, "wait_for": {"event": "hover"}}])
	check_eq(flow.handle("hover", {"rune": "fehu"})["result"], "none", "events do not skip talk:")
	check_eq(flow.advance()["result"], "advance", "click:")
	check_eq(flow.step_index, 1, "on the wait step:")
	check_eq(flow.advance()["result"], "none", "clicks do not skip waits:")
	check_eq(flow.handle("hover", {"rune": ""})["result"], "none", "leaving a stone is not a hover:")
	check_eq(flow.handle("hover", {"rune": "fehu"})["result"], "advance", "hover:")


func test_selection_wrong_alt_and_right() -> void:
	var flow: TutorialFlow = _flow_with([
		{"text": {}, "wait_for": {"event": "selection", "word": "pair", "prefer": ["fehu", "hagalaz"],
			"alt_text": {"ro": "alt"}}, "wrong_text": {"ro": "wrong"}},
		{"text": {}},
	])
	check_eq(flow.handle("selection", {"word": "single", "runes": ["gebo"]})["result"], "none", "one stone: still choosing:")
	var wrong: Dictionary = flow.handle("selection", {"word": "single", "runes": ["gebo", "isaz"]})
	check_eq(wrong["result"], "wrong", "two stones, no pair:")
	check_eq(wrong["say"], {"ro": "wrong"}, "wrong text:")
	var alt: Dictionary = flow.handle("selection", {"word": "pair", "runes": ["gebo", "dagaz"]})
	check_eq(alt["result"], "advance", "another pair is accepted:")
	check_eq(alt["say"], {"ro": "alt"}, "with the alternative line:")
	var right: TutorialFlow = _flow_with([
		{"text": {}, "wait_for": {"event": "selection", "word": "pair", "prefer": ["fehu", "hagalaz"],
			"alt_text": {"ro": "alt"}}},
		{"text": {}},
	])
	check_eq(right.handle("selection", {"word": "pair", "runes": ["hagalaz", "fehu"]})["say"], null, "the asked pair:")


func test_exact_selection_and_cast_conditions() -> void:
	var flow: TutorialFlow = _flow_with([
		{"text": {}, "wait_for": {"event": "selection", "exact": ["isaz", "hagalaz", "naudiz"]}},
		{"text": {}, "wait_for": {"event": "cast", "include": ["hagalaz", "fehu"]}, "wrong_text": {"ro": "no"}},
		{"text": {}, "wait_for": {"event": "spell_discovered", "spell": "winter"}},
	])
	check_eq(flow.handle("selection", {"word": "single", "runes": ["isaz", "hagalaz"]})["result"], "none", "2 of 3:")
	check_eq(flow.handle("selection", {"word": "triad", "runes": ["isaz", "hagalaz", "fehu"]})["result"], "wrong", "wrong third:")
	check_eq(flow.handle("selection", {"word": "single", "runes": ["naudiz", "isaz", "hagalaz"]})["result"], "advance", "all three:")
	check_eq(flow.handle("cast", {"word": "single", "runes": ["fehu"]})["result"], "wrong", "cast without hagalaz:")
	check_eq(flow.handle("cast", {"word": "pair", "runes": ["fehu", "hagalaz"]})["result"], "advance", "cast with both:")
	check_eq(flow.handle("spell_discovered", {"spell": "market"})["result"], "none", "another spell:")
	check_eq(flow.handle("spell_discovered", {"spell": "winter"})["result"], "advance", "winter:")


func test_lost_round_fails_the_lesson() -> void:
	var flow: TutorialFlow = _flow_with([{"text": {}, "wait_for": {"event": "round_won"}}])
	check_eq(flow.handle("round_lost")["result"], "lesson_failed", "lost:")


func test_won_round_skips_play_waits_but_keeps_talk() -> void:
	var flow: TutorialFlow = _flow_with([
		{"text": {}, "wait_for": {"event": "cast"}},
		{"text": {}, "wait_for": {"event": "selection", "word": "pair"}},
		{"text": {}},
		{"text": {}, "wait_for": {"event": "round_won"}},
	])
	check_eq(flow.handle("round_won")["result"], "advance", "won early:")
	check_eq(flow.step_index, 2, "lands on the talk step:")
	check_eq(flow.advance()["result"], "lesson_done", "the last wait is already satisfied:")


func test_steps_done_then_free_play_until_won() -> void:
	var flow: TutorialFlow = _flow_with([{"text": {}}])
	check_eq(flow.advance()["result"], "advance", "last talk:")
	check(flow.steps_done(), "no steps left")
	check(flow.gate()["actions"].has("cast"), "free play allows casting")
	check_eq(flow.handle("round_won")["result"], "lesson_done", "won:")


func test_gate_follows_the_step() -> void:
	var flow: TutorialFlow = _flow_with([
		{"text": {}},
		{"text": {}, "wait_for": {"event": "swap"}, "allow": ["select", "swap"], "selectable": ["raidho", "wunjo"]},
	])
	var talk: Dictionary = flow.gate()
	check(not talk["actions"].has("select") and not talk["actions"].has("cast"), "talk: no playing")
	check(talk["actions"].has("menu"), "talk: the menu always works")
	flow.advance()
	var wait: Dictionary = flow.gate()
	check(wait["actions"].has("swap") and wait["actions"].has("select"), "wait: allowed actions")
	check(not wait["actions"].has("cast"), "wait: cast stays off")
	check_eq(wait["runes"], ["raidho", "wunjo"] as Array[String], "wait: selectable stones:")


# --- Lesson 1: Stones and Casting -------------------------------------------------------------

func test_lesson_1_hand_has_exactly_two_pairs() -> void:
	var state: RoundState = _round(_lesson("stones_and_casting"))
	check_eq(state.preview(_indices(state, ["fehu", "hagalaz"]))["word"], "pair", "fehu + hagalaz:")
	check_eq(state.preview(_indices(state, ["gebo", "dagaz"]))["word"], "pair", "gebo + dagaz:")
	var positions: Dictionary = {}
	for stone: Stone in state.hand:
		positions[stone.position] = int(positions.get(stone.position, 0)) + 1
	var pairs: int = 0
	for count: int in positions.values():
		pairs += 1 if count >= 2 else 0
	check_eq(pairs, 2, "pairs in hand:")


func test_lesson_1_two_pairs_win_in_either_order() -> void:
	for order: Array in [[["fehu", "hagalaz"], ["gebo", "dagaz"]], [["gebo", "dagaz"], ["fehu", "hagalaz"]]]:
		var state: RoundState = _round(_lesson("stones_and_casting"))
		var first: Dictionary = _cast(state, order[0])
		check(not first["won"], "one pair is not enough (%s first)" % order[0][0])
		var second: Dictionary = _cast(state, order[1])
		check(second["won"], "two pairs win (%s first): %s of %s" % [order[0][0], state.score, state.target])


func test_lesson_1_is_not_won_without_pairs() -> void:
	# The strongest single stones, three Casts: still short of the target.
	var best: float = 0.0
	var ids: Array[String] = ["fehu", "hagalaz", "gebo", "isaz", "raidho", "dagaz", "wunjo", "ingwaz"]
	for a: String in ids:
		for b: String in ids:
			for c: String in ids:
				if a == b or b == c or a == c:
					continue
				var state: RoundState = _round(_lesson("stones_and_casting"))
				_cast(state, [a])
				_cast(state, [b])
				_cast(state, [c])
				best = maxf(best, state.score)
	check(best < float(_lesson("stones_and_casting")["target"]), "three single runes reach only %s" % best)
	# The lesson's first Pair (Fehu + Hagalaz) and two single runes are not enough either.
	var with_pair: float = 0.0
	for b: String in ids:
		for c: String in ids:
			if b == c or ["fehu", "hagalaz"].has(b) or ["fehu", "hagalaz"].has(c):
				continue
			var state: RoundState = _round(_lesson("stones_and_casting"))
			_cast(state, ["fehu", "hagalaz"])
			_cast(state, [b])
			_cast(state, [c])
			with_pair = maxf(with_pair, state.score)
	check(with_pair < float(_lesson("stones_and_casting")["target"]), "fehu+hagalaz and two singles reach %s" % with_pair)
