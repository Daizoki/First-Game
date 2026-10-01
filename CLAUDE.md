# CLAUDE.md — reguli pentru „Examenul de Moștenire” (Universul „Coborârea”, Jocul 1)

> Versiunea de design: **v3 — rune în stil Balatro, grafică desenată.** Roguelike de construit scoruri: un Săculeț cu
> pietre de rune (cele 24 de rune reale ale Futharkului vechi), Cuvinte rostite, scor = Putere × Rezonanță.
> Motto: „Puterea o moștenești. Runele le înveți.”

Citește asta la începutul fiecărei sesiuni. Design: `docs/DESIGN.md`. Lume și personaje: `docs/UNIVERS.md`.
Artă: `docs/ARTA.md`.

> **Starea codului:** codul din repo e încă scheletul din v2 (lupte, cercul runic). Migrarea la v3 se face **doar
> după OK-ul lui Relax** (lista „ce păstrăm” e în PR-ul Daizoki/First-Game#1).

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

## Reguli tehnice
- **Godot 4.x (Relax are 4.7), GDScript.** Renderer **Compatibility** de la început (exportul Web). Strălucirea și
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
- **Efecte în date:** declanșator (`on_score`, `on_held`, `on_round_end`, `on_cast`, `passive`) + condiții + acțiuni
  (`add_power`, `add_res`, `mul_res`, `add_money`, `retrigger`, `add_discard`…). Efecte prea speciale → handler numit
  în cod (`"special": "gebo_copy_left"`), ținuți într-o listă scurtă.
- **Două limbi:** fiecare text din JSON e `{"ro": "...", "en": "..."}`. Implicit româna; se schimbă din Setări și se
  salvează. **Niciun text afișat nu e scris în cod** — totul prin `Loc`: `Loc.t("cheie", {"n": 3})` pentru
  `ui_text.json`, `Loc.text(obiect_loc)` pentru restul. (Excepție: diagnostice pentru dezvoltator, în engleză.)
- **Grafică desenată:** bază **1920×1080**, stretch `canvas_items`, aspect `expand`, filtru **Linear** + mipmaps.
- **Runele se desenează din cod** din segmentele din `runes.json` (forme corecte ale Futharkului vechi), cu linii
  groase și strălucire în culoarea Neamului. `art/runes/<id>.png` le înlocuiește dacă există.
- **Placeholder-uri:** dacă lipsește `art/<categorie>/<id>.png`, ramă închisă + nume + iconiță simplă; pietrele sunt o
  formă de piatră procedurală cu runa strălucind. Dimensiuni: `docs/ARTA.md`.
- Fontul: deocamdată cel implicit; un font desenat/medieval (OFL, **cu ă â î ș ț**) se alege în Etapa 6.

## Autoload-uri (ordinea contează)
1. `GameData` — `scripts/autoload/game_data.gd` — date din `data/`, `errors`.
2. `SaveManager` — `scripts/autoload/save_manager.gd` — `user://save.json` (nume, Amintiri, deblocări, colecție,
   descoperiri, statistici, setări, **examenul în curs salvat după fiecare rundă**).
3. `Loc` — `scripts/autoload/loc.gd` — limba curentă, semnalul `language_changed`.
4. `RunState` — `scripts/autoload/run_state.gd` — examenul în curs.

## Verificare după fiecare etapă (nu raporta etapa gata dacă sunt erori)
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
docs/        UNIVERS.md, DESIGN.md, ARTA.md
data/        runes, words, talismans, lessons, engravings, examiners, trials, parents, economy,
             dialogs, ui_text (.json)
art/         stones/ runes/ talismans/ lessons/ engravings/ examiners/ portraits/ backgrounds/ ui/
scenes/      main_menu, morning (hub), parent_select, trial_select, round, scoring_popup, shop, pack_open,
             result, rune_book, collection, settings, intro, dialog
scripts/     autoload/ (game_data, run_state, save_manager, loc)
             core/ (bag, stone, word_detector, scorer, effects, examiner_rules, shop_logic, data_validator)
             ui/
tests/       run_tests.gd, test_case.gd, test_words.gd, test_scoring.gd, simulate.gd
```

## Etapele
| # | Etapa | Stare |
|---|---|---|
| 1 | Scheletul: Compatibility + 1920×1080, foldere, autoload-uri, JSON + validare, meniu, setări cu limba, docs, **scena de verificare a celor 24 de rune desenate din cod** | făcută pe v2; de migrat la v3 după OK |
| 2 | Miezul — o rundă: săculețul de 48, mâna de 8, Rostire/Schimbare, sortare/rearanjare, recunoașterea Cuvintelor (cu Laguz și ordinea), Putere × Rezonanță animat, cele 24 de Glasuri, rundă de test; teste; simulatorul + tabelul de probabilități | — |
| 3 | Examenul complet: 8 Probe × 3 runde, Examinatorii, Monede, Piața de noapte, primele 15 Talismane, Lecții, Gravuri, materiale, legături runice, Săculețe, Picat / Examen trecut | — |
| 4 | Bucla Aevei: Dimineața, alegerea părintelui, Amintiri, deblocări, salvare (inclusiv examenul în curs), Cartea de rune, Colecția, numele jucătorului | — |
| 5 | Povestea și conținutul: intro, replici, final, restul Talismanelor (~30), Cuvintele vechi (ALU, LAÞU, AUJA), balans cu simulatorul | — |
| 6 | Șlefuire și export: efectele din 3.13, fontul, arta lui Relax, ultimul balans, export Linux/Windows/Web | — |
