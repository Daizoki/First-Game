extends RefCounted
## Applies the base spells of the rune grammar (DESIGN 3.15) to a round: the Actions turn
## a spell into a "plan" (how strong, how many times, when), then the plan's ops change the
## Cast (before the score) or the round and the exam (after it). Pure logic, no screen.
##
## A plan: {"spell", "timing", "scale", "repeats", "spread", "lasts", "lasts_factor",
##          "ripens", "gift", "price", "fizzled", "ignored" (Action ids that changed nothing),
##          "actions"}

const RoundState = preload("res://scripts/core/round_state.gd")
const Stone = preload("res://scripts/core/stone.gd")

## Values an Action may scale; counts, amounts and caps are rounded to whole numbers.
const WHOLE: Array[String] = ["amount", "count", "max"]
## Ops that change the score of the Cast itself (the rest run after the score).
const SCORE_OPS: Array[String] = [
	"res_to_one", "res_per_held", "mul_res", "add_power", "retrigger_scoring", "word_upgrade",
	"mul_res_if_five", "mul_res_if_first_cast", "ignore_rule_cast", "talisman_retrigger_left", "power_per_talisman",
]
## Ops that wait for the player's choice (RoundState.pending).
const CHOICE_OPS: Array[String] = [
	"break_chosen_money", "remove_chosen", "change_kin_chosen", "reorder_bag_top", "copy_chosen_to_bag",
	"free_swap_chosen", "draw_keep", "discard_chosen", "swap_rule", "sell_talisman_full", "transform_talisman",
	"destroy_talisman_res",
]


## What the sentence's Actions make of its spell. rng: the exam RNG (Perthro); null for a
## preview, where the gamble is not rolled (its scale stays as it is).
static func make_plan(sentence: Dictionary, spells: Dictionary, actions_data: Dictionary,
		times_cast_before: int, rng: RandomNumberGenerator) -> Dictionary:
	var spell: Dictionary = spells[sentence["spell"]]
	var numeric: bool = not (spell.get("scalable", []) as Array).is_empty()
	var single: bool = bool(spell.get("single", false))
	var plan: Dictionary = {
		"spell": sentence["spell"], "timing": spell["timing"], "scale": 1.0, "repeats": 1, "spread": false,
		"lasts": 0, "lasts_factor": 1.0, "ripens": false, "gift": false, "price": {}, "fizzled": false,
		"ignored": [] as Array[String], "actions": sentence["actions"],
	}
	for action_id: String in sentence["actions"]:
		var action: Dictionary = actions_data.get(action_id, {})
		var useful: bool = true
		match str(action.get("kind", "")):
			"spread":
				if single:
					plan["spread"] = true
					plan["scale"] = float(plan["scale"]) * float(action.get("single_factor", 0.5))
				elif numeric:
					plan["scale"] = float(plan["scale"]) * float(action.get("factor", 1.5))
				else:
					useful = false
			"twice":
				plan["repeats"] = int(plan["repeats"]) * int(action.get("count", 2))
			"lasts":
				plan["lasts"] = int(plan["lasts"]) + int(action.get("count", 2))
				plan["lasts_factor"] = float(action.get("factor", 0.5))
			"grows":
				if numeric:
					plan["scale"] = float(plan["scale"]) * (1.0 + float(action.get("percent", 50)) / 100.0 * times_cast_before)
				else:
					useful = false
			"ripens":
				if numeric and str(spell["timing"]) != "before":
					plan["ripens"] = true
					plan["scale"] = float(plan["scale"]) * float(action.get("factor", 2))
				else:
					useful = false
			"gambles":
				if numeric and rng == null:
					pass
				elif numeric:
					if rng.randf() < float(action.get("chance", 0.5)):
						plan["scale"] = float(plan["scale"]) * float(action.get("factor", 3))
					else:
						plan["fizzled"] = true
				else:
					useful = false
			"price":
				if numeric:
					plan["price"] = {"casts": int(action.get("cost_casts", 1)), "money": int(action.get("cost_money", 4))}
					plan["scale"] = float(plan["scale"]) * float(action.get("factor", 2.5))
				else:
					useful = false
			"gift":
				plan["gift"] = true
		if not useful:
			(plan["ignored"] as Array).append(action_id)
	return plan


