extends Control
## The Journey (docs/PROMPT_ETAPA5.md 3; provisional boards until step G): before every fight
## a board names the Realm, the monster, its life, its weaknesses and (for a Lord) its rule;
## then the fight screen plays the fight; after it, the board shows the Coins won, or the end
## of the Journey. The Night Market comes between the fights. The logic lives in
## scripts/core/exam_state.gd.

const ExamState = preload("res://scripts/core/exam_state.gd")
const FightState = preload("res://scripts/core/fight_state.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")
const RoundScreen = preload("res://scripts/ui/round_screen.gd")
const Portrait = preload("res://scripts/ui/portrait.gd")
const ShopLogic = preload("res://scripts/core/shop_logic.gd")
const ShopScreen = preload("res://scripts/ui/shop_screen.gd")
const Progress = preload("res://scripts/core/progress.gd")

const ROUND_SCENE: PackedScene = preload("res://scenes/round.tscn")
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const MORNING_SCENE: String = "res://scenes/morning.tscn"
const TimeRewind = preload("res://scripts/ui/time_rewind.gd")
const MEMORY_COLOR: Color = Color("#b59be0")
## Seconds the finished round stays on screen before the board comes back.
const ROUND_END_PAUSE: float = 1.6
const MONEY_COLOR: Color = Color("#ebaa3c")
const RULE_COLOR: Color = Color("#ffb347")
const PHASE_BOARD: String = "board"
const PHASE_SHOP: String = "shop"

var exam: ExamState

@onready var _round_slot: Control = %RoundSlot
@onready var _board: Control = %Board
@onready var _box: VBoxContainer = %BoardBox

var _round_screen: Control = null
var _state: FightState = null
var _waiting_for_round: bool = false


func _ready() -> void:
	EventBus.round_won.connect(_on_round_over)
	EventBus.round_lost.connect(_on_round_over)
	var resume: bool = RunState.resume_requested
	RunState.resume_requested = false
	if not (resume and resume_exam()):
		start_exam(RunState.next_parent)


func _exit_tree() -> void:
	RunState.end_exam(exam != null and exam.passed)


## A new exam with this parent and a random seed (or the given one).
func start_exam(parent: String = "", seed_value: int = 0) -> void:
	exam = ExamState.new()
	exam.setup(tables(), seed_value if seed_value != 0 else randi(), parent)
	exam.unlocked_talismans = Progress.unlocked_talismans(SaveManager.data, GameData.talismans)
	for item: Dictionary in exam.consumables:
		Progress.record_seen(SaveManager.data, "engravings", str(item["id"]))
	RunState.start_exam(parent, exam.exam_seed)
	SaveManager.data["attempts"] = int(SaveManager.data.get("attempts", 0)) + 1
	_save_exam(PHASE_BOARD)
	_show_intro()


## Goes on with the exam saved after the last round (or the last Market). False if there is
## none, or it does not fit the current data.
func resume_exam() -> bool:
	var saved: Dictionary = SaveManager.data.get("current_exam", {})
	var loaded: ExamState = ExamState.new()
	if saved.is_empty() or not (saved.get("state") is Dictionary) or not loaded.load_dict(tables(), saved["state"]):
		return false
	exam = loaded
	RunState.start_exam(exam.parent_id, exam.exam_seed)
	if str(saved.get("phase", "")) == PHASE_SHOP:
		_open_shop()
	else:
		_show_intro()
	return true


## The exam in progress is saved between rounds: before the board ("board") or before the
## Market ("shop"). Quitting in the middle of a round goes back to the last save.
func _save_exam(phase: String) -> void:
	SaveManager.data["current_exam"] = {"phase": phase, "state": exam.to_dict()}
	SaveManager.save_game()


func _clear_saved_exam() -> void:
	SaveManager.data["current_exam"] = {}
	SaveManager.save_game()


## The GameData tables the Journey needs.
static func tables() -> Dictionary:
	return RoundScreen.tables()


# --- The board before a round --------------------------------------------------------------

