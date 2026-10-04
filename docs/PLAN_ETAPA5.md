# Etapa 5 — Pasul A: auditul și planul de migrare

> Pasul A nu schimbă cod. Documentul spune ce rămâne, ce se schimbă și ce se șterge, cum se migrează salvarea și ce
> riscuri sunt. Mai conține tabelele cerute înainte de implementare: Tabla Vrăjilor nouă, monștrii, Talismanele,
> părinții și indiciile. Specificația lui Relax e în `docs/PROMPT_ETAPA5.md`. **Tot ce scrie „propun” așteaptă OK-ul
> lui Relax.**

---

## 1. Întrebări înainte de pasul B

Răspunsurile acestea schimbă ce construiesc. Pentru fiecare am pus și ce aș face eu.

1. **Bossul final și Cercul 8.** Balaurul are deja 3 bare de viață (câte una pe cap), adică 3 faze. Cercul 8 spune
   că „bossul final are 3 faze”.
   **Propun:** în Cercurile 1–7 capetele cad unul după altul (3 bare). În Cercul 8 cele 3 capete stau deodată pe
   ecran: fiecare are bara lui și slăbiciunile lui, iar tu alegi pe care îl lovești. Ca un singur boss, dar cu 3
   ținte vii.
2. **Țintele „în Dușman” (Tiwaz).** Vechile efecte ale rândului erau toate „ținta scade cu X%”, adică tot daună.
   **Propun:** rândul Tiwaz rămâne „atacul curat”: 100% daună + natura dublă, fără alt efect. Cele 8 vrăji se
   deosebesc prin natura Elementului (tabelul din secțiunea 6).
3. **Ce se pierde din salvare.**
   **Propun:** se resetează tot în afară de nume și setări. Și Examenul trebuie trecut din nou, fiindcă e altul.
   Lista completă e în secțiunea 13. Alternativa: păstrăm Vrăjile descoperite (id-urile rămân aceleași), dar
   efectele lor se schimbă, așa că o descoperire veche ar arăta un efect pe care jucătorul nu l-a văzut.
4. **Bonusul de Neam cu cele 6 rune de start.** Cele 6 rune sunt în Neamuri diferite: Kenaz și Fehu în Neamul lui
   Fehu, Isaz și Eihwaz în al lui Hagalaz, Ehwaz și Tiwaz în al lui Tiwaz. La început, bonusul se poate lua doar cu
   Kenaz + Fehu (de exemplu Kenaz → Fehu → Kenaz). Lecția 2 doar îl arată, deci merge.
   **Propun:** lăsăm așa. Bonusul devine important când deblochezi mai multe rune.
5. **Imaginea `lupta.png` lipsește.** Mi-ai trimis 5 imagini, fără cea a luptei. Am pus în `docs/referinte/`:
   `meniu`, `sfarsit_runda`, `piata`, `sac`, `compendiu`. Nu blochează nimic până la pasul G.
6. **Regula din `CLAUDE.md`: „Runele sunt cele 24 de rune istorice reale”.** Rarele sunt tot rune reale (futhorc),
   dar Runele primordiale sunt inventate.
   **Propun** o regulă nouă: rune istorice cu sensuri reale (Futharkul vechi + futhorc-ul anglo-saxon) + 3 glife
   originale, marcate în joc ca „primordiale, nu istorice”.
7. **Imaginile de referință au un nod celtic (triquetra)** pe Talisman, iar secțiunea 10.1 cere fără noduri celtice.
   Îl înlocuiesc cu motive de ie, cum spune 10.1. Doar confirm.
8. **Git, înainte de marea schimbare.** Pe `main` e încă versiunea 0.3.0. Etapele 3 și 4 (v0.5.0) sunt doar pe
   ramura de lucru.
   **Propun:** fac un PR cu Etapele 3–4 și îl unim în `main`, cu eticheta `v0.5.0`. Așa avem mereu versiunea
   veche, care merge, dacă vrem să ne uităm înapoi. Etapa 5 continuă apoi pe ramură.

---

## 2. Termenii noi (în română și în cod)

| Ideea | La noi | id în cod |
|---|---|---|
| un drum întreg (run) | **Drumul** | `journey` |
| nivelul de dificultate | **Cercul** | `circle` |
| o zonă a Drumului | **Ținutul** | `realm` |
| o luptă | **lupta** | `fight` |
| inamicul | **monstrul** / **Stăpânul Ținutului** | `monster` / `boss` |
| viața jucătorului | **inimile** | `hearts` |
| pierderea de inimă oprită | **Scutul de inimă** | `heart_shield` |
| scorul | **dauna** | `damage` |
| ×2 / ×0,5 / ×0 | **slăbiciune / rezistență / imunitate** | `weak` / `resist` / `immune` |
| efectul propriu al monstrului | **trăsătura** | `trait` |
| regula bossului | **regula** | `rule` |
| efectul propriu al Elementului | **natura** | `nature` |
| îmbunătățire pe tot Drumul | **Binecuvântarea** | `blessing` |
| raritatea pietrei | comună / rară / extra rară / ultrarară | `common` / `rare` / `epic` / `primal` |
| piatra cu două roluri | **Legătura străveche** | `ancient_bind` |
| hub-ul | **Orașul Pragului** | `hub` |
| ecranul de după luptă | **Sfârșit de luptă** | `fight_end` |
| enciclopedia | **Compendiul** | `compendium` |

Rămân: Săculețul (`bag`), piatra (`stone`), Neamul (`kin`), Rostire/Schimbare (`cast` / `swap`), Putere × Rezonanță
(`power` × `res`), Talismanele, Lecțiile, Gravurile, Piața de noapte, Monedele, Vrăjile, Pergamentul. Dispar:
Cuvântul (`word`), Poziția (`position`), Probele (`trial`), Întrebarea mică/mare.

**Titlul jocului:** constanta `GAME_TITLE`, citită dintr-un singur loc (`data/ui_text.json`, cheia `game_title`,
plus o constantă în `scripts/autoload/game_data.gd`). Rămâne „Examenul de Moștenire”.

---

## 3. Harta fișierelor

### 3.1 Datele (`data/`)

