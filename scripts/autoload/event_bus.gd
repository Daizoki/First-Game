extends Node
## Game events that listeners (the tutorial, the hints) react to. The game only emits;
## it never knows who listens. Listeners never change game logic directly: the only
## thing they may set is the action gate below, which the game checks.

## A round screen opened (round_closed when it leaves the screen, won or not).
signal round_started
signal round_closed
## The stones in hand changed (dealt, refilled, swapped): their runes, in hand order.
signal hand_changed(rune_ids: Array)
## The mouse went over a stone in hand ("" when it left every stone).
signal stone_hovered(rune_id: String)
## The selection in hand changed: the Word it forms ("" = none), Spells it would cast,
## the runes selected (hand order).
signal selection_changed(word_key: String, spell_ids: Array, rune_ids: Array)
## A Cast starts (before the score animation).
signal cast(word_key: String, rune_ids: Array)
## The Cast is fully played out (score counted, Spells revealed); the hand is refilled.
signal cast_resolved
signal swap(count: int)
## The score animation reached a phase: "word", "stone", "voice", "total".
## rune_id is the stone involved ("" for word / total); detail is e.g. the Voice kind.
signal scoring_phase(phase: String, rune_id: String, detail: String)
## A Spell was cast (every time, after its reveal or toast).
signal spell_cast(spell_id: String)
## The same, with the Actions of its sentence (rune ids, in order).
signal spell_sentence_cast(spell_id: String, actions: Array)
## The selection reads a sentence of the rune grammar: its SentenceParser status ("spell",
## "incomplete", "wrong_order" …), the spell ("" if none) and how many Actions it has.
signal sentence_read(status: String, spell_id: String, action_count: int)
## Gebo kept a spell on the Scroll.
signal scroll_gained(spell_id: String)
## Something covers the whole game for a moment (the spell reveal).
signal overlay_opened(overlay_id: String)
signal overlay_closed(overlay_id: String)
## A Spell was cast for the first time ever.
signal spell_discovered(spell_id: String)
signal round_won
signal round_lost
## The exam screen introduced an examiner round (the examiner's character id).
signal examiner_met(examiner_id: String)
## The exam ended: passed all trials, or failed a round.
signal exam_finished(passed: bool)
signal book_opened(book_id: String)
signal book_closed(book_id: String)
signal pause_opened
signal pause_closed
## The action gate changed (the round screen refreshes its buttons).
signal gate_changed
## A scoring hold was released (see hold_scoring).
signal scoring_released

## Actions the player may take: "select", "cast", "swap", "sort", "speed", "menu", "word_book".
## Empty = everything is allowed. Hovering is always allowed.
var allowed_actions: Array[String] = []
## When not empty, only stones with these runes can be selected.
var selectable_runes: Array[String] = []
## Set while the tutorial runs (hints stay quiet).
var tutorial_active: bool = false

var _scoring_holds: int = 0


func is_allowed(action: String) -> bool:
	return allowed_actions.is_empty() or allowed_actions.has(action)


func can_select(rune_id: String) -> bool:
	return selectable_runes.is_empty() or selectable_runes.has(rune_id)


func set_gate(actions: Array[String], runes: Array[String] = []) -> void:
	allowed_actions = actions.duplicate()
	selectable_runes = runes.duplicate()
	gate_changed.emit()


func clear_gate() -> void:
	set_gate([], [])


## A listener asks the score animation to wait (e.g. while a caption is read).
func hold_scoring() -> void:
	_scoring_holds += 1


func release_scoring() -> void:
	_scoring_holds = maxi(0, _scoring_holds - 1)
	if _scoring_holds == 0:
		scoring_released.emit()


func scoring_held() -> bool:
	return _scoring_holds > 0


## Back to a neutral state (leaving the tutorial, tests).
func reset() -> void:
	tutorial_active = false
	_scoring_holds = 0
	clear_gate()
