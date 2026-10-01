extends Control
## The Rune Circle in the middle of the round: a stone disc with the 24 runes carved on its
## rim, turning very slowly. Glows in a Spell's color when the selection holds one, and
## pulses when it holds a Spell not discovered yet. The text in the middle is a child node.

const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")

const SPIN_SPEED: float = 0.035
const DISC: Color = Color("#1b1828")
const DISC_EDGE: Color = Color("#2b2540")
const INK: Color = Color("#05060a")
const VIOLET: Color = Color("#241b3a")

## Color of the glow; transparent = no Spell in the selection.
var glow_color: Color = Color(0, 0, 0, 0)
## True when the Spell in the selection is still undiscovered (mysterious pulse).
var awakening: bool = false

var _angle: float = 0.0
var _time: float = 0.0
var _rim: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for kin_id: String in GameData.kins:
		for rune: Dictionary in GameData.runes_in_kin(kin_id):
			_rim.append({"segments": rune["segments"], "color": GameData.kin_color(kin_id)})


func _process(delta: float) -> void:
	_angle += delta * SPIN_SPEED
	_time += delta
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size / 2.0
	var radius: float = minf(size.x, size.y) / 2.0 - 12.0
	if glow_color.a > 0.0:
		var pulse: float = 0.7 + 0.3 * sin(_time * (5.0 if awakening else 2.0))
		for i: int in range(8, 0, -1):
			draw_circle(center, radius + float(i) * 9.0, Color(glow_color, 0.035 * pulse * glow_color.a))
	draw_circle(center, radius + 6.0, INK)
	draw_circle(center, radius, DISC_EDGE)
	draw_circle(center, radius * 0.78, DISC)
	draw_arc(center, radius * 0.78, 0.0, TAU, 96, INK, 4.0, true)
	draw_arc(center, radius * 0.74, 0.0, TAU, 96, Color(VIOLET, 0.9), 2.0, true)
	var rim_color_alpha: float = 0.55 + (0.35 if glow_color.a > 0.0 else 0.0)
	for i: int in _rim.size():
		var angle: float = _angle + TAU * float(i) / float(_rim.size()) - PI / 2.0
		var at: Vector2 = center + Vector2.from_angle(angle) * radius * 0.89
		var glyph: float = radius * 0.13
		var color: Color = Color(_rim[i]["color"], rim_color_alpha)
		draw_set_transform(at, angle + PI / 2.0, Vector2.ONE)
		RuneGlyphScript.draw_segments(self, _rim[i]["segments"], Rect2(Vector2(-glyph, -glyph), Vector2(glyph, glyph) * 2.0), 3.0, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
