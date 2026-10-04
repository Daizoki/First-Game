extends RefCounted
## One round (DESIGN 3.2): the hand, Casts and Swaps, the target and the score, the spells of
## the rune grammar (3.15). Pure logic used by the round screen, the tests and the simulator.
##
## The order of `indices` given to preview() and cast() is the casting order (the order in
## which the player selected the stones): spells and some Voices read it. With spells off
## (the evening class before it teaches the grammar) stones are read left to right in hand.

const Stone = preload("res://scripts/core/stone.gd")
const Bag = preload("res://scripts/core/bag.gd")
const WordDetector = preload("res://scripts/core/word_detector.gd")
const Scorer = preload("res://scripts/core/scorer.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")
const SpellResolver = preload("res://scripts/core/spell_resolver.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")

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
## Spells off (the first lessons of the evening class): stones are read in hand order.
var spells_enabled: bool = true
## What spells leave for later Casts and rounds of the same exam. Stage 3 passes one
## Dictionary to every round of an exam (new_carry()).
var carry: Dictionary = {}
## The player's picks that spells wait for, oldest first (see answer()).
var pending: Array[Dictionary] = []
## Stones drawn for a pick (The Choice); they are in neither the hand nor the pile.
var offer: Array[Stone] = []
## The target when the round started (spells cannot push it below a share of it).
var target_at_start: float = 0.0
var hand_bonus: int = 0
var rng: RandomNumberGenerator
## Plans that ripen at the end of the round (Jera): [{"plan", "ctx"}].
var round_end_plans: Array[Dictionary] = []
## Wages: Coins per Cast left at the end of the round.
var money_per_cast_left: int = 0
## Provisions: share (%) of the score above the target that goes to the next round.
var overflow_pct: float = 0.0
## Casts added by spells this round (capped by economy.json).
var extra_casts: int = 0
## Clairvoyance: the next stones of the bag stay visible this round.
var peek_bonus: int = 0
## The examiner's rule this round: an entry of data/examiners.json ({} = no rule).
var rule: Dictionary = {}
## The rule stopped for the rest of the round (Ice or Strength against the Examiner).
var rule_cancelled: bool = false
## Casts the rule skips (Hail against the Examiner).
var rule_skip_casts: int = 0
var swaps_used: int = 0
## Words cast this round, in order (Morrah remembers them).
var words_cast: Array[String] = []
## The exam's Talismans, left to right (shared with ExamState): TalismanRules owned entries.
var talismans: Array = []
## Ice into the Talismans: they do not wear down this round.
var talismans_no_wear: bool = false
## The exam's Lessons and Engravings waiting to be used ({"type": "lesson" | "engraving", "id"}),
## shared with ExamState.
var consumables: Array = []

var _data: Dictionary
var _hand_size: int = 8
## Talismans a spell may turn another one into (the exam's unlocks); empty = every Talisman.
var unlocked_talismans: Array[String] = []
var _money_at_round_end: int = 0
var _once_used: Array[String] = []
## Rune ids drawn first, in this order (a fixed tutorial hand, then its next stones).
var _stacked: Array[String] = []
var _next_choice_id: int = 1


static func new_carry() -> Dictionary:
	return {
		"spell_counts": {}, "next_round": {}, "next_casts": [], "lasting": [], "scroll": {},
		"scroll_armed": false,
	}


