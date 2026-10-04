extends Control
## The Morning of the exam (DESIGN 3.11), the hub of Aeva's loop: Aeva greets the player (a
## line that knows how many mornings it has been), and from here the player goes on with the
## saved exam or begins a new one (choosing a parent), spends Memories, reads the Book of
## Runes, looks at the Collection, repeats the evening class or opens the Settings.
## The rules (Memories, unlocks, records) are in scripts/core/progress.gd.

const Portrait = preload("res://scripts/ui/portrait.gd")
const RuneBook = preload("res://scripts/ui/rune_book.gd")
const MemoriesShop = preload("res://scripts/ui/memories_shop.gd")
const ExamState = preload("res://scripts/core/exam_state.gd")
const ExamScreen = preload("res://scripts/ui/exam_screen.gd")
const Progress = preload("res://scripts/core/progress.gd")

const PARENT_SCENE: String = "res://scenes/parent_select.tscn"
const EXAM_SCENE: String = "res://scenes/exam.tscn"
const COLLECTION_SCENE: String = "res://scenes/collection.tscn"
## Until the new evening class (Stage 5 step H) it is a practice fight.
const PRACTICE_SCENE: String = "res://scenes/round.tscn"
const SETTINGS_SCENE: String = "res://scenes/settings.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const MEMORY_COLOR: Color = Color("#b59be0")

@onready var _content: Control = %Content

var _aeva_line: Label
var _memories: Label
var _buttons: VBoxContainer
var _rune_book: RuneBook
var _memories_shop: MemoriesShop
var _confirm: Control
## The saved exam, if there is one that still fits the data.
var _saved: ExamState = null


func _ready() -> void:
	_load_saved_exam()
	_build()
	Loc.language_changed.connect(func(_language: String) -> void: _rebuild())
	if RunState.came_from_class:
		RunState.came_from_class = false
		EventBus.evening_class_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _confirm != null and _confirm.visible:
		_confirm.visible = false
		get_viewport().set_input_as_handled()


func _load_saved_exam() -> void:
	_saved = null
	var saved: Dictionary = SaveManager.data.get("current_exam", {})
	if saved.is_empty() or not (saved.get("state") is Dictionary):
		return
	var exam: ExamState = ExamState.new()
	if exam.load_dict(ExamScreen.tables(), saved["state"]):
		_saved = exam
	else:
		# A save from an older version of the game: it cannot go on.
		SaveManager.data["current_exam"] = {}
		SaveManager.save_game()


func _rebuild() -> void:
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_build()


func _build() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 60)
	_content.add_child(margin)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 60)
	margin.add_child(columns)
	columns.add_child(_build_aeva())
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columns.add_child(spacer)
	columns.add_child(_build_menu())
	_rune_book = RuneBook.new()
	_rune_book.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_content.add_child(_rune_book)
	_rune_book.closed.connect(func() -> void: _focus_first())
	_memories_shop = MemoriesShop.new()
	_content.add_child(_memories_shop)
	_memories_shop.closed.connect(func() -> void:
		_refresh_memories()
		_focus_first())
	_confirm = _build_confirm()
	_content.add_child(_confirm)
	_refresh_memories()
	_focus_first()


## Left: Aeva and what she says this morning, the player and the records.
func _build_aeva() -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(760, 0)
	box.add_theme_constant_override("separation", 18)
	box.alignment = BoxContainer.ALIGNMENT_END
	var panel: PanelContainer = PanelContainer.new()
	box.add_child(panel)
	var inner: VBoxContainer = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 14)
	panel.add_child(inner)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	inner.add_child(row)
	var portrait: Portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(170, 170)
	portrait.character_id = "aeva"
	row.add_child(portrait)
	var who: VBoxContainer = VBoxContainer.new()
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(who)
	var aeva: Dictionary = GameData.characters.get("aeva", {})
	_label(who, Loc.text(aeva.get("name", {})), 48, &"TitleLabel")
	_label(who, Loc.text(aeva.get("job", {})), 22, &"SecondaryLabel")
	_aeva_line = _label(inner, "„%s”" % _greeting(), 30, &"")
	_aeva_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aeva_line.custom_minimum_size = Vector2(700, 0)
	var you: Label = _label(box, Loc.t("morning_you", {"name": str(SaveManager.data.get("player_name", ""))}), 30, &"TitleLabel")
	you.add_theme_color_override("font_color", Color("#e9e3d2"))
	var stats: Dictionary = SaveManager.data.get("stats", {})
	var line: Label = _label(box, Loc.t("morning_stats", {
		"trial": int(stats.get("best_trial", 0)), "total": GameData.realms.size(),
		"passed": int(stats.get("exams_passed", 0)), "cast": Loc.number(float(stats.get("best_cast_score", 0.0))),
	}), 22, &"SecondaryLabel")
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size = Vector2(700, 0)
	return box


