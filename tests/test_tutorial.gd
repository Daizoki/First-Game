extends "res://tests/test_case.gd"
## The evening class: the step machine (TutorialFlow), fixed hands, and that every lesson
## ends the way data/tutorial.json describes it (and not without the lesson's move).

const Fixtures = preload("res://tests/fixtures.gd")
const TutorialFlow = preload("res://scripts/core/tutorial_flow.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const Stone = preload("res://scripts/core/stone.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")


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


func test_book_wait_names_the_book() -> void:
	var flow: TutorialFlow = _flow_with([{"text": {}, "wait_for": {"event": "book_closed", "book": "words"}}, {"text": {}}])
	check_eq(flow.handle("book_closed", {"book": "runes"})["result"], "none", "the Book of Runes:")
	check_eq(flow.handle("book_closed", {"book": "words"})["result"], "advance", "the Book of Words:")


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


# --- Every lesson, played through the step machine ------------------------------------------

## Plays a lesson the way the tutorial screen would: game actions go through a RoundState set
## up like the lesson, and the same events reach the flow. Fails on actions the gate forbids.
## actions: ["advance"], ["hover", rune], ["select", [runes]], ["swap", [runes]], ["cast"],
## ["book"]. Returns the last flow result.
func _play_lesson(lesson: Dictionary, actions: Array) -> String:
	var flow: TutorialFlow = TutorialFlow.new()
	flow.setup({"lessons": [lesson]})
	var state: RoundState = _round(lesson)
	var selected: Array = []
	var last: String = ""
	for action: Array in actions:
		var kind: String = action[0]
		var gate: Dictionary = flow.gate()
		var needs: String = {"select": "select", "swap": "swap", "cast": "cast", "book": "word_book"}.get(kind, "")
		if not needs.is_empty() and not (gate["actions"] as Array).has(needs):
			failures.append("%s: \"%s\" is not allowed at step %d" % [lesson["id"], kind, flow.step_index])
			return "blocked"
		match kind:
			"advance":
				last = flow.advance()["result"]
			"hover":
				last = flow.handle("hover", {"rune": action[1]})["result"]
			"select":
				selected = action[1]
				for id: Variant in selected:
					var runes: Array = gate["runes"]
					if not runes.is_empty() and not runes.has(id):
						failures.append("%s: %s cannot be selected at step %d" % [lesson["id"], id, flow.step_index])
				var preview: Dictionary = state.preview(_indices(state, selected))
				last = flow.handle("selection", {"word": preview.get("word", ""), "runes": selected})["result"]
			"swap":
				state.swap(_indices(state, action[1]))
				last = flow.handle("swap", {"count": (action[1] as Array).size()})["result"]
				selected = []
			"cast":
				var indices: Array[int] = _indices(state, selected)
				var word: String = state.preview(indices).get("word", "")
				last = flow.handle("cast", {"word": word, "runes": selected})["result"]
				var result: Dictionary = state.cast(indices)
				for spell: String in result["spells"]:
					last = flow.handle("spell_cast", {"spell": spell})["result"]
				if result["won"]:
					last = flow.handle("round_won")["result"]
				elif result["lost"]:
					last = flow.handle("round_lost")["result"]
				selected = []
			"book":
				flow.handle("book_opened", {"book": "words"})
				last = flow.handle("book_closed", {"book": "words"})["result"]
		if last == "lesson_done" or last == "lesson_failed":
			return last
	return last


func test_every_lesson_has_steps_and_valid_hands() -> void:
	var lessons: Array = Fixtures.data()["tutorial"]["lessons"]
	check_eq(lessons.size(), 5, "lessons:")
	for lesson: Dictionary in lessons:
		check(not (lesson["steps"] as Array).is_empty(), "%s has steps" % lesson["id"])
		if lesson.has("hand"):
			check_eq((lesson["hand"] as Array).size(), 8, "%s hand size:" % lesson["id"])
			var state: RoundState = _round(lesson)
			check_eq(_hand_ids(state), _strings(lesson["hand"]), "%s hand:" % lesson["id"])


func _strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str(value))
	return result


