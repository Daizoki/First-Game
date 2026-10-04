extends RefCounted
## One fight (docs/PROMPT_ETAPA5.md 4–5): the hand, Casts and Swaps, the monster and its life,
## the spells of the rune grammar and their damage, the Lord's rule. Pure logic used by the
## fight screen, the tests and the simulator.
##
## The order of `indices` given to preview() and cast() is the casting order (the order in
## which the player selected the stones): the sentences read it. With spells off (an exam
## lesson before the grammar is taught) stones are read left to right in hand.

const Stone = preload("res://scripts/core/stone.gd")
const Bag = preload("res://scripts/core/bag.gd")
const Monster = preload("res://scripts/core/monster.gd")
const Damage = preload("res://scripts/core/damage.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")
const SpellResolver = preload("res://scripts/core/spell_resolver.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")

var bag: Bag
var hand: Array[Stone] = []
var monster: Monster
var casts_left: int = 0
var swaps_left: int = 0
var casts_used: int = 0
var money: int = 0
## Element rune id -> level (1 = base). Shared with the Journey (Lessons, Into the Voice).
var element_levels: Dictionary = {}
## Spells off (the first exam lesson): stones are read in hand order.
var spells_enabled: bool = true
## What spells leave for later Casts and fights of the same Journey (new_carry()).
var carry: Dictionary = {}
## The player's picks that spells wait for, oldest first (see answer()).
var pending: Array[Dictionary] = []
## Stones drawn for a pick (The Choice); they are in neither the hand nor the pile.
var offer: Array[Stone] = []
var hand_bonus: int = 0
var rng: RandomNumberGenerator
## Wages: Coins per Cast left at the end of the fight.
var money_per_cast_left: int = 0
## Provisions: share (%) of the damage past the monster's death that goes to the next fight.
var overflow_pct: float = 0.0
## Casts added by spells this fight (capped by economy.json).
var extra_casts: int = 0
## Clairvoyance: the next stones of the bag stay visible this fight.
var peek_bonus: int = 0
## The Lord's rule: the monster entry when it has a "rule" ({} = no rule).
var rule: Dictionary = {}
## The rule stopped for the rest of the fight (Ice or Strength upon the Lord).
var rule_cancelled: bool = false
## Casts the rule skips (Hail upon the Lord).
var rule_skip_casts: int = 0
var swaps_used: int = 0
## Spells cast this fight, in order (a Lord may remember them).
var spells_cast: Array[String] = []
## The Journey's Talismans, left to right (shared with the Journey).
var talismans: Array = []
## Ice into the Talismans: they do not wear down this fight.
var talismans_no_wear: bool = false
## Lessons and Engravings waiting to be used ({"type": "lesson" | "engraving", "id"}), shared.
var consumables: Array = []
## Life taken from the monster this fight, and the biggest single Cast.
var damage_dealt: float = 0.0
var best_cast_damage: float = 0.0
## Talismans a spell may turn another one into (the unlocks); empty = every Talisman.
var unlocked_talismans: Array[String] = []

var _data: Dictionary
var _hand_size: int = 8
var _money_at_end: int = 0
## Damage past the monster's death (Provisions).
var _overkill: float = 0.0
## Rune ids drawn first, in this order (a fixed exam hand, then its next stones).
var _stacked: Array[String] = []
var _next_choice_id: int = 1


static func new_carry() -> Dictionary:
	return {
		"spell_counts": {}, "next_round": {}, "next_casts": [], "lasting": [], "future_hits": [], "ripening": [],
		"scroll": {}, "scroll_armed": false, "ansuz_levels": {}, "heart_shields": 0,
	}


## data: the GameData tables ("runes", "elements", "targets", "spells", "spell_actions",
## "rules", "economy", optionally "talismans", "lessons", "engravings", "monsters").
## options (all optional): "casts", "swaps" (override the rules), "hand" + "bag_top"
## (rune ids drawn first, in order), "bag_only" (the bag holds only those stones),
## "spells" (false: no spells this fight), "carry" (the Journey's, see new_carry()),
## "bag" (the Journey's Bag), "money", "element_levels" (the Journey's, shared),
## "talismans", "consumables" (shared), "bonus_casts" / "bonus_swaps" / "bonus_hand"
## (the divine parent), "unlocked_talismans".
func setup(data: Dictionary, fight_rng: RandomNumberGenerator, fight_monster: Monster, options: Dictionary = {}) -> void:
	_data = data
	rng = fight_rng
	monster = fight_monster
	var rules: Dictionary = data["rules"]
	if options.has("bag"):
		bag = options["bag"]
	else:
		bag = Bag.new(rng)
		bag.fill_with_runes(data["runes"], int(rules.get("copies_per_rune", 2)))
	money = int(options.get("money", 0))
	if options.has("element_levels"):
		element_levels = options["element_levels"]
	rule = monster.entry if monster.entry.has("rule") else {}
	talismans = options.get("talismans", [])
	consumables = options.get("consumables", [])
	unlocked_talismans.assign(options.get("unlocked_talismans", []))
	_hand_size = maxi(1, int(rules.get("hand_size", 8)) + int(options.get("bonus_hand", 0)))
	casts_left = int(options.get("casts", rules.get("casts_per_round", 4))) + int(options.get("bonus_casts", 0))
	swaps_left = int(options.get("swaps", rules.get("swaps_per_round", 3))) + int(options.get("bonus_swaps", 0))
	spells_enabled = bool(options.get("spells", true))
	carry = options.get("carry", new_carry())
	for key: String in new_carry():
		if not carry.has(key):
			carry[key] = new_carry()[key]
	_stacked.clear()
	for id: Variant in options.get("hand", []):
		_stacked.append(str(id))
	for id: Variant in options.get("bag_top", []):
		_stacked.append(str(id))
	if bool(options.get("bag_only", false)):
		bag.keep_only(_stacked)


func start() -> void:
	damage_dealt = 0.0
	best_cast_damage = 0.0
	casts_used = 0
	extra_casts = 0
	peek_bonus = 0
	money_per_cast_left = 0
	overflow_pct = 0.0
	_overkill = 0.0
	_money_at_end = 0
	rule_cancelled = false
	rule_skip_casts = 0
	swaps_used = 0
	spells_cast.clear()
	talismans_no_wear = false
	var effects: Array[Dictionary] = talisman_effects()
	hand_bonus = int(TalismanRules.total(effects, "hand_size"))
	swaps_left += int(TalismanRules.total(effects, "round_swaps"))
	pending.clear()
	offer.clear()
	hand.clear()
	bag.reset_round()
	bag.stack_on_top(_stacked)
	var draw_extra: int = _apply_next_round()
	hand.append_array(_draw(hand_limit() + draw_extra))
	if draw_extra > 0 and hand.size() > hand_limit():
		ask({"kind": "put_back", "count": hand.size() - hand_limit()})