## Right: the title, Memories and the buttons.
func _build_menu() -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(560, 0)
	box.add_theme_constant_override("separation", 12)
	var title: Label = _label(box, Loc.t("morning_title"), 64, &"TitleLabel")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var attempt: Label = _label(box, Loc.t("morning_attempt", {"n": int(SaveManager.data.get("attempts", 0)) + (0 if _saved != null else 1)}),
		26, &"SecondaryLabel")
	attempt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_memories = _label(box, "", 36, &"TitleLabel")
	_memories.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_memories.add_theme_color_override("font_color", MEMORY_COLOR)
	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 10)
	box.add_child(_buttons)
	if _saved != null:
		var go_on: Button = _button(Loc.t("morning_continue"), _on_continue, true)
		go_on.custom_minimum_size = Vector2(0, 110)
		go_on.text += "\n" + Loc.t("morning_continue_info", {
			"trial": _saved.trial_index + 1, "total": _saved.trial_count(),
			"round": Loc.t("exam_round_" + _saved.round_kind()), "money": _saved.money,
		})
	_button(Loc.t("morning_new_exam"), _on_new_exam, _saved == null)
	_button(Loc.t("morning_unlocks"), func() -> void: _memories_shop.open(), false)
	_button(Loc.t("morning_rune_book"), func() -> void: _rune_book.open(), false)
	_button(Loc.t("morning_collection"), func() -> void: get_tree().change_scene_to_file(COLLECTION_SCENE), false)
	_button(Loc.t("morning_evening_class"), _on_evening_class, false)
	_button(Loc.t("morning_settings"), func() -> void:
		RunState.back_scene = scene_file_path
		get_tree().change_scene_to_file(SETTINGS_SCENE), false)
	_button(Loc.t("morning_menu"), func() -> void: get_tree().change_scene_to_file(MAIN_MENU_SCENE), false)
	return box


## Aeva's line for this morning (data/dialogs.json).
func _greeting() -> String:
	var pick: Dictionary = Progress.morning_dialog(SaveManager.data, _saved != null)
	var lines: Array = (GameData.dialogs.get(str(pick["id"]), {}) as Dictionary).get("lines", []).duplicate()
	# After a failed exam Aeva may also say any of her usual lines.
	if str(pick["id"]) == "aeva_morning_after_loss":
		lines.append_array((GameData.dialogs.get("aeva_morning", {}) as Dictionary).get("lines", []))
	if lines.is_empty():
		return ""
	var line: Dictionary = lines[randi() % lines.size()]
	return Loc.text(line["text"], pick["args"])


func _refresh_memories() -> void:
	_memories.text = Loc.t("morning_memories", {"n": Progress.memories(SaveManager.data)})


func _focus_first() -> void:
	if _buttons != null and _buttons.get_child_count() > 0:
		_focus_later(_buttons.get_child(0) as Button)


## Focus after this frame, unless the screen is gone by then (a button already changed scene).
func _focus_later(button: Button) -> void:
	_grab_focus_if_alive.call_deferred(weakref(button))


func _grab_focus_if_alive(ref: WeakRef) -> void:
	var button: Button = ref.get_ref() as Button
	if button != null and button.is_inside_tree():
		button.grab_focus()


# --- Actions -------------------------------------------------------------------------------

func _on_continue() -> void:
	RunState.request_exam("", true)
	get_tree().change_scene_to_file(EXAM_SCENE)


func _on_new_exam() -> void:
	if _saved != null:
		_confirm.visible = true
		return
	get_tree().change_scene_to_file(PARENT_SCENE)


## Beginning a new exam closes the saved one: it counts as finished (its Memories are paid).
func _abandon_and_begin() -> void:
	if _saved != null:
		Progress.finish_exam(SaveManager.data, _saved, GameData.rules)
		SaveManager.data["current_exam"] = {}
		SaveManager.save_game()
		_saved = null
	get_tree().change_scene_to_file(PARENT_SCENE)


func _on_evening_class() -> void:
	get_tree().change_scene_to_file(PRACTICE_SCENE)


# --- Building blocks -------------------------------------------------------------------------

func _build_confirm() -> Control:
	var layer: Control = Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.visible = false
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.05, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	center.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	_label(box, Loc.t("morning_abandon_title"), 44, &"TitleLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var text: Label = _label(box, Loc.t("morning_abandon_text"), 26, &"")
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(760, 0)
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	var yes: Button = Button.new()
	yes.text = Loc.t("morning_abandon_yes")
	yes.custom_minimum_size = Vector2(300, 70)
	yes.pressed.connect(_abandon_and_begin)
	row.add_child(yes)
	var no: Button = Button.new()
	no.text = Loc.t("morning_abandon_no")
	no.custom_minimum_size = Vector2(300, 70)
	no.theme_type_variation = &"CastButton"
	no.pressed.connect(func() -> void:
		layer.visible = false
		_focus_first())
	row.add_child(no)
	layer.visibility_changed.connect(func() -> void:
		if layer.visible:
			_focus_later(no))
	return layer


func _button(text: String, callback: Callable, main: bool) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 66)
	button.add_theme_font_size_override("font_size", 28)
	if main:
		button.theme_type_variation = &"CastButton"
	button.pressed.connect(callback)
	_buttons.add_child(button)
	return button


func _label(parent: Control, text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
