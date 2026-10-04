extends "res://tests/test_case.gd"
## Magic does the damage (docs/PROMPT_ETAPA5.md 5): the formula, weaknesses, resistances and
## immunities, the natures of the Elements, the Targets' shares, two spells in one Cast, the kin
## bonus, the Shield, the Burn, the Future, the Balaur's heads and the safety limits.

const Fixtures = preload("res://tests/fixtures.gd")
const FightState = preload("res://scripts/core/fight_state.gd")
const Monster = preload("res://scripts/core/monster.gd")
const Stone = preload("res://scripts/core/stone.gd")


## A monster built from this entry (merged over a plain one) with this much life.
func _monster(fields: Dictionary = {}, life: float = 10000.0) -> Monster:
	var entry: Dictionary = {"id": "test", "kind": "small", "name": {"ro": "t", "en": "t"},
		"description": {"ro": "t", "en": "t"}}
	entry.merge(fields, true)
	var monster: Monster = Monster.new()
	monster.setup(entry, life)
	return monster


## A fight whose hand starts with these runes (in this order).
func _fight(monster: Monster, hand: Array, options: Dictionary = {}) -> FightState:
	var fight: FightState = FightState.new()
	var all: Dictionary = {"hand": hand}
	all.merge(options, true)
	fight.setup(Fixtures.data(), Fixtures.rng(5), monster, all)
	fight.start()
	return fight


## Casts the first stones of the hand, in this order of hand indices.
func _cast(fight: FightState, order: Array) -> Dictionary:
	var selection: Array[int] = []
	for i: Variant in order:
		selection.append(int(i))
	return fight.cast(selection)


func test_fire_into_the_enemy() -> void:
	var monster: Monster = _monster()
	var fight: FightState = _fight(monster, ["kenaz", "tiwaz"])
	var preview: Dictionary = fight.preview([0, 1])
	check_eq(preview["spells"], ["kenaz_tiwaz"], "the spell:")
	check_eq(preview["damage"], 36.0, "18 × 2:")
	var result: Dictionary = _cast(fight, [0, 1])
	check_eq(result["damage"], 36.0, "dealt:")
	check_eq(monster.burn_stacks, 1, "a Burn stack:")
	check_eq(monster.burn_per_stack, 6.0, "Burn doubled into the Enemy:")


func test_the_wrong_order_does_nothing() -> void:
	var fight: FightState = _fight(_monster(), ["tiwaz", "kenaz"])
	var preview: Dictionary = fight.preview([0, 1])
	check_eq(preview["spells"], [], "no spell:")
	check_eq(str(preview["sentence"]["status"]), "wrong_order", "why:")
	check_eq(_cast(fight, [0, 1])["damage"], 0.0, "no damage:")


func test_ehwaz_strikes_twice() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "ehwaz", "tiwaz"])
	check_eq(_cast(fight, [0, 1, 2])["damage"], 72.0, "two hits of 36:")


func test_weak_resist_immune() -> void:
	var weak: FightState = _fight(_monster({"weak": ["kenaz"]}), ["kenaz", "tiwaz"])
	check_eq(_cast(weak, [0, 1])["damage"], 72.0, "weak ×2:")
	var resist: FightState = _fight(_monster({"resist": ["kenaz"]}), ["kenaz", "tiwaz"])
	check_eq(_cast(resist, [0, 1])["damage"], 18.0, "resistant ×0.5:")
	var immune_monster: Monster = _monster({"immune": ["isaz"]})
	var immune: FightState = _fight(immune_monster, ["isaz", "tiwaz"])
	check_eq(_cast(immune, [0, 1])["damage"], 0.0, "immune ×0:")
	check_eq(immune_monster.frozen, 0, "an immune monster is not frozen either")


func test_water_washes_resistances() -> void:
	var resist: FightState = _fight(_monster({"resist": ["laguz"]}), ["laguz", "fehu"])
	check_eq(_cast(resist, [0, 1])["damage"], 15.0, "Water ignores the resistance (30 × 50%):")
	var immune: FightState = _fight(_monster({"immune": ["laguz"]}), ["laguz", "tiwaz"])
	check_eq(_cast(immune, [0, 1])["damage"], 15.0, "doubled, an immunity becomes a resistance:")


func test_targets_let_through_a_share() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "fehu"])
	var money_before: int = fight.money
	check_eq(_cast(fight, [0, 1])["damage"], 18.0, "into Coins: 50%:")
	check_eq(fight.money - money_before, 2, "Coins for every stone of the spell:")


