extends Control
## Placeholder background of the Morning (until Relax draws art/backgrounds/morning.png):
## dawn over the City of the Threshold — the sky turning from night blue to amber, the sun
## coming up behind the blocks, and the Court of Inheritance in the middle, with Aeva's big
## clock whose hands move a little too fast.

const ART: String = "res://art/backgrounds/morning.png"
const NIGHT: Color = Color("#0a0c18")
const DAWN_BLUE: Color = Color("#1d2550")
const DAWN_ROSE: Color = Color("#7a3e5c")
const DAWN_AMBER: Color = Color("#e88a4a")
const INK: Color = Color("#05060a")
const BONE: Color = Color("#e9e3d2")
const CANDLE: Color = Color("#ffb347")

var _time: float = 0.0
var _blocks: Array[Dictionary] = []
var _art: Texture2D = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(ART):
		_art = load(ART) as Texture2D
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 31
	var x: float = -40.0
	while x < 1960.0:
		var width: float = rng.randf_range(110.0, 220.0)
		var height: float = rng.randf_range(160.0, 340.0)
		var windows: Array[Vector2] = []
		for wy: int in int(height / 34.0) - 1:
			for wx: int in int(width / 30.0) - 1:
				if rng.randf() < 0.08:
					windows.append(Vector2(14.0 + float(wx) * 30.0, 18.0 + float(wy) * 34.0))
		_blocks.append({"x": x, "w": width, "h": height, "windows": windows})
		x += width + rng.randf_range(6.0, 40.0)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _art != null:
		draw_texture_rect(_art, Rect2(Vector2.ZERO, size), false)
		return
	var horizon: float = size.y * 0.7
	# The sky: night at the top, rose, amber at the horizon.
	var middle: float = horizon * 0.55
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, middle), Vector2(0, middle)]),
		PackedColorArray([NIGHT, NIGHT, DAWN_BLUE, DAWN_BLUE]))
	draw_polygon(PackedVector2Array([Vector2(0, middle), Vector2(size.x, middle), Vector2(size.x, horizon),
		Vector2(0, horizon)]), PackedColorArray([DAWN_BLUE, DAWN_BLUE, DAWN_ROSE, DAWN_ROSE]))
	draw_polygon(PackedVector2Array([Vector2(0, horizon - 90.0), Vector2(size.x, horizon - 90.0),
		Vector2(size.x, horizon), Vector2(0, horizon)]),
		PackedColorArray([Color(DAWN_AMBER, 0.0), Color(DAWN_AMBER, 0.0), Color(DAWN_AMBER, 0.55), Color(DAWN_AMBER, 0.55)]))
	# The sun, half up, slowly rising.
	var sun: Vector2 = Vector2(size.x * 0.28, horizon - 20.0 - minf(_time * 0.6, 40.0))
	for i: int in range(7, 0, -1):
		draw_circle(sun, 70.0 + float(i) * 18.0, Color(DAWN_AMBER, 0.04))
	draw_circle(sun, 70.0, Color("#ffc27a"))
	for block: Dictionary in _blocks:
		var rect: Rect2 = Rect2(block["x"], horizon - float(block["h"]), block["w"], block["h"])
		draw_rect(rect, Color("#14122a"))
		draw_rect(rect, INK, false, 3.0)
		for window: Vector2 in block["windows"]:
			draw_rect(Rect2(rect.position + window, Vector2(12, 16)), Color(CANDLE, 0.6))
	_draw_court(Vector2(size.x * 0.5, horizon))
	draw_rect(Rect2(0, horizon, size.x, size.y - horizon), Color("#100d1c"))
	draw_line(Vector2(0, horizon), Vector2(size.x, horizon), INK, 6.0)


## The Court of Inheritance: steps, columns, a pediment and Aeva's clock.
func _draw_court(base: Vector2) -> void:
	var stone: Color = Color("#2a2540")
	var width: float = 620.0
	var left: float = base.x - width / 2.0
	for i: int in 3:
		draw_rect(Rect2(left - 30.0 + float(i) * 15.0, base.y - 20.0 * float(i + 1), width + 60.0 - float(i) * 30.0, 20.0),
			stone.darkened(0.1 * float(i)))
	var top: float = base.y - 60.0 - 300.0
	for i: int in 6:
		var column_x: float = left + 40.0 + float(i) * (width - 80.0) / 5.0
		draw_rect(Rect2(column_x - 18.0, top, 36.0, 300.0), stone)
		draw_rect(Rect2(column_x - 18.0, top, 36.0, 300.0), INK, false, 3.0)
	draw_rect(Rect2(left - 10.0, top - 30.0, width + 20.0, 30.0), stone)
	var roof: PackedVector2Array = PackedVector2Array([Vector2(left - 30.0, top - 30.0),
		Vector2(base.x, top - 170.0), Vector2(left + width + 30.0, top - 30.0)])
	draw_colored_polygon(roof, stone)
	roof.append(roof[0])
	draw_polyline(roof, INK, 4.0, true)
	# The clock in the pediment: its hands run a little too fast.
	var clock: Vector2 = Vector2(base.x, top - 82.0)
	draw_circle(clock, 50.0, Color(BONE, 0.9))
	draw_arc(clock, 50.0, 0.0, TAU, 48, INK, 4.0, true)
	for h: int in 12:
		var angle: float = TAU * float(h) / 12.0
		draw_line(clock + Vector2.from_angle(angle) * 40.0, clock + Vector2.from_angle(angle) * 46.0, INK, 3.0)
	var minute: float = _time * 0.8 - PI / 2.0
	var hour: float = _time * 0.8 / 12.0 - PI / 2.0 + 1.2
	draw_line(clock, clock + Vector2.from_angle(minute) * 40.0, INK, 3.0, true)
	draw_line(clock, clock + Vector2.from_angle(hour) * 26.0, INK, 5.0, true)
	draw_circle(clock, 5.0, INK)
