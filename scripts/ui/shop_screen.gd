extends Control
## The Night Market screen (DESIGN 3.9): Tanti Vera behind her stall, two Talismans, two
## Lessons or Engravings, two Bags and sometimes a Torn Page for sale; on the right your Coins, your Talismans (to
## sell) and your Lessons / Engravings (a Lesson can be learned here), rearranging the stall
## and leaving. A bought Bag opens over the stall: take one (or two) of what is inside.
## The logic is scripts/core/shop_logic.gd.

signal closed

const ShopLogic = preload("res://scripts/core/shop_logic.gd")
const Portrait = preload("res://scripts/ui/portrait.gd")
const TalismanRules = preload("res://scripts/core/talisman_rules.gd")
const MiniStone = preload("res://scripts/ui/mini_stone.gd")
const Progress = preload("res://scripts/core/progress.gd")

const MONEY_COLOR: Color = Color("#ebaa3c")
const CARD_SIZE: Vector2 = Vector2(330, 330)
const KIND_COLORS: Dictionary = {
	"talisman": Color("#c9c2ad"), "lesson": Color("#63c6f2"), "engraving": Color("#ffb347"), "pack": Color("#b59be0"),
	"page": Color("#e9d3a0"),
}
## A stall of more than 6 things (a Torn Page) gets a fourth column of narrower cards.
const NARROW_CARD_WIDTH: float = 310.0

var shop: ShopLogic

var _vera_line: Label
var _money: Label
var _stall: GridContainer
var _owned_box: VBoxContainer
var _reroll_button: Button
var _leave_button: Button
var _pack_layer: Control
var _pack_box: VBoxContainer
var _pack: Dictionary = {}
var _pack_left: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.05, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 30)
	margin.add_child(columns)
	var left: VBoxContainer = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 18)
	columns.add_child(left)
	var head: HBoxContainer = HBoxContainer.new()
	head.add_theme_constant_override("separation", 20)
	left.add_child(head)
	var portrait: Portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(130, 130)
	portrait.character_id = "vera"
	head.add_child(portrait)
	var titles: VBoxContainer = VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(titles)
	_label(titles, Loc.t("shop_title"), 60, &"TitleLabel")
	_vera_line = _label(titles, "", 26, &"")
	_vera_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stall = GridContainer.new()
	_stall.columns = 3
	_stall.add_theme_constant_override("h_separation", 16)
	_stall.add_theme_constant_override("v_separation", 16)
	left.add_child(_stall)
	var right: PanelContainer = PanelContainer.new()
	right.custom_minimum_size = Vector2(460, 0)
	columns.add_child(right)
	var side_box: VBoxContainer = VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 12)
	right.add_child(side_box)
	_money = _label(side_box, "", 40, &"TitleLabel")
	_money.add_theme_color_override("font_color", MONEY_COLOR)
	_reroll_button = _button(side_box, "", _on_reroll)
	_owned_box = VBoxContainer.new()
	_owned_box.add_theme_constant_override("separation", 6)
	_owned_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_box.add_child(_owned_box)
	_leave_button = _button(side_box, Loc.t("shop_leave"), func() -> void: closed.emit())
	_leave_button.theme_type_variation = &"CastButton"
	_leave_button.custom_minimum_size = Vector2(0, 90)
	_build_pack_layer()


## Opens the stall for this shop (ShopLogic already set up).
func open(shop_logic: ShopLogic) -> void:
	shop = shop_logic
	var lines: Array = (GameData.dialogs.get("vera_market", {}) as Dictionary).get("lines", [])
	if not lines.is_empty():
		_vera_line.text = "„%s”" % Loc.text(lines[shop.exam.rng.randi_range(0, lines.size() - 1)]["text"])
	_refresh()
	EventBus.shop_opened.emit()
	_leave_button.grab_focus()


func _refresh() -> void:
	_money.text = Loc.t("shop_money", {"n": shop.exam.money})
	_reroll_button.text = Loc.t("shop_reroll", {"n": shop.reroll_price()})
	_reroll_button.disabled = shop.exam.money < shop.reroll_price()
	for child: Node in _stall.get_children():
		_stall.remove_child(child)
		child.queue_free()
	_stall.columns = 3 if shop.offer.size() <= 6 else 4
	for i: int in shop.offer.size():
		var card: Control = _offer_card(i)
		if _stall.columns == 4:
			card.custom_minimum_size.x = NARROW_CARD_WIDTH
		_stall.add_child(card)
		_record_seen(shop.offer[i])
	_refresh_owned()