| Fișier | Ce se întâmplă |
|---|---|
| `kins.json` | **rămâne** (3 Neamuri; semnul monedă / fulg / stea) |
| `runes.json` | **se schimbă:** pleacă `position`, `base_power`, `voice`, `effects`; vin `rarity`, `unlock`, `nature` (pentru Elemente) și rarele (12), Legăturile străvechi (6), primordialele (3) |
| `spells_base.json` | **se schimbă:** cele 64 de vrăji primesc efectele de luptă (secțiunea 6); numele și versurile rămân |
| `spell_actions.json` | **se schimbă:** cele 8 Acțiuni cu efectele de luptă (5.4) |
| `elements.json` | **nou:** Putere, Rezonanță, creșterea pe nivel, natura |
| `targets.json` | **nou:** partea de daună a fiecărei Ținte și ce face natura dublă |
| `words.json` | **dispare.** Cuvintele vechi ALU, LAÞU, AUJA trec în `secrets.json` (secțiunea 9.5) |
| `trials.json` | **dispare** → `realms.json` (8 Ținuturi: fundal, monștri, boss, viața de bază) |
| `examiners.json` | **dispare** → `monsters.json` (monștri, boși, Kaldor de Examen). Regulile vechi devin reguli de boss (secțiunea 10) |
| `talismans.json` | **se rescrie** (secțiunea 8) |
| `lessons.json` | **se rescrie:** câte o Lecție pe Element (8) |
| `engravings.json` | **se schimbă:** materialele lucrează în vrăji, nu în scor (secțiunea 9.1) |
| `blessings.json` | **nou:** Binecuvântările (secțiunea 11) |
| `circles.json` | **nou:** Cercurile 1–8 (penalizare, avantaj, însemn) |
| `parents.json` | **se schimbă:** fiecare părinte își face săculețul lui (secțiunea 12) |
| `economy.json`, `rules.json` | **se schimbă:** prețuri mici, inimi, limite de siguranță, Amintiri |
| `tutorial.json` | **se rescrie:** 3 lecții |
| `hints.json` | **se schimbă:** pleacă indiciile Cuvintelor și ale Probelor, vin 7 noi (secțiunea 14) |
| `dialogs.json`, `characters.json` | **rămân și cresc** (replicile Aevei, monștrii ca personaje) |
| `ui_text.json` | **se schimbă mult** (toate textele de luptă și ecranele noi) |

### 3.2 Logica (`scripts/core/`)

| Fișier | Ce se întâmplă |
|---|---|
| `stone.gd` | **se schimbă:** pleacă poziția și Puterea de bază; vin raritatea, rolurile (unul sau două), `bonus_power` (pietre călite, adaugă Putere vrăjii), materialul |
| `bag.gd` | **rămâne** (săculețul de start din `parents.json`) |
| `sentence_parser.gd` | **se schimbă:** până la 2 propoziții pe Rostire; pietre cu două roluri; rolul ales pentru primordiale; motivul pentru „ordine greșită” |
| `spell_resolver.gd` | **se rescrie** pe daună: planul vrăjii (Acțiunile) rămâne, operațiile devin de luptă |
| `scorer.gd` | **dispare** → `damage.gd`: formula, slăbiciunile, natura, lanțul, Neamul; produce lista de evenimente pentru animație, ca acum |
| `word_detector.gd` | **dispare** |
| `round_state.gd` | **se transformă în** `fight_state.gd`: mâna, Rostirile, Schimbările, monstrul, trăsătura, regula, previzualizarea cu „Ucide!” |
| `exam_state.gd` | **se transformă în** `journey_state.gd`: Ținutul, lupta, inimile, Monedele, nivelurile Elementelor, Talismanele, Cercul, salvarea |
| `monster.gd` | **nou:** viața, slăbiciunile, Scutul, Arsura, Regenerarea, fazele (Balaurul) |
| `talisman_rules.gd` | **se rescrie** pe felurile noi de Talismane |
| `shop_logic.gd` | **se schimbă:** 5 obiecte, Blochează, Rune, Binecuvântări, prețuri după Cerc |
| `rewards.gd` | **nou:** recompensa 1 din 3 de la Sfârșit de luptă |
| `progress.gd` | **se schimbă:** runele deblocate, Cercurile deschise, Amintirile; pleacă nivelurile Cuvintelor |
| `tutorial_flow.gd`, `hint_rules.gd` | **rămân** (motorul e bun; se schimbă doar datele) |
| `data_validator.gd` | **se schimbă:** schemele noi |

### 3.3 Ecranele (`scripts/ui/`, `scenes/`)

| Acum | Devine |
|---|---|
| `round_screen.gd` + `scenes/round.tscn` + `tools/gen_round.py` | **Lupta** (`fight_screen.gd`, `scenes/fight.tscn`), rescrisă după 10.6 |
| `exam_screen.gd` + `scenes/exam.tscn` | **Drumul** (`journey_screen.gd`): lupta → Sfârșit de luptă → Piața → lupta următoare |
| `shop_screen.gd` | **Piața** nouă (5 obiecte, detalii în dreapta, Blochează) |
| — | **Sfârșit de luptă** (`fight_end.gd`), **Talismane și Sac** (`satchel.gd`), **UIKit** (`scenes/ui_kit.tscn`) |
| `morning.gd`, `morning_backdrop.gd`, `memories_shop.gd`, `parent_select.gd` | **Hub-ul** (Orașul Pragului): alegerea Cercului și a părintelui, Cursul de seară (rune pe Amintiri), Aeva |
| `rune_book.gd`, `collection.gd`, `word_book.gd` | **Compendiul** (Rune, Vrăji, Talismane, Monștri, Cercuri); Cartea Cuvintelor dispare |
| `main_menu.gd` | meniul nou (Joacă, Continuă, Compendiu, Setări, Ieșire) cu portalul de rune |
| `scoring_player.gd` | **animația daunei** (pietrele zboară, vraja lovește, bara cu „fantomă”) |
| `stone_view.gd`, `stone_card.gd`, `mini_stone.gd`, `role_sign.gd` | **se schimbă:** materialul după raritate, fără Poziție, semnul de Neam jos |
| `word_card.gd` | **dispare** (fișa cercului arată vraja și dauna) |
| `talisman_string.gd` | **se schimbă:** 5 locuri în ramă, nu pe sfoară (ca în imagini) |
| `night_backdrop.gd`, `classroom_backdrop.gd` | **rămân ca placeholder-e**, apoi fundalurile Ținuturilor |
| `hand_view`, `rune_circle`, `candle_row`, `sentence_bar`, `choice_panel`, `scroll_slot`, `spell_reveal`, `action_learned`, `float_layer`, `hint_bubble`, `tutorial*`, `portrait`, `settings`, `name_entry`, `boot` | **rămân**, cu stilul nou; Setările primesc mărimea textului |
| `rune_check.gd` | **rămâne** (scena de verificare a glifelor, cu rarele) |
| `time_rewind.gd` | **rămâne** (Aeva te întoarce în hub) |

