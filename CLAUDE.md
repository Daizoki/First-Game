# CLAUDE.md — reguli pentru „Examenul de Moștenire” (Universul „Coborârea”, Jocul 1)

> Versiunea de design: **v4 — rune în stil Balatro + Vrăji + stil desenat.** Roguelike de construit scoruri: un Săculeț
> cu pietre de rune (cele 24 de rune reale ale Futharkului vechi), Cuvinte rostite, scor = Putere × Rezonanță, plus
> **Vrăji** (combinații secrete de 2–3 rune cu efecte unice, ghicibile din sensul runelor).
> Motto: „Puterea o moștenești. Runele le înveți.”

Citește asta la începutul fiecărei sesiuni. Design: `docs/DESIGN.md`. Lume și personaje: `docs/UNIVERS.md`.
Artă: `docs/ARTA.md`.

> **Starea codului:** Etapele 1 și 2 sunt făcute pe v4. Etapa 2: o rundă de antrenament jucabilă (Joacă din meniu),
> săculețul de 48, Cuvintele, Putere × Rezonanță animat, cele 24 de Glasuri în date, primele 8 Vrăji cu animația de
> descoperire, simulatorul. **Etapa 2½ (instruirea, `docs/INSTRUIRE.md`, rezumat în `docs/DESIGN.md` 3.17) e făcută,
> pașii A–D** — EventBus, stratul de instruire (lumină, bulă, săgeată), intro + Lecțiile 1–5 în `data/tutorial.json`,
> mâini fixe, blocarea acțiunilor, numele jucătorului, pauza, Setările, fișa pietrei, fișa cercului, Cartea Cuvintelor
> (buton + tasta C), Cartea de rune (din pauză), indiciile contextuale (`data/hints.json`). Așteaptă testul final al
> lui Relax. Verificat cu Godot 4.7.2: 91 de teste trec (inclusiv parcurgerea fiecărei lecții).

## Cum lucrăm
- Utilizatorul e **Relax** (18 ani, Chișinău; desenează, TikTok/YouTube). **Scrie-i în română.**
  Codul, numele de fișiere și comentariile din cod sunt în **engleză**.
- **Claude scrie tot codul. Relax desenează arta, testează și ia deciziile de design.**
- Lucrăm pe **etape** (vezi mai jos). După fiecare etapă: te oprești și spui scurt
  1) ce ai făcut; 2) cum testează (ce apasă, ce ar trebui să vadă); 3) ce ai decis singur și ar putea vrea altfel.
  Apoi commit în git. **Nu treci la etapa următoare fără OK-ul lui.**
- Dacă ceva e neclar sau se contrazice: **întreabă înainte să construiești**.
- Lucruri complete care rulează, nu bucăți de cod de lipit.
- **Nu descărca și nu instala nimic** (fonturi, pluginuri, pachete) fără să spui întâi ce, de unde și de ce.
- Zeii și personajele sunt originale (fără zei din mitologii reale ca personaje, fără personaje din alte opere).
  **Runele sunt cele 24 de rune istorice reale (Futharkul vechi)**, cu sensurile lor reale — nu inventa sensuri
  „istorice”. Evită simbolurile din `docs/ARTA.md` (Valknut, Othala cu aripi, Sowilo dublu, soarele negru).
- **Balatro e doar inspirație pentru mecanică.** Nu copia numele (Joker, Chips, Mult, Blind, Ante, Tarot, Planet etc.),
  interfața, aranjarea ecranului, textele, valorile numerice sau efectele vizuale caracteristice.

## Termenii noștri (folosește-i peste tot, inclusiv în cod)
| Ideea | La noi | id în cod |
|---|---|---|
| pachetul de cărți | **Săculețul** cu pietre de rune | `bag` |
| o carte | o **piatră** (cu o rună pe ea) | `stone` |
| culoarea (suit) | **Neamul** (3 neamuri) | `kin` |
| valoarea cărții | **Poziția** runei în neamul ei (1–8) | `position` |
| mâna de poker jucată | **Cuvântul** rostit | `word` |
| a juca / a arunca | **a Rosti** / **a Schimba** | `cast` / `swap` |
| baza × multiplicatorul | **Putere × Rezonanță** | `power` × `res` |
| jokerii | **Talismanele** | `talisman` |
| cărțile care cresc nivelul unei mâini | **Lecțiile** | `lesson` |
| cărțile care modifică alte cărți | **Gravurile** | `engraving` |
| magazinul | **Piața de noapte** | `shop` |
| nivelurile de dificultate | **Probele** examenului | `trial` |
| rundele | **Întrebarea mică / mare**, **Examinatorul** | `small` / `big` / `examiner` |
| banii | **Monede** | `money` |
| *(nu există la Balatro)* | **Vrăjile** (combinații secrete de rune) | `spell` |

