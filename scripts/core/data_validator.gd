extends RefCounted
## Checks the content of data/*.json against simple schemas.
## Every problem becomes one readable line: "data/<file> [<id>]: <problem>".
## Pure logic, no autoloads: it can run in tests without a scene.

const LANGUAGES: Array = ["ro", "en"]

## Positions inside a kin go from 1 to this number.
const KIN_SIZE: int = 8

## Allowed values for "enum:<name>" fields.
const ENUMS: Dictionary = {
	"kin_sign": ["coin", "hail", "star"],
	"character_kind": ["god", "human", "demigod"],
	## The rune grammar (DESIGN 3.15): Element -> (Action, up to 2) -> Target.
	"rune_role": ["element", "action", "target"],
	"spell_timing": ["before", "after", "later"],
	## What a base spell does (scripts/core/spell_resolver.gd). Talisman and Examiner ops are
	## written down already; their spells stay "enabled": false until Stage 3.
	"spell_op": [
		"money_per_spell_stone", "add_money", "lose_cast", "money_interest", "break_chosen_money",
		"money_per_kin_in_hand", "money_per_hand_stone", "money_per_cast_left_at_end",
		"grow_random_bag", "grow_spell_stones", "break_random_hand", "copy_chosen_to_bag", "return_cast_to_bag",
		"remove_chosen", "reorder_bag_top", "change_kin_chosen", "copy_spell_to_bag",
		"hand_size_bonus", "power_to_held", "discard_chosen", "add_cast", "heart_shield", "redraw_hand", "draw_keep",
		"free_swap_chosen", "add_swap", "element_level_up",
		"next_cast_mul_res", "next_cast_add_power", "next_next_cast_mul_res", "carry_overflow",
		"next_fight_monster_down", "next_round_lose_swap", "next_round_peek", "next_round_draw_extra",
		"next_round_add_cast",
		"talisman_retrigger_left", "power_per_talisman", "destroy_talisman_res", "talismans_no_wear",
		"sell_talisman_full", "shop_rare_talisman", "transform_talisman", "shop_extra_talisman",
		"ignore_rule_cast", "cancel_rule_round", "monster_heal_pct", "monster_hp_pct", "cancel_rule_casts",
		"swap_rule", "peek_examiners",
	],
	## Numbers an Action may scale ("cost" never scales).
	"spell_scalable": ["percent", "amount", "count", "factor", "max"],
	"spell_action_kind": ["overflow", "twice", "lasts", "grows", "ripens", "gambles", "price", "gift"],
	## What an Element does besides its damage (data/elements.json, scripts/core/damage.gd).
	"element_nature": ["burn", "crush", "thorn", "freeze", "rain", "light", "wave", "time"],
	"monster_kind": ["small", "big", "boss", "exam"],
	"monster_tag": ["night", "undead"],
	## What a monster does in a fight (scripts/core/monster.gd; most come alive in Stage 5 step D).
	"monster_trait": [
		"steal_coin", "take_stone", "fury_swap", "shuffle_hand", "regen_pct", "regen_flat", "heal_if_one_spell",
		"heal_on_five", "face_down", "stone_to_hagalaz", "fury_shield", "burn_immune",
	],
	## What a Talisman does (scripts/core/talisman_rules.gd).
	"talisman_kind": [
		"add_res", "add_power", "rain_hits", "round_swaps", "hand_size", "wearing_res", "chain_money", "shop_discount",
		"mul_res_five", "burn_stacks", "new_spell_res", "power_per_bag_stone", "copy_right", "growing_mul",
		"second_chance",
	],
	"rarity": ["common", "rare", "legendary"],
	## How a divine parent becomes available (data/parents.json, DESIGN 3.10).
	"parent_unlock": ["start", "attempts", "memories"],
	## What an Engraving does to the stones in hand (scripts/core/round_state.gd, use_consumable).
	"engraving_kind": ["material", "bind", "change_rune", "copy_stone", "remove_stones", "change_kin"],
	"material": ["bone", "amber", "gold", "iron", "glass"],
	## The rules of the Lords of the Realms (scripts/core/fight_state.gd, DESIGN 3.8).
	"boss_rule": [
		"exact_count", "flux", "lightning", "tax", "dream", "min_stones", "remember_spell", "simple_no_damage",
		"heal", "trick", "no_element", "stone_to_hagalaz", "need_action", "max_hit_pct",
	],
	"tutorial_event": [
		"hover", "selection", "cast", "swap", "round_won", "spell_cast", "spell_discovered", "book_opened",
		"book_closed",
	],
	"tutorial_action": ["select", "cast", "swap", "sort", "speed", "menu", "word_book"],
	"tutorial_labels": ["meaning"],
	"book": ["words", "runes"],
	## UI elements the tutorial can light up (metadata "tutorial_id" on the round screen),
	## plus "stone:<rune_id>" for a stone in hand.
	"ui_id": [
		"hand", "circle", "btn_cast", "btn_swap", "target", "score", "candles", "chalk", "power_res",
		"examiner", "btn_word_book", "btn_menu", "sort", "kenaz", "btn_rune_book", "sentence", "scroll", "choice",
	],
	## What can show a contextual hint (data/hints.json). Events of later stages are listed
	## already so their hints can wait with "enabled": false.
	"hint_event": [
		"rune_in_hand", "idle", "shop_opened", "reroll_available", "talisman_bought", "examiner_met",
		"lesson_gained", "engraving_gained", "bindrune_gained", "exam_failed", "evening_class",
		"torn_page_found", "curse_discovered", "old_word_discovered", "wrong_order", "scroll_gained",
		"two_actions",
	],
}

