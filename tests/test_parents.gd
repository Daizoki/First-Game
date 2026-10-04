extends "res://tests/test_case.gd"
## The divine parents (DESIGN 3.10) and the exam in progress saved between rounds (3.11).

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _exam(parent: String = "", seed_value: int = 11) -> ExamState:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), seed_value, parent)
	return exam


func _win(exam: ExamState) -> Dictionary:
	var state: RoundState = exam.new_round()
	state.score = state.target
	state.finish()
	return exam.finish_round(state)


func _rune_ids(stones: Array) -> Array[String]:
	var ids: Array[String] = []
	for stone: Stone in stones:
		ids.append(stone.rune_id)
	return ids


func test_five_parents_with_varr_from_the_start() -> void:
	var parents: Dictionary = Fixtures.data()["parents"]
	check_eq(parents.keys(), ["varr", "selvia", "ignar", "gronn", "morrah"], "parents:")
	check_eq(str(parents["varr"]["unlock"]), "start", "Varr is there from the start:")
	check_eq(str(parents["selvia"]["unlock"]), "attempts", "Selvia comes after the first exam:")


func test_no_parent_keeps_the_standard_exam() -> void:
	var exam: ExamState = _exam()
	var state: RoundState = exam.new_round()
	check_eq(state.casts_left, 4, "Casts:")
	check_eq(state.swaps_left, 3, "Swaps:")
	check_eq(exam.bag.size(), 48, "Bag:")


func test_varr_and_selvia_add_casts_and_swaps() -> void:
	var varr: RoundState = _exam("varr").new_round()
	check_eq(varr.casts_left, 5, "Varr's child Casts:")
	check_eq(varr.swaps_left, 3, "Varr's child Swaps:")
	var selvia: RoundState = _exam("selvia").new_round()
	check_eq(selvia.casts_left, 4, "Selvia's child Casts:")
	check_eq(selvia.swaps_left, 4, "Selvia's child Swaps:")


func test_aeva_keeps_her_one_cast_even_for_varrs_child() -> void:
	var exam: ExamState = _exam("varr")
	exam.trial_index = 7
	exam.round_index = 2
	check_eq(exam.new_round().casts_left, 1, "Aeva's single Cast:")


func test_ignar_gives_two_engravings() -> void:
	var exam: ExamState = _exam("ignar")
	check_eq(exam.consumables.size(), 2, "Engravings at the start:")
	for item: Dictionary in exam.consumables:
		check_eq(str(item["type"]), "engraving", "kind:")
	check(str(exam.consumables[0]["id"]) != str(exam.consumables[1]["id"]), "two different Engravings")


func test_gronn_gives_a_slot_and_takes_a_stone() -> void:
	var exam: ExamState = _exam("gronn")
	check_eq(exam.talisman_slots(), 6, "Talisman slots:")
	check_eq(exam.new_round().hand.size(), 7, "stones in hand:")


func test_morrah_has_one_stone_of_each_rune() -> void:
	var exam: ExamState = _exam("morrah")
	check_eq(exam.bag.size(), 24, "Bag:")
	var seen: Dictionary = {}
	for stone: Stone in exam.bag.stones:
		check(not seen.has(stone.rune_id), "%s twice" % stone.rune_id)
		seen[stone.rune_id] = true


func test_a_saved_exam_goes_on_exactly() -> void:
	var exam: ExamState = _exam("ignar", 99)
	_win(exam)
	_win(exam)
	exam.money = 17
	exam.add_talisman("ignar_shawarma")
	exam.add_talisman("morrah_bookmark")
	(exam.talismans[1]["seen"] as Array).append("pair")
	exam.word_levels["pair"] = 3
	exam.bag.stones[0].material = "gold"
	exam.bag.stones[1].bound_rune = "kenaz"
	exam.bag.stones[1].bound_kin = "fehu"
	exam.bag.stones[1].bound_position = 6
	exam.bag.stones[2].bonus_power = 7
	exam.carry["spell_counts"]["isaz_tiwaz"] = 2
	exam.unlocked_talismans.assign(["ilinca_chalk", "ignar_shawarma"])
	# Through text, as in save.json.
	var text: String = JSON.stringify(exam.to_dict())
	var copy: ExamState = ExamState.new()
	check(copy.load_dict(Fixtures.data(), JSON.parse_string(text)), "the save loads")
	check_eq(copy.parent_id, "ignar", "parent:")
	check_eq(copy.money, 17, "Coins:")
	check_eq(copy.trial_index, exam.trial_index, "trial:")
	check_eq(copy.round_index, 2, "round:")
	check_eq(copy.examiners, exam.examiners, "examiners:")
	check_eq(copy.rounds_won, 2, "rounds won:")
	check_eq(copy.word_levels, {"pair": 3}, "Word levels:")
	check_eq(copy.talismans, exam.talismans, "Talismans:")
	check_eq(copy.consumables, exam.consumables, "consumables:")
	check_eq(copy.unlocked_talismans, exam.unlocked_talismans, "unlocks:")
	check_eq(copy.carry["spell_counts"], {"isaz_tiwaz": 2}, "spell counts:")
	check_eq(copy.bag.size(), exam.bag.size(), "Bag size:")
	for i: int in exam.bag.size():
		check_eq(copy.bag.stones[i].to_dict(), exam.bag.stones[i].to_dict(), "stone %d:" % i)
	# The same RNG state: the next round draws the same hand.
	check_eq(_rune_ids(copy.new_round().hand), _rune_ids(exam.new_round().hand), "next hand:")


func test_a_save_from_another_version_is_refused() -> void:
	var saved: Dictionary = _exam().to_dict()
	var text: String = JSON.stringify(saved).replace("\"s:version\",\"i:1\"", "\"s:version\",\"i:999\"")
	var copy: ExamState = ExamState.new()
	check(not copy.load_dict(Fixtures.data(), JSON.parse_string(text)), "an unknown version is refused")
	check(not copy.load_dict(Fixtures.data(), {}), "an empty save is refused")


func test_new_stones_after_loading_get_new_uids() -> void:
	var exam: ExamState = _exam()
	var copy: ExamState = ExamState.new()
	copy.load_dict(Fixtures.data(), JSON.parse_string(JSON.stringify(exam.to_dict())))
	var stone: Stone = copy.bag.make_stone(Fixtures.data()["runes"]["fehu"])
	for old: Stone in copy.bag.stones:
		check(old.uid != stone.uid, "uid %d is new" % stone.uid)
