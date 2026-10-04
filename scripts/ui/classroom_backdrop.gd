extends Control
## Placeholder background for the evening class (until Relax draws
## art/backgrounds/classroom.png): the lecture hall of the School of Runes the night before
## the exam — a dark wall, a blackboard with chalk runes, a hanging lamp, old desks.

const ART: String = "res://art/backgrounds/classroom.png"
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const NIGHT: Color = Color("#0a0c18")
const VIOLET: Color = Color("#241b3a")
const INK: Color = Color("#05060a")
const BONE: Color = Color("#e9e3d2")
const CANDLE: Color = Color("#ffb347")
const BOARD: Color = Color("#141c1d")
const WOOD: Color = Color("#2a1d1a")
## Runes chalked on the board: [rune id, x, y, size] in board coordinates (0..1).
const BOARD_RUNES: Array = [
	["fehu", 0.08, 0.16, 0.13], ["hagalaz", 0.24, 0.2, 0.11], ["tiwaz", 0.4, 0.14, 0.12],
	["isaz", 0.57, 0.18, 0.1], ["kenaz", 0.72, 0.15, 0.11], ["dagaz", 0.86, 0.22, 0.1],
]

var _time: float = 0.0
var _art: Texture2D = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(ART):
		_art = load(ART) as Texture2D


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _art != null:
		draw_texture_rect(_art, Rect2(Vector2.ZERO, size), false)
		_draw_lamp_glow(Vector2(size.x * 0.16, size.y * 0.2))
		return
	var floor_y: float = size.y * 0.7
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), Vector2(size.x, floor_y), Vector2(0, floor_y)]),
		PackedColorArray([NIGHT, NIGHT, VIOLET.darkened(0.3), VIOLET.darkened(0.3)]))
	# Wall planks.
	for i: int in 14:
		var x: float = size.x * float(i) / 14.0
		draw_line(Vector2(x, 0), Vector2(x, floor_y), Color(INK, 0.35), 3.0)
	_draw_board(Rect2(size.x * 0.27, size.y * 0.035, size.x * 0.46, size.y * 0.42))
	_draw_window(Rect2(size.x * 0.81, size.y * 0.3, size.x * 0.13, size.y * 0.3))
	draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), Color("#0c0a15"))
	draw_line(Vector2(0, floor_y), Vector2(size.x, floor_y), INK, 6.0)
	_draw_desks(floor_y)
	_draw_lamp_glow(Vector2(size.x * 0.16, size.y * 0.2))


func _draw_board(rect: Rect2) -> void:
	draw_rect(rect.grow(18.0), WOOD)
	draw_rect(rect.grow(18.0), INK, false, 5.0)
	draw_rect(rect, BOARD)
	# Old smudges of wiped chalk.
	for i: int in 5:
		var at: Vector2 = rect.position + rect.size * Vector2(0.15 + 0.17 * float(i), 0.62 + 0.08 * sin(float(i)))
		draw_circle(at, 60.0, Color(BONE, 0.014))
	for entry: Array in BOARD_RUNES:
		var rune: Dictionary = GameData.runes.get(entry[0], {})
		var side: float = rect.size.y * float(entry[3]) * 2.0
		var box: Rect2 = Rect2(rect.position + rect.size * Vector2(entry[1], entry[2]), Vector2(side, side))
		RuneGlyphScript.draw_segments(self, rune.get("segments", []), box, 4.0, Color(BONE, 0.55))
	# A chalk line of "homework" under the runes and the chalk tray.
	var y: float = rect.position.y + rect.size.y * 0.78
	draw_line(Vector2(rect.position.x + 40.0, y), Vector2(rect.end.x - 120.0, y), Color(BONE, 0.25), 3.0)
	draw_rect(Rect2(rect.position.x - 10.0, rect.end.y + 18.0, rect.size.x + 20.0, 12.0), WOOD.darkened(0.3))


func _draw_window(rect: Rect2) -> void:
	draw_rect(rect, Color("#101631"))
	draw_circle(rect.position + rect.size * Vector2(0.62, 0.3), rect.size.x * 0.16, Color(BONE, 0.85))
	draw_rect(rect, INK, false, 8.0)
	draw_line(Vector2(rect.get_center().x, rect.position.y), Vector2(rect.get_center().x, rect.end.y), INK, 6.0)
	draw_line(Vector2(rect.position.x, rect.get_center().y), Vector2(rect.end.x, rect.get_center().y), INK, 6.0)


func _draw_desks(floor_y: float) -> void:
	for row: int in 2:
		var y: float = floor_y + 40.0 + float(row) * 140.0
		var count: int = 5 + row
		for i: int in count:
			var width: float = size.x / float(count) - 60.0
			var x: float = 30.0 + float(i) * (width + 60.0)
			draw_rect(Rect2(x, y, width, 26.0), WOOD.darkened(0.35 - 0.1 * float(row)))
			draw_rect(Rect2(x, y, width, 26.0), INK, false, 3.0)
			draw_rect(Rect2(x + 12.0, y + 26.0, 14.0, 70.0), INK)
			draw_rect(Rect2(x + width - 26.0, y + 26.0, 14.0, 70.0), INK)


func _draw_lamp_glow(at: Vector2) -> void:
	var flicker: float = 0.85 + 0.15 * sin(_time * 7.0) * sin(_time * 3.1)
	draw_line(Vector2(at.x, 0), at, INK, 4.0)
	for i: int in range(8, 0, -1):
		draw_circle(at, 40.0 + float(i) * 34.0, Color(CANDLE, 0.022 * flicker))
	draw_colored_polygon(PackedVector2Array([at + Vector2(-46, 30), at + Vector2(46, 30), at + Vector2(20, -6),
		at + Vector2(-20, -6)]), INK)
	draw_circle(at + Vector2(0, 34), 14.0, Color(CANDLE, 0.9 * flicker))