## The spell's ops with every scalable value multiplied by `scale`. A multiplier ("factor")
## scales only its bonus part: ×1,5 at double strength is ×2.
static func scaled_ops(spell: Dictionary, scale: float) -> Array[Dictionary]:
	var scalable: Array = spell.get("scalable", [])
	var result: Array[Dictionary] = []
	for op: Dictionary in spell["ops"]:
		var copy: Dictionary = op.duplicate()
		for field: Variant in scalable:
			if not copy.has(field):
				continue
			var value: float = float(copy[field])
			if field == "factor":
				copy[field] = 1.0 + (value - 1.0) * scale
			elif WHOLE.has(str(field)):
				copy[field] = roundi(value * scale)
			else:
				copy[field] = value * scale
		result.append(copy)
	return result


## The numbers to show in the spell's effect text for this scale ({percent}, {amount}...).
static func effect_values(spell: Dictionary, scale: float = 1.0) -> Dictionary:
	var values: Dictionary = {}
	for op: Dictionary in scaled_ops(spell, scale):
		for key: Variant in op:
			if key != "op" and not values.has(key):
				values[key] = op[key]
	return values


## Score modifiers for this Cast from the plans that act before the score.
## ctx: {"cast": Array[Stone], "held": Array[Stone], "first_cast": bool}.
## Returns {"add_power", "add_res", "res_mults", "res_to_one", "retrigger_scoring", "word_upgrade"}.
static func score_mods(round_state: RoundState, plans: Array[Dictionary], ctx: Dictionary) -> Dictionary:
	var mods: Dictionary = empty_mods()
	for plan: Dictionary in plans:
		if str(plan["timing"]) != "before" or not _active(plan) or _no_examiner(round_state, plan):
			continue
		var spell: Dictionary = round_state.spell_data(plan["spell"])
		for r: int in int(plan["repeats"]):
			for op: Dictionary in scaled_ops(spell, float(plan["scale"])):
				_score_op(round_state, op, ctx, mods)
	return mods


static func empty_mods() -> Dictionary:
	return {
		"add_power": 0.0, "add_res": 0.0, "res_mults": [] as Array[float], "res_to_one": false,
		"retrigger_scoring": 0, "word_upgrade": 0, "ignore_rule": false, "talisman_retrigger_left": 0,
	}


## Everything the plans do after the score. ctx: {"word", "cast": Array[Stone],
## "scoring": Array[Stone], "power": float, "score": float}. Returns extra round score
## (High Noon). Choices go to round_state.pending.
static func after_score(round_state: RoundState, plans: Array[Dictionary], ctx: Dictionary) -> float:
	var extra_score: float = 0.0
	for plan: Dictionary in plans:
		if not (plan["price"] as Dictionary).is_empty():
			round_state.ask({"kind": "price", "spell": plan["spell"], "casts": plan["price"]["casts"],
				"money": plan["price"]["money"]})
		if not _active(plan):
			continue
		# Against the Examiner, in a round without one: only a few Coins.
		if _no_examiner(round_state, plan):
			round_state.money += int(round_state.economy_value("examiner_spell_fallback_money", 3))
			continue
		if int(plan["lasts"]) > 0:
			(round_state.carry["lasting"] as Array).append({
				"spell": plan["spell"], "scale": float(plan["scale"]) * float(plan["lasts_factor"]),
				"repeats": plan["repeats"], "rounds_left": plan["lasts"], "spread": plan["spread"],
			})
		if bool(plan["ripens"]):
			round_state.round_end_plans.append({"plan": plan, "ctx": ctx})
			continue
		extra_score += run_ops(round_state, plan, ctx, false)
	return extra_score


## Runs a plan's ops that act after the score (all of them for "after" / "later" spells, the
## non-score ones for "before" spells). Returns extra round score. `score_ops_too` runs the
## score ops as well, as round modifiers (a lasting or ripened plan has no Cast to change).
static func run_ops(round_state: RoundState, plan: Dictionary, ctx: Dictionary, score_ops_too: bool) -> float:
	var spell: Dictionary = round_state.spell_data(plan["spell"])
	var extra_score: float = 0.0
	for r: int in int(plan["repeats"]):
		for op: Dictionary in scaled_ops(spell, float(plan["scale"])):
			var kind: String = op["op"]
			if SCORE_OPS.has(kind):
				if score_ops_too:
					_queue_next_cast(round_state, op)
				continue
			if CHOICE_OPS.has(kind):
				_choice_op(round_state, plan, op)
				continue
			extra_score += _state_op(round_state, op, ctx)
	return extra_score


## A spell against the Examiner cast in a round that has none.
static func _no_examiner(round_state: RoundState, plan: Dictionary) -> bool:
	return round_state.rule.is_empty() and str(round_state.spell_data(plan["spell"]).get("target", "")) == "algiz"


