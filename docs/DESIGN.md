# Designul Jocului 1 — „Examenul de Moștenire” (EN: „The Inheritance Exam”) — v3

> Document viu: se actualizează când se schimbă designul. Valorile exacte stau în `data/*.json`.
> v1 (deckbuilder cu lupte) și v2 (cercul runic) sunt **înlocuite** de v3.

## 1. Viziunea
- Gen: **roguelike de construit scoruri, cu rune în loc de cărți**, în spiritul Balatro.
- În loc de un pachet de cărți ai un **Săculeț cu pietre de rune**. Tragi pietre în mână și **rostești Cuvinte**
  (combinații de rune). Fiecare Cuvânt dă un scor. Ca să treci o rundă, atingi scorul cerut de examinator.
- Cele **24 de rune sunt runele istorice reale (Futharkul vechi)**. **Fiecare rună are un efect („Glasul” ei)
  inspirat din sensul ei real** — asta ne face diferiți de Balatro.
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
1. Cuvântul rostit dă **Puterea** și **Rezonanța** de bază (în funcție de nivel).
2. **Pietrele care formează Cuvântul** punctează una câte una, de la stânga la dreapta: Puterea pietrei, apoi
   materialul și Glasul. Pietrele rostite care nu fac parte din Cuvânt nu punctează.
3. Efectele pietrelor rămase în mână (de ex. Isaz).
4. **Talismanele**, de la stânga la dreapta.
5. **Scor = Putere × Rezonanță**, adunat la scorul rundei.

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

## 3.8 Probele și Examinatorii
- **8 Probe** × 3 runde: **Întrebarea mică** (ținta de bază), **Întrebarea mare** (×1,5), **Examinatorul** (×2 + regulă).
- Curba țintelor: de propus și verificat cu simulatorul (fără valori din Balatro).
- **Monede:** recompensă după fiecare rundă câștigată + mic bonus pentru Rostirile rămase + mică dobândă la economii
  (cu plafon). Valori în `economy.json`. Economie simplă.
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

## 3.10 Părinții divini (= săculețul de start)
| Părinte | Bonus | Deblocare |
|---|---|---|
| Varr | +1 Rostire în fiecare rundă | de la început |
| Selvia | +1 Schimbare în fiecare rundă | după prima încercare |
| Ignar | începi examenul cu 2 Gravuri aleatorii | Amintiri |
| Gronn | +1 loc de Talisman, dar −1 piatră în mână | Amintiri |
| Morrah | săculeț de doar 24 de pietre (câte una din fiecare rună); mai greu, dar fiecare piatră contează (Patru și Cuvântul Vechi devin imposibile fără Dubluri) | Amintiri, pentru jucători avansați |

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

## 3.12 Povestea (scurtă)
- **Intro de 4–5 cadre:** 1) Coborârea zeilor; 2) oamenii găsesc 24 de semne vechi pe pietre, mai vechi decât orice
  zeu; 3) Orașul Pragului azi; 4) convocarea la Examenul de Moștenire; 5) prima întâlnire cu Aeva.
- Replicile examinatorilor, ale Aevei și ale lui Tanti Vera.
- **Finalul**, după Aeva: o scenă scurtă cu Pecetea și un indiciu despre misterul runelor.

## 3.13 Senzația
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
