extends Control
## The big moment when a Spell is cast for the first time (3.15 / 3.16): the screen darkens,
## a dotted circle turns, the Spell's runes pop onto it and join into a seal, then its name
## appears huge in its color with the formula, the effect and the Memories gained.
## Made to look good on video. Click anywhere to close.

signal closed

const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")

const CIRCLE_RADIUS: float = 170.0
const CIRCLE_CENTER_Y: float = 350.0

@onready var _title: Label = %RevealTitle
@onready var _spell_name: Label = %SpellName
@onready var _formula: Label = %Formula
@onready var _effect: Label = %Effect
@onready var _memories: Label = %Memories
@onready var _continue: Label = %ContinueHint

var _runes: Array[Dictionary] = []
var _pops: Array[float] = []
var _seal: float = 0.0
var _dark: float = 0.0
var _color: Color = Color.WHITE
var _time: float = 0.0
var _can_close: bool = false


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP


func reveal(spell: Dictionary, memories: int) -> void:
	_color = Color.html(str(spell.get("color", "#e9e3d2")))
	_runes.clear()
	var parts: PackedStringArray = []
	for rune_id: Variant in spell["runes"]:
		var rune: Dictionary = GameData.runes.get(rune_id, {})
		_runes.append(rune)
		var meaning: String = Loc.text(rune.get("meaning", {})).split(",")[0].split(";")[0]
		parts.append("%s · %s" % [Loc.text(rune.get("name", {})), meaning.strip_edges()])
	_pops.clear()
	_pops.resize(_runes.size())
	_pops.fill(0.0)
	_seal = 0.0
	_dark = 0.0
	_can_close = false
	_title.text = Loc.t("spell_reveal_title")
	_spell_name.text = Loc.text(spell["name"])
	_spell_name.add_theme_color_override("font_color", _color)
	_formula.text = "  +  ".join(parts)
	_effect.text = Loc.text(spell["effect"])
	_memories.text = Loc.t("spell_reveal_memories", {"n": memories})
	_continue.text = Loc.t("spell_reveal_continue")
	for label: Label in [_title, _spell_name, _formula, _effect, _memories, _continue]:
		label.modulate.a = 0.0
	visible = true

	var tween: Tween = create_tween()
	tween.tween_property(self, "_dark", 1.0, 0.4)
	tween.tween_property(_title, "modulate:a", 1.0, 0.3)
	for i: int in _runes.size():
		tween.tween_method(_set_pop.bind(i), 0.0, 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_seal", 1.0, 0.5)
	tween.tween_property(_spell_name, "modulate:a", 1.0, 0.25)
	tween.parallel().tween_property(_spell_name, "scale", Vector2.ONE, 0.45).from(Vector2(1.6, 1.6)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_formula, "modulate:a", 1.0, 0.3)
	tween.tween_property(_effect, "modulate:a", 1.0, 0.3)
	tween.tween_property(_memories, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func() -> void: _can_close = true)
	tween.tween_property(_continue, "modulate:a", 0.8, 0.4)


func _set_pop(value: float, index: int) -> void:
	_pops[index] = value


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and _can_close:
		accept_event()
		visible = false
		closed.emit()


func _process(delta: float) -> void:
	if visible:
		_time += delta
		_spell_name.pivot_offset = _spell_name.size / 2.0
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.05, 0.88 * _dark))
	var center: Vector2 = Vector2(size.x / 2.0, CIRCLE_CENTER_Y)
	for i: int in range(10, 0, -1):
		draw_circle(center, CIRCLE_RADIUS + float(i) * 12.0, Color(_color, 0.02 * _dark))
	# Dotted circle, turning.
	var dots: int = 72
	for i: int in dots:
		var angle: float = _time * 0.4 + TAU * float(i) / float(dots)
		draw_circle(center + Vector2.from_angle(angle) * CIRCLE_RADIUS, 3.0, Color(_color, 0.7 * _dark))
	var points: Array[Vector2] = []
	for i: int in _runes.size():
		var angle: float = -PI / 2.0 + TAU * float(i) / float(_runes.size())
		points.append(center + Vector2.from_angle(angle) * CIRCLE_RADIUS)
	# The seal: lines joining the runes.
	if _seal > 0.0 and points.size() > 1:
		for i: int in points.size():
			var a: Vector2 = points[i]
			var b: Vector2 = points[(i + 1) % points.size()]
			if points.size() == 2 and i == 1:
				break
			draw_line(a, a.lerp(b, _seal), Color(_color, 0.9), 5.0, true)
	for i: int in points.size():
		var pop: float = _pops[i]
		if pop <= 0.0:
			continue
		var half: float = 60.0 * pop
		draw_circle(points[i], half * 1.2, Color("#0a0c18"))
		draw_arc(points[i], half * 1.2, 0.0, TAU, 48, Color(_color, 0.9), 4.0, true)
		var rect: Rect2 = Rect2(points[i] - Vector2(half, half) * 0.75, Vector2(half, half) * 1.5)
		var segments: Array = _runes[i].get("segments", [])
		for layer: int in range(4, 0, -1):
			RuneGlyphScript.draw_segments(self, segments, rect, 6.0 + float(layer) * 6.0, Color(_color, 0.12))
		RuneGlyphScript.draw_segments(self, segments, rect, 8.0, _color)
		RuneGlyphScript.draw_segments(self, segments, rect, 3.0, Color.WHITE)
