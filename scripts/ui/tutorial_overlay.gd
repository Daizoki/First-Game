extends Control
## The tutorial layer above the game: the screen darkens except for soft "holes" of light
## around the elements being explained, a speech bubble with the speaker's portrait types
## its text letter by letter, and a chalk arrow points from the bubble to the light.
## It never blocks the mouse over the game (hovering always works); on talk bubbles a click
## first shows the whole text, a second click moves on.

signal advanced
signal bubble_clicked

const Portrait = preload("res://scripts/ui/portrait.gd")

const TYPE_SPEED: float = 55.0
const HOLE_PADDING: float = 14.0
const SCREEN_MARGIN: float = 24.0
const ARROW_GAP: float = 70.0
const LABEL_GAP: float = 46.0
const MAX_HOLES: int = 8
const DIM_LEVEL: float = 0.66
const BONE: Color = Color("#e9e3d2")
const INK: Color = Color("#05060a")

@onready var _dim: ColorRect = %Dim
@onready var _ink: Control = %Ink
@onready var _labels: Control = %Labels
@onready var _bubble: PanelContainer = %Bubble
@onready var _portrait: Portrait = %BubblePortrait
@onready var _speaker: Label = %Speaker
@onready var _text: Label = %BubbleText
@onready var _choices: HBoxContainer = %Choices
@onready var _click_hint: Label = %ClickHint

## Where the bubble sits when nothing is lit (0..1 of the screen height, bubble center).
var home_y: float = 0.5

var _targets: Array[Control] = []
var _holes: Array[Rect2] = []
var _labels_for: Array[Dictionary] = []
var _needs_click: bool = false
var _typing: bool = false
var _chars: float = 0.0
var _dim_level: float = 0.0
var _time: float = 0.0
var _bubble_goal: Vector2 = Vector2.ZERO
var _bubble_placed: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.visible = false
	_text.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_ink.draw.connect(_draw_ink)
	_bubble.gui_input.connect(_on_bubble_input)


## Shows a bubble. needs_click: a talk bubble (click to go on) rather than an instruction
## that waits for the player to do something in the game.
func say(speaker_id: String, text: String, needs_click: bool) -> void:
	var character: Dictionary = GameData.characters.get(speaker_id, {})
	_portrait.character_id = speaker_id
	_speaker.text = Loc.text(character.get("name", {}))
	_text.text = text
	_text.visible_characters = 0
	_chars = 0.0
	_typing = true
	_needs_click = needs_click
	_click_hint.text = Loc.t("tutorial_click")
	_click_hint.modulate.a = 0.0
	_clear_choices()
	var was_visible: bool = _bubble.visible
	_bubble.visible = true
	_bubble.reset_size()
	if not was_visible:
		_bubble_placed = false
		_bubble.modulate.a = 0.0
		var tween: Tween = _bubble.create_tween()
		tween.tween_property(_bubble, "modulate:a", 1.0, 0.18)


## Buttons inside the bubble: [{"text": String, "callback": Callable}].
func show_choices(choices: Array) -> void:
	_clear_choices()
	_needs_click = false
	for choice: Dictionary in choices:
		var button: Button = Button.new()
		button.text = choice["text"]
		button.custom_minimum_size = Vector2(260, 64)
		button.pressed.connect(choice["callback"])
		_choices.add_child(button)
	_choices.visible = true
	_bubble.reset_size()
	if _choices.get_child_count() > 0:
		(_choices.get_child(0) as Button).call_deferred("grab_focus")


func hide_bubble() -> void:
	_bubble.visible = false
	_typing = false
	_needs_click = false
	_clear_choices()


## Lights up these controls (empty: no darkening).
func set_targets(targets: Array[Control]) -> void:
	_targets = targets
	if _holes.size() != _target_rects().size():
		_holes = _target_rects()
	_bubble_placed = false


