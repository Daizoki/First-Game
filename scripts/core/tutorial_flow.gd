extends RefCounted
## The evening class (data/tutorial.json) as a state machine: which lesson and step we are
## on, and what each game event means for it. Pure logic: the tutorial screen shows it,
## the tests drive it with simulated events.
##
## A step without "wait_for" is read and clicked through (advance()). A step with
## "wait_for" moves on when the matching game event arrives (handle()).
## Results: {"result": "none" | "advance" | "wrong" | "lesson_done" | "lesson_failed",
##           "say": a loc text to show first (alt_text / wrong_text), or null}

## Actions the player always keeps (they never break a lesson).
const ALWAYS_ALLOWED: Array[String] = ["sort", "speed", "menu"]
const GAME_ACTIONS: Array[String] = ["select", "cast", "swap"]
## Waits that can no longer happen once the lesson's round is won.
const PLAY_EVENTS: Array[String] = ["hover", "selection", "cast", "swap", "round_won"]

var lessons: Array = []
var lesson_index: int = 0
var step_index: int = 0
## The current lesson's round is won (the remaining steps are only talk).
var won: bool = false


func setup(tutorial: Dictionary) -> void:
	lessons = tutorial.get("lessons", [])
	start_lesson(0)


func start_lesson(index: int) -> void:
	lesson_index = index
	step_index = 0
	won = false


func lesson() -> Dictionary:
	if lesson_index < 0 or lesson_index >= lessons.size():
		return {}
	return lessons[lesson_index]


func is_last_lesson() -> bool:
	return lesson_index >= lessons.size() - 1


## The current step, or {} once every step of the lesson has been played.
func step() -> Dictionary:
	var steps: Array = lesson().get("steps", [])
	if step_index < 0 or step_index >= steps.size():
		return {}
	return steps[step_index]


func steps_done() -> bool:
	return step().is_empty()


## True while the current step waits for a game event (not for a click).
func is_waiting() -> bool:
	return step().has("wait_for")


## What the player may do right now: {"actions": Array[String], "runes": Array[String]}.
## After the last step (free play until the round is won) everything is allowed.
func gate() -> Dictionary:
	var actions: Array[String] = ALWAYS_ALLOWED.duplicate()
	var runes: Array[String] = []
	var current: Dictionary = step()
	if current.is_empty():
		actions.append_array(GAME_ACTIONS)
	elif current.has("wait_for"):
		for action: Variant in current.get("allow", []):
			if not actions.has(str(action)):
				actions.append(str(action))
		for id: Variant in current.get("selectable", []):
			runes.append(str(id))
	return {"actions": actions, "runes": runes}


## The player clicked through a step that only talks.
func advance() -> Dictionary:
	if is_waiting():
		return _result("none")
	step_index += 1
	return _after_step(null)


## Feeds one game event: "hover" {rune}, "selection" {word, runes}, "cast" {word, runes},
## "swap" {count}, "spell_cast" / "spell_discovered" {spell}, "book_opened" / "book_closed" {book},
## (a "selection" wait with "in_order" needs the "exact" runes in that order: a spell is a sentence)
## "round_won", "round_lost".
func handle(event: String, args: Dictionary = {}) -> Dictionary:
	if lesson().is_empty():
		return _result("none")
	if event == "round_lost":
		return _result("lesson_failed")
	if event == "round_won":
		won = true
	var current: Dictionary = step()
	if current.is_empty():
		return _result("lesson_done") if won else _result("none")
	if not current.has("wait_for"):
		return _result("none")
	var wait: Dictionary = current["wait_for"]
	if str(wait["event"]) != event:
		if won:
			return _after_step(null)
		return _result("none")
	var verdict: String = _judge(wait, args)
	if verdict == "wrong":
		return _result("wrong", current.get("wrong_text"))
	if verdict == "no":
		return _result("none")
	step_index += 1
	var say: Variant = null
	if wait.has("prefer") and not _contains_all(_runes(args), wait["prefer"]):
		say = wait.get("alt_text")
	return _after_step(say)


## "yes", "no" (not yet, keep waiting quietly) or "wrong" (say wrong_text).
func _judge(wait: Dictionary, args: Dictionary) -> String:
	match str(wait["event"]):
		"hover":
			var rune: String = str(args.get("rune", ""))
			if rune.is_empty():
				return "no"
			return "yes" if not wait.has("rune") or wait["rune"] == rune else "no"
		"selection", "cast":
			var runes: Array[String] = _runes(args)
			var ok: bool = true
			if wait.has("word") and str(args.get("word", "")) != str(wait["word"]):
				ok = false
			if wait.has("include") and not _contains_all(runes, wait["include"]):
				ok = false
			if wait.has("exact") and not _same_runes(runes, wait["exact"]):
				ok = false
			if bool(wait.get("in_order", false)) and wait.has("exact") and runes != _strings(wait["exact"]):
				ok = false
			if ok:
				return "yes"
			if str(wait["event"]) == "cast" or runes.size() >= _min_count(wait):
				return "wrong"
			return "no"
		"spell_cast", "spell_discovered":
			return "yes" if not wait.has("spell") or str(args.get("spell", "")) == str(wait["spell"]) else "no"
		"book_opened", "book_closed":
			return "yes" if not wait.has("book") or str(args.get("book", "")) == str(wait["book"]) else "no"
	return "yes"


## After a step ends: skip waits that can no longer happen, then report the new state.
func _after_step(say: Variant) -> Dictionary:
	while won and is_waiting() and PLAY_EVENTS.has(str((step()["wait_for"] as Dictionary)["event"])):
		step_index += 1
	if steps_done() and (won or bool(lesson().get("end_after_steps", false))):
		return _result("lesson_done", say)
	return _result("advance", say)


## How many stones must be selected before a wrong selection is worth a remark.
func _min_count(wait: Dictionary) -> int:
	if wait.has("min_count"):
		return int(wait["min_count"])
	if wait.has("exact"):
		return (wait["exact"] as Array).size()
	if wait.has("include"):
		return (wait["include"] as Array).size()
	return 2


func _runes(args: Dictionary) -> Array[String]:
	var runes: Array[String] = []
	for id: Variant in args.get("runes", []):
		runes.append(str(id))
	return runes


func _strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str(value))
	return result


func _contains_all(runes: Array[String], wanted: Array) -> bool:
	var pool: Array[String] = runes.duplicate()
	for id: Variant in wanted:
		var at: int = pool.find(str(id))
		if at < 0:
			return false
		pool.remove_at(at)
	return true


func _same_runes(runes: Array[String], wanted: Array) -> bool:
	return runes.size() == wanted.size() and _contains_all(runes, wanted)


func _result(kind: String, say: Variant = null) -> Dictionary:
	return {"result": kind, "say": say}
