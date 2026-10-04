extends RefCounted
## One rune stone in the bag. Pure data: the rune it carries plus what happened to it during
## the Journey. A base stone gives no points by itself (Stage 5): it is a word of the spell.
## Its permanent Power (tempered stones, materials) is added to the spell it is part of.

## Unique number inside the exam, so the UI and the logic can tell copies apart.
var uid: int = 0
var rune_id: String = ""
var kin: String = ""
## Permanent extra Power for the spells this stone is part of (Tempering, Apprenticeship...).
var bonus_power: int = 0
## Extra Power for the current fight only (Encouragement); cleared when a fight starts.
var round_power: int = 0
## "bone", "amber", "gold", "iron", "glass" or "" for none.
var material: String = ""
## Drawn face down (the Scorpia's rule, the Flyer's trait).
var face_down: bool = false
## Two runes on one stone (the Binding, the ancient bindings): in a sentence it counts as its
## rune followed by the bound rune.
var bound_rune: String = ""
var bound_kin: String = ""


static func from_rune(rune: Dictionary, stone_uid: int) -> RefCounted:
	var stone: RefCounted = load("res://scripts/core/stone.gd").new()
	stone.uid = stone_uid
	stone.rune_id = str(rune.get("id", ""))
	stone.kin = str(rune.get("kin", ""))
	return stone


## A copy with a new uid (the Double, the Echo).
func duplicate_stone(new_uid: int) -> RefCounted:
	var copy: RefCounted = load("res://scripts/core/stone.gd").new()
	copy.uid = new_uid
	copy.rune_id = rune_id
	copy.kin = kin
	copy.bonus_power = bonus_power
	copy.material = material
	copy.bound_rune = bound_rune
	copy.bound_kin = bound_kin
	return copy


## The rune ids this stone stands for in a sentence, in order (one, or two when bound).
func runes() -> Array[String]:
	var ids: Array[String] = [rune_id]
	if not bound_rune.is_empty():
		ids.append(bound_rune)
	return ids


## Power this stone adds to the spell it is part of.
func power() -> int:
	return bonus_power + round_power


func to_dict() -> Dictionary:
	return {
		"uid": uid, "rune": rune_id, "kin": kin, "bonus_power": bonus_power, "material": material,
		"bound_rune": bound_rune, "bound_kin": bound_kin,
	}


## A stone saved with to_dict() (the exam in progress).
static func from_dict(saved: Dictionary) -> RefCounted:
	var stone: RefCounted = load("res://scripts/core/stone.gd").new()
	stone.uid = int(saved.get("uid", 0))
	stone.rune_id = str(saved.get("rune", ""))
	stone.kin = str(saved.get("kin", ""))
	stone.bonus_power = int(saved.get("bonus_power", 0))
	stone.material = str(saved.get("material", ""))
	stone.bound_rune = str(saved.get("bound_rune", ""))
	stone.bound_kin = str(saved.get("bound_kin", ""))
	return stone