func refill() -> void:
	hand.append_array(_draw(hand_limit() - hand.size()))


func hand_limit() -> int:
	return _hand_size + hand_bonus


func max_selection() -> int:
	return int((_data["rules"] as Dictionary).get("max_stones_per_action", 5))


func is_won() -> bool:
	return monster.is_dead()


## Lost when nothing can be cast any more (decided only once no pick is waiting).
func is_lost() -> bool:
	return pending.is_empty() and not is_won() and (casts_left <= 0 or hand.is_empty())


func can_cast(indices: Array[int]) -> bool:
	return casts_left > 0 and pending.is_empty() and _valid_selection(indices) and not is_won() \
		and cast_blocked(indices).is_empty()


func can_swap(indices: Array[int]) -> bool:
	return swaps_left > 0 and pending.is_empty() and _valid_selection(indices) and not is_won() \
		and bag.remaining() > 0 and money >= swap_cost()


## Why the rule forbids this Cast ("" when it may go): "exact_count", "min_stones" or
## "need_action".
func cast_blocked(indices: Array[int]) -> String:
	match active_rule():
		"exact_count":
			if indices.size() != required_count():
				return "exact_count"
		"min_stones":
			if indices.size() < mini(int(rule.get("rule_value", 4)), hand.size()):
				return "min_stones"
		"need_action":
			var parsed: Dictionary = _parse(_stones_at(_cast_order(indices)))
			for sentence: Dictionary in parsed.get("sentences", []):
				if not (sentence["actions"] as Array).is_empty():
					return ""
			return "need_action"
	return ""


# --- The Lord's rule -----------------------------------------------------------------------

## The Talismans that act now, left to right (Nix's Trick switches the leftmost off).
func talisman_effects() -> Array[Dictionary]:
	return TalismanRules.active(talismans, _data.get("talismans", {}), 0 if active_rule() == "trick" else -1)


## Full price of a Talisman (by rarity).
func talisman_price(id: String) -> int:
	var rarity: String = str((_data.get("talismans", {}) as Dictionary).get(id, {}).get("rarity", "common"))
	return int(_economy("price_" + rarity, 5))


## The rule in force ("" when there is none, a spell stopped it or Ice froze the monster).
func active_rule() -> String:
	if rule.is_empty() or rule_cancelled or rule_skip_casts > 0 or monster.frozen > 0:
		return ""
	return str(rule.get("rule", ""))


## Is there a rule or a trait a spell upon the Lord can stop?
func has_rule_or_trait() -> bool:
	return not rule.is_empty() or monster.entry.has("trait")


## Coins the next Swap costs (the tax).
func swap_cost() -> int:
	return int(rule.get("rule_value", 1)) if active_rule() == "tax" else 0


## How many stones the rule wants in this Cast (0 = any number).
func required_count() -> int:
	if active_rule() != "exact_count":
		return 0
	return mini(int(rule.get("rule_value", 5)), hand.size())


func cancel_rule() -> void:
	rule_cancelled = true


## Water upon the Lord: the rule becomes another Lord's.
func replace_rule(monster_id: String) -> bool:
	var monsters: Dictionary = _data.get("monsters", {})
	if not monsters.has(monster_id) or not (monsters[monster_id] as Dictionary).has("rule"):
		return false
	rule = monsters[monster_id]
	rule_cancelled = false
	return true


## Draws stones; the dream turns the first few of every draw face down.
func _draw(count: int) -> Array[Stone]:
	var drawn: Array[Stone] = bag.draw(count)
	if active_rule() == "dream":
		for i: int in mini(int(rule.get("rule_value", 3)), drawn.size()):
			drawn[i].face_down = true
	return drawn


# --- Preview and Cast ------------------------------------------------------------------------

## What the fight screen shows while stones are selected: the sentences, each spell's
## estimated damage against this monster, and whether the sure damage kills ("kill").
## Returns {} for an invalid selection.
func preview(selection: Array[int]) -> Dictionary:
	if not _valid_selection(selection):
		return {}
	var indices: Array[int] = _cast_order(selection)
	var cast_stones: Array[Stone] = _stones_at(indices)
	var held: Array[Stone] = _held(indices)
	var parsed: Dictionary = _parse(cast_stones)
	var mods: Dictionary = _peek_next_cast_mods()
	var plans: Array[Dictionary] = []
	var spells: Array[Dictionary] = []
	for sentence: Dictionary in parsed["sentences"]:
		var plan: Dictionary = SpellResolver.make_plan(sentence, _data["spells"], _data["spell_actions"],
			int((carry["spell_counts"] as Dictionary).get(sentence["spell"], 0)), null)
		plans.append(plan)
	SpellResolver.cast_mods(self, plans, mods)
	var sure: float = _pending_damage()
	var most: float = sure
	for n: int in plans.size():
		var sentence: Dictionary = parsed["sentences"][n]
		var result: Dictionary = _spell_damage(sentence, plans[n], n, cast_stones, held, mods, null)
		var now: float = _against_shield(result, sentence)
		var later: bool = bool(plans[n]["ripens"]) or bool(plans[n]["gift"]) or float(result["share"]) == 0.0
		var gamble: bool = bool(plans[n]["gamble"])
		if _zero_by_rule(sentence, mods):
			now = 0.0
		var info: Dictionary = {"spell": sentence["spell"], "damage": 0.0 if later else now,
			"power": result["power"], "res": result["res"], "mult": result["mult"], "plan": plans[n],
			"later": later, "gamble": gamble, "zero": _zero_by_rule(sentence, mods)}
		if not later:
			if gamble:
				most += now * float(plans[n]["gamble_factor"])
			else:
				sure += now
				most += now
		spells.append(info)
	var spell_ids: Array[String] = []
	for info: Dictionary in spells:
		spell_ids.append(info["spell"])
	return {
		"sentence": parsed, "spells": spell_ids, "per_spell": spells, "damage": sure, "damage_max": most,
		"kill": sure >= monster.total_hp(), "kin_bonus": _kin_bonus(cast_stones),
		"plan": plans[0] if not plans.is_empty() else {}, "blocked": cast_blocked(selection),
	}


