extends RefCounted
## The role sign of a rune in the grammar (docs/GRAMATICA.md 5), drawn in bone color:
## Element = a filled triangle, Action = an arrow, Target = a circle with a dot.

const BONE: Color = Color("#e9e3d2")
const INK: Color = Color("#05060a")


## Draws the sign for `role` centered at `at`, about `radius` from the middle to its edge.
static func draw(canvas: CanvasItem, role: String, at: Vector2, radius: float, color: Color = BONE) -> void:
	var width: float = maxf(2.0, radius * 0.24)
	match role:
		"element":
			var points: PackedVector2Array = []
			for i: int in 3:
				points.append(at + Vector2.from_angle(-PI / 2.0 + TAU * float(i) / 3.0) * radius)
			var outline: PackedVector2Array = []
			for point: Vector2 in points:
				outline.append(at + (point - at) * 1.25)
			canvas.draw_colored_polygon(outline, Color(INK, 0.8))
			canvas.draw_colored_polygon(points, color)
		"action":
			var tail: Vector2 = at + Vector2(-radius, 0)
			var tip: Vector2 = at + Vector2(radius, 0)
			var wing: float = radius * 0.65
			for pass_index: int in 2:
				var stroke: Color = Color(INK, 0.8) if pass_index == 0 else color
				var w: float = width + (3.0 if pass_index == 0 else 0.0)
				canvas.draw_line(tail, tip, stroke, w, true)
				canvas.draw_line(tip, tip + Vector2(-wing, -wing), stroke, w, true)
				canvas.draw_line(tip, tip + Vector2(-wing, wing), stroke, w, true)
		"target":
			canvas.draw_arc(at, radius, 0.0, TAU, 32, Color(INK, 0.8), width + 3.0, true)
			canvas.draw_arc(at, radius, 0.0, TAU, 32, color, width, true)
			canvas.draw_circle(at, radius * 0.3, color)


## The rune's role ("" when it has none).
static func role_of(rune_id: String) -> String:
	return str((GameData.runes.get(rune_id, {}) as Dictionary).get("role", ""))
