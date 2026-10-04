extends Control
## A small drawn stone (examples in the Book of Words): a rounded stone in ink, the rune in
## its kin color and the Position in the corner. "blank" shows an empty stone with "?".

const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const RoleSign = preload("res://scripts/ui/role_sign.gd")

const SIZE: Vector2 = Vector2(46, 58)
const INK: Color = Color("#05060a")
const STONE_FILL: Color = Color("#2c2840")
const BONE: Color = Color("#e9e3d2")

var rune_id: String = ""
var blank: bool = false
## The role sign of the rune grammar in the top-right corner.
var show_role: bool = false


func _ready() -> void:
	custom_minimum_size = SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2(2, 2), SIZE - Vector2(4, 4))
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = STONE_FILL
	box.border_color = INK
	box.set_border_width_all(3)
	box.set_corner_radius_all(12)
	draw_style_box(box, rect)
	var font: Font = get_theme_default_font()
	if blank or rune_id.is_empty():
		draw_string(font, Vector2(0, SIZE.y * 0.66), "?", HORIZONTAL_ALIGNMENT_CENTER, SIZE.x, 26, BONE)
		return
	var rune: Dictionary = GameData.runes.get(rune_id, {})
	var color: Color = GameData.kin_color(str(rune.get("kin", "")))
	var glyph_box: Rect2 = Rect2(Vector2(SIZE.x * 0.24, SIZE.y * 0.28), Vector2(SIZE.x * 0.52, SIZE.y * 0.52))
	RuneGlyphScript.draw_segments(self, rune.get("segments", []), glyph_box, 5.0, Color(color, 0.35))
	RuneGlyphScript.draw_segments(self, rune.get("segments", []), glyph_box, 2.5, color)
	draw_string(font, Vector2(8, 19), str(rune.get("position", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, BONE)
	if show_role:
		RoleSign.draw(self, str(rune.get("role", "")), Vector2(SIZE.x - 12.0, 13.0), 5.0)