## Casts the selected stones, in this order. Returns everything the screen needs to animate the
## result. If spells wait for picks afterwards, `pending` is not empty: answer them, then check
## is_won() / is_lost().
func cast(selection: Array[int]) -> Dictionary:
	if not can_cast(selection):
		return {}
	var indices: Array[int] = _cast_order(selection)
	var cast_stones: Array[Stone] = _stones_at(indices)
	var held: Array[Stone] = _held(indices)
	var events: Array[Dictionary] = []
	var hp_before: float = monster.total_hp()
	var rule_now: String = active_rule()

	# The start of the Cast: the Burn bites, the Future arrives, lasting spells strike again.
	_start_of_cast(events)
	var ripe_now: Array = (carry["ripening"] as Array).duplicate()
	(carry["ripening"] as Array).clear()

	# The lightning strikes one stone out of the sentence.
	var struck: int = -1
	var read_stones: Array[Stone] = cast_stones.duplicate()
	if rule_now == "lightning" and not cast_stones.is_empty():
		struck = rng.randi_range(0, cast_stones.size() - 1)
		read_stones.remove_at(struck)
		events.append({"type": "rule", "kind": "struck", "index": struck})
	var parsed: Dictionary = _parse(read_stones)

	var plans: Array[Dictionary] = []
	var sentences: Array[Dictionary] = []
	var spells: Array[String] = []
	for sentence: Dictionary in parsed["sentences"]:
		var spell_id: String = sentence["spell"]
		var counts: Dictionary = carry["spell_counts"]
		var plan: Dictionary = SpellResolver.make_plan(sentence, _data["spells"], _data["spell_actions"],
			int(counts.get(spell_id, 0)), rng)
		counts[spell_id] = int(counts.get(spell_id, 0)) + 1
		spells.append(spell_id)
		if bool(plan["gift"]):
			if (carry["scroll"] as Dictionary).is_empty() and int(_economy("scroll_slots", 1)) > 0:
				var kept: Dictionary = plan.duplicate(true)
				kept["gift"] = false
				kept["price"] = {}
				carry["scroll"] = {"spell": spell_id, "plan": kept, "sentence": sentence.duplicate(true)}
			else:
				plan["gift"] = false
		plans.append(plan)
		sentences.append(sentence)
	var scroll_used: String = ""
	if bool(carry["scroll_armed"]) and not (carry["scroll"] as Dictionary).is_empty():
		scroll_used = carry["scroll"]["spell"]
		plans.append(carry["scroll"]["plan"])
		var scroll_sentence: Dictionary = (carry["scroll"]["sentence"] as Dictionary).duplicate(true)
		scroll_sentence["stones"] = [] as Array[int]
		sentences.append(scroll_sentence)
		carry["scroll"] = {}
		carry["scroll_armed"] = false

	var mods: Dictionary = _take_next_cast_mods()
	SpellResolver.cast_mods(self, plans, mods)
	if float(carry.get("trial_res_mult", 1.0)) != 1.0:
		(mods["res_mults"] as Array).append(float(carry["trial_res_mult"]))
	for stone: Stone in cast_stones:
		stone.face_down = false

	# Every spell's damage, one after the other.
	var broken: Array[Stone] = []
	var froze: bool = false
	for n: int in plans.size():
		var plan: Dictionary = plans[n]
		var sentence: Dictionary = sentences[n]
		if not (plan["price"] as Dictionary).is_empty():
			ask({"kind": "price", "spell": plan["spell"], "swaps": plan["price"]["swaps"], "money": plan["price"]["money"]})
		if not SpellResolver.is_active(plan):
			events.append({"type": "spell", "index": n, "spell": plan["spell"], "element": sentence["element"],
				"fizzled": bool(plan["fizzled"]), "gift": bool(plan["gift"]), "power": 0.0, "res": 0.0})
			continue
		var result: Dictionary = _spell_damage(sentence, plan, mini(n, 1), read_stones, held, mods, rng)
		events.append_array(result["events"])
		broken.append_array(result["broken"])
		var target: Dictionary = _target_entry(sentence["target"])
		if float(target.get("future_share", 0.0)) > 0.0:
			# Into the Future: nothing now, double on the next Cast.
			var future: Dictionary = target.duplicate()
			future["share"] = target["future_share"]
			var later: Dictionary = _spell_damage(sentence, plan, mini(n, 1), read_stones, held, mods, null, future)
			(carry["future_hits"] as Array).append(_queued(later, sentence))
			events.append({"type": "later", "kind": "future", "amount": later["total"]})
		elif bool(plan["ripens"]):
			var ripe: Dictionary = _queued(result, sentence)
			ripe["amount"] = float(ripe["amount"]) * float(plan["ripen_factor"])
			(carry["ripening"] as Array).append(ripe)
			events.append({"type": "later", "kind": "ripen", "amount": ripe["amount"]})
		elif _zero_by_rule(sentence, mods):
			events.append({"type": "rule", "kind": "zero"})
		else:
			_hit(result, sentence, n, plan, events)
			# The nature comes with the hit (an immune monster feels nothing of the Element).
			if float(result["mult"]) > 0.0:
				froze = _apply_nature(result, sentence, events) or froze
		if int(plan["lasts"]) > 0:
			var lasting: Dictionary = _queued(result, sentence)
			lasting["amount"] = float(lasting["amount"]) * float(plan["lasts_factor"])
			lasting["casts_left"] = int(plan["lasts"])
			(carry["lasting"] as Array).append(lasting)
		if float(target.get("level_up", 0)) > 0:
			raise_element(sentence["element"], int(target["level_up"]), true)
	for item: Variant in ripe_now:
		var ripe: Dictionary = item
		events.append({"type": "tick", "kind": "ripen", "amount": monster.take_hit(float(ripe["amount"]),
			bool(ripe.get("ignore_shield", false))), "hp": monster.hp, "head": monster.head})
	# Glass that broke leaves the bag for good.
	for stone: Stone in broken:
		bag.remove(stone)

	# The cast stones leave the hand; held stones keep their order.
	hand = held
	casts_left -= 1
	casts_used += 1
	spells_cast.append_array(spells)
	if rule_skip_casts > 0:
		rule_skip_casts -= 1
	match rule_now:
		"flux":
			for stone: Stone in hand:
				bag.put_back(stone)
			hand.clear()
		"heal":
			if not monster.is_dead():
				monster.heal_pct(float(rule.get("rule_value", 10)))
		"stone_to_hagalaz":
			if not hand.is_empty():
				var turned: Stone = hand[rng.randi_range(0, hand.size() - 1)]
				turned.rune_id = "hagalaz"
				turned.kin = str((_data["runes"] as Dictionary).get("hagalaz", {}).get("kin", turned.kin))
	refill()
	for n: int in plans.size():
		if SpellResolver.is_active(plans[n]):
			var spell_stones: Array[Stone] = []
			for i: Variant in sentences[n].get("stones", []):
				spell_stones.append(read_stones[int(i)])
			SpellResolver.run_ops(self, plans[n], {"stones": spell_stones, "cast": cast_stones, "spell": plans[n]["spell"]})
	refill()
	if not froze and monster.frozen > 0:
		monster.frozen -= 1
	var gone: Array[String] = TalismanRules.after_cast(talismans, _data.get("talismans", {}), spells, talismans_no_wear)
	if spells.size() >= 2:
		money += int(TalismanRules.total(talisman_effects(), "chain_money"))
	var dealt: float = maxf(0.0, hp_before - monster.total_hp())
	damage_dealt += dealt
	best_cast_damage = maxf(best_cast_damage, dealt)
	events.append({"type": "total", "damage": dealt, "hp": monster.hp, "head": monster.head})
	return {
		"events": events, "damage": dealt, "cast_stones": cast_stones, "sentence": parsed, "spells": spells,
		"plans": plans, "scroll_used": scroll_used, "rule": rule_now, "struck": struck, "talismans_gone": gone,
		"won": is_won(), "lost": is_lost(),
	}