func _show_intro() -> void:
	_clear_board()
	var monster_id: String = exam.monster_id()
	var entry: Dictionary = exam.monster_entry()
	if Progress.record_seen(SaveManager.data, "monsters", monster_id):
		SaveManager.save_game()
	var realm_line: String = Loc.t("exam_trial", {"n": exam.trial_index + 1, "total": exam.trial_count(),
		"name": Loc.text(exam.trial().get("name", {}))})
	if not exam.parent_id.is_empty():
		realm_line += " · " + Loc.t("exam_parent", {"name": Loc.text((GameData.characters.get(exam.parent_id, {}) as Dictionary).get("name", {}))})
	_label(realm_line, 30, &"SecondaryLabel")
	_label(Loc.t("exam_round_" + exam.round_kind()), 64, &"TitleLabel")
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	_box.add_child(row)
	var portrait: Portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(150, 150)
	portrait.character_id = monster_id
	row.add_child(portrait)
	var who: VBoxContainer = VBoxContainer.new()
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(who)
	_label(Loc.text(entry.get("name", {})), 44, &"TitleLabel", who, HORIZONTAL_ALIGNMENT_LEFT)
	_label(Loc.t("exam_monster_hp", {"n": Loc.number(exam.monster_hp())}), 26, &"", who,
		HORIZONTAL_ALIGNMENT_LEFT).add_theme_color_override("font_color", RULE_COLOR)
	_label(Loc.text(entry.get("description", {})), 24, &"SecondaryLabel")
	var traits: String = _traits_line(entry)
	if not traits.is_empty():
		_label(traits, 24, &"")
	if exam.round_kind() == "boss":
		var rule: Label = _label(Loc.t("exam_rule", {"text": SpellText.rule_text(entry)}), 28, &"")
		rule.add_theme_color_override("font_color", RULE_COLOR)
		EventBus.examiner_met.emit(monster_id)
	else:
		_label(Loc.t("exam_no_rule"), 24, &"SecondaryLabel")
	_peek_line()
	_label(Loc.t("exam_money", {"n": exam.money}), 28, &"").add_theme_color_override("font_color", MONEY_COLOR)
	_button(Loc.t("exam_start_round"), _start_round, true)


## Weak to Fire · Resists Ice … (the Balaur's first head).
func _traits_line(entry: Dictionary) -> String:
	var lists: Dictionary = entry
	var heads: Array = entry.get("heads", [])
	if not heads.is_empty():
		lists = heads[0]
	var parts: PackedStringArray = []
	for key: String in ["weak", "resist", "immune"]:
		var names: PackedStringArray = []
		for element: Variant in lists.get(key, []):
			names.append(SpellText.element_name(str(element)))
		if not names.is_empty():
			parts.append(Loc.t("monster_" + key, {"list": ", ".join(names)}))
	return " · ".join(parts)


## Sun upon the Lord: who waits in the next Realms.
func _peek_line() -> void:
	var count: int = int(exam.carry.get("peek_examiners", 0))
	if count <= 0:
		return
	var names: PackedStringArray = []
	for id: String in exam.upcoming_bosses(count):
		var entry: Dictionary = GameData.monsters.get(id, {})
		names.append("%s (%s)" % [Loc.text(entry.get("name", {})), SpellText.rule_text(entry)])
	if not names.is_empty():
		_label(Loc.t("exam_peek", {"list": ", ".join(names)}), 22, &"SecondaryLabel")


# --- The round -----------------------------------------------------------------------------

func _start_round() -> void:
	_board.visible = false
	_state = exam.new_round()
	_round_screen = ROUND_SCENE.instantiate()
	_round_screen.set("config", {
		"fight": _state, "seed": exam.exam_seed, "backdrop": "night",
		"title": Loc.both("exam_title_" + exam.round_kind(), {"n": exam.trial_index + 1}), "show_result": false,
	})
	_round_slot.add_child(_round_screen)
	_waiting_for_round = true


func _on_round_over() -> void:
	if not _waiting_for_round:
		return
	_waiting_for_round = false
	await get_tree().create_timer(ROUND_END_PAUSE).timeout
	Progress.record_round(SaveManager.data, _state.best_cast_damage, exam.element_levels)
	var summary: Dictionary = exam.finish_round(_state)
	_round_screen.queue_free()
	_round_screen = null
	if bool(summary["exam_over"]):
		_clear_saved_exam()
		_show_result(summary)
	elif bool(summary.get("second_chance", false)):
		_save_exam(PHASE_BOARD)
		_show_second_chance()
	else:
		_save_exam(PHASE_SHOP)
		_show_reward(summary)


# --- The board after a round ---------------------------------------------------------------

