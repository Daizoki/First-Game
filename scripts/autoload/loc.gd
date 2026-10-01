extends Node
## Localization helper. Every text shown on screen goes through here.
##   Loc.t("menu_play")                      -> text from data/ui_text.json
##   Loc.text(card["name"])                  -> any {"ro": "...", "en": "..."} object
##   Loc.t("aeva_again", {"n": 3})           -> replaces {n} in the text

signal language_changed(language: String)

const LANGUAGES: Array = ["ro", "en"]
const DEFAULT_LANGUAGE: String = "ro"

var language: String = DEFAULT_LANGUAGE
## key -> {"ro": "...", "en": "..."}; filled from GameData in _ready.
var ui_text: Dictionary = {}

var _reported_missing: Dictionary = {}


func _ready() -> void:
	ui_text = GameData.ui_text
	set_language(str(SaveManager.get_setting("language", DEFAULT_LANGUAGE)))


## Switches the language and notifies every screen. Unknown codes fall back to Romanian.
func set_language(code: String) -> void:
	if not LANGUAGES.has(code):
		code = DEFAULT_LANGUAGE
	if code == language:
		return
	language = code
	language_changed.emit(language)


## Text from ui_text.json. Missing keys show as [key] so they are easy to spot.
func t(key: String, params: Dictionary = {}) -> String:
	if not ui_text.has(key):
		if not _reported_missing.has(key):
			_reported_missing[key] = true
			push_warning("Loc: missing ui_text key \"%s\"" % key)
		return "[%s]" % key
	return text(ui_text[key], params)


## Resolves a {"ro": "...", "en": "..."} object into the current language.
func text(value: Variant, params: Dictionary = {}) -> String:
	var result: String = ""
	if value is Dictionary:
		var dict: Dictionary = value
		result = str(dict.get(language, dict.get(DEFAULT_LANGUAGE, "")))
	elif value is String:
		result = value
	if not params.is_empty():
		result = result.format(params)
	return result


## Big numbers, nicely: "12 840" / "1,2 mil." in Romanian, "12,840" / "1.2M" in English.
func number(value: float) -> String:
	var negative: bool = value < 0.0
	value = absf(value)
	var text: String
	if value >= 1.0e6:
		var millions: String = _decimal(value / 1.0e6, 1)
		text = t("number_millions", {"n": millions})
	elif value != floorf(value) and value < 100.0:
		text = _decimal(value, 1)
	else:
		text = _group_thousands(str(int(roundf(value))))
	return ("-" if negative else "") + text


func _decimal(value: float, digits: int) -> String:
	var text: String = String.num(value, digits)
	if text.ends_with(".0"):
		text = text.substr(0, text.length() - 2)
	return text.replace(".", t("number_decimal_point"))


func _group_thousands(digits: String) -> String:
	var separator: String = t("number_thousands_separator")
	var result: String = ""
	var count: int = 0
	for i: int in range(digits.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = separator + result
		result = digits[i] + result
		count += 1
	return result
