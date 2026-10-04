extends RefCounted
## The Journey through the 8 Realms (docs/PROMPT_ETAPA5.md 3). Every Realm: a small monster, a
## big monster, then its Lord (boss). Keeps what lasts between fights: the Bag, the Coins, the
## Elements' levels, the Talismans, the consumables and the spells' carry. Pure logic: the
## Journey screen, the tests and the simulator drive it. (Stage 5 step D adds the hearts and
## renames it JourneyState.)
##
##   exam.setup(data, seed)
##   var fight = exam.new_round()     # play it until won or lost, then fight.finish()
##   var summary = exam.finish_round(fight)
##   exam.is_over() / exam.passed

const FightState = preload("res://scripts/core/fight_state.gd")
const Monster = preload("res://scripts/core/monster.gd")
const Bag = preload("res://scripts/core/bag.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")

const ROUND_KINDS: Array[String] = ["small", "big", "boss"]
## Bump when the saved Journey's shape changes (an old save is then dropped, not misread).
const SAVE_VERSION: int = 2

var exam_seed: int = 0
var rng: RandomNumberGenerator
var bag: Bag
var carry: Dictionary = {}
var money: int = 0
## Element rune id -> level (Lessons, into the Voice).
var element_levels: Dictionary = {}
## 0-based: Realm 0..7, fight 0..2.
var trial_index: int = 0
var round_index: int = 0
## The monsters of every Realm: [{"small", "big", "boss"}] (monster ids), chosen with the seed.
var lineup: Array[Dictionary] = []
## Lords beaten (monster ids).
var defeated: Array[String] = []
var rounds_won: int = 0
var finished: bool = false
var passed: bool = false
## Owned Talismans, left to right (TalismanRules entries); the fights share this list.
var talismans: Array = []
## Lessons and Engravings waiting to be used: {"type": "lesson" | "engraving", "id"}.
var consumables: Array = []
## Spells on/off for the fights.
var spells_enabled: bool = true
## The divine parent chosen for this Journey (data/parents.json; "" = none, the standard Bag).
var parent_id: String = ""
## Talismans the Night Market may offer (unlocked with Memories); empty = every Talisman.
var unlocked_talismans: Array[String] = []

var _data: Dictionary


## data: the GameData tables (runes, elements, targets, spells, spell_actions, rules, economy,
## realms, monsters, talismans, lessons, engravings, parents). The seed drives every random
## choice; the parent gives the Journey its starting bonus.
func setup(data: Dictionary, seed_value: int, parent: String = "") -> void:
	_data = data
	exam_seed = seed_value
	parent_id = parent
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	bag = Bag.new(rng)
	var copies: int = int((data["rules"] as Dictionary).get("copies_per_rune", 2))
	bag.fill_with_runes(data["runes"], int(parent_entry().get("copies_per_rune", copies)))
	carry = FightState.new_carry()
	money = int(_economy("start_money", 0))
	element_levels = {}
	talismans = []
	consumables = []
	trial_index = 0
	round_index = 0
	defeated.clear()
	rounds_won = 0
	finished = false
	passed = false
	_pick_lineup()
	_give_start_engravings()


## The chosen parent's entry ({} for none).
func parent_entry() -> Dictionary:
	return (_data.get("parents", {}) as Dictionary).get(parent_id, {})


func trial_count() -> int:
	return (_data["realms"] as Dictionary).size()


## The current Realm's entry.
func trial() -> Dictionary:
	return (_data["realms"] as Dictionary).values()[trial_index]


## "small", "big" or "boss".
func round_kind() -> String:
	return ROUND_KINDS[round_index]


## The monster of the current fight.
func monster_id() -> String:
	return str(lineup[trial_index].get(round_kind(), ""))


func monster_entry() -> Dictionary:
	return (_data["monsters"] as Dictionary).get(monster_id(), {})


## The Lord of the current Realm.
func boss_id() -> String:
	return str(lineup[trial_index].get("boss", ""))


func is_final_round() -> bool:
	return trial_index == trial_count() - 1 and round_kind() == "boss"


## The current monster's life: the Realm's base × the fight's multiplier × the monster's own.
func monster_hp() -> float:
	var entry: Dictionary = monster_entry()
	if entry.has("hp"):
		return float(entry["hp"])
	var mults: Array = _economy("monster_hp_mults", [1.0, 1.5, 2.5])
	return roundf(float(trial()["base_hp"]) * float(mults[round_index]) * float(entry.get("hp_mult", 1.0)))


## The options FightState.setup needs for the current fight.
func round_options() -> Dictionary:
	return {
		"bag": bag, "carry": carry, "money": money, "element_levels": element_levels, "spells": spells_enabled,
		"talismans": talismans, "consumables": consumables,
		"bonus_casts": int(parent_entry().get("casts", 0)), "bonus_swaps": int(parent_entry().get("swaps", 0)),
		"bonus_hand": int(parent_entry().get("hand", 0)), "unlocked_talismans": unlocked_talismans,
	}


