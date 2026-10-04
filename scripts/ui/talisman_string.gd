extends Control
## The Talismans hang on a string like cards held by clips and sway gently. Owned ones are
## drawn as cards (art/talismans/<id>.png when Relax has drawn it, otherwise a framed card
## with the owner's colour, initial and the name); empty clips are dashed outlines. The mouse
## card tells what a Talisman does; dragging one sideways changes the order (it matters:
## left to right). With show_rope off it draws loose, slightly rotated slots (consumables).

## A Talisman was dragged from one slot to another.
signal moved(from: int, to: int)
## A consumable was clicked (consumables mode).
signal used(slot: int)

const TalismanRules = preload("res://scripts/core/talisman_rules.gd")

const INK: Color = Color("#05060a")
const ROPE: Color = Color("#8a6a3e")
const SLOT: Color = Color("#a39db4")
const BONE: Color = Color("#e9e3d2")
const CARD_FILL: Color = Color("#1d1930")
const CARD_SIZE: Vector2 = Vector2(96, 134)
const RARITY_COLORS: Dictionary = {"common": Color("#c9c2ad"), "rare": Color("#63c6f2"), "legendary": Color("#ffb347")}
const ART_PATH: String = "res://art/talismans/%s.png"
const CONSUMABLE_ART: Dictionary = {"lesson": "res://art/lessons/%s.png", "engraving": "res://art/engravings/%s.png"}
const LESSON_COLOR: Color = Color("#63c6f2")
const ENGRAVING_COLOR: Color = Color("#ffb347")

@export var slots: int = 5
@export var show_rope: bool = true
var empty_label: String = ""
## Dragging is allowed (not during the score animation).
var enabled: bool = true
## Shows Lessons and Engravings ({"type", "id"}) instead of Talismans; a click uses one.
var consumable_mode: bool = false

var _time: float = 0.0
## Owned Talismans (TalismanRules entries), left to right.
var _owned: Array = []
var _disabled_slot: int = -1
var _flash: Dictionary = {}
var _art: Dictionary = {}
var _drag_from: int = -1
var _drag_x: float = 0.0


## Shows these owned Talismans; `disabled_slot` is drawn switched off (Nix's Trick).
func set_owned(owned: Array, disabled_slot: int = -1) -> void:
	_owned = owned
	_disabled_slot = disabled_slot
	mouse_filter = Control.MOUSE_FILTER_STOP if not owned.is_empty() else Control.MOUSE_FILTER_IGNORE
	for item: Dictionary in owned:
		var id: String = str(item["id"])
		if not _art.has(id):
			var path: String = _art_path(item)
			_art[id] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	queue_redraw()


## The card in this slot glows for a moment (it acted on the score).
func flash(slot: int) -> void:
	_flash[slot] = 1.0


## Centre of a slot's card, in global coordinates (where its floating numbers appear).
func slot_center(slot: int) -> Vector2:
	var place: Dictionary = _place(slot)
	return get_global_transform() * (place["at"] + Vector2(0, 10.0 + CARD_SIZE.y / 2.0))


func _process(delta: float) -> void:
	_time += delta
	for slot: Variant in _flash.keys():
		_flash[slot] = float(_flash[slot]) - delta * 1.5
		if float(_flash[slot]) <= 0.0:
			_flash.erase(slot)
	queue_redraw()


func _place(slot: int) -> Dictionary:
	var x: float = size.x * (float(slot) + 0.5) / float(slots)
	var y: float = 18.0 + 22.0 * sin(PI * x / size.x) if show_rope else 0.0
	var swing: float = 0.05 * sin(_time * 1.4 + float(slot)) if show_rope else (0.07 if slot % 2 == 0 else -0.05)
	return {"at": Vector2(x, y), "swing": swing}


func _draw() -> void:
	if show_rope:
		var rope: PackedVector2Array = []
		for i: int in 25:
			var rx: float = size.x * float(i) / 24.0
			rope.append(Vector2(rx, 18.0 + 22.0 * sin(PI * float(i) / 24.0)))
		draw_polyline(rope, ROPE, 4.0, true)
	var font: Font = get_theme_default_font()
	for s: int in slots:
		var place: Dictionary = _place(s)
		var at: Vector2 = place["at"]
		if s == _drag_from:
			at.x = _drag_x
		draw_set_transform(at, place["swing"], Vector2.ONE)
		if show_rope:
			draw_rect(Rect2(-6, -6, 12, 16), INK)
		var card: Rect2 = Rect2(Vector2(-CARD_SIZE.x / 2.0, 10), CARD_SIZE)
		if s < _owned.size():
			_draw_card(card, _owned[s], s, font)
		else:
			_draw_dashed_rect(card, Color(SLOT, 0.5))
			draw_string(font, card.position + Vector2(0, CARD_SIZE.y / 2.0 + 6), empty_label,
				HORIZONTAL_ALIGNMENT_CENTER, CARD_SIZE.x, 18, Color(SLOT, 0.6))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _art_path(item: Dictionary) -> String:
	if consumable_mode:
		return str(CONSUMABLE_ART.get(str(item.get("type", "")), ART_PATH)) % str(item["id"])
	return ART_PATH % str(item["id"])


