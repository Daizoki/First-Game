extends PanelContainer
## The card shown while the mouse is over a stone: the rune, its Kin, its historical meaning,
## its role in the rune grammar and what it does in a sentence, its material and the rune
## bound to it.

const Stone = preload("res://scripts/core/stone.gd")
const RuneGlyphScript = preload("res://scripts/ui/rune_glyph.gd")
const SpellText = preload("res://scripts/ui/spell_text.gd")

const WIDTH: float = 470.0
const GAP: float = 16.0
const MARGIN: float = 16.0

var _glyph: RuneGlyphScript
var _name: Label
var _kin: Label
var _role: Label
var _meaning: Label
var _power: Label
var _does: Label
## The role line (off while the rune grammar is not taught yet).
var show_role: bool = true
## The Elements' levels this Journey (element id -> level), for an Element's numbers.
var levels: Dictionary = {}

var _stone: Stone = null
var _anchor: Control = null


func _ready() -> void:
	theme_type_variation = &"TooltipPanel"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	var head: HBoxContainer = HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	box.add_child(head)
	_glyph = RuneGlyphScript.new()
	_glyph.custom_minimum_size = Vector2(64, 64)
	head.add_child(_glyph)
	var titles: VBoxContainer = VBoxContainer.new()
	titles.add_theme_constant_override("separation", -4)
	head.add_child(titles)
	_name = _label(titles, 38, &"TitleLabel")
	_kin = _label(titles, 24, &"")
	_role = _label(box, 25, &"")
	_meaning = _label(box, 25, &"")
	_power = _label(box, 25, &"SecondaryLabel")
	_does = _label(box, 25, &"")
	for label: Label in [_meaning, _does]:
		label.custom_minimum_size = Vector2(WIDTH - 40.0, 0)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


## Shows the card for this stone above `anchor` (the stone's view); null hides it.
func show_stone(stone: Stone, anchor: Control) -> void:
	_stone = stone
	_anchor = anchor
	visible = stone != null
	if stone == null:
		return
	if stone.face_down:
		_show_hidden()
		return
	_glyph.visible = true
	for label: Label in [_kin, _meaning, _power]:
		label.visible = true
	var rune: Dictionary = GameData.runes.get(stone.rune_id, {})
	var kin: Dictionary = GameData.kins.get(stone.kin, {})
	_glyph.rune_id = stone.rune_id
	_name.text = Loc.text(rune.get("name", {}))
	_kin.text = Loc.text(kin.get("name", {}))
	_kin.add_theme_color_override("font_color", GameData.kin_color(stone.kin))
	_role.text = Loc.t("card_role", {"role": Loc.t("role_" + str(rune.get("role", ""))),
		"phrase": Loc.text(rune.get("phrase", {}))})
	_role.visible = show_role and rune.has("role")
	_meaning.text = Loc.t("card_meaning", {"meaning": Loc.text(rune.get("meaning", {}))})
	_power.text = Loc.t("card_power", {"n": stone.power()}) if stone.power() != 0 else ""
	_does.text = SpellText.rune_role(stone.rune_id, int(levels.get(stone.rune_id, 1)))
	_does.visible = show_role and not _does.text.is_empty()
	if not stone.bound_rune.is_empty():
		var other: Dictionary = GameData.runes.get(stone.bound_rune, {})
		_name.text = "%s + %s" % [_name.text, Loc.text(other.get("name", {}))]
		_does.text += "\n" + Loc.t("card_bound", {"rune": Loc.text(other.get("name", {})),
			"does": SpellText.rune_role(stone.bound_rune, int(levels.get(stone.bound_rune, 1)))})
	if not stone.material.is_empty():
		var engraving: Dictionary = {}
		for id: String in GameData.engravings:
			if str(GameData.engravings[id].get("material", "")) == stone.material:
				engraving = GameData.engravings[id]
		if not _power.text.is_empty():
			_power.text += "  ·  "
		_power.text += Loc.t("material_" + stone.material, {"value": Loc.number(float(engraving.get("value", 0)))})
	_power.visible = not _power.text.is_empty()
	reset_size()


## A face-down stone (Lunet's Dream): nothing to read until it is cast.
func _show_hidden() -> void:
	_glyph.visible = false
	_name.text = Loc.t("card_face_down")
	for label: Label in [_kin, _role, _meaning, _power]:
		label.visible = false
	_does.visible = true
	_does.text = Loc.t("card_face_down_text")
	reset_size()


func _process(_delta: float) -> void:
	if not visible:
		return
	# The stone left the hand (cast or swapped): nothing to describe any more.
	if not is_instance_valid(_anchor) or _anchor.is_queued_for_deletion() or _anchor.modulate.a < 0.5:
		show_stone(null, null)
		return
	var parent_rect: Rect2 = (get_parent() as Control).get_global_rect()
	var anchor_rect: Rect2 = _anchor.get_global_rect()
	var at: Vector2 = Vector2(anchor_rect.get_center().x - size.x * 0.5, anchor_rect.position.y - size.y - GAP)
	at -= parent_rect.position
	at.x = clampf(at.x, MARGIN, parent_rect.size.x - size.x - MARGIN)
	at.y = clampf(at.y, MARGIN, parent_rect.size.y - size.y - MARGIN)
	position = at


func _label(parent: Control, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
