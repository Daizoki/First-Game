extends SceneTree
## Balance simulator (Stage 5: fights against monsters, damage from spells):
##   godot --headless --script tests/simulate.gd [-- part=1|2 hands=20000 journeys=100 seed=1 parent=<id>]
## Part 1: how often a hand of 8 stones drawn from the 48 can read a spell (Element → Target,
## with up to 2 Actions between), and two spells at once.
## Part 2: whole Journeys of 8 Realms with the Night Market in between, played by a simple
## player: every Cast is the selection with the best sure damage in the preview; without a
## spell it swaps. Reports how far the Journeys get, which monsters stop them, how many Casts a
## fight takes and the damage per Cast in every Realm. parent=<id> plays every Journey as that
## parent's child (data/parents.json).

const Fixtures = preload("res://tests/fixtures.gd")
const Stone = preload("res://scripts/core/stone.gd")
const Bag = preload("res://scripts/core/bag.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")
const FightState = preload("res://scripts/core/fight_state.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const ShopLogic = preload("res://scripts/core/shop_logic.gd")

## Most stones a Cast can hold (rules "max_stones_per_action").
const MAX_STONES: int = 5


func _initialize() -> void:
	var options: Dictionary = _options()
	var data: Dictionary = Fixtures.data()
	var seed_value: int = int(options.get("seed", 1))
	var part: String = str(options.get("part", ""))
	if part.is_empty() or part == "1":
		_spell_frequencies(data, Fixtures.rng(seed_value), int(options.get("hands", 20000)))
	if part.is_empty() or part == "2":
		_journeys(data, seed_value, int(options.get("journeys", options.get("exams", 100))), str(options.get("parent", "")))
	quit()


# --- Part 1: spells in a hand ----------------------------------------------------------------

func _spell_frequencies(data: Dictionary, rng: RandomNumberGenerator, hands: int) -> void:
	var bag: Bag = Bag.new(rng)
	bag.fill_with_runes(data["runes"], int((data["rules"] as Dictionary).get("copies_per_rune", 2)))
	var one: int = 0
	var two: int = 0
	var with_action: int = 0
	for h: int in hands:
		bag.reset_round()
		var hand: Array[Stone] = bag.draw(8)
		var roles: Dictionary = _roles(hand, data)
		var elements: int = (roles["element"] as Array).size()
		var targets: int = (roles["target"] as Array).size()
		if elements >= 1 and targets >= 1:
			one += 1
			if not (roles["action"] as Array).is_empty():
				with_action += 1
		if elements >= 2 and targets >= 2:
			two += 1
	print("--- Part 1: spells in a hand of 8 (%d hands) ---" % hands)
	print("at least one spell: %.1f%%" % (100.0 * one / hands))
	print("a spell with an Action: %.1f%%" % (100.0 * with_action / hands))
	print("two spells at once: %.1f%%" % (100.0 * two / hands))


# --- Part 2: whole Journeys ------------------------------------------------------------------

func _journeys(data: Dictionary, seed_value: int, journeys: int, parent: String) -> void:
	var realms: int = (data["realms"] as Dictionary).size()
	var reached: Array[int] = []
	reached.resize(realms + 1)
	reached.fill(0)
	var stopped_by: Dictionary = {}
	var casts_by_kind: Dictionary = {"small": [], "big": [], "boss": []}
	var damage_by_realm: Array = []
	for r: int in realms:
		damage_by_realm.append([] as Array[float])
	var passed: int = 0
	var talismans_total: int = 0
	var money_total: int = 0
	for j: int in journeys:
		var exam: ExamState = ExamState.new()
		exam.setup(data, seed_value * 100003 + j, parent)
		while not exam.is_over():
			var realm: int = exam.trial_index
			var kind: String = exam.round_kind()
			var monster_id: String = exam.monster_id()
			var fight: FightState = exam.new_round()
			_play_fight(fight)
			fight.finish()
			if fight.casts_used > 0:
				(damage_by_realm[realm] as Array).append(fight.damage_dealt / fight.casts_used)
			if fight.is_won():
				(casts_by_kind[kind] as Array).append(fight.casts_used)
			var summary: Dictionary = exam.finish_round(fight)
			if not fight.is_won() and bool(summary["exam_over"]):
				stopped_by[monster_id] = int(stopped_by.get(monster_id, 0)) + 1
			if bool(summary["exam_over"]):
				break
			if not bool(summary.get("second_chance", false)):
				_shop_greedily(exam, data)
		reached[exam.trial_index + 1] += 1
		if exam.passed:
			passed += 1
		talismans_total += exam.talismans.size()
		money_total += exam.money
	print("--- Part 2: %d Journeys%s ---" % [journeys, (" as %s's child" % parent) if not parent.is_empty() else ""])
	print("passed (the Balaur beaten): %.1f%%" % (100.0 * passed / journeys))
	var lines: PackedStringArray = []
	var at_least: int = journeys
	for r: int in range(1, realms + 1):
		lines.append("R%d %.0f%%" % [r, 100.0 * at_least / journeys])
		at_least -= reached[r]
	print("reached: %s" % ", ".join(lines))
	var stops: Array = stopped_by.keys()
	stops.sort_custom(func(a: Variant, b: Variant) -> bool: return int(stopped_by[a]) > int(stopped_by[b]))
	var stop_lines: PackedStringArray = []
	for id: Variant in stops:
		stop_lines.append("%s %d" % [id, stopped_by[id]])
	print("stopped by: %s" % ", ".join(stop_lines))
	for kind: String in ["small", "big", "boss"]:
		print("Casts to win a %s fight: %.2f (of 4)" % [kind, _mean(casts_by_kind[kind])])
	var damage_lines: PackedStringArray = []
	for r: int in realms:
		damage_lines.append("R%d %s" % [r + 1, _round_text(_mean(damage_by_realm[r]))])
	print("damage per Cast: %s" % ", ".join(damage_lines))
	print("at the end: %.1f Talismans, %.1f Coins on average" % [float(talismans_total) / journeys, float(money_total) / journeys])


## Plays a fight: Engravings at once (picks answered automatically), then every Cast is the
## best sure damage the preview finds; without a spell the stones that are no part of one are
## swapped, or, with no Swaps left, the fight casts what it has.
func _play_fight(fight: FightState) -> void:
	fight.answer_all_automatically()
	while not fight.consumables.is_empty() and fight.use_consumable(0):
		fight.answer_all_automatically()
	var guard: int = 0
	while not fight.is_won() and not fight.is_lost() and guard < 60:
		guard += 1
		var best: Array[int] = _best_cast(fight)
		if best.is_empty():
			var swap: Array[int] = _useless(fight)
			if fight.swaps_left > 0 and not swap.is_empty() and fight.can_swap(swap):
				fight.swap(swap)
				fight.answer_all_automatically()
				continue
			best = _any_cast(fight)
			if best.is_empty():
				break
		fight.cast(best)
		fight.answer_all_automatically()


## The selection (in casting order) with the most sure damage; [] when no spell can be read.
func _best_cast(fight: FightState) -> Array[int]:
	var best: Array[int] = []
	var best_damage: float = 0.0
	for order: Array[int] in _candidates(fight):
		if not fight.can_cast(order):
			continue
		var preview: Dictionary = fight.preview(order)
		if preview.is_empty() or (preview["spells"] as Array).is_empty():
			continue
		var damage: float = float(preview["damage"]) + 0.25 * (float(preview["damage_max"]) - float(preview["damage"]))
		# Fewer stones on a tie: they stay in hand for the next Cast.
		if damage > best_damage or (damage == best_damage and order.size() < best.size()):
			best_damage = damage
			best = order
	return best


## Every sentence the hand can form (Element, up to 2 Actions, Target), alone or two of them in
## a row within 5 stones.
func _candidates(fight: FightState) -> Array[Array]:
	var roles: Dictionary = {"element": [], "action": [], "target": []}
	for i: int in fight.hand.size():
		var stone: Stone = fight.hand[i]
		if stone.face_down or not stone.bound_rune.is_empty():
			# A face-down or bound stone is tried on its own (its runes decide).
			(roles["element"] as Array).append(i)
			continue
		var role: String = _role_of(stone.rune_id)
		if roles.has(role):
			(roles[role] as Array).append(i)
	var singles: Array[Array] = []
	for e: Variant in roles["element"]:
		for t: Variant in roles["target"]:
			if e == t:
				continue
			singles.append([int(e), int(t)] as Array[int])
			for a: Variant in roles["action"]:
				if a == e or a == t:
					continue
				singles.append([int(e), int(a), int(t)] as Array[int])
				for b: Variant in roles["action"]:
					if b == a or b == e or b == t:
						continue
					singles.append([int(e), int(a), int(b), int(t)] as Array[int])
	var result: Array[Array] = []
	result.append_array(singles)
	for first: Array[int] in singles:
		for second: Array[int] in singles:
			if first.size() + second.size() > MAX_STONES:
				continue
			var shared: bool = false
			for i: int in second:
				if first.has(i):
					shared = true
					break
			if shared:
				continue
			var both: Array[int] = first.duplicate()
			both.append_array(second)
			result.append(both)
	return result


func _role_of(rune_id: String) -> String:
	return str((Fixtures.data()["runes"] as Dictionary).get(rune_id, {}).get("role", ""))


## Stones that are no part of any sentence in hand (all but one Element and one Target).
func _useless(fight: FightState) -> Array[int]:
	var keep_element: int = -1
	var keep_target: int = -1
	for i: int in fight.hand.size():
		var role: String = _role_of(fight.hand[i].rune_id)
		if role == "element" and keep_element < 0:
			keep_element = i
		elif role == "target" and keep_target < 0:
			keep_target = i
	var result: Array[int] = []
	for i: int in fight.hand.size():
		if i != keep_element and i != keep_target and result.size() < fight.max_selection():
			result.append(i)
	return result


## Something the fight may cast when nothing else works (the Lord's rule may want a count).
func _any_cast(fight: FightState) -> Array[int]:
	var count: int = maxi(1, fight.required_count())
	if fight.active_rule() == "min_stones":
		count = mini(fight.max_selection(), fight.hand.size())
	var selection: Array[int] = []
	for i: int in mini(count, fight.hand.size()):
		selection.append(i)
	return selection if fight.can_cast(selection) else [] as Array[int]


## The simple player's shopping: the dearest Talisman it can afford, Lessons (learned at once),
## then a Bag if Coins are left.
func _shop_greedily(exam: ExamState, data: Dictionary) -> void:
	var shop: ShopLogic = ShopLogic.new()
	shop.setup(exam, data)
	var order: Array[int] = []
	for i: int in shop.offer.size():
		order.append(i)
	order.sort_custom(func(a: int, b: int) -> bool:
		return _shop_value(shop.offer[a]) > _shop_value(shop.offer[b]))
	for i: int in order:
		if not shop.can_buy(i):
			continue
		var bought: Dictionary = shop.buy(i)
		if bought.has("pack"):
			var pack: Dictionary = bought["pack"]
			var taken: int = 0
			for item: Dictionary in pack["items"]:
				if taken < int(pack["pick"]) and shop.take_from_pack(item):
					taken += 1
	var slot: int = 0
	while slot < exam.consumables.size():
		if not exam.use_lesson(slot):
			slot += 1


func _shop_value(item: Dictionary) -> int:
	match str(item["type"]):
		"talisman":
			return 100 + int(item["price"])
		"lesson":
			return 50
		"pack":
			return 20
	return 10


# --- Helpers ---------------------------------------------------------------------------------

func _roles(hand: Array[Stone], data: Dictionary) -> Dictionary:
	var roles: Dictionary = {"element": [], "action": [], "target": []}
	for stone: Stone in hand:
		var role: String = str((data["runes"] as Dictionary).get(stone.rune_id, {}).get("role", ""))
		if roles.has(role):
			(roles[role] as Array).append(stone.rune_id)
	return roles


func _mean(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var total: float = 0.0
	for value: Variant in values:
		total += float(value)
	return total / values.size()


func _round_text(value: float) -> String:
	return str(int(roundf(value)))


func _options() -> Dictionary:
	var options: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.split("=", true, 1)
		if parts.size() == 2:
			options[parts[0]] = parts[1]
	return options