func _show_reward(summary: Dictionary) -> void:
	_clear_board()
	_label(Loc.t("exam_round_won"), 60, &"TitleLabel")
	var defeated: String = str(summary["defeated"])
	if not defeated.is_empty():
		_label(Loc.t("exam_defeated", {"name": Loc.text((GameData.monsters.get(defeated, {}) as Dictionary).get("name", {}))}),
			32, &"")
	var reward: Dictionary = summary["reward"]
	_label(Loc.t("exam_reward_" + str(summary["kind"]), {"n": reward["round"]}), 28, &"")
	if int(reward["casts"]) > 0:
		_label(Loc.t("exam_reward_casts", {"n": reward["casts"]}), 28, &"")
	if int(reward["interest"]) > 0:
		_label(Loc.t("exam_reward_interest", {"n": reward["interest"]}), 28, &"")
	_label(Loc.t("exam_reward_total", {"n": reward["total"], "money": exam.money}), 34, &"").add_theme_color_override(
		"font_color", MONEY_COLOR)
	_button(Loc.t("exam_continue"), _open_shop, true)


## The Night Market between two rounds.
func _open_shop() -> void:
	_board.visible = false
	var spells_known: Array[String] = []
	var discoveries: Dictionary = SaveManager.data.get("discoveries", {})
	for category: String in ["spells", "torn_pages"]:
		for spell_id: Variant in discoveries.get(category, []):
			spells_known.append(str(spell_id))
	var logic: ShopLogic = ShopLogic.new()
	logic.setup(exam, tables(), spells_known)
	var screen: ShopScreen = ShopScreen.new()
	_round_slot.add_child(screen)
	screen.open(logic)
	screen.closed.connect(func() -> void:
		screen.queue_free()
		_save_exam(PHASE_BOARD)
		_show_intro())


## Aeva's Hourglass broke: the same round once more.
func _show_second_chance() -> void:
	_clear_board()
	_label(Loc.t("exam_second_chance_title"), 60, &"TitleLabel")
	_label(Loc.t("exam_second_chance_text"), 28, &"")
	_button(Loc.t("exam_retry"), _show_intro, true)


func _show_result(summary: Dictionary) -> void:
	_clear_board()
	var passed: bool = bool(summary["exam_passed"])
	var earned: Dictionary = Progress.finish_exam(SaveManager.data, exam, GameData.rules)
	SaveManager.save_game()
	EventBus.exam_finished.emit(passed)
	if passed:
		_label(Loc.t("exam_passed_title"), 72, &"TitleLabel")
		_label(Loc.t("exam_passed_text"), 28, &"SecondaryLabel")
	else:
		_label(Loc.t("exam_failed_title"), 72, &"TitleLabel")
		_label(Loc.t("exam_failed_by", {"name": Loc.text(exam.monster_entry().get("name", {}))}), 28, &"")
		_label(Loc.t("exam_failed_text"), 26, &"SecondaryLabel")
	_label(Loc.t("exam_stats", {"trial": exam.trial_index + 1, "total": exam.trial_count(),
		"defeated": exam.defeated.size(), "rounds": exam.rounds_won}), 26, &"")
	_show_memories(earned)
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	_box.add_child(row)
	_button(Loc.t("exam_to_morning"), _go_to_morning.bind(passed), true, row)
	_button(Loc.t("result_menu"), _go_to_menu, false, row)


## What the exam brought: Memories for the rounds, the examiners and passing.
func _show_memories(earned: Dictionary) -> void:
	_label(Loc.t("exam_memories_title", {"n": earned["total"]}), 40, &"TitleLabel").add_theme_color_override(
		"font_color", MEMORY_COLOR)
	var parts: PackedStringArray = []
	for key: String in ["rounds", "examiners", "passed"]:
		if int(earned[key]) > 0:
			parts.append(Loc.t("exam_memories_" + key, {"n": earned[key]}))
	if not parts.is_empty():
		_label(" · ".join(parts), 24, &"SecondaryLabel")
	_label(Loc.t("exam_memories_total", {"n": Progress.memories(SaveManager.data)}), 24, &"")


## Back to the Morning; after a failed exam Aeva turns back time first.
func _go_to_morning(passed: bool) -> void:
	if not passed:
		var rewind: TimeRewind = TimeRewind.new()
		add_child(rewind)
		await rewind.play()
	EventBus.reset()
	get_tree().change_scene_to_file(MORNING_SCENE)


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
		_grab_focus_if_alive.call_deferred(weakref(button))
	return button


## Focus after this frame, unless the button is gone by then.
func _grab_focus_if_alive(ref: WeakRef) -> void:
	var button: Button = ref.get_ref() as Button
	if button != null and button.is_inside_tree():
		button.grab_focus()