func _offer_card(index: int) -> Control:
	var item: Dictionary = shop.offer[index]
	var card: PanelContainer = PanelContainer.new()
	card.theme_type_variation = &"TooltipPanel"
	card.custom_minimum_size = CARD_SIZE
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)
	var info: Dictionary = _describe(str(item["type"]), str(item["id"]))
	var kind: Label = _label(box, info["kind"], 20, &"")
	kind.add_theme_color_override("font_color", KIND_COLORS.get(str(item["type"]), Color.WHITE))
	var title: Label = _label(box, info["name"], 28, &"TitleLabel")
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var text: Label = _label(box, info["text"], 20, &"")
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if bool(item["sold"]):
		card.modulate.a = 0.4
		_label(box, Loc.t("shop_sold"), 24, &"SecondaryLabel")
		return card
	var buy: Button = _button(box, Loc.t("shop_buy", {"n": item["price"]}), _on_buy.bind(index))
	buy.disabled = not shop.can_buy(index)
	if buy.disabled and shop.exam.money >= int(item["price"]):
		buy.tooltip_text = Loc.t("shop_no_slot")
	return card


func _refresh_owned() -> void:
	for child: Node in _owned_box.get_children():
		_owned_box.remove_child(child)
		child.queue_free()
	_label(_owned_box, Loc.t("shop_your_talismans", {"n": shop.exam.talismans.size(), "max": shop.exam.talisman_slots()}),
		24, &"SecondaryLabel")
	for slot: int in shop.exam.talismans.size():
		var owned: Dictionary = shop.exam.talismans[slot]
		var info: Dictionary = _describe("talisman", str(owned["id"]), owned)
		var row: HBoxContainer = HBoxContainer.new()
		_owned_box.add_child(row)
		var name_label: Label = _label(row, info["name"], 20, &"")
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.tooltip_text = info["text"]
		name_label.mouse_filter = Control.MOUSE_FILTER_PASS
		var sell: Button = _button(row, Loc.t("shop_sell", {"n": shop.exam.sell_price(str(owned["id"]))}), _on_sell.bind(slot))
		sell.custom_minimum_size = Vector2(150, 44)
	_label(_owned_box, Loc.t("shop_your_consumables", {"n": shop.exam.consumables.size(), "max": shop.exam.consumable_slots()}),
		24, &"SecondaryLabel")
	for slot: int in shop.exam.consumables.size():
		var item: Dictionary = shop.exam.consumables[slot]
		var info: Dictionary = _describe(str(item["type"]), str(item["id"]))
		var row: HBoxContainer = HBoxContainer.new()
		_owned_box.add_child(row)
		var name_label: Label = _label(row, info["name"], 20, &"")
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.tooltip_text = info["text"]
		name_label.mouse_filter = Control.MOUSE_FILTER_PASS
		if str(item["type"]) == "lesson":
			var learn: Button = _button(row, Loc.t("shop_learn"), _on_learn.bind(slot))
			learn.custom_minimum_size = Vector2(150, 44)


