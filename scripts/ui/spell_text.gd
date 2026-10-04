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
