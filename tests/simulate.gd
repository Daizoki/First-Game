extends SceneTree
## Balance simulator:
##   godot --headless --script tests/simulate.gd [-- hands=100000 rounds=300 seed=1]
## Part 1: how often each Word can be formed in a hand of 8 stones drawn from the 48.
## Part 2: plays whole test rounds with a simple greedy strategy and reports the scores.

const Fixtures = preload("res://tests/fixtures.gd")
const Stone = preload("res://scripts/core/stone.gd")
const Bag = preload("res://scripts/core/bag.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const RoundState = preload("res://scripts/core/round_state.gd")


func _initialize() -> void:
	var options: Dictionary = _options()
	var data: Dictionary = Fixtures.data()
	var rng: RandomNumberGenerator = Fixtures.rng(int(options.get("seed", 1)))
	_word_frequencies(data, rng, int(options.get("hands", 100000)))
	_play_rounds(data, rng, int(options.get("rounds", 300)))
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
