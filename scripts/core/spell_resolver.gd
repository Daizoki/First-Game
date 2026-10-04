extends RefCounted
## The spells of a fight (docs/PROMPT_ETAPA5.md 5.4–5.5, docs/PLAN_ETAPA5.md 6): the Actions turn
## a spell into a "plan" (how strong, how many times, when), the damage comes from Damage, and
## the plan's ops are the Target's extra effect (Coins, better stones, help for the hand…).
## Pure logic, no screen.
##
## A plan: {"spell", "scale", "repeats", "overflow", "lasts", "lasts_factor", "ripens", "gift",
##          "price", "fizzled", "gamble", "actions"}

const FightState = preload("res://scripts/core/fight_state.gd")
const Stone = preload("res://scripts/core/stone.gd")

## Values an Action may scale; counts, amounts and caps are rounded to whole numbers.
const WHOLE: Array[String] = ["amount", "count", "max"]
## Ops that change the Cast they are in (they run before the damage).
const CAST_OPS: Array[String] = ["talisman_retrigger_left", "power_per_talisman", "ignore_rule_cast"]
## Ops that wait for the player's choice (FightState.pending).
const CHOICE_OPS: Array[String] = [
	"break_chosen_money", "remove_chosen", "change_kin_chosen", "reorder_bag_top", "copy_chosen_to_bag",
	"free_swap_chosen", "draw_keep", "discard_chosen", "swap_rule", "sell_talisman_full", "transform_talisman",
	"destroy_talisman_res",
]


## What the sentence's Actions make of its spell. rng: the run's RNG (Perthro); null for a
## preview, where the gamble is not rolled (the plan says "gamble": true).
static func make_plan(sentence: Dictionary, spells: Dictionary, actions_data: Dictionary,
		times_cast_before: int, rng: RandomNumberGenerator) -> Dictionary:
	var plan: Dictionary = {
		"spell": sentence["spell"], "scale": 1.0, "repeats": 1, "overflow": false, "lasts": 0, "lasts_factor": 1.0,
		"ripens": false, "ripen_factor": 1.0, "gift": false, "price": {}, "fizzled": false, "gamble": false,
		"gamble_factor": 1.0, "actions": sentence["actions"],
	}
	for action_id: String in sentence["actions"]:
		var action: Dictionary = actions_data.get(action_id, {})
		match str(action.get("kind", "")):
			"overflow":
				plan["overflow"] = true
			"twice":
				plan["repeats"] = int(plan["repeats"]) * int(action.get("count", 2))
			"lasts":
				plan["lasts"] = int(plan["lasts"]) + int(action.get("count", 2))
				plan["lasts_factor"] = float(action.get("factor", 0.5))
			"grows":
				plan["scale"] = float(plan["scale"]) * (1.0 + float(action.get("percent", 50)) / 100.0 * times_cast_before)
			"ripens":
				plan["ripens"] = true
				plan["ripen_factor"] = float(plan["ripen_factor"]) * float(action.get("factor", 2))
			"gambles":
				if rng == null:
					plan["gamble"] = true
					plan["gamble_factor"] = float(plan["gamble_factor"]) * float(action.get("factor", 3))
				elif rng.randf() < float(action.get("chance", 0.5)):
					plan["scale"] = float(plan["scale"]) * float(action.get("factor", 3))
				else:
					plan["fizzled"] = true
			"price":
				plan["price"] = {"swaps": int(action.get("cost_swaps", 1)), "money": int(action.get("cost_money", 3))}
				plan["scale"] = float(plan["scale"]) * float(action.get("factor", 2.5))
			"gift":
				plan["gift"] = true
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


static func empty_mods() -> Dictionary:
	return {
		"add_power": 0.0, "add_res": 0.0, "res_mults": [] as Array[float], "ignore_rule": false,
		"talisman_retrigger_left": 0,
	}


## Ops of these plans that change the Cast they are in, added to `mods`.
static func cast_mods(fight: FightState, plans: Array[Dictionary], mods: Dictionary) -> void:
	for plan: Dictionary in plans:
		if not is_active(plan):
			continue
		for r: int in int(plan["repeats"]):
			for op: Dictionary in scaled_ops(fight.spell_data(plan["spell"]), float(plan["scale"])):
				match str(op["op"]):
					"talisman_retrigger_left":
						mods["talisman_retrigger_left"] = int(mods["talisman_retrigger_left"]) + int(op.get("count", 0))
					"power_per_talisman":
						mods["add_power"] = float(mods["add_power"]) + float(op.get("amount", 0)) * fight.talismans.size()
					"ignore_rule_cast":
						mods["ignore_rule"] = true


## The Target's extra effect, after the damage. ctx: {"stones": Array[Stone] of the spell,
## "cast": Array[Stone] of the Cast}. Choices go to fight.pending.
static func run_ops(fight: FightState, plan: Dictionary, ctx: Dictionary) -> void:
	var spell: Dictionary = fight.spell_data(plan["spell"])
	# Against the Lord, in a fight with neither rule nor trait: only a few Coins.
	if str(spell.get("target", "")) == "algiz" and not fight.has_rule_or_trait():
		fight.money += int(fight.economy_value("algiz_fallback_money", 3))
		return
	for r: int in int(plan["repeats"]):
		for op: Dictionary in scaled_ops(spell, float(plan["scale"])):
			var kind: String = op["op"]
			if CAST_OPS.has(kind):
				continue
			if CHOICE_OPS.has(kind):
				fight.ask(_choice(plan, op))
				continue
			_state_op(fight, op, ctx)


