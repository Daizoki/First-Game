extends Control
## A monster's life bar (docs/PROMPT_ETAPA5.md 9): red life, a white "ghost" that follows a
## moment later to show the damage just taken, the life in numbers, and one notch per head of
## the Balaur still waiting.

const INK: Color = Color("#05060a")
const BACK: Color = Color("#140c16")
const LIFE: Color = Color("#c8322a")
const LIFE_LIGHT: Color = Color("#ff6a3d")
const GHOST: Color = Color("#e9e3d2")
const BONE: Color = Color("#e9e3d2")
const SHIELD: Color = Color("#63c6f2")
const GHOST_DELAY: float = 0.35
const GHOST_TIME: float = 0.45

var max_value: float = 1.0
var value: float = 1.0
## Heads still to come after this one (drawn as small marks on the right).
var heads_left: int = 0
## The monster's Shield (shown as a blue edge with its number).
var shield: float = 0.0

var _ghost: float = 1.0
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Sets the life at once (a new monster, a new head).
func reset(life: float, most: float) -> void:
	max_value = maxf(1.0, most)
	value = clampf(life, 0.0, max_value)
	_ghost = value
	if _tween != null:
		_tween.kill()
	queue_redraw()


## Life after a hit: the red part drops now, the ghost follows.
func set_life(life: float) -> void:
	var before: float = _ghost
	value = clampf(life, 0.0, max_value)
	if value > before:
		_ghost = value
		queue_redraw()
		return
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(GHOST_DELAY)
	_tween.tween_method(_set_ghost, before, value, GHOST_TIME).set_ease(Tween.EASE_OUT)
	queue_redraw()


func _set_ghost(amount: float) -> void:
	_ghost = amount
	queue_redraw()


func _draw() -> void:
	var notch: float = 18.0 * heads_left
	var bar: Rect2 = Rect2(Vector2.ZERO, Vector2(size.x - notch, size.y))
	draw_rect(bar.grow(3.0), INK)
	draw_rect(bar, BACK)
	var ghost_w: float = bar.size.x * clampf(_ghost / max_value, 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(ghost_w, bar.size.y)), GHOST)
	var life_w: float = bar.size.x * clampf(value / max_value, 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(life_w, bar.size.y)), LIFE)
	draw_rect(Rect2(bar.position, Vector2(life_w, bar.size.y * 0.35)), LIFE_LIGHT.darkened(0.15))
	if shield > 0.0:
		draw_rect(bar, SHIELD, false, 3.0)
	for i: int in heads_left:
		var center: Vector2 = Vector2(bar.end.x + 12.0 + 18.0 * i, size.y / 2.0)
		draw_circle(center, 7.0, LIFE)
		draw_arc(center, 7.0, 0.0, TAU, 16, INK, 2.0)
	var font: Font = get_theme_font("font", "Label")
	var font_size: int = int(clampf(size.y * 0.62, 14.0, 30.0))
	var text: String = "%s / %s" % [Loc.number(ceilf(value)), Loc.number(max_value)]
	if shield > 0.0:
		text += "  ◆" + Loc.number(shield)
	var baseline: float = (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	draw_string_outline(font, Vector2(0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, font_size, 6, INK)
	draw_string(font, Vector2(0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, font_size, BONE)
