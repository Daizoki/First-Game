extends RefCounted
## Which contextual hints (data/hints.json) are due when something happens in the game.
## Pure logic: the Hints autoload feeds it the game's events and shows the bubbles; the
## tests feed it directly.
##
## A hint has either a "trigger" (an event, plus "rune" / "seconds" / "max_exams") or
## "follows": it comes right after the hint it names. A hint shows only once, only when
## "enabled", never during the evening class and never when hints are off in Settings.
##
## context: {"seen": Array (hint ids), "enabled": bool (the setting), "tutorial": bool,
##           "exams": int (exams started so far, counting the current one)}

var hints: Dictionary = {}


func setup(table: Dictionary) -> void:
	hints = table


## The hints to show for this event, in order (each trigger followed by its chain).
## Events: "rune_in_hand" {"runes": [...]}, "idle" {"seconds": float}, and the later stages'
## events from ENUMS["hint_event"] (no arguments yet).
func on_event(event: String, args: Dictionary, context: Dictionary) -> Array[String]:
	var due: Array[String] = []
	if not _listening(context):
		return due
	for id: String in hints:
		var hint: Dictionary = hints[id]
		if not hint.has("trigger") or not _available(id, context):
			continue
		if _matches(hint["trigger"], event, args, context):
			due.append(id)
			var visited: Array[String] = [id]
			_append_followers(id, context, due, visited)
	return due


## Seconds without any action after which an idle hint is due; INF when none can come.
func idle_threshold(context: Dictionary) -> float:
	var best: float = INF
	if not _listening(context):
		return best
	for id: String in hints:
		var trigger: Variant = (hints[id] as Dictionary).get("trigger")
		if not (trigger is Dictionary) or str(trigger.get("event", "")) != "idle" or not _available(id, context):
			continue
		if _exams_ok(trigger, context):
			best = minf(best, float(trigger.get("seconds", INF)))
	return best


func _listening(context: Dictionary) -> bool:
	return bool(context.get("enabled", true)) and not bool(context.get("tutorial", false))


## Switched on in the data and not seen yet.
func _available(id: String, context: Dictionary) -> bool:
	return bool((hints[id] as Dictionary).get("enabled", false)) and not (context.get("seen", []) as Array).has(id)


func _matches(trigger: Dictionary, event: String, args: Dictionary, context: Dictionary) -> bool:
	if str(trigger.get("event", "")) != event:
		return false
	match event:
		"rune_in_hand":
			return not trigger.has("rune") or (args.get("runes", []) as Array).has(trigger["rune"])
		"idle":
			return float(args.get("seconds", 0.0)) >= float(trigger.get("seconds", INF)) and _exams_ok(trigger, context)
	return true


func _exams_ok(trigger: Dictionary, context: Dictionary) -> bool:
	return not trigger.has("max_exams") or int(context.get("exams", 0)) <= int(trigger["max_exams"])


## Hints that follow `id` (and the ones following them), skipping those already seen.
## `visited` stops a chain that loops back on itself.
func _append_followers(id: String, context: Dictionary, due: Array[String], visited: Array[String]) -> void:
	for next_id: String in hints:
		if str((hints[next_id] as Dictionary).get("follows", "")) != id or visited.has(next_id):
			continue
		visited.append(next_id)
		if _available(next_id, context):
			due.append(next_id)
		_append_followers(next_id, context, due, visited)