## {"kind", "name", "text"} for anything on the stall.
func _describe(type: String, id: String, owned: Dictionary = {}) -> Dictionary:
	match type:
		"talisman":
			var entry: Dictionary = GameData.talismans.get(id, {})
			var raw: Dictionary = TalismanRules.text_values(owned if not owned.is_empty() else TalismanRules.make(id, GameData.talismans),
				GameData.talismans)
			var values: Dictionary = {}
			for key: Variant in raw:
				values[key] = Loc.number(float(raw[key]))
			return {"kind": "%s · %s" % [Loc.t("shop_kind_talisman"), Loc.t("rarity_" + str(entry.get("rarity", "common")))],
				"name": Loc.text(entry.get("name", {})), "text": Loc.text(entry.get("description", {}), values)}
		"lesson":
			var lesson: Dictionary = GameData.lessons.get(id, {})
			var word: Dictionary = GameData.words.get(str(lesson.get("word", "")), {})
			return {"kind": Loc.t("consumable_lesson"), "name": Loc.text(lesson.get("name", {})),
				"text": "%s\n%s" % [Loc.t("lesson_effect", {"word": Loc.text(word.get("name", {}))}), Loc.text(lesson.get("text", {}))]}
		"engraving":
			var engraving: Dictionary = GameData.engravings.get(id, {})
			var numbers: Dictionary = {}
			for key: String in ["value", "count"]:
				if engraving.has(key):
					numbers[key] = Loc.number(float(engraving[key]))
			return {"kind": Loc.t("consumable_engraving"), "name": Loc.text(engraving.get("name", {})),
				"text": Loc.text(engraving.get("text", {}), numbers)}
		"pack":
			var big: bool = id.ends_with("_big")
			var kind: String = id.trim_suffix("_big")
			return {"kind": Loc.t("shop_kind_pack_big") if big else Loc.t("shop_kind_pack"),
				"name": Loc.t("pack_" + kind), "text": Loc.t("pack_text_big" if big else "pack_text")}
		"page":
			return {"kind": Loc.t("shop_kind_page"), "name": Loc.t("page_name"), "text": Loc.t("page_text")}
	return {"kind": "", "name": id, "text": ""}


# --- Actions ------------------------------------------------------------------------------

func _on_buy(index: int) -> void:
	var item: Dictionary = shop.offer[index]
	var result: Dictionary = shop.buy(index)
	if not bool(result.get("ok", false)):
		return
	match str(item["type"]):
		"talisman":
			EventBus.talisman_bought.emit(str(item["id"]))
		"lesson", "engraving":
			EventBus.consumable_gained.emit(str(item["type"]), str(item["id"]))
	_refresh()
	if result.has("pack"):
		_open_pack(result["pack"])
	elif result.has("page"):
		_show_page(str(result["page"]))


func _on_sell(slot: int) -> void:
	shop.sell_talisman(slot)
	_refresh()


func _on_learn(slot: int) -> void:
	shop.exam.use_lesson(slot)
	_refresh()


func _on_reroll() -> void:
	if shop.reroll():
		_refresh()


# --- An opened Bag -------------------------------------------------------------------------

func _build_pack_layer() -> void:
	_pack_layer = Control.new()
	_pack_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pack_layer.visible = false
	add_child(_pack_layer)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.05, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pack_layer.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pack_layer.add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	center.add_child(panel)
	_pack_box = VBoxContainer.new()
	_pack_box.add_theme_constant_override("separation", 16)
	panel.add_child(_pack_box)


func _open_pack(pack: Dictionary) -> void:
	_pack = pack
	_pack_left = int(pack["pick"])
	_pack_layer.visible = true
	_show_pack()


func _show_pack() -> void:
	for child: Node in _pack_box.get_children():
		_pack_box.remove_child(child)
		child.queue_free()
	var title: Label = _label(_pack_box, Loc.t("pack_" + str(_pack["kind"])), 52, &"TitleLabel")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hint: Label = _label(_pack_box, Loc.t("pack_pick", {"n": _pack_left}), 26, &"")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	_pack_box.add_child(row)
	var items: Array = _pack["items"]
	for i: int in items.size():
		row.add_child(_pack_card(items[i], i))
		_record_seen(items[i])
	var skip: Button = _button(_pack_box, Loc.t("pack_skip"), _close_pack)
	skip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skip.custom_minimum_size = Vector2(300, 64)


