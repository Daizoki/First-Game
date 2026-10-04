extends Control
## The exam (DESIGN 3.1, 3.8): before every round a board names the trial, the round, the
## examiner, the target and (in the examiner round) the rule; then the round screen plays the
## round; after it, the board shows the Coins won, or the end of the exam. Stage 3D puts the
## Night Market between the rounds. The logic lives in scripts/core/exam_state.gd.

const ExamState = preload("res://scripts/core/exam_state.gd")
const RoundState = preload("res://scripts/core/round_state.gd")
const Portrait = preload("res://scripts/ui/portrait.gd")

const ROUND_SCENE: PackedScene = preload("res://scenes/round.tscn")
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
## Seconds the finished round stays on screen before the board comes back.
const ROUND_END_PAUSE: float = 1.6
const MONEY_COLOR: Color = Color("#ebaa3c")
const RULE_COLOR: Color = Color("#ffb347")

var exam: ExamState

@onready var _round_slot: Control = %RoundSlot
@onready var _board: Control = %Board
@onready var _box: VBoxContainer = %BoardBox

var _round_screen: Control = null
var _state: RoundState = null
var _waiting_for_round: bool = false


func _ready() -> void:
	EventBus.round_won.connect(_on_round_over)
	EventBus.round_lost.connect(_on_round_over)
	start_exam()


func _exit_tree() -> void:
	RunState.end_exam(exam != null and exam.passed)


## A new exam with a random seed (or the given one).
func start_exam(seed_value: int = 0) -> void:
	exam = ExamState.new()
	exam.setup(tables(), seed_value if seed_value != 0 else randi())
	RunState.start_exam("", exam.exam_seed)
	SaveManager.data["attempts"] = int(SaveManager.data.get("attempts", 0)) + 1
	SaveManager.save_game()
	_show_intro()


## The GameData tables the exam logic needs.
static func tables() -> Dictionary:
	return {
		"runes": GameData.runes, "words": GameData.words, "spells": GameData.spells,
		"spell_actions": GameData.spell_actions, "rules": GameData.rules, "economy": GameData.economy,
		"trials": GameData.trials, "examiners": GameData.examiners, "talismans": GameData.talismans,
		"lessons": GameData.lessons, "engravings": GameData.engravings,
	}


# --- The board before a round --------------------------------------------------------------

func _show_intro() -> void:
	_clear_board()
	var examiner: Dictionary = exam.examiner()
	var character: Dictionary = GameData.characters.get(exam.examiner_id(), {})
	_label(Loc.t("exam_trial", {"n": exam.trial_index + 1, "total": exam.trial_count()}), 30, &"SecondaryLabel")
	_label(Loc.t("exam_round_" + exam.round_kind()), 64, &"TitleLabel")
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	_box.add_child(row)
	var portrait: Portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(150, 150)
	portrait.character_id = exam.examiner_id()
	row.add_child(portrait)
	var who: VBoxContainer = VBoxContainer.new()
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(who)
	_label(Loc.text(character.get("name", {})), 44, &"TitleLabel", who, HORIZONTAL_ALIGNMENT_LEFT)
	_label(Loc.text(character.get("job", {})), 22, &"SecondaryLabel", who, HORIZONTAL_ALIGNMENT_LEFT)
	_label(Loc.t("round_target", {"target": Loc.number(exam.target())}), 40, &"").add_theme_color_override(
		"font_color", RULE_COLOR)
	if exam.round_kind() == "examiner":
		var rule: Label = _label(Loc.t("exam_rule", {"title": Loc.text(examiner.get("title", {})),
			"text": Loc.text(examiner.get("text", {}))}), 28, &"")
		rule.add_theme_color_override("font_color", RULE_COLOR)
		_label("„%s”" % Loc.text(examiner.get("intro", {})), 26, &"SecondaryLabel")
		EventBus.examiner_met.emit(exam.examiner_id())
	else:
		_label(Loc.t("exam_no_rule"), 24, &"SecondaryLabel")
	_peek_line()
	_label(Loc.t("exam_money", {"n": exam.money}), 28, &"").add_theme_color_override("font_color", MONEY_COLOR)
	_button(Loc.t("exam_start_round"), _start_round, true)


## Sun against the Examiner: who waits in the next trials.
func _peek_line() -> void:
	var count: int = int(exam.carry.get("peek_examiners", 0))
	if count <= 0:
		return
	var names: PackedStringArray = []
	for id: String in exam.upcoming_examiners(count):
		var entry: Dictionary = GameData.examiners.get(id, {})
		names.append("%s (%s)" % [Loc.text((GameData.characters.get(id, {}) as Dictionary).get("name", {})),
			Loc.text(entry.get("title", {}))])
	if not names.is_empty():
		_label(Loc.t("exam_peek", {"list": ", ".join(names)}), 22, &"SecondaryLabel")


# --- The round -----------------------------------------------------------------------------