## Builds and starts the current fight.
func new_round() -> FightState:
	var monster: Monster = Monster.new()
	monster.setup(monster_entry(), monster_hp())
	var state: FightState = FightState.new()
	state.setup(_data, rng, monster, round_options())
	state.start()
	return state


## After a fight ended (and FightState.finish() ran): pays the reward, moves on.
## Returns {"won", "kind", "reward": {"round", "casts", "interest", "total"}, "defeated": boss id or "",
## "exam_over", "exam_passed"}.
func finish_round(state: FightState) -> Dictionary:
	money = state.money
	var summary: Dictionary = {
		"won": state.is_won(), "kind": round_kind(), "defeated": "",
		"reward": {"round": 0, "casts": 0, "interest": 0, "total": 0},
		"exam_over": false, "exam_passed": false,
	}
	if not state.is_won():
		# Aeva's Hourglass: the fight starts over once, then the Hourglass breaks.
		var hourglass: int = TalismanRules.find_kind(talismans, _talisman_table(), "second_chance")
		if hourglass >= 0:
			talismans.remove_at(hourglass)
			summary["second_chance"] = true
			return summary
		finished = true
		summary["exam_over"] = true
		return summary
	var reward: Dictionary = reward_for(state)
	money += int(reward["total"])
	summary["reward"] = reward
	rounds_won += 1
	if round_kind() == "boss":
		defeated.append(monster_id())
		summary["defeated"] = monster_id()
		TalismanRules.after_examiner(talismans, _talisman_table())
	_advance()
	summary["exam_over"] = finished
	summary["exam_passed"] = passed
	return summary


## The Coins for a won fight: the fight's own, some per Cast left, interest on savings.
func reward_for(state: FightState) -> Dictionary:
	var by_kind: int = int(_economy("reward_" + ("examiner" if round_kind() == "boss" else round_kind()), 0))
	var per_cast: int = int(_economy("reward_per_cast_left", 0)) * maxi(0, state.casts_left)
	var per: int = maxi(1, int(_economy("interest_per", 6)))
	var interest: int = mini(maxi(0, state.money) / per, int(_economy("interest_max", 0)))
	return {"round": by_kind, "casts": per_cast, "interest": interest, "total": by_kind + per_cast + interest}


func is_over() -> bool:
	return finished


## Adds a Talisman if a slot is free.
func add_talisman(id: String) -> bool:
	if talismans.size() >= talisman_slots() or not _talisman_table().has(id):
		return false
	talismans.append(TalismanRules.make(id, _talisman_table()))
	return true


## Adds a Lesson or an Engraving if a consumable slot is free.
func add_consumable(type: String, id: String) -> bool:
	var table: Dictionary = _data.get("lessons" if type == "lesson" else "engravings", {})
	if consumables.size() >= consumable_slots() or not table.has(id):
		return false
	consumables.append({"type": type, "id": id})
	return true


func consumable_slots() -> int:
	return int(_economy("consumable_slots", 2))


## Uses a Lesson outside a fight (in the Market): its Element goes up a level.
func use_lesson(slot: int) -> bool:
	if slot < 0 or slot >= consumables.size() or str(consumables[slot]["type"]) != "lesson":
		return false
	var lesson: Dictionary = (_data.get("lessons", {}) as Dictionary).get(str(consumables[slot]["id"]), {})
	var element_id: String = str(lesson.get("element", ""))
	element_levels[element_id] = element_level(element_id) + 1
	consumables.remove_at(slot)
	return true


func element_level(element_id: String) -> int:
	return int(element_levels.get(element_id, 1))


## Sells the Talisman in this slot for a share of its price. Returns the Coins gained.
func sell_talisman(slot: int) -> int:
	if slot < 0 or slot >= talismans.size():
		return 0
	var gained: int = sell_price(str(talismans[slot]["id"]))
	talismans.remove_at(slot)
	money += gained
	return gained


func talisman_slots() -> int:
	return int(_economy("talisman_slots", 5)) + int(parent_entry().get("talisman_slots", 0))


func talisman_price(id: String) -> int:
	var rarity: String = str(_talisman_table().get(id, {}).get("rarity", "common"))
	return int(_economy("price_" + rarity, 5))


func sell_price(id: String) -> int:
	return talisman_price(id) * int(_economy("sell_share_pct", 50)) / 100


func move_talisman(from: int, to: int) -> void:
	if from < 0 or from >= talismans.size():
		return
	var item: Dictionary = talismans.pop_at(from)
	talismans.insert(clampi(to, 0, talismans.size()), item)


## The Lords of the next `count` Realms after the current one (Sun upon the Lord).
func upcoming_bosses(count: int) -> Array[String]:
	var result: Array[String] = []
	for i: int in range(trial_index + 1, mini(trial_index + 1 + count, lineup.size())):
		result.append(str(lineup[i]["boss"]))
	return result