func test_lesson_1_plays_to_the_end() -> void:
	var result: String = _play_lesson(_lesson("stones_and_casting"), [
		["advance"], ["hover", "fehu"], ["advance"], ["select", ["fehu", "hagalaz"]], ["advance"],
		["cast"], ["advance"], ["select", ["gebo", "dagaz"]], ["cast"],
	])
	check_eq(result, "lesson_done", "lesson 1:")


func test_lesson_2_needs_the_swap_for_its_family() -> void:
	var lesson: Dictionary = _lesson("swapping_and_big_words")
	var state: RoundState = _round(lesson)
	check(not WordDetector.available_in_hand(state.hand).has("family"), "no Family before swapping")
	state.swap(_indices(state, ["raidho", "wunjo"]))
	check(WordDetector.available_in_hand(state.hand).has("family"), "a Family after swapping Raidho and Wunjo")


func test_lesson_2_family_wins_in_one_cast_however_the_hand_is_ordered() -> void:
	var lesson: Dictionary = _lesson("swapping_and_big_words")
	var family: Array = ["isaz", "ehwaz", "thurisaz", "gebo", "dagaz"]
	for variant: String in ["as dealt", "other swap", "sorted by position", "sorted by kin"]:
		var state: RoundState = _round(lesson)
		state.swap(_indices(state, ["kenaz", "naudiz"] if variant == "other swap" else ["raidho", "wunjo"]))
		if variant == "sorted by position":
			state.sort_by_position()
		elif variant == "sorted by kin":
			state.sort_by_kin()
		var result: Dictionary = _cast(state, family)
		check_eq(result["word"], "family", "%s word:" % variant)
		check(result["won"], "%s: the Family wins (%s of %s)" % [variant, state.score, state.target])


func test_lesson_2_is_not_won_without_the_family() -> void:
	var lesson: Dictionary = _lesson("swapping_and_big_words")
	# The strongest two Casts without a Family (searched over every swap of the swappable
	# stones and every pair of Casts): swap Wunjo, Two Pairs, then a single rune. 2 395 points.
	var state: RoundState = _round(lesson)
	state.swap(_indices(state, ["wunjo"]))
	_cast(state, ["ehwaz", "gebo", "dagaz", "thurisaz"])
	_cast(state, ["isaz", "raidho", "kenaz", "naudiz", "jera"])
	check(state.score < state.target, "best line without a Family: %s of %s" % [state.score, state.target])
	# The natural alternative: the Triad and the Pair one after another.
	var split: RoundState = _round(lesson)
	split.swap(_indices(split, ["raidho", "wunjo"]))
	_cast(split, ["isaz", "ehwaz", "thurisaz"])
	_cast(split, ["gebo", "dagaz"])
	check(split.score < split.target, "Triad then Pair: %s of %s" % [split.score, split.target])


func test_lesson_2_plays_to_the_end() -> void:
	var result: String = _play_lesson(_lesson("swapping_and_big_words"), [
		["advance"], ["select", ["raidho", "wunjo"]], ["swap", ["raidho", "wunjo"]], ["advance"],
		["select", ["isaz", "ehwaz", "thurisaz", "gebo", "dagaz"]], ["cast"], ["book"],
	])
	check_eq(result, "lesson_done", "lesson 2:")


func test_lesson_3_needs_hagalaz_to_strike_twice() -> void:
	var lesson: Dictionary = _lesson("voice_of_the_runes")
	var state: RoundState = _round(lesson)
	check_eq(_cast(state, ["hagalaz", "fehu"])["word"], "pair", "hagalaz + fehu:")
	_cast(state, ["kenaz", "ingwaz"])
	check(state.is_won(), "Hagalaz + Fehu, then Kenaz + Ingwaz wins: %s of %s" % [state.score, state.target])
	# The same Casts if Hagalaz struck only once.
	var data: Dictionary = Fixtures.data().duplicate(true)
	((data["runes"] as Dictionary)["hagalaz"] as Dictionary).erase("effects")
	var once: RoundState = RoundState.new()
	once.setup(data, Fixtures.rng(int(lesson["seed"])), float(lesson["target"]), lesson)
	once.start()
	_cast(once, ["hagalaz", "fehu"])
	_cast(once, ["kenaz", "ingwaz"])
	check(not once.is_won(), "without the second strike: %s of %s" % [once.score, once.target])


