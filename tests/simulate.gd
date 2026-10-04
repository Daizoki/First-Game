extends SceneTree
## Balance simulator:
##   godot --headless --script tests/simulate.gd [-- hands=100000 rounds=300 seed=1]
## Part 1: how often each Word can be formed in a hand of 8 stones drawn from the 48.
## Part 2: plays whole test rounds with a simple greedy strategy and reports the scores.
## Part 3 (the rune grammar's balance): exams of 3 rounds (the spells' carry goes on) played
## three ways: spells off, greedy (spells only by chance) and spell-seeking. Reports how
## often a Cast holds a spell, the win rate, how often the 40% target floor is reached and,
## per spell, how much it moved the round compared with a Cast without a spell.
##   part=3 runs only Part 3 (exams=150 by default).

const Fixtures = preload("res://tests/fixtures.gd")
const Stone = preload("res://scripts/core/stone.gd")
const Bag = preload("res://scripts/core/bag.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const RoundState = preload("res://scripts/core/round_state.gd")


func _initialize() -> void:
	var options: Dictionary = _options()
	var data: Dictionary = Fixtures.data()
	var rng: RandomNumberGenerator = Fixtures.rng(int(options.get("seed", 1)))
	if str(options.get("part", "")) != "3":
		_word_frequencies(data, rng, int(options.get("hands", 100000)))
		_play_rounds(data, rng, int(options.get("rounds", 300)))
	_spell_balance(data, int(options.get("seed", 1)), int(options.get("exams", 150)))
	quit()


func _word_frequencies(data: Dictionary, rng: RandomNumberGenerator, hands: int) -> void:
	var words: Dictionary = data["words"]
	var available: Dictionary = {}
	var best: Dictionary = {}
	for id: String in words:
		available[id] = 0
		best[id] = 0
	var bag: Bag = Bag.new(rng)
	bag.fill_with_runes(data["runes"], int((data["rules"] as Dictionary)["copies_per_rune"]))
	var hand_size: int = int((data["rules"] as Dictionary)["hand_size"])
	for h: int in hands:
		bag.reset_round()
		var found: Array[String] = WordDetector.available_in_hand(bag.draw(hand_size))
		var top: String = "single"
		for id: String in found:
			available[id] += 1
			if int(words[id]["rank"]) > int(words[top]["rank"]):
				top = id
		best[top] += 1
	print("")
	print("== Words in a hand of %d stones (%d hands) ==" % [hand_size, hands])
	print("%-14s %5s %10s %10s %12s" % ["word", "rank", "possible", "best", "power x res"])
	for id: String in _by_rank(words):
		var word: Dictionary = words[id]
		print("%-14s %5d %9.2f%% %9.2f%% %6d x %-4s" % [
			id, int(word["rank"]), 100.0 * available[id] / hands, 100.0 * best[id] / hands,
			int(word["base_power"]), str(word["base_res"])])


func _play_rounds(data: Dictionary, rng: RandomNumberGenerator, rounds: int) -> void:
	var target: float = float((data["rules"] as Dictionary)["test_round_target"])
	var totals: Array[float] = []
	var best_cast: float = 0.0
	var spells_seen: Dictionary = {}
	for r: int in rounds:
		var round_state: RoundState = RoundState.new()
		round_state.setup(data, rng, 1.0e12)
		round_state.start()
		while round_state.casts_left > 0 and not round_state.hand.is_empty():
			var choice: Array[int] = _best_choice(round_state)
			if round_state.swaps_left > 0 and _weak(round_state, choice):
				round_state.swap(_non_scoring(round_state, choice))
				continue
			var result: Dictionary = round_state.cast(choice)
			round_state.answer_all_automatically()
			best_cast = maxf(best_cast, float(result["score"]))
			for id: String in result["spells"]:
				spells_seen[id] = int(spells_seen.get(id, 0)) + 1
		totals.append(round_state.score)
	totals.sort()
	var passed: int = 0
	for total: float in totals:
		if total >= target:
			passed += 1
	print("")
	print("== Greedy test rounds (%d rounds, target %d) ==" % [rounds, int(target)])
	print("score per round: min %d · 25%% %d · median %d · 75%% %d · max %d" % [
		int(totals[0]), int(totals[rounds / 4]), int(totals[rounds / 2]), int(totals[rounds * 3 / 4]),
		int(totals[rounds - 1])])
	print("rounds that reach the target: %.1f%%" % (100.0 * passed / rounds))
	print("best single cast: %d" % int(best_cast))
	print("spells cast by chance: %s" % str(spells_seen))


# --- Part 3: the rune grammar -------------------------------------------------------------

## Harder than the practice round, so that about half of the rounds are won without spells.
const EXAM_TARGETS: Array[float] = [1800.0, 1800.0, 1800.0]
## The seeking strategy casts a spell when its Word is worth at least this share of the best Word.
const SEEK_SHARE: float = 0.5


func _spell_balance(data: Dictionary, seed_value: int, exams: int) -> void:
	print("")
	print("== The rune grammar: %d exams of %d rounds (targets %s) ==" % [exams, EXAM_TARGETS.size(), str(EXAM_TARGETS)])
	print("%-10s %8s %8s %10s %12s %12s %10s" % ["strategy", "won", "median", "casts w/", "floor hit", "money/round", "picks"])
	var report: Dictionary = {}
	for strategy: String in ["off", "greedy", "seek", "seek2"]:
		var stats: Dictionary = _play_exams(data, Fixtures.rng(seed_value), exams, strategy)
		report[strategy] = stats
		var rounds: int = int(stats["rounds"])
		var scores: Array[float] = stats["progress"]
		scores.sort()
		print("%-10s %7.1f%% %7.2fx %9.1f%% %11.1f%% %12.1f %10d" % [strategy, 100.0 * stats["won"] / rounds,
			scores[scores.size() / 2], 100.0 * stats["spell_casts"] / maxi(1, int(stats["casts"])),
			100.0 * stats["floor_rounds"] / rounds, float(stats["money"]) / rounds, int(stats["picks"])])
	print("  won = rounds that reach the target; median = final score / target; casts w/ = Casts that hold a spell;")
	print("  floor hit = rounds where spells pushed the target to its 40% floor; seek2 = seeking, at most 2 spells a round")
	_spell_table(data, report["seek"])


## Plays `exams` exams with one strategy: "off" (no spells), "greedy" (the best Word, spells by
## chance), "seek" (a spell whenever its Word is not much worse), "seek2" (seek, 2 a round).
func _play_exams(data: Dictionary, rng: RandomNumberGenerator, exams: int, strategy: String) -> Dictionary:
	var stats: Dictionary = {"rounds": 0, "won": 0, "casts": 0, "spell_casts": 0, "floor_rounds": 0, "money": 0,
		"picks": 0, "progress": [] as Array[float], "spells": {}, "plain_gain": 0.0, "plain_casts": 0}
	for e: int in exams:
		var carry: Dictionary = RoundState.new_carry()
		for target: float in EXAM_TARGETS:
			var state: RoundState = RoundState.new()
			state.setup(data, rng, target, {"spells": strategy != "off", "carry": carry})
			state.start()
			state.answer_all_automatically()
			var spells_this_round: int = 0
			var floor_hit: bool = false
			while state.casts_left > 0 and not state.hand.is_empty() and not state.is_won():
				var limit: int = 2 if strategy == "seek2" else 99
				var seek: bool = strategy.begins_with("seek") and spells_this_round < limit
				var order: Array[int] = _seeking_choice(state, seek, strategy != "greedy" and not seek)
				var preview: Dictionary = state.preview(order)
				if state.swaps_left > 0 and _weak(state, order) and (preview["spells"] as Array).is_empty():
					state.swap(_non_scoring(state, order))
					continue
				var before: Dictionary = {"progress": state.score / state.target, "money": state.money,
					"casts": state.casts_left, "target": state.target, "bag": state.bag.size()}
				var result: Dictionary = state.cast(order)
				stats["picks"] = int(stats["picks"]) + state.pending.size()
				state.answer_all_automatically()
				var gain: float = state.score / state.target - float(before["progress"])
				stats["casts"] = int(stats["casts"]) + 1
				var floor_value: float = state.target_at_start * 0.4
				if state.target <= floor_value + 0.01 and not floor_hit:
					floor_hit = true
				if (result["spells"] as Array).is_empty():
					stats["plain_gain"] = float(stats["plain_gain"]) + gain
					stats["plain_casts"] = int(stats["plain_casts"]) + 1
					continue
				spells_this_round += 1
				stats["spell_casts"] = int(stats["spell_casts"]) + 1
				var id: String = result["spells"][0]
				var entry: Dictionary = stats["spells"].get(id, {"count": 0, "gain": 0.0, "money": 0, "casts": 0,
					"target": 0.0, "bag": 0})
				entry["count"] = int(entry["count"]) + 1
				entry["gain"] = float(entry["gain"]) + gain
				entry["money"] = int(entry["money"]) + state.money - int(before["money"])
				entry["casts"] = int(entry["casts"]) + state.casts_left - int(before["casts"]) + 1
				entry["target"] = float(entry["target"]) + 1.0 - state.target / float(before["target"])
				entry["bag"] = int(entry["bag"]) + state.bag.size() - int(before["bag"])
				stats["spells"][id] = entry
			state.finish()
			stats["rounds"] = int(stats["rounds"]) + 1
			stats["money"] = int(stats["money"]) + state.money
			(stats["progress"] as Array[float]).append(state.score / state.target)
			if state.is_won():
				stats["won"] = int(stats["won"]) + 1
			if floor_hit:
				stats["floor_rounds"] = int(stats["floor_rounds"]) + 1
	return stats


## The casting order to play. Plain: the greedy Word in hand order. Seeking: among orders whose
## first stones form a spell (Element, up to one Action from the hand, Target), the one with the
## best Word, if it is worth at least SEEK_SHARE of the plain best. no_spell: avoid spells.
func _seeking_choice(state: RoundState, seek: bool, no_spell: bool) -> Array[int]:
	var best: Array[int] = [0]
	var best_value: float = -1.0
	var best_spell: Array[int] = []
	var best_spell_value: float = -1.0
	for subset: Array[int] in _subsets(state.hand.size(), state.max_selection()):
		var plain: float = _word_value(state, subset)
		if plain > best_value and not (no_spell and _has_spell(state, subset)):
			best_value = plain
			best = subset
		if not seek:
			continue
		for order: Array[int] in _spell_orders(state, subset):
			if plain > best_spell_value:
				best_spell_value = plain
				best_spell = order
	if seek and not best_spell.is_empty() and best_spell_value >= best_value * SEEK_SHARE:
		return best_spell
	return best


func _word_value(state: RoundState, subset: Array[int]) -> float:
	var preview: Dictionary = state.preview(subset)
	var power: float = float(preview["power"])
	for i: int in preview["scoring"]:
		power += state.hand[i].base_power
	return power * float(preview["res"])


func _has_spell(state: RoundState, order: Array[int]) -> bool:
	return not (state.preview(order)["spells"] as Array).is_empty()


## Orders of this subset that start with a spell: Element, then (if the subset holds one) an
## Action, then a Target, then the rest. Only enabled spells count.
func _spell_orders(state: RoundState, subset: Array[int]) -> Array[Array]:
	var orders: Array[Array] = []
	var runes: Dictionary = Fixtures.data()["runes"]
	for e: int in subset:
		if runes[state.hand[e].rune_id]["role"] != "element":
			continue
		for t: int in subset:
			if runes[state.hand[t].rune_id]["role"] != "target":
				continue
			var middle: Array[int] = []
			for a: int in subset:
				if runes[state.hand[a].rune_id]["role"] == "action" and middle.is_empty():
					middle.append(a)
			var order: Array[int] = [e]
			order.append_array(middle)
			order.append(t)
			for i: int in subset:
				if not order.has(i):
					order.append(i)
			if _has_spell(state, order):
				orders.append(order)
	return orders


func _spell_table(data: Dictionary, stats: Dictionary) -> void:
	var spells: Dictionary = stats["spells"]
	var plain: float = float(stats["plain_gain"]) / maxi(1, int(stats["plain_casts"]))
	print("")
	print("== Spells under the seeking strategy (a Cast without a spell moves the round %.2f of its target) ==" % plain)
	print("%-16s %-18s %6s %8s %7s %7s %8s %6s  %s" % ["id", "name", "casts", "gain", "x plain", "money", "target-", "bag", "verdict"])
	var ids: Array[String] = []
	ids.assign(spells.keys())
	ids.sort_custom(func(a: String, b: String) -> bool:
		return float(spells[a]["gain"]) / int(spells[a]["count"]) > float(spells[b]["gain"]) / int(spells[b]["count"]))
	for id: String in ids:
		var entry: Dictionary = spells[id]
		var n: int = int(entry["count"])
		var gain: float = float(entry["gain"]) / n
		var ratio: float = gain / maxf(0.001, plain)
		var money: float = float(entry["money"]) / n
		var verdict: String = ""
		if ratio >= 2.0:
			verdict = "STRONG"
		elif ratio < 0.8 and money < 2.0 and float(entry["target"]) / n < 0.01:
			verdict = "weak now (may pay later)"
		print("%-16s %-18s %6d %8.3f %7.2f %7.1f %7.1f%% %6.1f  %s" % [id, str(data["spells"][id]["name"]["ro"]), n,
			gain, ratio, money, 100.0 * float(entry["target"]) / n, float(entry["bag"]) / n, verdict])
	var never: Array[String] = []
	for id: String in data["spells"]:
		if bool(data["spells"][id].get("enabled", false)) and not spells.has(id):
			never.append(id)
	print("never cast: %s" % str(never))


## Greedy: the selection (1..5 stones) whose Word preview gives the most Power × Resonance.
func _best_choice(round_state: RoundState) -> Array[int]:
	var best: Array[int] = [0]
	var best_value: float = -1.0
	for subset: Array[int] in _subsets(round_state.hand.size(), round_state.max_selection()):
		var preview: Dictionary = round_state.preview(subset)
		var power: float = float(preview["power"])
		for i: int in preview["scoring"]:
			power += round_state.hand[i].base_power
		var value: float = power * float(preview["res"])
		if value > best_value:
			best_value = value
			best = subset
	return best


## A Pair or worse is "weak": swap the stones that do not score.
func _weak(round_state: RoundState, choice: Array[int]) -> bool:
	var word: String = round_state.preview(choice)["word"]
	return (word == "single" or word == "pair") and round_state.bag.remaining() > 0


func _non_scoring(round_state: RoundState, choice: Array[int]) -> Array[int]:
	var scoring: Array = round_state.preview(choice)["scoring"]
	var result: Array[int] = []
	for i: int in round_state.hand.size():
		if not scoring.has(i) and result.size() < round_state.max_selection():
			result.append(i)
	return result


func _subsets(count: int, max_size: int) -> Array[Array]:
	var result: Array[Array] = []
	for mask: int in range(1, 1 << count):
		var subset: Array[int] = []
		for i: int in count:
			if mask & (1 << i):
				subset.append(i)
		if subset.size() <= max_size:
			result.append(subset)
	return result


func _by_rank(words: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	ids.assign(words.keys())
	ids.sort_custom(func(a: String, b: String) -> bool: return int(words[a]["rank"]) < int(words[b]["rank"]))
	return ids


func _options() -> Dictionary:
	var options: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=")
		if parts.size() == 2:
			options[parts[0]] = parts[1]
	return options