## Swaps the selected stones for new ones from the bag.
func swap(indices: Array[int]) -> bool:
	if not can_swap(indices):
		return false
	money -= swap_cost()
	swaps_used += 1
	_discard(indices)
	swaps_left -= 1
	refill()
	return true


## End of the fight: Wages and gold stones pay, Provisions carry the extra damage. Returns
## {"money": Coins gained}.
func finish() -> Dictionary:
	var money_before: int = money
	money += _money_at_end + money_per_cast_left * maxi(0, casts_left)
	for stone: Stone in hand:
		if stone.material == "gold":
			money += int(_materials().get("gold", {}).get("value", 0))
	_money_at_end = 0
	if overflow_pct > 0.0 and is_won():
		var next_round: Dictionary = carry["next_round"]
		next_round["overflow_damage"] = float(next_round.get("overflow_damage", 0.0)) + _overkill * overflow_pct / 100.0
	return {"money": money - money_before}


func element_level(element_id: String) -> int:
	return int(element_levels.get(element_id, 1))


## The Element gains levels (a Lesson; into the Voice, which stops at the cap per Journey).
func raise_element(element_id: String, levels: int, from_voice: bool = false) -> void:
	if element_id.is_empty() or levels <= 0:
		return
	if from_voice:
		var raised: Dictionary = carry["ansuz_levels"]
		var room: int = int(_economy("ansuz_level_cap", 3)) - int(raised.get(element_id, 0))
		levels = mini(levels, maxi(0, room))
		if levels <= 0:
			return
		raised[element_id] = int(raised.get(element_id, 0)) + levels
	element_levels[element_id] = element_level(element_id) + levels


func spell_data(spell_id: String) -> Dictionary:
	return (_data["spells"] as Dictionary).get(spell_id, {})


## The next stones of the bag while Clairvoyance is on (empty otherwise).
func peek() -> Array[Stone]:
	if peek_bonus <= 0:
		var none: Array[Stone] = []
		return none
	return bag.peek(peek_bonus)


## Groups the hand by role (Elements, Actions, Targets), then by Kin.
func sort_by_role() -> void:
	var order: Array[String] = ["element", "action", "target"]
	hand.sort_custom(func(a: Stone, b: Stone) -> bool:
		var ra: int = order.find(_role(a.rune_id))
		var rb: int = order.find(_role(b.rune_id))
		return ra < rb if ra != rb else a.kin < b.kin)


func sort_by_kin() -> void:
	var order: Array[String] = ["element", "action", "target"]
	hand.sort_custom(func(a: Stone, b: Stone) -> bool:
		return a.kin < b.kin if a.kin != b.kin else order.find(_role(a.rune_id)) < order.find(_role(b.rune_id)))


## Drag and drop inside the hand.
func move_stone(from: int, to: int) -> void:
	if from < 0 or from >= hand.size():
		return
	var stone: Stone = hand[from]
	hand.remove_at(from)
	hand.insert(clampi(to, 0, hand.size()), stone)


# --- Helpers the spells call -----------------------------------------------------------------

## Adds Casts from a spell, at most economy.json's limit per fight.
func add_casts(count: int) -> void:
	var allowed: int = maxi(0, int(_economy("spell_max_extra_casts_per_round", 2)) - extra_casts)
	var added: int = clampi(count, 0, allowed)
	casts_left += added
	extra_casts += added


## A stone breaks: it leaves the hand and the bag for good.
func break_stone(stone: Stone) -> void:
	hand.erase(stone)
	bag.remove(stone)


## The monster loses a share of its life (a Lord never more than boss_pct_cap % at once).
func monster_lose_pct(percent: float) -> void:
	monster.lose_pct(percent, float(_economy("boss_pct_cap", 50)))


## Modifiers waiting for a later Cast (0 = the next one).
func next_cast_mods(index: int) -> Dictionary:
	var queue: Array = carry["next_casts"]
	while queue.size() <= index:
		queue.append(SpellResolver.empty_mods())
	return queue[index]


## A spell waits for the player's pick.
func ask(choice: Dictionary) -> void:
	choice["id"] = _next_choice_id
	_next_choice_id += 1
	if str(choice["kind"]) == "draw_keep":
		offer = bag.draw(int(choice.get("count", 1)))
	if str(choice["kind"]) in ["sell_talisman_full", "transform_talisman", "destroy_talisman_res"] \
			and talismans.is_empty():
		return
	if str(choice["kind"]) == "swap_rule":
		choice["rules"] = _other_rules(int(choice.get("count", 3)))
		if (choice["rules"] as Array).is_empty() or rule.is_empty():
			return
	pending.append(choice)


# --- The player's picks --------------------------------------------------------------------

