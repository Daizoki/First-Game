extends Control
## The round screen (DESIGN 3.16): hand of stones, Rune Circle, score, Power × Resonance,
## candles for Casts, chalk lines for Swaps, the examiner card. Stage 2 plays a practice
## round with a fixed target; the tutorial and the full exam (Stage 3) reuse this screen.
## It reports what happens on the EventBus and respects its action gate; it knows nothing
## about who listens.

const RoundState = preload("res://scripts/core/round_state.gd")
const Stone = preload("res://scripts/core/stone.gd")
const StoneView = preload("res://scripts/ui/stone_view.gd")
const ScoringPlayer = preload("res://scripts/ui/scoring_player.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const HandView = preload("res://scripts/ui/hand_view.gd")
const RuneCircle = preload("res://scripts/ui/rune_circle.gd")
const CandleRow = preload("res://scripts/ui/candle_row.gd")
const Portrait = preload("res://scripts/ui/portrait.gd")
const TalismanString = preload("res://scripts/ui/talisman_string.gd")
const SpellReveal = preload("res://scripts/ui/spell_reveal.gd")
const FloatLayer = preload("res://scripts/ui/float_layer.gd")
const StoneCard = preload("res://scripts/ui/stone_card.gd")
const WordBook = preload("res://scripts/ui/word_book.gd")
const WordCard = preload("res://scripts/ui/word_card.gd")
const RuneBook = preload("res://scripts/ui/rune_book.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")
const SentenceBar = preload("res://scripts/ui/sentence_bar.gd")
const ScrollSlot = preload("res://scripts/ui/scroll_slot.gd")
const ChoicePanel = preload("res://scripts/ui/choice_panel.gd")
const ActionLearned = preload("res://scripts/ui/action_learned.gd")

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const SPEEDS: Array[int] = [1, 2, 4]
const FUTHARK: Array[String] = ["fehu", "uruz", "thurisaz", "ansuz", "raidho"]
const SHAKE_SHARE: float = 0.35
## More Swaps than this are shown as "endless" (Aeva's Hourglass).
const ENDLESS_SWAPS: int = 12

@onready var _trial_label: Label = %TrialLabel
@onready var _coins_label: Label = %CoinsLabel
@onready var _coins_value: Label = %CoinsValue
@onready var _bag_label: Label = %BagLabel
@onready var _bag_value: Label = %BagValue
@onready var _seed_label: Label = %SeedLabel
@onready var _speed_button: Button = %SpeedButton
@onready var _menu_button: Button = %MenuButton
@onready var _score_value: Label = %ScoreValue
@onready var _score_target: Label = %ScoreTarget
@onready var _score_bar: ProgressBar = %ScoreBar
@onready var _power_value: Label = %PowerValue
@onready var _res_value: Label = %ResValue
@onready var _casts_label: Label = %CastsLabel
@onready var _candles: CandleRow = %Candles
@onready var _swaps_label: Label = %SwapsLabel
@onready var _chalk: CandleRow = %Chalk
@onready var _portrait: Portrait = %Portrait
@onready var _examiner_name: Label = %ExaminerName
@onready var _examiner_role: Label = %ExaminerRole
@onready var _rule_text: Label = %RuleText
@onready var _target_label: Label = %TargetLabel
@onready var _circle: RuneCircle = %RuneCircle
@onready var _word_name: Label = %WordName
@onready var _word_level: Label = %WordLevel
@onready var _scoring_count: Label = %ScoringCount
@onready var _preview_value: Label = %PreviewValue
@onready var _sentence_bar: SentenceBar = %SentenceBar
@onready var _scroll_slot: ScrollSlot = %ScrollSlot
@onready var _choice_panel: ChoicePanel = %ChoicePanel
@onready var _action_learned: ActionLearned = %ActionLearned
@onready var _talismans: TalismanString = %Talismans
@onready var _consumables: TalismanString = %Consumables
@onready var _kenaz_panel: Control = %KenazPanel
@onready var _kenaz_label: Label = %KenazLabel
@onready var _kenaz_stones: HBoxContainer = %KenazStones
@onready var _hand: HandView = %Hand
@onready var _sort_label: Label = %SortLabel
@onready var _sort_position: Button = %SortPositionButton
@onready var _sort_kin: Button = %SortKinButton
@onready var _cast_button: Button = %CastButton
@onready var _swap_button: Button = %SwapButton
@onready var _float_layer: FloatLayer = %FloatLayer
@onready var _toast: Label = %Toast
@onready var _spell_reveal: SpellReveal = %SpellReveal
@onready var _result_panel: Control = %ResultPanel
@onready var _result_title: Label = %ResultTitle
@onready var _result_score: Label = %ResultScore
@onready var _result_money: Label = %ResultMoney
@onready var _again_button: Button = %AgainButton
@onready var _result_menu_button: Button = %ResultMenuButton
@onready var _word_book_button: Button = %WordBookButton
@onready var _word_book: WordBook = %WordBook
@onready var _classroom: Control = %Classroom
@onready var _night: Control = %Backdrop
@onready var _pause_panel: Control = %PausePanel
@onready var _pause_title: Label = %PauseTitle
@onready var _pause_seed: Label = %PauseSeed
@onready var _pause_buttons: VBoxContainer = %PauseButtons
@onready var _resume_button: Button = %ResumeButton
@onready var _main_menu_button: Button = %MainMenuButton
@onready var _rune_book_button: Button = %RuneBookButton
@onready var _rune_book: RuneBook = %RuneBook

## Set before the screen enters the tree (the tutorial does it). Every key is optional:
##   title, rule: {"ro", "en"} texts for the card    target: int    seed: int
##   casts, swaps, hand, bag_top, bag_only, spells: see RoundState.setup
##   examiner: character id    backdrop: "night" | "classroom"
##   hide_swap: bool    show_result: bool (default true)
##   round_state: a RoundState already set up and started (the exam builds its rounds)
var config: Dictionary = {}
## Half-speed score animation (the tutorial explains it phase by phase).
var slow_scoring: bool = false

var _round: RoundState
var _seed: int = 0
var _busy: bool = false
var _speed: int = 1
var _shown_score: float = 0.0
var _player: ScoringPlayer
var _casts_total: int = 0
var _swaps_total: int = 0
## Extra pause-menu buttons: [{"key": ui_text key, "button": Button}].
var _pause_actions: Array[Dictionary] = []
var _card: StoneCard
var _word_card: WordCard
## The selection's preview (RoundState.preview), kept for the circle's card.
var _preview: Dictionary = {}
var _word_card_shown: bool = false
## A spell's pick waits for the player (the hand picks stones for it).
var _picking: bool = false


func _ready() -> void:
	_seed = int(config.get("seed", 0))
	if _seed == 0:
		_seed = randi()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _seed
	if config.has("round_state"):
		_round = config["round_state"]
	else:
		_round = RoundState.new()
		var target: float = float(config.get("target", GameData.rule("test_round_target", 1500)))
		_round.setup({"runes": GameData.runes, "words": GameData.words, "spells": GameData.spells,
			"spell_actions": GameData.spell_actions, "rules": GameData.rules, "economy": GameData.economy,
			"examiners": GameData.examiners, "talismans": GameData.talismans}, rng, target, config)
		_round.start()
	_casts_total = _round.casts_left
	_swaps_total = _round.swaps_left
	_speed = int(SaveManager.get_setting("scoring_speed", GameData.rule("scoring_speed", 1)))

	_player = ScoringPlayer.new()
	_player.host = self
	_player.float_layer = _float_layer
	_player.power_label = _power_value
	_player.res_label = _res_value
	_player.word_label = _word_name
	_player.level_label = _word_level
	_player.total_label = _preview_value
	_player.talisman_string = _talismans
	_talismans.moved.connect(_on_talisman_moved)

	_hand.max_selection = _round.max_selection()
	_hand.can_select = func(stone: Stone) -> bool:
		return _picking or (EventBus.is_allowed("select") and EventBus.can_select(stone.rune_id))
	# Before the evening class teaches the grammar, stones have no roles and no casting order.
	_hand.show_order = _round.spells_enabled
	_hand.show_roles = _round.spells_enabled
	_hand.selection_changed.connect(_on_selection_changed)
	_hand.stone_moved.connect(_on_stone_moved)
	_card = StoneCard.new()
	_card.show_role = _round.spells_enabled
	add_child(_card)
	_word_card = WordCard.new()
	add_child(_word_card)
	_hand.hover_changed.connect(func(view: StoneView) -> void:
		_card.show_stone(view.stone if view != null else null, view)
		EventBus.stone_hovered.emit(view.stone.rune_id if view != null else ""))
	_scroll_slot.visible = _round.spells_enabled
	_scroll_slot.pressed.connect(_on_scroll_pressed)
	_cast_button.pressed.connect(_on_cast_pressed)
	_swap_button.pressed.connect(_on_swap_pressed)
	_sort_position.pressed.connect(_on_sort.bind(true))
	_sort_kin.pressed.connect(_on_sort.bind(false))
	_speed_button.pressed.connect(_on_speed_pressed)
	_word_book_button.pressed.connect(open_word_book)
	_word_book.closed.connect(func() -> void: EventBus.book_closed.emit("words"))
	_menu_button.pressed.connect(open_pause)
	_resume_button.pressed.connect(close_pause)
	_rune_book_button.pressed.connect(open_rune_book)
	_rune_book.closed.connect(func() -> void:
		_pause_panel.modulate.a = 1.0
		EventBus.book_closed.emit("runes")
		_rune_book_button.grab_focus())
	_main_menu_button.pressed.connect(_go_to_menu)
	_result_menu_button.pressed.connect(_go_to_menu)
	_again_button.pressed.connect(func() -> void: get_tree().reload_current_scene())
	Loc.language_changed.connect(func(_language: String) -> void: _refresh_texts())
	EventBus.gate_changed.connect(_refresh_state)

	_portrait.character_id = str(config.get("examiner", GameData.rule("test_round_examiner", "ilinca")))
	var classroom: bool = str(config.get("backdrop", "night")) == "classroom"
	_classroom.visible = classroom
	_night.visible = not classroom
	var hide_swap: bool = bool(config.get("hide_swap", false))
	for node: CanvasItem in [_swap_button, _swaps_label, _chalk]:
		node.visible = not hide_swap
	_result_panel.visible = false
	_pause_panel.visible = false
	_toast.modulate.a = 0.0
	_rune_book.visible = false
	EventBus.round_started.emit()
	call_deferred("_show_hand")
	_refresh_texts()


func _exit_tree() -> void:
	EventBus.round_closed.emit()


## Lays the round's hand out on screen and reports it.
func _show_hand() -> void:
	_hand.set_stones(_round.hand)
	var runes: Array[String] = []
	for stone: Stone in _round.hand:
		runes.append(stone.rune_id)
	EventBus.hand_changed.emit(runes)


func _refresh_texts() -> void:
	var examiner: Dictionary = GameData.characters.get(_portrait.character_id, {})
	_trial_label.text = Loc.text(config["title"]) if config.has("title") else Loc.t("round_practice")
	_coins_label.text = Loc.t("round_coins")
	_bag_label.text = Loc.t("round_bag")
	_seed_label.text = Loc.t("round_seed", {"seed": _seed})
	_speed_button.text = Loc.t("round_speed", {"n": _speed})
	_menu_button.text = Loc.t("round_menu")
	_casts_label.text = Loc.t("round_casts")
	_swaps_label.text = Loc.t("round_swaps")
	_examiner_name.text = Loc.text(examiner.get("name", {}))
	_examiner_role.text = Loc.text(examiner.get("job", {}))
	_rule_text.text = Loc.text(config["rule"]) if config.has("rule") else Loc.t("round_practice_rule")
	_sort_label.text = Loc.t("round_sort")
	_sort_position.text = Loc.t("round_sort_position")
	_sort_kin.text = Loc.t("round_sort_kin")
	_cast_button.text = Loc.t("round_cast_button")
	_swap_button.text = Loc.t("round_swap_button")
	_kenaz_label.text = Loc.t("kenaz_peek")
	_talismans.empty_label = Loc.t("round_talisman_slot")
	_consumables.empty_label = Loc.t("round_consumable_slot")
	_again_button.text = Loc.t("result_again")
	_result_menu_button.text = Loc.t("result_menu")
	_word_book_button.text = Loc.t("word_book_button")
	_pause_title.text = Loc.t("pause_title")
	_pause_seed.text = Loc.t("round_seed", {"seed": _seed})
	_resume_button.text = Loc.t("pause_resume")
	_main_menu_button.text = Loc.t("pause_main_menu")
	_rune_book_button.text = Loc.t("pause_rune_book")
	for action: Dictionary in _pause_actions:
		(action["button"] as Button).text = Loc.t(action["key"])
	_refresh_state()
	_on_selection_changed()


## Counters, target, buttons and the Kenaz preview.
func _refresh_state() -> void:
	_coins_value.text = Loc.number(_round.money)
	_bag_value.text = Loc.t("round_bag_value", {"left": _round.bag.remaining(), "total": _round.bag.size()})
	_score_value.text = Loc.number(_shown_score)
	_score_target.text = Loc.t("round_score_of", {"target": Loc.number(_round.target)})
	_target_label.text = Loc.t("round_target", {"target": Loc.number(_round.target)})
	_score_bar.max_value = maxf(1.0, _round.target)
	_score_bar.value = minf(_shown_score, _round.target)
	_candles.total = maxi(_casts_total, _round.casts_left)
	_candles.left = _round.casts_left
	_chalk.total = maxi(_swaps_total, _round.swaps_left)
	_chalk.left = _round.swaps_left
	# Aeva's Hourglass: Swaps without end, no chalk to draw.
	var endless: bool = _round.swaps_left > ENDLESS_SWAPS
	_chalk.visible = not endless and not bool(config.get("hide_swap", false))
	_swaps_label.text = Loc.t("round_swaps_endless") if endless else Loc.t("round_swaps")
	var cost: int = _round.swap_cost()
	_swap_button.text = Loc.t("round_swap_button_cost", {"n": cost}) if cost > 0 else Loc.t("round_swap_button")
	var selection: Array[int] = _hand.selected_indices()
	_cast_button.disabled = _busy or not _round.can_cast(selection) or not EventBus.is_allowed("cast")
	_swap_button.disabled = _busy or not _round.can_swap(selection) or not EventBus.is_allowed("swap")
	_sort_position.disabled = _busy or not EventBus.is_allowed("sort")
	_sort_kin.disabled = _sort_position.disabled
	_speed_button.disabled = not EventBus.is_allowed("speed")
	_menu_button.disabled = not EventBus.is_allowed("menu")
	_word_book_button.disabled = not EventBus.is_allowed("word_book")
	_hand.enabled = not _busy or (_picking and _choice_panel.uses_hand())
	_talismans.set_owned(_round.talismans, 0 if _round.active_rule() == "trick" else -1)
	_talismans.enabled = not _busy
	_scroll_slot.spell_id = _round.scroll_spell()
	_scroll_slot.armed = _round.scroll_armed()
	_scroll_slot.enabled = not _busy and EventBus.is_allowed("cast")
	_refresh_kenaz()


func _refresh_kenaz() -> void:
	for child: Node in _kenaz_stones.get_children():
		child.queue_free()
	var next: Array[Stone] = _round.kenaz_peek()
	_kenaz_panel.visible = not next.is_empty()
	for stone: Stone in next:
		var glyph: RuneGlyphScript = RuneGlyphScript.new()
		glyph.custom_minimum_size = Vector2(64, 64)
		glyph.rune_id = stone.rune_id
		_kenaz_stones.add_child(glyph)


## What is selected right now: {"word": id or "", "spells": [...], "runes": [...]}.
func selection_info() -> Dictionary:
	var indices: Array[int] = _hand.selected_indices()
	var preview: Dictionary = _round.preview(indices)
	var runes: Array[String] = []
	for i: int in indices:
		runes.append(_round.hand[i].rune_id)
	return {"word": preview.get("word", ""), "spells": preview.get("spells", []), "runes": runes}


func clear_selection() -> void:
	_hand.clear_selection()


## UI elements with this tutorial id (metadata "tutorial_id"), or the stones of
## "stone:<rune_id>" in hand.
func find_ui(id: String) -> Array[Control]:
	var found: Array[Control] = []
	if id.begins_with("stone:"):
		for view: StoneView in _hand.views_with_rune(id.substr(6)):
			found.append(view)
		return found
	for node: Node in find_children("*", "Control", true, false):
		if node.get_meta("tutorial_id", "") == id and (node as Control).is_visible_in_tree():
			found.append(node as Control)
	return found


## Adds a button to the pause menu (above "Main menu"). key: ui_text key.
func add_pause_action(key: String, callback: Callable) -> void:
	var button: Button = Button.new()
	button.custom_minimum_size = _resume_button.custom_minimum_size
	button.text = Loc.t(key)
	button.pressed.connect(callback)
	_pause_buttons.add_child(button)
	_pause_buttons.move_child(button, _main_menu_button.get_index())
	_pause_actions.append({"key": key, "button": button})


func open_pause() -> void:
	if _pause_panel.visible:
		return
	_pause_panel.visible = true
	_resume_button.grab_focus()
	EventBus.pause_opened.emit()


func close_pause() -> void:
	if not _pause_panel.visible or _rune_book.visible:
		return
	_pause_panel.visible = false
	EventBus.pause_closed.emit()


## The Book of Runes, over the pause menu.
func open_rune_book() -> void:
	if _rune_book.visible:
		return
	_rune_book.open()
	# The pause menu waits behind the book without showing through it.
	_pause_panel.modulate.a = 0.0
	EventBus.book_opened.emit("runes")


## The Book of Words over the round (button or key C).
func open_word_book() -> void:
	if _word_book.visible or _pause_panel.visible or not EventBus.is_allowed("word_book"):
		return
	_word_book.open(_round.word_levels)
	EventBus.book_opened.emit("words")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo \
			and (event as InputEventKey).keycode == KEY_C:
		get_viewport().set_input_as_handled()
		open_word_book()
		return
	if _word_book.visible or _rune_book.visible:
		return
	if event.is_action_pressed("ui_cancel") and EventBus.is_allowed("menu"):
		get_viewport().set_input_as_handled()
		if _pause_panel.visible:
			close_pause()
		else:
			open_pause()


## The middle of the Rune Circle: Word, scoring stones, Power × Resonance, Spells.
func _on_selection_changed() -> void:
	if _picking:
		_choice_panel.set_hand_picks(_hand.selected_indices().size())
		return
	if _busy:
		return
	var info: Dictionary = selection_info()
	EventBus.selection_changed.emit(info["word"], info["spells"], info["runes"])
	var preview: Dictionary = _round.preview(_hand.selected_indices())
	_preview = preview
	_set_word_card(false)
	_circle.glow_color = Color(0, 0, 0, 0)
	_circle.awakening = false
	_sentence_bar.clear()
	if preview.is_empty():
		_word_name.text = Loc.t("circle_hint")
		_word_level.text = ""
		_scoring_count.text = ""
		_preview_value.text = ""
		_power_value.text = "0"
		_res_value.text = "0"
	elif _selection_has_face_down():
		# Lunet's Dream: a face-down stone keeps its secret until it is cast.
		_word_name.text = Loc.t("word_hidden")
		_word_level.text = ""
		_scoring_count.text = Loc.t("circle_face_down")
		_preview_value.text = ""
		_power_value.text = "?"
		_res_value.text = "?"
		_preview = {}
	else:
		_word_name.text = _word_display_name(preview["word"])
		_word_level.text = Loc.t("circle_level", {"n": _round.word_level(preview["word"])})
		var count: int = (preview["scoring"] as Array).size()
		_scoring_count.text = Loc.t("circle_scoring_one") if count == 1 else Loc.t("circle_scoring_many", {"n": count})
		_preview_value.text = "%s × %s" % [Loc.number(preview["power"]), Loc.number(preview["res"])]
		_power_value.text = Loc.number(preview["power"])
		_res_value.text = Loc.number(preview["res"])
		_show_sentence(preview.get("sentence", {}), preview.get("plan", {}))
	_preview_value.modulate.a = 1.0
	_refresh_state()


## The circle's card follows the mouse over the middle of the circle.
func _process(_delta: float) -> void:
	var covered: bool = _pause_panel.visible or _word_book.visible or _rune_book.visible or _result_panel.visible
	_set_word_card(not _busy and not covered and not _preview.is_empty() and _mouse_over_circle())


func _selection_has_face_down() -> bool:
	for i: int in _hand.selected_indices():
		if _round.hand[i].face_down:
			return true
	return false


func _mouse_over_circle() -> bool:
	var rect: Rect2 = _circle.get_global_rect()
	var radius: float = minf(rect.size.x, rect.size.y) * 0.5 - 12.0
	return get_global_mouse_position().distance_to(rect.get_center()) <= radius


## Shows or hides the circle's card; while shown, the scoring stones glow in hand.
func _set_word_card(wanted: bool) -> void:
	if wanted == _word_card_shown:
		return
	_word_card_shown = wanted
	if not wanted:
		_word_card.hide_card()
		_hand.mark_scoring([])
		return
	var word_id: String = _preview["word"]
	var word: Dictionary = GameData.words[word_id]
	var known: bool = not bool(word.get("hidden", false)) or SaveManager.has_discovery("words", word_id)
	_word_card.show_word(_word_display_name(word_id),
		Loc.text(word["description"]) if known else Loc.t("word_hidden"),
		_preview, _round.word_level(word_id), _hand.selected_indices().size(), _circle)
	_hand.mark_scoring(_preview["scoring"])


## The sentence the selection reads, in its slots under the circle; the circle glows in the
## spell's color (and pulses while the spell is still a mystery).
func _show_sentence(parsed: Dictionary, plan: Dictionary) -> void:
	_sentence_bar.show_sentence(parsed, plan)
	var status: String = str(parsed.get("status", ""))
	if status == SentenceParser.SPELL:
		var spell_id: String = parsed["spell"]
		var color: Color = Color("#e9e3d2")
		if SaveManager.has_discovery("spells", spell_id):
			color = Color.html(str(GameData.spells[spell_id].get("color", "#e9e3d2")))
		else:
			_circle.awakening = true
		_circle.glow_color = color
	if not status.is_empty():
		EventBus.sentence_read.emit(status, str(parsed.get("spell", "")), (parsed.get("actions", []) as Array).size())


func _word_display_name(word_id: String) -> String:
	var word: Dictionary = GameData.words[word_id]
	if bool(word.get("hidden", false)) and not SaveManager.has_discovery("words", word_id):
		return Loc.t("word_hidden")
	return Loc.text(word["name"])


## Talismans act left to right: dragging one changes the exam's order.
func _on_talisman_moved(from: int, to: int) -> void:
	if _busy:
		return
	var item: Dictionary = _round.talismans.pop_at(from)
	_round.talismans.insert(clampi(to, 0, _round.talismans.size()), item)
	_refresh_state()


func _on_stone_moved(from: int, to: int) -> void:
	_round.move_stone(from, to)
	_on_selection_changed()


func _on_sort(by_position: bool) -> void:
	if _busy:
		return
	_hand.clear_selection()
	if by_position:
		_round.sort_by_position()
	else:
		_round.sort_by_kin()
	_hand.set_stones(_round.hand)


func _on_swap_pressed() -> void:
	var count: int = _hand.selected_indices().size()
	if _busy or not EventBus.is_allowed("swap") or not _round.swap(_hand.selected_indices()):
		return
	_show_hand()
	EventBus.swap.emit(count)
	_on_selection_changed()


func _on_cast_pressed() -> void:
	var selection: Array[int] = _hand.selected_indices()
	if _busy or not EventBus.is_allowed("cast") or not _round.can_cast(selection):
		return
	var info: Dictionary = selection_info()
	EventBus.cast.emit(info["word"], info["runes"])
	_busy = true
	_refresh_state()
	var held_views: Array[StoneView] = []
	for i: int in _round.hand.size():
		if not selection.has(i):
			held_views.append(_hand.view_at(i))
	_sentence_bar.clear()
	var result: Dictionary = _round.cast(selection)
	# The scorer's indices follow the casting order.
	var cast_views: Array[StoneView] = []
	for stone: Stone in result["cast_stones"]:
		cast_views.append(_hand.view_for(stone))
	result["won"] = _round.is_won()
	result["lost"] = false
	_player.speed = float(_speed) * (0.5 if slow_scoring else 1.0)
	await _player.play(result, cast_views, held_views)
	await _add_score(float(result["score"]))
	await _announce(result)
	for view: StoneView in cast_views:
		view.selected = false
		var tween: Tween = view.create_tween()
		tween.tween_property(view, "modulate:a", 0.0, 0.25 / float(_speed))
	await get_tree().create_timer(0.25 / float(_speed)).timeout
	_show_hand()
	await _resolve_picks()
	_busy = false
	_on_selection_changed()
	EventBus.cast_resolved.emit()
	if _round.is_won() or _round.is_lost():
		_finish_round()


## The spells' picks, one after another. Stones are picked in the hand; where the player may
## not select (a tutorial step) the round answers by itself.
func _resolve_picks() -> void:
	while not _round.pending.is_empty():
		var choice: Dictionary = _round.current_choice()
		var limits: Dictionary = _round.pick_limits(choice)
		if not EventBus.is_allowed("select") or limits.is_empty():
			if not _round.answer(_round.auto_answer()):
				_round.skip_choice()
			_show_hand()
			continue
		_picking = true
		_hand.clear_selection()
		_hand.show_order = false
		_hand.max_selection = maxi(1, _choice_panel_max(limits))
		var stones: Array = []
		match str(limits["source"]):
			"talisman":
				stones = _round.talismans
			"bag_top":
				stones = _round.bag.peek(int(limits["count"]))
			"offer":
				stones = _round.offer
		_choice_panel.ask(choice, limits, {"money": _round.money, "stones": stones, "kins": _round.kin_choices()})
		_refresh_state()
		var reply: Dictionary = await _choice_panel.answered
		if str(limits["source"]) == "hand":
			reply["stones"] = _hand.selected_indices()
		if not _round.answer(reply):
			_round.skip_choice()
		_choice_panel.close()
		_picking = false
		_hand.clear_selection()
		_hand.max_selection = _round.max_selection()
		_hand.show_order = _round.spells_enabled
		_show_hand()
		_refresh_state()


func _choice_panel_max(limits: Dictionary) -> int:
	return int(limits.get("max", 0)) if str(limits.get("source", "")) == "hand" else 0


## A click on the Scroll: ready to happen with the next Cast, or put away again.
func _on_scroll_pressed() -> void:
	if _busy or not _round.has_scroll():
		return
	if _round.scroll_armed():
		_round.disarm_scroll()
	else:
		_round.use_scroll()
	_refresh_state()


## The round score counts up; big casts shake the screen.
func _add_score(amount: float) -> void:
	if amount >= _round.target * SHAKE_SHARE:
		_shake()
	var tween: Tween = create_tween()
	tween.tween_method(_set_shown_score, _shown_score, _shown_score + amount, 0.6 / float(_speed))
	await tween.finished


func _set_shown_score(value: float) -> void:
	_shown_score = value
	_score_value.text = Loc.number(roundf(value))
	_score_bar.value = minf(value, _round.target)


## Spells, discoveries and the FUÞAR easter egg after a Cast.
func _announce(result: Dictionary) -> void:
	var word_id: String = result["word"]
	var word: Dictionary = GameData.words[word_id]
	if bool(word.get("hidden", false)) and SaveManager.add_discovery("words", word_id):
		await _show_toast(Loc.t("word_discovered", {"name": Loc.text(word["name"])}))
	if word_id == "chant" and _spells_out(result["cast_stones"]) == FUTHARK:
		await _show_toast(Loc.t("futhark_message"))
	for gone: String in result.get("talismans_gone", []):
		await _show_toast(Loc.t("talisman_gone", {"name": Loc.text((GameData.talismans.get(gone, {}) as Dictionary).get("name", {}))}))
	var plans: Array = result["plans"]
	for n: int in plans.size():
		var plan: Dictionary = plans[n]
		var id: String = plan["spell"]
		var spell: Dictionary = GameData.spells[id]
		# The Scroll's spell rides along as the last plan.
		if not str(result["scroll_used"]).is_empty() and n == plans.size() - 1:
			await _show_toast(Loc.t("scroll_happened", {"name": Loc.text(spell["name"]),
				"effect": SpellText.effect(spell, float(plan["scale"]))}))
			continue
		if SaveManager.add_discovery("spells", id):
			var memories: int = int(GameData.rule("memories_per_spell", 5))
			SaveManager.data["memories"] = int(SaveManager.data.get("memories", 0)) + memories
			SaveManager.save_game()
			EventBus.overlay_opened.emit("spell_reveal")
			_spell_reveal.reveal(spell, memories)
			await _spell_reveal.closed
			EventBus.overlay_closed.emit("spell_reveal")
			EventBus.spell_discovered.emit(id)
		elif bool(plan["fizzled"]):
			await _show_toast(Loc.t("spell_fizzled", {"name": Loc.text(spell["name"])}))
		elif bool(plan["gift"]):
			await _show_toast(Loc.t("spell_scroll_kept", {"name": Loc.text(spell["name"])}))
		else:
			await _show_toast("%s: %s" % [Loc.text(spell["name"]), SpellText.effect(spell, float(plan["scale"]))])
		for action_id: String in plan["actions"]:
			if SaveManager.add_discovery("actions", action_id):
				_action_learned.center = _circle.get_global_rect().get_center() - get_global_rect().position
				await _action_learned.play(action_id, float(_speed))
		if bool(plan["gift"]):
			EventBus.scroll_gained.emit(id)
		EventBus.spell_sentence_cast.emit(id, plan["actions"])
		EventBus.spell_cast.emit(id)
	_refresh_state()


func _spells_out(stones: Array) -> Array[String]:
	var ids: Array[String] = []
	for stone: Stone in stones:
		ids.append(stone.rune_id)
	return ids


func _show_toast(text: String) -> void:
	_toast.text = text
	var tween: Tween = create_tween()
	tween.tween_property(_toast, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.4 / float(_speed) + 0.4)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.3)
	await tween.finished


