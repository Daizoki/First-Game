# Designul Jocului 1 — „Examenul” (EN: „The Godborn Exam”)

> Document viu: se actualizează când se schimbă designul. Valorile exacte stau în `data/*.json`.

- Gen: **roguelite pe ture cu cărți** (deckbuilder ușor, mult mai mic decât un Slay the Spire).
- O partidă: **15–20 de minute**.
- Premisa: ești un semizeu de 16 ani convocat la **Examenul de Moștenire**. Dacă pici, **Aeva, zeița timpului**,
  te întoarce în dimineața examenului. Încerci din nou, dar **păstrezi amintirile** (progresul permanent).
- Ton: **epic + umor**. Zeii trăiesc la vedere printre oameni și au meserii banale.
- Scop: un joc mic, **terminat și publicat pe itch.io** (inclusiv versiune jucabilă în browser).

## 3.1 Bucla
```
Meniu → Dimineața examenului (hub) → Alegi părintele divin
      → Proba 1 → Proba 2 → Proba 3
      → VICTORIE (scena finală)  sau  PICAT (Aeva te întoarce)
      → primești Amintiri → înapoi în Dimineața examenului
```

## 3.2 Lupta
- **Eroul:** HP (depinde de părinte), **3 Energie pe tur**, **trage 5 cărți pe tur**. La final de tur, cărțile rămase în mână se aruncă.
- **Pachet → mână → teanc aruncat.** Când pachetul e gol, teancul aruncat se amestecă și devine pachet nou.
- **Scut:** absoarbe daune și dispare la începutul turului tău următor.
- **Intenții:** fiecare inamic arată deasupra lui ce face în tura următoare (iconiță + număr: atac 12, scut 8, aplică Slăbit etc.).
- **Stări (doar 4 în prima versiune):**

| Stare | id | Efect |
|---|---|---|
| Arsură | `burn` | primește X daune la final de tur, apoi X scade cu 1 |
| Slăbit | `weak` | dă cu 25% mai puține daune (durată în ture) |
| Vulnerabil | `vulnerable` | primește cu 50% mai multe daune (durată în ture) |
| Putere | `strength` | +X daune la fiecare atac (permanent în luptă) |

- **Victorie:** toți inamicii au 0 HP. **Înfrângere:** eroul are 0 HP → ecranul „Picat”.
- **Efectele cărților sunt liste de acțiuni în JSON**, executate în ordine. O carte nouă = doar JSON, fără cod:
  ```json
  {"type": "damage", "value": 6, "target": "enemy"}
  {"type": "damage", "value": 4, "target": "all_enemies"}
  {"type": "block",  "value": 5}
  {"type": "apply",  "status": "burn", "value": 3, "target": "enemy"}
  {"type": "draw",   "value": 2}
  {"type": "energy", "value": 1}
  {"type": "heal",   "value": 4}
  ```
  Ținte: `enemy` (o alege jucătorul), `all_enemies`, `random_enemy`, `self`.
- Inamicii au un **tipar de acțiuni** în JSON (secvență sau ciclu cu șanse simple), plus reguli speciale pentru boss (3.4).

## 3.3 Părinții divini (alegi unul la începutul partidei)
| id | Zeu | Domeniu | HP start | Stil de joc | Cartea semnătură |
|---|---|---|---|---|---|
| `varr` | Varr | furtună, fulger | 55 | daune mari, lovește mai mulți inamici | **Fulgerul lui Varr** — cost 2: 8 daune tuturor inamicilor |
| `selvia` | Selvia | mări, ape | 65 | scut + vindecare, luptă lungă | **Valul** — cost 1: 8 scut, vindecă 3 |
| `ignar` | Ignar | foc, forjă | 60 | Arsură care se adună în timp | **Jarul** — cost 1: aplică 4 Arsură |