## The pick waiting now ({} if none). "kind" says what to pick:
##   "price" {swaps, money}: answer {"option": "swap" | "money"}
##   "break_chosen_money" / "discard_chosen" / "put_back": exactly `count` (or `cost`) stones
##   "remove_chosen" / "free_swap_chosen": up to `count` stones
##   "change_kin_chosen": up to `count` stones and a kin: {"stones", "kin"}
##   "copy_chosen_to_bag": one stone
##   "reorder_bag_top": {"order": positions in bag.peek(count), first drawn first}
##   "draw_keep": {"pick": index in `offer`}
## Stones are hand indices: {"stones": [2, 5]}.
func current_choice() -> Dictionary:
	return pending[0] if not pending.is_empty() else {}


## What the current kind of pick takes, for the screen that asks it:
##   {"source": "option"} (price), {"source": "hand", "min", "max", "kin": bool},
##   {"source": "bag_top", "count"} (reorder), {"source": "offer"} (draw_keep).
func pick_limits(choice: Dictionary) -> Dictionary:
	var count: int = int(choice.get("count", choice.get("cost", 1)))
	match str(choice.get("kind", "")):
		"price":
			return {"source": "option"}
		"break_chosen_money", "discard_chosen", "put_back":
			var exact: int = mini(count, hand.size())
			return {"source": "hand", "min": exact, "max": exact, "kin": false}
		"copy_chosen_to_bag":
			var one: int = mini(1, hand.size())
			return {"source": "hand", "min": one, "max": one, "kin": false}
		"remove_chosen", "free_swap_chosen":
			return {"source": "hand", "min": 0, "max": count, "kin": false}
		"change_kin_chosen":
			return {"source": "hand", "min": 0, "max": count, "kin": true}
		"reorder_bag_top":
			return {"source": "bag_top", "count": bag.peek(count).size()}
		"draw_keep":
			return {"source": "offer"}
		"swap_rule":
			return {"source": "rule"}
		"engrave_material":
			var one_stone: int = mini(1, hand.size())
			return {"source": "hand", "min": one_stone, "max": one_stone, "kin": false}
		"bind_chosen":
			var two: int = mini(2, hand.size())
			return {"source": "hand", "min": two, "max": two, "kin": false}
		"change_rune_chosen":
			var one: int = mini(1, hand.size())
			return {"source": "hand", "min": one, "max": one, "kin": false, "rune": true}
		"sell_talisman_full", "transform_talisman", "destroy_talisman_res":
			return {"source": "talisman"}
	return {}


## The runes a stone can be reshaped into: the others with the same role.
func rune_choices(stone: Stone) -> Array[String]:
	var options: Array[String] = []
	var runes: Dictionary = _data["runes"]
	for id: String in runes:
		if _role(id) == _role(stone.rune_id) and id != stone.rune_id:
			options.append(id)
	return options


# --- Lessons and Engravings ----------------------------------------------------------------

## Uses the consumable in this slot. A Lesson raises its Element at once; an Engraving asks
## which stones in hand it changes (a pick, see current_choice()). Returns false if it
## cannot be used now.
func use_consumable(slot: int) -> bool:
	if slot < 0 or slot >= consumables.size() or not pending.is_empty():
		return false
	var item: Dictionary = consumables[slot]
	if str(item["type"]) == "lesson":
		var lesson: Dictionary = (_data.get("lessons", {}) as Dictionary).get(str(item["id"]), {})
		if lesson.is_empty():
			return false
		raise_element(str(lesson["element"]), 1)
		consumables.remove_at(slot)
		return true
	var engraving: Dictionary = (_data.get("engravings", {}) as Dictionary).get(str(item["id"]), {})
	if engraving.is_empty() or hand.is_empty():
		return false
	var choice: Dictionary = {"engraving": str(item["id"]), "count": int(engraving.get("count", 1))}
	match str(engraving["kind"]):
		"material":
			choice["kind"] = "engrave_material"
			choice["material"] = str(engraving["material"])
		"bind":
			if hand.size() < 2:
				return false
			choice["kind"] = "bind_chosen"
		"change_rune":
			choice["kind"] = "change_rune_chosen"
		"copy_stone":
			choice["kind"] = "copy_chosen_to_bag"
		"remove_stones":
			choice["kind"] = "remove_chosen"
		"change_kin":
			choice["kind"] = "change_kin_chosen"
	consumables.remove_at(slot)
	ask(choice)
	return true


## The kins a stone can be moved to (Water into the Bag).
func kin_choices() -> Array[String]:
	return _kins()


## Drops the current pick without its effect (nothing fits any more); drawn stones go back.
func skip_choice() -> void:
	if pending.is_empty():
		return
	for stone: Stone in offer:
		bag.put_back(stone)
	offer.clear()
	pending.pop_front()
	refill()