## Reguli tehnice
- **Godot 4.x (Relax are 4.7.2 pe Windows), GDScript.** Renderer **Compatibility** de la început (exportul Web). Strălucirea și
  fundalul animat: shadere proprii pe `CanvasItem` sau sprite-uri aditive, **nu** glow din `WorldEnvironment`.
- **Tipuri statice peste tot.** Fiecare funcție are tip de return explicit; funcțiile care pot întoarce `null` sau
  tipuri mixte folosesc `-> Variant`. Variabilele de buclă au tip (`for id: String in ...`).
  Avertismentul `untyped_declaration` e pornit în `project.godot`.
- **Fără scripturi uriașe.** Fiecare ecran = o scenă `.tscn` cu scriptul ei mic. Arbori de noduri simpli.
  Nodurile folosite din cod au `unique_name_in_owner` și se iau cu `%Nume`.
- **Logica separată de UI.** Săculețul, recunoașterea Cuvintelor, scorul și efectele stau în clase din
  `scripts/core/` care rulează fără ecran (testabile și simulabile).
- **RNG cu seed:** fiecare examen are un seed (afișat în meniul de pauză). Toată aleatoritatea trece prin RNG-ul
  examenului, ca o partidă să se poată repeta exact.
- **Scoruri mari:** `float`, formatate frumos („12 840”, „1,2 mil.”).
- **Nu folosim `class_name`** în scripturile de logică: testele le încarcă cu `preload(...)`, ca să meargă și pe un
  repo proaspăt clonat. Autoload-urile nu au voie să aibă `class_name`.
- **Conținutul stă în JSON în `data/`**: rune, Cuvinte, Talismane, Lecții, Gravuri, examinatori, probe, părinți,
  prețuri, dialoguri, texte UI. `GameData` încarcă și validează totul (`scripts/core/data_validator.gd`). Erorile apar
  ca „`data/<fișier> [<id>]: <problemă>`” pe ecranul meniului, fără crash. Câmp nou în JSON → adaugă-l și în schemă.
- **Efecte în date:** declanșator (`on_score`, `on_held`, `on_cast`, `in_word`, `on_round_end_held`, `passive`) +
  condiții (`first_in_word`, `first_cast`, `last_cast`, `chance`, `once_per_round`) + acțiuni (`add_power`, `add_res`,
  `mul_res`, `add_money`, `add_swap`, `retrigger`, `grow_power`, `base_power_mult`, `word_level_bonus`,
  `add_money_at_round_end`, `special`). Lista scurtă de handleri speciali: `kenaz_peek`, `gebo_copy_left`,
  `algiz_ignore_rule`, `berkanan_copy`, `laguz_wild`. Valorile permise sunt în `ENUMS` din `data_validator.gd`.
- **Scorul** (`scripts/core/scorer.gd`) produce o listă de evenimente pe care `scoring_player.gd` le animă. Logica nu
  știe nimic de ecran.
- **Două limbi:** fiecare text din JSON e `{"ro": "...", "en": "..."}`. Implicit româna; se schimbă din Setări și se
  salvează. **Niciun text afișat nu e scris în cod** — totul prin `Loc`: `Loc.t("cheie", {"n": 3})` pentru
  `ui_text.json`, `Loc.text(obiect_loc)` pentru restul. (Excepție: diagnostice pentru dezvoltator, în engleză.)
- **Grafică desenată:** bază **1920×1080**, stretch `canvas_items`, aspect `expand`, filtru **Linear** + mipmaps.
- **Runele se desenează din cod** din segmentele din `runes.json` (forme corecte ale Futharkului vechi), cu linii
  groase și strălucire în culoarea Neamului. `art/runes/<id>.png` le înlocuiește dacă există.
- **Placeholder-uri:** dacă lipsește `art/<categorie>/<id>.png`, ramă închisă + nume + iconiță simplă; pietrele sunt o
  formă de piatră procedurală cu runa strălucind. Dimensiuni: `docs/ARTA.md`.
