extends Control
## Aeva turns back time (DESIGN 3.13, a moment made for clips): the screen darkens, a big
## clock face spins backwards faster and faster, "Aeva turns back time…", then a flash.
## play() returns when it is over; the caller then goes to the Morning.

signal finished

const DURATION: float = 2.2
const BONE: Color = Color("#e9e3d2")
const AEVA: Color = Color("#b59be0")

var _t: float = 0.0
var _playing: bool = false
var _text: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_text = Label.new()
	_text.theme_type_variation = &"TitleLabel"
	_text.add_theme_font_size_override("font_size", 56)
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_text.offset_top = -220.0
	_text.offset_bottom = -140.0
	_text.offset_left = -600.0
	_text.offset_right = 600.0
	add_child(_text)


func play() -> void:
	_text.text = Loc.t("rewind_text")
	_text.modulate.a = 0.0
	_t = 0.0
	_playing = true
	visible = true
	var tween: Tween = create_tween()
	tween.tween_property(_text, "modulate:a", 1.0, 0.5)
	await finished


func _process(delta: float) -> void:
	if not _playing:
		return
	_t += delta
	queue_redraw()
	if _t >= DURATION:
		_playing = false
		finished.emit()


func _draw() -> void:
	var share: float = clampf(_t / DURATION, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.05, minf(1.0, share * 3.0)))
	var center: Vector2 = size / 2.0 - Vector2(0, 60)
	var radius: float = 260.0 + 40.0 * share
	for i: int in range(8, 0, -1):
		draw_circle(center, radius + float(i) * 14.0, Color(AEVA, 0.02 * share))
	draw_arc(center, radius, 0.0, TAU, 96, Color(BONE, 0.85 * minf(1.0, share * 4.0)), 5.0, true)
	for h: int in 12:
		var angle: float = TAU * float(h) / 12.0
		draw_line(center + Vector2.from_angle(angle) * (radius - 30.0), center + Vector2.from_angle(angle) * (radius - 8.0),
			Color(BONE, 0.8), 4.0)
	# The hands run backwards, faster and faster.
	var turns: float = -pow(share, 2.0) * 10.0
	draw_line(center, center + Vector2.from_angle(TAU * turns - PI / 2.0) * (radius - 50.0), BONE, 6.0, true)
	draw_line(center, center + Vector2.from_angle(TAU * turns / 12.0 - PI / 2.0) * (radius - 110.0), BONE, 10.0, true)
	draw_circle(center, 10.0, BONE)
	# The flash at the end.
	if share > 0.85:
		draw_rect(Rect2(Vector2.ZERO, size), Color(BONE, (share - 0.85) / 0.15))