## Answers the current pick. Returns false (and changes nothing) if the answer does not fit.
func answer(reply: Dictionary) -> bool:
	var choice: Dictionary = current_choice()
	if choice.is_empty():
		return false
	var kind: String = choice["kind"]
	var picked: Array[int] = []
	for i: Variant in reply.get("stones", []):
		picked.append(int(i))
	var count: int = int(choice.get("count", choice.get("cost", 1)))
	match kind:
		"price":
			var option: String = str(reply.get("option", ""))
			if option == "money" and money >= int(choice["money"]):
				money -= int(choice["money"])
			elif option == "swap" or option == "money":
				swaps_left = maxi(0, swaps_left - int(choice["swaps"]))
			else:
				return false
		"engrave_material", "bind_chosen", "change_rune_chosen":
			var wanted: int = int(pick_limits(choice)["max"])
			if not _valid_picks(picked) or picked.size() != wanted or wanted == 0:
				return false
			var chosen: Array[Stone] = _stones_at(picked)
			match kind:
				"engrave_material":
					chosen[0].material = str(choice.get("material", ""))
				"bind_chosen":
					if not chosen[0].bound_rune.is_empty() or not chosen[1].bound_rune.is_empty():
						return false
					chosen[0].bound_rune = chosen[1].rune_id
					chosen[0].bound_kin = chosen[1].kin
					break_stone(chosen[1])
				"change_rune_chosen":
					var new_id: String = str(reply.get("rune", ""))
					if not rune_choices(chosen[0]).has(new_id):
						return false
					chosen[0].rune_id = new_id
					chosen[0].kin = str((_data["runes"] as Dictionary)[new_id]["kin"])
		"break_chosen_money", "discard_chosen", "put_back", "copy_chosen_to_bag":
			var needed: int = 1 if kind == "copy_chosen_to_bag" else mini(count, hand.size())
			if not _valid_picks(picked) or picked.size() != needed:
				return false
			var stones: Array[Stone] = _stones_at(picked)
			match kind:
				"break_chosen_money":
					for stone: Stone in stones:
						break_stone(stone)
						money += int(choice.get("amount", 0))
				"discard_chosen":
					_discard(picked)
				"put_back":
					for stone: Stone in stones:
						hand.erase(stone)
						bag.put_back(stone)
				"copy_chosen_to_bag":
					for i: int in count:
						bag.add_copy_of(stones[0])
		"remove_chosen", "free_swap_chosen", "change_kin_chosen":
			if not _valid_picks(picked) or picked.size() > count:
				return false
			var kin: String = str(reply.get("kin", ""))
			if kind == "change_kin_chosen" and not picked.is_empty() and not _kins().has(kin):
				return false
			var stones: Array[Stone] = _stones_at(picked)
			match kind:
				"remove_chosen":
					for stone: Stone in stones:
						break_stone(stone)
				"free_swap_chosen":
					_discard(picked)
				"change_kin_chosen":
					for stone: Stone in stones:
						stone.kin = kin
		"reorder_bag_top":
			var top: Array[Stone] = bag.peek(count)
			var order: Array = reply.get("order", [])
			if order.size() != top.size():
				return false
			var seen: Array[int] = []
			for i: Variant in order:
				if int(i) < 0 or int(i) >= top.size() or seen.has(int(i)):
					return false
				seen.append(int(i))
			for stone: Stone in top:
				bag.draw_pile.erase(stone)
			for n: int in range(order.size() - 1, -1, -1):
				bag.draw_pile.append(top[int(order[n])])
		"sell_talisman_full", "transform_talisman", "destroy_talisman_res":
			var slot: int = int(reply.get("talisman", -1))
			if slot < 0 or slot >= talismans.size():
				return false
			talisman_spell(kind, slot, choice)
		"swap_rule":
			var picked_rule: String = str(reply.get("rule", ""))
			if not (choice.get("rules", []) as Array).has(picked_rule) or not replace_rule(picked_rule):
				return false
		"draw_keep":
			var pick: int = int(reply.get("pick", -1))
			if offer.is_empty():
				pass
			elif pick < 0 or pick >= offer.size():
				return false
			else:
				hand.append(offer[pick])
				for i: int in offer.size():
					if i != pick:
						bag.put_back(offer[i])
			offer.clear()
	pending.pop_front()
	if kind != "put_back" and kind != "draw_keep":
		refill()
	return true


## A sensible answer to the current pick (the simulator and the tests).
func auto_answer() -> Dictionary:
	var choice: Dictionary = current_choice()
	var count: int = int(choice.get("count", choice.get("cost", 1)))
	match str(choice.get("kind", "")):
		"price":
			return {"option": "money" if money >= int(choice["money"]) else "swap"}
		"break_chosen_money", "discard_chosen", "put_back", "remove_chosen", "free_swap_chosen":
			return {"stones": _least_useful(count)}
		"copy_chosen_to_bag", "engrave_material":
			return {"stones": _most_useful(1)}
		"change_kin_chosen":
			var kin: String = _most_common_kin()
			var stones: Array[int] = []
			for i: int in hand.size():
				if hand[i].kin != kin and stones.size() < count:
					stones.append(i)
			return {"stones": stones, "kin": kin}
		"reorder_bag_top":
			var order: Array[int] = []
			for i: int in bag.peek(count).size():
				order.append(i)
			return {"order": order}
		"draw_keep":
			return {"pick": 0}
		"swap_rule":
			return {"rule": (choice.get("rules", [""]) as Array)[0]}
		"sell_talisman_full", "transform_talisman", "destroy_talisman_res":
			return {"talisman": 0}
		"bind_chosen":
			var pair: Array[int] = []
			for i: int in hand.size():
				if pair.size() < 2 and hand[i].bound_rune.is_empty() \
						and (pair.is_empty() or hand[i].rune_id != hand[pair[0]].rune_id):
					pair.append(i)
			return {"stones": pair}
		"change_rune_chosen":
			var least: Array[int] = _least_useful(1)
			if least.is_empty():
				return {}
			var options: Array[String] = rune_choices(hand[least[0]])
			return {"stones": least, "rune": options[0] if not options.is_empty() else ""}
	return {}


## Answers every waiting pick with auto_answer().
func answer_all_automatically() -> void:
	var guard: int = 0
	while not pending.is_empty() and guard < 100:
		if not answer(auto_answer()):
			skip_choice()
		guard += 1


# --- The Scroll (Gebo) ---------------------------------------------------------------------

func has_scroll() -> bool:
	return not (carry["scroll"] as Dictionary).is_empty()


## The spell kept on the Scroll ("" if none).
func scroll_spell() -> String:
	return str((carry["scroll"] as Dictionary).get("spell", ""))


## The Scroll's spell happens together with the next Cast.
func use_scroll() -> bool:
	if not has_scroll():
		return false
	carry["scroll_armed"] = true
	return true


## Puts the Scroll back to waiting (it will not happen with the next Cast).
func disarm_scroll() -> void:
	carry["scroll_armed"] = false


func scroll_armed() -> bool:
	return bool(carry["scroll_armed"]) and has_scroll()


## A value from economy.json.
func economy_value(key: String, fallback: Variant) -> Variant:
	return _economy(key, fallback)


## A spell into the Talismans on the one in this slot: sell it for its full price, change it
## into another of the same rarity, or destroy it for ×Resonance for the rest of the Realm.
func talisman_spell(kind: String, slot: int, op: Dictionary) -> void:
	var owned: Dictionary = talismans[slot]
	var table: Dictionary = _data.get("talismans", {})
	match kind:
		"sell_talisman_full":
			money += talisman_price(str(owned["id"]))
			talismans.remove_at(slot)
		"transform_talisman":
			var rarity: String = str(table.get(owned["id"], {}).get("rarity", ""))
			var pool: Array[String] = []
			for id: String in table:
				if str(table[id].get("rarity", "")) == rarity and id != str(owned["id"]) \
						and (unlocked_talismans.is_empty() or unlocked_talismans.has(id)):
					pool.append(id)
			if not pool.is_empty():
				talismans[slot] = TalismanRules.make(pool[rng.randi_range(0, pool.size() - 1)], table)
		"destroy_talisman_res":
			talismans.remove_at(slot)
			carry["trial_res_mult"] = float(carry.get("trial_res_mult", 1.0)) * float(op.get("factor", 1.5))


# --- Inside the Cast -------------------------------------------------------------------------

