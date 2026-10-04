extends RefCounted
## The Night Market (DESIGN 3.9) between rounds: Talismans, Lessons / Engravings and Bags
## (packs) on the stall, rearranging the stall for a growing price, buying, selling.
## Pure logic on top of ExamState; every random choice uses the exam RNG.
##
## An offer item: {"type": "talisman" | "lesson" | "engraving" | "pack", "id", "price", "sold"}
## (a pack's id is "<kind>" or "<kind>_big", kind = talismans / lessons / engravings / stones).
## Opening a pack gives choices: {"pick": how many to take, "items": [...]}; a stone item
## carries a new Stone.

const ExamState = preload("res://scripts/core/exam_state.gd")
const Stone = preload("res://scripts/core/stone.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")

const PACK_KINDS: Array[String] = ["talismans", "lessons", "engravings", "stones"]
const RARITIES: Array[String] = ["common", "rare", "legendary"]

var exam: ExamState
var offer: Array[Dictionary] = []
var rerolls: int = 0
## Hidden Words the player knows (their Lessons may be sold).
var known_hidden_words: Array[String] = []

var _data: Dictionary


func setup(exam_state: ExamState, data: Dictionary, known_words: Array[String] = []) -> void:
	exam = exam_state
	_data = data
	known_hidden_words = known_words
	rerolls = 0
	_fill()


# --- Prices -------------------------------------------------------------------------------

## The Market Granny takes Coins off every price (never below 1).
func discount() -> int:
	return int(TalismanRules.total(TalismanRules.active(exam.talismans, _table("talismans")), "shop_discount"))


func price_of(type: String, id: String) -> int:
	var base: int = 0
	match type:
		"talisman":
			base = exam.talisman_price(id)
		"lesson":
			base = int(_economy("price_lesson", 3))
		"engraving":
			base = int(_economy("price_engraving", 4))
		"pack":
			base = int(_economy("price_pack_big" if id.ends_with("_big") else "price_pack", 4))
	return maxi(1, base - discount())


func reroll_price() -> int:
	return maxi(1, int(_economy("reroll_base", 2)) + int(_economy("reroll_step", 1)) * rerolls - discount())


# --- Buying and selling ---------------------------------------------------------------------

## Can this offer item be bought now (Coins, a free slot)?
func can_buy(index: int) -> bool:
	if index < 0 or index >= offer.size():
		return false
	var item: Dictionary = offer[index]
	if bool(item["sold"]) or exam.money < int(item["price"]):
		return false
	match str(item["type"]):
		"talisman":
			return exam.talismans.size() < exam.talisman_slots()
		"lesson", "engraving":
			return exam.consumables.size() < exam.consumable_slots()
	return true


## Buys an offer item. Talismans and consumables go to their slots; a pack returns what is
## inside (see open_pack), otherwise {}. Returns {"ok": bool, "pack": {...}}.
func buy(index: int) -> Dictionary:
	if not can_buy(index):
		return {"ok": false}
	var item: Dictionary = offer[index]
	exam.money -= int(item["price"])
	item["sold"] = true
	match str(item["type"]):
		"talisman":
			exam.add_talisman(str(item["id"]))
		"lesson", "engraving":
			exam.add_consumable(str(item["type"]), str(item["id"]))
		"pack":
			return {"ok": true, "pack": open_pack(str(item["id"]))}
	return {"ok": true}


func sell_talisman(slot: int) -> int:
	return exam.sell_talisman(slot)


## A fresh stall (except what was bought), for a price that grows each time.
func reroll() -> bool:
	if exam.money < reroll_price():
		return false
	exam.money -= reroll_price()
	rerolls += 1
	_fill()
	return true


# --- Bags (packs) ---------------------------------------------------------------------------

## What a pack holds: {"kind", "pick", "items": [{"type", "id"} or {"type": "stone", "stone": Stone}]}.
func open_pack(pack_id: String) -> Dictionary:
	var big: bool = pack_id.ends_with("_big")
	var kind: String = pack_id.trim_suffix("_big")
	var count: int = 5 if big else 3
	var items: Array[Dictionary] = []
	match kind:
		"talismans":
			for id: String in _pick_talismans(count, false):
				items.append({"type": "talisman", "id": id})
		"lessons":
			for id: String in _pick_ids(_lesson_pool(), count):
				items.append({"type": "lesson", "id": id})
		"engravings":
			for id: String in _pick_ids(_table("engravings").keys(), count):
				items.append({"type": "engraving", "id": id})
		"stones":
			for i: int in count:
				items.append({"type": "stone", "stone": _new_stone()})
	return {"kind": kind, "pick": 2 if big else 1, "items": items}


## Takes one item out of an opened pack. Lessons from a pack are learned at once; the rest
## go to their slots (a full slot refuses), stones go into the bag.
func take_from_pack(item: Dictionary) -> bool:
	match str(item["type"]):
		"talisman":
			return exam.add_talisman(str(item["id"]))
		"lesson":
			exam.consumables.append({"type": "lesson", "id": str(item["id"])})
			return exam.use_lesson(exam.consumables.size() - 1)
		"engraving":
			return exam.add_consumable("engraving", str(item["id"]))
		"stone":
			exam.bag.stones.append(item["stone"])
			return true
	return false