## data: {"runes", "words", "spells", "spell_actions", "rules", "economy"} (the GameData tables),
## optionally "examiners" (for Water against the Examiner).
## options (all optional): "casts", "swaps" (override the rules), "hand" + "bag_top"
## (rune ids drawn first, in order), "bag_only" (the bag holds only those stones),
## "spells" (false: no spells this round), "carry" (the exam's carry, see new_carry()),
## "bag" (the exam's Bag, kept between rounds), "money", "word_levels" (the exam's, shared),
## "rule" (the examiner's entry; its "casts" / "swaps" override the others),
## "talismans" (the exam's owned Talismans, shared), "bonus_casts" / "bonus_swaps" / "bonus_hand"
## (the divine parent's bonus).
func setup(data: Dictionary, round_rng: RandomNumberGenerator, round_target: float, options: Dictionary = {}) -> void:
	_data = data
	rng = round_rng
	var rules: Dictionary = data["rules"]
	if options.has("bag"):
		bag = options["bag"]
	else:
		bag = Bag.new(rng)
		bag.fill_with_runes(data["runes"], int(rules.get("copies_per_rune", 2)))
	target = round_target
	money = int(options.get("money", 0))
	if options.has("word_levels"):
		word_levels = options["word_levels"]
	rule = options.get("rule", {})
	talismans = options.get("talismans", [])
	consumables = options.get("consumables", [])
	lessons_used = int(options.get("lessons_used", 0))
	unlocked_talismans.assign(options.get("unlocked_talismans", []))
	# The divine parent's bonus (bonus_casts / bonus_swaps / bonus_hand) adds to the rules; an
	# examiner's own Casts or Swaps (Aeva) replace both.
	_hand_size = maxi(1, int(rules.get("hand_size", 8)) + int(options.get("bonus_hand", 0)))
	casts_left = int(rule.get("casts", int(options.get("casts", rules.get("casts_per_round", 4)))
		+ int(options.get("bonus_casts", 0))))
	swaps_left = int(rule.get("swaps", int(options.get("swaps", rules.get("swaps_per_round", 3)))
		+ int(options.get("bonus_swaps", 0))))
	spells_enabled = bool(options.get("spells", true))
	carry = options.get("carry", new_carry())
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
	extra_casts = 0
	peek_bonus = 0
	money_per_cast_left = 0
	overflow_pct = 0.0
	_money_at_round_end = 0
	_once_used.clear()
	rule_cancelled = false
	rule_skip_casts = 0
	swaps_used = 0
	words_cast.clear()
	talismans_no_wear = false
	talismans_owned = talismans.size()
	var effects: Array[Dictionary] = talisman_effects()
	hand_bonus = int(TalismanRules.total(effects, "hand_size"))
	swaps_left += int(TalismanRules.total(effects, "round_swaps"))
	pending.clear()
	offer.clear()
	round_end_plans.clear()
	hand.clear()
	bag.reset_round()
	bag.stack_on_top(_stacked)
	var draw_extra: int = _apply_next_round()
	target_at_start = target
	hand.append_array(_draw(hand_limit() + draw_extra))
	if draw_extra > 0 and hand.size() > hand_limit():
		ask({"kind": "put_back", "count": hand.size() - hand_limit()})
	_apply_lasting()


func refill() -> void:
	hand.append_array(_draw(hand_limit() - hand.size()))


func hand_limit() -> int:
	return _hand_size + hand_bonus


func max_selection() -> int:
	return int((_data["rules"] as Dictionary).get("max_stones_per_action", 5))


func is_won() -> bool:
	return score >= target


## Lost when nothing can be cast any more (decided only once no pick is waiting).
func is_lost() -> bool:
	return pending.is_empty() and not is_won() and (casts_left <= 0 or hand.is_empty())


func can_cast(indices: Array[int]) -> bool:
	return casts_left > 0 and pending.is_empty() and _valid_selection(indices) and not is_won() \
		and _count_allowed(indices)


func can_swap(indices: Array[int]) -> bool:
	return swaps_left > 0 and pending.is_empty() and _valid_selection(indices) and not is_won() \
		and bag.remaining() > 0 and money >= swap_cost()


# --- The examiner's rule --------------------------------------------------------------------

## The Talismans that act now, left to right (Nix's Trick switches the leftmost off).
func talisman_effects() -> Array[Dictionary]:
	return TalismanRules.active(talismans, _data.get("talismans", {}), 0 if active_rule() == "trick" else -1)


## Full price of a Talisman (by rarity).
func talisman_price(id: String) -> int:
	var rarity: String = str((_data.get("talismans", {}) as Dictionary).get(id, {}).get("rarity", "common"))
	return int(_economy("price_" + rarity, 5))


## The rule in force ("" when there is none or a spell cancelled it).
func active_rule() -> String:
	return "" if rule.is_empty() or rule_cancelled else str(rule.get("rule", ""))


## Coins the next Swap costs (Ignar's Fee, Aeva's Hourglass after the free ones).
func swap_cost() -> int:
	match active_rule():
		"tax":
			return int(rule.get("swap_cost", 1))
		"hourglass":
			return int(rule.get("swap_cost", 1)) if swaps_used >= int(rule.get("free_swaps", 3)) else 0
	return 0