## One spell's damage (see Damage.spell_damage). `target_override` replaces the Target entry.
func _spell_damage(sentence: Dictionary, plan: Dictionary, index: int, cast_stones: Array[Stone],
		held: Array[Stone], mods: Dictionary, damage_rng: RandomNumberGenerator,
		target_override: Dictionary = {}) -> Dictionary:
	var stones: Array[Stone] = []
	for i: Variant in sentence.get("stones", []):
		if int(i) < cast_stones.size():
			stones.append(cast_stones[int(i)])
	return Damage.spell_damage({
		"sentence": sentence, "stones": stones, "held": held, "plan": plan, "index": index,
		"element": (_data["elements"] as Dictionary).get(sentence["element"], {}),
		"level": element_level(sentence["element"]),
		"target": target_override if not target_override.is_empty() else _target_entry(sentence["target"]),
		"monster": monster, "talisman_effects": talisman_effects(), "mods": mods,
		"kin_bonus": _kin_bonus(cast_stones), "casts_left_after": casts_left - 1, "cast_count": cast_stones.size(),
		"materials": _materials(), "economy": _data.get("economy", {}), "bag_size": bag.size(), "rng": damage_rng,
	})


## The spell's hits land on the monster (the Shield takes its part unless Strength crushes it;
## a Lord small but stubborn takes at most a share of its life from one spell).
func _hit(result: Dictionary, sentence: Dictionary, index: int, plan: Dictionary, events: Array[Dictionary]) -> void:
	var ignore_shield: bool = str((result["nature"] as Dictionary).get("kind", "")) == "crush"
	var cap: float = INF
	if active_rule() == "max_hit_pct":
		cap = monster.max_hp * float(rule.get("rule_value", 30)) / 100.0
	var taken_total: float = 0.0
	for h: int in int(result["hits"]):
		var amount: float = minf(float(result["per_hit"]), maxf(0.0, cap - taken_total))
		var taken: float = monster.take_hit(amount, ignore_shield)
		taken_total += taken
		events.append({"type": "hit", "index": index, "amount": taken, "raw": result["per_hit"],
			"hp": monster.hp, "max_hp": monster.max_hp, "head": monster.head, "element": sentence["element"]})
		if monster.is_dead():
			break
	if monster.is_dead():
		var extra: float = float(result["total"]) - taken_total
		_overkill += maxf(0.0, extra)
		if bool(plan["overflow"]) and extra > 0.0:
			var next_round: Dictionary = carry["next_round"]
			next_round["overflow_damage"] = float(next_round.get("overflow_damage", 0.0)) + extra


## The Element's nature after its hits: Burn stacks, Freeze, a crushed Shield. Returns true
## when the monster was frozen now.
func _apply_nature(result: Dictionary, sentence: Dictionary, events: Array[Dictionary]) -> bool:
	var nature: Dictionary = result["nature"]
	var element: Dictionary = (_data["elements"] as Dictionary).get(sentence["element"], {})
	match str(nature["kind"]):
		"burn":
			var stacks: int = int(element.get("max_stacks", 3)) + int(TalismanRules.total(talisman_effects(), "burn_stacks"))
			monster.add_burn(float(nature["value"]), stacks)
			events.append({"type": "nature", "kind": "burn", "value": monster.burn_stacks})
		"freeze":
			monster.frozen = maxi(monster.frozen, int(nature["value"]))
			events.append({"type": "nature", "kind": "freeze", "value": nature["value"]})
			return true
		"crush":
			if bool(nature["double"]) and monster.shield > 0.0:
				monster.shield_broken = true
				events.append({"type": "nature", "kind": "shield_broken", "value": 0})
	return false


## The Burn, the Future and lasting spells, at the start of a Cast.
func _start_of_cast(events: Array[Dictionary]) -> void:
	var burned: float = monster.tick_burn()
	if burned > 0.0:
		events.append({"type": "tick", "kind": "burn", "amount": burned, "hp": monster.hp, "head": monster.head})
	var future: Array = carry["future_hits"]
	for item: Variant in future:
		var hit: Dictionary = item
		events.append({"type": "tick", "kind": "future", "amount": monster.take_hit(float(hit["amount"]),
			bool(hit.get("ignore_shield", false))), "hp": monster.hp, "head": monster.head})
	future.clear()
	var lasting: Array = carry["lasting"]
	for item: Variant in lasting.duplicate():
		var hit: Dictionary = item
		events.append({"type": "tick", "kind": "lasting", "amount": monster.take_hit(float(hit["amount"]),
			bool(hit.get("ignore_shield", false))), "hp": monster.hp, "head": monster.head})
		hit["casts_left"] = int(hit["casts_left"]) - 1
		if int(hit["casts_left"]) <= 0:
			lasting.erase(hit)


## Damage that will land at the start of the next Cast anyway (for the preview).
func _pending_damage() -> float:
	var total: float = monster.burn_per_stack * monster.burn_stacks
	for key: String in ["future_hits", "lasting"]:
		for item: Variant in carry[key]:
			total += float((item as Dictionary)["amount"])
	for item: Variant in carry["ripening"]:
		total += float((item as Dictionary)["amount"])
	return total


## A spell kept for later: its damage now, and whether it crushes the Shield.
func _queued(result: Dictionary, sentence: Dictionary) -> Dictionary:
	return {"amount": result["total"], "element": sentence["element"],
		"ignore_shield": str((result["nature"] as Dictionary).get("kind", "")) == "crush"}


## The damage that gets through the Shield (for the preview).
func _against_shield(result: Dictionary, sentence: Dictionary) -> float:
	if str((result["nature"] as Dictionary).get("kind", "")) == "crush" or monster.shield_broken:
		return float(result["total"])
	return maxf(0.0, float(result["per_hit"]) - monster.shield) * int(result["hits"])


## The Lord's rule makes this spell do no damage (an old spell remembered, a simple spell).
func _zero_by_rule(sentence: Dictionary, mods: Dictionary) -> bool:
	if bool(mods.get("ignore_rule", false)):
		return false
	match active_rule():
		"remember_spell":
			return spells_cast.has(str(sentence["spell"]))
		"simple_no_damage":
			return (sentence.get("actions", []) as Array).is_empty()
	return false


## All cast stones (at least kin_min_stones) of one Kin: ×Resonance for every spell.
func _kin_bonus(cast_stones: Array[Stone]) -> bool:
	if cast_stones.size() < int(_economy("kin_min_stones", 3)):
		return false
	for stone: Stone in cast_stones:
		if stone.kin != cast_stones[0].kin:
			return false
	return true


func _target_entry(target_id: String) -> Dictionary:
	return (_data["targets"] as Dictionary).get(target_id, {"share": 1.0})


