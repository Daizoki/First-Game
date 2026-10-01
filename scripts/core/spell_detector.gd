extends RefCounted
## Finds the Spells hidden in a set of cast stones (3.15): every rune of the Spell must be
## among ALL the cast stones (not only the scoring ones). Order does not matter and
## Laguz is NOT a wildcard here. Each matching Spell fires once per Cast.

const Stone = preload("res://scripts/core/stone.gd")


## Ids of the Spells contained in `stones`, in file order. With `only_active`, Spells whose
## effects are not implemented yet (no "actions" in spells.json) are ignored.
static func detect(stones: Array[Stone], spells: Dictionary, only_active: bool = true) -> Array[String]:
	var available: Dictionary = {}
	for stone: Stone in stones:
		available[stone.rune_id] = int(available.get(stone.rune_id, 0)) + 1
	var found: Array[String] = []
	for id: String in spells:
		var spell: Dictionary = spells[id]
		if only_active and not spell.has("actions"):
			continue
		if _contains(available, spell.get("runes", [])):
			found.append(id)
	return found


static func _contains(available: Dictionary, runes: Variant) -> bool:
	if not (runes is Array) or (runes as Array).is_empty():
		return false
	var needed: Dictionary = {}
	for rune: Variant in runes:
		needed[rune] = int(needed.get(rune, 0)) + 1
	for rune: Variant in needed:
		if int(available.get(rune, 0)) < int(needed[rune]):
			return false
	return true