static func _active(plan: Dictionary) -> bool:
	return not bool(plan["fizzled"]) and not bool(plan["gift"]) and float(plan["scale"]) > 0.0


static func _score_op(round_state: RoundState, op: Dictionary, ctx: Dictionary, mods: Dictionary) -> void:
	match str(op["op"]):
		"res_to_one":
			mods["res_to_one"] = true
		"res_per_held":
			mods["add_res"] = float(mods["add_res"]) + float(op.get("amount", 0)) * (ctx.get("held", []) as Array).size()
		"mul_res":
			(mods["res_mults"] as Array).append(float(op.get("factor", 1.0)))
		"mul_res_if_five":
			if (ctx.get("cast", []) as Array).size() >= round_state.max_selection():
				(mods["res_mults"] as Array).append(float(op.get("factor", 1.0)))
		"mul_res_if_first_cast":
			if bool(ctx.get("first_cast", false)):
				(mods["res_mults"] as Array).append(float(op.get("factor", 1.0)))
		"add_power":
			mods["add_power"] = float(mods["add_power"]) + float(op.get("amount", 0))
		"retrigger_scoring":
			mods["retrigger_scoring"] = int(mods["retrigger_scoring"]) + int(op.get("count", 0))
		"word_upgrade":
			mods["word_upgrade"] = int(mods["word_upgrade"]) + int(op.get("count", 0))
		"ignore_rule_cast":
			mods["ignore_rule"] = true
		"talisman_retrigger_left":
			mods["talisman_retrigger_left"] = int(mods.get("talisman_retrigger_left", 0)) + int(op.get("count", 0))
		"power_per_talisman":
			mods["add_power"] = float(mods["add_power"]) + float(op.get("amount", 0)) * round_state.talismans.size()


## A score op that has no Cast of its own any more applies to the next Cast instead.
static func _queue_next_cast(round_state: RoundState, op: Dictionary) -> void:
	var mods: Dictionary = round_state.next_cast_mods(0)
	_score_op(round_state, op, {"cast": [], "held": round_state.hand, "first_cast": false}, mods)