## A Lesson (a little book in the Word's name) or an Engraving (a chisel mark).
func _draw_consumable(card: Rect2, item: Dictionary, font: Font) -> void:
	var lesson: bool = str(item["type"]) == "lesson"
	var entry: Dictionary = _consumable_entry(item)
	var color: Color = LESSON_COLOR if lesson else ENGRAVING_COLOR
	draw_rect(card.grow(3.0), INK)
	var art: Texture2D = _art.get(str(item["id"]))
	if art != null:
		draw_texture_rect(art, card, false)
	else:
		draw_rect(card, CARD_FILL)
		var middle: Vector2 = card.position + Vector2(CARD_SIZE.x / 2.0, 44)
		if lesson:
			draw_rect(Rect2(middle - Vector2(24, 18), Vector2(48, 36)), color.darkened(0.4))
			draw_line(middle - Vector2(0, 18), middle + Vector2(0, 18), INK, 3.0)
		else:
			draw_line(middle + Vector2(-20, 20), middle + Vector2(16, -16), color, 6.0, true)
			draw_line(middle + Vector2(16, -16), middle + Vector2(22, -22), BONE, 4.0, true)
		var lines: PackedStringArray = _wrap(Loc.text(entry.get("name", {})), font, 15, CARD_SIZE.x - 10.0)
		for i: int in mini(lines.size(), 4):
			draw_string(font, card.position + Vector2(5, 92 + i * 15), lines[i], HORIZONTAL_ALIGNMENT_CENTER,
				CARD_SIZE.x - 10.0, 15, BONE)
	draw_rect(card, color, false, 3.0)


func _consumable_entry(item: Dictionary) -> Dictionary:
	var table: Dictionary = GameData.lessons if str(item["type"]) == "lesson" else GameData.engravings
	return table.get(str(item["id"]), {})


func _draw_card(card: Rect2, owned: Dictionary, slot: int, font: Font) -> void:
	if consumable_mode:
		_draw_consumable(card, owned, font)
		return
	var entry: Dictionary = GameData.talismans.get(str(owned["id"]), {})
	var rarity: Color = RARITY_COLORS.get(str(entry.get("rarity", "common")), BONE)
	var glow: float = float(_flash.get(slot, 0.0))
	if glow > 0.0:
		for i: int in range(5, 0, -1):
			draw_rect(card.grow(float(i) * 4.0), Color(rarity, 0.09 * glow))
	var dim: float = 0.35 if slot == _disabled_slot else 1.0
	draw_rect(card.grow(3.0), INK)
	var art: Texture2D = _art.get(str(owned["id"]))
	if art != null:
		draw_texture_rect(art, card, false, Color(1, 1, 1, dim))
	else:
		draw_rect(card, Color(CARD_FILL, dim))
		var owner_data: Dictionary = GameData.characters.get(str(entry.get("owner", "")), {})
		var color: Color = Color.html(str(owner_data.get("color", "#808080")))
		var middle: Vector2 = card.position + Vector2(CARD_SIZE.x / 2.0, 46)
		draw_circle(middle, 26.0, Color(color.darkened(0.3), dim))
		draw_string(get_theme_font("font", "TitleLabel"), middle + Vector2(-26, 11), Loc.text(owner_data.get("name", {})).substr(0, 1),
			HORIZONTAL_ALIGNMENT_CENTER, 52.0, 30, Color(BONE, dim))
		var card_name: String = Loc.text(entry.get("name", {}))
		var lines: PackedStringArray = _wrap(card_name, font, 15, CARD_SIZE.x - 10.0)
		for i: int in mini(lines.size(), 4):
			draw_string(font, card.position + Vector2(5, 92 + i * 15), lines[i], HORIZONTAL_ALIGNMENT_CENTER,
				CARD_SIZE.x - 10.0, 15, Color(BONE, dim))
	draw_rect(card, Color(rarity, dim), false, 3.0)


## Splits a name into lines that fit the card.
func _wrap(text: String, font: Font, font_size: int, width: float) -> PackedStringArray:
	var lines: PackedStringArray = []
	var line: String = ""
	for word: String in text.split(" "):
		var candidate: String = word if line.is_empty() else line + " " + word
		if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width and not line.is_empty():
			lines.append(line)
			line = word
		else:
			line = candidate
	if not line.is_empty():
		lines.append(line)
	return lines