func _advance() -> void:
	round_index += 1
	if round_index < ROUND_KINDS.size():
		return
	round_index = 0
	trial_index += 1
	carry["peek_examiners"] = maxi(0, int(carry.get("peek_examiners", 0)) - 1)
	# Thorn into the Talismans lasts until the end of its Realm.
	carry.erase("trial_res_mult")
	if trial_index >= trial_count():
		trial_index = trial_count() - 1
		round_index = ROUND_KINDS.size() - 1
		finished = true
		passed = true


## Every Realm gets a small and a big monster from those living there (the seed chooses),
## and its own Lord.
func _pick_lineup() -> void:
	lineup.clear()
	var monsters: Dictionary = _data["monsters"]
	for realm: Variant in (_data["realms"] as Dictionary).values():
		var entry: Dictionary = realm
		var pool_from: Array = entry.get("pool_from", [int(entry["number"])])
		var fights: Dictionary = {"boss": str(entry["boss"])}
		for kind: String in ["small", "big"]:
			var pool: Array[String] = []
			for id: String in monsters:
				var monster: Dictionary = monsters[id]
				if str(monster.get("kind", "")) != kind:
					continue
				for number: Variant in monster.get("realms", []):
					if pool_from.has(int(number)) and not pool.has(id):
						pool.append(id)
			fights[kind] = pool[rng.randi_range(0, pool.size() - 1)] if not pool.is_empty() else ""
		lineup.append(fights)


## Ignar's child starts with random Engravings (different ones while there are enough).
func _give_start_engravings() -> void:
	var pool: Array = (_data.get("engravings", {}) as Dictionary).keys()
	for i: int in int(parent_entry().get("start_engravings", 0)):
		if pool.is_empty():
			break
		add_consumable("engraving", str(pool.pop_at(rng.randi_range(0, pool.size() - 1))))


# --- Saving the Journey in progress ----------------------------------------------------------

## Everything needed to go on with this Journey later, between two fights, as plain data
## (JSON.from_native keeps the types, so it can go straight into save.json).
func to_dict() -> Dictionary:
	return JSON.from_native({
		"version": SAVE_VERSION, "seed": exam_seed, "rng_state": rng.state, "parent": parent_id,
		"bag": bag.to_dict(), "carry": carry, "money": money, "element_levels": element_levels,
		"trial": trial_index, "round": round_index, "lineup": lineup, "defeated": defeated,
		"rounds_won": rounds_won, "talismans": talismans, "consumables": consumables,
		"unlocked_talismans": unlocked_talismans,
	})


## Restores a Journey saved with to_dict(). Returns false (and changes nothing useful) when the
## save does not fit the current data: then it cannot go on.
func load_dict(data: Dictionary, saved: Dictionary) -> bool:
	if not saved.has("type"):
		return false
	var native: Variant = JSON.to_native(saved)
	if not (native is Dictionary):
		return false
	var state: Dictionary = native
	if int(state.get("version", 0)) != SAVE_VERSION:
		return false
	var saved_lineup: Array = state.get("lineup", [])
	if saved_lineup.size() != (data["realms"] as Dictionary).size():
		return false
	for fights: Variant in saved_lineup:
		if not (fights is Dictionary):
			return false
		for id: Variant in (fights as Dictionary).values():
			if not (data["monsters"] as Dictionary).has(str(id)):
				return false
	setup(data, int(state.get("seed", 1)), str(state.get("parent", "")))
	rng.state = int(state.get("rng_state", rng.state))
	bag.load_dict(state.get("bag", {}))
	carry = FightState.new_carry()
	carry.merge(state.get("carry", {}), true)
	money = int(state.get("money", 0))
	element_levels = (state.get("element_levels", {}) as Dictionary).duplicate(true)
	trial_index = clampi(int(state.get("trial", 0)), 0, trial_count() - 1)
	round_index = clampi(int(state.get("round", 0)), 0, ROUND_KINDS.size() - 1)
	lineup.clear()
	for fights: Variant in saved_lineup:
		lineup.append((fights as Dictionary).duplicate())
	defeated.assign((state.get("defeated", []) as Array).map(func(id: Variant) -> String: return str(id)))
	rounds_won = int(state.get("rounds_won", 0))
	talismans = []
	for item: Variant in state.get("talismans", []):
		if item is Dictionary and _talisman_table().has(str((item as Dictionary).get("id", ""))):
			talismans.append(item)
	consumables = []
	for item: Variant in state.get("consumables", []):
		if item is Dictionary:
			consumables.append(item)
	unlocked_talismans.assign((state.get("unlocked_talismans", []) as Array).map(func(id: Variant) -> String: return str(id)))
	return true


func _talisman_table() -> Dictionary:
	return _data.get("talismans", {})


func _economy(key: String, fallback: Variant) -> Variant:
	return (_data.get("economy", {}) as Dictionary).get(key, fallback)
