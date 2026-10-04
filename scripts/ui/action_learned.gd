extends Control
## The small moment when an Action is used for the first time (docs/GRAMATICA.md 5): its
## rune pops up over the circle inside a ring that opens, with "You learned: runs twice"
## and what the Action does. It does not block the game and leaves by itself.

signal finished

const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const RoleSign = preload("res://scripts/ui/role_sign.gd")

const ACCENT: Color = Color("#ffb347")
const BONE: Color = Color("#e9e3d2")
const HOLD: float = 2.4

## Where the ring opens (the middle of the Rune Circle), in this control's coordinates.
var center: Vector2 = Vector2(960, 420)

var _segments: Array = []
var _pop: float = 0.0
var _ring: float = 0.0
var _fade: float = 0.0
var _title: Label
var _phrase: Label
var _effect: Label
var _box: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_box = VBoxContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_constant_override("separation", 0)
	add_child(_box)
	_title = _label(28, &"SecondaryLabel")
	_phrase = _label(52, &"TitleLabel")
	_phrase.add_theme_color_override("font_color", ACCENT)
	_effect = _label(24, &"")
	_effect.custom_minimum_size = Vector2(620, 0)
	_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


## Plays the moment for this Action; speed is the score animation's speed (1, 2, 4).
func play(action_id: String, speed: float = 1.0) -> void:
	var rune: Dictionary = GameData.runes.get(action_id, {})
	var action: Dictionary = GameData.spell_actions.get(action_id, {})
	_segments = rune.get("segments", [])
	_title.text = Loc.t("action_learned_title")
	_phrase.text = Loc.text(rune.get("phrase", {}))
	_effect.text = Loc.text(action.get("effect", {}))
	_box.reset_size()
	_box.position = Vector2(center.x - _box.size.x * 0.5, center.y + 62.0)
	_pop = 0.0
	_ring = 0.0
	_fade = 1.0
	_box.modulate.a = 0.0
	visible = true
	var pace: float = 1.0 / maxf(1.0, speed * 0.5)
	var tween: Tween = create_tween()
	tween.tween_property(self, "_pop", 1.0, 0.35 * pace).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "_ring", 1.0, 0.7 * pace)
	tween.tween_property(_box, "modulate:a", 1.0, 0.25 * pace)
	tween.tween_interval(HOLD * pace)
	tween.tween_property(self, "_fade", 0.0, 0.35 * pace)
	tween.parallel().tween_property(_box, "modulate:a", 0.0, 0.35 * pace)
	await tween.finished
	visible = false
	finished.emit()


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	if _pop <= 0.0:
		return
	var alpha: float = _fade
	draw_circle(center, 168.0, Color(0.02, 0.02, 0.05, 0.92 * alpha))
	for i: int in 3:
		var r: float = 60.0 + _ring * (50.0 + float(i) * 22.0)
		draw_arc(center, r, 0.0, TAU, 64, Color(ACCENT, (0.8 - float(i) * 0.25) * alpha * (1.2 - _ring * 0.6)), 3.0, true)
	var half: float = 46.0 * _pop
	var rect: Rect2 = Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0)
	for layer: int in range(4, 0, -1):
		RuneGlyphScript.draw_segments(self, _segments, rect, 6.0 + float(layer) * 5.0, Color(ACCENT, 0.12 * alpha))
	RuneGlyphScript.draw_segments(self, _segments, rect, 7.0, Color(ACCENT, alpha))
	RuneGlyphScript.draw_segments(self, _segments, rect, 3.0, Color(1, 1, 1, alpha))
	RoleSign.draw(self, "action", center + Vector2(70.0, -70.0) * _pop, 12.0, Color(BONE, alpha))


func _label(font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color("#05060a"))
	label.add_theme_constant_override("outline_size", 8)
	_box.add_child(label)
	return label
