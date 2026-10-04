extends Control
## The sentence under the Rune Circle (docs/GRAMATICA.md 5): one slot per word of the
## sentence the selection reads, filled one by one (Element → Actions → Target), and a line
## under them: "???" for a spell not discovered yet, its name and effect once it is, or why
## the stones make no spell.

const SentenceParser = preload("res://scripts/core/sentence_parser.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const RoleSign = preload("res://scripts/ui/role_sign.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")

const BONE: Color = Color("#e9e3d2")
const MYSTERY: Color = Color("#ffb347")
const SLOT_HEIGHT: float = 46.0

var _slots: HBoxContainer
var _message: Label
## Slots appear one after another: how many words the last sentence had.
var _shown_parts: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("tutorial_id", "sentence")
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 2)
	add_child(box)
	_slots = HBoxContainer.new()
	_slots.alignment = BoxContainer.ALIGNMENT_CENTER
	_slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slots.add_theme_constant_override("separation", 6)
	_slots.custom_minimum_size = Vector2(0, SLOT_HEIGHT)
	box.add_child(_slots)
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 24)
	_message.add_theme_color_override("font_outline_color", Color("#05060a"))
	_message.add_theme_constant_override("outline_size", 8)
	box.add_child(_message)
	clear()


func clear() -> void:
	for child: Node in _slots.get_children():
		_slots.remove_child(child)
		child.queue_free()
	_message.text = ""
	_shown_parts = 0


## Shows the sentence of a preview (RoundState.preview: "sentence" and "plan").
func show_sentence(sentence: Dictionary, plan: Dictionary) -> void:
	var status: String = str(sentence.get("status", ""))
	var parts: Array = sentence.get("parts", [])
	var previous: int = _shown_parts
	clear()
	match status:
		SentenceParser.SPELL, SentenceParser.DORMANT:
			_add_parts(parts, previous)
		SentenceParser.INCOMPLETE:
			_add_parts(parts, previous)
			_add_arrow()
			_slots.add_child(_empty_slot())
	_shown_parts = parts.size() if status in [SentenceParser.SPELL, SentenceParser.DORMANT, SentenceParser.INCOMPLETE] else 0
	_message.text = _message_for(status, sentence, plan)
	_message.add_theme_color_override("font_color", _color_for(status, sentence))


func _add_parts(parts: Array, previous: int) -> void:
	for i: int in parts.size():
		if i > 0:
			_add_arrow()
		var slot: Control = _slot(str(parts[i]))
		_slots.add_child(slot)
		if i >= previous:
			# A new word drops into its slot.
			slot.modulate.a = 0.0
			var tween: Tween = slot.create_tween()
			tween.tween_property(slot, "modulate:a", 1.0, 0.18)


func _slot(rune_id: String) -> Control:
	var rune: Dictionary = GameData.runes.get(rune_id, {})
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"TooltipPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)
	var glyph: RuneGlyphScript = RuneGlyphScript.new()
	glyph.custom_minimum_size = Vector2(30, 30)
	glyph.rune_id = rune_id
	row.add_child(glyph)
	var mark: _RoleMark = _RoleMark.new()
	mark.role = str(rune.get("role", ""))
	row.add_child(mark)
	var label: Label = Label.new()
	label.text = Loc.text(rune.get("phrase", {}))
	label.add_theme_font_size_override("font_size", 22)
	row.add_child(label)
	return panel


func _empty_slot() -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"TooltipPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.modulate.a = 0.55
	var label: Label = Label.new()
	label.text = "…"
	label.theme_type_variation = &"SecondaryLabel"
	label.add_theme_font_size_override("font_size", 22)
	label.custom_minimum_size = Vector2(60, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel


func _add_arrow() -> void:
	var arrow: Label = Label.new()
	arrow.text = "→"
	arrow.theme_type_variation = &"SecondaryLabel"
	arrow.add_theme_font_size_override("font_size", 24)
	_slots.add_child(arrow)


func _message_for(status: String, sentence: Dictionary, plan: Dictionary) -> String:
	match status:
		SentenceParser.SPELL:
			var spell_id: String = sentence["spell"]
			var text: String = Loc.t("sentence_unknown")
			if SaveManager.has_discovery("spells", spell_id):
				var spell: Dictionary = GameData.spells[spell_id]
				text = Loc.t("sentence_spell", {"name": Loc.text(spell["name"]),
					"effect": SpellText.effect(spell, float(plan.get("scale", 1.0)))})
				if int(plan.get("repeats", 1)) > 1:
					text += " " + Loc.t("sentence_repeats", {"n": plan["repeats"]})
			for action_id: Variant in plan.get("ignored", []):
				text += " · " + Loc.t("sentence_ignored",
					{"phrase": Loc.text((GameData.runes.get(action_id, {}) as Dictionary).get("phrase", {}))})
			return text
		SentenceParser.DORMANT:
			return Loc.t("sentence_dormant")
		SentenceParser.INCOMPLETE:
			return Loc.t("sentence_incomplete")
		SentenceParser.WRONG_ORDER:
			return Loc.t("spell_wrong_order")
		SentenceParser.INTERRUPTED:
			return Loc.t("spell_interrupted")
	return ""


func _color_for(status: String, sentence: Dictionary) -> Color:
	if status == SentenceParser.SPELL:
		var spell_id: String = sentence["spell"]
		if SaveManager.has_discovery("spells", spell_id):
			return Color.html(str(GameData.spells[spell_id].get("color", "#e9e3d2")))
		return MYSTERY
	return Color(BONE, 0.85)


## The small role sign inside a slot.
class _RoleMark extends Control:
	var role: String = ""

	func _ready() -> void:
		custom_minimum_size = Vector2(16, 30)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		RoleSign.draw(self, role, Vector2(8, 15), 6.0)
