extends "res://tests/test_case.gd"
## Contextual hints (data/hints.json): validation and which hint is due when.

const Fixtures = preload("res://tests/fixtures.gd")
const HintRules = preload("res://scripts/core/hint_rules.gd")
const DataValidator = preload("res://scripts/core/data_validator.gd")

## Hints that are switched on now (the others wait for their stage).
const ENABLED_NOW: Array[String] = [
	"idle_help", "first_wrong_order", "first_scroll", "first_two_actions", "first_shop_1",
	"first_shop_2", "first_shop_3", "first_reroll", "first_talisman", "first_rule", "first_lesson",
	"first_engraving", "first_bindrune", "first_loss_1", "first_loss_2", "first_loss_3", "first_evening_class",
	"first_torn_page",
]
const MAX_TEXT: int = 120


func _rules(table: Dictionary = {}) -> HintRules:
	var rules: HintRules = HintRules.new()
	rules.setup(Fixtures.data()["hints"] if table.is_empty() else table)
	return rules


func _context(seen: Array = [], exams: int = 1) -> Dictionary:
	return {"seen": seen, "enabled": true, "tutorial": false, "exams": exams}


func _hint(id: String, extra: Dictionary) -> Dictionary:
	var hint: Dictionary = {"id": id, "enabled": true, "speaker": "vera", "text": {"ro": id, "en": id}}
	hint.merge(extra)
	return hint


func test_the_table_is_in_the_data() -> void:
	var hints: Dictionary = Fixtures.data()["hints"]
	check_eq(hints.size(), 22, "hints:")
	var enabled: Array[String] = []
	for id: String in hints:
		var hint: Dictionary = hints[id]
		if bool(hint["enabled"]):
			enabled.append(id)
		for language: String in ["ro", "en"]:
			var text: String = hint["text"][language]
			check(text.length() <= MAX_TEXT, "%s (%s) is longer than %d characters" % [id, language, MAX_TEXT])
		check(Fixtures.data()["characters"].has(hint["speaker"]), "%s: unknown speaker" % id)
	check_eq(enabled, ENABLED_NOW, "enabled hints:")


func test_the_old_laguz_hint_sleeps() -> void:
	# Laguz is no joker any more (Stage 5): its hint is switched off.
	var rules: HintRules = _rules()
	check_eq(rules.on_event("rune_in_hand", {"runes": ["fehu", "laguz"]}, _context()), [], "Laguz in hand:")


func test_quiet_in_the_tutorial_and_when_switched_off() -> void:
	var rules: HintRules = _rules()
	var tutorial: Dictionary = _context()
	tutorial["tutorial"] = true
	check_eq(rules.on_event("shop_opened", {}, tutorial), [], "during the evening class:")
	check_eq(rules.idle_threshold(tutorial), INF, "idle during the evening class:")
	var off: Dictionary = _context()
	off["enabled"] = false
	check_eq(rules.on_event("shop_opened", {}, off), [], "hints off:")
	check_eq(rules.idle_threshold(off), INF, "idle with hints off:")


func test_idle_help_after_40_seconds_in_the_first_three_exams() -> void:
	var rules: HintRules = _rules()
	check_eq(rules.idle_threshold(_context()), 40.0, "threshold:")
	check_eq(rules.on_event("idle", {"seconds": 39.0}, _context()), [], "39 s:")
	check_eq(rules.on_event("idle", {"seconds": 40.0}, _context([], 3)), ["idle_help"], "40 s, third exam:")
	check_eq(rules.on_event("idle", {"seconds": 90.0}, _context([], 4)), [], "fourth exam:")
	check_eq(rules.idle_threshold(_context([], 4)), INF, "no idle hint after the third exam:")
	check_eq(rules.idle_threshold(_context(["idle_help"])), INF, "idle hint already seen:")


func test_hints_of_later_stages_stay_quiet() -> void:
	var rules: HintRules = _rules()
	for event: String in ["curse_discovered", "old_word_discovered"]:
		check_eq(rules.on_event(event, {}, _context()), [], "%s:" % event)


func test_aevas_loop() -> void:
	var rules: HintRules = _rules()
	check_eq(rules.on_event("exam_failed", {}, _context()), ["first_loss_1", "first_loss_2", "first_loss_3"],
		"the first failed exam:")
	check_eq(rules.on_event("exam_failed", {}, _context(["first_loss_1", "first_loss_2", "first_loss_3"])), [],
		"only once:")
	check_eq(rules.on_event("evening_class", {}, _context()), ["first_evening_class"], "the evening class again:")
	check_eq(rules.on_event("torn_page_found", {}, _context()), ["first_torn_page"], "the first Torn Page:")


