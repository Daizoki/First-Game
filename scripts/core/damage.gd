extends RefCounted
## The damage of one spell (docs/PROMPT_ETAPA5.md 5.1, docs/PLAN_ETAPA5.md 5):
##   Damage = Power × Resonance × the monster's multiplier for the Element × the Target's share
## Power and Resonance come from the Element at its level; the stones of the spell (tempered
## Power, materials), the Talismans, the kin bonus and the chain add to them. The nature of the
## Element changes the hit (Rain strikes 3 times, Light against the night, Time per Cast left…).
## Records every step as an event, so the fight screen can animate it. Pure logic, no screen.

const Stone = preload("res://scripts/core/stone.gd")
const Monster = preload("res://scripts/core/monster.gd")

## Inputs (Dictionary):
##   sentence: SentenceParser sentence {spell, element, actions, target}
##   stones: Array[Stone] of the spell         held: Array[Stone] left in hand (iron)
##   plan: SpellResolver plan (scale, repeats)  index: 0 = first spell of the Cast, 1 = chained
##   element: elements.json entry               level: the Element's level (1 = base)
##   target: targets.json entry                 monster: Monster
##   talisman_effects: TalismanRules.active()    mods: SpellResolver.empty_mods() for this Cast
##   kin_bonus: bool                             casts_left_after: int (Time)
##   cast_count: stones cast                     materials: {material id: Engraving entry}
##   economy: economy.json                       bag_size: int (Toma)
##   rng: RandomNumberGenerator (null = preview: glass never breaks)
## Output: {"power", "res", "per_hit", "hits", "total", "mult", "share", "nature", "events",
##          "broken": Array[Stone]}. `total` is before the monster's Shield.
static func spell_damage(ctx: Dictionary) -> Dictionary:
	var events: Array[Dictionary] = []
	var element: Dictionary = ctx["element"]
	var target: Dictionary = ctx["target"]
	var plan: Dictionary = ctx["plan"]
	var sentence: Dictionary = ctx["sentence"]
	var level: int = maxi(1, int(ctx.get("level", 1)))
	var double: bool = bool(target.get("double_nature", false))
	var nature: String = str(element.get("nature", ""))
	var nature_value: float = float(element.get("nature_double" if double else "nature_value", 0))
	var power: float = float(element["power"]) + float(element["level_power"]) * (level - 1)
	var res: float = float(element["res"]) + float(element["level_res"]) * (level - 1)
	events.append({"type": "spell", "index": int(ctx.get("index", 0)), "spell": sentence["spell"],
		"element": sentence["element"], "level": level, "power": power, "res": res})

	# The stones of the spell: tempered Power and materials.
	var materials: Dictionary = ctx.get("materials", {})
	var res_mults: Array[float] = []
	var broken: Array[Stone] = []
	for stone: Stone in ctx.get("stones", []):
		if stone.power() != 0:
			power += stone.power()
			events.append(_bonus("add_power", stone.power(), power, res, "stone"))
		match stone.material:
			"bone":
				power += float(materials.get("bone", {}).get("value", 0))
				events.append(_bonus("add_power", materials.get("bone", {}).get("value", 0), power, res, "bone"))
			"amber":
				res += float(materials.get("amber", {}).get("value", 0))
				events.append(_bonus("add_res", materials.get("amber", {}).get("value", 0), power, res, "amber"))
			"glass":
				res_mults.append(float(materials.get("glass", {}).get("value", 1)))
				var rng: RandomNumberGenerator = ctx.get("rng")
				if rng != null and rng.randf() < float(materials.get("glass", {}).get("chance", 0)):
					broken.append(stone)
	for stone: Stone in ctx.get("held", []):
		if stone.material == "iron":
			res += float(materials.get("iron", {}).get("value", 0))
			events.append(_bonus("add_res", materials.get("iron", {}).get("value", 0), power, res, "iron"))

	# Spells that act on this Cast (the Future, the Spark…).
	var mods: Dictionary = ctx.get("mods", {})
	if float(mods.get("add_power", 0.0)) != 0.0:
		power += float(mods["add_power"])
		events.append(_bonus("add_power", mods["add_power"], power, res, "spell"))
	if float(mods.get("add_res", 0.0)) != 0.0:
		res += float(mods["add_res"])
		events.append(_bonus("add_res", mods["add_res"], power, res, "spell"))
	for factor: Variant in mods.get("res_mults", []):
		res_mults.append(float(factor))

	# Thorns: Resonance for every Action.
	if nature == "thorn":
		var actions: int = (sentence.get("actions", []) as Array).size()
		if actions > 0:
			res += nature_value * actions
			events.append(_bonus("add_res", nature_value * actions, power, res, "thorn"))

	# The Talismans, left to right (the Spark makes the leftmost act twice).
	var hits: int = 1
	if nature == "rain":
		hits = int(nature_value)
	var retrigger_left: int = int(mods.get("talisman_retrigger_left", 0))
	var effects: Array = ctx.get("talisman_effects", [])
	for n: int in effects.size():
		var effect: Dictionary = effects[n]
		var times: int = 1 + (retrigger_left if n == 0 else 0)
		for t: int in times:
			var value: float = float(effect["value"])
			match str(effect["kind"]):
				"add_power":
					power += value
				"add_res", "wearing_res", "new_spell_res":
					if value == 0.0:
						continue
					res += value
				"power_per_bag_stone":
					value = floorf(value * float(ctx.get("bag_size", 0)))
					if value == 0.0:
						continue
					power += value
				"mul_res_five":
					if int(ctx.get("cast_count", 0)) < 5:
						continue
					res *= value
				"growing_mul":
					res *= value
				"rain_hits":
					if nature != "rain":
						continue
					hits += int(value)
				_:
					continue
			events.append({"type": "talisman", "slot": effect["slot"], "kind": effect["kind"], "value": value,
				"power": power, "res": res})

	# Multipliers of Resonance: the kin bonus, glass, spells, the Sacrifice.
	var economy: Dictionary = ctx.get("economy", {})
	if bool(ctx.get("kin_bonus", false)):
		res *= float(economy.get("kin_bonus_res", 1.5))
		events.append(_bonus("mul_res", economy.get("kin_bonus_res", 1.5), power, res, "kin"))
	for factor: float in res_mults:
		res *= factor
		events.append(_bonus("mul_res", factor, power, res, "spell"))

	# The hit: Power × Resonance × the spell's strength, then the monster, the nature, the Target.
	var per_hit: float = power * res * float(plan.get("scale", 1.0))
	var monster: Monster = ctx.get("monster")
	var mult: float = 1.0
	if monster != null:
		var wave: int = 0
		if nature == "wave":
			wave = 2 if double else 1
		mult = monster.multiplier(str(sentence["element"]), wave)
		if mult != 1.0:
			events.append({"type": "mult", "value": mult, "reason": _reason(mult)})
		if nature == "light" and monster.has_tag("night"):
			mult *= nature_value
			events.append({"type": "mult", "value": nature_value, "reason": "light"})
	if nature == "time":
		var time_mult: float = 1.0 + nature_value / 100.0 * maxi(0, int(ctx.get("casts_left_after", 0)))
		if time_mult != 1.0:
			mult *= time_mult
			events.append({"type": "mult", "value": time_mult, "reason": "time"})
	var share: float = float(target.get("share", 1.0))
	if int(ctx.get("index", 0)) > 0:
		var chain: float = 1.0 + float(economy.get("chain_bonus_pct", 25)) / 100.0
		mult *= chain
		events.append({"type": "mult", "value": chain, "reason": "chain"})
	per_hit = roundf(per_hit * mult * share)
	hits *= int(plan.get("repeats", 1))
	return {
		"power": power, "res": res, "per_hit": per_hit, "hits": hits, "total": per_hit * hits, "mult": mult,
		"share": share, "nature": {"kind": nature, "value": nature_value, "double": double}, "events": events,
		"broken": broken,
	}


static func _bonus(kind: String, value: Variant, power: float, res: float, source: String) -> Dictionary:
	return {"type": "bonus", "kind": kind, "value": float(value), "power": power, "res": res, "source": source}


static func _reason(mult: float) -> String:
	if mult == Monster.IMMUNE:
		return "immune"
	if mult > 1.0:
		return "weak"
	return "resist"