func test_two_spells_and_the_chain() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "tiwaz", "isaz", "tiwaz"])
	var preview: Dictionary = fight.preview([0, 1, 2, 3])
	check_eq(preview["spells"], ["kenaz_tiwaz", "isaz_tiwaz"], "two spells:")
	# 36 + 28 × 1.25
	check_eq(preview["damage"], 71.0, "the second one +25%:")
	check_eq(_cast(fight, [0, 1, 2, 3])["damage"], 71.0, "dealt:")


func test_at_most_two_spells() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "tiwaz", "isaz", "tiwaz", "kenaz"])
	var preview: Dictionary = fight.preview([0, 1, 2, 3, 4])
	check_eq((preview["spells"] as Array).size(), 2, "spells:")


func test_the_kin_bonus() -> void:
	# Kenaz and Fehu are both of the Kin of Fehu.
	var fight: FightState = _fight(_monster(), ["kenaz", "fehu", "kenaz"])
	var preview: Dictionary = fight.preview([0, 1, 2])
	check(bool(preview["kin_bonus"]), "three stones of one Kin")
	check_eq(preview["damage"], 27.0, "18 × (2 × 1.5) × 50%:")
	var mixed: FightState = _fight(_monster(), ["kenaz", "fehu", "isaz"])
	check(not bool(mixed.preview([0, 1, 2])["kin_bonus"]), "Isaz is of another Kin")
	var two: FightState = _fight(_monster(), ["kenaz", "fehu"])
	check(not bool(two.preview([0, 1])["kin_bonus"]), "two stones are not enough")


func test_hail_strikes_three_times() -> void:
	var fight: FightState = _fight(_monster(), ["hagalaz", "fehu"])
	# 8 × 2 × 50% = 8 per hit, 3 hits.
	check_eq(_cast(fight, [0, 1])["damage"], 24.0, "three hits:")
	var doubled: FightState = _fight(_monster(), ["hagalaz", "tiwaz"])
	check_eq(_cast(doubled, [0, 1])["damage"], 96.0, "into the Enemy: six hits of 16:")


func test_the_shield_and_the_crush() -> void:
	var shielded: FightState = _fight(_monster({"shield": 30}), ["kenaz", "tiwaz"])
	check_eq(_cast(shielded, [0, 1])["damage"], 6.0, "36 − 30:")
	var crushed: FightState = _fight(_monster({"shield": 30}), ["uruz", "fehu"])
	check_eq(_cast(crushed, [0, 1])["damage"], 15.0, "Strength ignores the Shield:")
	var broken_monster: Monster = _monster({"shield": 30})
	var broken: FightState = _fight(broken_monster, ["uruz", "tiwaz"])
	_cast(broken, [0, 1])
	check(broken_monster.shield_broken, "Strength into the Enemy breaks the Shield")


func test_sun_against_the_night_and_time() -> void:
	var night: FightState = _fight(_monster({"tags": ["night"]}), ["sowilo", "fehu"])
	check_eq(_cast(night, [0, 1])["damage"], 32.0, "16 × 2 × ×2 × 50%:")
	var day: FightState = _fight(_monster(), ["dagaz", "tiwaz"])
	# 12 × 2 × (1 + 50% × 3 Casts left) = 60
	check_eq(_cast(day, [0, 1])["damage"], 60.0, "Day into the Enemy with 3 Casts left:")


func test_thorns_grow_with_actions() -> void:
	var fight: FightState = _fight(_monster(), ["thurisaz", "ehwaz", "fehu"])
	# (10 × (2 + 1)) × 50% = 15 per hit, twice.
	check_eq(_cast(fight, [0, 1, 2])["damage"], 30.0, "Thorns +1 Resonance per Action:")


func test_the_burn_bites_at_the_next_cast() -> void:
	var monster: Monster = _monster()
	var fight: FightState = _fight(monster, ["kenaz", "fehu", "isaz", "fehu"])
	_cast(fight, [0, 1])
	check_eq(monster.burn_stacks, 1, "one stack:")
	var hp: float = monster.hp
	var result: Dictionary = _cast(fight, [0, 1])
	check_eq(hp - monster.hp, 3.0 + 14.0, "the Burn (3) and Ice into Coins (14):")
	check_eq(str((result["events"] as Array)[0]["kind"]), "burn", "the Burn first:")


