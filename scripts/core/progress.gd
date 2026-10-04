extends RefCounted
## What lasts from one exam to the next (DESIGN 3.11, Aeva's loop): Memories earned at the end
## of an exam and spent in the Morning (parents, Talismans for the Night Market), the records,
## and the Collection of what was seen. Pure logic on the save data Dictionary
## (SaveManager.data), so the tests can use a plain default save.

const ExamState = preload("res://scripts/core/exam_state.gd")

## Collection categories (save["collection"]).
const COLLECTION: Array[String] = ["talismans", "engravings", "monsters"]


# --- Memories at the end of an exam ---------------------------------------------------------

## The Memories an exam brings: per round won, per examiner beaten, for passing.
## (Spells and hidden Words pay their own Memories when they are discovered.)
static func exam_memories(exam: ExamState, rules: Dictionary) -> Dictionary:
	var rounds: int = exam.rounds_won * int(rules.get("memories_per_round", 1))
	var examiners: int = exam.defeated.size() * int(rules.get("memories_per_examiner", 3))
	var passed: int = int(rules.get("memories_exam_passed", 15)) if exam.passed else 0
	return {"rounds": rounds, "examiners": examiners, "passed": passed, "total": rounds + examiners + passed}


## Closes a finished exam: adds its Memories, updates the records. Returns exam_memories().
static func finish_exam(save: Dictionary, exam: ExamState, rules: Dictionary) -> Dictionary:
	var earned: Dictionary = exam_memories(exam, rules)
	add_memories(save, int(earned["total"]))
	var stats: Dictionary = _dict(save, "stats")
	stats["exams_finished"] = int(stats.get("exams_finished", 0)) + 1
	var reached: int = exam.trial_index + 1
	stats["best_trial"] = maxi(int(stats.get("best_trial", 0)), reached)
	if exam.passed:
		stats["exams_passed"] = int(stats.get("exams_passed", 0)) + 1
	_dict(save, "flags")["last_exam"] = {"passed": exam.passed, "trial": reached}
	return earned


## Which of Aeva's Morning dialogs fits (data/dialogs.json), and the values for its text:
## the very first morning, the one after a passed exam, after a failed one, or any other.
## `in_progress`: an exam is saved (this morning is the one of that exam, not a new one).
static func morning_dialog(save: Dictionary, in_progress: bool = false) -> Dictionary:
	var morning: int = int(save.get("attempts", 0)) + (0 if in_progress else 1)
	var args: Dictionary = {"name": str(save.get("player_name", "")), "n": maxi(1, morning)}
	var last: Variant = _dict(save, "flags").get("last_exam")
	if morning <= 1:
		return {"id": "aeva_morning_first", "args": args}
	if last is Dictionary:
		args["trial"] = int((last as Dictionary).get("trial", 1))
		return {"id": "aeva_morning_passed" if bool((last as Dictionary).get("passed", false)) else "aeva_morning_after_loss",
			"args": args}
	return {"id": "aeva_morning", "args": args}


static func add_memories(save: Dictionary, amount: int) -> void:
	save["memories"] = maxi(0, int(save.get("memories", 0)) + amount)


static func memories(save: Dictionary) -> int:
	return int(save.get("memories", 0))


# --- Records -------------------------------------------------------------------------------

## After a fight: the best single Cast and the highest level of every Element.
static func record_round(save: Dictionary, best_cast: float, element_levels: Dictionary) -> void:
	var stats: Dictionary = _dict(save, "stats")
	stats["best_cast_score"] = maxf(float(stats.get("best_cast_score", 0.0)), best_cast)
	if not (stats.get("element_levels") is Dictionary):
		stats["element_levels"] = {}
	var best_levels: Dictionary = stats["element_levels"]
	for element_id: Variant in element_levels:
		best_levels[str(element_id)] = maxi(int(best_levels.get(str(element_id), 1)), int(element_levels[element_id]))


## The highest level an Element ever reached (1 if never raised).
static func best_element_level(save: Dictionary, element_id: String) -> int:
	var levels: Variant = _dict(save, "stats").get("element_levels", {})
	return int((levels as Dictionary).get(element_id, 1)) if levels is Dictionary else 1


# --- Parents -------------------------------------------------------------------------------

## Can this parent be chosen now? Varr from the start, Selvia after enough finished exams,
## the others once bought with Memories.
static func parent_available(save: Dictionary, parent: Dictionary) -> bool:
	var id: String = str(parent.get("id", ""))
	match str(parent.get("unlock", "")):
		"start":
			return true
		"attempts":
			return int(_dict(save, "stats").get("exams_finished", 0)) >= int(parent.get("cost", 1)) \
				or _list(save, "unlocked_parents").has(id)
		"memories":
			return _list(save, "unlocked_parents").has(id)
	return false


## A parent that is bought with Memories, not yet bought, and affordable.
static func can_buy_parent(save: Dictionary, parent: Dictionary) -> bool:
	return str(parent.get("unlock", "")) == "memories" and not parent_available(save, parent) \
		and memories(save) >= int(parent.get("cost", 0))


static func buy_parent(save: Dictionary, parent: Dictionary) -> bool:
	if not can_buy_parent(save, parent):
		return false
	add_memories(save, -int(parent.get("cost", 0)))
	_list(save, "unlocked_parents").append(str(parent["id"]))
	return true


# --- Talismans for the Night Market --------------------------------------------------------

## Talismans the Market may sell: those without a price ("unlock") and those bought.
static func unlocked_talismans(save: Dictionary, talismans: Dictionary) -> Array[String]:
	var bought: Array = _unlock_list(save, "talismans")
	var result: Array[String] = []
	for id: String in talismans:
		if int((talismans[id] as Dictionary).get("unlock", 0)) <= 0 or bought.has(id):
			result.append(id)
	return result


static func talisman_unlocked(save: Dictionary, talismans: Dictionary, id: String) -> bool:
	return unlocked_talismans(save, talismans).has(id)


static func can_buy_talisman(save: Dictionary, talismans: Dictionary, id: String) -> bool:
	return talismans.has(id) and not talisman_unlocked(save, talismans, id) \
		and memories(save) >= int((talismans[id] as Dictionary).get("unlock", 0))


static func buy_talisman(save: Dictionary, talismans: Dictionary, id: String) -> bool:
	if not can_buy_talisman(save, talismans, id):
		return false
	add_memories(save, -int((talismans[id] as Dictionary).get("unlock", 0)))
	_unlock_list(save, "talismans").append(id)
	return true


# --- The Collection ------------------------------------------------------------------------

## Notes that the player has seen this Talisman / Engraving / examiner. True if it is new.
static func record_seen(save: Dictionary, category: String, id: String) -> bool:
	var collection: Dictionary = _dict(save, "collection")
	if not (collection.get(category) is Array):
		collection[category] = []
	var list: Array = collection[category]
	if list.has(id):
		return false
	list.append(id)
	return true


static func has_seen(save: Dictionary, category: String, id: String) -> bool:
	var list: Variant = _dict(save, "collection").get(category, [])
	return list is Array and (list as Array).has(id)


# --- Helpers -------------------------------------------------------------------------------

static func _dict(save: Dictionary, key: String) -> Dictionary:
	if not (save.get(key) is Dictionary):
		save[key] = {}
	return save[key]


static func _list(save: Dictionary, key: String) -> Array:
	if not (save.get(key) is Array):
		save[key] = []
	return save[key]


static func _unlock_list(save: Dictionary, key: String) -> Array:
	var unlocks: Dictionary = _dict(save, "unlocks")
	if not (unlocks.get(key) is Array):
		unlocks[key] = []
	return unlocks[key]
