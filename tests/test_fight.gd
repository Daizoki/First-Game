extends "res://tests/test_case.gd"
## A fight around the damage (docs/PROMPT_ETAPA5.md 5.4–5.5, 7): the Actions, the Targets' extra
## effects, the Lords' rules, the Talismans, Lessons and Engravings.

const Fixtures = preload("res://tests/fixtures.gd")
const FightState = preload("res://scripts/core/fight_state.gd")
const Monster = preload("res://scripts/core/monster.gd")
const Stone = preload("res://scripts/core/stone.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")


func _monster(fields: Dictionary = {}, life: float = 10000.0) -> Monster:
	var entry: Dictionary = {"id": "test", "kind": "small", "name": {"ro": "t", "en": "t"},
		"description": {"ro": "t", "en": "t"}}
	entry.merge(fields, true)
	var monster: Monster = Monster.new()
	monster.setup(entry, life)
	return monster


func _fight(hand: Array, options: Dictionary = {}, monster: Monster = null) -> FightState:
	var fight: FightState = FightState.new()
	var all: Dictionary = {"hand": hand, "money": 10}
	all.merge(options, true)
	fight.setup(Fixtures.data(), Fixtures.rng(8), monster if monster != null else _monster(), all)
	fight.start()
	return fight


func _sel(order: Array) -> Array[int]:
	var selection: Array[int] = []
	for i: Variant in order:
		selection.append(int(i))
	return selection


func _talismans(ids: Array) -> Array:
	var owned: Array = []
	for id: Variant in ids:
		owned.append(TalismanRules.make(str(id), Fixtures.data()["talismans"]))
	return owned


func test_every_spell_has_a_row_effect_that_runs() -> void:
	# Every one of the 64 spells can be cast and answered without errors.
	for id: String in Fixtures.data()["spells"]:
		var spell: Dictionary = Fixtures.data()["spells"][id]
		var fight: FightState = _fight([spell["element"], spell["target"], "fehu", "kenaz", "isaz", "tiwaz", "uruz", "ehwaz"],
			{"talismans": _talismans(["ilinca_chalk", "gronn_helmet"])},
			_monster({"kind": "boss", "rule": "tax", "rule_value": 1}))
		var result: Dictionary = fight.cast(_sel([0, 1]))
		check_eq(result["spells"], [id], "%s is read:" % id)
		fight.answer_all_automatically()
		check(fight.pending.is_empty(), "%s leaves no pick waiting" % id)


func test_eihwaz_strikes_again_at_half() -> void:
	var monster: Monster = _monster()
	var fight: FightState = _fight(["kenaz", "eihwaz", "fehu", "isaz", "fehu", "isaz", "fehu"], {}, monster)
	fight.cast(_sel([0, 1, 2]))
	var hp: float = monster.hp
	fight.cast(_sel([0, 1]))
	# Burn 3 + lasting 18 × 50% = 9 + Ice into Coins 14.
	check_eq(hp - monster.hp, 3.0 + 9.0 + 14.0, "the lasting spell strikes again:")


func test_jera_comes_after_the_next_cast_doubled() -> void:
	var monster: Monster = _monster()
	var fight: FightState = _fight(["kenaz", "jera", "tiwaz", "isaz", "fehu"], {}, monster)
	check_eq(fight.cast(_sel([0, 1, 2]))["damage"], 0.0, "nothing now:")
	var hp: float = monster.hp
	fight.cast(_sel([0, 1]))
	# Ice 14 + ripened 36 × 2 (the Burn comes with the hit, so not yet).
	check_eq(hp - monster.hp, 14.0 + 72.0, "doubled after the next Cast:")


func test_naudiz_asks_its_price() -> void:
	var fight: FightState = _fight(["kenaz", "naudiz", "fehu"])
	var result: Dictionary = fight.cast(_sel([0, 1, 2]))
	check_eq(result["damage"], 45.0, "×2.5 (18 × 2 × 50% × 2.5):")
	check_eq(str(fight.current_choice()["kind"]), "price", "the price waits:")
	var swaps: int = fight.swaps_left
	check(fight.answer({"option": "swap"}), "paid with a Swap")
	check_eq(fight.swaps_left, swaps - 1, "one Swap less:")