func test_ice_freezes_the_rule() -> void:
	var monster: Monster = _monster({"kind": "boss", "rule": "tax", "rule_value": 2})
	var fight: FightState = _fight(monster, ["isaz", "fehu"], {"money": 10})
	check_eq(fight.swap_cost(), 2, "the tax:")
	_cast(fight, [0, 1])
	check_eq(fight.swap_cost(), 0, "frozen: no tax")


func test_into_the_future() -> void:
	var monster: Monster = _monster()
	var fight: FightState = _fight(monster, ["kenaz", "ingwaz", "isaz", "fehu"])
	check_eq(_cast(fight, [0, 1])["damage"], 0.0, "nothing now:")
	var hp: float = monster.hp
	_cast(fight, [0, 1])
	# The Future (36 × 2) and Ice into Coins (14), ×1.5 Resonance from the Embers of Tomorrow.
	check_eq(hp - monster.hp, 72.0 + 21.0, "200% on the next Cast:")


func test_perthro_is_not_sure_damage() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "perthro", "tiwaz"])
	var preview: Dictionary = fight.preview([0, 1, 2])
	check_eq(preview["damage"], 0.0, "the gamble is not sure:")
	check_eq(preview["damage_max"], 108.0, "but it may triple:")


func test_kill_in_the_preview() -> void:
	var fight: FightState = _fight(_monster({}, 30.0), ["kenaz", "tiwaz"])
	check(bool(fight.preview([0, 1])["kill"]), "36 kills 30")
	var tough: FightState = _fight(_monster({}, 40.0), ["kenaz", "tiwaz"])
	check(not bool(tough.preview([0, 1])["kill"]), "36 does not kill 40")
	_cast(fight, [0, 1])
	check(fight.is_won(), "won")


func test_lessons_raise_the_element() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "tiwaz"], {"element_levels": {"kenaz": 2}})
	check_eq(fight.preview([0, 1])["damage"], 81.0, "level 2: 27 × 3:")


func test_into_the_voice_has_a_cap() -> void:
	var levels: Dictionary = {}
	var carry: Dictionary = FightState.new_carry()
	for i: int in 5:
		var fight: FightState = _fight(_monster(), ["kenaz", "ansuz"], {"element_levels": levels, "carry": carry})
		_cast(fight, [0, 1])
	check_eq(int(levels["kenaz"]), 4, "at most +3 from the Voice:")


func test_a_lord_takes_at_most_half_from_a_share_spell() -> void:
	var lord: Monster = _monster({"kind": "boss"}, 1000.0)
	lord.lose_pct(80.0, 50.0)
	check_eq(lord.hp, 500.0, "a Lord loses at most 50% at once:")
	var small: Monster = _monster({}, 1000.0)
	small.lose_pct(80.0, 50.0)
	check_eq(small.hp, 200.0, "a small monster loses it all:")


func test_small_but_stubborn() -> void:
	var monster: Monster = _monster({"kind": "boss", "rule": "max_hit_pct", "rule_value": 30}, 100.0)
	var fight: FightState = _fight(monster, ["kenaz", "ehwaz", "tiwaz"])
	check_eq(_cast(fight, [0, 1, 2])["damage"], 30.0, "one spell takes at most 30%:")


func test_the_balaur_has_three_heads() -> void:
	var balaur: Dictionary = Fixtures.data()["monsters"]["balaur"]
	var monster: Monster = Monster.new()
	monster.setup(balaur, 50.0)
	check_eq(monster.heads(), 3, "heads:")
	check_eq(monster.total_hp(), 150.0, "three bars of 50:")
	check_eq(monster.multiplier("kenaz"), 2.0, "the first head fears Fire:")
	monster.take_hit(60.0)
	check_eq(monster.head, 1, "the second head:")
	check_eq(monster.hp, 50.0, "a head starts whole:")
	check_eq(monster.multiplier("isaz"), 2.0, "the second head fears Ice:")
	monster.take_hit(50.0)
	monster.take_hit(50.0)
	check(monster.is_dead(), "three heads down")


func test_a_bound_stone_is_two_runes_in_a_row() -> void:
	var fight: FightState = _fight(_monster(), ["kenaz", "ehwaz", "tiwaz"])
	fight.hand[0].bound_rune = "ehwaz"
	# Kenaz+Ehwaz on one stone, then Tiwaz: Fire runs twice.
	var preview: Dictionary = fight.preview([0, 2])
	check_eq(preview["spells"], ["kenaz_tiwaz"], "one spell from two stones:")
	check_eq(preview["damage"], 72.0, "and it strikes twice:")
