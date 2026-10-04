extends Control
## The evening class before the exam: Master Ilinca's intro, then lessons played on the
## real round screen with fixed hands (data/tutorial.json). This screen only listens to the
## EventBus and drives TutorialFlow; the round screen knows nothing about the tutorial.

const TutorialFlow = preload("res://scripts/core/tutorial_flow.gd")
const TutorialOverlay = preload("res://scripts/ui/tutorial_overlay.gd")
const ROUND_SCENE: PackedScene = preload("res://scenes/round.tscn")
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
## A phase caption stays this long after it is fully typed (unless clicked).
const CAPTION_READ_TIME: float = 1.2
const LESSON_HOME_Y: float = 0.36
## Captions sit at the top, over the examiner card, so the circle and counters stay visible.
const CAPTION_HOME_Y: float = 0.12
const INTRO_HOME_Y: float = 0.62

@onready var _game_slot: Control = %GameSlot
@onready var _overlay: TutorialOverlay = %Overlay

var _flow: TutorialFlow = TutorialFlow.new()
## How many things cover the lesson right now (pause menu, books).
var _covers: int = 0
var _round: Control = null
var _speaker: String = "ilinca"
var _intro_line: int = 0
## Called on the next click of a talk bubble that is not a lesson step.
var _talk_then: Callable = Callable()
## Results that arrived during a Cast; applied once the Cast is fully played out.
var _pending: Array[Dictionary] = []
var _casting: bool = false
var _captions: Dictionary = {}
var _captions_shown: Dictionary = {}
var _caption_holding: bool = false
var _caption_timer: float = -1.0
var _idle_time: float = 0.0
var _idle_shown: bool = false
## The idle nudge is on screen; the next thing the player does puts it away.
var _idle_bubble: bool = false


func _ready() -> void:
	EventBus.reset()
	EventBus.tutorial_active = true
	_speaker = str(GameData.tutorial.get("speaker", "ilinca"))
	_flow.setup(GameData.tutorial)
	_overlay.advanced.connect(_on_overlay_advanced)
	_overlay.bubble_clicked.connect(_on_bubble_clicked)
	EventBus.stone_hovered.connect(func(rune_id: String) -> void: _feed("hover", {"rune": rune_id}))
	EventBus.selection_changed.connect(func(word: String, _spells: Array, runes: Array) -> void:
		_feed("selection", {"word": word, "runes": runes}))
	EventBus.cast.connect(_on_cast)
	EventBus.cast_resolved.connect(_on_cast_resolved)
	EventBus.swap.connect(func(count: int) -> void: _feed("swap", {"count": count}))
	EventBus.scoring_phase.connect(_on_scoring_phase)
	EventBus.spell_cast.connect(func(spell_id: String) -> void: _feed("spell_cast", {"spell": spell_id}))
	EventBus.spell_discovered.connect(func(spell_id: String) -> void: _feed("spell_discovered", {"spell": spell_id}))
	EventBus.round_won.connect(func() -> void: _feed("round_won", {}))
	EventBus.round_lost.connect(func() -> void: _feed("round_lost", {}))
	# A book or the pause menu covers the lesson; the light and the bubble wait behind it
	# (the Book of Runes opens over the pause menu, so covers are counted).
	EventBus.book_opened.connect(func(book_id: String) -> void:
		_cover(1)
		_feed("book_opened", {"book": book_id}))
	EventBus.book_closed.connect(func(book_id: String) -> void:
		_cover(-1)
		_feed("book_closed", {"book": book_id}))
	EventBus.pause_opened.connect(_cover.bind(1))
	EventBus.pause_closed.connect(_cover.bind(-1))
	_show_intro_line(0)


func _exit_tree() -> void:
	EventBus.reset()


func _cover(step: int) -> void:
	_covers = maxi(0, _covers + step)
	_overlay.visible = _covers == 0


func _process(delta: float) -> void:
	if _caption_holding and not _overlay.is_typing():
		_caption_timer -= delta
		if _caption_timer <= 0.0:
			_release_caption()
	_tick_idle(delta)


# --- Intro -------------------------------------------------------------------------------

func _show_intro_line(index: int) -> void:
	var intro: Dictionary = GameData.tutorial.get("intro", {})
	var lines: Array = intro.get("lines", [])
	_intro_line = index
	_overlay.home_y = INTRO_HOME_Y
	if index < lines.size():
		var line: Dictionary = lines[index]
		_talk(str(line.get("speaker", _speaker)), _format(line["text"]), _show_intro_line.bind(index + 1))
		return
	_show_intro_choice()


