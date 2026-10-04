# Designul Jocului 1 — „Examenul de Moștenire” (EN: „The Inheritance Exam”) — v4

> Document viu: se actualizează când se schimbă designul. Valorile exacte stau în `data/*.json`.
> v1 (deckbuilder cu lupte) și v2 (cercul runic) sunt **înlocuite**. v4 = v3 + **Vrăjile** (3.15) + stilul vizual (3.16).

## 1. Viziunea
- Gen: **roguelike de construit scoruri, cu rune în loc de cărți**, în spiritul Balatro.
- În loc de un pachet de cărți ai un **Săculeț cu pietre de rune**. Tragi pietre în mână și **rostești Cuvinte**
  (combinații de rune). Fiecare Cuvânt dă un scor. Ca să treci o rundă, atingi scorul cerut de examinator.
- Cele **24 de rune sunt runele istorice reale (Futharkul vechi)**. **Fiecare rună are un efect („Glasul” ei)
  inspirat din sensul ei real**.
- **Vrăjile:** anumite combinații de 2–3 rune au efecte **complet diferite**, nu doar scor mai mare: scad ținta,
  dau bani, creează Talismane, schimbă săculețul, anulează regula examinatorului. Sunt ascunse până le descoperi și se
  pot ghici din sensul runelor (3.15). **Glasurile și Vrăjile ne fac diferiți de Balatro.**
- Premisa: ești un semizeu de 16 ani la **Examenul de Moștenire**. Dacă pici, **Aeva, zeița timpului**, te întoarce în
  dimineața examenului. Păstrezi amintirile, adică deblocările.
- Ton: **epic + umor**. Motto: **„Puterea o moștenești. Runele le înveți.”**
- Stil vizual: **desenat de mână** (tuș, întuneric, rune care strălucesc) — vezi `docs/ARTA.md`.
- Scop: un joc mic, **terminat și publicat pe itch.io**, inclusiv în browser.

**Regulă:** Balatro e doar inspirație pentru *mecanică*. **Nu copiem** numele lui (Joker, Chips, Mult, Blind, Ante,
Tarot, Planet etc.), interfața, aranjarea ecranului, textele, valorile numerice sau efectele vizuale caracteristice.

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
| cărțile care cresc nivelul unei mâini | **Lecțiile** (de la Școala de Rune) | `lesson` |
| cărțile care modifică alte cărți | **Gravurile** | `engraving` |
| magazinul | **Piața de noapte** | `shop` |
| nivelurile de dificultate | **Probele** examenului | `trial` |
| rundele | **Întrebarea mică**, **Întrebarea mare**, **Examinatorul** | `small`, `big`, `examiner` |
| banii | **Monede** | `money` |
| *(nu există la Balatro)* | **Vrăjile**: combinații secrete de rune cu efecte unice | `spell` |

## 3.1 Bucla
```
Meniu → Dimineața examenului (hub) → Alegi părintele divin (= săculețul de start)
  → Proba 1: Întrebarea mică → Piața → Întrebarea mare → Piața → Examinatorul → Piața
  → Proba 2 … → Proba 8 (Examinatoare finală: Aeva)
  → AI TRECUT EXAMENUL  sau  PICAT (Aeva te întoarce în timp)
  → primești Amintiri → înapoi în Dimineața examenului
```

## 3.2 Pietrele și săculețul
- **24 de rune** (3.5), în **3 Neamuri** a câte 8. Fiecare rună are o **Poziție** (1–8) în neamul ei.
- **Săculețul de start: 48 de pietre — fiecare rună de două ori.**
- O piatră are: runa, Neamul, Poziția, **Putere de bază** (pornim de la poziția + 2, deci 3–10; de balansat),
  **Glasul** runei, opțional un **material** și opțional o **legătură** (3.7).
- **O rundă:**
  - Tragi **8 pietre** în mână. Ai **4 Rostiri** și **3 Schimbări**.
  - **Rostire:** alegi 1–5 pietre; jocul recunoaște cel mai bun Cuvânt și calculează scorul; apoi tragi până ai iar 8.
  - **Schimbare:** alegi 1–5 pietre, le dai deoparte și tragi altele.
  - Pietrele rostite/schimbate nu se întorc în săculeț până la finalul rundei. Dacă săculețul se golește, joci cu ce
    ai în mână.
  - Treci runda când suma scorurilor atinge ținta; pici dacă rămâi fără Rostiri înainte.
  - La finalul rundei toate pietrele se întorc în săculeț și se amestecă.
- Sortare după Poziție sau după Neam (două butoane) și rearanjare cu drag. **Ordinea contează** (Gebo, Ehwaz, Tiwaz,
  Cuvintele vechi ascunse).

## 3.3 Scorul: Putere × Rezonanță
0. Se verifică **Vrăjile** din toate pietrele rostite (3.15); cele cu momentul `before_score` se aplică acum.
1. Cuvântul rostit dă **Puterea** și **Rezonanța** de bază (în funcție de nivel).
2. **Pietrele care formează Cuvântul** punctează una câte una, de la stânga la dreapta: Puterea pietrei, apoi
   materialul și Glasul. Pietrele rostite care nu fac parte din Cuvânt nu punctează.
3. Efectele pietrelor rămase în mână (de ex. Isaz).
4. **Talismanele**, de la stânga la dreapta.
5. **Scor = Putere × Rezonanță**, adunat la scorul rundei.
6. Vrăjile cu momentul `after_score` se aplică acum; cele cu `next_cast` se pregătesc pentru următoarea Rostire.

Animația scorului e **inima jocului**: fiecare piatră se ridică și strălucește, numerele zboară în contoare (Puterea
în albastru, Rezonanța în roșu), la final se înmulțesc cu un efect mare. Viteză ×1, ×2, ×4.
Scorurile pot fi foarte mari: `float`, formatate frumos („12 840”, „1,2 mil.”).

## 3.4 Cuvintele (tipurile de combinații)
| # | Cuvânt | Ce trebuie |
|---|---|---|
| 1 | Rună singură | nicio combinație; punctează piatra cu Poziția cea mai mare |
| 2 | Pereche | 2 pietre cu aceeași Poziție |
| 3 | Două perechi | 2 Perechi diferite |
| 4 | Treime | 3 pietre cu aceeași Poziție |
| 5 | Șir | 5 Poziții consecutive (1–8, fără întoarcere de la 8 la 1) |
| 6 | Neam | 5 pietre din același Neam |
| 7 | Familie | o Treime + o Pereche |
| 8 | Patru | 4 pietre cu aceeași Poziție |
| 9 | Descântec | un Șir în care toate pietrele sunt din același Neam |
| 10 | Cuvântul Vechi *(ascuns până îl descoperi)* | 5 pietre cu aceeași Poziție |

- 3 Neamuri × 8 Poziții ≠ poker, deci probabilitățile sunt altele. **Simulatorul** (8 pietre din 48) arată cât de des
  apare fiecare Cuvânt; ordinea și valorile de bază se fixează după tabel: **mai rar = mai puternic**.
  Punct de plecare: Rună singură ≈ 5 Putere × 1 Rezonanță. **Tabelul se arată lui Relax înainte de a fixa valorile.**
- Fiecare Cuvânt are **nivel** (de la 1). O Lecție îi crește nivelul: + Putere și + Rezonanță.
- Easter egg: un Descântec din Neamul lui Fehu de la Poziția 1 scrie **F-U-Þ-A-R** → mesaj special.

## 3.5 Cele 24 de rune (Futharkul vechi)
Datele istorice sunt verificate de Relax. **Nu inventăm alte sensuri „istorice”.** În Cartea de rune fiecare rună are
două texte: **„Sens istoric”** și **„În joc”** (Glasul). Numele sunt reconstruite de lingviști; sensurile vin din
nume și din poemele runice medievale (englez, norvegian, islandez). Multe sensuri „mistice” de pe internet sunt
interpretări moderne (secolul XX).

**Neamul lui Fehu** (avere, forță, drum) — auriu, semn: monedă
| Poz. | Rună | Nume | Sens istoric | Glasul (orientativ) |
|---|---|---|---|---|
| 1 | ᚠ | Fehu | vite, avere | +1 Monedă când punctează |
| 2 | ᚢ | Uruz | bourul (taurul sălbatic dispărut) | Puterea ei de bază e dublă |
| 3 | ᚦ | Thurisaz | uriaș, monstru; în poemul englez: spin | +4 Rezonanță |
| 4 | ᚨ | Ansuz | „un zeu”; în poemul englez: gura | Cuvântul punctează ca și cum ar avea +1 nivel |
| 5 | ᚱ | Raidho | călărie, călătorie | +1 Schimbare în runda asta |
| 6 | ᚲ | Kenaz | în poemul englez: făclie; în cele nordice: bubă, rană | Cât timp e în mână, vezi următoarele 3 pietre din săculeț |
| 7 | ᚷ | Gebo | dar, cadou | Copiază Glasul pietrei din stânga ei |
| 8 | ᚹ | Wunjo | bucurie | +1 Rezonanță pentru fiecare piatră din Cuvânt |

