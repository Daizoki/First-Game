extends "res://tests/test_case.gd"
## Aeva's loop (DESIGN 3.11): Memories at the end of an exam, buying parents and Talismans,
## the records and the Collection.

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const FightState = preload("res://scripts/core/fight_state.gd")
const Monster = preload("res://scripts/core/monster.gd")
const ShopLogic = preload("res://scripts/core/shop_logic.gd")
const Progress = preload("res://scripts/core/progress.gd")
const SaveManagerScript = preload("res://scripts/autoload/save_manager.gd")


func _save() -> Dictionary:
	return SaveManagerScript.default_data()


func _exam(seed_value: int = 5) -> ExamState:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), seed_value)
	return exam


func _win(exam: ExamState) -> Dictionary:
	var state: FightState = exam.new_round()
	while not state.monster.is_dead():
		state.monster.take_hit(state.monster.max_hp * 2.0, true)
	state.finish()
	return exam.finish_round(state)


func _parent(id: String) -> Dictionary:
	return Fixtures.data()["parents"][id]


func test_memories_for_rounds_examiners_and_passing() -> void:
	var rules: Dictionary = Fixtures.data()["rules"]
	var exam: ExamState = _exam()
	for i: int in 4:
		_win(exam)
	# 4 fights won, 1 Lord beaten.
	var earned: Dictionary = Progress.exam_memories(exam, rules)
	check_eq(earned["rounds"], 4 * int(rules["memories_per_round"]), "rounds:")
	check_eq(earned["examiners"], int(rules["memories_per_examiner"]), "examiners:")
	check_eq(earned["passed"], 0, "not passed:")
	var save: Dictionary = _save()
	Progress.finish_exam(save, exam, rules)
	check_eq(Progress.memories(save), int(earned["total"]), "Memories saved:")
	check_eq(save["stats"]["exams_finished"], 1, "exams finished:")
	check_eq(save["stats"]["best_trial"], 2, "best trial:")


func test_a_passed_exam_pays_the_bonus() -> void:
	var rules: Dictionary = Fixtures.data()["rules"]
	var exam: ExamState = _exam()
	while not exam.is_over():
		_win(exam)
	check(exam.passed, "the exam is passed")
	var save: Dictionary = _save()
	var earned: Dictionary = Progress.finish_exam(save, exam, rules)
	check_eq(earned["passed"], int(rules["memories_exam_passed"]), "bonus:")
	check_eq(earned["examiners"], 8 * int(rules["memories_per_examiner"]), "examiners:")
	check_eq(save["stats"]["exams_passed"], 1, "exams passed:")
	check_eq(save["stats"]["best_trial"], 8, "best trial:")


func test_parents_open_up() -> void:
	var save: Dictionary = _save()
	check(Progress.parent_available(save, _parent("varr")), "Varr from the start")
	check(not Progress.parent_available(save, _parent("selvia")), "Selvia waits")
	save["stats"]["exams_finished"] = 1
	check(Progress.parent_available(save, _parent("selvia")), "Selvia after the first exam")
	check(not Progress.parent_available(save, _parent("ignar")), "Ignar costs Memories")
	check(not Progress.buy_parent(save, _parent("ignar")), "not enough Memories")
	save["memories"] = int(_parent("ignar")["cost"]) + 5
	check(Progress.can_buy_parent(save, _parent("ignar")), "affordable")
	check(Progress.buy_parent(save, _parent("ignar")), "bought")
	check_eq(Progress.memories(save), 5, "Memories spent:")
	check(Progress.parent_available(save, _parent("ignar")), "Ignar now")
	check(not Progress.buy_parent(save, _parent("ignar")), "not twice")
	check(not Progress.can_buy_parent(save, _parent("varr")), "Varr is not for sale")


func test_talismans_for_the_market_open_up() -> void:
	var talismans: Dictionary = Fixtures.data()["talismans"]
	var save: Dictionary = _save()
	var start: Array[String] = Progress.unlocked_talismans(save, talismans)
	check(start.has("ilinca_chalk"), "a common one from the start")
	check(not start.has("aeva_hourglass"), "the Hourglass is locked")
	check(not Progress.buy_talisman(save, talismans, "nix"), "no Memories yet")
	save["memories"] = 100
	check(Progress.buy_talisman(save, talismans, "nix"), "bought")
	check_eq(Progress.memories(save), 100 - int(talismans["nix"]["unlock"]), "Memories spent:")
	check(Progress.talisman_unlocked(save, talismans, "nix"), "Nix unlocked")
	check(not Progress.buy_talisman(save, talismans, "ilinca_chalk"), "free ones are not sold")


func test_the_market_offers_only_unlocked_talismans() -> void:
	var data: Dictionary = Fixtures.data()
	var allowed: Array[String] = ["ilinca_chalk", "gronn_helmet"]
	for seed_value: int in range(1, 30):
		var exam: ExamState = _exam(seed_value)
		exam.unlocked_talismans = allowed
		var shop: ShopLogic = ShopLogic.new()
		shop.setup(exam, data)
		for item: Dictionary in shop.offer:
			if str(item["type"]) == "talisman":
				check(allowed.has(str(item["id"])), "%s is locked" % item["id"])
		var pack: Dictionary = shop.open_pack("talismans_big")
		for item: Dictionary in pack["items"]:
			check(allowed.has(str(item["id"])), "%s in a Bag is locked" % item["id"])


func test_records_and_the_collection() -> void:
	var save: Dictionary = _save()
	Progress.record_round(save, 1200.0, {"kenaz": 3})
	Progress.record_round(save, 800.0, {"kenaz": 2, "isaz": 4})
	check_eq(save["stats"]["best_cast_score"], 1200.0, "best Cast:")
	check_eq(Progress.best_element_level(save, "kenaz"), 3, "Fire:")
	check_eq(Progress.best_element_level(save, "isaz"), 4, "Ice:")
	check_eq(Progress.best_element_level(save, "uruz"), 1, "never raised:")
	check(Progress.record_seen(save, "monsters", "strigoi"), "new")
	check(not Progress.record_seen(save, "monsters", "strigoi"), "only once")
	check(Progress.has_seen(save, "monsters", "strigoi"), "seen")
	check(not Progress.has_seen(save, "talismans", "nix"), "not seen")


func test_a_fight_keeps_its_best_cast() -> void:
	var monster: Monster = Monster.new()
	monster.setup(Fixtures.data()["monsters"]["dummy"], 1.0e9)
	var state: FightState = FightState.new()
	state.setup(Fixtures.data(), Fixtures.rng(3), monster, {"hand": ["kenaz", "tiwaz", "kenaz", "ehwaz", "tiwaz"]})
	state.start()
	var first: float = float(state.cast([0, 1])["damage"])
	var second: float = float(state.cast([0, 1, 2])["damage"])
	check_eq(state.best_cast_damage, maxf(first, second), "best Cast of the fight:")
