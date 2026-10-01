extends Control
## Placeholder background (until Relax draws art/backgrounds/round_table.png): the City of the
## Threshold at night — moon, blocks with a few lit windows, a ruined temple, trolleybus
## wires, slow violet fog and a dark table in the foreground.

const ART: String = "res://art/backgrounds/round_table.png"
const NIGHT: Color = Color("#0a0c18")
const VIOLET: Color = Color("#241b3a")
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
	rng.seed = 22
	var x: float = -40.0
	while x < 1960.0:
		var width: float = rng.randf_range(120.0, 230.0)
		var height: float = rng.randf_range(180.0, 380.0)
		var windows: Array[Vector2] = []
		for wy: int in int(height / 34.0) - 1:
			for wx: int in int(width / 30.0) - 1:
				if rng.randf() < 0.13:
					windows.append(Vector2(14.0 + float(wx) * 30.0, 18.0 + float(wy) * 34.0))
		_blocks.append({"x": x, "w": width, "h": height, "windows": windows})
		x += width + rng.randf_range(6.0, 40.0)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _art != null:
		draw_texture_rect(_art, Rect2(Vector2.ZERO, size), false)
		_draw_fog()
		return
	var horizon: float = size.y * 0.66
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, horizon), Vector2(0, horizon)]),
		PackedColorArray([NIGHT, NIGHT, VIOLET, VIOLET]))
	var moon: Vector2 = Vector2(size.x * 0.685, size.y * 0.34)
	for i: int in range(6, 0, -1):
		draw_circle(moon, 58.0 + float(i) * 14.0, Color(BONE, 0.025))
	draw_circle(moon, 58.0, Color(BONE, 0.9))
	draw_circle(moon + Vector2(-18, -10), 12.0, Color(0.8, 0.77, 0.7, 0.6))
	_draw_ruin(Vector2(size.x * 0.2, horizon))
	for block: Dictionary in _blocks:
		var rect: Rect2 = Rect2(block["x"], horizon - float(block["h"]), block["w"], block["h"])
		draw_rect(rect, Color("#0e0d1c"))
		draw_rect(rect, INK, false, 3.0)
		for window: Vector2 in block["windows"]:
			draw_rect(Rect2(rect.position + window, Vector2(12, 16)), Color(CANDLE, 0.75))
	# Trolleybus wires.
	for k: int in 2:
		var wire: PackedVector2Array = []
		for i: int in 33:
			var wx: float = size.x * float(i) / 32.0
			wire.append(Vector2(wx, size.y * (0.3 + 0.025 * float(k)) + 26.0 * sin(PI * float(i) / 32.0)))
		draw_polyline(wire, INK, 2.0, true)
	_draw_fog()
	draw_rect(Rect2(0, horizon, size.x, size.y - horizon), Color("#0c0a15"))
	draw_line(Vector2(0, horizon), Vector2(size.x, horizon), INK, 6.0)


func _draw_ruin(base: Vector2) -> void:
	var color: Color = Color("#141226")
	for i: int in 4:
		var height: float = 230.0 - float(i % 3) * 60.0
		draw_rect(Rect2(base + Vector2(float(i) * 70.0, -height), Vector2(34, height)), color)
	draw_colored_polygon(PackedVector2Array([base + Vector2(-20, -230), base + Vector2(140, -300),
		base + Vector2(250, -240)]), color)


func _draw_fog() -> void:
	for i: int in 7:
		var drift: float = fmod(_time * (8.0 + float(i) * 2.0) + float(i) * 300.0, size.x + 800.0) - 400.0
		var at: Vector2 = Vector2(drift, size.y * (0.45 + 0.06 * float(i % 4)))
		for k: int in 3:
			draw_circle(at + Vector2(float(k) * 120.0, 0), 160.0 - float(k) * 30.0, Color(VIOLET, 0.05))