**Neamul lui Hagalaz** (forțele naturii, încercări) — albastru-gheață, semn: fulg de grindină
| Poz. | Rună | Nume | Sens istoric | Glasul |
|---|---|---|---|---|
| 1 | ᚺ | Hagalaz | grindină | Punctează de două ori |
| 2 | ᚾ | Naudiz | nevoie, lipsă, suferință | ×2 Rezonanță dacă e ultima Rostire a rundei |
| 3 | ᛁ | Isaz | gheață | Dacă rămâne în mână (nerostită), +3 Rezonanță la fiecare Rostire |
| 4 | ᛃ | Jera | an, an bun, recoltă | La finalul rundei, +2 Monede pentru fiecare Jera rostită în rundă |
| 5 | ᛇ | Eihwaz | tisa (copac care trăiește sute de ani) | Crește: +3 Putere permanent de fiecare dată când punctează |
| 6 | ᛈ | Perthro | sens necunoscut; poemul englez vorbește de joc și distracție (poate o cupă de zaruri) | 1 șansă din 4: ×3 Rezonanță |
| 7 | ᛉ | Algiz | elan (numele original e nesigur) | Regula Examinatorului nu se aplică acestei Rostiri |
| 8 | ᛊ | Sowilo | soare | ×1,5 Rezonanță |

**Neamul lui Tiwaz** (oameni, comunitate, moștenire) — roșu-cărămiziu, semn: stea
| Poz. | Rună | Nume | Sens istoric | Glasul |
|---|---|---|---|---|
| 1 | ᛏ | Tiwaz | numele unui zeu al cerului și al dreptății; în poemul englez: o stea călăuzitoare | ×2 Rezonanță dacă e prima piatră din stânga în Cuvânt |
| 2 | ᛒ | Berkanan | mesteacăn | O dată pe rundă, după ce punctează, adaugă în săculeț o copie a unei pietre din Cuvânt |
| 3 | ᛖ | Ehwaz | cal | Piatra din dreapta ei punctează încă o dată |
| 4 | ᛗ | Mannaz | om, ființă umană | Runa oamenilor: +2 Rezonanță pentru fiecare Lecție folosită în acest examen |
| 5 | ᛚ | Laguz | apă, lac, mare | Curge: contează ca piatră din orice Neam |
| 6 | ᛜ | Ingwaz | Ing, numele unui zeu sau erou | Sămânța: dacă rămâne în mână la finalul rundei, primește +10 Putere permanent |
| 7 | ᛞ | Dagaz | zi | ×2 Rezonanță dacă e prima Rostire a rundei |
| 8 | ᛟ | Othala | moștenire, pământul și casa familiei | Moștenirea: +2 Rezonanță pentru fiecare Talisman deținut |

- Ordinea tradițională: Dagaz pe 23 și Othala pe 24 (pe unele obiecte vechi sunt inversate; păstrăm ordinea tradițională).
- **Glasurile sunt o propunere** — se testează, se balansează și se raportează ce s-a schimbat.
- Opțiune în `data/`: `rune_voices_start_awake: true/false`. Dacă jocul pare prea încărcat, pornim cu pietrele
  „adormite” (fără Glas), iar o Gravură specială le **trezește**.
- **Cuvinte vechi ascunse (Etapa 5):** dacă pietrele punctate scriu, de la stânga la dreapta, unul dintre ele → bonus
  secret + mesaj de descoperire:
  - **ALU** (ᚨᛚᚢ) — cel mai des întâlnit; sens disputat (băutură rituală, amuletă sau ceva sacru);
  - **LAÞU** (ᛚᚨᚦᚢ) — tradus de obicei „chemare, invitație”;
  - **AUJA** (ᚨᚢᛃᚨ) — tradus de obicei „noroc”.
  Bonusurile: de propus.

## 3.6 Talismanele (5 locuri)
- Efecte pasive, ordonate de la stânga la dreapta (rearanjabile). Se cumpără din Piață și se vând pe jumătate din preț.
- Raritate: Comun, Rar, Legendar. **Prima versiune: ~30.** Talismanele sunt **ilustrațiile principale ale jocului**.
- **Etapa 3 a făcut primele 15** (tabelul de mai jos, fără Pecete, păstrată pentru final). Datele sunt în
  `data/talismans.json`: `kind` spune ce face, numerele cât. Logica e în `scripts/core/talisman_rules.gd`, iar scorul
  le aplică la pasul 4.
  - Prețuri: Comun 5, Rar 8, Legendar 13 Monede. Se vând cu 50%.
  - Pe ecran atârnă pe sfoară, cu fișă la mouse. Le tragi ca să le schimbi ordinea și strălucesc când lucrează.

| Talisman | Raritate | Efect |
|---|---|---|
| Creta Maestrei Ilinca | Comun | +4 Rezonanță |
| Casca de șantier a lui Gronn | Comun | +40 Putere |
| Umbrela lui Varr | Comun | pietrele din Neamul lui Hagalaz dau +3 Rezonanță când punctează |
| Scoica Selviei | Comun | +1 Schimbare în fiecare rundă |
| Cafeaua de noapte a lui Lunet | Comun | +1 piatră în mână (9) |
| Shaorma lui Ignar | Comun | +20 Rezonanță; scade cu 1 după fiecare Rostire și dispare la 0 |
| Biletul pe troleibuzul 22 | Comun | +1 Monedă de fiecare dată când rostești un Șir |
| Bunica din piață | Comun | totul în Piață costă cu 1 Monedă mai puțin |
| Mănușile lui Kaldor | Rar | ×2 Rezonanță dacă Cuvântul are exact 5 pietre |
| Bricheta lui Ignar | Rar | prima piatră punctată în fiecare Rostire punctează de două ori |
| Semnul de carte al Morrei | Rar | +1 Rezonanță permanent pentru fiecare tip de Cuvânt nou rostit în examen |
| Toma, fiul lui Gronn | Rar | + Putere egală cu numărul de pietre rămase în săculeț |
| Nix, copilul lui Lunet | Rar | copiază efectul Talismanului din dreapta lui |
| Dara, fiica lui Kaldor | Rar | ×1,5 Rezonanță; crește cu +0,25 după fiecare Examinator învins |
| Clepsidra Aevei | Legendar | o dată pe examen: dacă pici o rundă, o iei de la capăt; apoi Clepsidra se sparge |
| Pecetea Curții Moștenirii | Legendar | ×3 Rezonanță |

(Restul până la ~30: de propus, în același stil.)

## 3.7 Lecții, Gravuri, materiale și legături
- **2 locuri pentru consumabile** (Lecții și Gravuri).
- **Lecții (10):** câte una pe Cuvânt; fiecare îi crește nivelul cu 1. Text cu umor (ex. „Lecția despre Perechi.
  Kaldor a picat-o de două ori.”).
- **Gravuri (~10)** modifică pietrele din mână:
  - **Materiale** (cel mult unul pe piatră): **Os** (+20 Putere); **Chihlimbar** (+4 Rezonanță); **Aur** (+3 Monede
    dacă rămâne în mână la finalul rundei); **Fier** (×1,5 Rezonanță dacă rămâne în mână); **Sticlă** (×2 Rezonanță,
    1 șansă din 4 să se spargă și să dispară).
  - **Legătura** (mecanica noastră): leagă 2 pietre într-o **legătură runică** cu ambele rune; la formarea Cuvântului
    contează ca oricare dintre cele două (jocul alege varianta cea mai bună); când punctează, se declanșează **ambele
    Glasuri**. Istoric, runele legate chiar existau.
  - **Prefacerea:** schimbă runa unei pietre într-o rună la alegere din același Neam.
  - **Dublura:** adaugă în săculeț o copie a unei pietre.
  - **Sfărâmarea:** scoate definitiv până la 2 pietre din săculeț.
  - **Strămutarea:** mută până la 3 pietre în alt Neam (runa rămâne; se schimbă culoarea și Neamul).
- **Săculețe în Piață** (pachete): alegi 1 din 3 (sau 2 din 5 la cele mari). Tipuri: Lecții, Gravuri, Talismane,
  Pietre (uneori cu materiale).
- **Cum s-a construit (Etapa 3):**
  - `data/lessons.json` are 10 Lecții, câte una pe Cuvânt, cu glume. Lecția Cuvântului Vechi apare în Piață abia după
    ce l-ai descoperit.
  - `data/engravings.json` are 10 Gravuri: cele 5 materiale, Legătura, Prefacerea, Dublura, Sfărâmarea și Strămutarea.
  - Ai **2 locuri** pentru ele.
    - O Lecție se învață cu un clic, în rundă sau în Piață.
    - O Gravură se folosește în rundă: clic pe ea, apoi alegi pietrele din mână în panoul de alegeri.
  - Valorile materialelor stau în Gravuri:
    - Os: +20 Putere când punctează;
    - Chihlimbar: +4 Rezonanță când punctează;
    - Aur: +3 Monede dacă rămâne în mână la finalul rundei;
    - Fier: ×1,5 cât stă în mână, după Glasurile pietrelor din mână;
    - Sticlă: ×2, cu 1 șansă din 4 să se spargă.
  - **Legătura** unește 2 pietre cu rune diferite: a doua iese din săculeț, iar prima poartă ambele rune.
    - La Cuvânt, jocul încearcă ambele citiri și o păstrează pe cea mai bună.
    - Când punctează, se aud ambele Glasuri.
    - **Pentru vrăji contează doar runa principală.**

## 3.8 Probele și Examinatorii
- **8 Probe** × 3 runde: **Întrebarea mică** (ținta de bază), **Întrebarea mare** (×1,5), **Examinatorul** (×2 + regulă).
- Curba țintelor: de propus și verificat cu simulatorul (fără valori din Balatro).
  Valorile sunt în `data/trials.json`; verificarea se face cu `tests/simulate.gd -- part=4`, rezultatele în jurnal.