## Field kinds:
##   id, string, int, number, bool, loc, color, dict, array, segments,
##   rune_list (rune ids), scalable_list (names from ENUMS["spell_scalable"]), loc_map ({"key": loc}), spotlight_list (ui ids or "stone:<rune>"),
##   action_list (tutorial actions), enum:<name>, ref:<collection>, object:<schema>, array:<schema>
const SCHEMAS: Dictionary = {
	"kin": {
		"required": {"id": "id", "name": "loc", "color": "color", "sign": "enum:kin_sign"},
		"optional": {},
	},
	"rune": {
		"required": {
			"id": "id", "name": "loc", "glyph": "string", "kin": "ref:kins", "role": "enum:rune_role", "phrase": "loc",
			"meaning": "loc", "segments": "segments",
		},
		"optional": {},
	},
	## An Element's Power, Resonance and nature (data/elements.json); the id is its rune.
	"element": {
		"required": {
			"id": "ref:runes", "power": "number", "res": "number", "level_power": "number", "level_res": "number",
			"color": "color", "nature": "enum:element_nature", "nature_value": "number", "nature_double": "number",
			"nature_text": "loc",
		},
		"optional": {"max_stacks": "int"},
	},
	## How much of the damage a Target lets through (data/targets.json); the id is its rune.
	"target": {
		"required": {"id": "ref:runes", "share": "number", "text": "loc"},
		"optional": {"double_nature": "bool", "level_up": "int", "future_share": "number"},
	},
	## A base spell: Element -> Target (data/spells_base.json).
	"spell": {
		"required": {
			"id": "id", "element": "ref:runes", "target": "ref:runes", "name": "loc", "effect": "loc", "verse": "loc",
			"timing": "enum:spell_timing", "enabled": "bool", "color": "color", "ops": "array:spell_op",
			"scalable": "scalable_list",
		},
		"optional": {},
	},
	"spell_op": {
		"required": {"op": "enum:spell_op"},
		"optional": {
			"percent": "number", "amount": "number", "count": "number", "factor": "number", "max": "number",
			"per": "number", "cost": "number", "kin": "ref:kins",
		},
	},
	## An Action rune placed between Element and Target (data/spell_actions.json).
	"spell_action": {
		"required": {"id": "ref:runes", "kind": "enum:spell_action_kind", "effect": "loc"},
		"optional": {
			"factor": "number", "single_factor": "number", "count": "number", "percent": "number",
			"chance": "number", "cost_swaps": "int", "cost_money": "int",
		},
	},
	"economy": {
		"required": {
			"max_spells_per_cast": "int", "chain_bonus_pct": "number", "kin_bonus_res": "number", "kin_min_stones": "int",
			"boss_pct_cap": "number", "ansuz_level_cap": "int", "monster_hp_mults": "number_list",
			"spell_max_extra_casts_per_round": "int", "scroll_slots": "int",
			"algiz_fallback_money": "int", "start_money": "int",
			"reward_small": "int", "reward_big": "int", "reward_examiner": "int", "reward_per_cast_left": "int",
			"interest_per": "int", "interest_max": "int", "talisman_slots": "int", "price_common": "int",
			"price_rare": "int", "price_legendary": "int", "sell_share_pct": "int", "consumable_slots": "int",
			"price_lesson": "int", "price_engraving": "int", "shop_talismans": "int", "shop_consumables": "int",
			"shop_packs": "int", "rarity_weights_pct": "number_list", "price_pack": "int", "price_pack_big": "int",
			"reroll_base": "int", "reroll_step": "int", "pack_stone_material_pct": "int", "spell_max_extra_draw": "int",
			"price_page": "int", "page_chance_pct": "int",
		},
		"optional": {},
	},
	## A Talisman (data/talismans.json): its kind says what it does, the numbers how much.
	"talisman": {
		"required": {
			"id": "id", "rarity": "enum:rarity", "kind": "enum:talisman_kind", "name": "loc", "description": "loc",
		},
		"optional": {
			"owner": "ref:characters", "value": "number", "step": "number",
			"unlock": "int",
		},
	},
	## A Lesson raises one Word by a level (data/lessons.json).
	"lesson": {
		"required": {"id": "id", "element": "ref:runes", "name": "loc", "text": "loc"},
		"optional": {},
	},
	## An Engraving changes stones in hand (data/engravings.json).
	"engraving": {
		"required": {"id": "id", "kind": "enum:engraving_kind", "name": "loc", "text": "loc"},
		"optional": {"material": "enum:material", "value": "number", "chance": "number", "count": "int"},
	},
	## A divine parent: the starting bonus of an exam (data/parents.json); the id is a character id.
	## "cost" is the number of finished exams ("attempts") or of Memories ("memories").
	"parent": {
		"required": {"id": "ref:characters", "unlock": "enum:parent_unlock", "cost": "int", "bonus": "loc", "line": "loc"},
		"optional": {
			"casts": "int", "swaps": "int", "hand": "int", "talisman_slots": "int", "start_engravings": "int",
			"copies_per_rune": "int",
		},
	},
	## One of the 8 Realms of the Journey (data/realms.json).
	"realm": {
		"required": {"id": "id", "number": "int", "name": "loc", "base_hp": "int", "boss": "ref:monsters"},
		"optional": {"pool_from": "number_list"},
	},
	## A monster, a Lord of a Realm (boss) or an exam opponent (data/monsters.json).
	"monster": {
		"required": {"id": "id", "kind": "enum:monster_kind", "name": "loc", "description": "loc"},
		"optional": {
			"hp": "int", "hp_mult": "number", "realms": "number_list", "weak": "rune_list", "resist": "rune_list",
			"immune": "rune_list", "tags": "tag_list", "shield": "int", "trait": "enum:monster_trait",
			"trait_value": "number", "rule": "enum:boss_rule", "rule_value": "number", "rule_element": "ref:runes",
			"rule_text": "loc", "final": "bool", "heads": "array:monster_head",
		},
	},
	"monster_head": {
		"required": {},
		"optional": {"weak": "rune_list", "resist": "rune_list", "immune": "rune_list"},
	},
	"character": {
		"required": {"id": "id", "name": "loc", "kind": "enum:character_kind", "description": "loc", "color": "color"},
		"optional": {"domain": "loc", "job": "loc", "parent": "ref:characters"},
	},
	"dialog": {
		"required": {"id": "id", "lines": "array:dialog_line"},
		"optional": {},
	},
	"dialog_line": {
		"required": {"speaker": "ref:characters", "text": "loc"},
		"optional": {},
	},
	"tutorial": {
		"required": {"speaker": "ref:characters", "intro": "object:tutorial_intro", "lessons": "array:tutorial_lesson"},
		"optional": {},
	},
	"tutorial_intro": {
		"required": {
			"lines": "array:tutorial_line", "learn": "loc", "skip": "loc", "confirm": "loc",
			"confirm_yes": "loc", "confirm_no": "loc",
		},
		"optional": {},
	},
	"tutorial_line": {
		"required": {"text": "loc"},
		"optional": {"speaker": "ref:characters"},
	},
	"tutorial_lesson": {
		"required": {
			"id": "id", "title": "loc", "target": "int", "casts": "int", "swaps": "int", "seed": "int",
			"fail_text": "loc", "steps": "array:tutorial_step",
		},
		"optional": {
			"hand": "rune_list", "bag_top": "rune_list", "bag_only": "bool", "win_text": "loc",
			"idle_hint": "object:tutorial_idle", "spells": "bool", "end_after_steps": "bool",
		},
	},
	"tutorial_step": {
		"required": {"text": "loc"},
		"optional": {
			"speaker": "ref:characters", "spotlight": "spotlight_list", "wait_for": "object:tutorial_wait",
			"allow": "action_list", "selectable": "rune_list", "wrong_text": "loc", "slow_scoring": "bool",
			"phase_captions": "loc_map", "labels": "enum:tutorial_labels", "clear_selection": "bool",
		},
	},
	"tutorial_wait": {
		"required": {"event": "enum:tutorial_event"},
		"optional": {
			"rune": "ref:runes", "include": "rune_list", "exact": "rune_list",
			"prefer": "rune_list", "alt_text": "loc", "spell": "ref:spells", "min_count": "int",
			"book": "enum:book", "in_order": "bool",
		},
	},
	"tutorial_idle": {
		"required": {"seconds": "number", "text": "loc"},
		"optional": {},
	},
	"hint": {
		"required": {"id": "id", "enabled": "bool", "speaker": "ref:characters", "text": "loc"},
		"optional": {"trigger": "object:hint_trigger", "follows": "ref:hints"},
	},
	"hint_trigger": {
		"required": {"event": "enum:hint_event"},
		"optional": {"rune": "ref:runes", "seconds": "number", "max_exams": "int", "examiner": "ref:characters"},
	},
	"rules": {
		"required": {
			"hand_size": "int", "casts_per_round": "int", "swaps_per_round": "int",
			"max_stones_per_action": "int", "copies_per_rune": "int", "test_fight_monster": "ref:monsters",
			"memories_per_spell": "int", "scoring_speed": "int", "memories_per_round": "int",
			"memories_per_examiner": "int", "memories_exam_passed": "int",
		},
		"optional": {},
	},
}

