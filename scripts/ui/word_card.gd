extends PanelContainer
## The card shown while the mouse is over the middle of the Rune Circle: which Word the
## selection forms, what it means, how many stones score (they glow in hand meanwhile),
## Power × Resonance and the Spells in it.

const GAP: float = 18.0
const MARGIN: float = 16.0
const WIDTH: float = 460.0

var _name: Label
var _level: Label
var _description: Label
var _scoring: Label
var _values: Label
var _spells: Label
var _anchor: Control = null


func _ready() -> void:
	theme_type_variation = &"TooltipPanel"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	_name = _label(box, 38, &"TitleLabel")
	_level = _label(box, 20, &"SecondaryLabel")
	_description = _label(box, 24, &"")
	_scoring = _label(box, 23, &"SecondaryLabel")
	_values = _label(box, 28, &"")
	_spells = _label(box, 22, &"")
	for label: Label in [_description, _scoring, _spells]:
		label.custom_minimum_size = Vector2(WIDTH - 40.0, 0)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


## Shows the card next to `anchor` (the circle).
##   name, description: what to show for the Word ("???" while it is hidden)
##   preview: RoundState.preview()    level: the Word's level    count: stones selected
func show_word(word_name: String, description: String, preview: Dictionary, level: int, count: int,
		anchor: Control) -> void:
	_anchor = anchor
	_name.text = word_name
	_level.text = Loc.t("circle_level", {"n": level})
	_description.text = description
	_scoring.text = Loc.t("word_card_scoring", {"n": (preview["scoring"] as Array).size(), "total": count})
	_values.text = Loc.t("word_card_values", {"power": Loc.number(preview["power"]), "res": Loc.number(preview["res"])})
	_spells.text = _spell_text(preview["spells"])
	_spells.visible = not _spells.text.is_empty()
	visible = true
	reset_size()


func hide_card() -> void:
	visible = false
	_anchor = null


func _spell_text(spell_ids: Array) -> String:
	var lines: PackedStringArray = []
	var hidden: bool = false
	for id: String in spell_ids:
		var spell: Dictionary = GameData.spells[id]
		if SaveManager.has_discovery("spells", id):
			lines.append("%s: %s" % [Loc.text(spell["name"]), Loc.text(spell["effect"])])
		else:
			hidden = true
	if hidden:
		lines.append(Loc.t("circle_awakening"))
	return "\n".join(lines)


func _process(_delta: float) -> void:
	if not visible or not is_instance_valid(_anchor):
		return
	var parent_rect: Rect2 = (get_parent() as Control).get_global_rect()
	var anchor_rect: Rect2 = _anchor.get_global_rect()
	var at: Vector2 = Vector2(anchor_rect.end.x + GAP, anchor_rect.position.y + 10.0) - parent_rect.position
	if at.x + size.x > parent_rect.size.x - MARGIN:
		at.x = anchor_rect.position.x - parent_rect.position.x - size.x - GAP
	at.y = clampf(at.y, MARGIN, parent_rect.size.y - size.y - MARGIN)
	position = at


func _label(parent: Control, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
