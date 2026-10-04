extends RefCounted
## Recognises which Word a set of stones forms, and which of them score.
## Patterns are fixed rules (3.4); their strength order comes from "rank" in words.json.
## Laguz counts as a stone of any kin (only for Neam / Descântec, never for Spells).

const Stone = preload("res://scripts/core/stone.gd")

const WILD_KIN_RUNE: String = "laguz"
const ROW_LENGTH: int = 5
const MAX_POSITION: int = 8
const KINS: Array = ["fehu", "hagalaz", "tiwaz"]


## Best Word formed by the cast stones (1..5 stones, in hand order).
## Returns {"word": id, "scoring": Array[int] (indices into `stones`, left to right), "kin": kin id or ""}.
static func detect(stones: Array[Stone], words: Dictionary) -> Dictionary:
	# A bind-rune counts as either of its runes: try every reading, keep the best Word.
	var bound: Array[int] = []
	for i: int in stones.size():
		if not stones[i].bound_rune.is_empty():
			bound.append(i)
	if bound.is_empty():
		return _detect_plain(stones, words)
	var best: Dictionary = {}
	for mask: int in range(1 << bound.size()):
		var reading: Array[Stone] = stones.duplicate()
		for b: int in bound.size():
			if mask & (1 << b):
				reading[bound[b]] = stones[bound[b]].as_bound()
		var found: Dictionary = _detect_plain(reading, words)
		if best.is_empty() or _rank(words, found) > _rank(words, best) \
				or (_rank(words, found) == _rank(words, best) and (found["scoring"] as Array).size() > (best["scoring"] as Array).size()):
			best = found
	return best


static func _rank(words: Dictionary, found: Dictionary) -> int:
	return int((words[found["word"]] as Dictionary).get("rank", 0)) if not found.is_empty() else -1


static func _detect_plain(stones: Array[Stone], words: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	if stones.is_empty():
		return best
	var best_rank: int = -1
	for word_id: String in words:
		var rank: int = int((words[word_id] as Dictionary).get("rank", 0))
		if rank <= best_rank:
			continue
		var found: Dictionary = _match(word_id, stones)
		if not found.is_empty():
			best = found
			best_rank = rank
	return best


## Which Words could be cast from a whole hand (any 1..5 of its stones). Used by the simulator.
static func available_in_hand(stones: Array[Stone]) -> Array[String]:
	var result: Array[String] = ["single"]
	var counts: Array[int] = _position_counts(stones)
	var sorted_counts: Array[int] = []
	sorted_counts.assign(counts)
	sorted_counts.sort()
	sorted_counts.reverse()
	var top: int = sorted_counts[0]
	var second: int = sorted_counts[1]
	if top >= 2:
		result.append("pair")
	if top >= 2 and second >= 2:
		result.append("two_pairs")
	if top >= 3:
		result.append("triad")
	if top >= 3 and second >= 2:
		result.append("family")
	if top >= 4:
		result.append("four")
	if top >= 5:
		result.append("ancient_word")
	if _row_start(counts) > 0:
		result.append("row")
	for kin: String in KINS:
		if _kin_count(stones, kin) >= ROW_LENGTH:
			result.append("kin")
			break
	for kin: String in KINS:
		if _chant_start(stones, kin) > 0:
			result.append("chant")
			break
	return result


static func _match(word_id: String, stones: Array[Stone]) -> Dictionary:
	var counts: Array[int] = _position_counts(stones)
	match word_id:
		"single":
			return _result(word_id, [_highest_index(stones)], "")
		"pair":
			return _groups(word_id, stones, counts, [2])
		"two_pairs":
			return _groups(word_id, stones, counts, [2, 2])
		"triad":
			return _groups(word_id, stones, counts, [3])
		"family":
			return _groups(word_id, stones, counts, [3, 2])
		"four":
			return _groups(word_id, stones, counts, [4])
		"ancient_word":
			return _groups(word_id, stones, counts, [5])
		"row":
			if stones.size() == ROW_LENGTH and _row_start(counts) > 0:
				return _result(word_id, _all_indices(stones), "")
		"kin":
			if stones.size() == ROW_LENGTH:
				for kin: String in KINS:
					if _kin_count(stones, kin) == ROW_LENGTH:
						return _result(word_id, _all_indices(stones), kin)
		"chant":
			if stones.size() == ROW_LENGTH:
				for kin: String in KINS:
					if _kin_count(stones, kin) == ROW_LENGTH and _row_start(counts) > 0:
						return _result(word_id, _all_indices(stones), kin)
	return {}


## Finds groups of equal Positions (e.g. [3, 2] = a Triad and a Pair). Scoring stones are the groups.
static func _groups(word_id: String, stones: Array[Stone], counts: Array[int], sizes: Array) -> Dictionary:
	var used_positions: Array[int] = []
	var scoring: Array[int] = []
	for group_size: Variant in sizes:
		# Highest Position first, so a Pair of 8s beats a Pair of 2s when both exist.
		var found: int = 0
		for position: int in range(MAX_POSITION, 0, -1):
			if counts[position - 1] >= int(group_size) and not used_positions.has(position):
				found = position
				break
		if found == 0:
			return {}
		used_positions.append(found)
		var taken: int = 0
		for i: int in stones.size():
			if stones[i].position == found and taken < int(group_size):
				scoring.append(i)
				taken += 1
	scoring.sort()
	return _result(word_id, scoring, "")


static func _result(word_id: String, scoring: Array, kin: String) -> Dictionary:
	var indices: Array[int] = []
	indices.assign(scoring)
	return {"word": word_id, "scoring": indices, "kin": kin}


static func _position_counts(stones: Array[Stone]) -> Array[int]:
	var counts: Array[int] = []
	counts.resize(MAX_POSITION)
	counts.fill(0)
	for stone: Stone in stones:
		if stone.position >= 1 and stone.position <= MAX_POSITION:
			counts[stone.position - 1] += 1
	return counts


## First position of 5 consecutive positions that are all present, or 0.
static func _row_start(counts: Array[int]) -> int:
	for start: int in range(1, MAX_POSITION - ROW_LENGTH + 2):
		var ok: bool = true
		for position: int in range(start, start + ROW_LENGTH):
			if counts[position - 1] == 0:
				ok = false
				break
		if ok:
			return start
	return 0


## Stones that count for this kin (Laguz counts for every kin).
static func _kin_count(stones: Array[Stone], kin: String) -> int:
	var count: int = 0
	for stone: Stone in stones:
		if stone.kin == kin or stone.rune_id == WILD_KIN_RUNE:
			count += 1
	return count


## Descântec inside a whole hand: 5 consecutive positions all available in one kin.
static func _chant_start(stones: Array[Stone], kin: String) -> int:
	var counts: Array[int] = []
	counts.resize(MAX_POSITION)
	counts.fill(0)
	for stone: Stone in stones:
		if stone.kin == kin or stone.rune_id == WILD_KIN_RUNE:
			counts[stone.position - 1] += 1
	return _row_start(counts)


static func _highest_index(stones: Array[Stone]) -> int:
	var best: int = 0
	for i: int in stones.size():
		if stones[i].position > stones[best].position:
			best = i
	return best


static func _all_indices(stones: Array[Stone]) -> Array[int]:
	var result: Array[int] = []
	for i: int in stones.size():
		result.append(i)
	return result
