extends RefCounted
## The whole exam (DESIGN 3.1, 3.8): 8 trials of 3 rounds (small question, big question,
## examiner). Keeps what lasts between rounds: the Bag, the Coins, the Words' levels and the
## spells' carry. Pure logic: the exam screen, the tests and the simulator drive it.
##
##   exam.setup(data, seed)
##   var round_state = exam.new_round()     # play it until won or lost, then round_state.finish()
##   var summary = exam.finish_round(round_state)
##   exam.is_over() / exam.passed

const RoundState = preload("res://scripts/core/round_state.gd")
const Bag = preload("res://scripts/core/bag.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")

const ROUND_KINDS: Array[String] = ["small", "big", "examiner"]
## Bump when the saved exam's shape changes (an old save is then dropped, not misread).
const SAVE_VERSION: int = 1

var exam_seed: int = 0
var rng: RandomNumberGenerator
var bag: Bag
var carry: Dictionary = {}
var money: int = 0
var word_levels: Dictionary = {}
## 0-based: trial 0..7, round 0..2.
var trial_index: int = 0
var round_index: int = 0
## The examiner of every trial (character ids), the final one last.
var examiners: Array[String] = []
var defeated: Array[String] = []
var rounds_won: int = 0
var finished: bool = false
var passed: bool = false
## Owned Talismans, left to right (TalismanRules entries); the rounds share this list.
var talismans: Array = []
## Lessons and Engravings waiting to be used: {"type": "lesson" | "engraving", "id"}.
var consumables: Array = []
## Lessons used in this exam (some Voices count them).
var lessons_used: int = 0
## Spells on/off for the rounds (the simulator compares both).
var spells_enabled: bool = true
## The divine parent chosen for this exam (data/parents.json; "" = none, the standard Bag).
var parent_id: String = ""
## Talismans the Night Market may offer (unlocked with Memories); empty = every Talisman.
var unlocked_talismans: Array[String] = []

var _data: Dictionary


## data: the GameData tables (runes, words, spells, spell_actions, rules, economy, trials,
## examiners, talismans, lessons, engravings, parents). The seed drives every random choice of
## the exam; the parent (DESIGN 3.10) gives the exam its starting bonus.
func setup(data: Dictionary, seed_value: int, parent: String = "") -> void:
	_data = data
	exam_seed = seed_value
	parent_id = parent
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	bag = Bag.new(rng)
	var copies: int = int((data["rules"] as Dictionary).get("copies_per_rune", 2))
	bag.fill_with_runes(data["runes"], int(parent_entry().get("copies_per_rune", copies)))
	carry = RoundState.new_carry()
	money = int(_economy("start_money", 0))
	word_levels = {}
	talismans = []
	consumables = []
	lessons_used = 0
	trial_index = 0
	round_index = 0
	defeated.clear()
	rounds_won = 0
	finished = false
	passed = false
	_pick_examiners()
	_give_start_engravings()


## The chosen parent's entry ({} for none).
func parent_entry() -> Dictionary:
	return (_data.get("parents", {}) as Dictionary).get(parent_id, {})


func trial_count() -> int:
	return (_data["trials"] as Dictionary).size()


func trial() -> Dictionary:
	return (_data["trials"] as Dictionary).values()[trial_index]


## "small", "big" or "examiner".
func round_kind() -> String:
	return ROUND_KINDS[round_index]


## The examiner of the current trial (they sit at the desk for all three rounds).
func examiner_id() -> String:
	return examiners[trial_index]


func examiner() -> Dictionary:
	return (_data["examiners"] as Dictionary).get(examiner_id(), {})


## The rule of the current round ({} for the small and big questions).
func rule() -> Dictionary:
	return examiner() if round_kind() == "examiner" else {}


func is_final_round() -> bool:
	return trial_index == trial_count() - 1 and round_kind() == "examiner"


## The current round's target: the trial's base × the round's multiplier (× the examiner's own).
func target() -> float:
	var mults: Array = _economy("round_target_mults", [1.0, 1.5, 2.0])
	var value: float = float(trial()["base_target"]) * float(mults[round_index])
	if round_kind() == "examiner":
		value *= float(examiner().get("target_mult", 1.0))
	return roundf(value)


## The options RoundState.setup needs for the current round.
func round_options() -> Dictionary:
	return {
		"bag": bag, "carry": carry, "money": money, "word_levels": word_levels, "rule": rule(),
		"spells": spells_enabled, "talismans": talismans, "consumables": consumables, "lessons_used": lessons_used,
		"bonus_casts": int(parent_entry().get("casts", 0)), "bonus_swaps": int(parent_entry().get("swaps", 0)),
		"bonus_hand": int(parent_entry().get("hand", 0)), "unlocked_talismans": unlocked_talismans,
	}


## Builds and starts the current round.
func new_round() -> RoundState:
	var state: RoundState = RoundState.new()
	state.setup(_data, rng, target(), round_options())
	state.start()
	return state