## Small texts above lit controls: [{"control": Control, "text": String}].
func set_labels(entries: Array) -> void:
	for child: Node in _labels.get_children():
		child.queue_free()
	_labels_for.clear()
	for entry: Dictionary in entries:
		var label: Label = Label.new()
		label.text = entry["text"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_outline_color", INK)
		label.add_theme_constant_override("outline_size", 8)
		_labels.add_child(label)
		_labels_for.append({"control": entry["control"], "label": label})
	_bubble_placed = false


func clear() -> void:
	hide_bubble()
	set_targets([] as Array[Control])
	set_labels([])


func is_typing() -> bool:
	return _typing


func bubble_visible() -> bool:
	return _bubble.visible


func finish_typing() -> void:
	_typing = false
	_text.visible_characters = -1


func _process(delta: float) -> void:
	_time += delta
	if _typing:
		_chars += delta * TYPE_SPEED
		_text.visible_characters = int(_chars)
		if _chars >= float(_text.get_total_character_count()):
			finish_typing()
	var hint_goal: float = 1.0 if _needs_click and not _typing and _bubble.visible else 0.0
	_click_hint.modulate.a = move_toward(_click_hint.modulate.a, hint_goal, delta * 4.0)

	var goals: Array[Rect2] = _target_rects()
	if goals.size() != _holes.size():
		_holes = goals
	for i: int in _holes.size():
		_holes[i] = Rect2(_holes[i].position.lerp(goals[i].position, minf(1.0, delta * 12.0)),
			_holes[i].size.lerp(goals[i].size, minf(1.0, delta * 12.0)))
	_dim_level = move_toward(_dim_level, DIM_LEVEL if not _holes.is_empty() else 0.0, delta * 2.5)
	_update_shader()
	_place_labels()
	if _bubble.visible:
		_place_bubble(delta)
	_ink.queue_redraw()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not _bubble.visible or _choices.visible:
		return
	var click: bool = event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	var key: bool = event.is_action_pressed("ui_accept")
	if not click and not key:
		return
	if _typing and (_needs_click or _bubble.get_global_rect().has_point(get_global_mouse_position()) or key):
		finish_typing()
		get_viewport().set_input_as_handled()
	elif _needs_click:
		get_viewport().set_input_as_handled()
		advanced.emit()


func _on_bubble_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and not _needs_click:
		bubble_clicked.emit()


func _target_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var inverse: Transform2D = get_global_transform().affine_inverse()
	for target: Control in _targets:
		if is_instance_valid(target) and target.is_visible_in_tree():
			rects.append((inverse * target.get_global_rect()).grow(HOLE_PADDING))
		if rects.size() >= MAX_HOLES:
			break
	return rects


func _update_shader() -> void:
	var material: ShaderMaterial = _dim.material as ShaderMaterial
	var packed: PackedVector4Array = PackedVector4Array()
	for i: int in MAX_HOLES:
		if i < _holes.size():
			var hole: Rect2 = _holes[i]
			packed.append(Vector4(hole.position.x, hole.position.y, hole.size.x, hole.size.y))
		else:
			packed.append(Vector4.ZERO)
	material.set_shader_parameter("area_size", size)
	material.set_shader_parameter("hole_count", _holes.size())
	material.set_shader_parameter("holes", packed)
	material.set_shader_parameter("dim", _dim_level)


func _place_labels() -> void:
	var inverse: Transform2D = get_global_transform().affine_inverse()
	for entry: Dictionary in _labels_for:
		var target: Control = entry["control"]
		var label: Label = entry["label"]
		if not is_instance_valid(target):
			label.visible = false
			continue
		var rect: Rect2 = inverse * target.get_global_rect()
		label.reset_size()
		label.position = Vector2(rect.get_center().x - label.size.x * 0.5, rect.position.y - HOLE_PADDING - label.size.y - 4.0)


## Next to the light, without leaving the screen: above, below, right or left of it.
func _place_bubble(delta: float) -> void:
	var bubble_size: Vector2 = _bubble.size
	var goal: Vector2
	var lit: Rect2 = _lit_area()
	if lit.size == Vector2.ZERO:
		goal = Vector2((size.x - bubble_size.x) * 0.5, size.y * home_y - bubble_size.y * 0.5)
	else:
		var gap: float = ARROW_GAP + (LABEL_GAP if not _labels_for.is_empty() else 0.0)
		var center_x: float = lit.get_center().x - bubble_size.x * 0.5
		var center_y: float = lit.get_center().y - bubble_size.y * 0.5
		var candidates: Array[Vector2] = [
			Vector2(center_x, lit.position.y - gap - bubble_size.y),
			Vector2(center_x, lit.end.y + gap),
			Vector2(lit.end.x + gap, center_y),
			Vector2(lit.position.x - gap - bubble_size.x, center_y),
		]
		goal = candidates[0]
		var best: float = INF
		for candidate: Vector2 in candidates:
			var overflow: float = _overflow(Rect2(candidate, bubble_size))
			if overflow < best - 0.5:
				best = overflow
				goal = candidate
	goal.x = clampf(goal.x, SCREEN_MARGIN, size.x - bubble_size.x - SCREEN_MARGIN)
	goal.y = clampf(goal.y, SCREEN_MARGIN, size.y - bubble_size.y - SCREEN_MARGIN)
	if not _bubble_placed:
		_bubble.position = goal
		_bubble_placed = true
	_bubble_goal = goal
	_bubble.position = _bubble.position.lerp(_bubble_goal, minf(1.0, delta * 8.0))


func _lit_area() -> Rect2:
	if _holes.is_empty():
		return Rect2()
	var area: Rect2 = _holes[0]
	for hole: Rect2 in _holes:
		area = area.merge(hole)
	return area


func _overflow(rect: Rect2) -> float:
	var screen: Rect2 = Rect2(Vector2.ONE * SCREEN_MARGIN, size - Vector2.ONE * SCREEN_MARGIN * 2.0)
	var inside: Rect2 = rect.intersection(screen)
	return rect.get_area() - inside.get_area()


## The chalk arrow from the bubble to the light.
func _draw_ink() -> void:
	if not _bubble.visible or _holes.is_empty():
		return
	var box: Rect2 = Rect2(_bubble.position, _bubble.size)
	# Point at the light closest to the bubble.
	var lit: Rect2 = _holes[0]
	for hole: Rect2 in _holes:
		if hole.get_center().distance_to(box.get_center()) < lit.get_center().distance_to(box.get_center()):
			lit = hole
	var start: Vector2 = Vector2(clampf(lit.get_center().x, box.position.x + 30.0, box.end.x - 30.0),
		clampf(lit.get_center().y, box.position.y + 20.0, box.end.y - 20.0))
	var end: Vector2 = Vector2(clampf(start.x, lit.position.x, lit.end.x), clampf(start.y, lit.position.y, lit.end.y))
	if box.intersects(lit) or start.distance_to(end) < 30.0:
		return
	var direction: Vector2 = (end - start).normalized()
	end -= direction * (6.0 + 5.0 * sin(_time * 5.0))
	start += direction * 8.0
	var bend: Vector2 = direction.orthogonal() * start.distance_to(end) * 0.14
	var points: PackedVector2Array = []
	for i: int in 17:
		var t: float = float(i) / 16.0
		var middle: Vector2 = start.lerp(end, 0.5) + bend
		points.append(start.lerp(middle, t).lerp(middle.lerp(end, t), t))
	_ink.draw_polyline(points, Color(INK, 0.8), 10.0, true)
	_ink.draw_polyline(points, Color(BONE, 0.92), 5.0, true)
	var tip_direction: Vector2 = (points[16] - points[14]).normalized()
	for side: float in [-1.0, 1.0]:
		var wing: Vector2 = end - tip_direction.rotated(side * 0.55) * 26.0
		_ink.draw_line(end, wing, Color(INK, 0.8), 10.0, true)
		_ink.draw_line(end, wing, Color(BONE, 0.92), 5.0, true)


func _clear_choices() -> void:
	for child: Node in _choices.get_children():
		_choices.remove_child(child)
		child.queue_free()
	_choices.visible = false