func _show_intro_choice() -> void:
	var intro: Dictionary = GameData.tutorial.get("intro", {})
	var lines: Array = intro.get("lines", [])
	if not lines.is_empty():
		var last: Dictionary = lines[lines.size() - 1]
		_overlay.say(str(last.get("speaker", _speaker)), _format(last["text"]), false)
		_overlay.finish_typing()
	_overlay.show_choices([
		{"text": Loc.text(intro.get("learn", {})), "callback": _start_lesson.bind(0)},
		{"text": Loc.text(intro.get("skip", {})), "callback": _confirm_skip},
	])


func _confirm_skip() -> void:
	var intro: Dictionary = GameData.tutorial.get("intro", {})
	_overlay.say(_speaker, _format(intro.get("confirm", {})), false)
	_overlay.show_choices([
		{"text": Loc.text(intro.get("confirm_yes", {})), "callback": _finish},
		{"text": Loc.text(intro.get("confirm_no", {})), "callback": _show_intro_choice},
	])


# --- Lessons -----------------------------------------------------------------------------

func _start_lesson(index: int) -> void:
	_flow.start_lesson(index)
	var lesson: Dictionary = _flow.lesson()
	if lesson.is_empty():
		_finish()
		return
	if _round != null:
		_round.queue_free()
		_round = null
	_overlay.clear()
	_talk_then = Callable()
	_pending.clear()
	_casting = false
	_covers = 0
	_overlay.visible = true
	_captions_shown.clear()
	_idle_time = 0.0
	_idle_shown = false
	_idle_bubble = false
	EventBus.set_gate(TutorialFlow.ALWAYS_ALLOWED)
	var round_screen: Control = ROUND_SCENE.instantiate()
	round_screen.set("config", {
		"title": GameData.ui_text.get("menu_tutorial", {}),
		"rule": Loc.both("tutorial_lesson_title", {"n": index + 1, "title": lesson["title"]}),
		"target": lesson["target"], "casts": lesson["casts"], "swaps": lesson["swaps"], "seed": lesson["seed"],
		"hand": lesson.get("hand", []), "bag_top": lesson.get("bag_top", []),
		"bag_only": lesson.get("bag_only", false), "spells": lesson.get("spells", true),
		"examiner": _speaker, "backdrop": "classroom",
		"hide_swap": int(lesson["swaps"]) == 0, "show_result": false,
	})
	_game_slot.add_child(round_screen)
	_round = round_screen
	_round.call("add_pause_action", "pause_skip_tutorial", _finish)
	_overlay.home_y = LESSON_HOME_Y
	# The hand lays its stones out on the next frame; light them up after that.
	await get_tree().process_frame
	await get_tree().process_frame
	_show_step()


func _show_step() -> void:
	var step: Dictionary = _flow.step()
	var gate: Dictionary = _flow.gate()
	var actions: Array[String] = []
	actions.assign(gate["actions"])
	var runes: Array[String] = []
	runes.assign(gate["runes"])
	EventBus.set_gate(actions, runes)
	_overlay.home_y = LESSON_HOME_Y
	if step.is_empty():
		_overlay.clear()
		return
	if bool(step.get("clear_selection", false)):
		_round.call("clear_selection")
	var targets: Array[Control] = []
	for id: Variant in step.get("spotlight", []):
		targets.append_array(_round.call("find_ui", str(id)) as Array[Control])
	_overlay.set_targets(targets)
	var labels: Array = []
	if str(step.get("labels", "")) == "meaning":
		for target: Control in targets:
			var stone: Variant = target.get("stone")
			if stone != null:
				var rune: Dictionary = GameData.runes.get(stone.get("rune_id"), {})
				labels.append({"control": target, "text": _short_meaning(rune)})
	_overlay.set_labels(labels)
	_overlay.say(str(step.get("speaker", _speaker)), _format(step["text"]), not _flow.is_waiting())
	# The player may already have done what this step asks (e.g. the stones are selected).
	var wait: Dictionary = step.get("wait_for", {})
	if str(wait.get("event", "")) == "selection":
		var info: Dictionary = _round.call("selection_info")
		_feed("selection", {"word": info["word"], "runes": info["runes"]}, false)


## A game event for the flow. During a Cast, results wait until the Cast is played out.
func _feed(event: String, args: Dictionary, reset_idle: bool = true) -> void:
	if _round == null:
		return
	if reset_idle and event != "round_won" and event != "round_lost":
		_idle_time = 0.0
		if _idle_bubble and event != "hover":
			_idle_bubble = false
			_overlay.hide_bubble()
	var result: Dictionary = _flow.handle(event, args)
	if _casting and result["result"] != "none":
		_pending.append(result)
		return
	_apply(result)