## How many stones Kaldor's rule wants in this Cast (0 = any number).
func required_count() -> int:
	if active_rule() != "exact_count" or rule_skip_casts > 0:
		return 0
	return mini(int(rule.get("count", 5)), hand.size())


func cancel_rule() -> void:
	rule_cancelled = true


## Water against the Examiner: the rule becomes another examiner's.
func replace_rule(examiner_id: String) -> bool:
	var examiners: Dictionary = _data.get("examiners", {})
	if not examiners.has(examiner_id):
		return false
	rule = examiners[examiner_id]
	rule_cancelled = false
	return true


func _count_allowed(indices: Array[int]) -> bool:
	var needed: int = required_count()
	return needed == 0 or indices.size() == needed or _has_algiz(_stones_at(indices))


## Does the rule touch this Cast? Not when a spell or Algiz's Voice keeps it away.
func _rule_applies(cast_stones: Array[Stone], mods: Dictionary) -> bool:
	return not active_rule().is_empty() and rule_skip_casts == 0 and not bool(mods.get("ignore_rule", false)) \
		and not _has_algiz(cast_stones)


## Algiz's Voice: a cast Algiz keeps the rule away from the Cast.
func _has_algiz(stones: Array[Stone]) -> bool:
	if not bool((_data["rules"] as Dictionary).get("rune_voices_start_awake", true)):
		return false
	for stone: Stone in stones:
		var rune: Dictionary = (_data["runes"] as Dictionary).get(stone.rune_id, {})
		for effect: Dictionary in rune.get("effects", []):
			if effect.get("trigger") != "on_cast":
				continue
			for action: Dictionary in effect["actions"]:
				if action.get("name", "") == "algiz_ignore_rule":
					return true
	return false


## Draws stones; Lunet's Dream turns the first few of every draw face down.
func _draw(count: int) -> Array[Stone]:
	var drawn: Array[Stone] = bag.draw(count)
	if active_rule() == "dream":
		for i: int in mini(int(rule.get("count", 3)), drawn.size()):
			drawn[i].face_down = true
	return drawn


## What the round screen shows while stones are selected (before casting).
func preview(selection: Array[int]) -> Dictionary:
	if not _valid_selection(selection):
		return {}
	var indices: Array[int] = _cast_order(selection)
	var selected: Array[Stone] = _stones_at(indices)
	var word: Dictionary = WordDetector.detect(selected, _data["words"])
	var word_data: Dictionary = (_data["words"] as Dictionary)[word["word"]]
	var level: int = word_level(word["word"])
	var scoring_hand: Array[int] = []
	for i: int in word["scoring"]:
		scoring_hand.append(indices[i])
	var sentence: Dictionary = _parse(selected)
	var spells: Array[String] = []
	var plan: Dictionary = {}
	if str(sentence.get("status", "")) == SentenceParser.SPELL:
		spells.append(sentence["spell"])
		plan = SpellResolver.make_plan(sentence, _data["spells"], _data["spell_actions"],
			int((carry["spell_counts"] as Dictionary).get(sentence["spell"], 0)), null)
	return {
		"word": word["word"],
		"scoring": scoring_hand,
		"power": float(word_data["base_power"]) + float(word_data["level_power"]) * (level - 1),
		"res": float(word_data["base_res"]) + float(word_data["level_res"]) * (level - 1),
		"sentence": sentence,
		"spells": spells,
		"plan": plan,
	}


