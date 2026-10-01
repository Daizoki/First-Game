extends RefCounted
## Scores one Cast step by step (DESIGN 3.3) and records every step as an event, so the
## round screen can animate it. Pure logic: runs in tests and in the simulator.
##
## Steps: 1) the Word gives base Power and Resonance (by level), 2) scoring stones left to
## right add their Power and trigger their Voice, 3) stones held in hand (Isaz),
## 4) Talismans (Stage 3), 5) Score = Power × Resonance.

const Stone = preload("res://scripts/core/stone.gd")

## Inputs (Dictionary):
##   cast: Array[Stone] in hand order      held: Array[Stone] left in hand
##   word: result of WordDetector.detect   words, runes: data tables
##   word_level: int                       cast_index: int (0 = first Cast of the round)
##   is_last_cast: bool                    voices_awake: bool
##   res_mult: float (Star spell, from the previous Cast)
##   lessons_used, talismans: int          once_used: Array[String] (rune ids, this round)
##   rng: RandomNumberGenerator
## Output (Dictionary): events, power, res, score, money, money_at_round_end, swaps,
##   grow (Array of {stone, value}), copies (Array[Stone]), once_used, ignore_rule
static func score_cast(ctx: Dictionary) -> Dictionary:
	var state: Dictionary = {
		"ctx": ctx, "events": [], "power": 0.0, "res": 0.0, "money": 0, "money_at_round_end": 0,
		"swaps": 0, "grow": [], "copies": [], "once_used": (ctx.get("once_used", []) as Array).duplicate(),
		"ignore_rule": false,
	}
	var cast: Array[Stone] = ctx["cast"]
	var word: Dictionary = ctx["word"]
	var scoring: Array[int] = word["scoring"]
	var voices: bool = ctx.get("voices_awake", true)

	# Step 1: the Word, with Ansuz-like level bonuses from its scoring stones.
	var level: int = int(ctx.get("word_level", 1))
	if voices:
		for i: int in scoring:
			level += int(_sum_actions(ctx, cast[i], "in_word", "word_level_bonus"))
	var word_data: Dictionary = (ctx["words"] as Dictionary)[word["word"]]
	state["power"] = float(word_data["base_power"]) + float(word_data["level_power"]) * (level - 1)
	state["res"] = float(word_data["base_res"]) + float(word_data["level_res"]) * (level - 1)
	_event(state, {"type": "word", "word": word["word"], "level": level})

	if voices:
		for i: int in cast.size():
			for effect: Dictionary in _effects(ctx, cast[i], "on_cast"):
				for action: Dictionary in effect["actions"]:
					if action.get("name", "") == "algiz_ignore_rule":
						state["ignore_rule"] = true

	# Step 2: scoring stones, left to right. Ehwaz adds extra triggers to the stone on its right.
	var extra: Dictionary = {}
	for n: int in scoring.size():
		var times: int = 1 + int(extra.get(n, 0))
		var t: int = 0
		while t < times:
			var retrigger: Dictionary = _score_stone(state, cast, scoring, n, voices, t == 0)
			times += int(retrigger.get("self", 0))
			if retrigger.get("right", 0) > 0 and n + 1 < scoring.size():
				extra[n + 1] = int(extra.get(n + 1, 0)) + int(retrigger["right"])
			t += 1

	# Step 3: stones held in hand.
	if voices:
		var held: Array[Stone] = ctx.get("held", [] as Array[Stone])
		for j: int in held.size():
			for effect: Dictionary in _effects(ctx, held[j], "on_held"):
				if _conditions_ok(state, effect, -1):
					_apply_actions(state, effect, held[j], {"type": "held", "index": j})

	# Steps 4-5: Talismans arrive in Stage 3; carried bonuses (Star) apply before the total.
	var res_mult: float = float(ctx.get("res_mult", 1.0))
	if res_mult != 1.0:
		state["res"] = float(state["res"]) * res_mult
		_event(state, {"type": "bonus", "kind": "mul_res", "value": res_mult})
	state["score"] = float(state["power"]) * float(state["res"])
	_event(state, {"type": "total", "score": state["score"]})
	state.erase("ctx")
	return state


## One scoring trigger of one stone. Returns {"self": n, "right": n} retriggers it asked for.
static func _score_stone(state: Dictionary, cast: Array[Stone], scoring: Array[int], n: int,
		voices: bool, first_time: bool) -> Dictionary:
	var ctx: Dictionary = state["ctx"]
	var index: int = scoring[n]
	var stone: Stone = cast[index]
	var power: float = float(stone.base_power) * _base_power_mult(ctx, stone) + float(stone.bonus_power)
	state["power"] = float(state["power"]) + power
	_event(state, {"type": "stone", "index": index, "power_add": power})
	var retrigger: Dictionary = {}
	if not voices:
		return retrigger
	var effects: Array[Dictionary] = _effects(ctx, stone, "on_score")
	# Gebo: copies the Voice of the scoring stone on its left (never another Gebo).
	if _has_special(effects, "gebo_copy_left") and n > 0:
		var left: Stone = cast[scoring[n - 1]]
		if left.rune_id != stone.rune_id:
			effects.append_array(_effects(ctx, left, "on_score"))
	for effect: Dictionary in effects:
		if not _conditions_ok(state, effect, n, stone):
			continue
		var asked: Dictionary = _apply_actions(state, effect, stone, {"type": "voice", "index": index})
		if first_time:
			retrigger["self"] = int(retrigger.get("self", 0)) + int(asked.get("self", 0))
		retrigger["right"] = int(retrigger.get("right", 0)) + int(asked.get("right", 0))
	return retrigger