static func _state_op(round_state: RoundState, op: Dictionary, ctx: Dictionary) -> float:
	var next_round: Dictionary = round_state.carry["next_round"]
	var scoring: Array = ctx.get("scoring", [])
	match str(op["op"]):
		"reduce_target_pct":
			round_state.reduce_target(round_state.target * float(op["percent"]) / 100.0)
		"reduce_target_pct_per_scoring":
			round_state.reduce_target(round_state.target * float(op["percent"]) * scoring.size() / 100.0)
		"reduce_target_by_power":
			round_state.reduce_target(float(ctx.get("power", 0.0)) * float(op["percent"]) / 100.0)
		"lose_swap":
			round_state.swaps_left = maxi(0, round_state.swaps_left - int(op["cost"]))
		"next_round_target_pct":
			next_round["target_pct"] = float(next_round.get("target_pct", 0.0)) + float(op["cost"])
		"cast_score_pct":
			return float(ctx.get("score", 0.0)) * float(op["percent"]) / 100.0
		"add_cast":
			round_state.add_casts(int(op["count"]))
		"add_money":
			round_state.money += int(op["amount"])
		"money_per_scoring":
			round_state.money += int(op["amount"]) * scoring.size()
		"money_interest":
			var interest: int = int(op["amount"]) * (maxi(0, round_state.money) / maxi(1, int(op.get("per", 5))))
			round_state.money += mini(interest, int(op["max"]))
		"money_per_hand_stone":
			round_state.money += int(op["amount"]) * round_state.hand.size()
		"money_per_kin_in_hand":
			var count: int = 0
			for stone: Stone in round_state.hand:
				if stone.kin == str(op.get("kin", "")):
					count += 1
			round_state.money += int(op["amount"]) * count
		"lose_cast":
			round_state.casts_left = maxi(0, round_state.casts_left - int(op["cost"]))
		"money_per_cast_left_at_end":
			round_state.money_per_cast_left += int(op["amount"])
		"grow_random_bag":
			var pool: Array[Stone] = round_state.bag.stones.duplicate()
			for i: int in mini(int(op["count"]), pool.size()):
				var stone: Stone = pool.pop_at(round_state.rng.randi_range(0, pool.size() - 1))
				stone.bonus_power += int(op["amount"])
		"grow_scoring":
			for stone: Stone in scoring:
				stone.bonus_power += int(op["amount"])
		"return_cast_to_bag":
			for stone: Stone in ctx.get("cast", []):
				if round_state.bag.stones.has(stone) and not round_state.bag.draw_pile.has(stone):
					round_state.bag.put_back(stone)
		"break_random_hand":
			if not round_state.hand.is_empty():
				var stone: Stone = round_state.hand.pop_at(round_state.rng.randi_range(0, round_state.hand.size() - 1))
				round_state.bag.remove(stone)
		"copy_scoring_to_bag":
			for stone: Stone in scoring:
				for i: int in int(op["count"]):
					round_state.bag.add_copy_of(stone)
		"hand_size_bonus":
			round_state.hand_bonus += int(op["count"])
		"power_to_held":
			for stone: Stone in round_state.hand:
				stone.round_power += int(op["amount"])
		"redraw_hand":
			# The whole hand goes; a new one comes at once (also when Eihwaz repeats the Storm
			# at the start of a round, where no Cast refills the hand afterwards).
			round_state.hand.clear()
			round_state.refill()
		"add_swap":
			round_state.swaps_left += int(op["count"])
		"word_level_up":
			var word: String = str(ctx.get("word", ""))
			if not word.is_empty():
				round_state.word_levels[word] = round_state.word_level(word) + int(op["count"])
		"break_random_word_stone":
			if not scoring.is_empty():
				round_state.bag.remove(scoring[round_state.rng.randi_range(0, scoring.size() - 1)])
		"next_cast_mul_res":
			(round_state.next_cast_mods(0)["res_mults"] as Array).append(float(op["factor"]))
		"next_next_cast_mul_res":
			(round_state.next_cast_mods(1)["res_mults"] as Array).append(float(op["cost"]))
		"next_cast_add_power":
			var mods: Dictionary = round_state.next_cast_mods(0)
			mods["add_power"] = float(mods["add_power"]) + float(op["amount"])
		"carry_overflow":
			round_state.overflow_pct += float(op["percent"])
		"next_round_head_start":
			next_round["head_start_pct"] = float(next_round.get("head_start_pct", 0.0)) + float(op["percent"])
		"next_round_lose_swap":
			next_round["swaps"] = int(next_round.get("swaps", 0)) - int(op["cost"])
		"next_round_draw_extra":
			next_round["draw_extra"] = int(next_round.get("draw_extra", 0)) + int(op["count"])
		"next_round_peek":
			next_round["peek"] = maxi(int(next_round.get("peek", 0)), int(op["count"]))
		"next_round_add_cast":
			next_round["casts"] = int(next_round.get("casts", 0)) + int(op["count"])
		"cancel_rule_round":
			round_state.cancel_rule()
		"target_pct_up":
			round_state.target *= 1.0 + float(op["cost"]) / 100.0
		"cancel_rule_casts":
			round_state.rule_skip_casts += int(op["count"])
		"examiner_target_down":
			round_state.reduce_target(round_state.target * float(op["percent"]) / 100.0)
		"peek_examiners":
			round_state.carry["peek_examiners"] = maxi(int(round_state.carry.get("peek_examiners", 0)), int(op["count"]))
		"talismans_no_wear":
			round_state.talismans_no_wear = true
		"shop_rare_talisman":
			round_state.carry["shop_rare"] = int(round_state.carry.get("shop_rare", 0)) + int(op["count"])
		"shop_extra_talisman":
			round_state.carry["shop_extra"] = int(round_state.carry.get("shop_extra", 0)) + int(op["count"])
	return 0.0


## Ops that need the player's pick. A "single" spell spread by Raidho needs no pick: it
## touches every stone in hand.
static func _choice_op(round_state: RoundState, plan: Dictionary, op: Dictionary) -> void:
	var kind: String = op["op"]
	if bool(plan["spread"]):
		match kind:
			"break_chosen_money":
				for stone: Stone in round_state.hand.duplicate():
					round_state.break_stone(stone)
					round_state.money += int(op["amount"])
				return
			"copy_chosen_to_bag":
				for stone: Stone in round_state.hand:
					for i: int in maxi(1, int(op["count"])):
						round_state.bag.add_copy_of(stone)
				return
			"sell_talisman_full", "transform_talisman", "destroy_talisman_res":
				# Spread: every Talisman, at half strength (sold for half, or each one changed / destroyed).
				for slot: int in range(round_state.talismans.size() - 1, -1, -1):
					round_state.talisman_spell(kind, slot, op, 0.5)
				return
	var choice: Dictionary = {"kind": kind, "spell": plan["spell"]}
	for key: String in ["count", "amount", "cost", "factor"]:
		if op.has(key):
			choice[key] = op[key]
	round_state.ask(choice)
