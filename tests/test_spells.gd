extends "res://tests/test_case.gd"
## The spells of the rune grammar in a round: base effects, the 8 Actions (on a numeric
## effect and on a "single" one), the player's picks, the Scroll, the next round and the
## safety limits from economy.json.

const Fixtures = preload("res://tests/fixtures.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const SpellResolver = preload("res://scripts/core/spell_resolver.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _round(target: float = 1.0e9, carry: Dictionary = {}, seed_value: int = 42) -> RoundState:
	var state: RoundState = RoundState.new()
	var options: Dictionary = {} if carry.is_empty() else {"carry": carry}
	state.setup(Fixtures.data(), Fixtures.rng(seed_value), target, options)
	state.start()
	return state


## Puts these runes in hand (the rest of the old hand stays after them) and casts them in order.
func _cast(state: RoundState, ids: Array) -> Dictionary:
	var stones: Array[Stone] = Fixtures.stones(ids)
	var order: Array[int] = []
	for i: int in stones.size():
		order.append(i)
	stones.append_array(state.hand.slice(0, maxi(0, state.hand.size() - stones.size())))
	state.hand = stones
	return state.cast(order)


func test_strength_into_coins_and_its_actions() -> void:
	var cases: Dictionary = {
		"": 4, "ehwaz": 8, "raidho": 6, "naudiz": 10, "eihwaz": 4, "jera": 0, "gebo": 0,
	}
	for action: String in cases:
		var state: RoundState = _round()
		var ids: Array = ["uruz", "fehu"] if action.is_empty() else ["uruz", action, "fehu"]
		_cast(state, ids)
		check_eq(state.money, cases[action], "Strength %s into Coins:" % action)


func test_berkanan_grows_with_every_cast_of_the_same_spell() -> void:
	var state: RoundState = _round()
	_cast(state, ["uruz", "berkanan", "fehu"])
	check_eq(state.money, 4, "first time: +4")
	_cast(state, ["uruz", "berkanan", "fehu"])
	check_eq(state.money, 4 + 6, "second time: +50%")


func test_jera_ripens_at_the_end_of_the_round_doubled() -> void:
	var state: RoundState = _round()
	_cast(state, ["uruz", "jera", "fehu"])
	check_eq(state.money, 0, "nothing yet:")
	state.finish()
	# +8 from the spell; Jera also scored (the highest stone), so its own Voice pays +2.
	check_eq(state.money, 8 + 2, "at the end, ×2:")


func test_perthro_is_all_or_nothing() -> void:
	var seen: Dictionary = {}
	for seed_value: int in range(1, 30):
		var state: RoundState = _round(1.0e9, {}, seed_value)
		_cast(state, ["uruz", "perthro", "fehu"])
		check(state.money == 12 or state.money == 0, "Perthro gives ×3 or nothing, got %d" % state.money)
		seen[state.money] = true
	check(seen.has(12) and seen.has(0), "both outcomes happen: %s" % str(seen.keys()))


func test_naudiz_asks_its_price() -> void:
	var state: RoundState = _round()
	var casts: int = state.casts_left
	_cast(state, ["uruz", "naudiz", "fehu"])
	check_eq(state.current_choice().get("kind"), "price", "a price to pay:")
	check(not state.can_cast([0]), "no Cast while a pick waits")
	check(state.answer({"option": "money"}), "pay in Coins")
	check_eq(state.money, 10 - 4, "+10, then -4:")
	check_eq(state.casts_left, casts - 1, "only the Cast itself:")
	var other: RoundState = _round()
	_cast(other, ["uruz", "naudiz", "fehu"])
	other.answer({"option": "cast"})
	check_eq(other.casts_left, casts - 2, "or pay with a Cast:")


func test_eihwaz_comes_back_in_the_next_two_rounds() -> void:
	var first: RoundState = _round()
	_cast(first, ["uruz", "eihwaz", "fehu"])
	check_eq(first.money, 4, "now:")
	var second: RoundState = _round(1.0e9, first.carry)
	check_eq(second.money, 2, "next round, half:")
	var third: RoundState = _round(1.0e9, first.carry)
	check_eq(third.money, 2, "the round after:")
	var fourth: RoundState = _round(1.0e9, first.carry)
	check_eq(fourth.money, 0, "then it is over:")


func test_gebo_keeps_the_spell_on_a_scroll() -> void:
	var state: RoundState = _round()
	_cast(state, ["uruz", "gebo", "fehu"])
	check(state.has_scroll(), "a Scroll")
	check_eq(state.scroll_spell(), "uruz_fehu", "with Strength into Coins:")
	_cast(state, ["uruz", "gebo", "fehu"])
	check_eq(state.money, 4, "the slot is full, so the second one happens now:")
	check(state.use_scroll(), "use it")
	_cast(state, ["isaz"])
	check_eq(state.money, 8, "it happens with the next Cast:")
	check(not state.has_scroll(), "the Scroll is used up")


func test_raidho_spreads_a_single_spell_over_the_whole_hand() -> void:
	var state: RoundState = _round()
	_cast(state, ["hagalaz", "fehu"])
	check_eq(state.current_choice().get("kind"), "break_chosen_money", "pick a stone to smash:")
	var stone: Stone = state.hand[0]
	var bag_size: int = state.bag.size()
	check(state.answer({"stones": [0]}), "smash the first stone")
	# Hagalaz and Fehu are also a Pair: Fehu's Voice pays +1.
	check_eq(state.money, 1 + 6, "+6:")
	check(not state.hand.has(stone), "the stone left the hand")
	check(state.bag.size() <= bag_size, "and the bag")
	var spread: RoundState = _round()
	var hand_size: int = spread.hand.size()
	_cast(spread, ["hagalaz", "raidho", "fehu"])
	check(spread.pending.is_empty(), "no pick: every stone is touched")
	check_eq(spread.money, 1 + 3 * hand_size, "half strength (+3) for each of %d stones:" % hand_size)


func test_actions_that_mean_nothing_are_ignored() -> void:
	var state: RoundState = _round()
	var result: Dictionary = _cast(state, ["isaz", "raidho", "othala"])
	var plan: Dictionary = (result["plans"] as Array)[0]
	check_eq(plan["ignored"], ["raidho"] as Array[String], "×1.5 on a spell without numbers:")


func test_factor_scales_only_its_bonus() -> void:
	var spell: Dictionary = Fixtures.data()["spells"]["kenaz_ansuz"]
	check_eq(SpellResolver.effect_values(spell, 2.0)["factor"], 2.0, "×1.5 at double strength is ×2:")
	check_eq(SpellResolver.effect_values(spell, 1.5)["factor"], 1.75, "×1.5 spread is ×1.75:")


func test_before_spells_change_this_cast() -> void:
	var plain: RoundState = _round()
	var base: Dictionary = _cast(plain, ["kenaz", "isaz"])
	var state: RoundState = _round()
	var boosted: Dictionary = _cast(state, ["kenaz", "ansuz"])
	check_eq(boosted["word"], base["word"], "the same Word:")
	check_eq(boosted["res"], float(base["res"]) * 1.5, "Fire into the Word: ×1.5 Resonance:")


func test_the_future_reaches_the_next_cast_and_round() -> void:
	var state: RoundState = _round()
	_cast(state, ["kenaz", "ingwaz"])
	var next: Dictionary = _cast(state, ["isaz"])
	var doubled: bool = false
	for event: Dictionary in next["events"]:
		if event["type"] == "bonus" and event["kind"] == "mul_res" and float(event["value"]) == 2.0:
			doubled = true
	check(doubled, "Tomorrow's Embers: the next Cast has ×2 Resonance")
	check(not _has_mul_res(_cast(state, ["isaz"])), "and only that one")
	_cast(state, ["dagaz", "ingwaz"])
	var casts: int = _round().casts_left
	check_eq(_round(1.0e9, state.carry).casts_left, casts + 1, "Tomorrow: +1 Cast next round:")


func test_the_target_never_drops_below_its_floor() -> void:
	var state: RoundState = _round(1000.0)
	_cast(state, ["thurisaz", "ehwaz", "tiwaz"])
	check_eq(state.target, 422.5, "The Barb twice (1000 × 0.65 × 0.65):")
	_cast(state, ["thurisaz", "tiwaz"])
	check_eq(state.target, 400.0, "never below 40%:")


func test_spells_add_at_most_two_casts_a_round() -> void:
	var state: RoundState = _round()
	var casts: int = state.casts_left
	_cast(state, ["dagaz", "ehwaz", "tiwaz"])
	check_eq(state.casts_left, casts - 1 + 2, "The Long Day twice:")
	_cast(state, ["dagaz", "tiwaz"])
	check_eq(state.casts_left, casts - 2 + 2, "no more than +2 in a round:")


func test_every_pick_has_a_sensible_automatic_answer() -> void:
	for ids: Array in [["hagalaz", "othala"], ["laguz", "othala"], ["sowilo", "othala"], ["thurisaz", "othala"],
			["laguz", "mannaz"], ["sowilo", "mannaz"], ["thurisaz", "mannaz"]]:
		var state: RoundState = _round()
		_cast(state, ids)
		check(not state.pending.is_empty(), "%s waits for a pick" % str(ids))
		state.answer_all_automatically()
		check(state.pending.is_empty(), "%s: answered" % str(ids))
		check(state.hand.size() >= state.hand_limit(), "%s: the hand is full again" % str(ids))


func test_spells_are_off_when_the_round_says_so() -> void:
	var state: RoundState = RoundState.new()
	state.setup(Fixtures.data(), Fixtures.rng(42), 1000.0, {"spells": false})
	state.start()
	var result: Dictionary = _cast(state, ["isaz", "tiwaz"])
	check_eq(result["spells"], [] as Array[String], "no spell:")
	check_eq(state.target, 1000.0, "target unchanged:")


func _has_mul_res(result: Dictionary) -> bool:
	for event: Dictionary in result["events"]:
		if event["type"] == "bonus" and event["kind"] == "mul_res":
			return true
	return false


func test_every_pick_says_what_it_takes() -> void:
	var expected: Dictionary = {
		"hagalaz_fehu": {"source": "hand", "min": 1, "max": 1},
		"hagalaz_othala": {"source": "hand", "min": 0, "max": 2},
		"laguz_othala": {"source": "hand", "min": 0, "max": 2, "kin": true},
		"thurisaz_mannaz": {"source": "hand", "min": 2, "max": 2},
		"sowilo_othala": {"source": "bag_top", "count": 5},
		"sowilo_mannaz": {"source": "offer"},
	}
	for spell_id: String in expected:
		var state: RoundState = _round()
		var parts: PackedStringArray = spell_id.split("_")
		_cast(state, [parts[0], parts[1]])
		var limits: Dictionary = state.pick_limits(state.current_choice())
		for key: String in expected[spell_id]:
			check_eq(limits.get(key), expected[spell_id][key], "%s %s:" % [spell_id, key])
	var price: RoundState = _round()
	_cast(price, ["uruz", "naudiz", "fehu"])
	check_eq(price.pick_limits(price.current_choice())["source"], "option", "a price is two buttons:")


func test_a_skipped_pick_gives_the_drawn_stones_back() -> void:
	var state: RoundState = _round()
	_cast(state, ["sowilo", "mannaz"])
	var in_pile: int = state.bag.remaining()
	check_eq(state.offer.size(), 3, "three stones drawn:")
	state.skip_choice()
	check(state.pending.is_empty(), "no pick left")
	check(state.offer.is_empty(), "no offer left")
	check_eq(state.bag.remaining(), in_pile + 3, "they went back into the bag:")


func test_the_scroll_can_be_put_away_again() -> void:
	var state: RoundState = _round()
	_cast(state, ["uruz", "gebo", "fehu"])
	check(state.use_scroll() and state.scroll_armed(), "ready")
	state.disarm_scroll()
	check(not state.scroll_armed(), "put away")
	_cast(state, ["isaz"])
	check_eq(state.money, 0, "nothing happened with this Cast:")
	check(state.has_scroll(), "still on the Scroll")


func test_the_preview_reads_the_actions_without_rolling() -> void:
	var state: RoundState = _round()
	var before: int = state.rng.randi()
	var again: RoundState = _round()
	_put(again, ["uruz", "perthro", "fehu"])
	var preview: Dictionary = again.preview([0, 1, 2])
	check_eq(preview["plan"]["fizzled"], false, "no roll in a preview:")
	check_eq(again.rng.randi(), before, "the exam's dice were not touched:")
	_put(again, ["isaz", "raidho", "othala"])
	check_eq(again.preview([0, 1, 2])["plan"]["ignored"], ["raidho"] as Array[String], "the preview tells what does nothing:")
	_put(again, ["uruz", "naudiz", "fehu"])
	check_eq(again.preview([0, 1, 2])["plan"]["scale"], 2.5, "the price's strength:")


func _put(state: RoundState, ids: Array) -> void:
	var stones: Array[Stone] = Fixtures.stones(ids)
	stones.append_array(state.hand.slice(0, maxi(0, state.hand.size() - stones.size())))
	state.hand = stones
