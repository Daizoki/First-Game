extends Control
## The fight screen (docs/PROMPT_ETAPA5.md 9; provisional layout until step G): the hand of
## stones, the Rune Circle that reads the spells, the damage estimate, candles for Casts,
## chalk lines for Swaps, and the monster's card with its life bar. A practice fight against
## the Training Dummy when opened alone; the Journey (exam_screen) builds its own fights.
## It reports what happens on the EventBus and respects its action gate; it knows nothing
## about who listens.

const FightState = preload("res://scripts/core/fight_state.gd")
const Monster = preload("res://scripts/core/monster.gd")
const Stone = preload("res://scripts/core/stone.gd")
const StoneView = preload("res://scripts/ui/stone_view.gd")
const ScoringPlayer = preload("res://scripts/ui/scoring_player.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const HandView = preload("res://scripts/ui/hand_view.gd")
const RuneCircle = preload("res://scripts/ui/rune_circle.gd")
const CandleRow = preload("res://scripts/ui/candle_row.gd")
const Portrait = preload("res://scripts/ui/portrait.gd")
const HpBar = preload("res://scripts/ui/hp_bar.gd")
const TalismanString = preload("res://scripts/ui/talisman_string.gd")
const SpellReveal = preload("res://scripts/ui/spell_reveal.gd")
const FloatLayer = preload("res://scripts/ui/float_layer.gd")
const StoneCard = preload("res://scripts/ui/stone_card.gd")
const RuneBook = preload("res://scripts/ui/rune_book.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")
const SentenceBar = preload("res://scripts/ui/sentence_bar.gd")
const ScrollSlot = preload("res://scripts/ui/scroll_slot.gd")
const ChoicePanel = preload("res://scripts/ui/choice_panel.gd")
const ActionLearned = preload("res://scripts/ui/action_learned.gd")

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const SPEEDS: Array[int] = [1, 2, 4]
## A hit bigger than this share of the monster's life shakes the screen.
const SHAKE_SHARE: float = 0.3
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
@onready var _estimate_label: Label = %EstimateLabel
@onready var _estimate_value: Label = %EstimateValue
@onready var _estimate_note: Label = %EstimateNote
@onready var _power_value: Label = %PowerValue
@onready var _res_value: Label = %ResValue
@onready var _casts_label: Label = %CastsLabel
@onready var _candles: CandleRow = %Candles
@onready var _swaps_label: Label = %SwapsLabel
@onready var _chalk: CandleRow = %Chalk
@onready var _monster_card: Control = %MonsterCard
@onready var _portrait: Portrait = %Portrait
@onready var _monster_name: Label = %MonsterName
@onready var _hp_bar: HpBar = %HpBar
@onready var _monster_traits: Label = %MonsterTraits
@onready var _monster_status: Label = %MonsterStatus
@onready var _rule_box: Control = %RuleBox
@onready var _rule_text: Label = %RuleText
@onready var _circle: RuneCircle = %RuneCircle
@onready var _spell_name: Label = %SpellName
@onready var _spell_second: Label = %SpellSecond
@onready var _circle_info: Label = %CircleInfo
@onready var _preview_value: Label = %PreviewValue
@onready var _sentence_bar: SentenceBar = %SentenceBar
@onready var _scroll_slot: ScrollSlot = %ScrollSlot
@onready var _choice_panel: ChoicePanel = %ChoicePanel
@onready var _action_learned: ActionLearned = %ActionLearned
@onready var _talismans: TalismanString = %Talismans
@onready var _consumables: TalismanString = %Consumables
@onready var _peek_panel: Control = %PeekPanel
@onready var _peek_label: Label = %PeekLabel
@onready var _peek_stones: HBoxContainer = %PeekStones
@onready var _hand: HandView = %Hand
@onready var _sort_label: Label = %SortLabel
@onready var _sort_role: Button = %SortRoleButton
@onready var _sort_kin: Button = %SortKinButton
@onready var _cast_button: Button = %CastButton
@onready var _swap_button: Button = %SwapButton
@onready var _float_layer: FloatLayer = %FloatLayer
@onready var _toast: Label = %Toast
@onready var _spell_reveal: SpellReveal = %SpellReveal
@onready var _result_panel: Control = %ResultPanel
@onready var _result_title: Label = %ResultTitle
@onready var _result_damage: Label = %ResultDamage
@onready var _result_money: Label = %ResultMoney
@onready var _again_button: Button = %AgainButton
@onready var _result_menu_button: Button = %ResultMenuButton
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

## Set before the screen enters the tree. Every key is optional:
##   title: {"ro", "en"} text for the top left    seed: int
##   monster: monster id for a practice fight (default: rules "test_fight_monster")
##   casts, swaps, hand, bag_top, bag_only, spells: see FightState.setup
##   backdrop: "night" | "classroom"    hide_swap: bool    show_result: bool (default true)
##   fight: a FightState already set up and started (the Journey builds its fights)
var config: Dictionary = {}
## Half-speed animation (the tutorial explains it phase by phase).
var slow_scoring: bool = false

var _fight: FightState
var _seed: int = 0
var _busy: bool = false
var _speed: int = 1
var _player: ScoringPlayer
var _casts_total: int = 0
var _swaps_total: int = 0
## Extra pause-menu buttons: [{"key": ui_text key, "button": Button}].
var _pause_actions: Array[Dictionary] = []
var _card: StoneCard
## The selection's preview (FightState.preview).
var _preview: Dictionary = {}
## A spell's pick waits for the player (the hand picks stones for it).
var _picking: bool = false


func _ready() -> void:
	_seed = int(config.get("seed", 0))
	if _seed == 0:
		_seed = randi()
	if config.has("fight"):
		_fight = config["fight"]
	else:
		_fight = practice_fight(config, _seed)
	_casts_total = _fight.casts_left
	_swaps_total = _fight.swaps_left
	_speed = int(SaveManager.get_setting("scoring_speed", GameData.rule("scoring_speed", 1)))

	_player = ScoringPlayer.new()
	_player.host = self
	_player.float_layer = _float_layer
	_player.power_label = _power_value
	_player.res_label = _res_value
	_player.spell_label = _spell_name
	_player.total_label = _preview_value
	_player.monster_card = _monster_card
	_player.hp_bar = _hp_bar
	_player.monster = _fight.monster
	_player.talisman_string = _talismans
	_player.on_hit = func(amount: float) -> void:
		if amount >= _fight.monster.max_hp * SHAKE_SHARE:
			_shake()
	_talismans.moved.connect(_on_talisman_moved)
	_consumables.consumable_mode = true
	_consumables.used.connect(_on_consumable_used)

	_hand.max_selection = _fight.max_selection()
	_hand.can_select = func(stone: Stone) -> bool:
		return _picking or (EventBus.is_allowed("select") and EventBus.can_select(stone.rune_id))
	# Before the evening class teaches the grammar, stones have no roles and no casting order.
	_hand.show_order = _fight.spells_enabled
	_hand.show_roles = _fight.spells_enabled
	_hand.selection_changed.connect(_on_selection_changed)
	_hand.stone_moved.connect(_on_stone_moved)
	_card = StoneCard.new()
	_card.show_role = _fight.spells_enabled
	_card.levels = _fight.element_levels
	add_child(_card)
	_hand.hover_changed.connect(func(view: StoneView) -> void:
		_card.show_stone(view.stone if view != null else null, view)
		EventBus.stone_hovered.emit(view.stone.rune_id if view != null else ""))
	_scroll_slot.visible = _fight.spells_enabled
	_scroll_slot.pressed.connect(_on_scroll_pressed)
	_cast_button.pressed.connect(_on_cast_pressed)
	_swap_button.pressed.connect(_on_swap_pressed)
	_sort_role.pressed.connect(_on_sort.bind(true))
	_sort_kin.pressed.connect(_on_sort.bind(false))
	_speed_button.pressed.connect(_on_speed_pressed)
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

	_portrait.character_id = _fight.monster.id
	_reset_monster_bar()
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
	call_deferred("_resolve_start_picks")
	_refresh_texts()


## A practice fight against one monster with its life from data (the Training Dummy unless
## config names another).
static func practice_fight(options: Dictionary, seed_value: int) -> FightState:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var monster_id: String = str(options.get("monster", GameData.rule("test_fight_monster", "dummy")))
	var entry: Dictionary = GameData.monsters.get(monster_id, {})
	var monster: Monster = Monster.new()
	monster.setup(entry, float(entry.get("hp", 100)))
	var fight: FightState = FightState.new()
	fight.setup(tables(), rng, monster, options)
	fight.start()
	return fight


## The GameData tables a fight needs.
static func tables() -> Dictionary:
	return {
		"runes": GameData.runes, "elements": GameData.elements, "targets": GameData.targets,
		"spells": GameData.spells, "spell_actions": GameData.spell_actions, "rules": GameData.rules,
		"economy": GameData.economy, "talismans": GameData.talismans, "lessons": GameData.lessons,
		"engravings": GameData.engravings, "monsters": GameData.monsters, "realms": GameData.realms,
		"parents": GameData.parents,
	}


func _exit_tree() -> void:
	EventBus.round_closed.emit()


## Lays the fight's hand out on screen and reports it.
func _show_hand() -> void:
	_hand.set_stones(_fight.hand)
	var runes: Array[String] = []
	for stone: Stone in _fight.hand:
		runes.append(stone.rune_id)
	EventBus.hand_changed.emit(runes)


func _refresh_texts() -> void:
	_trial_label.text = Loc.text(config["title"]) if config.has("title") else Loc.t("round_practice")
	_coins_label.text = Loc.t("round_coins")
	_bag_label.text = Loc.t("round_bag")
	_seed_label.text = Loc.t("round_seed", {"seed": _seed})
	_speed_button.text = Loc.t("round_speed", {"n": _speed})
	_menu_button.text = Loc.t("round_menu")
	_estimate_label.text = Loc.t("round_estimate")
	_casts_label.text = Loc.t("round_casts")
	_swaps_label.text = Loc.t("round_swaps")
	_monster_name.text = Loc.text(_fight.monster.entry.get("name", {}))
	_sort_label.text = Loc.t("round_sort")
	_sort_role.text = Loc.t("round_sort_role")
	_sort_kin.text = Loc.t("round_sort_kin")
	_cast_button.text = Loc.t("round_cast_button")
	_swap_button.text = Loc.t("round_swap_button")
	_peek_label.text = Loc.t("peek_label")
	_talismans.empty_label = Loc.t("round_talisman_slot")
	_consumables.empty_label = Loc.t("round_consumable_slot")
	_again_button.text = Loc.t("result_again")
	_result_menu_button.text = Loc.t("result_menu")
	_pause_title.text = Loc.t("pause_title")
	_pause_seed.text = Loc.t("round_seed", {"seed": _seed})
	_resume_button.text = Loc.t("pause_resume")
	_main_menu_button.text = Loc.t("pause_main_menu")
	_rune_book_button.text = Loc.t("pause_rune_book")
	for action: Dictionary in _pause_actions:
		(action["button"] as Button).text = Loc.t(action["key"])
	_refresh_state()
	_on_selection_changed()


## Counters, buttons, the monster's card and the peek at the bag.
func _refresh_state() -> void:
	_coins_value.text = Loc.number(_fight.money)
	_bag_value.text = Loc.t("round_bag_value", {"left": _fight.bag.remaining(), "total": _fight.bag.size()})
	_candles.total = maxi(_casts_total, _fight.casts_left)
	_candles.left = _fight.casts_left
	_chalk.total = maxi(_swaps_total, _fight.swaps_left)
	_chalk.left = _fight.swaps_left
	# Aeva's Hourglass: Swaps without end, no chalk to draw.
	var endless: bool = _fight.swaps_left > ENDLESS_SWAPS
	_chalk.visible = not endless and not bool(config.get("hide_swap", false))
	_swaps_label.text = Loc.t("round_swaps_endless") if endless else Loc.t("round_swaps")
	var cost: int = _fight.swap_cost()
	_swap_button.text = Loc.t("round_swap_button_cost", {"n": cost}) if cost > 0 else Loc.t("round_swap_button")
	var selection: Array[int] = _hand.selected_indices()
	_cast_button.disabled = _busy or not _fight.can_cast(selection) or not EventBus.is_allowed("cast")
	_swap_button.disabled = _busy or not _fight.can_swap(selection) or not EventBus.is_allowed("swap")
	_sort_role.disabled = _busy or not EventBus.is_allowed("sort")
	_sort_kin.disabled = _sort_role.disabled
	_speed_button.disabled = not EventBus.is_allowed("speed")
	_menu_button.disabled = not EventBus.is_allowed("menu")
	_hand.enabled = not _busy or (_picking and _choice_panel.uses_hand())
	_talismans.set_owned(_fight.talismans, 0 if _fight.active_rule() == "trick" else -1)
	_talismans.enabled = not _busy
	_consumables.set_owned(_fight.consumables)
	_consumables.enabled = not _busy and EventBus.is_allowed("cast")
	_scroll_slot.spell_id = _fight.scroll_spell()
	_scroll_slot.armed = _fight.scroll_armed()
	_scroll_slot.enabled = not _busy and EventBus.is_allowed("cast")
	_refresh_monster()
	_refresh_peek()


## The monster's card: weaknesses of the head in front, Burn / Freeze / Shield, the rule.
func _refresh_monster() -> void:
	var monster: Monster = _fight.monster
	var lists: Dictionary = monster.entry
	var all_heads: Array = monster.entry.get("heads", [])
	if not all_heads.is_empty():
		lists = all_heads[clampi(monster.head, 0, all_heads.size() - 1)]
	var parts: PackedStringArray = []
	for key: String in ["weak", "resist", "immune"]:
		var names: PackedStringArray = []
		for element: Variant in lists.get(key, []):
			names.append(SpellText.element_name(str(element)))
		if not names.is_empty():
			parts.append(Loc.t("monster_" + key, {"list": ", ".join(names)}))
	_monster_traits.text = " · ".join(parts) if not parts.is_empty() else Loc.t("monster_plain")
	var status: PackedStringArray = []
	if monster.burn_stacks > 0:
		status.append(Loc.t("monster_burn", {"n": monster.burn_stacks,
			"value": Loc.number(monster.burn_per_stack * monster.burn_stacks)}))
	if monster.frozen > 0:
		status.append(Loc.t("monster_frozen", {"n": monster.frozen}))
	if monster.shield_broken:
		status.append(Loc.t("monster_shield_broken"))
	if not all_heads.is_empty():
		status.append(Loc.t("monster_head", {"n": monster.head + 1, "total": monster.heads()}))
	_monster_status.text = " · ".join(status)
	# The rule of a Lord (or the Balaur's heads); the board before the fight told the story.
	var rule_text: String = SpellText.rule_text(_fight.rule)
	if rule_text.is_empty():
		rule_text = SpellText.rule_text(monster.entry)
	elif _fight.active_rule().is_empty():
		rule_text = Loc.t("monster_rule_resting", {"text": rule_text})
	_rule_text.text = rule_text
	_rule_box.visible = not rule_text.is_empty()
	if not _busy:
		_hp_bar.shield = 0.0 if monster.shield_broken else monster.shield
		_hp_bar.heads_left = maxi(0, monster.heads() - 1 - monster.head)
		_hp_bar.set_life(maxf(0.0, monster.hp))


func _reset_monster_bar() -> void:
	var monster: Monster = _fight.monster
	_hp_bar.heads_left = maxi(0, monster.heads() - 1 - monster.head)
	_hp_bar.shield = 0.0 if monster.shield_broken else monster.shield
	_hp_bar.reset(maxf(0.0, monster.hp), monster.max_hp)


## The next stones of the bag, when a spell lets the player see them.
func _refresh_peek() -> void:
	for child: Node in _peek_stones.get_children():
		child.queue_free()
	var next: Array[Stone] = _fight.peek()
	_peek_panel.visible = not next.is_empty()
	for stone: Stone in next:
		var glyph: RuneGlyphScript = RuneGlyphScript.new()
		glyph.custom_minimum_size = Vector2(64, 64)
		glyph.rune_id = stone.rune_id
		_peek_stones.add_child(glyph)


## What is selected right now: {"spells": [...], "runes": [...]}.
func selection_info() -> Dictionary:
	var indices: Array[int] = _hand.selected_indices()
	var preview: Dictionary = _fight.preview(indices)
	var runes: Array[String] = []
	for i: int in indices:
		runes.append(_fight.hand[i].rune_id)
	return {"spells": preview.get("spells", []), "runes": runes}


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


func _unhandled_input(event: InputEvent) -> void:
	if _rune_book.visible:
		return
	if event.is_action_pressed("ui_cancel") and EventBus.is_allowed("menu"):
		get_viewport().set_input_as_handled()
		if _pause_panel.visible:
			close_pause()
		else:
			open_pause()


## The middle of the Rune Circle: the spells read, Power × Resonance, the damage estimate.
func _on_selection_changed() -> void:
	if _picking:
		var picked: Array[int] = _hand.selected_indices()
		_choice_panel.set_hand_picks(picked.size())
		# The Reshaping: other runes of the same role.
		var runes: Array[String] = []
		if not picked.is_empty():
			runes = _fight.rune_choices(_fight.hand[picked[0]])
		_choice_panel.set_rune_options(runes)
		return
	if _busy:
		return
	var info: Dictionary = selection_info()
	EventBus.selection_changed.emit("", info["spells"], info["runes"])
	_preview = _fight.preview(_hand.selected_indices())
	_circle.glow_color = Color(0, 0, 0, 0)
	_circle.awakening = false
	_sentence_bar.clear()
	_spell_second.text = ""
	_circle_info.text = ""
	_preview_value.text = ""
	_estimate_value.text = "—"
	_estimate_note.text = ""
	_power_value.text = "0"
	_res_value.text = "0"
	if _preview.is_empty():
		_spell_name.text = Loc.t("circle_hint")
	elif _selection_has_face_down():
		# The dream: a face-down stone keeps its secret until it is cast.
		_spell_name.text = Loc.t("word_hidden")
		_circle_info.text = Loc.t("circle_face_down")
		_power_value.text = "?"
		_res_value.text = "?"
		_estimate_value.text = "?"
	else:
		_show_preview(_preview)
	_preview_value.modulate.a = 1.0
	_refresh_state()


func _show_preview(preview: Dictionary) -> void:
	var parsed: Dictionary = preview["sentence"]
	var per_spell: Array = preview["per_spell"]
	_show_sentence(parsed, preview.get("plan", {}))
	if per_spell.is_empty():
		_spell_name.text = SpellText.circle_line(parsed)
		if _spell_name.text.is_empty():
			_spell_name.text = Loc.t("circle_no_spell")
	else:
		var first: Dictionary = per_spell[0]
		_spell_name.text = SpellText.spell_name(str(first["spell"]))
		_power_value.text = Loc.number(first["power"])
		_res_value.text = Loc.number(first["res"])
		if per_spell.size() > 1:
			_spell_second.text = Loc.t("circle_second_spell", {"name": SpellText.spell_name(str(per_spell[1]["spell"]))})
	var notes: PackedStringArray = []
	var blocked: String = str(preview.get("blocked", ""))
	if not blocked.is_empty():
		notes.append(Loc.t("blocked_" + blocked, {"n": _fight.required_count() if blocked == "exact_count"
			else int(_fight.rule.get("rule_value", 4))}))
	if bool(preview.get("kin_bonus", false)):
		notes.append(Loc.t("circle_kin_bonus", {"n": Loc.number(float(GameData.economy.get("kin_bonus_res", 1.5)))}))
	for info: Dictionary in per_spell:
		if bool(info.get("zero", false)):
			notes.append(Loc.t("circle_zero_by_rule"))
			break
	_circle_info.text = "\n".join(notes)
	var damage: float = float(preview["damage"])
	var most: float = float(preview["damage_max"])
	_estimate_value.text = Loc.number(damage)
	if not per_spell.is_empty():
		_preview_value.text = Loc.t("circle_estimate", {"n": Loc.number(damage)})
	if bool(preview["kill"]):
		_estimate_note.text = Loc.t("round_estimate_kill")
	elif most > damage:
		_estimate_note.text = Loc.t("round_estimate_max", {"n": Loc.number(most)})
	else:
		for info: Dictionary in per_spell:
			if bool(info.get("later", false)):
				_estimate_note.text = Loc.t("round_estimate_later")


func _selection_has_face_down() -> bool:
	for i: int in _hand.selected_indices():
		if _fight.hand[i].face_down:
			return true
	return false


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


## Talismans act left to right: dragging one changes the order.
func _on_talisman_moved(from: int, to: int) -> void:
	if _busy:
		return
	var item: Dictionary = _fight.talismans.pop_at(from)
	_fight.talismans.insert(clampi(to, 0, _fight.talismans.size()), item)
	_refresh_state()


func _on_stone_moved(from: int, to: int) -> void:
	_fight.move_stone(from, to)
	_on_selection_changed()


func _on_sort(by_role: bool) -> void:
	if _busy:
		return
	_hand.clear_selection()
	if by_role:
		_fight.sort_by_role()
	else:
		_fight.sort_by_kin()
	_hand.set_stones(_fight.hand)


func _on_swap_pressed() -> void:
	var count: int = _hand.selected_indices().size()
	if _busy or not EventBus.is_allowed("swap") or not _fight.swap(_hand.selected_indices()):
		return
	_show_hand()
	EventBus.swap.emit(count)
	_on_selection_changed()


func _on_cast_pressed() -> void:
	var selection: Array[int] = _hand.selected_indices()
	if _busy or not EventBus.is_allowed("cast") or not _fight.can_cast(selection):
		return
	var info: Dictionary = selection_info()
	EventBus.cast.emit("", info["runes"])
	_busy = true
	_refresh_state()
	_sentence_bar.clear()
	# The views of the cast stones, in casting order (the selection order).
	var cast_views: Array[StoneView] = []
	for i: int in selection:
		cast_views.append(_hand.view_at(i))
	var result: Dictionary = _fight.cast(selection)
	_player.speed = float(_speed) * (0.5 if slow_scoring else 1.0)
	await _player.play(result, cast_views)
	await _announce(result)
	for view: StoneView in cast_views:
		view.selected = false
		var tween: Tween = view.create_tween()
		tween.tween_property(view, "modulate:a", 0.0, 0.25 / float(_speed))
	await get_tree().create_timer(0.25 / float(_speed)).timeout
	_show_hand()
	await _resolve_picks()
	_busy = false
	_reset_monster_bar()
	_on_selection_changed()
	EventBus.cast_resolved.emit()
	if _fight.is_won() or _fight.is_lost():
		_finish_round()


## Picks waiting when the fight starts (stones carried over to put back). A fight can also
## start already won (Raidho carried enough damage), or with no stone to draw: then it ends at
## once.
func _resolve_start_picks() -> void:
	if not _fight.pending.is_empty():
		_busy = true
		_refresh_state()
		await _resolve_picks()
		_busy = false
		_show_hand()
		_on_selection_changed()
	if _fight.is_won():
		_busy = true
		_refresh_state()
		await _show_toast(Loc.t("round_won_at_start"))
		_busy = false
		_finish_round()
	elif _fight.is_lost():
		_finish_round()


## The spells' picks, one after another. Stones are picked in the hand; where the player may
## not select (a tutorial step) the fight answers by itself.
func _resolve_picks() -> void:
	while not _fight.pending.is_empty():
		var choice: Dictionary = _fight.current_choice()
		var limits: Dictionary = _fight.pick_limits(choice)
		if not EventBus.is_allowed("select") or limits.is_empty():
			if not _fight.answer(_fight.auto_answer()):
				_fight.skip_choice()
			_show_hand()
			continue
		_picking = true
		_hand.clear_selection()
		_hand.show_order = false
		_hand.max_selection = maxi(1, _choice_panel_max(limits))
		var stones: Array = []
		match str(limits["source"]):
			"talisman":
				stones = _fight.talismans
			"bag_top":
				stones = _fight.bag.peek(int(limits["count"]))
			"offer":
				stones = _fight.offer
		_choice_panel.ask(choice, limits, {"money": _fight.money, "swaps": _fight.swaps_left, "stones": stones,
			"kins": _fight.kin_choices()})
		_refresh_state()
		var reply: Dictionary = await _choice_panel.answered
		if str(limits["source"]) == "hand":
			reply["stones"] = _hand.selected_indices()
		if not _fight.answer(reply):
			_fight.skip_choice()
		_choice_panel.close()
		_picking = false
		_hand.clear_selection()
		_hand.max_selection = _fight.max_selection()
		_hand.show_order = _fight.spells_enabled
		_show_hand()
		_refresh_state()


func _choice_panel_max(limits: Dictionary) -> int:
	return int(limits.get("max", 0)) if str(limits.get("source", "")) == "hand" else 0


## A click on a Lesson or an Engraving: a Lesson raises its Element now; an Engraving asks
## which stones in hand it changes.
func _on_consumable_used(slot: int) -> void:
	if _busy or slot >= _fight.consumables.size():
		return
	var item: Dictionary = _fight.consumables[slot]
	var lesson: bool = str(item["type"]) == "lesson"
	if not _fight.use_consumable(slot):
		await _show_toast(Loc.t("consumable_cannot"))
		return
	if lesson:
		var element_id: String = str((GameData.lessons.get(str(item["id"]), {}) as Dictionary).get("element", ""))
		EventBus.consumable_used.emit("lesson", str(item["id"]))
		_refresh_state()
		_on_selection_changed()
		await _show_toast(Loc.t("lesson_learned", {
			"element": SpellText.element_name(element_id),
			"n": _fight.element_level(element_id)}))
		return
	EventBus.consumable_used.emit("engraving", str(item["id"]))
	_busy = true
	_refresh_state()
	await _resolve_picks()
	_busy = false
	_show_hand()
	_on_selection_changed()


## A click on the Scroll: ready to happen with the next Cast, or put away again.
func _on_scroll_pressed() -> void:
	if _busy or not _fight.has_scroll():
		return
	if _fight.scroll_armed():
		_fight.disarm_scroll()
	else:
		_fight.use_scroll()
	_refresh_state()


## Discoveries after a Cast: new spells, new Actions, Talismans worn out, the Scroll.
func _announce(result: Dictionary) -> void:
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
		elif bool(plan["gift"]):
			await _show_toast(Loc.t("spell_scroll_kept", {"name": Loc.text(spell["name"])}))
		for action_id: String in plan["actions"]:
			if SaveManager.add_discovery("actions", action_id):
				_action_learned.center = _circle.get_global_rect().get_center() - get_global_rect().position
				await _action_learned.play(action_id, float(_speed))
		if bool(plan["gift"]):
			EventBus.scroll_gained.emit(id)
		EventBus.spell_sentence_cast.emit(id, plan["actions"])
		EventBus.spell_cast.emit(id)
	_refresh_state()


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
	var finished: Dictionary = _fight.finish()
	_refresh_state()
	if _fight.is_won():
		EventBus.round_won.emit()
	else:
		EventBus.round_lost.emit()
	if not bool(config.get("show_result", true)):
		return
	_result_title.text = Loc.t("result_won_title") if _fight.is_won() else Loc.t("result_lost_title")
	_result_damage.text = Loc.t("result_damage", {"n": Loc.number(_fight.damage_dealt),
		"best": Loc.number(_fight.best_cast_damage)})
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
