extends "res://tests/test_case.gd"
## The divine parents (DESIGN 3.10). The saved Journey is tested in test_journey.gd.

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const FightState = preload("res://scripts/core/fight_state.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _exam(parent: String = "", seed_value: int = 11) -> ExamState:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), seed_value, parent)
	return exam


func _win(exam: ExamState) -> Dictionary:
	var state: FightState = exam.new_round()
	while not state.monster.is_dead():
		state.monster.take_hit(state.monster.max_hp * 2.0, true)
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
	var state: FightState = exam.new_round()
	check_eq(state.casts_left, 4, "Casts:")
	check_eq(state.swaps_left, 3, "Swaps:")
	check_eq(exam.bag.size(), 48, "Bag:")


func test_varr_and_selvia_add_casts_and_swaps() -> void:
	var varr: FightState = _exam("varr").new_round()
	check_eq(varr.casts_left, 5, "Varr's child Casts:")
	check_eq(varr.swaps_left, 3, "Varr's child Swaps:")
	var selvia: FightState = _exam("selvia").new_round()
	check_eq(selvia.casts_left, 4, "Selvia's child Casts:")
	check_eq(selvia.swaps_left, 4, "Selvia's child Swaps:")


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


func test_new_stones_after_loading_get_new_uids() -> void:
	var exam: ExamState = _exam()
	var copy: ExamState = ExamState.new()
	copy.load_dict(Fixtures.data(), JSON.parse_string(JSON.stringify(exam.to_dict())))
	var stone: Stone = copy.bag.make_stone(Fixtures.data()["runes"]["fehu"])
	for old: Stone in copy.bag.stones:
		check(old.uid != stone.uid, "uid %d is new" % stone.uid)


func test_a_save_from_another_version_is_refused() -> void:
	var saved: Dictionary = _exam().to_dict()
	var text: String = JSON.stringify(saved).replace("\"s:version\",\"i:2\"", "\"s:version\",\"i:999\"")
	var copy: ExamState = ExamState.new()
	check(not copy.load_dict(Fixtures.data(), JSON.parse_string(text)), "an unknown version is refused")
	check(not copy.load_dict(Fixtures.data(), {}), "an empty save is refused")