## Casts the selected stones, in this order. Returns everything the screen needs to animate
## the result. If spells wait for picks afterwards, `pending` is not empty: answer them,
## then check is_won() / is_lost().
func cast(selection: Array[int]) -> Dictionary:
	if not can_cast(selection):
		return {}
	var indices: Array[int] = _cast_order(selection)
	var cast_stones: Array[Stone] = _stones_at(indices)
	var held: Array[Stone] = []
	for i: int in hand.size():
		if not indices.has(i):
			held.append(hand[i])
	var word: Dictionary = WordDetector.detect(cast_stones, _data["words"])
	var rules: Dictionary = _data["rules"]

	var sentence: Dictionary = _parse(cast_stones)
	var plans: Array[Dictionary] = []
	var spells: Array[String] = []
	if str(sentence.get("status", "")) == SentenceParser.SPELL:
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
				carry["scroll"] = {"spell": spell_id, "plan": kept}
			else:
				plan["gift"] = false
				(plan["ignored"] as Array).append("gebo")
		plans.append(plan)
	var scroll_used: String = ""
	if bool(carry["scroll_armed"]) and not (carry["scroll"] as Dictionary).is_empty():
		scroll_used = carry["scroll"]["spell"]
		plans.append(carry["scroll"]["plan"])
		carry["scroll"] = {}
		carry["scroll_armed"] = false

	var mods: Dictionary = SpellResolver.score_mods(self, plans, {
		"cast": cast_stones, "held": held, "first_cast": casts_used == 0})
	_merge_mods(mods, _take_next_cast_mods())
	if float(carry.get("trial_res_mult", 1.0)) != 1.0:
		(mods["res_mults"] as Array).append(float(carry["trial_res_mult"]))
	_lower_word_levels(plans, word["word"])
	var rule_now: String = active_rule() if _rule_applies(cast_stones, mods) else ""
	var blocked: Array[int] = []
	var zero_score: bool = false
	match rule_now:
		"lightning":
			var scoring_now: Array = word["scoring"]
			if not scoring_now.is_empty():
				blocked.append(int(scoring_now[rng.randi_range(0, scoring_now.size() - 1)]))
		"weight":
			for i: int in word["scoring"]:
				if cast_stones[i].position <= int(rule.get("max_position", 3)):
					blocked.append(i)
		"remember":
			zero_score = words_cast.has(word["word"])
		"correction":
			zero_score = (rule.get("words", []) as Array).has(word["word"])
	for stone: Stone in cast_stones:
		stone.face_down = false
	var result: Dictionary = Scorer.score_cast({
		"blocked": blocked, "zero_score": zero_score, "talisman_effects": talisman_effects(), "materials": _materials(),
		"bag_left": bag.remaining(),
		"cast": cast_stones, "held": held, "word": word, "words": _data["words"], "runes": _data["runes"],
		"word_level": word_level(word["word"]), "cast_index": casts_used, "is_last_cast": casts_left == 1,
		"voices_awake": bool(rules.get("rune_voices_start_awake", true)), "spell_mods": mods,
		"lessons_used": lessons_used, "talismans": talismans_owned, "once_used": _once_used, "rng": rng,
	})
	_once_used.assign(result["once_used"])
	score += float(result["score"])
	money += int(result["money"])
	_money_at_round_end += int(result["money_at_round_end"])
	swaps_left += int(result["swaps"])
	for grow: Dictionary in result["grow"]:
		(grow["stone"] as Stone).bonus_power += int(grow["value"])
	for source: Stone in result["copies"]:
		bag.add_copy_of(source)
	# Glass that broke while scoring leaves the bag for good.
	for broken: Stone in result["broken"]:
		bag.remove(broken)

	# The cast stones leave the hand; held stones keep their order.
	hand = held
	casts_left -= 1
	casts_used += 1
	words_cast.append(word["word"])
	if rule_skip_casts > 0:
		rule_skip_casts -= 1
	match rule_now:
		"competition":
			target *= 1.0 + float(rule.get("percent", 10)) / 100.0
		"flux":
			for stone: Stone in hand:
				bag.put_back(stone)
			hand.clear()
	refill()
	var scoring_stones: Array[Stone] = []
	for i: int in word["scoring"]:
		scoring_stones.append(cast_stones[i])
	var spell_score: float = SpellResolver.after_score(self, plans, {
		"word": word["word"], "cast": cast_stones, "scoring": scoring_stones,
		"power": result["power"], "score": result["score"]})
	score += spell_score
	refill()
	var gone: Array[String] = TalismanRules.after_cast(talismans, _data.get("talismans", {}), word["word"],
		talismans_no_wear)
	result["word"] = word["word"]
	result["cast_stones"] = cast_stones
	result["scoring"] = word["scoring"]
	result["sentence"] = sentence
	result["spells"] = spells
	result["plans"] = plans
	result["scroll_used"] = scroll_used
	result["spell_score"] = spell_score
	result["rule"] = rule_now
	result["talismans_gone"] = gone
	result["blocked"] = blocked
	result["score"] = float(result["score"]) + spell_score
	result["won"] = is_won()
	result["lost"] = is_lost()
	return result


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