func _slot_at(at: Vector2) -> int:
	for s: int in _owned.size():
		var place: Dictionary = _place(s)
		var card: Rect2 = Rect2(place["at"] + Vector2(-CARD_SIZE.x / 2.0, 10), CARD_SIZE)
		if card.has_point(at):
			return s
	return -1


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var button: InputEventMouseButton = event
		if consumable_mode:
			var clicked: int = _slot_at(button.position)
			if button.pressed and enabled and clicked >= 0:
				used.emit(clicked)
			accept_event()
			return
		if button.pressed and enabled:
			_drag_from = _slot_at(button.position)
			_drag_x = button.position.x
		elif not button.pressed and _drag_from >= 0:
			var to: int = clampi(int(button.position.x / (size.x / float(slots))), 0, _owned.size() - 1)
			if to != _drag_from:
				moved.emit(_drag_from, to)
			_drag_from = -1
		accept_event()
	elif event is InputEventMouseMotion and _drag_from >= 0:
		_drag_x = (event as InputEventMouseMotion).position.x


## The mouse card shows the Talisman under the mouse (its id is the tooltip "text").
func _get_tooltip(at_position: Vector2) -> String:
	var slot: int = _slot_at(at_position)
	return str(slot) if slot >= 0 else ""


func _make_custom_tooltip(for_text: String) -> Object:
	var slot: int = int(for_text)
	if slot < 0 or slot >= _owned.size():
		return null
	var owned: Dictionary = _owned[slot]
	if consumable_mode:
		return _consumable_tooltip(owned)
	var entry: Dictionary = GameData.talismans.get(str(owned["id"]), {})
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"TooltipPanel"
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var title: Label = Label.new()
	title.theme_type_variation = &"TitleLabel"
	title.add_theme_font_size_override("font_size", 32)
	title.text = Loc.text(entry.get("name", {}))
	box.add_child(title)
	var rarity: Label = Label.new()
	rarity.add_theme_font_size_override("font_size", 22)
	rarity.add_theme_color_override("font_color", RARITY_COLORS.get(str(entry.get("rarity", "common")), BONE))
	rarity.text = Loc.t("rarity_" + str(entry.get("rarity", "common")))
	box.add_child(rarity)
	var text: Label = Label.new()
	text.custom_minimum_size = Vector2(420, 0)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 24)
	var values: Dictionary = {}
	var raw: Dictionary = TalismanRules.text_values(owned, GameData.talismans)
	for key: Variant in raw:
		values[key] = Loc.number(float(raw[key]))
	text.text = Loc.text(entry.get("description", {}), values)
	if slot == _disabled_slot:
		text.text += "\n" + Loc.t("talisman_disabled")
	box.add_child(text)
	var hint: Label = Label.new()
	hint.theme_type_variation = &"SecondaryLabel"
	hint.add_theme_font_size_override("font_size", 19)
	hint.text = Loc.t("talisman_drag_hint")
	box.add_child(hint)
	return panel


func _consumable_tooltip(item: Dictionary) -> Control:
	var lesson: bool = str(item["type"]) == "lesson"
	var entry: Dictionary = _consumable_entry(item)
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"TooltipPanel"
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var title: Label = Label.new()
	title.theme_type_variation = &"TitleLabel"
	title.add_theme_font_size_override("font_size", 32)
	title.text = Loc.text(entry.get("name", {}))
	box.add_child(title)
	var kind: Label = Label.new()
	kind.add_theme_font_size_override("font_size", 22)
	kind.add_theme_color_override("font_color", LESSON_COLOR if lesson else ENGRAVING_COLOR)
	kind.text = Loc.t("consumable_lesson") if lesson else Loc.t("consumable_engraving")
	box.add_child(kind)
	var text: Label = Label.new()
	text.custom_minimum_size = Vector2(420, 0)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 24)
	if lesson:
		var word: Dictionary = GameData.words.get(str(entry.get("word", "")), {})
		text.text = "%s\n%s" % [Loc.t("lesson_effect", {"word": Loc.text(word.get("name", {}))}), Loc.text(entry.get("text", {}))]
	else:
		var values: Dictionary = {}
		for key: String in ["value", "count"]:
			if entry.has(key):
				values[key] = Loc.number(float(entry[key]))
		text.text = Loc.text(entry.get("text", {}), values)
	box.add_child(text)
	var hint: Label = Label.new()
	hint.theme_type_variation = &"SecondaryLabel"
	hint.add_theme_font_size_override("font_size", 19)
	hint.text = Loc.t("consumable_use_hint")
	box.add_child(hint)
	return panel


func _draw_dashed_rect(rect: Rect2, color: Color) -> void:
	var corners: Array[Vector2] = [rect.position, rect.position + Vector2(rect.size.x, 0), rect.end,
		rect.position + Vector2(0, rect.size.y), rect.position]
	for i: int in 4:
		draw_dashed_line(corners[i], corners[i + 1], color, 2.0, 8.0)
