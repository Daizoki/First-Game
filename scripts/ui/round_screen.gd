extends Control
## The round screen (DESIGN 3.16): hand of stones, Rune Circle, score, Power × Resonance,
## candles for Casts, chalk lines for Swaps, the examiner card. Stage 2 plays a practice
## round with a fixed target; the full exam (Stage 3) reuses this screen.

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

const MAIN_MENU_SCENE: String = "res://scenes/main_menu.tscn"
const SPEEDS: Array[int] = [1, 2, 4]
const FUTHARK: Array[String] = ["fehu", "uruz", "thurisaz", "ansuz", "raidho"]
const SHAKE_SHARE: float = 0.35

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
@onready var _spell_line: Label = %SpellLine
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

var _round: RoundState
var _seed: int = 0
var _busy: bool = false
var _speed: int = 1
var _shown_score: float = 0.0
var _player: ScoringPlayer


func _ready() -> void:
	_seed = randi()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _seed
	_round = RoundState.new()
	_round.setup({"runes": GameData.runes, "words": GameData.words, "spells": GameData.spells,
		"rules": GameData.rules}, rng, float(GameData.rule("test_round_target", 1500)))
	_round.start()
	_speed = int(SaveManager.get_setting("scoring_speed", GameData.rule("scoring_speed", 1)))

	_player = ScoringPlayer.new()
	_player.host = self
	_player.float_layer = _float_layer
	_player.power_label = _power_value
	_player.res_label = _res_value
	_player.word_label = _word_name
	_player.level_label = _word_level
	_player.total_label = _preview_value

	_hand.max_selection = _round.max_selection()
	_hand.selection_changed.connect(_on_selection_changed)
	_hand.stone_moved.connect(_on_stone_moved)
	_cast_button.pressed.connect(_on_cast_pressed)
	_swap_button.pressed.connect(_on_swap_pressed)
	_sort_position.pressed.connect(_on_sort.bind(true))
	_sort_kin.pressed.connect(_on_sort.bind(false))
	_speed_button.pressed.connect(_on_speed_pressed)
	_menu_button.pressed.connect(_go_to_menu)
	_result_menu_button.pressed.connect(_go_to_menu)
	_again_button.pressed.connect(func() -> void: get_tree().reload_current_scene())
	Loc.language_changed.connect(func(_language: String) -> void: _refresh_texts())

	_portrait.character_id = str(GameData.rule("test_round_examiner", "ilinca"))
	_result_panel.visible = false
	_toast.modulate.a = 0.0
	_hand.call_deferred("set_stones", _round.hand)
	_refresh_texts()


func _refresh_texts() -> void:
	var examiner: Dictionary = GameData.characters.get(_portrait.character_id, {})
	_trial_label.text = Loc.t("round_practice")
	_coins_label.text = Loc.t("round_coins")
	_bag_label.text = Loc.t("round_bag")
	_seed_label.text = Loc.t("round_seed", {"seed": _seed})
	_speed_button.text = Loc.t("round_speed", {"n": _speed})
	_menu_button.text = Loc.t("round_menu")
	_casts_label.text = Loc.t("round_casts")
	_swaps_label.text = Loc.t("round_swaps")
	_examiner_name.text = Loc.text(examiner.get("name", {}))
	_examiner_role.text = Loc.text(examiner.get("job", {}))
	_rule_text.text = Loc.t("round_practice_rule")
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
	_candles.total = int(GameData.rule("casts_per_round", 4))
	_candles.left = _round.casts_left
	_chalk.total = maxi(int(GameData.rule("swaps_per_round", 3)), _round.swaps_left)
	_chalk.left = _round.swaps_left
	var selection: Array[int] = _hand.selected_indices()
	_cast_button.disabled = _busy or not _round.can_cast(selection)
	_swap_button.disabled = _busy or not _round.can_swap(selection)
	_hand.enabled = not _busy
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


## The middle of the Rune Circle: Word, scoring stones, Power × Resonance, Spells.
func _on_selection_changed() -> void:
	if _busy:
		return
	var preview: Dictionary = _round.preview(_hand.selected_indices())
	_circle.glow_color = Color(0, 0, 0, 0)
	_circle.awakening = false
	_spell_line.text = ""
	if preview.is_empty():
		_word_name.text = Loc.t("circle_hint")
		_word_level.text = ""
		_scoring_count.text = ""
		_preview_value.text = ""
		_power_value.text = "0"
		_res_value.text = "0"
	else:
		_word_name.text = _word_display_name(preview["word"])
		_word_level.text = Loc.t("circle_level", {"n": _round.word_level(preview["word"])})
		var count: int = (preview["scoring"] as Array).size()
		_scoring_count.text = Loc.t("circle_scoring_one") if count == 1 else Loc.t("circle_scoring_many", {"n": count})
		_preview_value.text = "%s × %s" % [Loc.number(preview["power"]), Loc.number(preview["res"])]
		_power_value.text = Loc.number(preview["power"])
		_res_value.text = Loc.number(preview["res"])
		_show_spells(preview["spells"])
	_preview_value.modulate.a = 1.0
	_refresh_state()


