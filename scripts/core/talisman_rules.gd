extends RefCounted
## The Talismans (DESIGN 3.6): an owned Talisman is a small Dictionary
## {"id", "value" (for those that change: the Shawarma, Dara), "seen" (Morrah's Bookmark)}.
## Its "kind" in data/talismans.json says what it does; this file turns the owned list into
## the effects that act on a Cast (the scorer applies them, step 4) and on a round.

## Kinds that change the Cast's score after the stones (scorer step 4), left to right.
const CAST_KINDS: Array[String] = [
	"add_res", "add_power", "wearing_res", "new_word_res", "power_per_bag_stone", "mul_res_five",
	"growing_mul", "word_money",
]


## A new owned Talisman.
static func make(id: String, table: Dictionary) -> Dictionary:
	var entry: Dictionary = table.get(id, {})
	var owned: Dictionary = {"id": id}
	match str(entry.get("kind", "")):
		"wearing_res", "growing_mul":
			owned["value"] = float(entry.get("value", 0))
		"new_word_res":
			owned["seen"] = [] as Array[String]
	return owned


## The effects that act now, left to right: [{"slot", "id", "kind", "value", "kin", "word"}].
## Nix copies the Talisman on its right; `disabled_slot` (Nix's Trick, the examiner) is skipped.
static func active(owned: Array, table: Dictionary, disabled_slot: int = -1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for slot: int in owned.size():
		if slot == disabled_slot:
			continue
		var source: int = slot
		if str(_entry(owned[slot], table).get("kind", "")) == "copy_right":
			source = slot + 1
			if source >= owned.size() or source == disabled_slot \
					or str(_entry(owned[source], table).get("kind", "")) == "copy_right":
				continue
		var entry: Dictionary = _entry(owned[source], table)
		result.append({
			"slot": slot, "id": str((owned[slot] as Dictionary)["id"]), "kind": str(entry.get("kind", "")),
			"value": current_value(owned[source], table), "kin": str(entry.get("kin", "")),
			"word": str(entry.get("word", "")),
		})
	return result


## What the Talisman adds right now (the Shawarma's charge, Dara's ×, the Bookmark's total).
static func current_value(owned: Dictionary, table: Dictionary) -> float:
	var entry: Dictionary = _entry(owned, table)
	match str(entry.get("kind", "")):
		"new_word_res":
			return float(entry.get("value", 1)) * float((owned.get("seen", []) as Array).size())
		"wearing_res", "growing_mul":
			return float(owned.get("value", entry.get("value", 0)))
	return float(entry.get("value", 0))


## The sum of one kind among the active effects (the Coffee's stones, the Shell's Swaps...).
static func total(effects: Array[Dictionary], kind: String) -> float:
	var sum: float = 0.0
	for effect: Dictionary in effects:
		if effect["kind"] == kind:
			sum += float(effect["value"])
	return sum


## Numbers for the Talisman's description text ({value}, {step}, {now}).
static func text_values(owned: Dictionary, table: Dictionary) -> Dictionary:
	var entry: Dictionary = _entry(owned, table)
	return {
		"value": owned.get("value", entry.get("value", 0)), "step": entry.get("step", 0),
		"now": current_value(owned, table),
	}


## After a Cast: the Shawarma wears down (unless `no_wear`), the Bookmark notes a new Word.
## Returns the ids of the Talismans used up.
static func after_cast(owned: Array, table: Dictionary, word_id: String, no_wear: bool) -> Array[String]:
	var gone: Array[String] = []
	for item: Dictionary in owned.duplicate():
		match str(_entry(item, table).get("kind", "")):
			"wearing_res":
				if not no_wear:
					item["value"] = float(item["value"]) - 1.0
					if float(item["value"]) <= 0.0:
						owned.erase(item)
						gone.append(str(item["id"]))
			"new_word_res":
				var seen: Array = item["seen"]
				if not seen.has(word_id):
					seen.append(word_id)
	return gone


## After an examiner is beaten: Dara grows.
static func after_examiner(owned: Array, table: Dictionary) -> void:
	for item: Dictionary in owned:
		var entry: Dictionary = _entry(item, table)
		if str(entry.get("kind", "")) == "growing_mul":
			item["value"] = float(item["value"]) + float(entry.get("step", 0))


## Index of the first owned Talisman of this kind (-1 if none).
static func find_kind(owned: Array, table: Dictionary, kind: String) -> int:
	for i: int in owned.size():
		if str(_entry(owned[i], table).get("kind", "")) == kind:
			return i
	return -1


static func _entry(owned: Dictionary, table: Dictionary) -> Dictionary:
	return table.get(str(owned.get("id", "")), {})
