extends Control
## One rune stone on screen: a procedural stone shape with an ink outline, the glowing rune
## in the middle, the Position in the top-left corner and the kin sign bottom-right.
## Sways gently, tilts and lifts under the mouse, jumps when selected.
## Relax's art/stones/stone.png replaces the procedural stone when it exists.

const Stone = preload("res://scripts/core/stone.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const RoleSign = preload("res://scripts/ui/role_sign.gd")

const STONE_SIZE: Vector2 = Vector2(150, 190)
const STONE_ART: String = "res://art/stones/stone.png"
const INK: Color = Color("#05060a")
const STONE_FILL: Color = Color("#2c2840")
const STONE_LIGHT: Color = Color("#3d3756")
const BONE: Color = Color("#e9e3d2")
const SELECT_LIFT: float = 46.0
const HOVER_LIFT: float = 14.0

var stone: Stone
var selected: bool = false: set = set_selected
var hovered: bool = false
## Tilt from the hand's arc; the sway is added on top.
var base_rotation: float = 0.0
## Extra glow while the stone scores.
var flash: float = 0.0
## Lit while the mouse is over the circle and this stone would score.
var marked: bool = false
## Selected but would not score (faded while the circle's card is shown).
var dimmed: bool = false: set = set_dimmed
## Place in the casting order (1-5) shown on the selected stone; 0 = none.
var order: int = 0: set = set_order
## The role sign (off while the rune grammar is not taught yet).
var show_role: bool = true

var _glyph: RuneGlyphScript
var _outline: PackedVector2Array = []
var _kin_color: Color = Color.WHITE
var _time: float = 0.0
var _phase: float = 0.0
var _lift: float = 0.0
var _art: Texture2D = null


func setup(value: Stone) -> void:
	stone = value
	custom_minimum_size = STONE_SIZE
	size = STONE_SIZE
	pivot_offset = STONE_SIZE / 2.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_kin_color = GameData.kin_color(stone.kin)
	_phase = float(stone.uid % 97) * 0.37
	_outline = _make_outline(stone.uid)
	if ResourceLoader.exists(STONE_ART):
		_art = load(STONE_ART) as Texture2D
	_glyph = RuneGlyphScript.new()
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glyph.position = Vector2(STONE_SIZE.x * 0.2, STONE_SIZE.y * 0.24)
	_glyph.size = Vector2(STONE_SIZE.x * 0.6, STONE_SIZE.x * 0.6)
	_glyph.rune_id = stone.rune_id
	add_child(_glyph)


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func set_order(value: int) -> void:
	order = value
	queue_redraw()


func set_dimmed(value: bool) -> void:
	if value == dimmed:
		return
	dimmed = value
	modulate.a = 0.45 if value else 1.0


## Visual offset (lift) the hand adds to the stone's resting place.
func lift_offset() -> float:
	return -_lift


func _process(delta: float) -> void:
	_time += delta
	var target_lift: float = SELECT_LIFT if selected else (HOVER_LIFT if hovered else 0.0)
	_lift = lerpf(_lift, target_lift, minf(1.0, delta * 12.0))
	var sway: float = sin(_time * 1.3 + _phase) * 0.018
	rotation = base_rotation + sway + (0.06 if hovered and not selected else 0.0)
	flash = maxf(0.0, flash - delta * 1.6)
	_glyph.glow = 1.0 + (1.2 if selected else 0.0) + (1.4 if marked else 0.0) + flash * 3.0
	_glyph.visible = not stone.face_down
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = STONE_SIZE / 2.0
	# Halo in the kin color when selected, scoring or marked.
	var halo: float = (0.55 if selected else 0.0) + (0.9 if marked else 0.0) + flash
	if halo > 0.0:
		for i: int in range(6, 0, -1):
			var grow: float = 1.0 + float(i) * 0.05
			draw_colored_polygon(_scaled(_outline, center, grow), Color(_kin_color, 0.06 * halo))
	if _art != null:
		draw_texture_rect(_art, Rect2(Vector2.ZERO, STONE_SIZE), false)
	else:
		draw_colored_polygon(_outline, STONE_FILL)
		draw_colored_polygon(_scaled(_outline, center + Vector2(-6, -10), 0.82), STONE_LIGHT)
		draw_colored_polygon(_scaled(_outline, center + Vector2(4, 6), 0.78), STONE_FILL)
		var closed: PackedVector2Array = _outline.duplicate()
		closed.append(_outline[0])
		draw_polyline(closed, INK, 5.0, true)
	var font: Font = get_theme_default_font()
	if stone.face_down:
		# Lunet's Dream: only the back of the stone shows.
		draw_string(font, Vector2(0, STONE_SIZE.y * 0.62), "?", HORIZONTAL_ALIGNMENT_CENTER, STONE_SIZE.x, 72,
			Color(BONE, 0.55))
		if selected and order > 0:
			_draw_order(font)
		return
	draw_string(font, Vector2(18, 38), str(stone.position), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, BONE)
	_draw_kin_sign(STONE_SIZE - Vector2(30, 30), 13.0)
	if show_role:
		RoleSign.draw(self, RoleSign.role_of(stone.rune_id), Vector2(STONE_SIZE.x - 32.0, 30.0), 11.0)
	if selected and order > 0:
		_draw_order(font)


## The casting-order number: a bone disc at the top of the stone.
func _draw_order(font: Font) -> void:
	var at: Vector2 = Vector2(STONE_SIZE.x * 0.5, 4.0)
	draw_circle(at, 21.0, INK)
	draw_circle(at, 18.0, BONE)
	draw_string(font, at + Vector2(-18.0, 10.0), str(order), HORIZONTAL_ALIGNMENT_CENTER, 36.0, 28, INK)


func _draw_kin_sign(at: Vector2, radius: float) -> void:
	var color: Color = Color(_kin_color, 0.9)
	match stone.kin:
		"fehu":
			draw_arc(at, radius, 0.0, TAU, 24, color, 3.0, true)
			draw_circle(at, radius * 0.3, color)
		"hagalaz":
			for i: int in 3:
				var dir: Vector2 = Vector2.from_angle(PI / 2.0 + float(i) * PI / 3.0) * radius
				draw_line(at - dir, at + dir, color, 3.0, true)
		_:
			var points: PackedVector2Array = []
			for i: int in 10:
				var r: float = radius if i % 2 == 0 else radius * 0.45
				points.append(at + Vector2.from_angle(-PI / 2.0 + float(i) * PI / 5.0) * r)
			draw_colored_polygon(points, color)


## An irregular rounded stone outline, always the same for the same stone.
func _make_outline(seed_value: int) -> PackedVector2Array:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value * 7919
	var points: PackedVector2Array = []
	var center: Vector2 = STONE_SIZE / 2.0
	var radius: Vector2 = STONE_SIZE / 2.0 - Vector2(8, 8)
	var count: int = 22
	for i: int in count:
		var angle: float = TAU * float(i) / float(count)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		# Squarish ellipse (superellipse) with a little noise: a carved standing stone.
		var shape: float = pow(pow(absf(dir.x), 3.0) + pow(absf(dir.y), 3.0), -1.0 / 3.0)
		var noise: float = 1.0 + rng.randf_range(-0.045, 0.03)
		points.append(center + dir * radius * shape * noise)
	return points


func _scaled(points: PackedVector2Array, center: Vector2, factor: float) -> PackedVector2Array:
	var result: PackedVector2Array = []
	for point: Vector2 in points:
		result.append(center + (point - STONE_SIZE / 2.0) * factor)
	return result
