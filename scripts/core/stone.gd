extends RefCounted
## One rune stone in the bag. Pure data: the rune it carries plus what happened to it
## during the exam (permanent Power growth, later materials and bindings).

## Unique number inside the exam, so the UI and the scorer can tell copies apart.
var uid: int = 0
var rune_id: String = ""
var kin: String = ""
var position: int = 0
var base_power: int = 0
## Permanent extra Power gained during the exam (Eihwaz, Ingwaz, spells into the Bag...).
var bonus_power: int = 0
## Extra Power for the current round only (Encouragement); cleared when a round starts.
var round_power: int = 0
## Stage 3: "bone", "amber", "gold", "iron", "glass" or "" for none.
var material: String = ""
## Lunet's rule (Stage 3): drawn face down.
var face_down: bool = false
## A bind-rune (the Binding): the second rune on the stone, with its Kin and Position.
## The Word may read the stone as either rune; both Voices are heard when it scores.
var bound_rune: String = ""
var bound_kin: String = ""
var bound_position: int = 0


static func from_rune(rune: Dictionary, stone_uid: int) -> RefCounted:
	var stone: RefCounted = load("res://scripts/core/stone.gd").new()
	stone.uid = stone_uid
	stone.rune_id = str(rune.get("id", ""))
	stone.kin = str(rune.get("kin", ""))
	stone.position = int(rune.get("position", 0))
	stone.base_power = int(rune.get("base_power", 0))
	return stone


## A copy with a new uid (Berkanan, Dublura).
func duplicate_stone(new_uid: int) -> RefCounted:
	var copy: RefCounted = load("res://scripts/core/stone.gd").new()
	copy.uid = new_uid
	copy.rune_id = rune_id
	copy.kin = kin
	copy.position = position
	copy.base_power = base_power
	copy.bonus_power = bonus_power
	copy.material = material
	copy.bound_rune = bound_rune
	copy.bound_kin = bound_kin
	copy.bound_position = bound_position
	return copy


## The stone read as its second rune (a bind-rune; the Word picks the better reading).
func as_bound() -> RefCounted:
	var other: RefCounted = duplicate_stone(uid)
	other.rune_id = bound_rune
	other.kin = bound_kin
	other.position = bound_position
	return other


func to_dict() -> Dictionary:
	return {
		"uid": uid, "rune": rune_id, "kin": kin, "position": position,
		"base_power": base_power, "bonus_power": bonus_power, "material": material, "bound_rune": bound_rune,
	}