func _show_spells(spell_ids: Array) -> void:
	if spell_ids.is_empty():
		return
	var known: PackedStringArray = []
	var hidden: bool = false
	var color: Color = Color(0, 0, 0, 0)
	for id: String in spell_ids:
		var spell: Dictionary = GameData.spells[id]
		if SaveManager.has_discovery("spells", id):
			known.append(Loc.text(spell["name"]))
			color = Color.html(str(spell.get("color", "#e9e3d2")))
		else:
			hidden = true
	if hidden:
		_spell_line.text = Loc.t("circle_awakening")
		_circle.awakening = true
		if color.a == 0.0:
			color = Color("#e9e3d2")
	if not known.is_empty():
		_spell_line.text = Loc.t("circle_spell", {"name": ", ".join(known)}) + ("  ·  " + _spell_line.text if hidden else "")
	_spell_line.add_theme_color_override("font_color", color)
	_circle.glow_color = color


func _word_display_name(word_id: String) -> String:
	var word: Dictionary = GameData.words[word_id]
	if bool(word.get("hidden", false)) and not SaveManager.has_discovery("words", word_id):
		return Loc.t("word_hidden")
	return Loc.text(word["name"])


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
	if _busy or not _round.swap(_hand.selected_indices()):
		return
	_hand.set_stones(_round.hand)
	_on_selection_changed()


func _on_cast_pressed() -> void:
	var selection: Array[int] = _hand.selected_indices()
	if _busy or not _round.can_cast(selection):
		return
	_busy = true
	_refresh_state()
	var cast_views: Array[StoneView] = []
	var held_views: Array[StoneView] = []
	for i: int in _round.hand.size():
		var view: StoneView = _hand.view_at(i)
		if selection.has(i):
			cast_views.append(view)
		else:
			held_views.append(view)
	var result: Dictionary = _round.cast(selection)
	_player.speed = float(_speed)
	await _player.play(result, cast_views, held_views)
	await _add_score(float(result["score"]))
	await _announce(result)
	for view: StoneView in cast_views:
		view.selected = false
		var tween: Tween = view.create_tween()
		tween.tween_property(view, "modulate:a", 0.0, 0.25 / float(_speed))
	await get_tree().create_timer(0.25 / float(_speed)).timeout
	_hand.set_stones(_round.hand)
	_busy = false
	_on_selection_changed()
	if result["won"] or result["lost"]:
		_finish_round()


## The round score counts up; big casts shake the screen.
func _add_score(amount: float) -> void:
	if amount >= _round.target * SHAKE_SHARE:
		_shake()
	var tween: Tween = create_tween()
	tween.tween_method(_set_shown_score, _shown_score, _shown_score + amount, 0.6 / float(_speed))
	await tween.finished


func _set_shown_score(value: float) -> void:
	_shown_score = value
	_score_value.text = Loc.number(value)
	_score_bar.value = minf(value, _round.target)


## Spells, discoveries and the FUÞAR easter egg after a Cast.
func _announce(result: Dictionary) -> void:
	var word_id: String = result["word"]
	var word: Dictionary = GameData.words[word_id]
	if bool(word.get("hidden", false)) and SaveManager.add_discovery("words", word_id):
		await _show_toast(Loc.t("word_discovered", {"name": Loc.text(word["name"])}))
	if word_id == "chant" and _spells_out(result["cast_stones"]) == FUTHARK:
		await _show_toast(Loc.t("futhark_message"))
	for id: String in result["spells"]:
		var spell: Dictionary = GameData.spells[id]
		if SaveManager.add_discovery("spells", id):
			var memories: int = int(GameData.rule("memories_per_spell", 5))
			SaveManager.data["memories"] = int(SaveManager.data.get("memories", 0)) + memories
			SaveManager.save_game()
			_spell_reveal.reveal(spell, memories)
			await _spell_reveal.closed
		else:
			await _show_toast("%s: %s" % [Loc.text(spell["name"]), Loc.text(spell["effect"])])
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
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