## After a round ended (and RoundState.finish() ran): pays the reward, moves on.
## Returns {"won", "kind", "reward": {"round", "casts", "interest", "total"}, "defeated": examiner id or "",
## "exam_over", "exam_passed"}.
func finish_round(state: RoundState) -> Dictionary:
	money = state.money
	lessons_used = state.lessons_used
	var summary: Dictionary = {
		"won": state.is_won(), "kind": round_kind(), "defeated": "",
		"reward": {"round": 0, "casts": 0, "interest": 0, "total": 0},
		"exam_over": false, "exam_passed": false,
	}
	if not state.is_won():
		# Aeva's Hourglass: the round starts over once, then the Hourglass breaks.
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
	if round_kind() == "examiner":
		defeated.append(examiner_id())
		summary["defeated"] = examiner_id()
		TalismanRules.after_examiner(talismans, _talisman_table())
	_advance()
	summary["exam_over"] = finished
	summary["exam_passed"] = passed
	return summary


## The Coins for a won round: the round's own, some per Cast left, interest on savings.
func reward_for(state: RoundState) -> Dictionary:
	var by_kind: int = int(_economy("reward_" + round_kind(), 0))
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


## Uses a Lesson outside a round (in the Market): its Word goes up a level.
func use_lesson(slot: int) -> bool:
	if slot < 0 or slot >= consumables.size() or str(consumables[slot]["type"]) != "lesson":
		return false
	var lesson: Dictionary = (_data.get("lessons", {}) as Dictionary).get(str(consumables[slot]["id"]), {})
	var word_id: String = str(lesson.get("word", ""))
	word_levels[word_id] = int(word_levels.get(word_id, 1)) + 1
	lessons_used += 1
	consumables.remove_at(slot)
	return true


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


## Examiners of the next `count` trials after the current one (Sun against the Examiner).
func upcoming_examiners(count: int) -> Array[String]:
	return examiners.slice(trial_index + 1, mini(trial_index + 1 + count, examiners.size()))


func _advance() -> void:
	round_index += 1
	if round_index < ROUND_KINDS.size():
		return
	round_index = 0
	trial_index += 1
	carry["peek_examiners"] = maxi(0, int(carry.get("peek_examiners", 0)) - 1)
	# Thorn into the Talismans lasts until the end of its trial.
	carry.erase("trial_res_mult")
	if trial_index >= trial_count():
		trial_index = trial_count() - 1
		round_index = ROUND_KINDS.size() - 1
		finished = true
		passed = true


## Ignar's child starts with random Engravings (different ones while there are enough).
func _give_start_engravings() -> void:
	var pool: Array = (_data.get("engravings", {}) as Dictionary).keys()
	for i: int in int(parent_entry().get("start_engravings", 0)):
		if pool.is_empty():
			break
		add_consumable("engraving", str(pool.pop_at(rng.randi_range(0, pool.size() - 1))))


# --- Saving the exam in progress -------------------------------------------------------------

## Everything needed to go on with this exam later, between two rounds, as plain data
## (JSON.from_native keeps the types, so it can go straight into save.json).
func to_dict() -> Dictionary:
	return JSON.from_native({
		"version": SAVE_VERSION, "seed": exam_seed, "rng_state": rng.state, "parent": parent_id,
		"bag": bag.to_dict(), "carry": carry, "money": money, "word_levels": word_levels,
		"trial": trial_index, "round": round_index, "examiners": examiners, "defeated": defeated,
		"rounds_won": rounds_won, "talismans": talismans, "consumables": consumables, "lessons_used": lessons_used,
		"unlocked_talismans": unlocked_talismans,
	})


## Restores an exam saved with to_dict(). Returns false (and changes nothing useful) when the
## save does not fit the current data: then the exam cannot go on.
func load_dict(data: Dictionary, saved: Dictionary) -> bool:
	if not saved.has("type"):
		return false
	var native: Variant = JSON.to_native(saved)
	if not (native is Dictionary):
		return false
	var state: Dictionary = native
	if int(state.get("version", 0)) != SAVE_VERSION:
		return false
	var saved_examiners: Array = state.get("examiners", [])
	for id: Variant in saved_examiners:
		if not (data["examiners"] as Dictionary).has(str(id)):
			return false
	if saved_examiners.size() != (data["trials"] as Dictionary).size():
		return false
	setup(data, int(state.get("seed", 1)), str(state.get("parent", "")))
	rng.state = int(state.get("rng_state", rng.state))
	bag.load_dict(state.get("bag", {}))
	carry = RoundState.new_carry()
	carry.merge(state.get("carry", {}), true)
	money = int(state.get("money", 0))
	word_levels = (state.get("word_levels", {}) as Dictionary).duplicate(true)
	trial_index = clampi(int(state.get("trial", 0)), 0, trial_count() - 1)
	round_index = clampi(int(state.get("round", 0)), 0, ROUND_KINDS.size() - 1)
	examiners.assign(saved_examiners.map(func(id: Variant) -> String: return str(id)))
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
	lessons_used = int(state.get("lessons_used", 0))
	unlocked_talismans.assign((state.get("unlocked_talismans", []) as Array).map(func(id: Variant) -> String: return str(id)))
	return true


## Trials 1..n-1 get different examiners in a random order; the final one is always last.
func _pick_examiners() -> void:
	examiners.clear()
	var pool: Array[String] = []
	var final_id: String = ""
	var table: Dictionary = _data["examiners"]
	for id: String in table:
		if bool((table[id] as Dictionary).get("final", false)):
			final_id = id
		else:
			pool.append(id)
	for i: int in trial_count() - 1:
		examiners.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	examiners.append(final_id)


func _talisman_table() -> Dictionary:
	return _data.get("talismans", {})


func _economy(key: String, fallback: Variant) -> Variant:
	return (_data.get("economy", {}) as Dictionary).get(key, fallback)