### 3.4 Testele

| Acum | Devine |
|---|---|
| `test_words`, `test_scoring` | **dispar** → `test_damage` (formula, slăbiciuni, rezistențe, imunități, lanț, Neam, natura, limite) |
| `test_exam`, `test_parents` | → `test_journey` (Ținuturi, inimi, boss rănit, săculețul părinților, salvare) |
| `test_sentence`, `test_spells` | **se schimbă** (2 vrăji pe Rostire, pietre cu două roluri, efectele noi) |
| `test_talismans`, `test_consumables`, `test_shop`, `test_progress`, `test_hints`, `test_tutorial`, `test_data` | **se schimbă** pe datele noi |
| `test_loc`, `test_save` | **rămân** (+ migrarea salvării) |
| — | **noi:** `test_monsters` (trăsături, reguli, Balaurul), `test_runes` (deblocări, rare, Legături, primordiale), `test_circles` |
| `simulate.gd` | **se rescrie:** Drumuri pe Cercurile 1–4 (pasul I) |

### 3.5 Documentele
- `DESIGN.md`: v5 (se rescriu 3.1–3.17). Jurnalul de decizii rămâne, cu o intrare nouă.
- `GRAMATICA.md`: 2 vrăji pe Rostire, Neamul, efectele de luptă.
- `INSTRUIRE.md`: cele 3 lecții.
- `ARTA.md`: stilul nou, paleta, fonturile, dimensiunile.
- `UNIVERS.md`: lumea din afara orașului, creaturile.
- `ARTA_SURSE.md`: nou.
- `TRADUCERI.md`: generat ca acum.
- `CLAUDE.md`: regula priorității, termenii, structura. Scrisă deja la pasul A, fiindcă e doar document.

---

## 4. Arhitectura nouă, pe scurt

```
JourneyState (tot Drumul: Cerc, părinte, Ținut 0..7, lupta 0..2, inimi, Monede, nivelurile Elementelor,
              Talismane, consumabile, Binecuvântări, săculețul, carry al vrăjilor, rănile bossului)
   └─ new_fight() → FightState (o luptă: mâna, Rostiri, Schimbări, Monster, regula, previzualizarea)
         └─ cast(selecție) → SentenceParser (0–2 propoziții) → SpellResolver (planul + Acțiunile)
                              → Damage (formula) → evenimente pentru animație
   └─ finish_fight(state) → recompensa 1 din 3 / inimă pierdută / boss rănit → Piață → lupta următoare
```
- Ca acum, logica rulează fără ecran: testele și simulatorul o folosesc direct.
- EventBus, Hints, SaveManager, Loc și instruirea rămân. Primesc doar evenimente noi (`fight_won`,
  `heart_lost`, `weakness_hit`, `immunity_hit`, `boss_met`, `rare_rune_gained`, `circle_opened`…).

---

## 5. Formula și ordinea calculului

Pentru fiecare vrajă din Rostire:
1. **Putere** = Puterea Elementului la nivelul lui + `bonus_power` al pietrelor din vrajă + Talismanele (+Putere).
2. **Rezonanță** = Rezonanța Elementului + Spinul (+1 pe Acțiune) + Talismanele (+Rezonanță); apoi ×1,5 bonusul de
   Neam și ×Talismanele (×Rezonanță).
3. **Lovitura** = Putere × Rezonanță × multiplicatorul monstrului (×2 / ×0,5 / ×0; Apa ignoră ×0,5) × natura
   (Soarele contra nopții, Ziua pe Rostirile rămase) × partea Țintei.
4. **Acțiunile:** Ehwaz = 2 lovituri, Perthro ×3 sau ×0, Naudiz ×2,5, Berkanan +50% pe fiecare rostire anterioară,
   Raidho (ce depășește viața trece mai departe), Eihwaz / Jera / Gebo (mai târziu).
5. **Lanțul:** a doua vrajă din Rostire ×1,25.
6. **Scutul monstrului** scade din fiecare lovitură (Forța și Gār îl ignoră). Arsura, Regenerarea și restul vin
   după.
7. **Limitele:** cel mult 2 vrăji pe Rostire, cel mult +2 Rostiri pe luptă din efecte. O lovitură procentuală („X%
   din viață”) ia cel mult 50% din viața unui boss.

**Previzualizarea:** aceeași formulă, fără șanse. Perthro intră cu ×0 în dauna sigură și cu „până la ×3” în
estimare. „Ucide!” apare când dauna sigură ≥ viața rămasă.

---

## 6. Elementele și Tabla Vrăjilor nouă (cele 64)

### 6.1 Elementele

Valorile de bază sunt cele din prompt. La fiecare nivel (o Lecție) **propun** +50% din Puterea de bază și +1
Rezonanță; Forța primește +0,5 Rezonanță, ca să nu explodeze.

