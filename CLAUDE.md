# CLAUDE.md — reguli pentru „Examenul” (Universul „Coborârea”, Jocul 1)

> Versiunea de design: **v2 (cu rune)**. Cei doi stâlpi ai jocului: **Puterile** (moștenite de la părintele divin)
> și **Runele** (magia oamenilor, învățată). Motto: „Puterea o moștenești. Runele le înveți.”

Citește asta la începutul fiecărei sesiuni. Detaliile de design sunt în `docs/DESIGN.md`,
lumea și personajele în `docs/UNIVERS.md`.

## Cum lucrăm
- Utilizatorul e **Relax** (18 ani, Chișinău; pixel art, TikTok/YouTube). **Scrie-i în română.**
  Codul, numele de fișiere și comentariile din cod sunt în **engleză**.
- **Claude scrie tot codul. Relax desenează arta, testează și ia deciziile de design.**
- Lucrăm pe **etape** (vezi mai jos). După fiecare etapă: te oprești și spui scurt
  1) ce ai făcut; 2) cum testează (ce apasă, ce ar trebui să vadă); 3) ce ai decis singur și ar putea vrea altfel.
  Apoi commit în git. **Nu treci la etapa următoare fără OK-ul lui.**
- Dacă ceva e neclar sau se contrazice: **întreabă înainte să construiești**.
- Lucruri complete care rulează, nu bucăți de cod de lipit.
- **Nu descărca și nu instala nimic** (fonturi, pluginuri, pachete) fără să spui întâi ce, de unde și de ce.
- Toate personajele sunt originale. Fără zei din mitologii reale, personaje din alte opere
  sau **alfabete runice reale** (futhark etc.): runele și simbolurile lor sunt inventate.

## Reguli tehnice
- **Godot 4.x, GDScript.** Randare `gl_compatibility` (merge și pe Web).
- **Tipuri statice peste tot.** Fiecare funcție are tip de return explicit; funcțiile care pot
  întoarce `null` sau tipuri mixte folosesc `-> Variant`. Variabilele de buclă au tip (`for id: String in ...`).
  Avertismentul `untyped_declaration` e pornit în `project.godot`.
- **Fără scripturi uriașe.** Fiecare ecran = o scenă `.tscn` cu scriptul ei mic. Arbori de noduri simpli.
  Nodurile folosite din cod au `unique_name_in_owner` și se iau cu `%Nume`.
- **Logica separată de UI.** Lupta, efectele, AI-ul stau în clase care rulează fără ecran (testabile).
- **Nu folosim `class_name`** în scripturile de logică: testele le încarcă cu `preload(...)`, ca să meargă
  și pe un repo proaspăt clonat (fără cache-ul `.godot/`). Autoload-urile nu au voie să aibă `class_name`.
- **Conținutul stă în JSON în `data/`**, nu în cod. `GameData` încarcă și validează totul la pornire
  (`scripts/core/data_validator.gd`: scheme, câmpuri obligatorii, id-uri, referințe între fișiere).
  Erorile apar ca „`data/<fișier> [<id>]: <problemă>`” pe ecranul meniului, fără crash.
  Când adaugi un câmp nou în JSON, adaugă-l și în schema din `data_validator.gd` (altfel apare „unknown field”).
- **Două limbi:** fiecare text din JSON e `{"ro": "...", "en": "..."}`. Implicit româna; se schimbă din Setări
  și se salvează. **Niciun text afișat nu e scris în cod** — totul trece prin `Loc`:
  `Loc.t("cheie", {"n": 3})` pentru `ui_text.json`, `Loc.text(obiect_loc)` pentru restul.
  (Excepție: mesajele de diagnostic pentru dezvoltator — erori de date, `push_error` — sunt în engleză.)
- **Pixel art:** bază 640×360, stretch `viewport`, aspect `keep`, scale `integer`, filtru `Nearest`, fereastră 1280×720.
- **Placeholder-uri automate** (se implementează în Etapa 2, odată cu primele personaje pe ecran): codul caută `art/<categorie>/<id>.png`; dacă lipsește, desenează un dreptunghi
  colorat (culoarea din `gods.json` → `color`; runele au culoarea lor din `runes.json`) cu inițiala și numele.
  Mărimi: vezi `art/README.md` (inclusiv `art/runes/`, 32×32).
- Fontul: deocamdată cel implicit; fontul pixel (OFL, cu ă â î ș ț) se alege în Etapa 6.

## Autoload-uri (ordinea contează)
1. `GameData` — `scripts/autoload/game_data.gd` — date din `data/`, `errors`.
2. `SaveManager` — `scripts/autoload/save_manager.gd` — `user://save.json` (nume, Amintiri, deblocări,
   **Cuvinte descoperite (Cartea de rune)**, încercări, cea mai bună probă, setări).
3. `Loc` — `scripts/autoload/loc.gd` — limba curentă, semnalul `language_changed`.
4. `RunState` — `scripts/autoload/run_state.gd` — partida în curs (nu se salvează în v1).

## Verificare după fiecare etapă (nu raporta etapa gata dacă sunt erori)
```bash
godot --headless --editor --quit          # prima dată pe un clone nou: importă proiectul (.godot/)
godot --headless --path . --quit          # prinde erorile de parsare
godot --headless --script tests/run_tests.gd   # testele logice; cod de ieșire 0 = ok
```
Teste noi: fișier `tests/test_<ceva>.gd` care `extends "res://tests/test_case.gd"`, metode `test_*`,
adăugat în lista `TEST_FILES` din `tests/run_tests.gd`.

## Structura
```
data/        gods, cards, enemies, blessings, runes, words, trials, events, dialogs, ui_text (.json)
art/         characters/ enemies/ gods/ portraits/ cards/ blessings/ runes/ backgrounds/ ui/
scenes/      câte o scenă .tscn pe ecran (main_menu, hub, parent_select, trial_map, combat, reward, rest,
             event, dialog, result, deck_view, rune_book, evening_class, settings)
scripts/     autoload/, core/ (validare date), combat/ (combat_state, card_effects, enemy_ai,
             statuses, rune_circle), ui/
tests/       run_tests.gd, test_case.gd, test_*.gd
docs/        UNIVERS.md, DESIGN.md
```

## Etapele
| # | Etapa | Stare |
|---|---|---|
| 1 | Scheletul: proiect, foldere, autoload-uri, JSON + validare, meniu, setări cu limba, docs | făcută pe v1; de adaptat la v2 (runes/words) |
| 2 | Lupta: CombatState, efecte, stări, AI cu intenții, **Cercul runic + 6 rune + Cuvinte (descoperire la ½ putere)**, ecran de luptă; Varr vs 2 Manechine; teste (inclusiv recunoașterea Cuvintelor) | — |
| 3 | Examenul: alegere părinte, harta probei, recompense, Odihnă, 3 probe + examinatori, Picat/Victorie, pachet | — |
| 4 | Bucla și Amintirile: hub, Aeva, deblocări, salvare, binecuvântări, numele jucătorului, **Cartea de rune permanentă, Cursul de seară al Maestrei Ilinca** | — |
| 5 | Povestea: rivali, evenimente, dialoguri cu portrete, intro (4–5 cadre: Coborârea, runele oamenilor, orașul, convocarea), final | — |
| 6 | Șlefuire și export: efecte, font pixel, balans + simulare, export Linux/Windows/Web | — |