- **Monede:** recompensă după fiecare rundă câștigată + mic bonus pentru Rostirile rămase + mică dobândă la economii
  (cu plafon). Valori în `economy.json`. Economie simplă.
  - Pornești cu 3 Monede.
  - Întrebarea mică dă 4, cea mare 5, Examinatorul 6.
  - +2 pentru fiecare Rostire rămasă.
  - Dobândă: 1 la fiecare 6 Monede, cel mult 4.
- **Cum s-a construit (Etapa 3):**
  - `data/examiners.json` are, pentru fiecare Examinator, regula, numele ei, replica de început, cea de înfrângere,
    cea când pici și numerele regulii. Logica e în `scripts/core/exam_state.gd` (examenul) și `round_state.gd`
    (regulile).
  - Examinatorul Probei stă la catedră în toate cele 3 runde; regula lui se aplică doar în a treia.
  - Algiz (Glasul) și vraja Fumul țin regula departe de o Rostire. Celelalte vrăji „asupra Examinatorului” anulează,
    amână sau schimbă regula. Într-o rundă fără Examinator, vrăjile asupra Examinatorului dau doar +3 Monede.
  - Aeva are o singură Rostire, deci ținta ei e mai mică: `target_mult` în date.
- Examinatorii Probelor 1–7: ordine aleatorie, fără repetări. **Aeva e mereu ultima (Proba 8).**
- Replică înainte de rundă și replică la înfrângerea lui (`dialogs.json`).

| Examinator | Cine e | Regula (orientativ) |
|---|---|---|
| Kaldor | zeul războiului, antrenor de box | „Garda sus!”: trebuie să rostești exact 5 pietre |
| Selvia | zeița mărilor, salvamar | „Fluxul”: după fiecare Rostire, pietrele din mână se întorc în săculeț și tragi altele |
| Varr | zeul furtunii, șofer pe troleibuzul 22 | „Fulgerul”: la fiecare Rostire, o piatră aleatorie din Cuvânt nu punctează |
| Ignar | zeul focului, are o shaormerie | „Taxa”: fiecare Schimbare costă 1 Monedă |
| Lunet | zeul viselor, DJ de noapte | „Visul”: primele 3 pietre trase de fiecare dată vin cu fața în jos |
| Gronn | zeul pământului, șef de șantier | „Greutatea”: runele cu Poziția 1–3 nu punctează |
| Morrah | zeița morții și a amintirilor, bibliotecară | „Ține minte”: un tip de Cuvânt deja rostit în runda asta nu mai punctează |
| Maestra Ilinca | om, cea mai mare maestră de rune | „Corectura”: Rună singură și Pereche dau scor 0 |
| Dara | semizeiță rivală | „Competiția”: ținta crește cu 10% după fiecare Rostire |
| Nix | semizeu rival | „Păcăleala”: Talismanul din stânga e dezactivat în runda asta |
| **Aeva** | zeița timpului, Directoarea Examenului | **„Clepsidra”** (finală): o singură Rostire, dar Schimbări nelimitate (după a treia, fiecare costă 1 Monedă). De balansat |

## 3.9 Piața de noapte
- Între runde: **Piața de noapte** din Orașul Pragului (tarabe, becuri, aburi de la shaorma).
- Vânzătoarea: **Tanti Vera**, vinde rune de 40 de ani, are o replică pentru orice.
- La fiecare vizită: 2 Talismane, 2 consumabile (Lecții sau Gravuri), 2 Săculețe și **„Rearanjează taraba”**
  (reîmprospătează; prețul crește la fiecare apăsare). Prețuri în `economy.json`.
- **Cum s-a construit (Etapa 3):** logica e în `scripts/core/shop_logic.gd`, ecranul în `scripts/ui/shop_screen.gd`.
  - Piața se deschide după fiecare rundă câștigată.
  - Talismanele apar după raritate: 70% Comun, 25% Rar, 5% Legendar. Nu apare niciunul pe care îl ai deja.
  - Prețuri:
    - Lecție 3, Gravură 4 Monede;
    - Săculeț 4, Săculeț mare 7;
    - rearanjarea pornește de la 2 și crește cu 1.
  - Bunica din piață scade toate prețurile cu 1 Monedă.
  - Soarele și Ziua spre Talismane schimbă taraba următoare (un Talisman Rar sigur, un Talisman în plus).
  - Tanti Vera are o replică la fiecare vizită (`data/dialogs.json`).

## 3.10 Părinții divini (= săculețul de start)
| Părinte | Bonus | Deblocare |
|---|---|---|
| Varr | +1 Rostire în fiecare rundă | de la început |
| Selvia | +1 Schimbare în fiecare rundă | după prima încercare |
| Ignar | începi examenul cu 2 Gravuri aleatorii | Amintiri |
| Gronn | +1 loc de Talisman, dar −1 piatră în mână | Amintiri |
| Morrah | săculeț de doar 24 de pietre (câte una din fiecare rună); mai greu, dar fiecare piatră contează (Patru și Cuvântul Vechi devin imposibile fără Dubluri) | Amintiri, pentru jucători avansați |

- **Cum s-a construit (Etapa 4):** datele sunt în `data/parents.json`, cu felul deblocării (`start`, `attempts`,
  `memories`) și prețul.
  - Varr e de la început, iar Selvia vine după primul examen terminat.
  - Ignar costă 40 de Amintiri, Gronn 80, Morrah 120.
  - Bonusul se adaugă la regulile rundei. Regula unui Examinator care își are propriile Rostiri sau Schimbări
    (Aeva) e mai tare decât el, deci copilul lui Varr are tot o singură Rostire la Aeva.
  - Fiecare părinte are o replică pe fișa lui (`line`).

## 3.11 Bucla Aevei, Amintirile și colecția
- La finalul fiecărui examen (câștigat sau pierdut): **Amintiri** după proba atinsă, Examinatorii învinși și descoperiri.
- **Dimineața examenului** (hub): Aeva te întâmpină cu o replică ce depinde de numărul de încercări
  („Iar tu? A {n}-a oară în dimineața asta.”). Cheltui Amintiri pe: deblocarea părinților; adăugarea de Talismane noi
  în ofertele Pieței (la început doar o parte sunt disponibile).
- **Cartea de rune:** cele 24 de rune (forma, sensul istoric, Glasul); Cuvintele (cu nivelurile maxime atinse);
  Cuvintele vechi ascunse (cu semn de întrebare până le descoperi).
- **Colecția:** Talismane, Gravuri și Examinatori văzuți.
- La prima pornire, jucătorul își scrie numele (max. 12 caractere).
- **Salvare** în `user://save.json` (`SaveManager`): nume, Amintiri, deblocări, colecție, descoperiri, statistici (cel
  mai mare scor dintr-o Rostire, cea mai bună probă), setări. **Examenul în curs se salvează după fiecare rundă.**
- **RNG cu seed:** fiecare examen are un seed afișat în meniul de pauză, ca o partidă să poată fi repetată exact.
- **Cum s-a construit (Etapa 4):** regulile sunt în `scripts/core/progress.gd`, iar ecranele sunt `scenes/morning.tscn`,
  `parent_select.tscn` și `collection.tscn`.
  - **Amintirile:**
    - 1 pentru fiecare rundă câștigată, 3 pentru fiecare Examinator învins, 15 pentru examenul trecut;
    - 5 pentru fiecare Vrajă descoperită și 3 pentru fiecare Cuvânt ascuns descoperit;
    - valorile sunt în `data/rules.json`.
  - **Dimineața:**
    - Aeva are o replică după câte dimineți au fost (prima, după un examen picat, după unul trecut, oricare altă);
    - butoanele: Continuă examenul (cu Proba, runda și Monedele), Începe examenul, Amintirile, Cartea de rune,
      Colecția, Cursul de seară, Setări, Meniul principal;
    - dedesubt: numele, cea mai bună Probă, examenele trecute, cea mai mare Rostire.
  - **Amintirile (ecranul):** părinții de cumpărat și 5 Talismane care la început lipsesc din Piață: Semnul de carte
    al Morrei și Toma (20), Nix și Dara (30), Clepsidra Aevei (50).
  - **Examenul în curs** se salvează după fiecare rundă și după fiecare Piață. Dacă ieși în mijlocul unei runde, o
    reiei de la panoul de dinaintea ei, cu aceleași pietre (același seed). Un examen nou peste unul salvat îl închide
    pe cel vechi și îi plătește Amintirile.
  - **La final:** panoul arată Amintirile câștigate, apoi „Aeva întoarce timpul” (un ceas care se rotește înapoi) și
    Dimineața. Primul examen picat aduce cele 3 indicii ale Aevei.
  - **Cartea de rune** are trei pagini: Runele, Tabla Vrăjilor, Cuvintele (cu cel mai mare nivel atins vreodată).
  - **Colecția:** Talismanele și Gravurile văzute în Piață sau primite, Examinatorii întâlniți; restul sunt „???”.
  - **Paginile rupte:** uneori (50%) Tanti Vera vinde una cu 3 Monede. Arată runele unei Vrăji nedescoperite și un
    vers ca indiciu (fiecare dintre cele 64 de Vrăji are versul ei, `verse` în `spells_base.json`). Pagina rămâne pe
    Tabla Vrăjilor („? · pagină”, iar versul apare la mouse).
  - **Numele** se scrie la prima pornire (cel mult 12 litere) și se poate schimba din Setări.
  - Cursul de seară (instruirea) se poate relua din Dimineață și se termină tot acolo.

