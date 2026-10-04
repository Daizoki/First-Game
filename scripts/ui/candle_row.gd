extends Control
## Casts left, drawn as candles (lit = still available, out = used, with a thread of smoke),
## or Swaps left, drawn as chalk lines (used ones are crossed out).

enum Style { CANDLES, CHALK }

const BONE: Color = Color("#e9e3d2")
const CANDLE: Color = Color("#ffb347")
const EMBER: Color = Color("#ff6a3d")
const INK: Color = Color("#05060a")
const SMOKE: Color = Color("#a39db4")

@export var style: Style = Style.CANDLES
var total: int = 4: set = _set_total
var left: int = 4: set = _set_left

var _time: float = 0.0


func _set_total(value: int) -> void:
	total = value
	queue_redraw()


func _set_left(value: int) -> void:
	left = value
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var count: int = maxi(total, left)
	if count == 0:
		return
	var step: float = minf(70.0, size.x / float(count))
	for i: int in count:
		var x: float = step * (float(i) + 0.5)
		if style == Style.CANDLES:
			_draw_candle(Vector2(x, size.y), i < left, i)
		else:
			_draw_chalk(Vector2(x, size.y * 0.5), i < left, i)


func _draw_candle(base: Vector2, lit: bool, i: int) -> void:
	var body: Rect2 = Rect2(base + Vector2(-13, -70), Vector2(26, 70))
	draw_rect(body, Color(BONE, 0.92 if lit else 0.5))
	draw_rect(body, INK, false, 3.0)
	var wick: Vector2 = base + Vector2(0, -70)
	draw_line(wick, wick + Vector2(0, -8), INK, 3.0)
	if lit:
		var flicker: float = 1.0 + 0.12 * sin(_time * 11.0 + float(i) * 1.7) + 0.06 * sin(_time * 23.0 + float(i))
		var tip: Vector2 = wick + Vector2(2.0 * sin(_time * 7.0 + float(i)), -34.0 * flicker)
		var flame: PackedVector2Array = [wick + Vector2(-9, -6), tip, wick + Vector2(9, -6), wick + Vector2(0, 2)]
		draw_circle(wick + Vector2(0, -16), 22.0, Color(CANDLE, 0.12))
		draw_colored_polygon(flame, Color(EMBER, 0.95))
		draw_colored_polygon(PackedVector2Array([wick + Vector2(-4, -6), wick.lerp(tip, 0.6), wick + Vector2(4, -6)]), CANDLE)
	else:
		var smoke: PackedVector2Array = []
		for k: int in 8:
			var h: float = float(k) * 7.0
			smoke.append(wick + Vector2(5.0 * sin(_time * 2.0 + h * 0.15 + float(i)), -10.0 - h))
		draw_polyline(smoke, Color(SMOKE, 0.45), 2.0, true)


func _draw_chalk(center: Vector2, available: bool, i: int) -> void:
	var a: Vector2 = center + Vector2(-6, 22)
	var b: Vector2 = center + Vector2(6, -22)
	var jitter: float = float((i * 37) % 5) - 2.0
	draw_line(a, b + Vector2(jitter, 0), Color(BONE, 0.85), 6.0, true)
	if not available:
		draw_line(center + Vector2(-22, -6), center + Vector2(22, 8), Color(EMBER, 0.85), 4.0, true)
