# Writes docs/TRADUCERI.md: every Romanian text of the evening class, the spells of the rune
# grammar, the hints and the UI, side by side with its English translation, so Relax can
# check the English. Run from the project root after changing a text:
#   python3 tools/export_translations.py

import json

OUT = "docs/TRADUCERI.md"


def load(name):
    with open(f"data/{name}", encoding="utf-8") as f:
        return json.load(f)


def cell(text):
    return text.replace("|", "\\|").replace("\n", " ")


def is_text(value):
    return isinstance(value, dict) and set(value) == {"ro", "en"}


def walk(value, path, rows):
    """Collects (path, ro, en) for every {"ro", "en"} pair under `value`."""
    if is_text(value):
        rows.append((path, value["ro"], value["en"]))
    elif isinstance(value, dict):
        for key, item in value.items():
            walk(item, f"{path}.{key}" if path else key, rows)
    elif isinstance(value, list):
        for index, item in enumerate(value):
            walk(item, f"{path}[{index}]", rows)


def table(rows, first="Unde"):
    lines = [f"| {first} | Română | English |", "|---|---|---|"]
    for where, ro, en in rows:
        lines.append(f"| `{cell(where)}` | {cell(ro)} | {cell(en)} |")
    return lines


def tutorial_section():
    data = load("tutorial.json")
    out = ["## Instruirea (`data/tutorial.json`)", ""]
    rows = []
    walk(data["intro"], "intro", rows)
    out += ["### Intro", ""] + table(rows) + [""]
    for number, lesson in enumerate(data["lessons"], 1):
        rows = []
        for key, value in lesson.items():
            if key == "steps":
                for index, step in enumerate(value, 1):
                    walk(step, f"pas {index}", rows)
            elif key != "id":
                walk(value, key, rows)
        title = lesson.get("title", {}).get("ro", lesson["id"])
        out += [f"### Lecția {number} — {title}", ""] + table(rows) + [""]
    return out


def spells_section():
    out = ["## Gramatica runelor (`data/runes.json`, `data/spells_base.json`, `data/spell_actions.json`)", ""]
    rows = [(rune["id"] + " · " + rune["role"], rune["phrase"]["ro"], rune["phrase"]["en"]) for rune in load("runes.json")]
    out += ["### Rolul fiecărei rune în propoziție", ""] + table(rows, "Rună") + [""]
    rows = []
    for spell in load("spells_base.json"):
        where = spell["id"] + ("" if spell["enabled"] else " (doarme)")
        rows.append((where, spell["name"]["ro"], spell["name"]["en"]))
        rows.append((where + " · efect", spell["effect"]["ro"], spell["effect"]["en"]))
    out += ["### Cele 64 de vrăji (nume și efect)", ""] + table(rows, "Vraja") + [""]
    rows = [(action["id"], action["effect"]["ro"], action["effect"]["en"]) for action in load("spell_actions.json")]
    out += ["### Cele 8 Acțiuni", ""] + table(rows, "Acțiune") + [""]
    return out


def hints_section():
    rows = [(hint["id"] + ("" if hint["enabled"] else " (oprit)"), hint["text"]["ro"], hint["text"]["en"])
            for hint in load("hints.json")]
    return ["## Indiciile (`data/hints.json`)", ""] + table(rows, "Indiciu") + [""]


def ui_section():
    rows = [(key, value["ro"], value["en"]) for key, value in load("ui_text.json").items() if is_text(value)]
    return ["## Textele interfeței (`data/ui_text.json`)", ""] + table(rows, "Cheie") + [""]


def main():
    lines = [
        "# Traducerile în engleză",
        "",
        "> Generat cu `python3 tools/export_translations.py` din fișierele din `data/`. Nu-l edita de mână: schimbă",
        "> textul în JSON și rulează din nou scriptul. `{name}`, `{n}` … sunt locuri pe care jocul le completează.",
        "",
    ]
    lines += tutorial_section() + spells_section() + hints_section() + ui_section()
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