- **Paleta** (Noapte `#0A0C18`, Os `#E9E3D2`, Jar `#FF6A3D`, Neamurile etc.) e în `docs/ARTA.md`; folosește-o peste tot.
- **Tema UI:** `scenes/theme/main_theme.tres` — fontul Grenze, butoane și panouri în paletă. Variante de etichetă:
  `TitleLabel` (Grenze Gotisch, culoarea Lumânare) și `SecondaryLabel` (text secundar). Folosește-le în loc de culori
  puse de mână.
- **Fonturi:** Grenze Gotisch + Grenze sunt în `fonts/` (descărcate cu OK-ul lui Relax, licențe OFL lângă ele).
- **Instruirea** (`docs/INSTRUIRE.md`, `data/tutorial.json`): logica pașilor în `scripts/core/tutorial_flow.gd`
  (testabilă), ecranul în `scripts/ui/tutorial.gd` + `tutorial_overlay.gd` (shader `shaders/spotlight.gdshader`).
  Elementele pe care lumina le poate găsi au metadata `tutorial_id` (lista în `ENUMS["ui_id"]`); pietrele sunt
  `stone:<rune_id>`. Ecranul de rundă se configurează prin `config` (mână fixă, țintă, fundal…) și nu știe de
  instruire. `scenes/round.tscn` se generează cu `python3 tools/gen_round.py`.
- **Indiciile** (`data/hints.json`): `trigger` (eveniment din `ENUMS["hint_event"]`) sau `follows`; o singură dată,
  pe rând, oprite în instruire și din Setări. Cele pentru elemente neconstruite au `"enabled": false`.
- **În fiecare etapă viitoare** (detalii în `docs/DESIGN.md` 3.17): pornești indiciile din `hints.json` pentru
  elementele pe care le construiești (`"enabled": true`, emiți evenimentul lor, test în `tests/test_hints.gd`) și
  adaugi **fișă la mouse** pentru orice element nou pe care îl vede jucătorul (Talismane, consumabile, regula
  Examinatorului, marfa din Piață…). Elementele noi pe care le poate arăta instruirea primesc `tutorial_id`.
- **Vrăjile** (`data/spells.json`): 2–3 rune, ordinea nu contează, verificate pe toate pietrele rostite; Laguz nu e
  joker pentru Vrăji; moment `before_score` / `after_score` / `next_cast`; ascunse până la prima rostire.

## Autoload-uri (ordinea contează)
1. `GameData` — `scripts/autoload/game_data.gd` — date din `data/`, `errors`.
2. `SaveManager` — `scripts/autoload/save_manager.gd` — `user://save.json` (nume, Amintiri, deblocări, colecție,
   descoperiri, statistici, setări, **examenul în curs salvat după fiecare rundă**).
3. `Loc` — `scripts/autoload/loc.gd` — limba curentă, semnalul `language_changed`.
4. `RunState` — `scripts/autoload/run_state.gd` — examenul în curs.
5. `EventBus` — `scripts/autoload/event_bus.gd` — evenimentele jocului (`round_started`/`closed`, `hand_changed`,
   `stone_hovered`, `selection_changed`, `cast`, `swap`, `scoring_phase`, `spell_discovered`, `round_won`/`lost`,
   `book_opened`/`closed` …) și „poarta” de acțiuni (`allowed_actions`, `selectable_runes`). Jocul doar emite și
   verifică poarta; instruirea și indiciile doar ascultă.
6. `Hints` — `scripts/autoload/hints.gd` — indiciile contextuale: ascultă EventBus-ul, întreabă
   `scripts/core/hint_rules.gd` (testabil) ce indiciu e de arătat și afișează bula (`scripts/ui/hint_bubble.gd`).
   Evenimentele etapelor viitoare (`shop_opened`, `talisman_bought` …) ajung la el prin `Hints.fire(...)` sau semnale noi.

