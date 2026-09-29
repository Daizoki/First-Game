extends "res://tests/test_case.gd"
## Loc: languages, fallbacks and {placeholders}.

const LocScript = preload("res://scripts/autoload/loc.gd")


func _make_loc() -> LocScript:
	var loc: LocScript = LocScript.new()
	loc.ui_text = {
		"hello": {"ro": "Salut, {name}!", "en": "Hello, {name}!"},
		"again": {"ro": "Iar tu? A {n}-a oară în dimineața asta.", "en": "You again? Time number {n} this morning."},
	}
	return loc


func test_default_language_is_romanian() -> void:
	var loc: LocScript = _make_loc()
	check_eq(loc.language, "ro", "default language:")
	check_eq(loc.t("hello", {"name": "Relax"}), "Salut, Relax!", "ro text:")
	loc.free()


func test_switch_language_and_signal() -> void:
	var loc: LocScript = _make_loc()
	var received: Array = []
	loc.language_changed.connect(func(code: String) -> void: received.append(code))
	loc.set_language("en")
	check_eq(loc.t("hello", {"name": "Relax"}), "Hello, Relax!", "en text:")
	check_eq(received, ["en"], "signal:")
	loc.set_language("en")
	check_eq(received.size(), 1, "same language should not emit again:")
	loc.free()


func test_unknown_language_falls_back_to_romanian() -> void:
	var loc: LocScript = _make_loc()
	loc.set_language("en")
	loc.set_language("xx")
	check_eq(loc.language, "ro", "fallback language:")
	loc.free()


func test_number_placeholder() -> void:
	var loc: LocScript = _make_loc()
	check_eq(loc.t("again", {"n": 3}), "Iar tu? A 3-a oară în dimineața asta.", "number param:")
	loc.free()


func test_missing_key_shows_key() -> void:
	var loc: LocScript = _make_loc()
	check_eq(loc.t("nope"), "[nope]", "missing key:")
	loc.free()


func test_text_resolves_any_loc_object() -> void:
	var loc: LocScript = _make_loc()
	var name: Dictionary = {"ro": "Lovitură", "en": "Strike"}
	check_eq(loc.text(name), "Lovitură", "ro:")
	loc.set_language("en")
	check_eq(loc.text(name), "Strike", "en:")
	check_eq(loc.text({"ro": "doar ro"}), "doar ro", "missing en falls back to ro:")
	loc.free()