## End of the round: Ingwaz grows if still in hand, Jera pays out, ripened spells (Jera
## the Action) happen, Wages pay, Provisions carry the extra score. Returns what happened.
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
	var money_before: int = money
	for entry: Dictionary in round_end_plans:
		SpellResolver.run_ops(self, entry["plan"], entry["ctx"], false)
	round_end_plans.clear()
	money += _money_at_round_end + money_per_cast_left * casts_left
	# Gold stones still in hand pay.
	for stone: Stone in hand:
		if stone.material == "gold":
			money += int(_materials().get("gold", {}).get("value", 0))
	_money_at_round_end = 0
	if overflow_pct > 0.0:
		var next_round: Dictionary = carry["next_round"]
		next_round["overflow"] = float(next_round.get("overflow", 0.0)) \
			+ maxf(0.0, score - target) * overflow_pct / 100.0
	return {"grown": grown, "money": money - money_before}


func word_level(word_id: String) -> int:
	return int(word_levels.get(word_id, 1))


func spell_data(spell_id: String) -> Dictionary:
	return (_data["spells"] as Dictionary).get(spell_id, {})


## The next stones of the bag when Kenaz is in hand or Clairvoyance is on (empty otherwise).
func kenaz_peek() -> Array[Stone]:
	var count: int = peek_bonus
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


# --- Spell helpers (SpellResolver calls these) -------------------------------------------

## Lowers the target, never below the floor from economy.json (40% of the round's start).
func reduce_target(amount: float) -> void:
	var floor_value: float = target_at_start * float(_economy("spell_target_floor_pct", 40)) / 100.0
	target = maxf(minf(target, floor_value), target - maxf(0.0, amount))


## Adds Casts from a spell, at most economy.json's limit per round.
func add_casts(count: int) -> void:
	var allowed: int = maxi(0, int(_economy("spell_max_extra_casts_per_round", 2)) - extra_casts)
	var added: int = clampi(count, 0, allowed)
	casts_left += added
	extra_casts += added


## A stone breaks: it leaves the hand and the bag for good.
func break_stone(stone: Stone) -> void:
	hand.erase(stone)
	bag.remove(stone)


## Score modifiers waiting for a later Cast (0 = the next one).
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
		choice["rules"] = _other_rules(int(choice.get("count", 2)))
		if (choice["rules"] as Array).is_empty():
			return
	pending.append(choice)


# --- The player's picks --------------------------------------------------------------------

## The pick waiting now ({} if none). "kind" says what to pick:
##   "price" {casts, money}: answer {"option": "cast" | "money"}
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


## The runes a stone can be reshaped into: the others of its Kin, by Position.
func rune_choices(stone: Stone) -> Array[String]:
	var options: Array[String] = []
	var runes: Dictionary = _data["runes"]
	for id: String in runes:
		if str(runes[id]["kin"]) == stone.kin and id != stone.rune_id:
			options.append(id)
	options.sort_custom(func(a: String, b: String) -> bool: return int(runes[a]["position"]) < int(runes[b]["position"]))
	return options


# --- Lessons and Engravings ----------------------------------------------------------------

## Uses the consumable in this slot. A Lesson raises its Word at once; an Engraving asks
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
		var word_id: String = str(lesson["word"])
		word_levels[word_id] = word_level(word_id) + 1
		lessons_used += 1
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


## The Engravings that make materials, by material id.
func _materials() -> Dictionary:
	var result: Dictionary = {}
	var engravings: Dictionary = _data.get("engravings", {})
	for id: String in engravings:
		if str(engravings[id].get("kind", "")) == "material":
			result[str(engravings[id]["material"])] = engravings[id]
	return result


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
			elif option == "cast" or option == "money":
				casts_left = maxi(0, casts_left - int(choice["casts"]))
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
					if chosen[1].rune_id == chosen[0].rune_id:
						return false
					chosen[0].bound_rune = chosen[1].rune_id
					chosen[0].bound_kin = chosen[1].kin
					chosen[0].bound_position = chosen[1].position
					break_stone(chosen[1])
				"change_rune_chosen":
					var new_rune: Dictionary = (_data["runes"] as Dictionary).get(str(reply.get("rune", "")), {})
					if new_rune.is_empty() or str(new_rune["kin"]) != chosen[0].kin:
						return false
					chosen[0].rune_id = str(new_rune["id"])
					chosen[0].position = int(new_rune["position"])
					chosen[0].base_power = int(new_rune["base_power"])
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


