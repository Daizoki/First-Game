extends RefCounted
## A monster in a fight (docs/PROMPT_ETAPA5.md 4, 9): its life, weaknesses (×2), resistances
## (×0.5) and immunities (×0), its Shield, the Burn and the Freeze the Elements leave on it,
## and the heads of the Balaur (one life bar after another, each with its own weaknesses).
## Pure logic: the fight, the preview and the tests use it.

const WEAK: float = 2.0
const RESIST: float = 0.5
const IMMUNE: float = 0.0

## The entry from data/monsters.json.
var entry: Dictionary = {}
var id: String = ""
var max_hp: float = 1.0
var hp: float = 1.0
var shield: float = 0.0
## Shattered for the rest of the fight (Strength into the Enemy).
var shield_broken: bool = false
## Burn: stacks × damage per stack, taken at the start of every later Cast.
var burn_stacks: int = 0
var burn_per_stack: float = 0.0
## Casts during which the trait and the rule rest (Ice).
var frozen: int = 0
## The Balaur: the head now in front (0..2); every head has max_hp of life.
var head: int = 0


## A monster from its entry with this much life (each head gets all of it, for the Balaur).
func setup(monster_entry: Dictionary, life: float) -> void:
	entry = monster_entry
	id = str(entry.get("id", ""))
	max_hp = maxf(1.0, roundf(life))
	hp = max_hp
	shield = float(entry.get("shield", 0))
	shield_broken = false
	burn_stacks = 0
	burn_per_stack = 0.0
	frozen = 0
	head = 0


func heads() -> int:
	return maxi(1, (entry.get("heads", []) as Array).size())


func is_dead() -> bool:
	return hp <= 0.0 and head >= heads() - 1


func is_boss() -> bool:
	return str(entry.get("kind", "")) == "boss"


func has_tag(tag: String) -> bool:
	return (entry.get("tags", []) as Array).has(tag)


## Life left in total (every head still to come counts in full).
func total_hp() -> float:
	return maxf(0.0, hp) + max_hp * float(heads() - 1 - head)


## ×2, ×0.5, ×0 or ×1 for a spell of this Element. The Wave ignores resistances; doubled, it
## also turns immunities into resistances.
func multiplier(element: String, wave: int = 0) -> float:
	var lists: Dictionary = _current_lists()
	if (lists.get("immune", []) as Array).has(element):
		return RESIST if wave >= 2 else IMMUNE
	if (lists.get("weak", []) as Array).has(element):
		return WEAK
	if (lists.get("resist", []) as Array).has(element):
		return 1.0 if wave >= 1 else RESIST
	return 1.0


## One hit. The Shield takes its part first unless the hit ignores it. A head that falls
## passes nothing on (the next head starts whole). Returns the life actually taken.
func take_hit(amount: float, ignore_shield: bool = false) -> float:
	if is_dead() or amount <= 0.0:
		return 0.0
	var through: float = amount
	if not ignore_shield and not shield_broken:
		through = maxf(0.0, amount - shield)
	var taken: float = minf(through, maxf(0.0, hp))
	hp -= through
	if hp <= 0.0 and head < heads() - 1:
		head += 1
		hp = max_hp
	return taken


## Damage past the monster's death in the last hit (for the spreading Raidho).
func overkill() -> float:
	return maxf(0.0, -hp) if is_dead() else 0.0


## Burn: one more stack (up to max_stacks), each worth `per_stack`.
func add_burn(per_stack: float, max_stacks: int) -> void:
	if (entry.get("trait", "") as String) == "burn_immune":
		return
	burn_per_stack = maxf(burn_per_stack, per_stack)
	burn_stacks = mini(burn_stacks + 1, maxi(1, max_stacks))


## The Burn bites at the start of a Cast. Returns the life taken.
func tick_burn() -> float:
	if burn_stacks <= 0:
		return 0.0
	return take_hit(burn_per_stack * burn_stacks, true)


func heal_pct(percent: float) -> void:
	hp = minf(max_hp, hp + max_hp * percent / 100.0)


## Loses a share of its life; a boss never more than `boss_cap` % at once.
func lose_pct(percent: float, boss_cap: float) -> float:
	var share: float = percent if not is_boss() else minf(percent, boss_cap)
	return take_hit(max_hp * share / 100.0, true)


func _current_lists() -> Dictionary:
	var all_heads: Array = entry.get("heads", [])
	if not all_heads.is_empty():
		return all_heads[clampi(head, 0, all_heads.size() - 1)]
	return entry