func _pack_card(item: Dictionary, index: int) -> Control:
	var card: PanelContainer = PanelContainer.new()
	card.theme_type_variation = &"TooltipPanel"
	card.custom_minimum_size = Vector2(240, 300)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)
	if bool(item.get("taken", false)):
		card.modulate.a = 0.35
	if str(item["type"]) == "stone":
		var stone: RefCounted = item["stone"]
		var mini: MiniStone = MiniStone.new()
		mini.rune_id = str(stone.get("rune_id"))
		mini.show_role = true
		mini.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(mini)
		var rune: Dictionary = GameData.runes.get(str(stone.get("rune_id")), {})
		_label(box, Loc.text(rune.get("name", {})), 28, &"TitleLabel")
		var text: String = Loc.text(rune.get("voice", {}))
		var material: String = str(stone.get("material"))
		if not material.is_empty():
			var value: float = 0.0
			for id: String in GameData.engravings:
				if str(GameData.engravings[id].get("material", "")) == material:
					value = float(GameData.engravings[id].get("value", 0))
			text = "%s\n%s" % [Loc.t("material_" + material, {"value": Loc.number(value)}), text]
		var voice: Label = _label(box, text, 19, &"")
		voice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		voice.size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		var info: Dictionary = _describe(str(item["type"]), str(item["id"]))
		_label(box, info["kind"], 18, &"SecondaryLabel")
		var title: Label = _label(box, info["name"], 24, &"TitleLabel")
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var text_label: Label = _label(box, info["text"], 18, &"")
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if not bool(item.get("taken", false)):
		_button(box, Loc.t("pack_take"), _on_take.bind(index))
	return card


func _on_take(index: int) -> void:
	var item: Dictionary = (_pack["items"] as Array)[index]
	if not shop.take_from_pack(item):
		return
	item["taken"] = true
	match str(item["type"]):
		"talisman":
			EventBus.talisman_bought.emit(str(item["id"]))
		"lesson", "engraving":
			EventBus.consumable_gained.emit(str(item["type"]), str(item["id"]))
	_pack_left -= 1
	_refresh()
	if _pack_left <= 0:
		_close_pack()
	else:
		_show_pack()


## A Torn Page: which runes the spell needs (Element → Target) and a verse as a hint. It stays
## in the Book of Runes, on the Spell Table.
func _show_page(spell_id: String) -> void:
	SaveManager.add_discovery("torn_pages", spell_id)
	EventBus.torn_page_found.emit(spell_id)
	var spell: Dictionary = GameData.spells.get(spell_id, {})
	_pack = {}
	_pack_layer.visible = true
	for child: Node in _pack_box.get_children():
		_pack_box.remove_child(child)
		child.queue_free()
	var title: Label = _label(_pack_box, Loc.t("page_name"), 52, &"TitleLabel")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	_pack_box.add_child(row)
	for n: int in 2:
		var rune_id: String = str(spell.get("element" if n == 0 else "target", ""))
		var rune: Dictionary = GameData.runes.get(rune_id, {})
		var column: VBoxContainer = VBoxContainer.new()
		column.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_child(column)
		var mini: MiniStone = MiniStone.new()
		mini.rune_id = rune_id
		mini.show_role = true
		mini.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		column.add_child(mini)
		_label(column, Loc.text(rune.get("name", {})), 30, &"TitleLabel").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label(column, Loc.text(rune.get("phrase", {})), 22, &"SecondaryLabel").horizontal_alignment = \
			HORIZONTAL_ALIGNMENT_CENTER
		if n == 0:
			_label(row, "→", 48, &"TitleLabel")
	var verse: Label = _label(_pack_box, "„%s”" % Loc.text(spell.get("verse", {})), 30, &"")
	verse.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verse.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	verse.custom_minimum_size = Vector2(760, 0)
	var where: Label = _label(_pack_box, Loc.t("page_where"), 22, &"SecondaryLabel")
	where.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var done: Button = _button(_pack_box, Loc.t("pack_skip"), _close_pack)
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	done.custom_minimum_size = Vector2(300, 64)
	done.grab_focus()


func _close_pack() -> void:
	_pack_layer.visible = false
	_pack = {}
	_refresh()


## The Collection keeps every Talisman and Engraving the player has seen on the stall.
func _record_seen(item: Dictionary) -> void:
	var category: String = {"talisman": "talismans", "engraving": "engravings"}.get(str(item["type"]), "")
	if not category.is_empty() and Progress.record_seen(SaveManager.data, category, str(item["id"])):
		SaveManager.save_game()


func _label(parent: Control, text: String, font_size: int, variation: StringName) -> Label:
	var label: Label = Label.new()
	label.text = text
	if variation != &"":
		label.theme_type_variation = variation
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _button(parent: Control, text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