- **Deblocare:** Varr de la început. Selvia după prima încercare, indiferent de rezultat. Ignar costă 30 de Amintiri.
- **Pachet de start (10 cărți):** 5× Lovitură (cost 1, 6 daune), 4× Apărare (cost 1, 5 scut), 1× cartea semnătură.
- **Cărți pentru recompense:** 6 pentru fiecare părinte + 4 neutre (22 în total), în stilul fiecărui părinte. Direcție:
  - Varr: *Tunet* (cost 1: 5 daune, aplică 1 Vulnerabil), *Linia 22* (cost 0: trage 2 cărți; Varr conduce troleibuzul 22).
  - Selvia: *Maree* (cost 1: 6 scut, trage 1 carte), *Adâncul* (cost 2: 14 scut).
  - Ignar: *Shaorma de foc* (cost 1: vindecă 4, aplică 2 Arsură), *Forja* (cost 1: +2 Putere).
  - Neutre: *Respiră* (cost 0: +1 Energie tura asta), *Pumn de semizeu* (cost 2: 14 daune).
- La recompense, cărțile părintelui tău apar mai des (aprox. 60%).
- Fiecare carte poate fi **îmbunătățită o dată** (la Odihnă): versiunea `+` are valori mai mari (câmpul `upgrade` din `cards.json`).

## 3.4 Examenul: 3 probe
Fiecare probă are un fundal, inamici tematici și un **zeu examinator** ca boss.

**Structura unei probe (5 pași):**
1. Luptă
2. Alegere: **Luptă grea** (recompensă mai bună) sau **Eveniment**
3. Luptă
4. Alegere: **Odihnă** (vindecă 30% HP sau îmbunătățește o carte) sau **Rival** (luptă de elită, dă o binecuvântare)
5. **Examinatorul** (boss)

Între probe eroul își reface 25% din HP.

| Probă | Examinator | Loc | Inamici | Rival |
|---|---|---|---|---|
| 1. Proba Forței | **Kaldor** | arena de nisip a sălii de box | Manechin de antrenament, Câine de bronz, Soldat de lut | Dara |
| 2. Proba Minții | **Lunet** | sala oglinzilor | Fantomă de vis (aplică Slăbit), Ceasul care fuge, Ecou | Nix |
| 3. Proba Umbrei | **Morrah** | Biblioteca Sufletelor | Carte blestemată, Umbră, Paznic de os | Toma (eveniment de alianță, nu luptă) |

**Reguli speciale pentru examinatori:**
- **Kaldor:** atacuri mari; +1 Putere în fiecare tur. Sub 50% HP strigă „Garda sus!” și primește scut mare o dată.
- **Lunet:** invocă 2 **Ecouri** (HP mic) la începutul luptei și din nou când amândouă au murit; aplică Slăbit.
- **Morrah:** atacul ei crește cu fiecare tur („Liniștea se adună”) — jucătorul trebuie să termine repede; aplică Vulnerabil.

**Recompense:**
- după luptă normală: alegi 1 carte din 3 (sau sari peste);
- după elită/rival: o binecuvântare + alegere de carte;
- după examinator: o binecuvântare + o carte rară.

## 3.5 Binecuvântări (efecte pasive, 8 în prima versiune)
| id | Nume | Efect |
|---|---|---|
| `kaldor_whistle` | Fluierul lui Kaldor | +1 Putere la începutul fiecărei lupte |
| `lunet_coffee` | Cafeaua de noapte a lui Lunet | +2 cărți trase în primul tur |
| `varr_umbrella` | Umbrela lui Varr | primul atac primit în fiecare luptă face 0 daune |
| `selvia_shell` | Scoica Selviei | vindecă 3 HP după fiecare luptă |
| `ignar_lighter` | Bricheta lui Ignar | orice Arsură aplicată primește +1 |
| `morrah_bookmark` | Semnul de carte al Morrei | la începutul luptei, alegi 1 carte din pachet s-o ai în mână |
| `gronn_helmet` | Casca de șantier a lui Gronn | +8 scut în primul tur |
| `aeva_hourglass` | Clepsidra Aevei | o dată pe examen, când ai muri, rămâi la 1 HP |