var errors: Array[String] = []

var _refs: Array[Dictionary] = []
var _id_regex: RegEx


func _init() -> void:
	_id_regex = RegEx.new()
	_id_regex.compile("^[a-z0-9_]+$")


func add_error(file_name: String, entry_id: String, problem: String) -> void:
	var where: String = "data/" + file_name
	if not entry_id.is_empty():
		where += " [" + entry_id + "]"
	errors.append("%s: %s" % [where, problem])


## Validates a file that holds a list of objects with "id".
## Returns id -> entry for every entry that has a usable id.
func validate_collection(file_name: String, raw: Variant, schema_name: String) -> Dictionary:
	var result: Dictionary = {}
	if not (raw is Array):
		add_error(file_name, "", "the file must contain a list [ ... ] of objects")
		return result
	var entries: Array = raw
	for i: int in entries.size():
		var entry: Variant = entries[i]
		var label: String = "#%d" % (i + 1)
		if not (entry is Dictionary):
			add_error(file_name, label, "entry is not an object { ... }")
			continue
		var dict: Dictionary = entry
		var id_value: Variant = dict.get("id")
		var has_text_id: bool = id_value is String and not (id_value as String).is_empty()
		if has_text_id:
			label = id_value
		validate_object(file_name, label, "", dict, schema_name)
		if has_text_id and _id_regex.search(id_value) != null:
			if result.has(id_value):
				add_error(file_name, label, "duplicate id")
			else:
				result[id_value] = dict
	return result


