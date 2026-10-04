extends RefCounted
## Texts for the spells of the rune grammar, in the current language: the sentence a
## selection forms ("Gheața → se întinde → peste Țintă"), a spell's effect with its numbers,
## and the help line under the circle.

const SpellResolver = preload("res://scripts/core/spell_resolver.gd")
const SentenceParser = preload("res://scripts/core/sentence_parser.gd")

const ARROW: String = " → "


## The rune phrases joined as a sentence.
static func sentence(rune_ids: Array) -> String:
	var parts: PackedStringArray = []
	for id: Variant in rune_ids:
		parts.append(Loc.text((GameData.runes.get(id, {}) as Dictionary).get("phrase", {})))
	return ARROW.join(parts)


## The spell's effect with its numbers filled in (scaled by the Actions when scale != 1).
static func effect(spell: Dictionary, scale: float = 1.0) -> String:
	var values: Dictionary = {}
	var raw: Dictionary = SpellResolver.effect_values(spell, scale)
	for key: Variant in raw:
		values[key] = Loc.number(float(raw[key]))
	return Loc.text(spell.get("effect", {}), values)


## The line under the circle for a parsed selection ("" when there is nothing to say).
static func circle_line(parsed: Dictionary) -> String:
	var status: String = str(parsed.get("status", ""))
	var text: String = sentence(parsed.get("parts", []))
	match status:
		SentenceParser.SPELL:
			var spell_id: String = parsed["spell"]
			if SaveManager.has_discovery("spells", spell_id):
				return Loc.t("circle_spell", {"name": Loc.text(GameData.spells[spell_id]["name"])})
			return Loc.t("spell_unknown", {"sentence": text})
		SentenceParser.DORMANT:
			return Loc.t("spell_dormant", {"sentence": text})
		SentenceParser.INCOMPLETE:
			return Loc.t("spell_incomplete", {"sentence": text})
		SentenceParser.WRONG_ORDER:
			return Loc.t("spell_wrong_order")
		SentenceParser.INTERRUPTED:
			return Loc.t("spell_interrupted")
	return ""


## What a rune does in a sentence: an Element's strength and nature (at this level), an
## Action's effect, a Target's share of the damage.
static func rune_role(rune_id: String, level: int = 1) -> String:
	var rune: Dictionary = GameData.runes.get(rune_id, {})
	match str(rune.get("role", "")):
		"element":
			var element: Dictionary = GameData.elements.get(rune_id, {})
			if element.is_empty():
				return ""
			var power: float = float(element["power"]) + float(element["level_power"]) * (level - 1)
			var res: float = float(element["res"]) + float(element["level_res"]) * (level - 1)
			return Loc.t("rune_does_element", {"power": Loc.number(power), "res": Loc.number(res),
				"nature": nature(element)})
		"action":
			return Loc.text((GameData.spell_actions.get(rune_id, {}) as Dictionary).get("effect", {}))
		"target":
			return Loc.text((GameData.targets.get(rune_id, {}) as Dictionary).get("text", {}))
	return ""


## An Element's nature, normal or doubled (by Tiwaz).
static func nature(element: Dictionary, double: bool = false) -> String:
	return Loc.text(element.get("nature_text", {}), {
		"value": Loc.number(float(element.get("nature_double" if double else "nature_value", 0))),
		"stacks": int(element.get("max_stacks", 3)),
	})


## A spell's name, or "???" while it is still undiscovered.
static func spell_name(spell_id: String) -> String:
	if not SaveManager.has_discovery("spells", spell_id):
		return Loc.t("word_hidden")
	return Loc.text((GameData.spells.get(spell_id, {}) as Dictionary).get("name", {}))


## An Element's name: its rune's phrase ("Focul", "Gheața").
static func element_name(element_id: String) -> String:
	return Loc.text((GameData.runes.get(element_id, {}) as Dictionary).get("phrase", {}))


## A Lord's rule, with its number ("" when the monster has none).
static func rule_text(entry: Dictionary) -> String:
	if not entry.has("rule_text"):
		return ""
	return Loc.text(entry["rule_text"], {"value": Loc.number(float(entry.get("rule_value", 0)))})
