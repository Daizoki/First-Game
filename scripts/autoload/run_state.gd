extends Node
## State of the current exam attempt (one run). Lives only in memory:
## in the first version a run is not saved when the game closes.
## Filled in during Stage 3 (exam) and Stage 4 (loop and memories).

signal run_started
signal run_ended(won: bool)

var active: bool = false
var parent_id: String = ""
var max_hp: int = 0
var hp: int = 0
## Card ids in the deck (duplicates allowed).
var deck: Array[String] = []
var blessings: Array[String] = []
var trial_index: int = 0
var step_index: int = 0
## Counters used to award memories at the end: fights, elites, examiners won.
var stats: Dictionary = {}


func reset() -> void:
	active = false
	parent_id = ""
	max_hp = 0
	hp = 0
	deck.clear()
	blessings.clear()
	trial_index = 0
	step_index = 0
	stats = {"fights_won": 0, "elites_won": 0, "examiners_won": 0}


func start_run(god_id: String, starting_hp: int, starting_deck: Array[String]) -> void:
	reset()
	active = true
	parent_id = god_id
	max_hp = starting_hp
	hp = starting_hp
	deck.assign(starting_deck)
	run_started.emit()


func end_run(won: bool) -> void:
	active = false
	run_ended.emit(won)