## 3.12 Povestea (scurtă)
- **Intro de 4–5 cadre:** 1) Coborârea zeilor; 2) oamenii găsesc 24 de semne vechi pe pietre, mai vechi decât orice
  zeu; 3) Orașul Pragului azi; 4) convocarea la Examenul de Moștenire; 5) prima întâlnire cu Aeva.
- Replicile examinatorilor, ale Aevei și ale lui Tanti Vera.
- **Finalul**, după Aeva: o scenă scurtă cu Pecetea și un indiciu despre misterul runelor.

## 3.13 Senzația
(Detaliile vizuale complete sunt în 3.16.)
- Pietrele se înclină ușor sub mouse și „respiră” când sunt selectate. Runele pulsează cu lumină.
- Scorul crește cu cifre care se rotesc. La multiplicatori mari: tremur de ecran, flash, cifre mari.
- Fundal animat cu shader (ceață de noapte, paleta din `docs/ARTA.md`).
- Hook-uri pentru sunete (SFX + muzică), placeholder-uri deocamdată.
- **Momentele mari arată bine filmate** (TikTok/Shorts): o Rostire uriașă, deschiderea unui Săculeț legendar,
  apariția unui Examinator, întoarcerea în timp.

## 3.14 Ținte de dificultate (orientativ)
- Un jucător nou trece Proba 1 aproape mereu, iar Proba 3 în ~50% din încercări.
- Primul examen complet reușit: după câteva ore de joc.
- O partidă completă: 30–45 de minute.

## 3.15 Gramatica runelor (Vrăjile)
> Înlocuiește vechile Vrăji cu rețete fixe (Etapa 2b). Specificația completă e în `docs/GRAMATICA.md`; valorile sunt în
> `data/spells_base.json`, `data/spell_actions.json` și `data/economy.json`.

**Ideea:** runele sunt cuvinte. Fiecare rună are un **rol**, ales după sensul ei, iar pietrele rostite una după alta
formează o **propoziție**. Propoziția corectă devine vrajă. Altă ordine înseamnă altă vrajă sau nicio vrajă.

- **Rolurile** (8 de fiecare; Neamul și Poziția rămân, pentru Cuvinte):
  - **Elemente**, din ce e făcută vraja: Kenaz Focul, Uruz Forța, Thurisaz Spinul, Isaz Gheața, Hagalaz Grindina,
    Sowilo Soarele, Laguz Apa, Dagaz Ziua;
  - **Acțiuni**, cum lucrează: Raidho se întinde, Gebo se dăruiește, Naudiz cere un preț, Jera se coace, Eihwaz
    durează, Perthro riscă, Berkanan crește, Ehwaz aleargă de două ori;
  - **Ținte**, asupra a ce: Tiwaz peste Țintă, Fehu în Monede, Othala în Săculeț, Mannaz în Mână, Ansuz în Cuvânt,
    Ingwaz în Viitor, Wunjo în Talismane, Algiz asupra Examinatorului (ultimele două pornesc în Etapa 3).
  - Laguz e Apa, un Element, nu un joker pentru vrăji. Pentru Neam rămâne joker.
- **Propoziția:** **Element → Țintă**, **Element → Acțiune → Țintă** sau **Element → Acțiune → Acțiune → Țintă**.
  - Pietrele stau una după alta, în **ordinea de rostire** (ordinea în care le selectezi; pe piatră apare numărul
    1–5).
  - Contează doar **prima** propoziție completă.
  - Pietrele din afara propoziției punctează normal, iar o piatră poate fi și în Cuvânt, și în vrajă.
  - Ordine greșită (Ținta înaintea Elementului) = nicio vrajă.
  - O propoziție întreruptă de altă piatră nu se leagă.
- **Vrăjile de bază:** 8 Elemente × 8 Ținte = **64**, fiecare cu nume și efect (de ex. Gheața peste Țintă =
  **Iarna**: ținta scade cu 15%).
  - Momentul efectului: **înainte** (schimbă scorul Rostirii), **după** (după scor) sau **mai târziu** (următoarea
    Rostire sau rundă).
  - Cele 16 spre Talismane și Examinator au datele scrise, dar „dorm” (`enabled: false`) până în Etapa 3.
- **Acțiunile** schimbă vraja de bază și se aplică în ordine:
  - Raidho: valorile ×1,5; pe o vrajă care atinge o singură piatră, le atinge pe toate, la jumătate de putere;
  - Ehwaz: de 2 ori;
  - Eihwaz: se repetă la începutul următoarelor 2 runde, la jumătate;
  - Berkanan: +50% pentru fiecare rostire anterioară a aceleiași vrăji în examen;
  - Jera: vine la finalul rundei, dublu;
  - Perthro: 50% ×3, 50% nimic;
  - Naudiz: plătești pe loc 1 Rostire sau 4 Monede, efect ×2,5;
  - Gebo: vraja nu se întâmplă acum, ci așteaptă pe **Pergament** (1 loc), până îl folosești.
  O Acțiune care n-are ce schimba nu face nimic, iar previzualizarea spune asta.
- **Limite** (în `economy.json`): ținta nu scade sub 40% din valoarea de la începutul rundei; cel mult +2 Rostiri pe
  rundă din vrăji; un singur Pergament.
- **Glasurile care țin de ordine** citesc ordinea de rostire:
  - Gebo copiază Glasul pietrei rostite înaintea ei;
  - Ehwaz face să mai puncteze o dată piatra de după ea;
  - Tiwaz dă ×2 Rezonanță dacă e rostită prima.
  Cu vrăjile oprite (Lecțiile 1–3), pietrele se citesc de la stânga la dreapta.
- **Pe ecran:**
  - semnul rolului în colțul pietrei (triunghi = Element, săgeată = Acțiune, cerc cu punct = Țintă);
  - numerele de ordine pe pietrele selectate;
  - **propoziția sub cerc**, în locașe care se umplu pe rând, cu mesajul de dedesubt:
    - „???” cât timp vraja nu e descoperită;
    - numele și efectul, după ce e descoperită;
    - „propoziție neterminată”;
    - „Ordinea e greșită: Elementul vine primul.”
  - panoul de alegeri, pentru vrăjile care îți cer ceva (piatra de spart, Neamul nou, ordinea din săculeț, prețul
    lui Naudiz…);
  - locul de Pergament.
- **Descoperirea:**
  - Prima rostire a unei vrăji de bază pornește animația mare (3.16), făcută pentru clipuri.
  - Prima folosire a unei Acțiuni are o animație mică: „Ai învățat: aleargă de două ori”.
  - Vrăjile și Acțiunile descoperite rămân pentru totdeauna și dau +Amintiri.
  - **Cartea de rune** are **Tabla Vrăjilor**: 8 × 8, Elementele pe coloane și Țintele pe rânduri, numele sau „?” în
    fiecare căsuță, iar dedesubt cele 8 Acțiuni.
- **Mai târziu:**
  - Cuvintele vechi ascunse (ALU, LAÞU, AUJA) rămân separate de vrăji și se citesc tot în ordinea de rostire.
  - Paginile rupte din Piață (Etapa 4) arată o căsuță nedescoperită a Tablei, cu un vers ca indiciu.
  - Blestemele (Etapa 5) vor fi propoziții care se întorc împotriva ta, cu o recompensă.
- **Balansul** (Etapa 2b, pasul C, jurnalul de mai jos):
  - vrăjile apar în 34% din Rostiri din întâmplare și în 80% dacă le cauți;
  - urcă rundele câștigate de la 75% la 80%;
  - limita de 40% se atinge în 2% din runde.

## 3.16 Stilul vizual și senzația
Luăm de la jocurile de gen doar **principiile**: totul reacționează, numerele cresc cu impact, fundalul trăiește, fiecare
acțiune are sunet. **Aspectul e al nostru.** Nu copiem fundalul psihedelic rotitor, panoul lateral, fontul sau cutiile
albastru/roșu ale Balatro. Paleta și fonturile: `docs/ARTA.md`.

**Ecranul rundei (1920×1080):**
- **stânga sus:** Proba („Proba 3 din 8”), Monedele (monedă cu runa Fehu), Săculețul („40 / 48”);
- **stânga:** Scorul rundei (cifră mare + „din 1 200” + bară de progres în culoarea jarului) și, dedesubt,
  **Putere × Rezonanță**: Puterea pe o tăbliță de os (fundal deschis, cifre închise), Rezonanța într-un bloc de jar
  (roșu-închis, cifre portocalii care strălucesc);
- **stânga, mai jos:** Rostirile ca **4 lumânări** (cele folosite sunt stinse, cu un fir de fum) și Schimbările ca
  **3 linii de cretă** (cele folosite sunt tăiate);
- **sus, centru:** cartea Examinatorului: portret rotund, nume, „zeul războiului · antrenor de box”, regula într-o casetă
  roșie, Ținta;
- **centru:** **Cercul runic**, un disc de piatră cu cele 24 de rune gravate pe margine, care se rotește foarte încet.
  În mijloc apar, în timp ce alegi pietre, numele Cuvântului, câte pietre punctează, Putere × Rezonanță și Vrăjile
  găsite. Când există o Vrajă, cercul strălucește în culoarea ei;