## A sensible answer to the current pick (the simulator, the tests, and the round screen
## until the picks have their own screen).
func auto_answer() -> Dictionary:
	var choice: Dictionary = current_choice()
	var count: int = int(choice.get("count", choice.get("cost", 1)))
	match str(choice.get("kind", "")):
		"price":
			return {"option": "money" if money >= int(choice["money"]) else "cast"}
		"break_chosen_money", "discard_chosen", "put_back", "remove_chosen", "free_swap_chosen":
			return {"stones": _weakest(count)}
		"copy_chosen_to_bag":
			return {"stones": _strongest(1)}
		"change_kin_chosen":
			var kin: String = _most_common_kin()
			var stones: Array[int] = []
			for i: int in _weakest(hand.size()):
				if hand[i].kin != kin and stones.size() < count:
					stones.append(i)
			return {"stones": stones, "kin": kin}
		"reorder_bag_top":
			var order: Array[int] = []
			for i: int in bag.peek(count).size():
				order.append(i)
			return {"order": order}
		"draw_keep":
			var best: int = 0
			for i: int in offer.size():
				if _power(offer[i]) > _power(offer[best]):
					best = i
			return {"pick": best}
		"swap_rule":
			return {"rule": (choice.get("rules", [""]) as Array)[0]}
		"sell_talisman_full", "transform_talisman", "destroy_talisman_res":
			return {"talisman": 0}
		"engrave_material":
			return {"stones": _strongest(1)}
		"bind_chosen":
			var pair: Array[int] = []
			for i: int in _strongest(hand.size()):
				if pair.size() < 2 and (pair.is_empty() or hand[i].rune_id != hand[pair[0]].rune_id):
					pair.append(i)
			return {"stones": pair}
		"change_rune_chosen":
			var weakest: Array[int] = _weakest(1)
			if weakest.is_empty():
				return {}
			var options: Array[String] = rune_choices(hand[weakest[0]])
			return {"stones": weakest, "rune": options[options.size() - 1] if not options.is_empty() else ""}
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


func _cast_order(selection: Array[int]) -> Array[int]:
	var order: Array[int] = []
	order.assign(selection)
	if not spells_enabled:
		order.sort()
	return order


func _parse(stones: Array[Stone]) -> Dictionary:
	if not spells_enabled:
		return {}
	var ids: Array[String] = []
	for stone: Stone in stones:
		ids.append(stone.rune_id)
	return SentenceParser.parse(ids, _data["runes"], _data["spells"])


## next_round from the carry: target change, head start, extra score, Swaps, Casts, peek.
## Returns how many extra stones to draw (The Tide).
func _apply_next_round() -> int:
	var next_round: Dictionary = carry["next_round"]
	target *= 1.0 + float(next_round.get("target_pct", 0.0)) / 100.0
	score = target * float(next_round.get("head_start_pct", 0.0)) / 100.0 + float(next_round.get("overflow", 0.0))
	swaps_left = maxi(0, swaps_left + int(next_round.get("swaps", 0)))
	peek_bonus = int(next_round.get("peek", 0))
	# The Tide draws extra stones to choose from, never more than economy.json allows.
	var draw_extra: int = mini(int(next_round.get("draw_extra", 0)), int(_economy("spell_max_extra_draw", 8)))
	var casts: int = int(next_round.get("casts", 0))
	carry["next_round"] = {}
	add_casts(casts)
	return draw_extra


## Eihwaz: lasting spells happen again at the start of the round, at half strength.
func _apply_lasting() -> void:
	var lasting: Array = carry["lasting"]
	for entry: Dictionary in lasting.duplicate():
		var spell: Dictionary = spell_data(entry["spell"])
		if spell.is_empty():
			lasting.erase(entry)
			continue
		var plan: Dictionary = {
			"spell": entry["spell"], "timing": spell["timing"], "scale": entry["scale"],
			"repeats": entry["repeats"], "spread": entry["spread"], "lasts": 0, "lasts_factor": 1.0,
			"ripens": false, "gift": false, "price": {}, "fizzled": false, "ignored": [], "actions": [],
		}
		SpellResolver.run_ops(self, plan, {}, true)
		entry["rounds_left"] = int(entry["rounds_left"]) - 1
		if int(entry["rounds_left"]) <= 0:
			lasting.erase(entry)


