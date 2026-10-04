extends RefCounted
## Reads the cast stones as a sentence (DESIGN 3.15, the rune grammar). Every rune has a role:
## Element, Action or Target. A spell is Element -> Target, with up to 2 Actions between them,
## the stones one right after the other in casting order. Only the first complete sentence
## counts (read from stone 1 onwards). Pure logic: the round, the preview and the tests use it.

const MAX_ACTIONS: int = 2

## Why there is no spell (also shown under the circle).
const NONE: String = "none"                   ## no Element at all
const INCOMPLETE: String = "incomplete"       ## an Element with no Target after it
const WRONG_ORDER: String = "wrong_order"     ## Targets only before the Elements
const INTERRUPTED: String = "interrupted"     ## Element ... Target, broken by another stone
## A sentence was found.
const SPELL: String = "spell"
## A sentence was found, but its spell wakes up in a later stage ("enabled": false).
const DORMANT: String = "dormant"


## rune_ids: the cast stones in casting order. runes: GameData.runes. spells: GameData.spells.
## Returns {"status", "spell" (id or ""), "element", "actions" (rune ids), "target",
##          "indices" (positions in rune_ids that form the sentence),
##          "parts" (rune ids of the sentence, or of the unfinished one)}.
static func parse(rune_ids: Array[String], runes: Dictionary, spells: Dictionary) -> Dictionary:
	var roles: Array[String] = []
	for id: String in rune_ids:
		roles.append(str((runes.get(id, {}) as Dictionary).get("role", "")))
	for start: int in roles.size():
		if roles[start] != "element":
			continue
		var indices: Array[int] = [start]
		var next: int = start + 1
		while next < roles.size() and roles[next] == "action" and indices.size() <= MAX_ACTIONS:
			indices.append(next)
			next += 1
		if next < roles.size() and roles[next] == "target":
			indices.append(next)
			return _found(rune_ids, indices, spells)
	return _no_spell(rune_ids, roles)


## The base spell for this Element and Target ("" if none).
static func spell_for(element: String, target: String, spells: Dictionary) -> String:
	for id: String in spells:
		var spell: Dictionary = spells[id]
		if str(spell.get("element", "")) == element and str(spell.get("target", "")) == target:
			return id
	return ""


static func _found(rune_ids: Array[String], indices: Array[int], spells: Dictionary) -> Dictionary:
	var parts: Array[String] = []
	for i: int in indices:
		parts.append(rune_ids[i])
	var actions: Array[String] = []
	for i: int in range(1, parts.size() - 1):
		actions.append(parts[i])
	var spell_id: String = spell_for(parts[0], parts[-1], spells)
	var enabled: bool = not spell_id.is_empty() and bool((spells[spell_id] as Dictionary).get("enabled", false))
	return {
		"status": SPELL if enabled else DORMANT, "spell": spell_id, "element": parts[0], "actions": actions,
		"target": parts[-1], "indices": indices, "parts": parts,
	}


static func _no_spell(rune_ids: Array[String], roles: Array[String]) -> Dictionary:
	var first_element: int = roles.find("element")
	var result: Dictionary = {
		"status": NONE, "spell": "", "element": "", "actions": [] as Array[String], "target": "",
		"indices": [] as Array[int], "parts": [] as Array[String],
	}
	if first_element < 0:
		return result
	# The unfinished sentence: the first Element and the Actions right after it.
	var parts: Array[String] = [rune_ids[first_element]]
	var next: int = first_element + 1
	while next < roles.size() and roles[next] == "action" and parts.size() <= MAX_ACTIONS:
		parts.append(rune_ids[next])
		next += 1
	result["element"] = parts[0]
	result["parts"] = parts
	var target_after: bool = false
	var target_before: bool = false
	for i: int in roles.size():
		if roles[i] == "target":
			if i > first_element:
				target_after = true
			else:
				target_before = true
	if target_after:
		result["status"] = INTERRUPTED
	elif target_before:
		result["status"] = WRONG_ORDER
	else:
		result["status"] = INCOMPLETE
	return result