| Element | Niv. 1 | Niv. 2 | Niv. 3 | Natura | Natura dublă (cu Tiwaz) |
|---|---|---|---|---|---|
| Focul (Kenaz) | 18 × 2 = 36 | 27 × 3 = 81 | 36 × 4 = 144 | Arsură 3 pe Rostire, max. 3 straturi | Arsură 6 pe strat |
| Forța (Uruz) | 30 × 1 = 30 | 45 × 1,5 = 68 | 60 × 2 = 120 | ignoră Scutul | ignoră Scutul și îl sparge pentru toată lupta |
| Spinul (Thurisaz) | 10 × 2 | 15 × 3 | 20 × 4 | +1 Rezonanță pe Acțiune | +2 Rezonanță pe Acțiune |
| Gheața (Isaz) | 14 × 2 | 21 × 3 | 28 × 4 | Îngheț: fără trăsătură sau regulă la Rostirea următoare | Îngheț 2 Rostiri |
| Grindina (Hagalaz) | 8 × 2 (×3 lovituri) | 12 × 3 (×3) | 16 × 4 (×3) | 3 lovituri | 6 lovituri |
| Soarele (Sowilo) | 16 × 2 | 24 × 3 | 32 × 4 | ×2 contra creaturilor nopții | ×3 contra creaturilor nopții |
| Apa (Laguz) | 15 × 2 | 22 × 3 | 30 × 4 | ignoră rezistențele | și imunitățile devin rezistențe (×0,5) |
| Ziua (Dagaz) | 12 × 2 | 18 × 3 | 24 × 4 | +25% pe Rostire rămasă | +50% pe Rostire rămasă |

### 6.2 Țintele: partea de daună
- Tiwaz 100%;
- Fehu, Othala, Mannaz, Ansuz, Wunjo și Algiz 50%;
- Ingwaz 0% acum și 200% la Rostirea următoare.

Numele vrăjilor și versurile Paginilor rupte rămân. Unde numele nu mai se potrivește cu efectul, propun unul nou
(marcat cu ✎).

**În Dușman (Tiwaz): 100% + natura dublă.** Atacul curat; fără alt efect (întrebarea 2).

| Vraja | Nume | Ce face în plus |
|---|---|---|
| Kenaz → Tiwaz | Pârjolul | Arsură 6 pe strat |
| Uruz → Tiwaz | Asaltul | sparge Scutul pentru toată lupta |
| Thurisaz → Tiwaz | Ghimpele | +2 Rezonanță pe Acțiune |
| Isaz → Tiwaz | Iarna | Îngheț 2 Rostiri |
| Hagalaz → Tiwaz | Prăpădul | 6 lovituri |
| Sowilo → Tiwaz | Amiaza | ×3 contra nopții |
| Laguz → Tiwaz | Viitura | imunitățile devin rezistențe |
| Dagaz → Tiwaz | Ziua lungă | +50% pe Rostire rămasă |

**În Monede (Fehu): 50% + Monede.**

| Vraja | Nume | Monedele |
|---|---|---|
| Kenaz → Fehu | Fierăria | +1 pentru fiecare piatră din vrajă |
| Uruz → Fehu | Târgul | +4 |
| Thurisaz → Fehu | Camăta | +8, dar −1 Rostire |
| Isaz → Fehu | Cămara | +1 la fiecare 5 Monede pe care le ai (cel mult +4) |
| Hagalaz → Fehu | Ciobul | spargi definitiv o piatră aleasă din mână → +5 |
| Sowilo → Fehu | Aurul | +2 pentru fiecare piatră din Neamul lui Fehu din mână |
| Laguz → Fehu | Izvorul | +1 pentru fiecare piatră din mână |
| Dagaz → Fehu | Simbria | la finalul luptei, +2 pentru fiecare Rostire rămasă |

**În Săculeț (Othala): 50% + pietre mai bune, permanent.** Pietrele nu mai punctează. „Puterea unei pietre”
(`bonus_power`) se adaugă la Puterea vrăjii în care intră piatra.

| Vraja | Nume | Ce face |
|---|---|---|
| Kenaz → Othala | Călirea | 3 pietre aleatorii din săculeț primesc +3 Putere |
| Uruz → Othala | Ucenicia | pietrele acestei vrăji primesc +2 Putere |
| Thurisaz → Othala | Altoiul | o piatră aleatorie din mână se sparge; 2 copii ale unei pietre alese intră în săculeț |
| Isaz → Othala | Întoarcerea | pietrele rostite se întorc imediat în săculeț |
| Hagalaz → Othala | Cernerea | scoți definitiv până la 2 pietre alese |
| Sowilo → Othala | Prevestirea | vezi primele 3 pietre din săculeț și le pui în ce ordine vrei |
| Laguz → Othala | Înfierea | muți 2 pietre alese în alt Neam |
| Dagaz → Othala | Ecoul | o copie a fiecărei pietre din vrajă intră în săculeț |

**În Tine (Mannaz): 50% + Scut de inimă sau ajutor la mână.**

| Vraja | Nume | Ce face |
|---|---|---|
| Kenaz → Mannaz | Vatra | +1 piatră în mână tot restul luptei |
| Uruz → Mannaz | Încurajarea | pietrele din mână primesc +3 Putere în lupta asta |
| Thurisaz → Mannaz | Jertfa | arunci 2 pietre alese → +1 Rostire |
| Isaz → Mannaz | Pavăza ✎ (era Răbdarea) | **+1 Scut de inimă** |
| Hagalaz → Mannaz | Furtuna | arunci toată mâna și tragi alta, gratis |
| Sowilo → Mannaz | Alegerea | tragi 3 pietre și păstrezi una |
| Laguz → Mannaz | Valul | schimbi până la 3 pietre, gratis |
| Dagaz → Mannaz | Răgazul | +1 Schimbare |

**În Glas (Ansuz): 50% + Elementul crește cu 1 nivel tot Drumul.** Efectul e același pentru toate cele 8, cum cere
promptul. Numele rămân:
- Văpaia (Kenaz);
- Strigătul (Uruz);
- Rana (Thurisaz);
- Lecția (Isaz);
- Bâlbâiala (Hagalaz; Grindina se bâlbâie, dar învață);
- Lumina plină (Sowilo);
- Revărsarea (Laguz);
- Zorii (Dagaz).

*Risc:* e puternic, fiindcă orice Rostire Ansuz crește un nivel. Propun o limită: cel mult +3 niveluri pe Element
din Ansuz într-un Drum.

**În Viitor (Ingwaz): 0% acum, 200% la Rostirea următoare, plus:**

