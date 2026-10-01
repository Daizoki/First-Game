extends Control
## A round portrait. Uses art/examiners/<id>.png when Relax has drawn it; otherwise a circle
## in the character's color with the initial.

const INK: Color = Color("#05060a")
const BONE: Color = Color("#e9e3d2")
const ART_PATH: String = "res://art/examiners/%s.png"

var character_id: String = "": set = set_character_id

var _color: Color = Color("#808080")
var _initial: String = ""
var _art: Texture2D = null


func set_character_id(value: String) -> void:
	character_id = value
	var character: Dictionary = GameData.characters.get(value, {})
	_color = Color.html(str(character.get("color", "#808080")))
	_initial = Loc.text(character.get("name", {})).substr(0, 1)
	_art = null
	var path: String = ART_PATH % value
	if ResourceLoader.exists(path):
		_art = load(path) as Texture2D
	queue_redraw()


func _draw() -> void:
	var center: Vector2 = size / 2.0
	var radius: float = minf(size.x, size.y) / 2.0 - 4.0
	draw_circle(center, radius + 4.0, INK)
	if _art != null:
		draw_texture_rect(_art, Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false)
	else:
		draw_circle(center, radius, _color.darkened(0.45))
		draw_circle(center, radius * 0.86, _color.darkened(0.2))
		var font: Font = get_theme_font("font", "TitleLabel")
		draw_string(font, center + Vector2(-radius, radius * 0.38), _initial, HORIZONTAL_ALIGNMENT_CENTER,
			radius * 2.0, int(radius * 1.1), BONE)
	draw_arc(center, radius, 0.0, TAU, 64, Color("#241b3a"), 4.0, true)
