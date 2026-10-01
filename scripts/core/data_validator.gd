extends RefCounted
## Checks the content of data/*.json against simple schemas.
## Every problem becomes one readable line: "data/<file> [<id>]: <problem>".
## Pure logic, no autoloads: it can run in tests without a scene.

const LANGUAGES: Array = ["ro", "en"]

## Allowed values for "enum:<name>" fields.
const ENUMS: Dictionary = {
	"target": ["enemy", "all_enemies", "random_enemy", "self"],
	"status": ["burn", "weak", "vulnerable", "strength"],
	"card_type": ["attack", "skill", "power", "rune"],
	"rarity": ["starter", "common", "uncommon", "rare", "special"],
	"unlock_type": ["default", "after_attempts", "memories"],
	"blessing_trigger": ["combat_start", "first_turn", "combat_end", "passive"],
	"blessing_rule": ["negate_first_hit", "burn_bonus", "choose_card_from_deck", "cheat_death", "first_word_double"],
}

## Rune combo wildcard in words.json: matches any rune.
const ANY_RUNE: String = "any"
## Number of runes the Rune Circle holds before they are spoken as a Word.
const CIRCLE_SIZE: int = 3

## Field kinds:
##   id, string, int, number, bool, loc, color, dict, array, pool, effects, rune_combo,
##   enum:<name>, ref:<collection>, object:<schema>, array:<schema>
const SCHEMAS: Dictionary = {
	"god": {
		"required": {
			"id": "id", "name": "loc", "domain": "loc", "job": "loc",
			"personality": "loc", "color": "color",
		},
		"optional": {
			"playable": "bool", "starting_hp": "int", "signature_card": "ref:cards",
			"affinity_rune": "ref:runes", "playstyle": "loc", "unlock": "object:unlock",
		},
	},
	"unlock": {
		"required": {"type": "enum:unlock_type"},
		"optional": {"value": "int"},
	},
	"card": {
		"required": {
			"id": "id", "name": "loc", "cost": "int", "type": "enum:card_type",
			"rarity": "enum:rarity", "pool": "pool", "effects": "effects",
		},
		"optional": {"description": "loc", "rune": "ref:runes", "upgrade": "object:card_upgrade"},
	},
	"card_upgrade": {
		"required": {},
		"optional": {"cost": "int", "effects": "effects", "description": "loc"},
	},
	"character": {
		"required": {"id": "id", "name": "loc", "description": "loc", "color": "color"},
		"optional": {"parent": "ref:gods"},
	},
	"rune": {
		"required": {"id": "id", "name": "loc", "meaning": "loc", "color": "color"},
		"optional": {},
	},
	"word": {
		"required": {"id": "id", "name": "loc", "runes": "rune_combo", "effects": "effects"},
		"optional": {"description": "loc", "fallback": "bool"},
	},
	"enemy": {
		"required": {"id": "id", "name": "loc", "hp": "int"},
		"optional": {},
	},
	"blessing": {
		"required": {"id": "id", "name": "loc", "description": "loc", "effect": "object:blessing_effect"},
		"optional": {},
	},
	"blessing_effect": {
		"required": {"trigger": "enum:blessing_trigger"},
		"optional": {"actions": "effects", "rule": "enum:blessing_rule", "value": "int"},
	},
	"trial": {
		"required": {"id": "id", "name": "loc"},
		"optional": {},
	},
	"event": {
		"required": {"id": "id", "name": "loc"},
		"optional": {},
	},
	"dialog": {
		"required": {"id": "id", "lines": "array:dialog_line"},
		"optional": {},
	},
	"dialog_line": {
		"required": {"speaker": "string", "text": "loc"},
		"optional": {},
	},
}

