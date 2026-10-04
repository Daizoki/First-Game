extends "res://tests/test_case.gd"
## Lessons, Engravings, materials and bind-runes (DESIGN 3.7).

const Fixtures = preload("res://tests/fixtures.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const Stone = preload("res://scripts/core/stone.gd")


func _round(consumables: Array = [], seed_value: int = 42) -> RoundState:
	var state: RoundState = RoundState.new()
	state.setup(Fixtures.data(), Fixtures.rng(seed_value), 1.0e9, {"consumables": consumables, "money": 0})
	state.start()
	return state


func _put(state: RoundState, ids: Array) -> Array[Stone]:
	var stones: Array[Stone] = Fixtures.stones(ids)
	var all: Array[Stone] = stones.duplicate()
	all.append_array(state.hand.slice(0, maxi(0, state.hand.size() - stones.size())))
	state.hand = all
	return stones


func _cast(state: RoundState, count: int) -> Dictionary:
	var order: Array[int] = []
	for i: int in count:
		order.append(i)
	return state.cast(order)


func test_ten_lessons_and_ten_engravings() -> void:
	check_eq(Fixtures.data()["lessons"].size(), 10, "lessons:")
	check_eq(Fixtures.data()["engravings"].size(), 10, "engravings:")
	for id: String in Fixtures.data()["lessons"]:
		check(Fixtures.data()["words"].has(Fixtures.data()["lessons"][id]["word"]), "%s teaches a real Word" % id)


func test_a_lesson_raises_its_word() -> void:
	var state: RoundState = _round([{"type": "lesson", "id": "lesson_pair"}])
	check(state.use_consumable(0), "used")
	check_eq(state.word_level("pair"), 2, "the Pair at level 2:")
	check_eq(state.lessons_used, 1, "counted:")
	check(state.consumables.is_empty(), "gone")


func test_materials_score() -> void:
	var plain: RoundState = _round()
	_put(plain, ["wunjo"])
	var base: Dictionary = _cast(plain, 1)
	for material: String in ["bone", "amber"]:
		var state: RoundState = _round()
		_put(state, ["wunjo"])[0].material = material
		var result: Dictionary = _cast(state, 1)
		if material == "bone":
			check_eq(float(result["power"]), float(base["power"]) + 20.0, "Bone: +20 Power:")
		else:
			check_eq(float(result["res"]), float(base["res"]) + 4.0, "Amber: +4 Resonance:")


func test_glass_doubles_and_sometimes_breaks() -> void:
	var broke: int = 0
	for seed_value: int in range(1, 41):
		var state: RoundState = _round([], seed_value)
		var glass: Stone = _put(state, ["wunjo"])[0]
		glass.material = "glass"
		state.bag.stones.append(glass)
		var result: Dictionary = _cast(state, 1)
		check(float(result["res"]) >= 2.0, "×2 Resonance")
		if not state.bag.stones.has(glass):
			broke += 1
	check(broke > 0 and broke < 40, "it breaks sometimes (%d of 40)" % broke)


func test_iron_in_hand_and_gold_at_the_end() -> void:
	var state: RoundState = _round()
	var stones: Array[Stone] = _put(state, ["wunjo", "isaz"])
	stones[1].material = "iron"
	var plain: RoundState = _round()
	_put(plain, ["wunjo", "isaz"])
	check_eq(float(_cast(state, 1)["res"]), float(_cast(plain, 1)["res"]) * 1.5, "Iron held: ×1.5:")
	var golden: RoundState = _round()
	_put(golden, ["wunjo"])[0].material = "gold"
	golden.finish()
	check_eq(golden.money, 3, "Gold in hand at the end: +3 Coins:")


func test_engravings_work_on_stones_in_hand() -> void:
	var state: RoundState = _round([{"type": "engraving", "id": "bone"}])
	_put(state, ["wunjo"])
	check(state.use_consumable(0), "used")
	check_eq(state.current_choice()["kind"], "engrave_material", "pick a stone:")
	check(state.answer({"stones": [0]}), "picked")
	check_eq(state.hand[0].material, "bone", "now bone:")
	var copies: RoundState = _round([{"type": "engraving", "id": "double"}])
	var size: int = copies.bag.size()
	copies.use_consumable(0)
	copies.answer({"stones": [0]})
	check_eq(copies.bag.size(), size + 1, "the Double: one more stone in the bag:")
	var reshaped: RoundState = _round([{"type": "engraving", "id": "reshaping"}])
	_put(reshaped, ["fehu"])
	reshaped.use_consumable(0)
	check(not reshaped.answer({"stones": [0], "rune": "isaz"}), "only a rune of the same Kin")
	check(reshaped.answer({"stones": [0], "rune": "wunjo"}), "Fehu becomes Wunjo")
	check_eq(reshaped.hand[0].position, 8, "with Wunjo's Position:")


func test_a_bind_rune_counts_as_either_rune() -> void:
	var state: RoundState = _round([{"type": "engraving", "id": "binding"}])
	_put(state, ["fehu", "isaz"])
	var size: int = state.bag.size()
	state.use_consumable(0)
	check(state.answer({"stones": [0, 1]}), "bound")
	var bound: Stone = state.hand[0]
	check_eq(bound.bound_rune, "isaz", "Fehu and Isaz on one stone:")
	check(state.bag.size() <= size, "the second stone left the bag")
	var pair_with_three: Array[Stone] = [bound]
	pair_with_three.append_array(Fixtures.stones(["thurisaz"]))
	check_eq(WordDetector.detect(pair_with_three, Fixtures.data()["words"])["word"], "pair",
		"read as Isaz (Position 3), it pairs with Thurisaz:")
	var pair_with_one: Array[Stone] = [bound]
	pair_with_one.append_array(Fixtures.stones(["hagalaz"]))
	check_eq(WordDetector.detect(pair_with_one, Fixtures.data()["words"])["word"], "pair",
		"read as Fehu (Position 1), it pairs with Hagalaz:")


func test_both_voices_of_a_bind_rune_are_heard() -> void:
	var state: RoundState = _round()
	var stone: Stone = _put(state, ["fehu"])[0]
	stone.bound_rune = "thurisaz"
	stone.bound_kin = "fehu"
	stone.bound_position = 3
	var result: Dictionary = _cast(state, 1)
	check_eq(int(result["money"]), 1, "Fehu's Coin:")
	check(float(result["res"]) >= 5.0, "and Thurisaz's +4 Resonance")


func test_exam_slots_and_lessons_in_the_market() -> void:
	var exam: ExamState = ExamState.new()
	exam.setup(Fixtures.data(), 3)
	check(exam.add_consumable("lesson", "lesson_row"), "a Lesson")
	check(exam.add_consumable("engraving", "glass"), "an Engraving")
	check(not exam.add_consumable("lesson", "lesson_pair"), "two slots")
	check(exam.use_lesson(0), "a Lesson works outside a round")
	check_eq(int(exam.word_levels["row"]), 2, "the Row goes up:")
	check(not exam.use_lesson(0), "an Engraving needs a hand")
