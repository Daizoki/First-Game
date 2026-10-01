extends Control
## Talismans hang on a string like cards held by clips and sway gently (Stage 3 fills the
## slots). For now: the string with 5 empty clips. With show_rope off it draws loose,
## slightly rotated slots (the 2 consumables).

const INK: Color = Color("#05060a")
const ROPE: Color = Color("#8a6a3e")
const SLOT: Color = Color("#a39db4")
const CARD_SIZE: Vector2 = Vector2(96, 134)

@export var slots: int = 5
@export var show_rope: bool = true
var empty_label: String = ""

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if show_rope:
		var rope: PackedVector2Array = []
		for i: int in 25:
			var rx: float = size.x * float(i) / 24.0
			rope.append(Vector2(rx, 18.0 + 22.0 * sin(PI * float(i) / 24.0)))
		draw_polyline(rope, ROPE, 4.0, true)
	var font: Font = get_theme_default_font()
	for s: int in slots:
		var x: float = size.x * (float(s) + 0.5) / float(slots)
		var y: float = 18.0 + 22.0 * sin(PI * x / size.x) if show_rope else 0.0
		var swing: float = 0.05 * sin(_time * 1.4 + float(s)) if show_rope else (0.07 if s % 2 == 0 else -0.05)
		draw_set_transform(Vector2(x, y), swing, Vector2.ONE)
		if show_rope:
			draw_rect(Rect2(-6, -6, 12, 16), INK)
		var card: Rect2 = Rect2(Vector2(-CARD_SIZE.x / 2.0, 10), CARD_SIZE)
		_draw_dashed_rect(card, Color(SLOT, 0.5))
		draw_string(font, card.position + Vector2(0, CARD_SIZE.y / 2.0 + 6), empty_label,
			HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x, 18, Color(SLOT, 0.6))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_dashed_rect(rect: Rect2, color: Color) -> void:
	var corners: Array[Vector2] = [rect.position, rect.position + Vector2(rect.size.x, 0), rect.end,
		rect.position + Vector2(0, rect.size.y), rect.position]
	for i: int in 4:
		draw_dashed_line(corners[i], corners[i + 1], color, 2.0, 8.0)