func _take_next_cast_mods() -> Dictionary:
	var queue: Array = carry["next_casts"]
	return queue.pop_front() if not queue.is_empty() else SpellResolver.empty_mods()


func _merge_mods(into: Dictionary, extra: Dictionary) -> void:
	into["add_power"] = float(into["add_power"]) + float(extra.get("add_power", 0.0))
	into["add_res"] = float(into["add_res"]) + float(extra.get("add_res", 0.0))
	(into["res_mults"] as Array).append_array(extra.get("res_mults", []))
	into["res_to_one"] = bool(into["res_to_one"]) or bool(extra.get("res_to_one", false))
	into["retrigger_scoring"] = int(into["retrigger_scoring"]) + int(extra.get("retrigger_scoring", 0))
	into["word_upgrade"] = int(into["word_upgrade"]) + int(extra.get("word_upgrade", 0))
	into["ignore_rule"] = bool(into.get("ignore_rule", false)) or bool(extra.get("ignore_rule", false))
	into["talisman_retrigger_left"] = int(into.get("talisman_retrigger_left", 0)) \
		+ int(extra.get("talisman_retrigger_left", 0))


## The Stutter: the Word loses a level before it scores (never below 1).
func _lower_word_levels(plans: Array[Dictionary], word_id: String) -> void:
	for plan: Dictionary in plans:
		if str(plan["timing"]) != "before" or bool(plan["fizzled"]) or bool(plan["gift"]):
			continue
		for r: int in int(plan["repeats"]):
			for op: Dictionary in SpellResolver.scaled_ops(spell_data(plan["spell"]), float(plan["scale"])):
				if op["op"] == "word_level_down":
					word_levels[word_id] = maxi(1, word_level(word_id) - int(op.get("cost", 1)))


## Stones leave the hand for this round (Swap, discards).
func _discard(indices: Array[int]) -> void:
	var order: Array[int] = []
	order.assign(indices)
	order.sort()
	order.reverse()
	for i: int in order:
		hand.remove_at(i)


## A value from economy.json.
func economy_value(key: String, fallback: Variant) -> Variant:
	return _economy(key, fallback)


func _economy(key: String, fallback: Variant) -> Variant:
	return (_data.get("economy", {}) as Dictionary).get(key, fallback)


## A spell into the Talismans on the one in this slot: sell it for its full price (or
## `share` of it), change it into another of the same rarity, or destroy it for ×Resonance
## for the rest of the trial.
func talisman_spell(kind: String, slot: int, op: Dictionary, share: float = 1.0) -> void:
	var owned: Dictionary = talismans[slot]
	var table: Dictionary = _data.get("talismans", {})
	match kind:
		"sell_talisman_full":
			money += roundi(float(talisman_price(str(owned["id"]))) * share)
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


## Up to `count` other examiners' ids (never the final one, never the rule in force).
func _other_rules(count: int) -> Array[String]:
	var pool: Array[String] = []
	var examiners: Dictionary = _data.get("examiners", {})
	for id: String in examiners:
		if not bool((examiners[id] as Dictionary).get("final", false)) and id != str(rule.get("id", "")):
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
	for kin: String in WordDetector.KINS:
		if not kins.has(kin):
			kins.append(kin)
	return kins


func _most_common_kin() -> String:
	var counts: Dictionary = {}
	var best: String = WordDetector.KINS[0]
	for stone: Stone in hand:
		counts[stone.kin] = int(counts.get(stone.kin, 0)) + 1
		if int(counts[stone.kin]) > int(counts.get(best, 0)):
			best = stone.kin
	return best


func _power(stone: Stone) -> int:
	return stone.base_power + stone.bonus_power


## Hand indices of the `count` weakest stones.
func _weakest(count: int) -> Array[int]:
	var order: Array[int] = []
	for i: int in hand.size():
		order.append(i)
	order.sort_custom(func(a: int, b: int) -> bool: return _power(hand[a]) < _power(hand[b]))
	return order.slice(0, mini(count, order.size()))


func _strongest(count: int) -> Array[int]:
	var order: Array[int] = _weakest(hand.size())
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