## Verificare după fiecare etapă (nu raporta etapa gata dacă sunt erori)
În sesiunile din cloud, Godot 4.7.2 pentru Linux se poate descărca în scratchpad (Relax a fost de acord); capturile de
ecran se fac cu `xvfb-run` + `--rendering-driver opengl3`. Pe calculatorul lui Relax, Godot e pe Windows.
```bash
godot --headless --editor --quit          # prima dată pe un clone nou: importă proiectul (.godot/)
godot --headless --path . --quit          # prinde erorile de parsare
godot --headless --script tests/run_tests.gd   # testele logice; cod de ieșire 0 = ok
godot --headless --script tests/simulate.gd    # simulatorul (din Etapa 2): frecvența Cuvintelor, apoi balans
```
Teste noi: fișier `tests/test_<ceva>.gd` care `extends "res://tests/test_case.gd"`, metode `test_*`,
adăugat în lista `TEST_FILES` din `tests/run_tests.gd`.

## Structura (țintă v3)
```
docs/        UNIVERS.md, DESIGN.md, ARTA.md, INSTRUIRE.md, TRADUCERI.md (generat)
data/        kins, runes, words, spells, characters, rules, dialogs, tutorial, hints, ui_text (.json) — există deja
             talismans, lessons, engravings, examiners, trials, parents, economy — vin în etapele lor
fonts/       Grenze, Grenze Gotisch + licențe OFL
art/         stones/ runes/ talismans/ lessons/ engravings/ examiners/ portraits/ backgrounds/ ui/
scenes/      boot, name_entry, main_menu, rune_check, settings, round, spell_reveal, tutorial, tutorial_overlay,
             theme/main_theme.tres — există deja
             morning (hub), parent_select, trial_select, shop, pack_open, result, rune_book, collection,
             intro, dialog — vin în etapele lor
scripts/     autoload/ (game_data, run_state, save_manager, loc, event_bus, hints)
             core/ (stone, bag, word_detector, spell_detector, scorer, round_state, tutorial_flow, hint_rules,
                    data_validator;
                    examiner_rules, shop_logic vin în Etapa 3)
             ui/ (ecrane + componente: rune_glyph, stone_view, hand_view, rune_circle, candle_row, portrait,
                  talisman_string, night_backdrop, classroom_backdrop, float_layer, scoring_player, spell_reveal,
                  stone_card, word_card, word_book, rune_book, mini_stone, hint_bubble, round_screen, tutorial,
                  tutorial_overlay, boot, name_entry)
shaders/     spotlight.gdshader (lumina instruirii)
tools/       gen_round.py (generează scenes/round.tscn), export_translations.py (generează docs/TRADUCERI.md)
tests/       run_tests.gd, test_case.gd, fixtures.gd, test_data/loc/save/words/scoring/tutorial/hints.gd, simulate.gd
```

## Etapele
| # | Etapa | Stare |
|---|---|---|
| 1 | Scheletul: Compatibility + 1920×1080, foldere, autoload-uri, JSON + validare, meniu, setări cu limba, docs, **scena de verificare a celor 24 de rune desenate din cod** | făcută |
| 2 | Miezul — o rundă: săculețul de 48, mâna de 8, Rostire/Schimbare, sortare/rearanjare, recunoașterea Cuvintelor (cu Laguz și ordinea), Putere × Rezonanță animat, cele 24 de Glasuri, rundă de test; teste; simulatorul + tabelul de probabilități; **primele 8 Vrăji** (detectare, efecte, descoperire, animație simplă); ecranul de rundă așezat ca în 3.16 | făcută (așteaptă testul lui Relax) |
| 2½ | Instruirea „Seara dinaintea examenului” (`docs/INSTRUIRE.md`): A sistemul, B lecțiile 1–5, C ajutorul permanent + indiciile, D documentele | făcută (așteaptă testul final al lui Relax) |
| 3 | Examenul complet: 8 Probe × 3 runde, Examinatorii, Monede, Piața de noapte, primele 15 Talismane, Lecții, Gravuri, materiale, legături runice, Săculețe, Picat / Examen trecut | — |
| 4 | Bucla Aevei: Dimineața, alegerea părintelui, Amintiri, deblocări, salvare (inclusiv examenul în curs), Cartea de rune (cu Vrăjile descoperite), Colecția, numele jucătorului, Paginile rupte în Piață | — |
| 5 | Povestea și conținutul: intro, replici, final, restul Talismanelor (~30), restul Vrăjilor (30–40, cu blestemele), Cuvintele vechi (ALU, LAÞU, AUJA), balans cu simulatorul | — |
| 6 | Șlefuire și export: efectele din 3.13 și 3.16 (linii care fierb, granulație, animația completă a Vrăjilor), fonturile Grenze (cu OK), arta lui Relax, ultimul balans, export Linux/Windows/Web | — |