| Vraja | Nume | Ce face |
|---|---|---|
| Kenaz → Ingwaz | Jarul de mâine | Rostirea următoare are ×1,5 Rezonanță |
| Uruz → Ingwaz | Avântul | Rostirea următoare are +20 Putere |
| Thurisaz → Ingwaz | Datoria | Rostirea următoare ×2 Rezonanță, cea de după ×0,5 |
| Isaz → Ingwaz | Merindea | jumătate din dauna peste viața monstrului trece în lupta următoare |
| Hagalaz → Ingwaz | Avansul | monstrul următor începe cu −10% viață, dar tu cu −1 Schimbare |
| Sowilo → Ingwaz | Clarviziunea | în lupta următoare vezi mereu următoarele 3 pietre |
| Laguz → Ingwaz | Mareea | la începutul luptei următoare tragi 4 în plus și păstrezi 8 |
| Dagaz → Ingwaz | Ziua de mâine | lupta următoare are +1 Rostire |

**În Talismane (Wunjo): 50% + Talismane.**

| Vraja | Nume | Ce face |
|---|---|---|
| Kenaz → Wunjo | Scânteia | Talismanul din stânga lucrează de 2 ori la Rostirea asta |
| Uruz → Wunjo | Fanfara | +5 Putere pentru fiecare Talisman |
| Thurisaz → Wunjo | Sacrificiul | distrugi un Talisman ales → ×1,5 Rezonanță tot restul Ținutului |
| Isaz → Wunjo | Conserva | Talismanele care se consumă nu scad în lupta asta |
| Hagalaz → Wunjo | Lichidarea | vinzi un Talisman ales pe prețul întreg |
| Sowilo → Wunjo | Vitrina | la Piața următoare apare sigur un Talisman Rar |
| Laguz → Wunjo | Metamorfoza | un Talisman ales devine altul, de aceeași raritate |
| Dagaz → Wunjo | Ziua de târg | +1 Talisman pe taraba următoare |

**Asupra Stăpânului (Algiz): 50% + oprește trăsătura sau regula.** Fără regulă și fără trăsătură, vraja dă +3
Monede, ca acum.

| Vraja | Nume | Cât oprește |
|---|---|---|
| Kenaz → Algiz | Fumul | Rostirea asta |
| Uruz → Algiz | Revolta | toată lupta, dar monstrul își reface 10% din viață |
| Thurisaz → Algiz | Înțepătura | nu oprește nimic; monstrul pierde 10% din viață (boss: lovitură procentuală, max. 50%) |
| Isaz → Algiz | Înghețul | toată lupta |
| Hagalaz → Algiz | Asurzirea | următoarele 2 Rostiri |
| Sowilo → Algiz | Iscoada | Rostirea asta + vezi boșii următoarelor 2 Ținuturi |
| Laguz → Algiz | Schimbul | schimbi regula bossului cu una din 3, la alegere |
| Dagaz → Algiz | Amânarea | +1 Rostire în lupta asta |

### 6.3 Acțiunile
Sunt exact cum scrie în 5.4. Acum pot fi folosite cu oricare dintre rândurile de mai sus.

### 6.4 Rarele și Tabla Vrăjilor
Tabla rămâne 8 × 8, doar cu runele de bază. **Propun** ca o rună rară să se poarte ca o rudă de bază:
- un **Element rar** folosește efectul de rând al rudei, cu natura lui:
  - Āc → Forța;
  - Īor → Apa (și natura Forței);
  - Ēar → Gheața;
  - Cweorð → Focul;
- o **Țintă rară** are efectul ei, oricare ar fi Elementul.

Așa nu trebuie scrise sute de vrăji noi. În Compendiu, vrăjile cu rune rare apar pe o pagină separată, ca
„variante”.

---

## 7. Runele: start, deblocare, rare

- **Start:** Kenaz, Isaz, Ehwaz, Eihwaz, Tiwaz, Fehu. Săculețul are 24 de pietre (câte 4).
- **Deblocare:**
  - fiecare boss învins prima dată → o rună nouă, aleasă din 3, ca să ai control;
  - Cursul de seară → orice rună de bază pe Amintiri: 15 la început, plus 5 pentru fiecare rună deja deblocată;
  - socoteala: 8 boși pe Drum, dar doar primele victorii contează. Un Drum bun deblochează 3–5 rune, iar cu
    Amintirile ajungi la toate 24 în 3–5 Drumuri. Simulatorul verifică.
- **Rarele (12):** datele din 6.2 ale promptului.
  - Glifele vin din Unicode (ᚪ ᛡ ᛠ ᛢ ᚫ ᚣ ᚸ ᛄ ᚩ ᛣ ᛤ ᛥ) și le desenez din segmente, ca acum.
  - Sensurile istorice, scrise exact, cu „nesigur” unde e cazul:
    - Īor: o creatură din râu care mănâncă pe uscat (poemul runic englez);
    - Cweorð: nesigur;
    - Calc: nesigur (potir, cretă sau sanda);
    - Cealc: nesigur.
- **Legăturile străvechi (6):** o piatră, două roluri; în propoziție contează ca două pietre la rând; +25% daună.
- **Primordialele (3):** jucătorul alege rolul când o selectează (un meniu mic pe piatră). Glifele le desenezi tu;
  până atunci, un cerc gol cu un semn de întrebare.
  - **Runa Coborârii** are nevoie de o limită: cel mult +500%.
  - **Runa Clepsidrei** nu se repetă pe ea însăși.
- **Raritatea pe piatră:** gri / muchii de cristal albastru / violet / aur-jar animat, cu culorile din 10.2.

---

## 8. Talismanele: ce rămâne și ce se rescrie

