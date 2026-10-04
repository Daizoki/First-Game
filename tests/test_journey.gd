extends "res://tests/test_case.gd"
## The Journey through the 8 Realms (docs/PROMPT_ETAPA5.md 3, 9): every Realm has a small and a
## big monster and its Lord; the monsters' life grows Realm by Realm.

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const FightState = preload("res://scripts/core/fight_state.gd")


func _exam(seed_value: int = 11) -> ExamState:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), seed_value)
	return exam


func _win(exam: ExamState) -> Dictionary:
	var fight: FightState = exam.new_round()
	fight.monster.take_hit(fight.monster.total_hp() * 2.0, true)
	while not fight.monster.is_dead():
		fight.monster.take_hit(fight.monster.max_hp * 2.0, true)
	fight.finish()
	return exam.finish_round(fight)


func test_eight_realms_with_their_lords() -> void:
	var exam: ExamState = _exam()
	check_eq(exam.trial_count(), 8, "realms:")
	check_eq(exam.lineup.size(), 8, "a lineup per realm:")
	var monsters: Dictionary = Fixtures.data()["monsters"]
	for n: int in 8:
		var fights: Dictionary = exam.lineup[n]
		check_eq(str(monsters[fights["small"]]["kind"]), "small", "realm %d small:" % (n + 1))
		check_eq(str(monsters[fights["big"]]["kind"]), "big", "realm %d big:" % (n + 1))
		check_eq(str(fights["boss"]), str(Fixtures.data()["realms"].values()[n]["boss"]), "realm %d Lord:" % (n + 1))
	check_eq(str(exam.lineup[7]["boss"]), "balaur", "the Balaur waits at the Gate:")


func test_life_grows_from_small_to_boss_and_realm_to_realm() -> void:
	var exam: ExamState = _exam()
	var first_small: float = exam.monster_hp()
	_win(exam)
	var first_big: float = exam.monster_hp()
	_win(exam)
	var first_boss: float = exam.monster_hp()
	check(first_small < first_big and first_big < first_boss, "small < big < Lord (%s, %s, %s)" % [first_small, first_big, first_boss])
	_win(exam)
	check_eq(exam.trial_index, 1, "the second Realm:")
	check(exam.monster_hp() > first_small, "the second Realm is tougher")


func test_a_won_fight_pays_and_a_lost_one_ends_the_journey() -> void:
	var exam: ExamState = _exam()
	var money: int = exam.money
	var summary: Dictionary = _win(exam)
	check(bool(summary["won"]), "won")
	check(exam.money > money, "Coins for the fight")
	var fight: FightState = exam.new_round()
	fight.casts_left = 0
	fight.finish()
	var lost: Dictionary = exam.finish_round(fight)
	check(bool(lost["exam_over"]), "the Journey ends (hearts come in step D)")


func test_beating_every_lord_passes() -> void:
	var exam: ExamState = _exam()
	while not exam.is_over():
		_win(exam)
	check(exam.passed, "passed")
	check_eq(exam.defeated.size(), 8, "eight Lords:")


func test_a_saved_journey_goes_on_exactly() -> void:
	var exam: ExamState = _exam(99)
	_win(exam)
	exam.element_levels["kenaz"] = 3
	exam.bag.stones[0].material = "gold"
	exam.bag.stones[1].bound_rune = "ehwaz"
	exam.bag.stones[2].bonus_power = 7
	var copy: ExamState = ExamState.new()
	check(copy.load_dict(Fixtures.data(), JSON.parse_string(JSON.stringify(exam.to_dict()))), "the save loads")
	check_eq(copy.lineup, exam.lineup, "lineup:")
	check_eq(copy.element_levels, {"kenaz": 3}, "Element levels:")
	check_eq(copy.round_index, 1, "fight:")
	for i: int in exam.bag.size():
		check_eq(copy.bag.stones[i].to_dict(), exam.bag.stones[i].to_dict(), "stone %d:" % i)
	var a: Array = exam.new_round().hand.map(func(s: RefCounted) -> String: return s.get("rune_id"))
	var b: Array = copy.new_round().hand.map(func(s: RefCounted) -> String: return s.get("rune_id"))
	check_eq(b, a, "the same next hand:")