func test_gebo_keeps_the_spell_on_a_scroll() -> void:
	var monster: Monster = _monster()
	var fight: FightState = _fight(["kenaz", "gebo", "tiwaz", "isaz", "fehu"], {}, monster)
	check_eq(fight.cast(_sel([0, 1, 2]))["damage"], 0.0, "nothing now:")
	check_eq(fight.scroll_spell(), "kenaz_tiwaz", "on the Scroll:")
	fight.use_scroll()
	var hp: float = monster.hp
	fight.cast(_sel([0, 1]))
	check_eq(hp - monster.hp, 14.0 + 36.0 * 1.25, "the Scroll strikes with the next Cast (chained):")


func test_raidho_carries_the_overkill() -> void:
	var fight: FightState = _fight(["kenaz", "raidho", "tiwaz"], {}, _monster({}, 10.0))
	fight.cast(_sel([0, 1, 2]))
	check(fight.is_won(), "won")
	check_eq(float(fight.carry["next_round"]["overflow_damage"]), 26.0, "36 − 10 goes on:")
	var next: Monster = _monster({}, 100.0)
	var second: FightState = _fight(["isaz"], {"carry": fight.carry}, next)
	check_eq(next.hp, 74.0, "the next monster starts hurt:")
	check(second != null, "fight")


func test_berkanan_grows_with_every_cast() -> void:
	var carry: Dictionary = FightState.new_carry()
	var damages: Array = []
	for i: int in 3:
		var fight: FightState = _fight(["kenaz", "berkanan", "fehu"], {"carry": carry})
		damages.append(fight.cast(_sel([0, 1, 2]))["damage"])
	check_eq(damages, [18.0, 27.0, 36.0], "+50% for every earlier cast:")


func test_into_you_gives_a_heart_shield() -> void:
	var fight: FightState = _fight(["isaz", "mannaz"])
	fight.cast(_sel([0, 1]))
	check_eq(int(fight.carry["heart_shields"]), 1, "a Heart Shield:")


func test_upon_the_lord_stops_the_rule() -> void:
	var lord: Monster = _monster({"kind": "boss", "rule": "tax", "rule_value": 2})
	var fight: FightState = _fight(["uruz", "algiz"], {}, lord)
	fight.cast(_sel([0, 1]))
	check_eq(fight.active_rule(), "", "stopped:")
	var plain: FightState = _fight(["isaz", "algiz"])
	var money: int = plain.money
	plain.cast(_sel([0, 1]))
	check_eq(plain.money - money, 3, "no rule: a few Coins instead:")


func test_rules_of_the_lords() -> void:
	var cloanta: FightState = _fight(["kenaz", "tiwaz", "kenaz", "ehwaz", "tiwaz"], {},
		_monster({"kind": "boss", "rule": "simple_no_damage"}))
	check_eq(cloanta.cast(_sel([0, 1]))["damage"], 0.0, "a simple spell does nothing:")
	check(cloanta.cast(_sel([0, 1, 2]))["damage"] > 0.0, "with an Action it works")
	var muma: FightState = _fight(["kenaz", "tiwaz", "isaz", "tiwaz"], {},
		_monster({"kind": "boss", "rule": "no_element", "rule_element": "kenaz"}))
	check_eq(muma.preview(_sel([0, 1]))["spells"], [], "Fire is forbidden:")
	check_eq(muma.preview(_sel([2, 3]))["spells"], ["isaz_tiwaz"], "Ice is not:")
	var zmeu: FightState = _fight(["kenaz", "tiwaz", "ehwaz"], {}, _monster({"kind": "boss", "rule": "need_action"}))
	check(not zmeu.can_cast(_sel([0, 1])), "the Zmeu wants an Action")
	check(zmeu.can_cast(_sel([0, 2, 1])), "Kenaz, Ehwaz, Tiwaz")
	var heal_monster: Monster = _monster({"kind": "boss", "rule": "heal", "rule_value": 10}, 100.0)
	var heal: FightState = _fight(["kenaz", "fehu"], {}, heal_monster)
	heal.cast(_sel([0, 1]))
	check_eq(heal_monster.hp, 92.0, "100 − 18 + 10:")
	var solomonar: FightState = _fight(["kenaz", "tiwaz", "fehu", "fehu"], {"bag_only": true},
		_monster({"kind": "boss", "rule": "stone_to_hagalaz"}))
	solomonar.cast(_sel([0, 1]))
	var turned: int = 0
	for stone: Stone in solomonar.hand:
		if stone.rune_id == "hagalaz":
			turned += 1
	check_eq(turned, 1, "one stone turned into Hagalaz:")