- **dreapta sus:** Talismanele atârnă pe o sfoară, ca niște cărți prinse cu cleme, și se leagănă ușor;
- **dreapta:** cele 2 consumabile (Lecții și Gravuri), ușor rotite;
- **jos:** mâna de 8 pietre, într-un arc ușor. Fiecare piatră are poziția în colțul din stânga sus, runa strălucind în
  centru și semnul Neamului în dreapta jos;
- **dreapta jos:** butoanele **Rostește** (mare, jar) și **Schimbă**; **stânga jos:** sortare după Poziție sau Neam;
- **fundalul:** Orașul Pragului noaptea: lună, blocuri cu câteva ferestre aprinse, ruine de templu, firele
  troleibuzului, ceață violetă care se mișcă încet, o masă întunecată în primul plan.

**Efecte (shadere sau tween-uri, pe renderer-ul Compatibility):**
- **Linii care „fierb”:** contururile și ramele tremură ușor, schimbând de 8–12 ori pe secundă între 3 variante de
  zgomot (shader de deplasare). Textul nu fierbe.
- **Granulație de hârtie** peste tot ecranul, foarte discretă.
- **Pietrele:** se leagănă ușor când stau, se înclină și se ridică sub mouse, sar în sus când sunt selectate, cu un
  halou în culoarea Neamului. Runa are **trei straturi** (strălucire neclară, culoarea Neamului, miez alb) și pulsează.
- **Talismanele** se leagănă pe sfoară; **flacăra lumânărilor** pâlpâie.
- **Descoperirea unei Vrăji:** ecranul se întunecă; un cerc punctat se rotește; runele Vrăjii apar pe cerc cu un „pop”
  și se unesc cu linii (sigiliul); numele Vrăjii apare uriaș, cu strălucire în culoarea ei; dedesubt: formula
  („Isaz · gheață + Hagalaz · grindină + Naudiz · nevoie”), efectul și scorul Rostirii.
- **Sunet** (placeholder-uri acum): fiecare piatră punctată are un sunet care urcă în ton. Muzica: atmosferă de noapte
  cu instrumente populare (nai, țambal, cobză), ca identitate proprie.

## 3.17 Instruirea și indiciile
Specificația completă e în `docs/INSTRUIRE.md`; aici e ce s-a construit și regulile pentru etapele viitoare.

**Instruirea — „Seara dinaintea examenului”** (Maestra Ilinca, sala de curs a Școlii de Rune):
- Pornește singură la prima pornire, după nume. Intro cu două butoane: **Învață-mă** → Lecția 1;
  **Mă descurc singur** → „Sigur? Kaldor nu explică nimic.” [Da, sar] [Nu, rămân].
- Se poate relua din meniu („Instruire”) și din Setări („Reia instruirea”); se poate sări din pauză. La final (sau la
  sărit) se salvează `tutorial_done`.
- Cinci lecții, fiecare o mini-rundă. Valorile stau în `data/tutorial.json`:

  | # | Lecția | Ce înveți | Mână | Ținta | Rostiri / Schimbări |
  |---|---|---|---|---|---|
  | 1 | Pietrele și Rostirea | fișa pietrei, Poziția, Neamul, Perechea, cercul, scorul încetinit, lumânările | fixă | 250 | 3 / 0 |
  | 2 | Schimbarea și Cuvintele mari | Schimbarea, maximum 5 pietre, Familia, Cartea Cuvintelor | fixă (+ 2 pietre fixe în săculeț) | 3 000 | 2 / 1 |
  | 3 | Glasul runelor | Glasurile: Hagalaz lovește de două ori, Fehu dă o Monedă | fixă | 240 | 2 / 0 |
  | 4 | Vrăjile | propoziția Isaz → Tiwaz (Iarna), ordinea greșită (Fehu → Hagalaz), o Acțiune la mijloc (Uruz → Ehwaz → Fehu); se termină după ultimul pas | fixă | 300 | 3 / 0 |
  | 5 | Singur | joc liber cu săculețul întreg (seed fix); după 25 s fără acțiune, un singur indiciu | trasă | 280 | 4 / 3 |

- Pașii unei lecții: bulă de citit (clic), sau „așteaptă” o acțiune (mouse pe o piatră, o selecție anume, Rostire,
  Schimbare, carte deschisă / închisă). Lumina (`spotlight`) arată elementul; restul ecranului se întunecă.
- Doar acțiunile care ar strica lecția se blochează (butoanele se sting); mouse-ul pe pietre merge mereu. O selecție
  greșită nu se blochează: Ilinca spune `wrong_text`. Scorul lecției 1 se joacă încetinit, cu bule pe faze.
- Pierzi o lecție → o iei de la capăt („Nu se notează.”). Lecția 5 câștigată → instruirea e gata → meniul principal
  (până apare Dimineața examenului, Etapa 4).

**Ajutorul permanent** (merge mereu, și în instruire):
- **Fișa pietrei** (mouse pe piatră): runa, Poziția și Neamul, rolul în Gramatică („Element — Gheața”), sensul
  istoric, Puterea, Glasul.
- **Fișa cercului** (mouse pe mijlocul cercului): Cuvântul, descrierea, câte pietre punctează (ele strălucesc în mână,
  celelalte selectate se estompează), Putere × Rezonanță, propoziția și vraja ei.
- **Cartea Cuvintelor** (butonul „Cuvinte” lângă cerc sau tasta **C**): cele 10 Cuvinte de la cel mai puternic la cel
  mai obișnuit, cu exemplu din pietre mici, nivel și valori; Cuvântul Vechi e „???” până îl descoperi.
- **Cartea de rune** (din pauză), cu două file: „Runele” (cele 24 de rune pe Neamuri, cu rolul lor) și „Tabla
  Vrăjilor” (grila 8 × 8 și cele 8 Acțiuni; ce n-ai descoperit e „?”).
- **Propoziția sub cerc** și **fișa Pergamentului** (mouse pe Pergament), vezi 3.15.

**Indiciile contextuale** (`data/hints.json`, tot jocul):
- Bulă mică cu portret în dreapta ecranului; apare **o singură dată**, pe rând, nu blochează nimic, se închide cu un
  clic. Se trec la „văzute” (`hints_seen`) când apar.
- Tăcute în instruire și când sunt oprite din Setări (`hints_enabled`); ascunse cât timp e deschisă pauza sau o carte.
- Fiecare indiciu are fie `trigger` (un eveniment din `ENUMS["hint_event"]`, plus `rune` / `seconds` / `max_exams`),
  fie `follows` (vine imediat după alt indiciu). Acum sunt pornite `first_laguz`, `idle_help` și cele trei ale
  Gramaticii: `first_wrong_order` (prima ordine greșită), `first_scroll` (primul Pergament), `first_two_actions` (prima
  vrajă cu două Acțiuni). Celelalte 16 au `"enabled": false` și așteaptă etapa lor (tabelul din `docs/INSTRUIRE.md`,
  secțiunea 4).

**Cum se leagă de joc:** jocul doar emite evenimente pe `EventBus` și întreabă „poarta” (`allowed_actions`,
`selectable_runes`); instruirea și indiciile doar ascultă. Elementele pe care lumina le poate găsi au metadata
`tutorial_id` (lista în `ENUMS["ui_id"]`); pietrele sunt `stone:<rune_id>`.

**Reguli pentru fiecare etapă viitoare** (sunt și în `CLAUDE.md`):
1. Când construiești un element care are indicii în `hints.json`, îi pui `"enabled": true`, emiți evenimentul lui
   (`Hints.fire(...)` sau un semnal nou pe `EventBus`) și adaugi un test în `tests/test_hints.gd`.
2. Orice element nou pe care jucătorul îl vede (Talisman, consumabil, regula Examinatorului, marfa din Piață…)
   primește **fișă la mouse**, în stilul fișei pietrei (`TooltipPanel`).
3. Elementele noi pe care ar putea să le arate instruirea sau un indiciu primesc `tutorial_id` (și intră în
   `ENUMS["ui_id"]`).
4. Orice text nou are română și engleză; traducerea în engleză i-o arăt lui Relax la finalul etapei.

## Sistemul de efecte (2.2)
Un efect = **declanșator** + **condiții** + **acțiuni**.
- Declanșatori: `on_score` (piatra punctează), `on_held` (piatra stă în mână când rostești), `on_round_end`,
  `on_cast`, `passive`.
- Acțiuni: `add_power`, `add_res`, `mul_res`, `add_money`, `retrigger`, `add_discard` etc.
- Efecte prea speciale pentru JSON: handler numit în cod (`"special": "gebo_copy_left"`), ținuți într-o listă scurtă.

## Jurnal de decizii
- **v3:** jocul devine roguelike de scoruri cu pietre de rune (stil Balatro, termeni proprii). Folosim runele reale
  ale Futharkului vechi (regula din v2 „fără alfabete runice reale” e anulată). Grafică desenată, 1920×1080.
- **Etapa 1 pe v3 (decizii propuse de Claude, acceptate implicit):**
  - `data/characters.json` = „cine e cine” (zeii, oamenii, semizeii: nume, descriere, culoare); celelalte fișiere
    trimit la el prin `id`.
  - Efectele „permanente” ale pietrelor (Eihwaz, Ingwaz, copia lui Berkanan) țin **până la finalul examenului**.
  - Fișiere mici în plus față de lista din 2.6: `data/kins.json` (cele 3 Neamuri: nume, culoare, semn) și
    `data/rules.json` (mâna de 8, 4 Rostiri, 3 Schimbări, max. 5 pietre, 2 copii din fiecare rună,
    `rune_voices_start_awake`).
  - Fereastra pornește la 1600×900 (baza rămâne 1920×1080), ca să încapă pe laptopuri.
  - Formele runelor (`segments` în `runes.json`) sunt scrise de Claude după formele standard ale Futharkului vechi;
    Relax le verifică în ecranul „Cele 24 de rune”.
