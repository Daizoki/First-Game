extends PanelContainer
## A contextual hint: a small bubble with the speaker's portrait that slides in on the right
## and types its line letter by letter. It never blocks the game (only the bubble itself
## takes the mouse); a click on it closes it.

signal closed

const Portrait = preload("res://scripts/ui/portrait.gd")

const TYPE_SPEED: float = 55.0
const WIDTH: float = 520.0
const MARGIN: float = 24.0
## Bubble top as a share of the screen height (on the round screen: under the consumables,
## above the Cast button).
const TOP_SHARE: float = 0.44
const SLIDE: float = 60.0

var _portrait: Portrait
var _speaker: Label
var _text: Label
var _close_hint: Label
var _chars: float = 0.0
var _typing: bool = false
var _closing: bool = false
var _covered: bool = false
var _tween: Tween


func _ready() -> void:
	theme_type_variation = &"BubblePanel"
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	visible = false
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	_portrait = Portrait.new()
	_portrait.custom_minimum_size = Vector2(84, 84)
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_portrait)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 2)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(body)
	_speaker = _label(body, 26, &"TitleLabel")
	_text = _label(body, 25, &"")
	_text.custom_minimum_size = Vector2(WIDTH - 150.0, 0)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_close_hint = _label(body, 18, &"SecondaryLabel")
	_close_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gui_input.connect(_on_input)


func show_hint(speaker_id: String, text: String) -> void:
	var character: Dictionary = GameData.characters.get(speaker_id, {})
	_portrait.character_id = speaker_id
	_speaker.text = Loc.text(character.get("name", {}))
	_text.text = text
	_text.visible_characters = 0
	_close_hint.text = Loc.t("hint_close")
	_chars = 0.0
	_typing = true
	_closing = false
	visible = not _covered
	reset_size()
	var goal: Vector2 = _goal()
	position = goal + Vector2(SLIDE, 0)
	modulate.a = 0.0
	_animate(goal, 1.0)


## Closes the bubble (a click does it). Emits `closed` once it has faded out.
func close() -> void:
	if _closing or (not visible and not _covered) or _text.text.is_empty():
		return
	_closing = true
	_animate(_goal() + Vector2(SLIDE * 0.5, 0), 0.0)
	await _tween.finished
	visible = false
	_text.text = ""
	_closing = false
	closed.emit()


## Gone at once, without `closed` (hints switched off, the evening class started).
func clear() -> void:
	if _tween != null:
		_tween.kill()
	visible = false
	_text.text = ""
	_typing = false
	_closing = false


func is_showing() -> bool:
	return not _text.text.is_empty()


## Hidden while a menu or a book covers the game; comes back afterwards.
func set_covered(value: bool) -> void:
	_covered = value
	if is_showing() and not _closing:
		visible = not value


func _process(delta: float) -> void:
	if not visible:
		return
	if _typing:
		_chars += delta * TYPE_SPEED
		_text.visible_characters = int(_chars)
		if _chars >= float(_text.get_total_character_count()):
			_typing = false
			_text.visible_characters = -1
	if _tween == null or not _tween.is_running():
		position = _goal()


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		accept_event()
		close()


## Right side of the screen, below the middle.
func _goal() -> Vector2:
	var area: Vector2 = (get_parent() as Control).size
	return Vector2(area.x - size.x - MARGIN, area.y * TOP_SHARE)


func _animate(goal: Vector2, alpha: float) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", goal, 0.25)
	_tween.tween_property(self, "modulate:a", alpha, 0.2)


func _label(parent: Control, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label