În `blessings.json`, fiecare are `effect.trigger` (`combat_start`, `first_turn`, `combat_end`, `passive`) și fie
`actions` (aceleași acțiuni ca la cărți), fie o `rule` specială tratată de cod.

## 3.6 Rivalii și evenimentele
- **Dialoguri scurte** (2–4 replici) înainte și după fiecare întâlnire cu un rival sau zeu, cu portret, nume și text
  care apare literă cu literă. Replicile stau în `dialogs.json`.
- **Dara** (fiica lui Kaldor): elită în Proba 1. Competitivă și arogantă, dar corectă.
- **Nix** (copilul lui Lunet): elită în Proba 2. Glumeț și mincinos; nu știi niciodată de partea cui e.
- **Toma** (fiul lui Gronn): eveniment în Proba 3. Îl ajuți (pierzi 8 HP, primești *Umărul lui Toma*: cost 1, 12 scut) sau îl lași.
- **Evenimente (3–4 în prima versiune)**, fiecare cu text și 2–3 alegeri. Exemple:
  - *Automatul de cafea al zeilor:* plătești 6 HP pentru o carte la alegere.
  - *Un turist vrea selfie cu tine:* accepți (+1 carte aleatorie) sau refuzi (vindecă 5).
  - *Radioul lui Lunet la difuzor:* ghicești următorul cântec; dacă ghicești → o binecuvântare, dacă nu → 1 Slăbit la următoarea luptă.

## 3.7 Amintirile (progres permanent)
- La finalul fiecărei partide, pierdute sau câștigate: **+2** pentru fiecare luptă câștigată, **+5** pentru o elită, **+10** pentru un examinator.
- În **Dimineața examenului** (hub) cheltui Amintiri pe:
  - deblocare Ignar (30);
  - +5 HP maxim (20; de maximum 3 ori);
  - înlocuirea unei Lovituri de start cu o carte mai bună (25).
- **Aeva** apare în hub la fiecare repetare cu o replică nouă, care depinde de numărul de încercări (`dialogs.json`).
  Ex.: *„Iar tu? A {n}-a oară în dimineața asta.”*
- La prima pornire, jucătorul își scrie numele (maximum 12 caractere).
- **Salvare** în `user://save.json` prin `SaveManager`: nume, Amintiri, deblocări, număr de încercări, cea mai bună
  probă atinsă, setări (limbă, volum). Partida în curs nu se salvează la ieșire în prima versiune.

## 3.8 Ecrane
Meniu principal (Joacă / Setări / Ieșire) · Dimineața examenului (hub) · Alegere părinte · Harta probei · Luptă ·
Recompensă · Odihnă · Eveniment · Dialog · Vizualizare pachet · Pauză · Picat · Victorie (scena finală scurtă).

## 3.9 Senzația (Etapa 6)
- Numere de daune care sar, tremur de ecran la lovituri mari, cărți care se măresc la hover, tranziții scurte între ecrane.
- Hook-uri pentru sunete (SFX + muzică), cu placeholder-uri deocamdată.
- **Momentele mari (apariția unui examinator, victoria, întoarcerea în timp) trebuie să arate bine filmate** — pentru clipuri TikTok/Shorts.

## 3.10 Ținte de dificultate (orientativ)
- Un jucător nou trece Proba 1 în aproximativ 70% din încercări.
- Examenul complet la prima încercare: aproximativ 15–25%.
- După câteva deblocări: aproximativ 50%.

## Jurnal de decizii
- **Etapa 1:** randare `gl_compatibility` (necesară pentru exportul Web). Textul descrierii unei cărți va fi generat
  automat din `effects` (în Etapa 2), ca un număr schimbat în JSON să schimbe și textul; câmpul `description` rămâne
  opțional, pentru cărți cu text special.