func test_talismans_add_to_every_spell() -> void:
	var fight: FightState = _fight(["kenaz", "tiwaz"], {"talismans": _talismans(["ilinca_chalk", "gronn_helmet"])})
	# (18 + 10) × (2 + 2)
	check_eq(fight.preview(_sel([0, 1]))["damage"], 112.0, "Chalk and Helmet:")
	var umbrella: FightState = _fight(["hagalaz", "fehu"], {"talismans": _talismans(["varr_umbrella"])})
	check_eq(umbrella.preview(_sel([0, 1]))["damage"], 32.0, "Hail strikes 4 times:")
	var gloves: FightState = _fight(["kenaz", "tiwaz", "isaz", "ehwaz", "tiwaz"], {"talismans": _talismans(["kaldor_gloves"])})
	# (36 + 28 × 2 × 1.25) × 2 Resonance
	check_eq(gloves.preview(_sel([0, 1, 2, 3, 4]))["damage"], 212.0, "Gloves with 5 stones:")


func test_the_shawarma_and_the_bookmark() -> void:
	var owned: Array = _talismans(["ignar_shawarma", "morrah_bookmark"])
	var fight: FightState = _fight(["kenaz", "fehu", "isaz", "fehu"], {"talismans": owned})
	fight.cast(_sel([0, 1]))
	check_eq(float(owned[0]["value"]), 9.0, "the Shawarma wears down:")
	check_eq((owned[1]["seen"] as Array), ["kenaz_fehu"], "the Bookmark remembers:")


func test_a_lesson_and_engravings() -> void:
	var fight: FightState = _fight(["kenaz", "tiwaz", "isaz", "fehu"],
		{"consumables": [{"type": "lesson", "id": "lesson_kenaz"}, {"type": "engraving", "id": "bone"}]})
	check(fight.use_consumable(0), "the Lesson")
	check_eq(fight.element_level("kenaz"), 2, "Fire level 2:")
	check(fight.use_consumable(0), "the Bone Engraving asks for a stone")
	check(fight.answer({"stones": [0]}), "Kenaz becomes bone")
	# (27 + 10) × 3
	check_eq(fight.preview(_sel([0, 1]))["damage"], 111.0, "a bone stone adds Power:")


func test_the_binding_makes_one_stone_of_two() -> void:
	var fight: FightState = _fight(["kenaz", "ehwaz", "tiwaz"], {"consumables": [{"type": "engraving", "id": "binding"}]})
	check(fight.use_consumable(0), "the Binding")
	check(fight.answer({"stones": [0, 1]}), "Kenaz and Ehwaz bound")
	var stone: Stone = fight.hand[0]
	check_eq(stone.runes(), ["kenaz", "ehwaz"], "one stone, two runes:")
	var tiwaz: int = -1
	for i: int in fight.hand.size():
		if fight.hand[i].rune_id == "tiwaz":
			tiwaz = i
	check_eq(fight.preview(_sel([0, tiwaz]))["damage"], 72.0, "Fire runs twice from two stones:")


func test_reshaping_keeps_the_role() -> void:
	var fight: FightState = _fight(["kenaz"])
	for id: String in fight.rune_choices(fight.hand[0]):
		check_eq(str(Fixtures.data()["runes"][id]["role"]), "element", "%s is an Element:" % id)
