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

const ROUND_KINDS: Array[String] = ["small", "big", "examiner"]

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
## Spells on/off for the rounds (the simulator compares both).
var spells_enabled: bool = true

var _data: Dictionary


## data: the GameData tables (runes, words, spells, spell_actions, rules, economy, trials,
## examiners). The seed drives every random choice of the exam.
func setup(data: Dictionary, seed_value: int) -> void:
	_data = data
	exam_seed = seed_value
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	bag = Bag.new(rng)
	bag.fill_with_runes(data["runes"], int((data["rules"] as Dictionary).get("copies_per_rune", 2)))
	carry = RoundState.new_carry()
	money = int(_economy("start_money", 0))
	word_levels = {}
	trial_index = 0
	round_index = 0
	defeated.clear()
	rounds_won = 0
	finished = false
	passed = false
	_pick_examiners()


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
		"spells": spells_enabled,
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
	var summary: Dictionary = {
		"won": state.is_won(), "kind": round_kind(), "defeated": "",
		"reward": {"round": 0, "casts": 0, "interest": 0, "total": 0},
		"exam_over": false, "exam_passed": false,
	}
	if not state.is_won():
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
	if trial_index >= trial_count():
		trial_index = trial_count() - 1
		round_index = ROUND_KINDS.size() - 1
		finished = true
		passed = true


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


func _economy(key: String, fallback: Variant) -> Variant:
	return (_data.get("economy", {}) as Dictionary).get(key, fallback)
