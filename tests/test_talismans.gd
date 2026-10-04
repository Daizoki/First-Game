extends "res://tests/test_case.gd"
## The Talismans (DESIGN 3.6): their effects on a Cast and a round, Nix's copy, the examiner
## Nix's trick, the ones that change (Shawarma, Bookmark, Dara), Aeva's Hourglass, buying and
## selling, and the spells into the Talismans.

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _owned(ids: Array) -> Array:
	var list: Array = []
	for id: Variant in ids:
		list.append(TalismanRules.make(str(id), Fixtures.data()["talismans"]))
	return list


func _round(ids: Array, examiner_id: String = "") -> RoundState:
	var state: RoundState = RoundState.new()
	var options: Dictionary = {"talismans": _owned(ids), "money": 0}
	if not examiner_id.is_empty():
		options["rule"] = Fixtures.data()["examiners"][examiner_id]
	state.setup(Fixtures.data(), Fixtures.rng(42), 1.0e9, options)
	state.start()
	return state


func _cast(state: RoundState, ids: Array) -> Dictionary:
	var stones: Array[Stone] = Fixtures.stones(ids)
	stones.append_array(state.hand.slice(0, maxi(0, state.hand.size() - stones.size())))
	state.hand = stones
	var order: Array[int] = []
	for i: int in ids.size():
		order.append(i)
	return state.cast(order)


func _score(talisman_ids: Array, rune_ids: Array, examiner_id: String = "") -> Dictionary:
	return _cast(_round(talisman_ids, examiner_id), rune_ids)


func test_fifteen_talismans_in_the_data() -> void:
	var table: Dictionary = Fixtures.data()["talismans"]
	check_eq(table.size(), 15, "talismans:")
	for id: String in table:
		check(not str(table[id]["description"]["ro"]).is_empty(), "%s has a text" % id)


func test_flat_bonuses() -> void:
	var plain: Dictionary = _score([], ["fehu", "hagalaz"])
	var chalk: Dictionary = _score(["ilinca_chalk"], ["fehu", "hagalaz"])
	check_eq(float(chalk["res"]), float(plain["res"]) + 4.0, "the Chalk: +4 Resonance:")
	var helmet: Dictionary = _score(["gronn_helmet"], ["fehu", "hagalaz"])
	check_eq(float(helmet["power"]), float(plain["power"]) + 40.0, "the Hard Hat: +40 Power:")


func test_the_umbrella_likes_hagalaz_stones() -> void:
	var plain: Dictionary = _score([], ["fehu", "hagalaz"])
	var umbrella: Dictionary = _score(["varr_umbrella"], ["fehu", "hagalaz"])
	# Hagalaz's Voice makes it score twice, so the Umbrella pays twice.
	check_eq(float(umbrella["res"]), float(plain["res"]) + 6.0, "Hagalaz scores twice: +3 each time:")
	var fehu: Dictionary = _score(["varr_umbrella"], ["fehu", "uruz"])
	check_eq(float(fehu["res"]), float(_score([], ["fehu", "uruz"])["res"]), "nothing for other Kins:")


func test_shell_and_coffee_change_the_round() -> void:
	var base: RoundState = _round([])
	var both: RoundState = _round(["selvia_shell", "lunet_coffee"])
	check_eq(both.swaps_left, base.swaps_left + 1, "the Shell: +1 Swap:")
	check_eq(both.hand.size(), 9, "the Coffee: 9 stones:")


func test_the_shawarma_wears_down() -> void:
	var state: RoundState = _round(["ignar_shawarma"])
	var first: Dictionary = _cast(state, ["fehu", "hagalaz"])
	check_eq(float(state.talismans[0]["value"]), 19.0, "one bite:")
	state.talismans[0]["value"] = 1.0
	var last: Dictionary = _cast(state, ["fehu", "hagalaz"])
	check(state.talismans.is_empty(), "eaten")
	check_eq(last["talismans_gone"], ["ignar_shawarma"] as Array[String], "the round says so:")
	check(float(first["res"]) > float(last["res"]), "it gave less and less")


func test_ticket_gloves_lighter() -> void:
	var row: Dictionary = _score(["trolley_ticket"], ["fehu", "naudiz", "thurisaz", "ansuz", "raidho"])
	check_eq(int(row["money"]), 1 + 1, "a Row: +1 Coin (and Fehu's Voice):")
	var five: Dictionary = _score(["kaldor_gloves"], ["fehu", "uruz", "thurisaz", "ansuz", "raidho"])
	var plain: Dictionary = _score([], ["fehu", "uruz", "thurisaz", "ansuz", "raidho"])
	check_eq(float(five["res"]), float(plain["res"]) * 2.0, "the Gloves: ×2 with five scoring stones:")
	var lit: Dictionary = _score(["ignar_lighter"], ["wunjo"])
	check(float(lit["power"]) > float(_score([], ["wunjo"])["power"]), "the Lighter: the first stone scores twice")


