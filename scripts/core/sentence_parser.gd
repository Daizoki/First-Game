extends RefCounted
## Reads the cast stones as sentences (the rune grammar, docs/PROMPT_ETAPA5.md 5.2). Every rune
## is an Element, an Action or a Target. A spell is Element -> Target with up to 2 Actions
## between them, the stones one right after the other in casting order. One Cast may hold up
## to 2 spells (read from stone 1 onwards); a bound stone stands for two runes in a row.
## Stones outside every spell do nothing. Pure logic: the fight, the preview and the tests use it.

const MAX_ACTIONS: int = 2

## Why there is no spell (shown under the circle).
const NONE: String = "none"                   ## no Element at all
const INCOMPLETE: String = "incomplete"       ## an Element with no Target after it
const WRONG_ORDER: String = "wrong_order"     ## Targets only before the Elements
const INTERRUPTED: String = "interrupted"     ## Element ... Target, broken by another stone
## At least one sentence was found.
const SPELL: String = "spell"
## A sentence was found, but its spell sleeps ("enabled": false).
const DORMANT: String = "dormant"


## stones: the cast stones in casting order; each item is a rune id, or an Array of rune ids
## for a bound stone (Stone.runes()). runes: GameData.runes. spells: GameData.spells.
## max_spells: how many sentences one Cast may hold (economy.json).
## Returns {"status", "sentences": Array of {"spell", "element", "actions", "target",
##          "stones" (indices into `stones`), "parts" (rune ids)}, "unused": stone indices in no
##          spell} plus, for the screen, the first sentence's "spell", "element", "actions",
##          "target", "indices" and "parts" (or the unfinished sentence's parts).
static func parse(stones: Array, runes: Dictionary, spells: Dictionary, max_spells: int = 2) -> Dictionary:
	var tokens: Array[Dictionary] = _tokens(stones, runes)
	var sentences: Array[Dictionary] = []
	var dormant: bool = false
	var start: int = 0
	while start < tokens.size() and sentences.size() < max_spells:
		if tokens[start]["role"] != "element":
			start += 1
			continue
		var used: Array[int] = [start]
		var next: int = start + 1
		while next < tokens.size() and tokens[next]["role"] == "action" and used.size() <= MAX_ACTIONS:
			used.append(next)
			next += 1
		if next < tokens.size() and tokens[next]["role"] == "target":
			used.append(next)
			var sentence: Dictionary = _sentence(tokens, used, spells)
			if str(sentence["spell"]).is_empty() or not bool((spells[sentence["spell"]] as Dictionary).get("enabled", false)):
				dormant = true
			else:
				sentences.append(sentence)
			start = next + 1
		else:
			start += 1
	var result: Dictionary = {
		"sentences": sentences, "status": SPELL, "spell": "", "element": "", "actions": [] as Array[String],
		"target": "", "indices": [] as Array[int], "parts": [] as Array[String],
		"unused": _unused(stones.size(), sentences),
	}
	if not sentences.is_empty():
		var first: Dictionary = sentences[0]
		for key: String in ["spell", "element", "actions", "target", "parts"]:
			result[key] = first[key]
		result["indices"] = first["stones"]
		return result
	result["status"] = DORMANT if dormant else _why_none(tokens)
	result["parts"] = _unfinished(tokens)
	if not (result["parts"] as Array).is_empty():
		result["element"] = (result["parts"] as Array)[0]
	return result


## The base spell for this Element and Target ("" if none).
static func spell_for(element: String, target: String, spells: Dictionary) -> String:
	for id: String in spells:
		var spell: Dictionary = spells[id]
		if str(spell.get("element", "")) == element and str(spell.get("target", "")) == target:
			return id
	return ""


## One token per rune, with the stone it comes from.
static func _tokens(stones: Array, runes: Dictionary) -> Array[Dictionary]:
	var tokens: Array[Dictionary] = []
	for i: int in stones.size():
		var ids: Array = stones[i] if stones[i] is Array else [stones[i]]
		for id: Variant in ids:
			tokens.append({"rune": str(id), "stone": i,
				"role": str((runes.get(str(id), {}) as Dictionary).get("role", ""))})
	return tokens


static func _sentence(tokens: Array[Dictionary], used: Array[int], spells: Dictionary) -> Dictionary:
	var parts: Array[String] = []
	var stone_indices: Array[int] = []
	for i: int in used:
		parts.append(tokens[i]["rune"])
		if not stone_indices.has(int(tokens[i]["stone"])):
			stone_indices.append(int(tokens[i]["stone"]))
	var actions: Array[String] = []
	for i: int in range(1, parts.size() - 1):
		actions.append(parts[i])
	return {
		"spell": spell_for(parts[0], parts[-1], spells), "element": parts[0], "actions": actions,
		"target": parts[-1], "stones": stone_indices, "parts": parts,
	}


static func _unused(count: int, sentences: Array[Dictionary]) -> Array[int]:
	var unused: Array[int] = []
	for i: int in count:
		var in_spell: bool = false
		for sentence: Dictionary in sentences:
			if (sentence["stones"] as Array).has(i):
				in_spell = true
		if not in_spell:
			unused.append(i)
	return unused


static func _why_none(tokens: Array[Dictionary]) -> String:
	var first_element: int = -1
	for i: int in tokens.size():
		if tokens[i]["role"] == "element":
			first_element = i
			break
	if first_element < 0:
		return NONE
	var target_after: bool = false
	var target_before: bool = false
	for i: int in tokens.size():
		if tokens[i]["role"] == "target":
			if i > first_element:
				target_after = true
			else:
				target_before = true
	if target_after:
		return INTERRUPTED
	if target_before:
		return WRONG_ORDER
	return INCOMPLETE


## The unfinished sentence: the first Element and the Actions right after it.
static func _unfinished(tokens: Array[Dictionary]) -> Array[String]:
	var parts: Array[String] = []
	for i: int in tokens.size():
		if tokens[i]["role"] != "element":
			continue
		parts.append(tokens[i]["rune"])
		var next: int = i + 1
		while next < tokens.size() and tokens[next]["role"] == "action" and parts.size() <= MAX_ACTIONS:
			parts.append(tokens[next]["rune"])
			next += 1
		break
	return parts