func test_a_hint_brings_the_ones_that_follow_it() -> void:
	var table: Dictionary = {
		"shop_1": _hint("shop_1", {"trigger": {"event": "shop_opened"}}),
		"shop_2": _hint("shop_2", {"follows": "shop_1"}),
		"shop_3": _hint("shop_3", {"follows": "shop_2"}),
		"talisman": _hint("talisman", {"trigger": {"event": "talisman_bought"}}),
	}
	var rules: HintRules = _rules(table)
	check_eq(rules.on_event("shop_opened", {}, _context()), ["shop_1", "shop_2", "shop_3"], "the whole chain:")
	check_eq(rules.on_event("shop_opened", {}, _context(["shop_2"])), ["shop_1", "shop_3"], "skips a seen one:")
	check_eq(rules.on_event("shop_opened", {}, _context(["shop_1"])), [], "the chain starts with its trigger:")
	(table["shop_3"] as Dictionary)["enabled"] = false
	check_eq(rules.on_event("shop_opened", {}, _context()), ["shop_1", "shop_2"], "a switched-off follower:")


func test_a_chain_that_loops_ends() -> void:
	# The validator refuses this table; the rules must still not hang on it.
	var table: Dictionary = {
		"start": _hint("start", {"trigger": {"event": "shop_opened"}, "follows": "b"}),
		"a": _hint("a", {"follows": "start"}),
		"b": _hint("b", {"follows": "a"}),
	}
	check_eq(_rules(table).on_event("shop_opened", {}, _context()), ["start", "a", "b"], "loop:")


func test_validator_checks_hints() -> void:
	var validator: DataValidator = DataValidator.new()
	var raw: Array = [
		_hint("both", {"trigger": {"event": "shop_opened"}, "follows": "fine"}),
		_hint("neither", {}),
		_hint("lazy", {"trigger": {"event": "idle"}}),
		_hint("odd", {"trigger": {"event": "dancing"}}),
		_hint("lost", {"follows": "nowhere"}),
		_hint("fine", {"trigger": {"event": "rune_in_hand", "rune": "laguz"}}),
	]
	var loaded: Dictionary = {"hints": validator.validate_collection("hints.json", raw, "hint"),
		"characters": {"vera": {}}, "runes": {"laguz": {}}}
	validator.check_references(loaded)
	var errors: Array[String] = validator.errors
	check(has_error(errors, ["[both]", "either"]), "trigger and follows together should be an error")
	check(has_error(errors, ["[neither]", "either"]), "a hint without trigger or follows should be an error")
	check(has_error(errors, ["[lazy]", "seconds"]), "idle without seconds should be an error")
	check(has_error(errors, ["[odd]", "dancing"]), "an unknown event should be an error")
	check(has_error(errors, ["[lost]", "nowhere"]), "following a missing hint should be an error")
	check(not has_error(errors, ["[fine]"]), "a good hint should pass: " + "\n".join(PackedStringArray(errors)))


func test_the_grammar_hints() -> void:
	var rules: HintRules = _rules()
	check_eq(rules.on_event("wrong_order", {}, _context()), ["first_wrong_order"] as Array[String], "wrong order:")
	check_eq(rules.on_event("scroll_gained", {"spell": "uruz_fehu"}, _context()), ["first_scroll"] as Array[String],
		"first Scroll:")
	check_eq(rules.on_event("two_actions", {"spell": "isaz_tiwaz"}, _context()), ["first_two_actions"] as Array[String],
		"two Actions:")
	check_eq(rules.on_event("wrong_order", {}, _context(["first_wrong_order"])), [] as Array[String], "only once:")
	var tutorial: Dictionary = _context()
	tutorial["tutorial"] = true
	check_eq(rules.on_event("wrong_order", {}, tutorial), [] as Array[String], "quiet in the evening class:")


func test_meeting_the_lords() -> void:
	var rules: HintRules = _rules()
	check_eq(rules.on_event("examiner_met", {"examiner": "statu_palma"}, _context()), ["first_rule"] as Array[String],
		"the first Lord: Ilinca explains the rule:")
	check_eq(rules.on_event("examiner_met", {"examiner": "muma_padurii"}, _context(["first_rule"])),
		[] as Array[String], "only once:")


func test_the_market_hints() -> void:
	var rules: HintRules = _rules()
	check_eq(rules.on_event("shop_opened", {}, _context()), ["first_shop_1", "first_shop_2", "first_shop_3"] as Array[String],
		"Tanti Vera's three lines:")
	check_eq(rules.on_event("talisman_bought", {}, _context()), ["first_talisman"] as Array[String], "the first Talisman:")
	check_eq(rules.on_event("engraving_gained", {}, _context()), ["first_engraving"] as Array[String], "the first Engraving:")