func test_the_bookmark_remembers_new_words() -> void:
	var state: RoundState = _round(["morrah_bookmark"])
	_cast(state, ["fehu", "hagalaz"])
	_cast(state, ["wunjo"])
	var third: Dictionary = _cast(state, ["uruz", "naudiz"])
	check_eq(TalismanRules.current_value(state.talismans[0], Fixtures.data()["talismans"]), 2.0, "two Words seen:")
	check(float(third["res"]) > 2.0, "they add Resonance")


func test_toma_counts_the_bag() -> void:
	var state: RoundState = _round(["toma"])
	var left: int = state.bag.remaining()
	var result: Dictionary = _cast(state, ["wunjo"])
	var plain: Dictionary = _score([], ["wunjo"])
	check_eq(float(result["power"]), float(plain["power"]) + float(left), "+1 Power per stone in the bag:")


func test_nix_copies_the_talisman_on_its_right() -> void:
	var plain: Dictionary = _score([], ["fehu", "hagalaz"])
	var copied: Dictionary = _score(["nix", "ilinca_chalk"], ["fehu", "hagalaz"])
	check_eq(float(copied["res"]), float(plain["res"]) + 8.0, "two Chalks:")
	var alone: Dictionary = _score(["ilinca_chalk", "nix"], ["fehu", "hagalaz"])
	check_eq(float(alone["res"]), float(plain["res"]) + 4.0, "nothing on its right:")


func test_the_examiner_nix_switches_the_leftmost_off() -> void:
	var plain: Dictionary = _score([], ["fehu", "uruz", "naudiz", "isaz"], "nix")
	var tricked: Dictionary = _score(["gronn_helmet", "ilinca_chalk"], ["fehu", "uruz", "naudiz", "isaz"], "nix")
	check_eq(float(tricked["power"]), float(plain["power"]), "the Hard Hat is off:")
	check_eq(float(tricked["res"]), float(plain["res"]) + 4.0, "the Chalk still works:")


func test_dara_grows_and_the_hourglass_saves_once() -> void:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), 5)
	check(exam.add_talisman("dara") and exam.add_talisman("aeva_hourglass"), "bought")
	for i: int in 3:
		var state: RoundState = exam.new_round()
		state.score = state.target
		state.finish()
		exam.finish_round(state)
	check_eq(float(exam.talismans[0]["value"]), 1.75, "Dara after one examiner:")
	var lost: RoundState = exam.new_round()
	lost.casts_left = 0
	lost.finish()
	var summary: Dictionary = exam.finish_round(lost)
	check(summary.get("second_chance", false), "the Hourglass breaks")
	check(not exam.is_over(), "and the exam goes on")
	check_eq(exam.round_kind(), "small", "the same round again:")
	check_eq(exam.talismans.size(), 1, "the Hourglass is gone:")


func test_slots_buying_and_selling() -> void:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), 5)
	for id: String in ["ilinca_chalk", "gronn_helmet", "toma", "nix", "dara"]:
		check(exam.add_talisman(id), "%s fits" % id)
	check(not exam.add_talisman("varr_umbrella"), "five slots")
	var money: int = exam.money
	check_eq(exam.sell_talisman(2), exam.sell_price("toma"), "Toma sold:")
	check_eq(exam.money, money + exam.sell_price("toma"), "for half the price:")
	exam.move_talisman(0, 3)
	check_eq(str(exam.talismans[3]["id"]), "ilinca_chalk", "dragged to the right:")


func test_spells_into_the_talismans() -> void:
	var sold: RoundState = _round(["dara"])
	_cast(sold, ["hagalaz", "wunjo"])
	check_eq(sold.current_choice().get("kind"), "sell_talisman_full", "pick one to sell:")
	sold.answer({"talisman": 0})
	check_eq(sold.money, sold.talisman_price("dara"), "full price:")
	var power: RoundState = _round(["ilinca_chalk", "toma"])
	var boosted: Dictionary = _cast(power, ["uruz", "wunjo"])
	check(float(boosted["power"]) >= 20.0, "Strength into the Talismans: +10 Power each")
	var thorn: RoundState = _round(["ilinca_chalk"])
	_cast(thorn, ["thurisaz", "wunjo"])
	thorn.answer({"talisman": 0})
	check(thorn.talismans.is_empty(), "destroyed")
	check_eq(float(thorn.carry["trial_res_mult"]), 1.5, "×1.5 for the rest of the trial:")
	var ice: RoundState = _round(["ignar_shawarma"])
	_cast(ice, ["isaz", "wunjo"])
	check_eq(float(ice.talismans[0]["value"]), 20.0, "Ice: the Shawarma did not wear down:")