| Talisman | Acum | Propun |
|---|---|---|
| Creta Maestrei Ilinca | +4 Rezonanță pe Rostire | **rămâne:** +2 Rezonanță la fiecare vrajă |
| Casca lui Gronn | +40 Putere | **rămâne:** +10 Putere la fiecare vrajă |
| Umbrela lui Varr | Rezonanță pe piatra din Neamul lui Hagalaz | **rescris:** Grindina lovește de 4 ori în loc de 3 |
| Scoica Selviei | +1 Schimbare | **rămâne** (pe luptă) |
| Cafeaua lui Lunet | +1 piatră în mână | **rămâne** |
| Shaorma lui Ignar | Rezonanță care se consumă | **rămâne:** +10 Rezonanță, scade cu 1 la fiecare Rostire |
| Biletul de troleibuz | Monedă pe Șir | **rescris:** +1 Monedă la fiecare Rostire cu 2 vrăji |
| Bunica din piață | −1 Monedă la prețuri | **rămâne** |
| Mănușile lui Kaldor | ×2 dacă punctează 5 pietre | **rescris:** ×2 Rezonanță dacă rostești 5 pietre |
| Bricheta lui Ignar | prima piatră punctează de 2 ori | **rescris:** Arsura are 5 straturi maxime |
| Semnul de carte al Morrei | +1 pe fiecare Cuvânt nou | **rescris:** +1 Rezonanță pentru fiecare vrajă diferită rostită în Drum |
| Toma, fiul lui Gronn | Putere pe piatra din săculeț | **rămâne:** +1 Putere pe vrajă pentru fiecare 2 pietre din săculeț |
| Nix, copilul lui Lunet | copiază Talismanul din dreapta | **rămâne** |
| Dara, fiica lui Kaldor | ×1,5, crește după Examinator | **rămâne:** crește după fiecare boss |
| Clepsidra Aevei | runda se reia o dată | **rescris:** prima inimă pe care ai pierde-o în Drum nu se pierde (apoi se sparge) |

Cele 15 Talismane noi (până la ~30) vin la pasul E sau după, gândite pentru luptă: slăbiciuni, Arsură, Scut,
Legături, boși.

---

## 9. Consumabilele și secretele

### 9.1 Gravurile
Materialele lucrează acum când piatra e **într-o vrajă**:

| Material | Ce face |
|---|---|
| Os | +X Putere vrăjii |
| Chihlimbar | +X Rezonanță |
| Aur | +3 Monede la finalul luptei dacă piatra e în mână |
| Fier | +X Rezonanță tuturor vrăjilor cât timp piatra stă în mână |
| Sticlă | ×2 Rezonanță; se poate sparge |

- **Legătura** își schimbă sensul: face o Legătură străveche din două pietre de bază alese (două roluri).
- **Prefacerea, Dublura, Sfărâmarea și Strămutarea** rămân.

### 9.2 Lecțiile
- Câte una pe Element (8). Jucătorul vede doar Lecțiile Elementelor deblocate.
- În Cercul 7, o Lecție dă +50% (adică 1,5 niveluri).

### 9.3 Pergamentul și Paginile rupte
- **Pergamentul (Gebo)** rămâne.
- **Paginile rupte** rămân în Piață, cu versurile scrise deja.

### 9.4 Amintirile
Se primesc pentru:
- fiecare luptă câștigată;
- fiecare boss;
- Drumul terminat;
- fiecare vrajă descoperită.

Se cheltuie pe:
- runele de la Cursul de seară;
- părinți;
- Talismanele de pus în Piață.

### 9.5 Cuvintele vechi (ALU, LAÞU, AUJA): secrete
Rămân ca secrete. Dacă rostești runele în ordinea lor, se întâmplă ceva special:
- **ALU** (Ansuz, Laguz, Uruz): un Scut de inimă;
- **LAÞU** (Laguz, Ansuz, Thurisaz, Uruz): toate vrăjile Rostirii ×2;
- **AUJA** (Ansuz, Uruz, Jera, Ansuz): +10 Monede.

Le pun în `data/secrets.json` la pasul C. Nu apar nicăieri până nu le descoperi.

---

## 10. Examinatorii → regulile boșilor

Regulile vechi care țin de pietre și de mână rămân. Cele care țineau de Cuvinte se rescriu:

| Regula veche (Examinator) | Devine |
|---|---|
| Kaldor: exact 5 pietre | **rămâne** |
| Selvia: mâna nouă după fiecare Rostire | **rămâne** |
| Varr: o piatră nu punctează | „o piatră aleatorie din Rostire nu contează” (poate rupe o propoziție) |
| Ignar: Schimbarea costă 1 Monedă | **rămâne** |
| Lunet: primele 3 pietre cu fața în jos | **rămâne** |
| Gronn: Pozițiile 1–3 nu punctează | „Rostirea trebuie să aibă cel puțin 4 pietre” |
| Morrah: Cuvânt repetat = 0 | „o vrajă rostită deja în luptă nu mai face daună” |
| Ilinca: Rună singură și Pereche = 0 | devine regula Babei Cloanța (E → Ț nu face daună) |
| Dara: ținta crește 10% | „monstrul își reface 10% din viață după fiecare Rostire” |
| Nix: primul Talisman oprit | **rămâne** |
| Aeva: o singură Rostire | **dispare** (Aeva nu mai e la catedră) |

Din regulile acestea se aleg și a doua regulă a boșilor din Cercul 3, și cele de la Schimbul (Laguz → Algiz).

---

## 11. Binecuvântările (propunere, 8)

Costă între 10 și 15 Monede (−25% în Cercul 7) și apar rar.

| Binecuvântarea | Ce dă tot Drumul |
|---|---|
| a lui Varr | +1 Rostire în luptele cu boși |
| a Selviei | +1 Schimbare în fiecare luptă |
| a lui Ignar | Focul pornește cu 1 nivel în plus |
| a lui Kaldor | +1 inimă maximă (și una plină) |
| a lui Lunet | vezi mereu următoarele 2 pietre din săculeț |
| a Morrei | +1 loc de consumabil |
| a lui Gronn | +1 loc de Talisman |
| a Aevei | o luptă pierdută se reia o dată, fără să pierzi inimă |

---

## 12. Părinții: săculețul de start (propunere)

Fiecare părinte schimbă cele 24 de pietre. În plus, aduce 2 pietre din runa lui, chiar dacă ea nu e deblocată:
un gust din ce urmează.