static func is_active(plan: Dictionary) -> bool:
	return not bool(plan["fizzled"]) and not bool(plan["gift"]) and float(plan["scale"]) > 0.0


static func _choice(plan: Dictionary, op: Dictionary) -> Dictionary:
	var choice: Dictionary = {"kind": op["op"], "spell": plan["spell"]}
	for key: String in ["count", "amount", "cost", "factor"]:
		if op.has(key):
			choice[key] = op[key]
	return choice


static func _state_op(fight: FightState, op: Dictionary, ctx: Dictionary) -> void:
	var next_round: Dictionary = fight.carry["next_round"]
	var spell_stones: Array = ctx.get("stones", [])
	match str(op["op"]):
		"money_per_spell_stone":
			fight.money += int(op["amount"]) * spell_stones.size()
		"add_money":
			fight.money += int(op["amount"])
		"lose_cast":
			fight.casts_left = maxi(0, fight.casts_left - int(op["cost"]))
		"money_interest":
			var interest: int = int(op["amount"]) * (maxi(0, fight.money) / maxi(1, int(op.get("per", 5))))
			fight.money += mini(interest, int(op["max"]))
		"money_per_kin_in_hand":
			var count: int = 0
			for stone: Stone in fight.hand:
				if stone.kin == str(op.get("kin", "")):
					count += 1
			fight.money += int(op["amount"]) * count
		"money_per_hand_stone":
			fight.money += int(op["amount"]) * fight.hand.size()
		"money_per_cast_left_at_end":
			fight.money_per_cast_left += int(op["amount"])
		"grow_random_bag":
			var pool: Array[Stone] = fight.bag.stones.duplicate()
			for i: int in mini(int(op["count"]), pool.size()):
				var stone: Stone = pool.pop_at(fight.rng.randi_range(0, pool.size() - 1))
				stone.bonus_power += int(op["amount"])
		"grow_spell_stones":
			for stone: Stone in spell_stones:
				stone.bonus_power += int(op["amount"])
		"break_random_hand":
			if not fight.hand.is_empty():
				fight.break_stone(fight.hand[fight.rng.randi_range(0, fight.hand.size() - 1)])
		"return_cast_to_bag":
			for stone: Stone in ctx.get("cast", []):
				if fight.bag.stones.has(stone) and not fight.bag.draw_pile.has(stone):
					fight.bag.put_back(stone)
		"copy_spell_to_bag":
			for stone: Stone in spell_stones:
				for i: int in int(op["count"]):
					fight.bag.add_copy_of(stone)
		"hand_size_bonus":
			fight.hand_bonus += int(op["count"])
		"power_to_held":
			for stone: Stone in fight.hand:
				stone.round_power += int(op["amount"])
		"add_cast":
			fight.add_casts(int(op["count"]))
		"heart_shield":
			fight.carry["heart_shields"] = int(fight.carry.get("heart_shields", 0)) + int(op["count"])
		"redraw_hand":
			# The whole hand goes; a new one comes at once (also when a lasting spell repeats it at
			# the start of a fight, where no Cast refills the hand afterwards).
			fight.hand.clear()
			fight.refill()
		"add_swap":
			fight.swaps_left += int(op["count"])
		"element_level_up":
			fight.raise_element(str(fight.spell_data(str(ctx.get("spell", ""))).get("element", "")), int(op["count"]), true)
		"next_cast_mul_res":
			(fight.next_cast_mods(0)["res_mults"] as Array).append(float(op["factor"]))
		"next_next_cast_mul_res":
			(fight.next_cast_mods(1)["res_mults"] as Array).append(float(op["cost"]))
		"next_cast_add_power":
			var mods: Dictionary = fight.next_cast_mods(0)
			mods["add_power"] = float(mods["add_power"]) + float(op["amount"])
		"carry_overflow":
			fight.overflow_pct += float(op["percent"])
		"next_fight_monster_down":
			next_round["monster_down_pct"] = float(next_round.get("monster_down_pct", 0.0)) + float(op["percent"])
		"next_round_lose_swap":
			next_round["swaps"] = int(next_round.get("swaps", 0)) - int(op["cost"])
		"next_round_peek":
			next_round["peek"] = maxi(int(next_round.get("peek", 0)), int(op["count"]))
		"next_round_draw_extra":
			next_round["draw_extra"] = int(next_round.get("draw_extra", 0)) + int(op["count"])
		"next_round_add_cast":
			next_round["casts"] = int(next_round.get("casts", 0)) + int(op["count"])
		"talismans_no_wear":
			fight.talismans_no_wear = true
		"shop_rare_talisman":
			fight.carry["shop_rare"] = int(fight.carry.get("shop_rare", 0)) + int(op["count"])
		"shop_extra_talisman":
			fight.carry["shop_extra"] = int(fight.carry.get("shop_extra", 0)) + int(op["count"])
		"cancel_rule_round":
			fight.cancel_rule()
		"monster_heal_pct":
			fight.monster.heal_pct(float(op["cost"]))
		"monster_hp_pct":
			fight.monster_lose_pct(float(op["percent"]))
		"cancel_rule_casts":
			fight.rule_skip_casts += int(op["count"])
		"peek_examiners":
			fight.carry["peek_examiners"] = maxi(int(fight.carry.get("peek_examiners", 0)), int(op["count"]))