## Applies the actions of one effect; returns the retriggers it asked for.
static func _apply_actions(state: Dictionary, effect: Dictionary, stone: Stone, base_event: Dictionary) -> Dictionary:
	var ctx: Dictionary = state["ctx"]
	var asked: Dictionary = {}
	for action: Dictionary in effect["actions"]:
		var kind: String = action["type"]
		var value: float = float(action.get("value", 0)) * _per_multiplier(ctx, action)
		var event: Dictionary = base_event.duplicate()
		event["rune"] = stone.rune_id
		event["kind"] = kind
		event["value"] = value
		match kind:
			"add_power":
				state["power"] = float(state["power"]) + value
			"add_res":
				state["res"] = float(state["res"]) + value
			"mul_res":
				state["res"] = float(state["res"]) * value
			"add_money":
				state["money"] = int(state["money"]) + int(value)
			"add_money_at_round_end":
				state["money_at_round_end"] = int(state["money_at_round_end"]) + int(value)
			"add_swap":
				state["swaps"] = int(state["swaps"]) + int(value)
			"grow_power":
				(state["grow"] as Array).append({"stone": stone, "value": int(value)})
			"retrigger":
				var target: String = action.get("target", "self")
				asked[target] = int(asked.get(target, 0)) + int(value)
			"special":
				var special: String = action.get("name", "")
				event["kind"] = special
				if special == "berkanan_copy":
					var cast: Array[Stone] = ctx["cast"]
					var scoring: Array[int] = (ctx["word"] as Dictionary)["scoring"]
					var rng: RandomNumberGenerator = ctx["rng"]
					var source: Stone = cast[scoring[rng.randi_range(0, scoring.size() - 1)]]
					(state["copies"] as Array).append(source)
					event["copy"] = source.rune_id
				elif special == "gebo_copy_left":
					continue
			_:
				continue
		_event(state, event)
	return asked


static func _conditions_ok(state: Dictionary, effect: Dictionary, n: int, stone: Stone = null) -> bool:
	var ctx: Dictionary = state["ctx"]
	for condition: Dictionary in effect.get("conditions", []):
		match str(condition["type"]):
			"first_in_word":
				if n != 0:
					return false
			"first_cast":
				if int(ctx.get("cast_index", 0)) != 0:
					return false
			"last_cast":
				if not bool(ctx.get("is_last_cast", false)):
					return false
			"chance":
				var rng: RandomNumberGenerator = ctx["rng"]
				if rng.randf() >= float(condition.get("value", 0.0)):
					return false
			"once_per_round":
				var used: Array = state["once_used"]
				if stone == null or used.has(stone.rune_id):
					return false
				used.append(stone.rune_id)
	return true


static func _per_multiplier(ctx: Dictionary, action: Dictionary) -> float:
	match str(action.get("per", "")):
		"word_stone":
			return float(((ctx["word"] as Dictionary)["scoring"] as Array).size())
		"lesson_used":
			return float(ctx.get("lessons_used", 0))
		"talisman":
			return float(ctx.get("talismans", 0))
	return 1.0


static func _base_power_mult(ctx: Dictionary, stone: Stone) -> float:
	if not bool(ctx.get("voices_awake", true)):
		return 1.0
	var mult: float = 1.0
	for effect: Dictionary in _effects(ctx, stone, "passive"):
		for action: Dictionary in effect["actions"]:
			if action["type"] == "base_power_mult":
				mult *= float(action.get("value", 1))
	return mult


static func _sum_actions(ctx: Dictionary, stone: Stone, trigger: String, kind: String) -> float:
	var total: float = 0.0
	for effect: Dictionary in _effects(ctx, stone, trigger):
		for action: Dictionary in effect["actions"]:
			if action["type"] == kind:
				total += float(action.get("value", 0))
	return total


## The effects of a stone's rune that use this trigger.
static func _effects(ctx: Dictionary, stone: Stone, trigger: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rune: Dictionary = (ctx["runes"] as Dictionary).get(stone.rune_id, {})
	for effect: Variant in rune.get("effects", []):
		if effect is Dictionary and (effect as Dictionary).get("trigger") == trigger:
			result.append(effect)
	return result


static func _has_special(effects: Array[Dictionary], special: String) -> bool:
	for effect: Dictionary in effects:
		for action: Dictionary in effect["actions"]:
			if action.get("name", "") == special:
				return true
	return false


static func _event(state: Dictionary, event: Dictionary) -> void:
	event["power"] = state["power"]
	event["res"] = state["res"]
	(state["events"] as Array).append(event)
