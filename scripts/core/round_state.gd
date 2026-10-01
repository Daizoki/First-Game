extends RefCounted
## One round (DESIGN 3.2): the hand, Casts and Swaps, the target and the score, the Spells.
## Pure logic used by the round screen, the tests and the simulator.

const Stone = preload("res://scripts/core/stone.gd")
const Bag = preload("res://scripts/core/bag.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const SpellDetector = preload("res://scripts/core/spell_detector.gd")
const Scorer = preload("res://scripts/core/scorer.gd")

var bag: Bag
var hand: Array[Stone] = []
var target: float = 0.0
var score: float = 0.0
var casts_left: int = 0
var swaps_left: int = 0
var casts_used: int = 0
var money: int = 0
## Word id -> level. Shared with the exam later (Lessons).
var word_levels: Dictionary = {}
var lessons_used: int = 0
var talismans_owned: int = 0
## Side effects for the rest of the exam (Stage 3 uses them).
var pending_talismans: int = 0
var market_discount_pct: int = 0

var _data: Dictionary
var _rng: RandomNumberGenerator
var _hand_size: int = 8
var _hand_bonus: int = 0
var _res_mult_next: float = 1.0
var _money_at_round_end: int = 0
var _once_used: Array[String] = []
## Rune ids drawn first, in this order (a fixed tutorial hand, then its next stones).
var _stacked: Array[String] = []


## data: {"runes", "words", "spells", "rules"} (the GameData tables).
## options (all optional): "casts", "swaps" (override the rules), "hand" + "bag_top"
## (rune ids drawn first, in order), "bag_only" (the bag holds only those stones).
func setup(data: Dictionary, rng: RandomNumberGenerator, round_target: float, options: Dictionary = {}) -> void:
	_data = data
	_rng = rng
	var rules: Dictionary = data["rules"]
	bag = Bag.new(rng)
	bag.fill_with_runes(data["runes"], int(rules.get("copies_per_rune", 2)))
	target = round_target
	_hand_size = int(rules.get("hand_size", 8))
	casts_left = int(options.get("casts", rules.get("casts_per_round", 4)))
	swaps_left = int(options.get("swaps", rules.get("swaps_per_round", 3)))
	_stacked.clear()
	for id: Variant in options.get("hand", []):
		_stacked.append(str(id))
	for id: Variant in options.get("bag_top", []):
		_stacked.append(str(id))
	if bool(options.get("bag_only", false)):
		bag.keep_only(_stacked)


func start() -> void:
	score = 0.0
	casts_used = 0
	_hand_bonus = 0
	_res_mult_next = 1.0
	_money_at_round_end = 0
	_once_used.clear()
	hand.clear()
	bag.reset_round()
	bag.stack_on_top(_stacked)
	refill()


func refill() -> void:
	hand.append_array(bag.draw(hand_limit() - hand.size()))


func hand_limit() -> int:
	return _hand_size + _hand_bonus


func max_selection() -> int:
	return int((_data["rules"] as Dictionary).get("max_stones_per_action", 5))


func is_won() -> bool:
	return score >= target


func is_lost() -> bool:
	return not is_won() and (casts_left <= 0 or hand.is_empty())


func can_cast(indices: Array[int]) -> bool:
	return casts_left > 0 and _valid_selection(indices) and not is_won()


func can_swap(indices: Array[int]) -> bool:
	return swaps_left > 0 and _valid_selection(indices) and not is_won() and bag.remaining() > 0


## What the round screen shows while stones are selected (before casting).
func preview(indices: Array[int]) -> Dictionary:
	if not _valid_selection(indices):
		return {}
	var selected: Array[Stone] = _stones_at(indices)
	var word: Dictionary = WordDetector.detect(selected, _data["words"])
	var word_data: Dictionary = (_data["words"] as Dictionary)[word["word"]]
	var level: int = word_level(word["word"])
	var scoring_hand: Array[int] = []
	for i: int in word["scoring"]:
		scoring_hand.append(_sorted(indices)[i])
	return {
		"word": word["word"],
		"scoring": scoring_hand,
		"power": float(word_data["base_power"]) + float(word_data["level_power"]) * (level - 1),
		"res": float(word_data["base_res"]) + float(word_data["level_res"]) * (level - 1),
		"spells": SpellDetector.detect(selected, _data["spells"]),
	}


## Casts the selected stones. Returns everything the screen needs to animate the result.
func cast(indices: Array[int]) -> Dictionary:
	if not can_cast(indices):
		return {}
	var order: Array[int] = _sorted(indices)
	var cast_stones: Array[Stone] = _stones_at(order)
	var held: Array[Stone] = []
	for i: int in hand.size():
		if not order.has(i):
			held.append(hand[i])
	var word: Dictionary = WordDetector.detect(cast_stones, _data["words"])
	var spells: Array[String] = SpellDetector.detect(cast_stones, _data["spells"])
	var rules: Dictionary = _data["rules"]

	var result: Dictionary = Scorer.score_cast({
		"cast": cast_stones, "held": held, "word": word, "words": _data["words"], "runes": _data["runes"],
		"word_level": word_level(word["word"]), "cast_index": casts_used, "is_last_cast": casts_left == 1,
		"voices_awake": bool(rules.get("rune_voices_start_awake", true)), "res_mult": _res_mult_next,
		"lessons_used": lessons_used, "talismans": talismans_owned, "once_used": _once_used, "rng": _rng,
	})
	_res_mult_next = 1.0
	_once_used.assign(result["once_used"])
	score += float(result["score"])
	money += int(result["money"])
	_money_at_round_end += int(result["money_at_round_end"])
	swaps_left += int(result["swaps"])
	for grow: Dictionary in result["grow"]:
		(grow["stone"] as Stone).bonus_power += int(grow["value"])
	for source: Stone in result["copies"]:
		bag.add_copy_of(source)

	# The cast stones leave the hand; held stones keep their order.
	hand = held
	casts_left -= 1
	casts_used += 1
	result["word"] = word["word"]
	result["cast_stones"] = cast_stones
	result["scoring"] = word["scoring"]
	result["spells"] = spells
	result["spell_effects"] = _apply_spells(spells, word["word"])
	refill()
	result["won"] = is_won()
	result["lost"] = is_lost()
	return result


## Swaps the selected stones for new ones from the bag.
func swap(indices: Array[int]) -> bool:
	if not can_swap(indices):
		return false
	var order: Array[int] = _sorted(indices)
	order.reverse()
	for i: int in order:
		hand.remove_at(i)
	swaps_left -= 1
	refill()
	return true


## End of the round: Ingwaz grows if still in hand, Jera pays out. Returns what happened.
func finish() -> Dictionary:
	var grown: Array[Stone] = []
	if bool((_data["rules"] as Dictionary).get("rune_voices_start_awake", true)):
		for stone: Stone in hand:
			var rune: Dictionary = (_data["runes"] as Dictionary).get(stone.rune_id, {})
			for effect: Dictionary in rune.get("effects", []):
				if effect.get("trigger") != "on_round_end_held":
					continue
				for action: Dictionary in effect["actions"]:
					if action["type"] == "grow_power":
						stone.bonus_power += int(action.get("value", 0))
						grown.append(stone)
	money += _money_at_round_end
	var paid: int = _money_at_round_end
	_money_at_round_end = 0
	return {"grown": grown, "money": paid}


func word_level(word_id: String) -> int:
	return int(word_levels.get(word_id, 1))


## The next stones of the bag when Kenaz is in hand (empty otherwise).
func kenaz_peek() -> Array[Stone]:
	var count: int = 0
	for stone: Stone in hand:
		var rune: Dictionary = (_data["runes"] as Dictionary).get(stone.rune_id, {})
		for effect: Dictionary in rune.get("effects", []):
			for action: Dictionary in effect.get("actions", []):
				if action.get("name", "") == "kenaz_peek":
					count = maxi(count, int(action.get("value", 0)))
	if count == 0:
		var none: Array[Stone] = []
		return none
	return bag.peek(count)


func sort_by_position() -> void:
	hand.sort_custom(func(a: Stone, b: Stone) -> bool:
		return a.position < b.position if a.position != b.position else a.kin < b.kin)


func sort_by_kin() -> void:
	hand.sort_custom(func(a: Stone, b: Stone) -> bool:
		return a.kin < b.kin if a.kin != b.kin else a.position < b.position)


## Drag and drop inside the hand.
func move_stone(from: int, to: int) -> void:
	if from < 0 or from >= hand.size():
		return
	var stone: Stone = hand[from]
	hand.remove_at(from)
	hand.insert(clampi(to, 0, hand.size()), stone)


func _apply_spells(spells: Array[String], word_id: String) -> Array[Dictionary]:
	var applied: Array[Dictionary] = []
	for id: String in spells:
		var spell: Dictionary = (_data["spells"] as Dictionary)[id]
		for action: Dictionary in spell.get("actions", []):
			var value: float = float(action.get("value", 0))
			match str(action["type"]):
				"reduce_target_pct":
					target = maxf(0.0, target * (1.0 - value / 100.0))
				"add_money":
					money += int(value)
				"refund_cast":
					casts_left += int(value)
				"next_cast_mul_res":
					_res_mult_next *= value
				"word_level_up":
					word_levels[word_id] = word_level(word_id) + int(value)
				"grant_random_talisman":
					pending_talismans += int(value)
				"market_discount_pct":
					market_discount_pct = maxi(market_discount_pct, int(value))
				"hand_size_bonus":
					_hand_bonus += int(value)
			applied.append({"spell": id, "type": action["type"], "value": value})
	return applied


func _valid_selection(indices: Array[int]) -> bool:
	if indices.is_empty() or indices.size() > max_selection():
		return false
	for i: int in indices:
		if i < 0 or i >= hand.size() or indices.count(i) > 1:
			return false
	return true


func _sorted(indices: Array[int]) -> Array[int]:
	var order: Array[int] = []
	order.assign(indices)
	order.sort()
	return order


func _stones_at(indices: Array[int]) -> Array[Stone]:
	var stones: Array[Stone] = []
	for i: int in _sorted(indices):
		stones.append(hand[i])
	return stones