# --- Filling the stall ----------------------------------------------------------------------

func _fill() -> void:
	offer.clear()
	var talisman_count: int = int(_economy("shop_talismans", 2)) + int(exam.carry.get("shop_extra", 0))
	var rare_first: bool = int(exam.carry.get("shop_rare", 0)) > 0
	exam.carry.erase("shop_extra")
	exam.carry.erase("shop_rare")
	for id: String in _pick_talismans(talisman_count, rare_first):
		offer.append(_item("talisman", id))
	for i: int in int(_economy("shop_consumables", 2)):
		if exam.rng.randf() < 0.5:
			var lessons: Array[String] = _pick_ids(_lesson_pool(), 1)
			if not lessons.is_empty():
				offer.append(_item("lesson", lessons[0]))
				continue
		var engravings: Array[String] = _pick_ids(_table("engravings").keys(), 1)
		if not engravings.is_empty():
			offer.append(_item("engraving", engravings[0]))
	for i: int in int(_economy("shop_packs", 2)):
		var kind: String = PACK_KINDS[exam.rng.randi_range(0, PACK_KINDS.size() - 1)]
		var big: bool = exam.rng.randf() < 0.3
		offer.append(_item("pack", kind + ("_big" if big else "")))


func _item(type: String, id: String) -> Dictionary:
	return {"type": type, "id": id, "price": price_of(type, id), "sold": false}


## Talismans not owned, not already on the stall, by rarity weight (the first one rare when
## Sun into the Talismans asked for it).
func _pick_talismans(count: int, rare_first: bool) -> Array[String]:
	var taken: Array[String] = []
	for owned: Dictionary in exam.talismans:
		taken.append(str(owned["id"]))
	for item: Dictionary in offer:
		if str(item["type"]) == "talisman":
			taken.append(str(item["id"]))
	var picked: Array[String] = []
	for n: int in count:
		var rarity: String = "rare" if rare_first and n == 0 else _roll_rarity()
		var pool: Array[String] = []
		for fallback: int in RARITIES.size():
			pool = _talismans_of(rarity, taken)
			if not pool.is_empty():
				break
			rarity = RARITIES[(RARITIES.find(rarity) + RARITIES.size() - 1) % RARITIES.size()]
		if pool.is_empty():
			break
		var id: String = pool[exam.rng.randi_range(0, pool.size() - 1)]
		picked.append(id)
		taken.append(id)
	return picked


func _talismans_of(rarity: String, taken: Array[String]) -> Array[String]:
	var pool: Array[String] = []
	var table: Dictionary = _table("talismans")
	var locked: bool = not exam.unlocked_talismans.is_empty()
	for id: String in table:
		if str(table[id].get("rarity", "")) == rarity and not taken.has(id) \
				and (not locked or exam.unlocked_talismans.has(id)):
			pool.append(id)
	return pool


func _roll_rarity() -> String:
	var weights: Array = _economy("rarity_weights_pct", [70, 25, 5])
	var roll: float = exam.rng.randf() * 100.0
	var sum: float = 0.0
	for i: int in weights.size():
		sum += float(weights[i])
		if roll < sum:
			return RARITIES[mini(i, RARITIES.size() - 1)]
	return RARITIES[0]


## Lessons the stall may sell: hidden Words only once discovered.
func _lesson_pool() -> Array:
	var pool: Array = []
	var lessons: Dictionary = _table("lessons")
	var words: Dictionary = _data.get("words", {})
	for id: String in lessons:
		var word_id: String = str(lessons[id]["word"])
		if not bool((words.get(word_id, {}) as Dictionary).get("hidden", false)) or known_hidden_words.has(word_id):
			pool.append(id)
	return pool


## Up to `count` different ids, chosen with the exam RNG.
func _pick_ids(ids: Array, count: int) -> Array[String]:
	var pool: Array = ids.duplicate()
	var picked: Array[String] = []
	while picked.size() < count and not pool.is_empty():
		picked.append(str(pool.pop_at(exam.rng.randi_range(0, pool.size() - 1))))
	return picked


## A new stone for a Stones pack: a random rune, sometimes with a material.
func _new_stone() -> Stone:
	var runes: Dictionary = _table("runes")
	var ids: Array = runes.keys()
	var stone: Stone = exam.bag.make_stone(runes[ids[exam.rng.randi_range(0, ids.size() - 1)]])
	if exam.rng.randf() * 100.0 < float(_economy("pack_stone_material_pct", 30)):
		var materials: Array[String] = ["bone", "amber", "gold", "iron", "glass"]
		stone.material = materials[exam.rng.randi_range(0, materials.size() - 1)]
	return stone


func _table(name: String) -> Dictionary:
	return _data.get(name, {})


func _economy(key: String, fallback: Variant) -> Variant:
	return (_data.get("economy", {}) as Dictionary).get(key, fallback)