func _apply(result: Dictionary) -> void:
	var say: Variant = result.get("say")
	match str(result["result"]):
		"advance":
			if say != null:
				_talk(_speaker, _format(say), _show_step)
			else:
				_show_step()
		"wrong":
			if say != null:
				_overlay.say(_speaker, _format(say), false)
		"lesson_done":
			_lesson_done(say)
		"lesson_failed":
			EventBus.set_gate(TutorialFlow.ALWAYS_ALLOWED)
			_overlay.set_targets([] as Array[Control])
			_overlay.set_labels([])
			_talk(_speaker, _format(_flow.lesson().get("fail_text", {})), _start_lesson.bind(_flow.lesson_index))


func _lesson_done(say: Variant) -> void:
	EventBus.set_gate(TutorialFlow.ALWAYS_ALLOWED)
	_overlay.set_targets([] as Array[Control])
	_overlay.set_labels([])
	var next: Callable = _finish if _flow.is_last_lesson() else _start_lesson.bind(_flow.lesson_index + 1)
	var win_text: Variant = _flow.lesson().get("win_text")
	if say != null:
		_talk(_speaker, _format(say), _lesson_done.bind(null))
	elif win_text != null:
		_talk(_speaker, _format(win_text), next)
	else:
		next.call()


func _on_cast(word: String, runes: Array) -> void:
	var step: Dictionary = _flow.step()
	_casting = true
	_captions = step.get("phase_captions", {})
	if _round != null:
		_round.set("slow_scoring", bool(step.get("slow_scoring", false)))
	_overlay.clear()
	_feed("cast", {"word": word, "runes": runes})


func _on_cast_resolved() -> void:
	_casting = false
	_release_caption()
	_captions = {}
	if _round != null:
		_round.set("slow_scoring", false)
	var results: Array[Dictionary] = _pending.duplicate()
	_pending.clear()
	if results.is_empty():
		_show_step()
		return
	for result: Dictionary in results:
		_apply(result)


## Small captions during a slow Cast: "word", "stone", "total", "voice:<rune_id>".
func _on_scoring_phase(phase: String, rune_id: String, detail: String) -> void:
	if not _casting or _captions.is_empty():
		return
	var key: String = phase
	if phase == "voice":
		key = "voice:" + rune_id
	elif phase == "stone" and detail != "first":
		return
	if not _captions.has(key) or _captions_shown.has(key):
		return
	_captions_shown[key] = true
	_release_caption()
	_overlay.home_y = CAPTION_HOME_Y
	_overlay.say(_speaker, _format(_captions[key]), false)
	EventBus.hold_scoring()
	_caption_holding = true
	_caption_timer = CAPTION_READ_TIME


func _release_caption() -> void:
	if _caption_holding:
		_caption_holding = false
		EventBus.release_scoring()


func _on_bubble_clicked() -> void:
	if _idle_bubble:
		_idle_bubble = false
		_overlay.hide_bubble()
	if _caption_holding:
		_overlay.hide_bubble()
		_release_caption()


## A talk bubble outside the lesson steps (intro, corrections, lesson end).
func _talk(speaker: String, text: String, then: Callable) -> void:
	_talk_then = then
	_overlay.say(speaker, text, true)


func _on_overlay_advanced() -> void:
	if _talk_then.is_valid():
		var then: Callable = _talk_then
		_talk_then = Callable()
		then.call()
		return
	_apply(_flow.advance())


## Lesson 5: one nudge if the player does nothing for a while.
func _tick_idle(delta: float) -> void:
	var hint: Dictionary = _flow.lesson().get("idle_hint", {})
	if hint.is_empty() or _idle_shown or _round == null or _casting or not _flow.steps_done():
		return
	_idle_time += delta
	if _idle_time >= float(hint["seconds"]):
		_idle_shown = true
		_idle_bubble = true
		_overlay.say(_speaker, _format(hint["text"]), false)


func _finish() -> void:
	SaveManager.data["tutorial_done"] = true
	SaveManager.save_game()
	EventBus.reset()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _format(text: Variant) -> String:
	return Loc.text(text, {"name": str(SaveManager.data.get("player_name", ""))})


func _short_meaning(rune: Dictionary) -> String:
	return Loc.text(rune.get("meaning", {})).split(",")[0].split(";")[0].strip_edges()
