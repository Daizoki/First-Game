extends Node
## Contextual hints (data/hints.json): the first time something happens, a small bubble with
## a portrait says one line. Each hint shows once (saved in hints_seen), one after another,
## closes with a click and never blocks the game. Quiet during the evening class and when
## switched off in Settings. It only listens to the EventBus; the game never calls it.

const HintRules = preload("res://scripts/core/hint_rules.gd")
const HintBubble = preload("res://scripts/ui/hint_bubble.gd")

## Above the game screens and their overlays.
const LAYER: int = 40
## Pause between two hints of a queue.
const GAP: float = 0.4

var _rules: HintRules = HintRules.new()
var _bubble: HintBubble
var _queue: Array[String] = []
var _current: String = ""
var _gap: float = 0.0
## Idle time is counted only inside a round, outside the score animation, while nothing
## covers the game (pause menu, books) and no hint is on screen.
var _in_round: bool = false
var _casting: bool = false
var _covers: int = 0
var _idle: float = 0.0


func _ready() -> void:
	_rules.setup(GameData.hints)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = LAYER
	add_child(layer)
	var area: Control = Control.new()
	area.set_anchors_preset(Control.PRESET_FULL_RECT)
	area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(area)
	_bubble = HintBubble.new()
	area.add_child(_bubble)
	_bubble.closed.connect(_on_bubble_closed)

	EventBus.round_started.connect(_on_round_started)
	EventBus.round_closed.connect(_on_round_closed)
	EventBus.round_won.connect(func() -> void: _in_round = false)
	EventBus.round_lost.connect(func() -> void: _in_round = false)
	EventBus.hand_changed.connect(func(rune_ids: Array) -> void: fire("rune_in_hand", {"runes": rune_ids}))
	EventBus.stone_hovered.connect(func(rune_id: String) -> void:
		if not rune_id.is_empty():
			_idle = 0.0)
	EventBus.selection_changed.connect(func(_word: String, _spells: Array, _runes: Array) -> void: _idle = 0.0)
	EventBus.swap.connect(func(_count: int) -> void: _idle = 0.0)
	EventBus.cast.connect(func(_word: String, _runes: Array) -> void: _casting = true)
	EventBus.cast_resolved.connect(func() -> void:
		_casting = false
		_idle = 0.0)
	EventBus.book_opened.connect(func(_book: String) -> void: _cover(1))
	EventBus.book_closed.connect(func(_book: String) -> void: _cover(-1))
	EventBus.sentence_read.connect(func(status: String, _spell: String, _actions: int) -> void:
		if status == "wrong_order":
			fire("wrong_order"))
	EventBus.scroll_gained.connect(func(spell_id: String) -> void: fire("scroll_gained", {"spell": spell_id}))
	EventBus.spell_sentence_cast.connect(func(spell_id: String, actions: Array) -> void:
		if actions.size() >= 2:
			fire("two_actions", {"spell": spell_id}))
	EventBus.shop_opened.connect(func() -> void:
		fire("shop_opened")
		fire("reroll_available"))
	EventBus.talisman_bought.connect(func(_id: String) -> void: fire("talisman_bought"))
	EventBus.consumable_gained.connect(func(type: String, _id: String) -> void:
		fire("lesson_gained" if type == "lesson" else "engraving_gained"))
	EventBus.consumable_used.connect(func(_type: String, id: String) -> void:
		if id == "binding":
			fire("bindrune_gained"))
	EventBus.examiner_met.connect(func(examiner_id: String) -> void: fire("examiner_met", {"examiner": examiner_id}))
	EventBus.overlay_opened.connect(func(_overlay: String) -> void: _cover(1))
	EventBus.overlay_closed.connect(func(_overlay: String) -> void: _cover(-1))
	EventBus.pause_opened.connect(func() -> void: _cover(1))
	EventBus.pause_closed.connect(func() -> void: _cover(-1))


## Feeds one game event to the hint rules; due hints join the queue. Later stages send
## their events (shop_opened, talisman_bought …) the same way, through the EventBus.
func fire(event: String, args: Dictionary = {}) -> void:
	for id: String in _rules.on_event(event, args, context()):
		if id != _current and not _queue.has(id):
			_queue.append(id)
	_show_next()


## What the rules need to know about the player right now.
func context() -> Dictionary:
	return {
		"seen": SaveManager.data.get("hints_seen", []),
		"enabled": bool(SaveManager.get_setting("hints_enabled", true)),
		"tutorial": EventBus.tutorial_active,
		"exams": int(SaveManager.data.get("attempts", 0)),
	}


## The hint on screen ("" when none).
func current() -> String:
	return _current


func _process(delta: float) -> void:
	var ctx: Dictionary = context()
	if not bool(ctx["enabled"]) or bool(ctx["tutorial"]):
		if not _current.is_empty() or not _queue.is_empty():
			_clear()
		return
	if _gap > 0.0:
		_gap -= delta
		if _gap <= 0.0:
			_show_next()
	if _in_round and not _casting and _covers == 0 and _current.is_empty():
		_idle += delta
		if _idle >= _rules.idle_threshold(ctx):
			fire("idle", {"seconds": _idle})
			_idle = 0.0


func _show_next() -> void:
	if not _current.is_empty() or _queue.is_empty() or _gap > 0.0:
		return
	_current = _queue.pop_front()
	var hint: Dictionary = GameData.hints[_current]
	if not (SaveManager.data.get("hints_seen") is Array):
		SaveManager.data["hints_seen"] = []
	(SaveManager.data["hints_seen"] as Array).append(_current)
	SaveManager.save_game()
	_bubble.set_covered(_covers > 0)
	_bubble.show_hint(str(hint["speaker"]), Loc.text(hint["text"]))


func _on_bubble_closed() -> void:
	_current = ""
	_idle = 0.0
	_gap = GAP


func _on_round_started() -> void:
	_in_round = true
	_casting = false
	_covers = 0
	_idle = 0.0
	_bubble.set_covered(false)


func _on_round_closed() -> void:
	_in_round = false
	_covers = 0
	_bubble.set_covered(false)


func _cover(step: int) -> void:
	_covers = maxi(0, _covers + step)
	_bubble.set_covered(_covers > 0)


func _clear() -> void:
	_queue.clear()
	_current = ""
	_gap = 0.0
	_bubble.clear()
