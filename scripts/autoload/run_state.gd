extends Node
## State of the exam in progress. Every random choice of the exam goes through `rng`,
## so an exam can be replayed exactly from its seed (shown in the pause menu).
## Filled in during Stage 2 (round) and Stage 3 (full exam).

signal exam_started
signal exam_ended(passed: bool)

var active: bool = false
var exam_seed: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var parent_id: String = ""
## 0-based: trial 0..7, round 0..2 (small question, big question, examiner).
var trial_index: int = 0
var round_index: int = 0
var money: int = 0
## What the exam screen should do when it opens (set by the Morning): go on with the saved
## exam, or start a new one with this parent.
var resume_requested: bool = false
var next_parent: String = ""


func reset() -> void:
	active = false
	exam_seed = 0
	rng = RandomNumberGenerator.new()
	parent_id = ""
	trial_index = 0
	round_index = 0
	money = 0


## The Morning asks for an exam: a new one with this parent, or the saved one.
func request_exam(parent: String, resume: bool) -> void:
	next_parent = parent
	resume_requested = resume


## Starts a new exam. A seed of 0 picks a random one.
func start_exam(chosen_parent_id: String, chosen_seed: int = 0) -> void:
	reset()
	active = true
	parent_id = chosen_parent_id
	exam_seed = chosen_seed if chosen_seed != 0 else randi()
	rng.seed = exam_seed
	exam_started.emit()


func end_exam(passed: bool) -> void:
	active = false
	exam_ended.emit(passed)