func _role(rune_id: String) -> String:
	return str((_data["runes"] as Dictionary).get(rune_id, {}).get("role", ""))


func _cast_order(selection: Array[int]) -> Array[int]:
	var order: Array[int] = []
	order.assign(selection)
	if not spells_enabled:
		order.sort()
	return order


## The sentences of these stones (a forbidden Element's spells do not form).
func _parse(stones: Array[Stone]) -> Dictionary:
	if not spells_enabled:
		return {"status": SentenceParser.NONE, "sentences": [] as Array[Dictionary], "spell": "", "parts": [] as Array[String],
			"element": "", "actions": [] as Array[String], "target": "", "indices": [] as Array[int], "unused": [] as Array[int]}
	var runes: Array = []
	for stone: Stone in stones:
		runes.append(stone.runes() if not stone.bound_rune.is_empty() else stone.rune_id)
	var parsed: Dictionary = SentenceParser.parse(runes, _data["runes"], _data["spells"],
		int(_economy("max_spells_per_cast", 2)))
	if active_rule() == "no_element":
		var forbidden: String = str(rule.get("rule_element", ""))
		var kept: Array[Dictionary] = []
		for sentence: Dictionary in parsed["sentences"]:
			if str(sentence["element"]) != forbidden:
				kept.append(sentence)
		if kept.size() != (parsed["sentences"] as Array).size():
			parsed["sentences"] = kept
			parsed["forbidden"] = true
			if kept.is_empty():
				parsed["status"] = SentenceParser.NONE
				parsed["spell"] = ""
	return parsed


## next_round from the carry: the monster weakened, Swaps, Casts, peek. Returns how many extra
## stones to draw (The Tide).
func _apply_next_round() -> int:
	var next_round: Dictionary = carry["next_round"]
	var down: float = float(next_round.get("monster_down_pct", 0.0))
	if down > 0.0:
		monster.lose_pct(down, float(_economy("boss_pct_cap", 50)))
	var overflow: float = float(next_round.get("overflow_damage", 0.0))
	if overflow > 0.0:
		monster.take_hit(overflow, true)
	swaps_left = maxi(0, swaps_left + int(next_round.get("swaps", 0)))
	peek_bonus = int(next_round.get("peek", 0))
	var draw_extra: int = mini(int(next_round.get("draw_extra", 0)), int(_economy("spell_max_extra_draw", 8)))
	var casts: int = int(next_round.get("casts", 0))
	carry["next_round"] = {}
	add_casts(casts)
	return draw_extra


func _take_next_cast_mods() -> Dictionary:
	var queue: Array = carry["next_casts"]
	var mods: Dictionary = queue.pop_front() if not queue.is_empty() else SpellResolver.empty_mods()
	return mods.duplicate(true)


func _peek_next_cast_mods() -> Dictionary:
	var queue: Array = carry["next_casts"]
	return (queue[0] as Dictionary).duplicate(true) if not queue.is_empty() else SpellResolver.empty_mods()


## Stones leave the hand for this fight (Swap, discards).
func _discard(indices: Array[int]) -> void:
	var order: Array[int] = []
	order.assign(indices)
	order.sort()
	order.reverse()
	for i: int in order:
		hand.remove_at(i)


func _economy(key: String, fallback: Variant) -> Variant:
	return (_data.get("economy", {}) as Dictionary).get(key, fallback)


## The Engravings that make materials, by material id.
func _materials() -> Dictionary:
	var result: Dictionary = {}
	var engravings: Dictionary = _data.get("engravings", {})
	for id: String in engravings:
		if str(engravings[id].get("kind", "")) == "material":
			result[str(engravings[id]["material"])] = engravings[id]
	return result


## Up to `count` other Lords' rules (never the final one, never the rule in force).
func _other_rules(count: int) -> Array[String]:
	var pool: Array[String] = []
	var monsters: Dictionary = _data.get("monsters", {})
	for id: String in monsters:
		var entry: Dictionary = monsters[id]
		if entry.has("rule") and not bool(entry.get("final", false)) and id != str(rule.get("id", "")):
			pool.append(id)
	var picked: Array[String] = []
	while picked.size() < count and not pool.is_empty():
		picked.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return picked


func _kins() -> Array[String]:
	var kins: Array[String] = []
	for stone: Stone in bag.stones:
		if not kins.has(stone.kin):
			kins.append(stone.kin)
	for id: String in (_data.get("kins", {}) as Dictionary):
		if not kins.has(id):
			kins.append(id)
	for kin: String in ["fehu", "hagalaz", "tiwaz"]:
		if not kins.has(kin):
			kins.append(kin)
	return kins


func _most_common_kin() -> String:
	var counts: Dictionary = {}
	var best: String = hand[0].kin if not hand.is_empty() else "fehu"
	for stone: Stone in hand:
		counts[stone.kin] = int(counts.get(stone.kin, 0)) + 1
		if int(counts[stone.kin]) > int(counts.get(best, 0)):
			best = stone.kin
	return best


## How much a stone is worth keeping: Elements and Targets above Actions, then tempered Power.
func _usefulness(stone: Stone) -> int:
	var by_role: Dictionary = {"element": 20, "target": 15, "action": 10}
	return int(by_role.get(_role(stone.rune_id), 0)) + stone.power()


func _least_useful(count: int) -> Array[int]:
	var order: Array[int] = []
	for i: int in hand.size():
		order.append(i)
	order.sort_custom(func(a: int, b: int) -> bool: return _usefulness(hand[a]) < _usefulness(hand[b]))
	return order.slice(0, mini(count, order.size()))


func _most_useful(count: int) -> Array[int]:
	var order: Array[int] = _least_useful(hand.size())
	order.reverse()
	return order.slice(0, mini(count, order.size()))


func _valid_picks(indices: Array[int]) -> bool:
	for i: int in indices:
		if i < 0 or i >= hand.size() or indices.count(i) > 1:
			return false
	return true


func _valid_selection(indices: Array[int]) -> bool:
	if indices.is_empty() or indices.size() > max_selection():
		return false
	return _valid_picks(indices)


## The stones at these hand indices, in this order.
func _stones_at(indices: Array[int]) -> Array[Stone]:
	var stones: Array[Stone] = []
	for i: int in indices:
		stones.append(hand[i])
	return stones


func _held(indices: Array[int]) -> Array[Stone]:
	var held: Array[Stone] = []
	for i: int in hand.size():
		if not indices.has(i):
			held.append(hand[i])
	return held