| Părinte | Săculețul | Altceva | Deblocare |
|---|---|---|---|
| Varr (furtuna) | Kenaz 6, Isaz 6, Ehwaz 3, Eihwaz 3, Tiwaz 4, Fehu 2 (+2 Hagalaz) | — | de la început |
| Selvia (ape) | cel standard, dar 2 Isaz devin 2 Laguz | +1 Schimbare | după primul Drum |
| Ignar (foc) | Kenaz 8, Isaz 2, restul standard | Arsura are 4 straturi maxime | Amintiri |
| Gronn (munți) | cel standard + 2 Uruz | +1 loc de Talisman, −1 piatră în mână | Amintiri |
| Morrah (amintiri) | doar 18 pietre (câte 3) | prima vrajă nouă din fiecare luptă dă +1 Amintire | Amintiri |

Asta înlocuiește întrebarea despre Varr de la Etapa 4: nu mai dă Rostiri în plus, ci un săculeț cu mai multe
Elemente.

---

## 13. Lumea: Ținuturi, monștri, boși (propunere)

### 13.1 Viața
- **Monstrul mic** din Ținutul n are 100 × 1,55^(n−1) viață; cel **mare** ×1,5, iar **bossul** ×2,5.
- Câteva repere:
  - Ținutul 1: 100 / 150 / 250;
  - Ținutul 4: 372 / 558 / 930;
  - Ținutul 8: ~2 160 / ~3 240 / ~5 400.
- Fiecare monstru mai are un multiplicator propriu (Căpcăunul are mai multă viață, Spiridușul mai puțină).
- **Cercul 2+:** viața ×1,25.
- La început, o Rostire bună face 40–110 daună (Kenaz → Tiwaz = 36 + Arsură; cu 2 vrăji ~100). Valorile se fixează
  cu simulatorul la pasul I.

### 13.2 Monștrii (16) și Ținuturile lor

Toți sunt din folclorul și basmele publice românești. Gheonoaia și Scorpia vin din „Tinerețe fără bătrânețe și viață
fără de moarte” (Ispirescu, domeniu public). Prin „noaptea” înțeleg creaturile pe care le lovește mai tare Soarele.

| Monstru | Ce e (folclor) | Slab la | Rezistent / imun | Trăsătura | Ținuturi |
|---|---|---|---|---|---|
| Spiriduș | duh mic și hoț | Foc | — | fură 1 Monedă pe Rostire | 1, 2 |
| Moroi | duhul unui mort; noaptea | Soare | rez. Apă | îți ia o piatră din mână pe Rostire | 1, 3, 6 |
| Pricolici | om care se face lup | Foc, Soare | rez. Forță | Furie: după a 2-a Rostire, −1 Schimbare | 1, 2 |
| Fata Pădurii | duhul pădurii care rătăcește oamenii | Foc | rez. Apă | mâna se amestecă după fiecare Rostire | 2 |
| Vârcolac | fiara care mănâncă luna; noaptea | Ziua, Soare | rez. Gheață | Scut 30 | 2, 7 |
| Iele | zâne ale nopții care dansează; noaptea | Ziua | **imune la Forță** | Dansul: mâna se amestecă | 3, 7 |
| Strigoi | mort ridicat din mormânt; noaptea | Soare, Foc | **imun la Gheață** | Regenerare 5% pe Rostire | 3, 4, 6 |
| Joimărița | o pedepsește pe cea care n-a tors până joi | Foc | rez. Spin | dacă nu rostești 2 vrăji, își reface 10% | 4 |
| Marțolea | duhul care pedepsește lucrul de marți seara; noaptea | Ziua | rez. Grindină | Rostirile de 5 pietre îl vindecă 5% | 4 |
| Zburătorul | duh care zboară noaptea și tulbură somnul; noaptea | Soare | imun la Grindină | primele 2 pietre din fiecare tragere vin cu fața în jos | 4 |
| Hala | duhul grindinei și al furtunii | Foc | **imună la Grindină** | o piatră din mână devine Hagalaz la fiecare Rostire | 5 |
| Vâlva Băilor | păzitoarea minelor din munți | Apă | rez. Forță | Scut 50 | 5, 7 |
| Căpcăun | uriaș care mănâncă oameni | Spin | rez. Grindină | viață multă (×1,4) | 5, 6 |
| Uriaș | uriaș din basme | Spin, Apă | rez. Forță | Scut 40, reface 10 pe Rostire | 5, 7 |
| Gheonoaia | monstrul-pasăre din basm | Grindină | rez. Foc | Furie: după a 2-a Rostire, Scut 30 | 6 |
| Pui de balaur | balaur tânăr, cu un singur cap | Gheață, Apă | rez. Foc | Arsura nu-l prinde | 7, 8 |

Ținutul 8 (Poarta) amestecă monștrii cei mai tari din toate Ținuturile.

### 13.3 Boșii (8)

| Ținut | Boss | Slab / rezistent | Regula |
|---|---|---|---|
| 1 Marginea Orașului | **Statu-Palmă-Barbă-Cot** (piticul cât o palmă, cu barba cât un cot) | Foc / — | mic, dar încăpățânat: o vrajă îi ia cel mult 30% din viață |
| 2 Codrul | **Muma Pădurii** | Soare / rez. Spin | Focul e interzis în pădurea ei (vrăjile de Foc nu se leagă) |
| 3 Mlaștina | **Știma Apelor** (duhul care păzește apele) | Foc / imună la Apă | mâna se schimbă după fiecare Rostire (fosta regulă a Selviei) |
| 4 Satul blestemat | **Baba Cloanța** | Ziua / rez. Gheață | vrăjile simple (E → Ț) nu fac daună |
| 5 Munții | **Solomonarul** | Gheață / imun la Grindină | o piatră din mână devine Hagalaz la fiecare Rostire |
| 6 Cetatea în ruină | **Scorpia** | Gheață, Apă / rez. Foc | primele 3 pietre din fiecare tragere vin cu fața în jos (fosta regulă a lui Lunet) |
| 7 Peștera Zmeului | **Zmeul** | Gheață / rez. Foc | fiecare Rostire trebuie să aibă o vrajă cu Acțiune |
| 8 Poarta | **Balaurul cu trei capete** | fiecare cap altfel (Foc / Gheață / Apă) | 3 capete, unul după altul (vezi întrebarea 1) |