## Actions used by cards and blessings: "type" -> schema of the other fields.
const EFFECTS: Dictionary = {
	"damage": {"required": {"value": "int", "target": "enum:target"}, "optional": {"times": "int"}},
	"block": {"required": {"value": "int"}, "optional": {}},
	"apply": {"required": {"status": "enum:status", "value": "int", "target": "enum:target"}, "optional": {}},
	"draw": {"required": {"value": "int"}, "optional": {}},
	"energy": {"required": {"value": "int"}, "optional": {}},
	"heal": {"required": {"value": "int"}, "optional": {}},
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
				add_error(file_name, label, "\"%s\" must be a color like \"#e8c547\"" % path)
		"dict":
			if not (value is Dictionary):
				add_error(file_name, label, "\"%s\" must be an object { ... }" % path)
		"array":
			if not (value is Array):
				add_error(file_name, label, "\"%s\" must be a list [ ... ]" % path)
		"pool":
			if not (value is String):
				add_error(file_name, label, "\"%s\" must be \"neutral\" or a god id" % path)
			elif value != "neutral":
				_add_ref(file_name, label, path, "gods", value)
		"effects":
			_check_effects(file_name, label, path, value)
		"rune_combo":
			_check_rune_combo(file_name, label, path, value)
		_:
			add_error(file_name, label, "internal: unknown field kind \"%s\" for \"%s\"" % [kind, path])


## Call after words.json is loaded: no two Words may use the same rune combination
## (order does not matter) and there must be exactly one fallback ("mumble") Word.
func check_words(file_name: String, words: Dictionary) -> void:
	var seen: Dictionary = {}
	var fallback_count: int = 0
	for id: String in words:
		var word: Dictionary = words[id]
		var fallback: Variant = word.get("fallback", false)
		if fallback is bool and fallback:
			fallback_count += 1
			continue
		if not _is_string_list(word.get("runes")):
			continue
		var key: String = combo_key(word["runes"])
		if seen.has(key):
			add_error(file_name, id, "same runes as word \"%s\" (%s)" % [seen[key], key])
		else:
			seen[key] = id
	if not words.is_empty() and fallback_count != 1:
		add_error(file_name, "", "there must be exactly one word with \"fallback\": true (the mumbled word), found %d" % fallback_count)


## Order-independent key for a rune combination, e.g. ["tor", "ar", "tor"] -> "ar+tor+tor".
static func combo_key(runes: Array) -> String:
	var names: PackedStringArray = PackedStringArray(runes)
	names.sort()
	return "+".join(names)


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


func _check_effects(file_name: String, label: String, path: String, value: Variant) -> void:
	if not (value is Array):
		add_error(file_name, label, "\"%s\" must be a list of actions [ {\"type\": ...} ]" % path)
		return
	var actions: Array = value
	for i: int in actions.size():
		var action_path: String = "%s[%d]" % [path, i]
		if not (actions[i] is Dictionary):
			add_error(file_name, label, "\"%s\" must be an object {\"type\": ...}" % action_path)
			continue
		var action: Dictionary = actions[i]
		var type_value: Variant = action.get("type")
		if not (type_value is String) or not EFFECTS.has(type_value):
			add_error(file_name, label, "\"%s.type\" must be one of: %s (got %s)" % [
				action_path, ", ".join(PackedStringArray(EFFECTS.keys())), JSON.stringify(type_value)])
			continue
		var schema: Dictionary = EFFECTS[type_value]
		var optional: Dictionary = (schema["optional"] as Dictionary).duplicate()
		optional["type"] = "string"
		_check_fields(file_name, label, action_path + ".", action, schema["required"], optional)


func _check_rune_combo(file_name: String, label: String, path: String, value: Variant) -> void:
	if not (value is Array):
		add_error(file_name, label, "\"%s\" must be a list of rune ids, e.g. [\"tor\", \"tor\", \"tor\"]" % path)
		return
	var runes: Array = value
	for i: int in runes.size():
		var rune: Variant = runes[i]
		var rune_path: String = "%s[%d]" % [path, i]
		if not (rune is String):
			add_error(file_name, label, "\"%s\" must be a rune id or \"%s\"" % [rune_path, ANY_RUNE])
		elif rune != ANY_RUNE:
			_add_ref(file_name, label, rune_path, "runes", rune)


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
		"god":
			var playable: Variant = dict.get("playable", false)
			if playable is bool and playable:
				for field: String in ["starting_hp", "signature_card", "affinity_rune", "unlock"]:
					if not dict.has(field):
						add_error(file_name, label, "playable god is missing field \"%s\"" % field)
		"card":
			var cost: Variant = dict.get("cost")
			if cost is int and cost < 0:
				add_error(file_name, label, "\"cost\" cannot be negative")
			var type_value: Variant = dict.get("type")
			var is_rune_card: bool = type_value is String and type_value == "rune"
			if is_rune_card != dict.has("rune"):
				add_error(file_name, label, "rune cards need type \"rune\" and a \"rune\" field (both or neither)")
		"word":
			var fallback: Variant = dict.get("fallback", false)
			var runes: Variant = dict.get("runes")
			if runes is Array:
				var size: int = (runes as Array).size()
				if fallback is bool and fallback and size != 0:
					add_error(file_name, label, "the fallback word (mumble) must have \"runes\": []")
				elif not (fallback is bool and fallback) and size != CIRCLE_SIZE:
					add_error(file_name, label, "\"runes\" must list exactly %d runes (got %d)" % [CIRCLE_SIZE, size])


func _add_ref(file_name: String, label: String, path: String, collection: String, id_value: String) -> void:
	_refs.append({"file": file_name, "label": label, "path": path, "collection": collection, "id": id_value})


func _is_string_list(value: Variant) -> bool:
	if not (value is Array):
		return false
	for item: Variant in value:
		if not (item is String):
			return false
	return true


func _is_integer(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		var number: float = value
		return number == floorf(number)
	return false