- **v4:** au intrat Vrăjile (3.15), stilul vizual al ecranului de rundă (3.16), paleta și fonturile propuse (Grenze
  Gotisch + Grenze, OFL, se descarcă doar cu OK-ul lui Relax). Culorile Neamurilor se iau din paleta din `docs/ARTA.md`.
- **Etapa 1 pe v4 (decizii propuse de Claude):**
  - Fiecare Vrajă din `spells.json` are o **categorie** (Țintă, Economie, Săculeț, Acțiuni, Talismane, Examinator, Risc,
    Permanent, Scor) și o **culoare** pentru strălucirea cercului. Le-am ales eu; se pot schimba din JSON.
  - Categorii alese: Drumul și Potopul = Acțiuni; Făclia și Focul = Săculeț; Sacrificiul și Zarurile = Risc;
    Lecția și Pădurea = Permanent.
  - Titlurile folosesc culoarea Lumânare (`#FFB347`), motto-ul culoarea Hagalaz, restul textului culoarea Os.
- **Etapa 2 — o rundă (propuneri de verificat de Relax):**
  - **Tabelul de probabilități** (simulator, 100 000 de mâini de 8 pietre din 48; „posibil” = Cuvântul se poate
    forma din mână, „cel mai bun” = e cel mai puternic Cuvânt posibil):

    | Cuvânt | posibil | cel mai bun | Putere × Rezonanță (nivel 1) | + pe nivel |
    |---|---|---|---|---|
    | Rună singură | 100% | 0% | 5 × 1 | +8 / +1 |
    | Pereche | 99,6% | 1,8% | 12 × 2 | +12 / +1 |
    | Două perechi | 80,7% | 27,7% | 22 × 2 | +18 / +1 |
    | Treime | 37,9% | 3,4% | 30 × 3 | +22 / +2 |
    | Neam | 29,9% | 13,9% | 36 × 3 | +22 / +2 |
    | Familie | 29,4% | 25,8% | 42 × 4 | +26 / +2 |
    | Șir | 23,8% | 22,3% | 48 × 4 | +28 / +2 |
    | Patru | 3,7% | 3,5% | 70 × 6 | +34 / +3 |
    | Descântec | 1,5% | 1,5% | 110 × 8 | +42 / +4 |
    | Cuvântul Vechi | 0,16% | 0,16% | 160 × 12 | +50 / +4 |

  - Concluzie: cu 3 Neamuri × 8 Poziții, fiecare Poziție apare de 6 ori în săculeț, deci **Perechea e aproape sigură**,
    iar **Șirul e mai rar decât Neamul și Familia**. Ordinea „mai rar = mai puternic” devine: Rună singură < Pereche <
    Două perechi < Treime < Neam < Familie < **Șir** < Patru < Descântec < Cuvântul Vechi (câmpul `rank` din
    `words.json`). Valorile sunt propunerea lui Claude, nu cele din Balatro.
  - **Runda de test:** ținta 1 500 (`rules.json` → `test_round_target`). O strategie lacomă simplă (simulator) face
    în medie ~2 500 pe rundă și trece ~89% din runde.
  - **Glasurile** sunt toate în date (`runes.json` → `effects`). Handleri speciali în cod (lista scurtă din 2.2):
    `kenaz_peek`, `gebo_copy_left`, `algiz_ignore_rule`, `berkanan_copy`, `laguz_wild`.
  - Interpretări: Hagalaz punctează de 2 ori (Putere + Glas); Ehwaz face piatra din dreapta (în Cuvânt) să mai
    puncteze o dată; Gebo copiază Glasul pietrei din stânga ei din Cuvânt (nu al altui Gebo); Ansuz ridică nivelul
    Cuvântului doar dacă punctează; Berkanan adaugă o copie a unei pietre aleatorii din Cuvânt, o dată pe rundă;
    Algiz contează dacă e rostită (nu trebuie să puncteze); Jera plătește la finalul rundei.
  - **Primele 8 Vrăji** (din tabelul 3.15) au efecte. Moștenirea (Talisman) și Hramul (Piața la jumătate de preț) se
    notează în rundă, dar se simt abia în Etapa 3, când există Talismane și Piață. Steaua dublează Rezonanța la final,
    înainte de înmulțire. Descoperirea unei Vrăji dă **+5 Amintiri** (`memories_per_spell`).
  - Easter egg F-U-Þ-A-R: un Descântec cu Fehu, Uruz, Thurisaz, Ansuz, Raidho în ordine afișează un mesaj special.
- **Etapa 2½, pasul C — ajutorul permanent și indiciile (propuneri de verificat de Relax):**
  - Indiciile stau în `data/hints.json`: fiecare are fie un `trigger` (eveniment + `rune` / `seconds` / `max_exams`),
    fie `follows` (vine imediat după alt indiciu, ca șirurile Tantei Vera și ale Aevei). Acum sunt pornite doar
    `first_laguz` și `idle_help`; restul au `"enabled": false` și se pornesc în etapa lor.
  - Bula de indiciu stă în dreapta ecranului, sub mijloc; un clic pe ea o închide. Indiciul se trece la „văzute” când
    apare (nu când e închis). Se ascunde cât timp e deschis meniul de pauză sau o carte.
  - Timpul „fără acțiune” se numără doar în rundă, nu în timpul animației de scor, al pauzei sau al cărților; orice
    mouse pe o piatră, selecție, Rostire sau Schimbare îl pune la zero.
  - „Primele 3 examene”: până la Etapa 3, fiecare „Joacă” din meniu numără ca o încercare (`attempts` din salvare).
  - Fișa cercului: mouse-ul pe mijlocul cercului arată Cuvântul, descrierea, câte pietre punctează, Putere ×
    Rezonanță și Vrăjile; pietrele care punctează strălucesc, celelalte selectate se estompează.
  - Cartea de rune (din pauză): runele pe Neamuri (sens, Poziție, Putere, Glas), apoi Vrăjile. Vrăjile nedescoperite
    arată „???” și pietre goale — numărul pietrelor goale spune dacă Vraja are 2 sau 3 rune.
- **Etapa 2½, pasul D — documentele (propuneri de verificat de Relax):**
  - Secțiunea 3.17 „Instruirea și indiciile” rezumă ce s-a construit și regulile pentru etapele viitoare; aceleași
    reguli, pe scurt, sunt în `CLAUDE.md`.
  - Traducerile în engleză stau în `docs/TRADUCERI.md`, generat cu `python3 tools/export_translations.py` din
    `data/` (instruirea, indiciile, textele interfeței). Se regenerează după orice text nou.
  - Am corectat 5 rânduri în engleză: „Hold the mouse over” → „Hover over” (de 2 ori, ca în indiciul `idle_help`),
    „I'll manage alone” → „I'll manage on my own”, „a coin” → „a Coin” (ca „Coins” din interfață), „colour” →
    „color” (engleza americană, peste tot la fel), „alive at the exam” → „alive in the exam”.
- **Etapa 2b, pasul A — Gramatica runelor: datele și logica (propuneri de verificat de Relax):**
  - Fiecare rună are `role` și `phrase` în `runes.json`. Cele 64 de vrăji stau în `data/spells_base.json` (id-ul e
    `<element>_<țintă>`, de ex. `isaz_tiwaz` = Iarna), cele 8 Acțiuni în `data/spell_actions.json`, limitele în
    `data/economy.json`. Vechiul `spells.json` (cele 8 Vrăji cu rețete) a fost scos.
  - Numele propuse pentru toate cele 64 de vrăji sunt în `spells_base.json` (cele date de Relax au rămas: Iarna,
    Ziua lungă, Târgul, Furtuna, Valul, Lecția, Jarul de mâine). Culoarea strălucirii vine de la Element.
  - **Lecțiile 1–3 au vrăjile oprite și citesc pietrele de la stânga la dreapta, ca înainte.** Motiv: Glasurile Gebo,
    Ehwaz și Tiwaz citesc acum ordinea de rostire, iar Familia din Lecția 2 ar fi dat între 900 și 6 528 de puncte după
    ordinea clicurilor (ținta e 3 000). Ordinea contează abia din Lecția 4, care o predă.
  - Lecția 4 e deja cea nouă (altfel nu mai mergea fără vechile Vrăji). Pasul 8 e împărțit în două: întâi alegi Uruz →
    Ehwaz → Fehu, apoi „Rostește.”. Ținta e 300, ca lecția să nu se câștige din greșeală. Pasul D o finisează (lumina
    pe semnele rolului și pe propoziție vine cu Pasul B).
  - Interpretări:
    - Gebo copiază Glasul pietrei rostite chiar înaintea ei, chiar dacă aceea nu punctează. Ehwaz face să mai puncteze
      piatra rostită după ea, doar dacă aceea punctează. Tiwaz: ×2 dacă e prima piatră rostită.
    - Raidho pe o vrajă „single” (Ciobul, Altoiul) atinge toate pietrele din mână, la jumătate de putere.
    - „×1,5” pe un multiplicator crește doar partea de bonus: ×1,5 la putere dublă e ×2, întins de Raidho e ×1,75.
    - Valorile întregi (Monede, pietre) se rotunjesc.
    - O Acțiune care nu are ce schimba (de ex. Raidho, Berkanan, Perthro, Naudiz sau Jera pe o vrajă fără număr, sau
      Jera pe o vrajă „înainte”) nu face nimic; vraja merge normal.
    - Jera pe o vrajă „mai târziu” o înregistrează la finalul rundei.
    - Eihwaz: la începutul următoarelor 2 runde vraja se repetă la jumătate de putere. Dacă e o vrajă „înainte”, se
      aplică primei Rostiri a rundei.
    - Gebo: dacă locul de Pergament e plin, vraja se aplică pe loc. Pergamentul folosit se aplică împreună cu
      următoarea Rostire.
    - Naudiz: prețul se alege după Rostire; fără 4 Monede, se plătește cu o Rostire.
    - Bâlbâiala scade nivelul Cuvântului înainte de scor, deci Rostirea de acum punctează deja cu nivelul mai mic.
    - Revărsarea nu urcă niciodată într-un Cuvânt ascuns (n-ar trebui să-i dea numele).
    - Alegerea (Soarele în Mână): piatra păstrată intră în mână peste cele 8.
    - Prima rostire a unei propoziții descoperă vraja chiar dacă Perthro a ratat sau Gebo a pus-o pe Pergament.
  - **Alegerile** (piatra de spart, Neamul nou, ordinea din săculeț, prețul lui Naudiz…) stau în `RoundState.pending`.
    Până la Pasul B, ecranul de rundă le răspunde singur, cu o regulă simplă: sparge sau aruncă pietrele cele mai slabe,
    copiază-o pe cea mai puternică, plătește în Monede dacă ai.
  - Vrăjile spre Talismane și Examinator se citesc deja ca propoziții, dar „dorm” (`enabled: false`) până în Etapa 3.