### 13.4 Examenul
- **Manechinul de antrenament:** viață mică, fără trăsături.
- **Câinele de bronz:** viață medie.
- **Kaldor:** slab la Foc, imun la Gheață, fără regulă. În Examen nu se pierd inimi.

---

## 14. Indiciile noi (propunere de replici)

| id | Când | Cine | Text |
|---|---|---|---|
| `first_weakness` | prima slăbiciune lovită | Ilinca | „Ai lovit unde doare. Slăbiciunea dublează dauna. Citește-o înainte să rostești.” |
| `first_immunity` | prima imunitate | Ilinca | „Nimic. Unele creaturi nici nu simt un Element. Schimbă Elementul, nu încăpățânarea.” |
| `first_boss` | primul boss | Aeva | „Stăpânii Ținuturilor nu pleacă. Dacă nu-i dobori, te lovesc și te așteaptă. Răniți.” |
| `first_heart_lost` | prima inimă pierdută | Aeva | „O inimă mai puțin. Mai ai. Deocamdată.” |
| `first_rare_rune` | prima rună rară | Tanti Vera | „Asta n-o găsești în manuale. Englezii vechi au mai adăugat câteva rune. Ține-o bine.” |
| `first_ancient_bind` | prima Legătură străveche | Ilinca | „Două rune într-o piatră. Contează ca două pietre la rând. Nu le despărți.” |
| `first_new_circle` | primul Cerc nou | Aeva | „Un Cerc nou. Mai greu. Nu te uita așa la mine, tu ai vrut.” |

Indiciile Cuvintelor (de exemplu `first_laguz`, Laguz ca joker) și cele ale Examinatorilor de la Probe dispar sau se
rescriu.

---

## 15. Salvarea: migrarea
- `SAVE_VERSION` 1 → 2. La încărcarea unei salvări vechi:
  - **rămân** numele jucătorului și setările (limba, volumul, indiciile);
  - **se pierd:**
    - Amintirile;
    - încercările;
    - părinții și Talismanele deblocate;
    - Colecția;
    - descoperirile (Vrăji, Acțiuni, Cuvinte ascunse, Pagini rupte);
    - recordurile (cea mai bună Probă, cea mai mare Rostire, nivelurile Cuvintelor);
    - indiciile văzute;
    - instruirea trecută (Examenul nou trebuie trecut);
    - examenul în curs.
- O copie a salvării vechi rămâne în `save.json.v1`, ca să nu se piardă nimic de tot.
- Un test verifică migrarea.

---

## 16. Riscuri și cum le țin în frâu

1. **E aproape o rescriere** (~60% din cod).
   - Lucrez pe pași.
   - După fiecare pas, jocul pornește și testele trec, chiar dacă unele ecrane sunt provizorii. De exemplu, la
     pasul B lupta merge pe ecranul de rundă de acum, adaptat; ecranul nou vine la G.
2. **Balansul e necunoscut.**
   - Simulatorul vine devreme: o versiune simplă la B, pentru o luptă; cea completă la I.
   - Valorile stau toate în JSON.
3. **Propozițiile devin mai complicate:** 2 vrăji, pietre cu 2 roluri, rolul ales la primordiale. Parser-ul are
   teste pe toate cazurile, iar previzualizarea spune de ce nu se leagă.
4. **Efecte prea puternice:** Ansuz, Runa Coborârii, Æsc, Raidho cu Merindea. Am pus limitele în `economy.json`, iar
   simulatorul caută vrăjile care ies din rând.
5. **Fonturile:** cer OK-ul tău la pasul F înainte să descarc ceva:
   - Cinzel, Alegreya, Alegreya Sans, Alegreya Sans SC (de pe Google Fonts, licență OFL);
   - Forum, pentru rusă.

   Grenze iese din proiect.
6. **Ramele procedurale** în Compatibility (shader pe `CanvasItem`): le testez cu captura de ecran în cloud și în
   UIKit.
7. **Instruirea veche** (5 lecții, testele ei) se șterge abia la pasul H. Până atunci rămâne, adaptată cât să nu
   cadă.
8. **Folclorul:** descrieri scurte și corecte. Evit creaturile foarte întunecate (de exemplu Samca, care face rău
   copiilor).

---

## 17. Ordinea pașilor (ce atinge fiecare)

| Pas | Atinge |
|---|---|
| **B** Miezul | `elements.json`, `targets.json`, spells / actions noi, `damage.gd`, `monster.gd`, `fight_state.gd`, parser cu 2 vrăji + Neam, Lecțiile pe Elemente; Manechinul; scot Cuvintele, Poziția, Glasurile; `test_damage`, `test_sentence`, `test_spells`; ecranul de rundă adaptat provizoriu (monstrul cu bara, „Ucide!”) |
| **C** Runele | `runes.json` (rarități, deblocări, rare, Legături, primordiale), glifele futhorc, `secrets.json`, Gravura Legătura, `test_runes` |
| **D** Lumea | `realms.json`, `monsters.json`, `journey_state.gd`, inimile, boss rănit, Sfârșit de luptă + `rewards.gd`, salvarea Drumului, `test_journey`, `test_monsters` |
| **E** Piața și Cercurile | `shop_logic` (5, Blochează, Rune, Binecuvântări), `blessings.json`, `circles.json`, hub-ul provizoriu cu alegerea Cercului, Talismanele rescrise, `test_shop`, `test_circles` |
| **F** UI Kit | fonturile (cu OK), `Theme` nou, paleta, ramele, butoanele, cardurile, pietrele, bara de viață, inimile, însemnele, tabelul de contrast, `scenes/ui_kit.tscn` |
| **G** Ecranele | meniul, Lupta, Sfârșit de luptă, Piața, Talismane și Sac, Compendiul, Hub-ul |
| **H** Examenul | `tutorial.json` cu 3 lecții, indiciile noi, șterg lecțiile vechi |
| **I** Balansul | `simulate.gd` pe Drumuri și Cercuri, tabelele cerute |

După fiecare pas: `DESIGN.md`, `ARTA.md`, `CLAUDE.md`, traducerile, commit, raport și așteptarea OK-ului tău.