func _shake() -> void:
	var tween: Tween = create_tween()
	for i: int in 8:
		tween.tween_property(self, "position", Vector2(randf_range(-14, 14), randf_range(-10, 10)), 0.035)
	tween.tween_property(self, "position", Vector2.ZERO, 0.05)


func _finish_round() -> void:
	var finished: Dictionary = _round.finish()
	_refresh_state()
	if _round.is_won():
		EventBus.round_won.emit()
	else:
		EventBus.round_lost.emit()
	if not bool(config.get("show_result", true)):
		return
	_result_title.text = Loc.t("result_won_title") if _round.is_won() else Loc.t("result_lost_title")
	_result_score.text = Loc.t("result_score", {"score": Loc.number(_round.score), "target": Loc.number(_round.target)})
	_result_money.text = Loc.t("result_money", {"n": finished["money"]}) if int(finished["money"]) > 0 else ""
	_result_panel.visible = true
	_again_button.grab_focus()


func _on_speed_pressed() -> void:
	_speed = SPEEDS[(SPEEDS.find(_speed) + 1) % SPEEDS.size()]
	SaveManager.set_setting("scoring_speed", _speed)
	_speed_button.text = Loc.t("round_speed", {"n": _speed})


func _go_to_menu() -> void:
	EventBus.reset()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
