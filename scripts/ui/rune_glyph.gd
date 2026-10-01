extends Control
## Draws one rune from the line segments in data/runes.json: thick strokes with a glow
## in the color of the rune's kin, gently pulsing. If Relax adds art/runes/<id>.png,
## that drawing is shown instead.

## Stroke width as a fraction of the glyph size.
const STROKE: float = 0.075
## Glow halo: how many soft layers and how far they spread (multiples of the stroke).
const GLOW_LAYERS: int = 5
const GLOW_SPREAD: float = 3.2
const GLOW_ALPHA: float = 0.11
const PULSE_SPEED: float = 1.8

@export var rune_id: String = "": set = set_rune_id
## 0 = no glow, 1 = normal, >1 = brighter (selected stones, big moments).
@export var glow: float = 1.0

var _segments: Array = []
var _color: Color = Color.WHITE
var _texture: Texture2D = null
var _time: float = 0.0
var _phase: float = 0.0


func set_rune_id(value: String) -> void:
	rune_id = value
	_segments = []
	_texture = null
	if GameData.runes.has(rune_id):
		var rune: Dictionary = GameData.runes[rune_id]
		_segments = rune.get("segments", [])
		_color = GameData.kin_color(str(rune.get("kin", "")))
		_texture = GameData.rune_texture(rune_id)
	# Each rune pulses a little out of step with the others.
	_phase = float(hash(rune_id) % 1000) / 1000.0 * TAU
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var side: float = minf(size.x, size.y)
	var origin: Vector2 = (size - Vector2(side, side)) / 2.0
	var pulse: float = 0.8 + 0.2 * sin(_time * PULSE_SPEED + _phase)

	if _texture != null:
		draw_texture_rect(_texture, Rect2(origin, Vector2(side, side)), false, Color(1, 1, 1, 0.85 + 0.15 * pulse))
		return

	var stroke: float = side * STROKE
	# Soft halo: wide, faint layers first, narrower ones on top.
	for layer: int in range(GLOW_LAYERS, 0, -1):
		var width: float = stroke * (1.0 + GLOW_SPREAD * float(layer) / float(GLOW_LAYERS))
		var halo: Color = Color(_color, GLOW_ALPHA * glow * pulse)
		_draw_strokes(origin, side, width, halo)
	# The carved stroke itself, a bit lighter than the kin color.
	_draw_strokes(origin, side, stroke, _color.lightened(0.35))


func _draw_strokes(origin: Vector2, side: float, width: float, color: Color) -> void:
	for segment: Variant in _segments:
		var s: Array = segment
		var a: Vector2 = origin + Vector2(float(s[0]), float(s[1])) * side
		var b: Vector2 = origin + Vector2(float(s[2]), float(s[3])) * side
		draw_line(a, b, color, width, true)
		# Round caps so joints look like one continuous carving.
		draw_circle(a, width / 2.0, color)
		draw_circle(b, width / 2.0, color)