func test_lesson_3_is_not_won_without_casting_hagalaz() -> void:
	var lesson: Dictionary = _lesson("voice_of_the_runes")
	var others: Array = ["fehu", "isaz", "berkanan", "wunjo", "kenaz", "raidho", "ingwaz"]
	var best: float = 0.0
	for first: Array in _combinations(others, 5):
		for second: Array in _combinations(others, 5):
			var state: RoundState = _round(lesson)
			if _cast(state, first).is_empty() or _cast(state, second).is_empty():
				continue
			best = maxf(best, state.score)
	check(best < float(lesson["target"]), "best two Casts without Hagalaz: %s" % best)


## Every subset of `items` with 1..max_size elements, in order.
func _combinations(items: Array, max_size: int) -> Array:
	var result: Array = []
	for mask: int in range(1, 1 << items.size()):
		var subset: Array = []
		for i: int in items.size():
			if mask & (1 << i):
				subset.append(items[i])
		if subset.size() <= max_size:
			result.append(subset)
	return result


func test_lesson_3_plays_to_the_end() -> void:
	var result: String = _play_lesson(_lesson("voice_of_the_runes"), [
		["advance"], ["hover", "hagalaz"], ["advance"], ["select", ["hagalaz", "fehu"]], ["cast"],
		["advance"], ["select", ["kenaz", "ingwaz"]], ["cast"],
	])
	check_eq(result, "lesson_done", "lesson 3:")


func test_lesson_4_spell_and_triad_in_one_cast() -> void:
	var lesson: Dictionary = _lesson("spells")
	var state: RoundState = _round(lesson)
	var preview: Dictionary = state.preview(_indices(state, ["isaz", "hagalaz", "naudiz", "fehu", "tiwaz"]))
	check_eq(preview["word"], "triad", "the five stones:")
	check_eq(preview["spells"], ["winter"] as Array[String], "spells:")
	var result: Dictionary = _cast(state, ["isaz", "hagalaz", "naudiz", "fehu", "tiwaz"])
	check(float(result["score"]) < float(lesson["target"]), "the Triad alone is below the target")
	check(result["won"], "Winter lowers the target enough: %s of %s" % [state.score, state.target])
	# The same Cast with no Spells in the game.
	var data: Dictionary = Fixtures.data().duplicate(true)
	data["spells"] = {}
	var plain: RoundState = RoundState.new()
	plain.setup(data, Fixtures.rng(int(lesson["seed"])), float(lesson["target"]), lesson)
	plain.start()
	check(not _cast(plain, ["isaz", "hagalaz", "naudiz", "fehu", "tiwaz"])["won"], "without Winter it is not won")


func test_lesson_4_plays_to_the_end() -> void:
	var result: String = _play_lesson(_lesson("spells"), [
		["advance"], ["advance"], ["select", ["isaz", "hagalaz", "naudiz"]], ["advance"],
		["select", ["isaz", "hagalaz", "naudiz", "fehu", "tiwaz"]], ["cast"], ["advance"], ["advance"],
	])
	check_eq(result, "lesson_done", "lesson 4:")


func test_lesson_5_small_target_two_or_three_words() -> void:
	var lesson: Dictionary = _lesson("on_your_own")
	var pairs: RoundState = _round(lesson)
	for pair: Array in [["thurisaz", "isaz"], ["uruz", "berkanan"], ["mannaz", "ansuz"]]:
		_cast(pairs, pair)
	check(pairs.is_won(), "three Pairs win: %s of %s" % [pairs.score, pairs.target])
	var singles: RoundState = _round(lesson)
	for rune: String in ["hagalaz", "perthro", "uruz", "ansuz"]:
		_cast(singles, [rune])
	check(not singles.is_won(), "four single runes do not: %s of %s" % [singles.score, singles.target])


func test_lesson_5_plays_to_the_end() -> void:
	var result: String = _play_lesson(_lesson("on_your_own"), [
		["advance"], ["select", ["mannaz", "ansuz"]], ["cast"], ["select", ["uruz", "berkanan"]], ["cast"],
	])
	check_eq(result, "lesson_done", "lesson 5:")
