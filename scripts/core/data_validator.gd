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
}

## Field kinds:
##   id, string, int, number, bool, loc, color, dict, array, segments,
##   enum:<name>, ref:<collection>, object:<schema>, array:<schema>
const SCHEMAS: Dictionary = {
	"kin": {
		"required": {"id": "id", "name": "loc", "color": "color", "sign": "enum:kin_sign"},
		"optional": {},
	},
	"rune": {
		"required": {
			"id": "id", "name": "loc", "glyph": "string", "kin": "ref:kins", "position": "int",
			"base_power": "int", "meaning": "loc", "voice": "loc", "segments": "segments",
		},
		"optional": {},
	},
	"word": {
		"required": {"id": "id", "name": "loc", "description": "loc"},
		"optional": {"hidden": "bool"},
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
	"rules": {
		"required": {
			"hand_size": "int", "casts_per_round": "int", "swaps_per_round": "int",
			"max_stones_per_action": "int", "copies_per_rune": "int", "rune_voices_start_awake": "bool",
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


## Call after runes.json is loaded: every kin must hold exactly one rune on each position 1..8.
func check_runes(file_name: String, runes: Dictionary, kins: Dictionary) -> void:
	var taken: Dictionary = {}
	for id: String in runes:
		var rune: Dictionary = runes[id]
		var kin: Variant = rune.get("kin")
		var position: Variant = rune.get("position")
		if not (kin is String) or not (position is int):
			continue
		var key: String = "%s:%d" % [kin, position]
		if taken.has(key):
			add_error(file_name, id, "kin \"%s\" already has a rune on position %d (%s)" % [kin, position, taken[key]])
		else:
			taken[key] = id
	for kin_id: String in kins:
		for position: int in range(1, KIN_SIZE + 1):
			if not taken.has("%s:%d" % [kin_id, position]):
				add_error(file_name, "", "kin \"%s\" has no rune on position %d" % [kin_id, position])


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
		_:
			add_error(file_name, label, "internal: unknown field kind \"%s\" for \"%s\"" % [kind, path])


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
		"rune":
			var position: Variant = dict.get("position")
			if position is int and (position < 1 or position > KIN_SIZE):
				add_error(file_name, label, "\"position\" must be between 1 and %d" % KIN_SIZE)
			var power: Variant = dict.get("base_power")
			if power is int and power < 0:
				add_error(file_name, label, "\"base_power\" cannot be negative")
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