func _start_round() -> void:
	_board.visible = false
	_state = exam.new_round()
	var examiner: Dictionary = exam.examiner()
	var rule: Dictionary = Loc.both("exam_no_rule")
	if exam.round_kind() == "examiner":
		rule = {}
		for language: String in ["ro", "en"]:
			rule[language] = "%s: %s" % [(examiner["title"] as Dictionary)[language], (examiner["text"] as Dictionary)[language]]
	_round_screen = ROUND_SCENE.instantiate()
	_round_screen.set("config", {
		"round_state": _state, "seed": exam.exam_seed, "examiner": exam.examiner_id(), "backdrop": "night",
		"title": Loc.both("exam_title_" + exam.round_kind(), {"n": exam.trial_index + 1}), "rule": rule,
		"show_result": false,
	})
	_round_slot.add_child(_round_screen)
	_waiting_for_round = true


func _on_round_over() -> void:
	if not _waiting_for_round:
		return
	_waiting_for_round = false
	await get_tree().create_timer(ROUND_END_PAUSE).timeout
	var summary: Dictionary = exam.finish_round(_state)
	_round_screen.queue_free()
	_round_screen = null
	if bool(summary["exam_over"]):
		_show_result(summary)
	elif bool(summary.get("second_chance", false)):
		_show_second_chance()
	else:
		_show_reward(summary)


# --- The board after a round ---------------------------------------------------------------

func _show_reward(summary: Dictionary) -> void:
	_clear_board()
	_label(Loc.t("exam_round_won"), 60, &"TitleLabel")
	var defeated: String = str(summary["defeated"])
	if not defeated.is_empty():
		var entry: Dictionary = GameData.examiners.get(defeated, {})
		_label(Loc.t("exam_defeated", {"name": Loc.text((GameData.characters.get(defeated, {}) as Dictionary).get("name", {}))}),
			32, &"")
		_label("„%s”" % Loc.text(entry.get("defeated", {})), 26, &"SecondaryLabel")
	var reward: Dictionary = summary["reward"]
	_label(Loc.t("exam_reward_" + str(summary["kind"]), {"n": reward["round"]}), 28, &"")
	if int(reward["casts"]) > 0:
		_label(Loc.t("exam_reward_casts", {"n": reward["casts"]}), 28, &"")
	if int(reward["interest"]) > 0:
		_label(Loc.t("exam_reward_interest", {"n": reward["interest"]}), 28, &"")
	_label(Loc.t("exam_reward_total", {"n": reward["total"], "money": exam.money}), 34, &"").add_theme_color_override(
		"font_color", MONEY_COLOR)
	_button(Loc.t("exam_continue"), _show_intro, true)


## Aeva's Hourglass broke: the same round once more.
func _show_second_chance() -> void:
	_clear_board()
	_label(Loc.t("exam_second_chance_title"), 60, &"TitleLabel")
	_label(Loc.t("exam_second_chance_text"), 28, &"")
	_button(Loc.t("exam_retry"), _show_intro, true)


func _show_result(summary: Dictionary) -> void:
	_clear_board()
	var passed: bool = bool(summary["exam_passed"])
	EventBus.exam_finished.emit(passed)
	var aeva: Dictionary = GameData.examiners.get("aeva", {})
	if passed:
		_label(Loc.t("exam_passed_title"), 72, &"TitleLabel")
		_label("„%s”" % Loc.text(aeva.get("defeated", {})), 28, &"SecondaryLabel")
	else:
		_label(Loc.t("exam_failed_title"), 72, &"TitleLabel")
		var by: Dictionary = exam.examiner()
		_label("%s: „%s”" % [Loc.text((GameData.characters.get(exam.examiner_id(), {}) as Dictionary).get("name", {})),
			Loc.text(by.get("won", {}))], 28, &"")
		_label("%s: „%s”" % [Loc.text((GameData.characters.get("aeva", {}) as Dictionary).get("name", {})),
			Loc.text(aeva.get("won", {}))], 26, &"SecondaryLabel")
	_label(Loc.t("exam_stats", {"trial": exam.trial_index + 1, "total": exam.trial_count(),
		"defeated": exam.defeated.size(), "rounds": exam.rounds_won}), 26, &"")
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	_box.add_child(row)
	_button(Loc.t("exam_again"), func() -> void: start_exam(), true, row)
	_button(Loc.t("result_menu"), _go_to_menu, false, row)


func _go_to_menu() -> void:
	EventBus.reset()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


# --- Helpers -------------------------------------------------------------------------------

func _clear_board() -> void:
	for child: Node in _box.get_children():
		_box.remove_child(child)
		child.queue_free()
	_board.visible = true


func _label(text: String, font_size: int, variation: StringName, parent: Control = null,
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = align
	# Lines of the board wrap at its width; short lines inside a row keep their own width.
	if parent == null:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(820, 0)
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	(parent if parent != null else _box).add_child(label)
	return label


func _button(text: String, callback: Callable, main: bool, parent: Control = null) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(340, 80)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if main:
		button.theme_type_variation = &"CastButton"
	button.pressed.connect(callback)
	(parent if parent != null else _box).add_child(button)
	if main:
		button.call_deferred("grab_focus")
	return button