- **Etapa 2b, pasul B — Gramatica runelor: interfața (propuneri de verificat de Relax):**
  - **Semnul rolului** e desenat din cod (`scripts/ui/role_sign.gd`) în colțul din dreapta sus al pietrei, în culoarea
    os: triunghi plin (Element), săgeată (Acțiune), cerc cu punct (Țintă). Apare și pe pietrele mici din Cartea de rune
    și din panoul de alegeri. În Lecțiile 1–3 (vrăjile oprite) pietrele n-au semn și nici numere de ordine.
  - **Numărul de ordine** e un disc os, sus pe mijlocul pietrei selectate. Deselectezi o piatră → celelalte se
    renumerotează. Sortarea golește selecția (ca înainte).
  - **Propoziția** (`scripts/ui/sentence_bar.gd`) stă sub cerc. Fiecare cuvânt e un locaș cu runa, semnul rolului și
    fraza, cu săgeți între ele. Cât timp lipsește Ținta, ultimul locaș e gol („…”). Dedesubt apare unul din mesaje:
    - „???”, pentru o vrajă nedescoperită;
    - numele și efectul, pentru una descoperită, cu valorile schimbate de Acțiuni (Perthro nu se aruncă în
      previzualizare, iar „de 2 ori” pentru Ehwaz e scris separat);
    - „propoziție neterminată”, „Ordinea e greșită…” sau „Propoziția e întreruptă…”;
    - „„se întinde” nu schimbă nimic aici”, pentru o Acțiune fără efect.
  - Ca să încapă propoziția între cerc și mână, **cercul e puțin mai mic** (470 → 440 px). Textul vrăjii nu mai stă în
    cerc. Mesajele scurte (Toast) apar în locul propoziției, care se golește la Rostire.
  - **Alegerile au panoul lor** (`scripts/ui/choice_panel.gd`), deasupra mâinii, cu numele vrăjii în culoarea ei:
    - pietrele din mână le alegi chiar în mână (fără numere de ordine), iar „Gata” se aprinde când numărul e corect;
    - la Înfierea alegi și Neamul;
    - prețul lui Naudiz are două butoane („1 Rostire” / „4 Monede”; al doilea e stins dacă n-ai bani);
    - Prevestirea arată primele 5 pietre din săculeț, pe care le apeși în ordinea dorită; „Lasă așa” le păstrează
      ordinea;
    - Alegerea arată cele 3 pietre trase: apeși una.
    Într-un pas de instruire care nu te lasă să selectezi, runda răspunde singură, ca înainte.
  - **Pergamentul** (`scripts/ui/scroll_slot.gd`) stă deasupra butoanelor Rostește/Schimbă:
    - gol, e un contur punctat;
    - plin, e un pergament cu numele vrăjii;
    - un clic îl pregătește (strălucește: „pleacă la următoarea Rostire”), al doilea clic îl pune la loc.
    Are fișă la mouse cu efectul. Când se folosește, un mesaj spune „Din Pergament · Târgul: +4 Monede”.
  - **Animația mică pentru o Acțiune nouă** (`scripts/ui/action_learned.gd`): runa apare peste cerc într-un inel care
    se deschide, cu „Ai învățat · aleargă de două ori” și ce face Acțiunea. Pleacă singură după ~3 secunde și nu
    blochează jocul.
  - **Cartea de rune** are două file: „Runele” (cu rolul fiecărei rune) și **„Tabla Vrăjilor”**. Tabla e o grilă
    8 × 8: Elementele pe coloane, Țintele pe rânduri, în ordinea din `GRAMATICA.md`.
    - O căsuță descoperită arată numele în culoarea vrăjii; cea nedescoperită arată „?”.
    - Vrăjile spre Talismane și Examinator sunt estompate („·”) până în Etapa 3.
    - Fișa la mouse a fiecărei căsuțe arată propoziția și, dacă vraja e descoperită, efectul.
    - Dedesubt sunt cele 8 Acțiuni: fraza, plus ce face Acțiunea dacă ai folosit-o, altfel un îndemn.
    - Numărul de sus („3 din 48”) numără doar vrăjile active.
  - Fișa pietrei are rândul „Element — Gheața” (sau Acțiune / Țintă).
  - Indiciile nu mai apar peste animația mare de descoperire. EventBus are acum `overlay_opened`/`overlay_closed`, iar
    indiciile se ascund cât e ceva peste joc.
  - Lecția 4: pașii 4 și 7 luminează propoziția de sub cerc (`sentence`), nu cercul.
- **Etapa 2b, pasul C — balansul Gramaticii (simulatorul, `godot --headless --script tests/simulate.gd -- part=3`):**
  - Partea 3 a simulatorului joacă 150 de examene de câte 3 runde (450 de runde). Ținta e 1 800 pe rundă, aleasă ca
    jocul fără vrăji să piardă cam o rundă din patru. Vrăjile care țin mai mult de o rundă se moștenesc între runde.
  - Patru strategii:
    - **off**: fără vrăji;
    - **greedy**: cel mai bun Cuvânt, vrăjile doar din întâmplare;
    - **seek**: rostește o vrajă dacă Cuvântul ei valorează cel puțin jumătate din cel mai bun;
    - **seek2**: la fel, dar cel mult 2 vrăji pe rundă.

    | strategia | runde câștigate | scor final / țintă (median) | Rostiri cu vrajă | runde la limita de 40% |
    |---|---|---|---|---|
    | off | 74,9% | 1,11× | 0% | 0% |
    | greedy | 80,2% | 1,15× | 34% | 0,7% |
    | seek | 80,2% | 1,24× | 80% | 2,0% |
    | seek2 | 78,0% | 1,19× | 60% | 2,4% |
  - **Concluzii:**
    - Vrăjile apar ușor: o treime din Rostiri au una din întâmplare, 80% dacă le cauți.
    - Totuși **nu fac jocul prea ușor**: +5 puncte procentuale de runde câștigate și +12% scor median.
    - Limita de 40% la țintă se atinge rar (2% din runde).
    - Varianta „cel mult 2 vrăji pe rundă” nu e necesară acum: dă un rezultat puțin mai slab, iar jocul nu e prea ușor.
    - Nu propun nici vrăji simple mai slabe.
  - **Vrăji prea puternice** (pe Rostirea lor, comparat cu o Rostire fără vrajă, care urcă scorul cu ~0,48 din țintă):
    - Rana (×3 Rezonanță, sparge o piatră): 5,3×;
    - Revărsarea (Cuvântul urcă un rang): 3,9×;
    - Văpaia (×1,5): 2,4×;
    - Lumina plină (×2 cu 5 pietre): 2,4×;
    - Răbdarea (+3 Rez. pentru fiecare piatră din mână): 2,2×;
    - Bâlbâiala (punctează de două ori, Cuvântul −1 nivel): 2,1×.
    Toate sunt vrăji „înainte”, pe Cuvânt, firești ca cele mai tari. **Propunere:**
    - Rana ×3 → ×2,5;
    - Revărsarea rămâne, dar o urmărim în Etapa 3 (cu Lecțiile poate deveni prea bună);
    - celelalte rămân.
  - **Vrăji slabe acum:**
    - **Asaltul** (ținta scade cu Puterea Rostirii) scade ținta doar cu ~3,6%, fiindcă Puterea e mică față de țintă.
      **Propunere:** ținta scade cu de 3 ori Puterea (`percent` 100 → 300).
    - Încurajarea, Ziua lungă, Merindea, Avântul și Cămara cântăresc puțin pe Rostirea lor. Rostirea în plus,
      Monedele și runda următoare se văd abia în examenul complet. **Propunere:** le judecăm în Etapa 3, cu Piața și
      țintele reale.
    - Vrăjile cu Monede (Târgul, Ciobul, Izvorul, Camăta) dau 5–14 Monede. Încă nu au pe ce le cheltui, deci se pot
      judeca abia în Etapa 3.
  - **Nicio valoare nu e schimbată până nu decide Relax.**
