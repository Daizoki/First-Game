extends Control
## The Scroll slot next to the hand (Gebo, docs/GRAMATICA.md 4): empty, it is a dashed
## outline; with a spell kept on it, a parchment with the spell's name. A click gets it
## ready to happen together with the next Cast (another click puts it away). The mouse
## card tells which spell it holds and what it does.

signal pressed

const SpellText = preload("res://scripts/ui/spell_text.gd")

const PARCHMENT: Color = Color("#d8c9a3")
const PARCHMENT_DARK: Color = Color("#a8936a")
const INK: Color = Color("#05060a")
const BONE: Color = Color("#e9e3d2")

## The spell on the Scroll ("" = empty).
var spell_id: String = "": set = set_spell
## Ready to happen with the next Cast.
var armed: bool = false: set = set_armed
var enabled: bool = true

var _time: float = 0.0
var _hovered: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_meta("tutorial_id", "scroll")
	mouse_entered.connect(func() -> void: _hovered = true)
	mouse_exited.connect(func() -> void: _hovered = false)
	_update_tooltip()


func set_spell(value: String) -> void:
	spell_id = value
	_update_tooltip()
	queue_redraw()


func set_armed(value: bool) -> void:
	armed = value
	_update_tooltip()
	queue_redraw()


func _update_tooltip() -> void:
	# The text itself is built in _make_custom_tooltip; it only has to be non-empty.
	tooltip_text = "scroll"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not spell_id.is_empty() else Control.CURSOR_ARROW


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if enabled and not spell_id.is_empty():
			pressed.emit()


func _process(delta: float) -> void:
	_time += delta
	if armed or _hovered:
		queue_redraw()


func _draw() -> void:
	var font: Font = get_theme_default_font()
	var rect: Rect2 = Rect2(Vector2(10, 14), size - Vector2(20, 28))
	if spell_id.is_empty():
		_draw_dashed(rect, Color(BONE, 0.35))
		draw_string(font, Vector2(0, size.y * 0.5 + 8.0), Loc.t("scroll_empty"), HORIZONTAL_ALIGNMENT_CENTER,
			size.x, 22, Color(BONE, 0.45))
		return
	var spell: Dictionary = GameData.spells.get(spell_id, {})
	var color: Color = Color.html(str(spell.get("color", "#e9e3d2")))
	if armed:
		var pulse: float = 0.6 + 0.4 * sin(_time * 4.0)
		for i: int in range(5, 0, -1):
			var grow: float = float(i) * 5.0
			draw_rect(rect.grow(grow), Color(color, 0.07 * pulse))
	var lift: Vector2 = Vector2(0, -4) if _hovered else Vector2.ZERO
	var body: Rect2 = Rect2(rect.position + lift, rect.size)
	draw_rect(body.grow(3.0), INK)
	draw_rect(body, PARCHMENT)
	# The rolled ends.
	for x: float in [body.position.x, body.end.x]:
		var roll: Rect2 = Rect2(Vector2(x - 8.0, body.position.y - 6.0), Vector2(16, body.size.y + 12.0))
		draw_rect(roll.grow(2.0), INK)
		draw_rect(roll, PARCHMENT_DARK)
	draw_string(font, Vector2(body.position.x, body.position.y + body.size.y * 0.45), Loc.text(spell.get("name", {})),
		HORIZONTAL_ALIGNMENT_CENTER, body.size.x, 26, INK)
	var hint: String = Loc.t("scroll_armed") if armed else Loc.t("scroll_use")
	draw_string(font, Vector2(body.position.x, body.position.y + body.size.y * 0.8), hint,
		HORIZONTAL_ALIGNMENT_CENTER, body.size.x, 17, Color(INK, 0.75))


func _draw_dashed(rect: Rect2, color: Color) -> void:
	var corners: Array[Vector2] = [rect.position, Vector2(rect.end.x, rect.position.y), rect.end,
		Vector2(rect.position.x, rect.end.y)]
	for i: int in 4:
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % 4]
		var length: float = a.distance_to(b)
		var step: float = 14.0
		var t: float = 0.0
		while t < length:
			draw_line(a.lerp(b, t / length), a.lerp(b, minf(t + step * 0.55, length) / length), color, 2.0)
			t += step


## The mouse card: what the Scroll holds and how to use it.
func _make_custom_tooltip(_for_text: String) -> Object:
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"TooltipPanel"
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var title: Label = Label.new()
	title.theme_type_variation = &"TitleLabel"
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)
	var text: Label = Label.new()
	text.custom_minimum_size = Vector2(420, 0)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 23)
	box.add_child(text)
	if spell_id.is_empty():
		title.text = Loc.t("scroll_title")
		text.text = Loc.t("scroll_card_empty")
	else:
		var spell: Dictionary = GameData.spells.get(spell_id, {})
		title.text = Loc.text(spell.get("name", {}))
		title.add_theme_color_override("font_color", Color.html(str(spell.get("color", "#e9e3d2"))))
		text.text = "%s\n%s" % [SpellText.effect(spell),
			Loc.t("scroll_card_armed") if armed else Loc.t("scroll_card_use")]
	return panel