## Validates a file that holds a single object (e.g. rules.json).
func validate_single(file_name: String, raw: Variant, schema_name: String) -> Dictionary:
	if not (raw is Dictionary):
		add_error(file_name, "", "the file must contain one object { ... }")
		return {}
	validate_object(file_name, "", "", raw, schema_name)
	return raw


## Validates ui_text.json: {"key": {"ro": "...", "en": "..."}}.
func validate_text_table(file_name: String, raw: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not (raw is Dictionary):
		add_error(file_name, "", "the file must be an object {\"key\": {\"ro\": \"...\", \"en\": \"...\"}}")
		return result
	var table: Dictionary = raw
	for key: Variant in table:
		var key_text: String = str(key)
		_check_loc(file_name, key_text, "text", table[key])
		result[key_text] = table[key]
	return result


func validate_object(file_name: String, label: String, path: String, dict: Dictionary, schema_name: String) -> void:
	var schema: Dictionary = SCHEMAS[schema_name]
	_check_fields(file_name, label, path, dict, schema["required"], schema["optional"])
	_extra_checks(file_name, label, dict, schema_name)


## Call after every collection is loaded: checks that ids pointing to other files exist.
func check_references(loaded: Dictionary) -> void:
	for ref: Dictionary in _refs:
		var collection: String = ref["collection"]
		var table: Dictionary = loaded.get(collection, {})
		if not table.has(ref["id"]):
			add_error(ref["file"], ref["label"], "\"%s\" points to \"%s\", which does not exist in %s.json" % [
				ref["path"], ref["id"], collection])


## Call after runes.json is loaded: every kin holds runes of all three roles.
func check_runes(file_name: String, runes: Dictionary, kins: Dictionary) -> void:
	for kin_id: String in kins:
		var count: int = 0
		for id: String in runes:
			if str((runes[id] as Dictionary).get("kin", "")) == kin_id:
				count += 1
		if count == 0:
			add_error(file_name, "", "kin \"%s\" has no rune" % kin_id)


## Call after elements.json, targets.json and runes.json are loaded: one entry per Element
## rune and per Target rune.
func check_roles(elements_file: String, elements: Dictionary, targets_file: String, targets: Dictionary,
		runes: Dictionary) -> void:
	for id: String in runes:
		var role: String = str((runes[id] as Dictionary).get("role", ""))
		if role == "element" and not elements.has(id):
			add_error(elements_file, "", "the Element rune \"%s\" has no entry" % id)
		if role == "target" and not targets.has(id):
			add_error(targets_file, "", "the Target rune \"%s\" has no entry" % id)
	for id: String in elements:
		if runes.has(id) and str((runes[id] as Dictionary).get("role", "")) != "element":
			add_error(elements_file, id, "%s is not an Element rune" % id)
	for id: String in targets:
		if runes.has(id) and str((runes[id] as Dictionary).get("role", "")) != "target":
			add_error(targets_file, id, "%s is not a Target rune" % id)


func check_value(file_name: String, label: String, path: String, value: Variant, kind: String) -> void:
	if kind.begins_with("enum:"):
		var allowed: Array = ENUMS[kind.substr(5)]
		if not (value is String) or not allowed.has(value):
			add_error(file_name, label, "\"%s\" must be one of: %s (got %s)" % [
				path, ", ".join(PackedStringArray(allowed)), JSON.stringify(value)])
		return
	if kind.begins_with("ref:"):
		if not (value is String):
			add_error(file_name, label, "\"%s\" must be an id (text)" % path)
			return
		_add_ref(file_name, label, path, kind.substr(4), value)
		return
	if kind.begins_with("object:"):
		if not (value is Dictionary):
			add_error(file_name, label, "\"%s\" must be an object { ... }" % path)
			return
		validate_object(file_name, label, path + ".", value, kind.substr(7))
		return
	if kind.begins_with("array:"):
		if not (value is Array):
			add_error(file_name, label, "\"%s\" must be a list [ ... ]" % path)
			return
		var items: Array = value
		for i: int in items.size():
			var item_path: String = "%s[%d]" % [path, i]
			if not (items[i] is Dictionary):
				add_error(file_name, label, "\"%s\" must be an object { ... }" % item_path)
				continue
			validate_object(file_name, label, item_path + ".", items[i], kind.substr(6))
		return

	match kind:
		"id":
			if not (value is String) or _id_regex.search(value) == null:
				add_error(file_name, label, "\"%s\" must use only a-z, 0-9 and _ (got %s)" % [path, JSON.stringify(value)])
		"string":
			if not (value is String) or (value as String).strip_edges().is_empty():
				add_error(file_name, label, "\"%s\" must be a non-empty text" % path)
		"int":
			if not _is_integer(value):
				add_error(file_name, label, "\"%s\" must be a whole number (got %s)" % [path, JSON.stringify(value)])
		"number":
			if not (value is int or value is float):
				add_error(file_name, label, "\"%s\" must be a number" % path)
		"bool":
			if not (value is bool):
				add_error(file_name, label, "\"%s\" must be true or false" % path)
		"loc":
			_check_loc(file_name, label, path, value)
		"color":
			if not (value is String) or not Color.html_is_valid(value):
				add_error(file_name, label, "\"%s\" must be a color like \"#e8b84a\"" % path)
		"dict":
			if not (value is Dictionary):
				add_error(file_name, label, "\"%s\" must be an object { ... }" % path)
		"array":
			if not (value is Array):
				add_error(file_name, label, "\"%s\" must be a list [ ... ]" % path)
		"segments":
			_check_segments(file_name, label, path, value)
		"scalable_list":
			if not (value is Array):
				add_error(file_name, label, "\"%s\" must be a list of value names" % path)
			else:
				for i: int in (value as Array).size():
					check_value(file_name, label, "%s[%d]" % [path, i], (value as Array)[i], "enum:spell_scalable")
		"rune_list":
			_check_id_list(file_name, label, path, value, "runes")
		"tag_list":
			if not (value is Array):
				add_error(file_name, label, "\"%s\" must be a list of tags" % path)
			else:
				for i: int in (value as Array).size():
					check_value(file_name, label, "%s[%d]" % [path, i], (value as Array)[i], "enum:monster_tag")
		"number_list":
			if not (value is Array) or (value as Array).is_empty():
				add_error(file_name, label, "\"%s\" must be a list of numbers" % path)
			else:
				for item: Variant in value:
					if not (item is int or item is float):
						add_error(file_name, label, "\"%s\" must hold only numbers" % path)
						break
		"action_list":
			if not (value is Array):
				add_error(file_name, label, "\"%s\" must be a list of actions" % path)
			else:
				for i: int in (value as Array).size():
					check_value(file_name, label, "%s[%d]" % [path, i], (value as Array)[i], "enum:tutorial_action")
		"spotlight_list":
			_check_spotlights(file_name, label, path, value)
		"loc_map":
			if not (value is Dictionary):
				add_error(file_name, label, "\"%s\" must be an object {\"key\": {\"ro\": ..., \"en\": ...}}" % path)
			else:
				for key: Variant in value:
					_check_loc(file_name, label, "%s.%s" % [path, str(key)], (value as Dictionary)[key])
		_:
			add_error(file_name, label, "internal: unknown field kind \"%s\" for \"%s\"" % [kind, path])


## Call after spells_base.json and runes.json are loaded: every spell is an Element ->
## Target pair, each pair appears exactly once, and every scalable value exists in an op.
func check_spells(file_name: String, spells: Dictionary, runes: Dictionary) -> void:
	var seen: Dictionary = {}
	for id: String in spells:
		var spell: Dictionary = spells[id]
		var element: String = str(spell.get("element", ""))
		var target: String = str(spell.get("target", ""))
		if runes.has(element) and str((runes[element] as Dictionary).get("role", "")) != "element":
			add_error(file_name, id, "\"element\" must be an Element rune (%s is not)" % element)
		if runes.has(target) and str((runes[target] as Dictionary).get("role", "")) != "target":
			add_error(file_name, id, "\"target\" must be a Target rune (%s is not)" % target)
		var key: String = element + ">" + target
		if seen.has(key):
			add_error(file_name, id, "same Element and Target as spell \"%s\"" % seen[key])
		else:
			seen[key] = id
		var ops: Variant = spell.get("ops")
		for field: Variant in spell.get("scalable", []):
			var found: bool = false
			if ops is Array:
				for op: Variant in ops:
					if op is Dictionary and (op as Dictionary).has(field):
						found = true
			if not found:
				add_error(file_name, id, "\"scalable\" names \"%s\", which no op has" % str(field))


## Call after realms.json and monsters.json are loaded: Realms numbered 1..n in order, each
## Lord is a boss, every Realm has small and big monsters, exactly one final boss.
func check_world(realms_file: String, realms: Dictionary, monsters_file: String, monsters: Dictionary,
		hp_mults: Variant) -> void:
	var n: int = 0
	for id: String in realms:
		n += 1
		var realm: Dictionary = realms[id]
		if int(realm.get("number", 0)) != n:
			add_error(realms_file, id, "realms must be numbered 1, 2, 3 … in file order")
		var boss: Dictionary = monsters.get(str(realm.get("boss", "")), {})
		if not boss.is_empty() and str(boss.get("kind", "")) != "boss":
			add_error(realms_file, id, "\"boss\" must be a monster of kind \"boss\"")
		var pool: Array = realm.get("pool_from", [n])
		for kind: String in ["small", "big"]:
			var found: bool = false
			for monster_id: String in monsters:
				var monster: Dictionary = monsters[monster_id]
				if str(monster.get("kind", "")) != kind:
					continue
				for number: Variant in monster.get("realms", []):
					if pool.has(int(number)):
						found = true
			if not found:
				add_error(realms_file, id, "no %s monster lives in this realm" % kind)
	var finals: int = 0
	for id: String in monsters:
		var monster: Dictionary = monsters[id]
		if bool(monster.get("final", false)):
			finals += 1
		if not monster.has("hp") and not monster.has("hp_mult"):
			add_error(monsters_file, id, "a monster needs \"hp\" or \"hp_mult\"")
	if finals != 1:
		add_error(monsters_file, "", "exactly one monster must have \"final\": true (found %d)" % finals)
	if hp_mults is Array and (hp_mults as Array).size() != 3:
		add_error("economy.json", "", "\"monster_hp_mults\" needs 3 numbers (small, big, boss)")


## Call after spell_actions.json and runes.json are loaded: one entry per Action rune.
func check_spell_actions(file_name: String, actions: Dictionary, runes: Dictionary) -> void:
	for id: String in actions:
		if runes.has(id) and str((runes[id] as Dictionary).get("role", "")) != "action":
			add_error(file_name, id, "%s is not an Action rune" % id)
	for id: String in runes:
		if str((runes[id] as Dictionary).get("role", "")) == "action" and not actions.has(id):
			add_error(file_name, "", "the Action rune \"%s\" has no entry" % id)


## JSON numbers arrive as floats; whole numbers become ints so code can use them directly.
static func normalize_numbers(value: Variant) -> Variant:
	if value is float:
		var number: float = value
		if not is_nan(number) and not is_inf(number) and number == floorf(number) and absf(number) < 1e15:
			return int(number)
		return number
	if value is Array:
		var array: Array = value
		for i: int in array.size():
			array[i] = normalize_numbers(array[i])
		return array
	if value is Dictionary:
		var dict: Dictionary = value
		for key: Variant in dict.keys():
			dict[key] = normalize_numbers(dict[key])
		return dict
	return value


func _check_fields(file_name: String, label: String, path: String, dict: Dictionary,
		required: Dictionary, optional: Dictionary) -> void:
	for field: String in required:
		if not dict.has(field):
			add_error(file_name, label, "missing field \"%s\"" % (path + field))
		else:
			check_value(file_name, label, path + field, dict[field], required[field])
	for key: Variant in dict:
		var field: String = str(key)
		if required.has(field):
			continue
		if optional.has(field):
			check_value(file_name, label, path + field, dict[key], optional[field])
		else:
			add_error(file_name, label, "unknown field \"%s\" (typo?)" % (path + field))


## Rune shapes: a list of line segments [x1, y1, x2, y2] inside the 0..1 square (y grows downward).
func _check_segments(file_name: String, label: String, path: String, value: Variant) -> void:
	if not (value is Array) or (value as Array).is_empty():
		add_error(file_name, label, "\"%s\" must be a non-empty list of lines [x1, y1, x2, y2]" % path)
		return
	var lines: Array = value
	for i: int in lines.size():
		var line_path: String = "%s[%d]" % [path, i]
		if not (lines[i] is Array) or (lines[i] as Array).size() != 4:
			add_error(file_name, label, "\"%s\" must have exactly 4 numbers [x1, y1, x2, y2]" % line_path)
			continue
		for number: Variant in lines[i]:
			if not (number is int or number is float) or float(number) < 0.0 or float(number) > 1.0:
				add_error(file_name, label, "\"%s\" numbers must be between 0 and 1 (got %s)" % [
					line_path, JSON.stringify(number)])
				break


## A list of ids that must exist in another collection (e.g. rune ids).
func _check_id_list(file_name: String, label: String, path: String, value: Variant, collection: String) -> void:
	if not (value is Array):
		add_error(file_name, label, "\"%s\" must be a list of ids" % path)
		return
	var ids: Array = value
	for i: int in ids.size():
		if not (ids[i] is String):
			add_error(file_name, label, "\"%s[%d]\" must be an id" % [path, i])
		else:
			_add_ref(file_name, label, "%s[%d]" % [path, i], collection, ids[i])


func _check_spotlights(file_name: String, label: String, path: String, value: Variant) -> void:
	if not (value is Array):
		add_error(file_name, label, "\"%s\" must be a list of UI ids" % path)
		return
	var ids: Array = value
	for i: int in ids.size():
		var item_path: String = "%s[%d]" % [path, i]
		var id: Variant = ids[i]
		if id is String and (id as String).begins_with("stone:"):
			_add_ref(file_name, label, item_path, "runes", (id as String).substr(6))
		else:
			check_value(file_name, label, item_path, id, "enum:ui_id")


func _check_loc(file_name: String, label: String, path: String, value: Variant) -> void:
	if not (value is Dictionary):
		add_error(file_name, label, "\"%s\" must be a text in both languages: {\"ro\": \"...\", \"en\": \"...\"}" % path)
		return
	var dict: Dictionary = value
	for language: String in LANGUAGES:
		var text: Variant = dict.get(language)
		if not (text is String) or (text as String).is_empty():
			add_error(file_name, label, "\"%s\" is missing the \"%s\" text" % [path, language])
	for key: Variant in dict:
		if not LANGUAGES.has(key):
			add_error(file_name, label, "\"%s\" has an unknown language \"%s\"" % [path, str(key)])


func _extra_checks(file_name: String, label: String, dict: Dictionary, schema_name: String) -> void:
	match schema_name:
		"hint":
			if dict.has("trigger") == dict.has("follows"):
				add_error(file_name, label, "a hint needs either \"trigger\" or \"follows\" (not both)")
			var trigger: Variant = dict.get("trigger")
			if trigger is Dictionary and str((trigger as Dictionary).get("event", "")) == "idle" \
					and not (trigger as Dictionary).has("seconds"):
				add_error(file_name, label, "an \"idle\" hint needs \"seconds\"")
			if str(dict.get("follows", "")) == str(dict.get("id", "")):
				add_error(file_name, label, "a hint cannot follow itself")
		"rules":
			for field: String in ["hand_size", "casts_per_round", "max_stones_per_action", "copies_per_rune"]:
				var number: Variant = dict.get(field)
				if number is int and number < 1:
					add_error(file_name, label, "\"%s\" must be at least 1" % field)


func _add_ref(file_name: String, label: String, path: String, collection: String, id_value: String) -> void:
	_refs.append({"file": file_name, "label": label, "path": path, "collection": collection, "id": id_value})


func _is_integer(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		var number: float = value
		return number == floorf(number)
	return false