- **Etapa 2b, pasul D — instruirea și documentele:**
  - Lecția 4 e cea din `GRAMATICA.md` 6:
    - pasul 2 luminează semnele de pe Isaz, Tiwaz și Ehwaz;
    - pașii 4 și 7 luminează propoziția de sub cerc;
    - pasul 8 aduce animația mică „Ai învățat: aleargă de două ori” și +8 Monede.
    Pasul 8 din spec e împărțit în „alege” + „Rostește.” (10 pași în loc de 9), ca să poată fi verificată ordinea
    înainte de Rostire.
  - Indiciile `first_wrong_order`, `first_scroll` și `first_two_actions` sunt pornite. Vin din evenimentele EventBus
    `sentence_read` (statusul `wrong_order`), `scroll_gained` și `spell_sentence_cast` (cu 2 Acțiuni). Ca toate
    indiciile, tac în instruire.
  - Secțiunea 3.15 e rescrisă ca „Gramatica runelor”; 3.17 are fișa cu rolul, Tabla Vrăjilor și indiciile noi.
  - Traducerile în engleză (frazele runelor, cele 64 de nume și efecte, cele 8 Acțiuni, textele noi ale interfeței)
    sunt în `docs/TRADUCERI.md`, generat cu `python3 tools/export_translations.py`.

- **Balansul cerut de Relax după Etapa 2b:** Rana ×3 → **×2,5**; Asaltul scade ținta cu **300%** din Puterea Rostirii
  (în loc de 100%).
- **Etapa 3 — examenul complet (propuneri de verificat de Relax):**
  - **Fluxul:** „Joacă” → panoul Probei (Proba n din 8, runda, Examinatorul cu portret, ținta; în runda a treia
    regula și replica lui) → runda → panoul cu Monedele câștigate → Piața de noapte → runda următoare. La final:
    „Ai picat” (replica Examinatorului și a Aevei, Proba atinsă, Examinatori învinși) sau „Ai trecut Examenul de
    Moștenire!”. Alegerea părintelui, Dimineața și salvarea examenului în curs vin în Etapa 4; până atunci examenul
    pornește cu săculețul standard de 48.
  - **Examinatorii:** cei 10 (fără Aeva) se amestecă după seed; 7 dintre ei apar în Probele 1–7, Aeva mereu în a 8-a.
    Examinatorul stă la catedră toată Proba (portretul), dar regula lui se aplică doar în runda a treia.
  - **Regulile, așa cum le-am înțeles:**
    - Kaldor: Rostește nu merge decât cu exact 5 pietre (sau toate, dacă ai mai puține în mână).
    - Selvia: după fiecare Rostire, toată mâna se întoarce în săculeț și tragi 8 noi.
    - Varr: o piatră aleatorie din Cuvânt nu punctează („nu punctează” deasupra ei).
    - Ignar: fiecare Schimbare costă 1 Monedă; fără bani, nu poți schimba.
    - Lunet: primele 3 pietre din fiecare tragere vin cu fața în jos. Cât timp o piatră e cu fața în jos, cercul
      ascunde și Cuvântul, ca să nu-l ghicești din previzualizare.
    - Gronn: pietrele cu Poziția 1–3 nu punctează (dar Glasurile celorlalte merg).
    - Morrah: un Cuvânt deja rostit în rundă dă scor 0.
    - Ilinca: Rună singură și Pereche dau 0.
    - Dara: ținta crește cu 10% după fiecare Rostire.
    - Nix: primul Talisman din stânga e oprit (se vede estompat).
    - Aeva: o singură Rostire și Schimbări fără sfârșit; primele 3 gratis, apoi 1 Monedă fiecare. Pentru că e o
      singură Rostire, ținta ei e mai mică (`target_mult`, vezi balansul).
  - **Indiciul lui Kaldor** („Eu sunt Kaldor…”) apare prima dată când îl întâlnești pe Kaldor; la primul Examinator,
    oricare ar fi el, Ilinca spune un indiciu nou (`first_rule`) despre regula de pe fișă.
  - **Talismanele:** am ales 15 din tabelul din 3.6. **Pecetea Curții Moștenirii** rămâne pentru final (e și în
    poveste). Nix copiază Talismanul din dreapta lui; dacă în dreapta e alt Nix sau nimic, nu face nimic. Umbrela lui
    Varr dă Rezonanța la fiecare punctare (Hagalaz, care punctează de două ori, o dă de două ori). Bricheta face
    prima piatră care punctează să mai puncteze o dată. Clepsidra Aevei se sparge la prima rundă picată și runda se
    reia de la capăt (aceeași țintă, săculețul cum era).
  - **Gravurile:** le folosești în rundă, cu clic pe ele, apoi alegi pietrele în mână (panoul de alegeri). Lecțiile
    se învață oriunde. Lecțiile luate dintr-un Săculeț se învață pe loc; Gravurile din Săculeț merg în cele 2 locuri.
  - **Săculețul cu pietre:** 3 pietre noi cu rune aleatorii, 30% cu un material.
  - **Valorile economiei sunt ale noastre**, nu cele din Balatro (recompensele, Rostirile rămase, dobânda, prețurile).
  - **Balansul examenului** (`tests/simulate.gd -- part=4 exams=120`): un jucător simplu joacă examene întregi.
    Alege cel mai bun Cuvânt, vrăjile îi ies din întâmplare, schimbă pietrele la Cuvintele slabe, folosește Gravurile
    la început de rundă și învață Lecțiile pe loc. În Piață cumpără întâi cel mai scump Talisman pe care și-l permite,
    apoi Lecții, apoi Săculețe.
    - Țintele de bază ale Probelor (`data/trials.json`): **800, 2 600, 6 200, 10 500, 16 000, 25 000, 40 000,
      62 000**. Întrebarea mare e ×1,5, Examinatorul ×2. Aeva are ×0,4 din ×2, pentru că are o singură Rostire.

      | Proba | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 (Aeva) |
      |---|---|---|---|---|---|---|---|---|
      | trecută | 98% | 95% | 79% | 63% | 43% | 31% | 18% | 7% |

    - Examenul întreg e trecut în ~7% din încercări. La final rămân în medie ~15 Monede și ~4,7 Talismane.
    - Un jucător nou e mai slab decât acest jucător simulat, deci ar trebui să fie aproape de ținta din 3.14 (Proba 1
      aproape mereu, Proba 3 ~50%). Testul lui Relax spune dacă e așa.
    - Examenele se termină cel mai des la Aeva, la Întrebările mari din Probele 3–7 și la Morrah, Ilinca și Varr.
  - **O reparație găsită de simulator:** Mareea („tragi 12, păstrezi 8”), repetată de Acțiuni, putea aduna zeci de
    pietre în plus la începutul rundei. Acum sunt cel mult 8 (`spell_max_extra_draw` în `economy.json`). Alegerea „pune
    înapoi” de la începutul rundei apare pe ecran ca orice altă alegere.
- **Etapa 4 — bucla Aevei (propuneri de verificat de Relax):**
  - **Fluxul:**
    - „Joacă” duce în Dimineață, unde poți continua examenul salvat sau începe unul nou;
    - pentru un examen nou alegi părintele, apoi urmează Probele;
    - la final vezi Amintirile câștigate, apoi „Aeva întoarce timpul” și te întorci în Dimineață;
    - Cursul de seară se termină tot în Dimineață.
  - **Prețurile în Amintiri** sunt ale mele:
    - părinții: Ignar 40, Gronn 80, Morrah 120;
    - Talismanele: Semnul de carte și Toma 20, Nix și Dara 30, Clepsidra 50.

    Vrăjile descoperite dau multe Amintiri (5 fiecare, până la 320 în total). Cu prețuri mai mici, botul care
    joacă la întâmplare debloca tot în 2–3 examene; acum îi trebuie în jur de 10.
  - **Balansul părinților** (`simulate.gd -- part=4 exams=100 parent=…`, același jucător simplu):

    | Părintele | P3 | P5 | P7 | examen trecut |
    |---|---|---|---|---|
    | fără | 84% | 46% | 21% | 9% |
    | Varr | 96% | 69% | 31% | 11% |
    | Selvia | 80% | 45% | 19% | 9% |
    | Ignar | 85% | 48% | 19% | 5% |
    | Gronn | 85% | 41% | 18% | 9% |
    | Morrah | 81% | 50% | 26% | 8% |

    Varr (+1 Rostire) e cel mai puternic, deși e părintele de la început. Rostirea în plus aduce și 2 Monede la
    fiecare rundă, prin Rostirile rămase. De decis de Relax: rămâne așa (un început mai blând) sau îl slăbim.
  - **Două erori găsite de botul care joacă prin ecrane (reparate, cu teste):**
    - o rundă care începe deja câștigată (Merindea adusese mai mult scor decât noua țintă) nu se mai termina; acum
      se termină pe loc, cu un mesaj;
    - Furtuna repetată de Eihwaz la începutul rundei arunca mâna fără să tragă alta, iar runda rămânea fără pietre.
      Acum trage o mână nouă. Și o rundă fără nicio piatră de tras se termină singură.
