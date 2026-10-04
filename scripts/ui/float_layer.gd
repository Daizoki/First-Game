extends Control
## Numbers and short texts that jump out of the stones and float away while a Cast scores.

const RISE: float = 70.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Shows `text` centered on `at` (in this layer's coordinates) for `duration` seconds.
func spawn(text: String, at: Vector2, color: Color, font_size: int = 36, duration: float = 0.9) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("#05060a"))
	label.add_theme_constant_override("outline_size", 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	label.reset_size()
	label.position = at - label.size / 2.0
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(0.6, 0.6)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, duration * 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:y", label.position.y - RISE, duration)
	tween.parallel().tween_property(label, "modulate:a", 0.0, duration * 0.5).set_delay(duration * 0.5)
	tween.tween_callback(label.queue_free)
