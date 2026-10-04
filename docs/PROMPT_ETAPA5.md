# ETAPA 5 — Marea schimbare: Lumea, magia care face daună, runele rare și stilul nou

> Copiat din mesajul lui Relax (4 octombrie 2026). Are prioritate față de `docs/GRAMATICA.md` (fostul
> `PROMPT_GRAMATICA.md`), `docs/INSTRUIRE.md` (fostul `PROMPT_INSTRUIRE.md`) și promptul de start acolo unde se
> contrazic. Imaginile de referință sunt în `docs/referinte/` (`meniu`, `sfarsit_runda`, `piata`, `sac`, `compendiu`;
> `lupta` lipsește încă). Planul de migrare: `docs/PLAN_ETAPA5.md`.

---

## 0. Cum lucrăm
- Etapele 1–4 sunt gata. Documentul ăsta **schimbă mult**: conceptul jocului, sistemul de scor, runele și tot aspectul.
- Are prioritate față de `PROMPT_START.md`, `PROMPT_GRAMATICA.md` și `PROMPT_INSTRUIRE.md` acolo unde se contrazic. Scrie asta în `CLAUDE.md`.
- Regulile din `CLAUDE.md` rămân: lucrezi pe pași, te oprești după fiecare, îmi spui ce ai făcut și cum testez, faci commit și aștepți OK-ul meu.
- **Pasul A nu schimbă cod.** Faci doar planul de migrare și mi-l arăți. Nu ștergi nimic până nu-ți dau OK.
- Uită-te la imaginile din `docs/referinte/`. Ele arată **atmosfera** pe care o vreau. Secțiunea 10 spune ce luăm din ele și ce facem mai bine.

---

## 1. Noua viziune
> Ești un semizeu de 16 ani. Treci Examenul de Moștenire (instruirea, 3 lecții), apoi ieși din Orașul Pragului în **lumea mare**, plină de creaturi din basmele românești. Le învingi cu **magia runelor**: pui runele în ordinea corectă și formezi vrăji. **Dauna vine din vrajă, nu din rune.** Fiecare drum e altfel (roguelike, în stilul Balatro). Fiecare drum terminat deschide un **Cerc** nou: mai greu, dar cu puteri și rune mai bune.

**Decizii luate deja (dacă vreuna ți se pare greșită, spune-mi înainte să o construiești):**
1. **Scorul = dauna vrăjilor.** Cuvintele de tip poker (Pereche, Șir, Familie…), Cartea Cuvintelor și **Poziția** runelor dispar.
2. **Cele 24 de rune de bază nu mai au Glas propriu.** Sunt „literele” magiei: au doar **Rol** și **Neam**. Efectele speciale stau pe **runele rare** (12 rare, 6 extra rare, 3 ultrarare). Așa o piatră de bază se citește dintr-o privire.
3. **Neamul rămâne:** dacă rostești doar pietre din același Neam, primești bonus.
4. **Monștri în loc de ținte.** Fiecare luptă e cu un monstru cu viață, slăbiciuni și rezistențe. Jucătorul are **Viață (5 inimi)**.
5. **Instruirea = Examenul, în 3 lecții.** Înlocuiește cele 5 lecții de acum.
6. **Monștrii vin din folclorul românesc** (strigoi, iele, zmei, balauri…). Asta ne face diferiți de mii de jocuri cu dragoni și schelete.
7. **Cercurile = dificultățile.** Fiecare e mai greu, dar aduce și un avantaj nou.
8. **Stil nou, după imagini:** dark fantasy gotic, luminat de lumânări și jar. Fonturi noi: **Cinzel + Alegreya + Alegreya Sans**.
9. **Numele „RuneBound” nu-l folosim:** e numele unui joc de societate existent (Fantasy Flight Games). Pune titlul într-o singură constantă (`GAME_TITLE`), ca să-l schimb ușor. Până aleg altul, rămâne „Examenul de Moștenire”.

---

## 2. Ce rămâne, ce se schimbă, ce dispare
| Rămâne | Se schimbă | Dispare |
|---|---|---|
| săculețul, mâna de 8, Rostirile (4), Schimbările (3) | ținta rundei → **viața monstrului** | Cuvintele poker și Cartea Cuvintelor |
| gramatica Element → Acțiune → Țintă, ordinea de selecție | **Țintele** primesc sens de luptă (secțiunea 5) | **Poziția** runelor |
| Acțiunile, Pergamentul (Gebo) | **Lecțiile** cresc nivelul unui **Element** | **Glasurile** celor 24 de rune de bază |
| descoperirea vrăjilor, Tabla Vrăjilor 8 × 8 | Examinatorii → doar în Examen + **Stăpânii Ținuturilor** (boși) | cele 8 Probe ca structură a jocului |
| Talismane, Gravuri, Piața, Aeva, Amintiri, hub-ul | Neamul → **bonus de Neam** | efectul „linii care fierb” și granulația |
| salvarea, EventBus, indiciile, sistemul de instruire | instruirea → **3 lecții**; tot stilul vizual și fonturile | |
| Cuvintele vechi ascunse (ALU, LAÞU, AUJA), ca secrete | | |

**Salvările vechi:** crește versiunea salvării. Păstrezi numele jucătorului și setările; progresul se resetează. Spune-mi ce se pierde.

---

## 3. Structura jocului
```
Prima pornire → nume → EXAMENUL (3 lecții) → Pecetea → hub: Orașul Pragului
Hub → alegi Cercul + părintele divin (săculețul de start) → DRUMUL
Drumul = 8 Ținuturi. Fiecare Ținut:
   Monstru mic → Piață → Monstru mare → Piață → Stăpânul Ținutului (boss) → Piață
Ținutul 8 se termină cu bossul final.
Câștigi → se deschide Cercul următor.   Rămâi fără inimi → Aeva te întoarce în hub → Amintiri.
```
- **Viața:** 5 inimi la începutul Drumului.
  - **Monstru mic sau mare:** dacă nu-l omori până la ultima Rostire, te lovește: **−1 inimă** și trece mai departe, fără recompensă.
  - **Boss:** dacă nu-l omori, **−2 inimi** și lupta reîncepe. **Bossul își păstrează rănile.**
  - La 0 inimi, Drumul se termină.
- **După fiecare luptă câștigată:** ecranul „Sfârșit de luptă” (ca în imaginea `sfarsit_runda`):
  - în stânga, rezultatele;
  - în centru, **alegi 1 din 3 recompense** (Rună / Talisman / Binecuvântare);
  - în dreapta, detaliile recompensei selectate;
  - butoane: **Sari** (iei Monede în loc), **Alege**, **Continuă**.
- **Examenul** se poate reface oricând din meniu.

---

## 4. Lupta
- **Monstrul** apare sus, în centru: portret mare, nume, **bara de viață**, iconițele de **slăbiciuni** (×2), **rezistențe** (×0,5) și **imunități** (×0).
  - Unii monștri au o **trăsătură** (Scut, Regenerare, Furie…). Boșii au și o **regulă**, ca fostii examinatori.
- **Bara de viață** scade în două etape: partea roșie scade imediat, iar în spatele ei o bară albă „fantomă” scade cu o mică întârziere. Așa dauna se simte.
- **Previzualizarea:** în cercul de rune vezi propoziția vrăjii, dauna estimată față de monstru (cu slăbiciunea sau rezistența aplicată) și eticheta **„Ucide!”** dacă dauna sigură ajunge pentru viața rămasă. Șansele (Perthro) nu intră în estimarea sigură.
- **Monștrii nu atacă pe ture.** Presiunea vine din numărul limitat de Rostiri și din trăsături și reguli.

---

## 5. Magia face dauna
### 5.1 Formula
Pentru fiecare vrajă din Rostire:
```
Dauna = Putere × Rezonanță × multiplicatorul monstrului pentru Element × partea Țintei
```
- **Elementul** dă Puterea și Rezonanța de bază (cresc cu nivelul, prin Lecții) și o **natură** (un mic efect propriu).
- **Acțiunile** modifică vraja.
- **Ținta** decide cât din daună ajunge la monstru și ce efect în plus are.
- Pietrele de bază **nu dau puncte**. Puterea vine din vrajă, din nivelul Elementului, din Talismane și din runele rare.

### 5.2 Propoziția (din Gramatica, cu două schimbări)
- Ordinea de rostire = ordinea în care selectezi pietrele (numerotate 1–5).
- Forme valide, cu pietrele una după alta: **E → Ț**, **E → A → Ț**, **E → A → A → Ț**.
- **Schimbare 1: până la 2 vrăji într-o Rostire** (de exemplu E→Ț + E→A→Ț = 5 pietre). Daunele se adună, iar **a doua vrajă primește +25%** („lanț”).
- **Schimbare 2: bonusul de Neam.** Dacă toate pietrele rostite (minimum 3) sunt din același Neam, toate vrăjile primesc **×1,5 Rezonanță**.
- Pietrele rostite care nu fac parte dintr-o vrajă nu fac nimic. Doar se consumă.
- Ordine greșită = nicio vrajă, iar previzualizarea explică de ce.

### 5.3 Elementele (valori orientative la nivelul 1; balansează)
| Element (rună) | Putere × Rezonanță | Natura |
|---|---|---|
| Focul (Kenaz) | 18 × 2 | **Arsură:** monstrul pierde 3 la fiecare Rostire următoare (se adună, maximum 3 straturi) |
| Forța (Uruz) | 30 × 1 | **Zdrobire:** ignoră Scutul |
| Spinul (Thurisaz) | 10 × 2 | +1 Rezonanță pentru fiecare Acțiune din vrajă |
| Gheața (Isaz) | 14 × 2 | **Îngheț:** monstrul nu-și folosește trăsătura sau regula la următoarea Rostire |
| Grindina (Hagalaz) | 8 × 2 | **Ploaie:** lovește de 3 ori (fiecare lovitură contează separat pentru Talismane) |
| Soarele (Sowilo) | 16 × 2 | **Lumină:** ×2 contra creaturilor nopții (strigoi, moroi, iele) |
| Apa (Laguz) | 15 × 2 | **Val:** ignoră rezistențele (nu și imunitățile) |
| Ziua (Dagaz) | 12 × 2 | **Timp:** +25% daună pentru fiecare Rostire rămasă |

- O **Lecție** crește un Element cu 1 nivel (de exemplu +8 Putere, +1 Rezonanță; propune valorile).
- Tabla Vrăjilor păstrează nivelurile.

### 5.4 Acțiunile (adaptate pentru luptă)
| Acțiune (rună) | Ce face |
|---|---|
| se întinde (Raidho) | ce depășește viața monstrului trece la monstrul următor |
| aleargă de două ori (Ehwaz) | vraja lovește de 2 ori |
| durează (Eihwaz) | vraja lovește din nou la începutul următoarelor 2 Rostiri, cu jumătate din daună |
| crește (Berkanan) | +50% pentru fiecare dată când ai mai rostit aceeași vrajă în Drumul ăsta |
| se coace (Jera) | dauna vine după următoarea Rostire, dar dublă |
| riscă (Perthro) | 50%: ×3; 50%: nimic |
| cere un preț (Naudiz) | alegi pe loc: pierzi 1 Schimbare sau 3 Monede; vraja face ×2,5 |
| se dăruiește (Gebo) | vraja nu se aplică acum; devine **Pergament** și o folosești când vrei |

### 5.5 Țintele (adaptate pentru luptă)
| Țintă (rună) | Partea de daună | Efectul în plus |
|---|---|---|
| în Dușman (Tiwaz) | **100%** | natura Elementului e dublă (de ex. Arsură 6 în loc de 3) |
| în Monede (Fehu) | 50% | Monede, după Element (rândul „În Monede” din `PROMPT_GRAMATICA.md`) |
| în Săculeț (Othala) | 50% | îmbunătățiri permanente ale pietrelor (rândul „În Săculeț”) |
| în Tine (Mannaz) | 50% | **Scut de inimă** (oprește o pierdere de inimă) sau efecte de mână, după Element; propune tabelul |
| în Glas (Ansuz) | 50% | Elementul folosit crește permanent cu 1 nivel în Drumul ăsta |
| în Viitor (Ingwaz) | 0% acum | **200% la următoarea Rostire**, plus efectul din rândul „În Viitor” |
| în Talismane (Wunjo) | 50% | rândul „În Talismane” |
| asupra Stăpânului (Algiz) | 50% | anulează trăsătura sau regula monstrului (după Element: o Rostire, toată lupta etc.) |

- Tabelele de efecte cu 64 de vrăji din `PROMPT_GRAMATICA.md` le **adaptezi**: „ținta scade cu X%” devine „monstrul pierde X% din viață”, iar ce ținea de Cuvinte se scoate.
- Arată-mi tabelul nou complet înainte să-l implementezi.
- **Limite de siguranță** (în `economy.json`):
  - maximum 2 vrăji pe Rostire;
  - maximum +2 Rostiri pe luptă din efecte;
  - nicio vrajă nu poate scoate mai mult de 50% din viața unui boss dintr-o singură lovitură procentuală.

---

## 6. Runele
### 6.1 Cele 24 de rune de bază
- Rolurile rămân cele din `PROMPT_GRAMATICA.md`: 8 Elemente, 8 Acțiuni, 8 Ținte.
- **La început jucătorul are doar un sfert: 6 rune, câte 2 din fiecare rol:**
  - Elemente: **Kenaz (Focul), Isaz (Gheața)**;
  - Acțiuni: **Ehwaz (aleargă de două ori), Eihwaz (durează)**;
  - Ținte: **Tiwaz (în Dușman), Fehu (în Monede)**.
- **Săculețul de start:** 24 de pietre (câte 4 din fiecare dintre cele 6 rune). Părinții divini schimbă săculețul, de exemplu Varr are mai multe Elemente. Propune.
- **Deblocarea celorlalte 18:**
  - fiecare Stăpân de Ținut învins **prima dată** deblochează o rună nouă;
  - la **Cursul de seară** din hub, Maestra Ilinca te învață rune pe Amintiri.
  - Ținta: toate cele 24 deblocate după aproximativ 3–5 Drumuri.
- În Piață și la recompense apar **doar runele deblocate**.

### 6.2 Runele speciale (se deschid mai târziu)
| Raritate | Câte | Ce sunt | Se deschid |
|---|---|---|---|
| **Rară** | 12 | runele adăugate în alfabetul anglo-saxon (futhorc): rune istorice reale, fiecare cu un **rol + o putere specială** | după primul Drum terminat (Cercul 1) |
| **Extra rară** | 6 | **Legături străvechi:** o singură piatră cu **două roluri** (de ex. Element + Acțiune), deci o vrajă din mai puține pietre | Cercul 3 |
| **Ultrarară** | 3 | **Runele primordiale:** rune inventate, din misterul universului (mai vechi decât Coborârea). Pot fi **orice rol** și au o putere uriașă | Cercul 5, doar de la boși |

**Rarele (12): futhorc-ul anglo-saxon.** Glifele sunt reale. Sensul istoric e scris exact așa în Cartea de rune, cu „nesigur” acolo unde nu se știe.
| Rună | Nume | Sens istoric | Rol | Puterea (orientativ) |
|---|---|---|---|---|
| ᚪ | Āc | stejar | Element „Lemnul” | +2 Putere permanent de fiecare dată când e folosit |
| ᛡ | Īor | nesigur (o creatură care trăiește și în apă, și pe uscat) | Element „Mlaștina” | are ambele naturi: a Apei și a Forței |
| ᛠ | Ēar | pământ, mormânt | Element „Țărâna” | ×3 contra creaturilor nemuritoare (strigoi, moroi) |
| ᛢ | Cweorð | nesigur | Element „Flacăra albă” | ca Focul, dar Arsura nu are limită de straturi |
| ᚫ | Æsc | frasin | Acțiune „se ramifică” | dacă vraja ucide, ce depășește viața se dublează și trece mai departe |
| ᚣ | Ȳr | arc (interpretare obișnuită) | Acțiune „țintește” | ×2 dacă vraja lovește o slăbiciune |
| ᚸ | Gār | suliță | Acțiune „străpunge” | ignoră imunitățile și Scutul |
| ᛄ | Gēr | an (forma anglo-saxonă a lui Jera) | Acțiune „se întoarce” | vraja se repetă singură la începutul luptei următoare |
| ᚩ | Ōs | gura (în poemul runic englez) | Țintă „în Strigăt” | 100% daună + monstrul își pierde trăsătura pentru toată lupta |
| ᛣ | Calc | nesigur (poate potir, cretă sau sanda) | Țintă „în Potir” | 0% acum; dauna se adună în potir și se varsă la ultima Rostire, ×1,5 |
| ᛤ | Cealc | nesigur (înrudită cu calc) | Țintă „în Cretă” | 50% daună + descoperi toate vrăjile cu același Element |
| ᛥ | Stān | piatră | Țintă „în Zid” | 50% daună + un Scut de inimă |

**Extra rarele (6): Legăturile străvechi** (desenate ca două rune suprapuse). Contează ca **două pietre consecutive** în propoziție și au +25% daună:
| Legătura | Roluri |
|---|---|
| Kenaz + Ehwaz: „Focul care aleargă” | E + A |
| Isaz + Eihwaz: „Gheața care durează” | E + A |
| Hagalaz + Perthro: „Grindina care riscă” | E + A |
| Sowilo + Tiwaz: „Soarele în Dușman” (o vrajă dintr-o singură piatră) | E + Ț |
| Dagaz + Ingwaz: „Ziua în Viitor” | E + Ț |
| Gebo + Fehu: „Darul în Monede” | A + Ț |

**Ultrararele (3): Runele primordiale.** Glife **originale**, desenate de mine; nu litere istorice și nimic care seamănă cu simboluri extremiste. Pot fi orice rol (jucătorul alege rolul când o selectează):
| Rună | Puterea |
|---|---|
| Runa Pragului | vraja în care e folosită are ×3 Rezonanță |
| Runa Clepsidrei | după Rostire, toată Rostirea se repetă o dată |
| Runa Coborârii | consumă toate pietrele din mână: +100% daună pentru fiecare piatră consumată |

- **Raritatea se vede pe piatră:** comun = piatră gri; rar = muchii de cristal albastru; extra rar = violet; ultrarar = aur-jar, cu o strălucire animată.
- Gravura **Legătura** (deja existentă) îi lasă pe jucător să-și facă singur o legătură din două pietre de bază.

---

## 7. Piața, Talismanele, Binecuvântările
- **Piața** (ca în imaginea `piata`):
  - vânzătoarea sus, în centru (Tanti Vera, desenată mai târziu de mine);
  - **5 obiecte** pe tarabă;
  - în dreapta, detaliile obiectului selectat;
  - butoane: **Cumpără**, **Reîmprospătează** (prețul crește la fiecare apăsare), **Blochează** (păstrezi un obiect pentru vizita următoare; costă puțin) și **Pleacă**.
- **Ce se vinde:**
  - **Rune** (pietre noi pentru săculeț; doar cele deblocate, rarele în funcție de Cerc);
  - **Talismane** (5 locuri, efecte pasive; le păstrezi pe cele care se potrivesc cu noul sistem și le rescrii pe cele care țineau de Cuvinte);
  - **Lecții** (cresc un Element);
  - **Gravuri** (modifică pietrele);
  - **Binecuvântări**: îmbunătățiri pentru tot Drumul, mai scumpe și mai rare (de ex. +1 Schimbare în fiecare luptă, +1 inimă maximă, +1 loc de Talisman). Le dau zeii; fiecare are numele unui zeu din panteon.
- **Prețurile rămân mici și ușor de citit (3–15 Monede).** Nu folosi sute sau mii ca în imagini.
- **Ecranul „Talismane și Sac”** (ca în imaginea `sac`):
  - stânga: profilul (Monede, Săculeț, Viață, Ținut) și categoriile;
  - centru: grila de obiecte, cu câte bucăți ai din fiecare;
  - dreapta: detaliile și cele 5 Talismane echipate.

---

## 8. Cercurile (dificultățile)
Fiecare Drum câștigat deschide Cercul următor. **Penalizările și avantajele se adună.** Avantajele nu trebuie să anuleze penalizarea: fiecare Cerc trebuie să fie, per total, mai greu. Verifică asta cu simulatorul.

| Cerc | Mai greu | Dar primești |
|---|---|---|
| 1 | — (jocul de bază) | — |
| 2 | monștrii au +25% viață | runele **rare** pot apărea în Piață |
| 3 | boșii au o a doua regulă | Talismanele rare apar mai des; +1 loc de consumabil |
| 4 | −1 inimă maximă | runele **extra rare** apar în Piață |
| 5 | −1 Schimbare în fiecare luptă | boșii pot lăsa **rune ultrarare**; Piața are un obiect în plus |
| 6 | monștrii mici și mari se regenerează 5% după fiecare Rostire | începi Drumul cu un Talisman rar, la alegere din 3 |
| 7 | prețurile cresc cu 25% | Binecuvântările costă cu 25% mai puțin; Lecțiile dau +50% |
| 8 | bossul final are 3 faze | Talismanele legendare pot apărea în Piață |

- Fiecare Cerc are un **însemn propriu**: un cerc de piatră cu tot mai multe rune aprinse.
- Se alege din hub, înainte de Drum.

---

## 9. Lumea și monștrii (folclorul românesc)
**Cele 8 Ținuturi (fundal, monștri, boss):**
1. **Marginea Orașului:** blocuri părăsite, ceață.
2. **Codrul**
3. **Mlaștina**
4. **Satul blestemat**
5. **Munții**
6. **Cetatea în ruină**
7. **Peștera Zmeului**
8. **Poarta:** bossul final.

**Monștri (exemple; propune lista completă: minimum 16 monștri și 8 boși, cu viața pe Ținut și pe Cerc):**
| Creatură | Ce e | Slab la | Rezistent / imun | Trăsătură |
|---|---|---|---|---|
| Spiriduș | duh mic și hoț | Focul | — | fură 1 Monedă la fiecare Rostire |
| Pricolici | om-lup | Focul, Soarele | rezistent la Forță | Furie: după a doua Rostire, ia −1 Schimbare |
| Strigoi | mort care se ridică din mormânt | Soarele, Focul | **imun la Gheață** | Regenerare 5% după fiecare Rostire |
| Moroi | duhul unui mort | Soarele | rezistent la Apă | la fiecare Rostire îți ia o piatră din mână |
| Iele | zâne ale nopții care dansează | Ziua | **imune la Forță** | Dansul: mâna se amestecă după fiecare Rostire |
| Căpcăun | uriaș cu viață multă | Spinul | rezistent la Grindină | — |
| Vârcolac | fiara care mănâncă luna | Ziua, Soarele | rezistent la Gheață | Scut 30 |

| Boss | Ținut | Regula (orientativ) |
|---|---|---|
| Muma Pădurii | Codrul | Focul e interzis în pădurea ei |
| Baba Cloanța | Satul blestemat | vrăjile simple (E → Ț) nu fac daună |
| Solomonarul (stăpânul furtunilor, călare pe balaur) | Munții | imun la Grindină; la fiecare Rostire, o piatră din mână devine Hagalaz |
| Zmeul | Peștera | fiecare Rostire trebuie să aibă o vrajă cu Acțiune |
| Balaurul cu trei capete | Poarta (final) | 3 bare de viață, câte una pe cap; fiecare cap are alte slăbiciuni |

- Toate creaturile sunt din folclorul public. Le desenez eu, în stilul nostru.
- Descrierile din Compendiu sunt scurte și corecte: ce spune folclorul, plus o frază de umor.

---

## 10. Stilul vizual nou
### 10.1 Direcția
**„Dark fantasy gotic est-european, luminat de lumânări și jar.”** Imaginile de referință sunt **atmosfera țintă**:
- rame ornate de piatră și fier;
- titluri aurii cu litere romane;
- jar portocaliu pe ce e important;
- noapte albastră, lună, lumânări, cerc de rune.

Sunt generate cu AI, așa că au și greșeli. Nu le copiem la pixel. Construim un **sistem de interfață** care dă aceeași senzație, dar se citește mai bine.

**Ce păstrăm din imagini:**
- așezarea pe 3 coloane (info stânga, acțiune centru, detalii dreapta);
- un banner de titlu sus, în centru;
- butoanele mari jos;
- obiectul selectat cu ramă de jar;
- cercul de rune ca piesă centrală;
- lumânări și braziere pe margini.

**Ce facem mai bine** (reguli de bază ale interfețelor de joc: ierarhie vizuală, lizibilitate, consecvență, răspuns la fiecare acțiune):
1. **Un singur lucru aprins pe ecran:** obiectul selectat sau acțiunea principală. Toate celelalte rame sunt metal stins. În imagini strălucește totul, deci nimic nu iese în evidență.
2. **Text lizibil:** minimum **18 px la 1080p** (ghidul de accesibilitate Xbox pentru PC); textul obișnuit la 22–24 px. Contrast minimum **4,5 : 1** pentru text normal și 3 : 1 pentru titluri mari. Sub orice text e un panou opac, niciodată direct pe fundalul pictat.
3. **Fundalul nu concurează cu interfața:** e mai întunecat și mai puțin saturat decât interfața, cu vignetă. Detaliile mari stau pe margini; centrul rămâne liniștit.
4. **Regula 60-30-10 la culori:** 60% noapte (albastru-negru), 30% piatră și metal, 10% jar și aur. Culorile Elementelor apar **doar** pe rune, vrăji și daună.
5. **Un singur set de iconițe:** linie de 2 px, colțuri rotunjite la fel, aceeași grosime peste tot.
6. **Fără clișee nordice:** fără corbi, Valhalla sau noduri celtice. În locul lor, **motive est-europene**: turnuri de cetate, biserici și porți maramureșene din lemn sculptat, cusături geometrice de ie pe rame, opaițe. Ce ne face recognoscibili.
7. **Textele corecte:** „Rostește” (nu „Rotește”), „Maestra Ilinca”, „Talismane”. Imaginile au greșeli; jocul nu.

### 10.2 Paleta
| Nume | Hex | Folosire |
|---|---|---|
| Noapte | `#0B0F1A` | fundal (60%) |
| Panou | `#141A28` | panouri |
| Panou ridicat | `#1C2333` | hover, carduri |
| Piatră | `#2A2F3A` | rame de piatră |
| Cerneală | `#05070C` | contururi, umbre |
| Bronz stins | `#8A6A3F` | rame de metal inactive |
| Aur | `#E8C27A` (gradient `#F6DFA4` → `#C8923E`) | titluri, valori importante |
| Pergament | `#EDE3CC` | text principal |
| Text secundar | `#B7AE9C` | descrieri, etichete |
| Jar | `#FF7A2E` | selecție, acțiunea principală, „Ucide!” |
| Jar adânc | `#B8401E` | butonul principal |
| Viață | `#E0473C` | inimi, bara monstrului |

**Elementele** (doar pe rune, vrăji, daună; fiecare are și o iconiță proprie, ca să nu depindă doar de culoare):

| Element | Culoare |
|---|---|
| Focul | `#FF6A2B` |
| Forța | `#C9A46A` |
| Spinul | `#7FBF5A` |
| Gheața | `#6CC6FF` |
| Grindina | `#D8ECFF` |
| Soarele | `#FFC94A` |
| Apa | `#2FC4C0` |
| Ziua | `#F3E6B8` |

**Acțiunile** strălucesc argintiu (`#CFD6E6`), **Țintele** auriu (`#E8C27A`).

**Raritatea** (convenția pe care o cunosc toți jucătorii):

| Raritate | Culoare |
|---|---|
| Comun | `#D9D2C3` |
| Rar | `#4DA3FF` |
| Extra rar | `#A86BFF` |
| Ultrarar | `#FF9A2E` → `#FFD36A`, animat |

**Neamul** se vede printr-un semn mic pe piatră (monedă / fulg / stea), nu prin culoarea glifului.

Verifică contrastul fiecărei combinații de text și fundal și arată-mi un tabel.

### 10.3 Fonturile
Toate sunt de pe Google Fonts, licență OFL, și au diacriticele românești (subsetul latin-ext). **Cere-mi voie înainte să le descarci.**

| Font | Pentru ce | Detalii |
|---|---|---|
| **Cinzel** (700–900) | logo, titluri de ecran, nume de vrăji, monștri și obiecte, cifrele mari de daună | doar majuscule, minimum 28 px; auriu, contur închis de 2 px, strălucire slabă |
| **Alegreya** (400/500, italic) | descrieri, dialoguri, tooltip-uri, citate | 22–24 px; italic doar pentru citate și text de atmosferă |
| **Alegreya Sans** (500/700) și **Alegreya Sans SC** | etichete mici, cifre din contoare, butoane secundare | minimum 18 px; etichetele în majuscule mici, cu spațiere +8% |

- **Cifrele din contoare:** în Godot, pe `FontVariation`, activează `lnum` + `tnum` (cifre drepte, de aceeași lățime), ca scorurile să nu „danseze” când se schimbă. Alegreya are implicit cifre „vechi”, de înălțimi diferite.
- **Scara de mărimi la 1080p:**

| Element | Mărime |
|---|---|
| logo | 72 |
| titlu de ecran | 48 |
| titlu de panou | 32 |
| nume de obiect | 28 |
| text principal | 24 |
| text secundar | 20 |
| minimum | 18 |

- **În Setări:** mărimea textului 100% / 125% / 150%.
- **Test obligatoriu:** randează „ȘșȚțĂăÂâÎî” cu fiecare font și verifică virgula de sub ș și ț (nu sedilă).
- **Rusă, mai târziu:** Alegreya și Alegreya Sans au chirilice; Cinzel nu are, așa că pentru titluri în rusă pune **Forum** ca font de rezervă. Pregătește lanțul de rezervă de pe acum.
- Maximum 3 familii de fonturi. Fără text lung scris doar cu majuscule. Tooltip-urile au maximum 60 de caractere pe rând.

### 10.4 Componentele (un `Theme` Godot comun)
- **Panou:** ramă de piatră și fier (StyleBox 9-slice). Până fac eu textura, ramă **procedurală** din shader: zgomot de piatră, margine de bronz cu gradient și colțuri ornate desenate geometric (motiv de ie). Panoul activ primește margine de jar care pulsează încet.
- **Butoane:**
  - Principal (jar), Secundar (metal), Pericol;
  - stări: normal, hover (+lumină, se ridică 2 px), apăsat (coboară), dezactivat, focus (pentru tastatură și controler);
  - fiecare buton are sunet.
- **Card de obiect** (Rună, Talisman, Binecuvântare, Lecție, Gravură):
  - rama după raritate și ilustrația;
  - numele în Cinzel, raritatea colorată, descrierea în Alegreya;
  - prețul jos.
- **Piatra de rună:**
  - formă de piatră, cu materialul după raritate;
  - glif care strălucește (culoarea Elementului / argintiu / auriu);
  - semnul de rol în colțul din dreapta sus, semnul de Neam jos;
  - la selecție, numărul de ordine.
- **Tooltip:** panou opac, titlu Cinzel, text Alegreya. Cuvintele-cheie sunt colorate: Elementele în culoarea lor, numerele în auriu.
- **Altele:** bara de viață a monstrului (cu bara fantomă), inimile, Monedele, Săculețul, însemnele Cercurilor.
- **Scena `UIKit`:** toate componentele în toate stările, pe un singur ecran, ca să le verific dintr-o privire.

### 10.5 Efecte (toate pe renderer-ul Compatibility)
- Scântei de jar care urcă încet în fundal (particule), flăcări de lumânare și brazier (shader), vignetă, o ceață ușoară.
- **Selecția:** ramă de jar care pulsează; piatra se ridică și strălucește mai tare.
- **Rostirea:** pietrele zboară în cerc în ordinea selecției; propoziția se aprinde cuvânt cu cuvânt; vraja zboară spre monstru; monstrul tremură; numărul de daună sare (Cinzel, mare, în culoarea Elementului); bara de viață scade în două etape.
- **Daună mare:** scuturare scurtă a ecranului și flash. **Vrajă nouă:** animația mare de descoperire (deja făcută), în stilul nou.
- **Tranziții** între ecrane: fade scurt + ușoară mișcare.
- **Efectul „linii care fierb” și granulația de hârtie se scot:** nu se potrivesc cu stilul pictat.

### 10.6 Ecranele (după imaginile din `docs/referinte/`)
1. **Meniu principal:** logo (titlul din `GAME_TITLE`) și tagline în stânga sus; butoanele Joacă, Continuă, Compendiu, Setări, Ieșire în stânga; în dreapta, **portalul cu cercul de rune** care se rotește încet.
2. **Lupta:**
   - stânga sus: Drumul (Ținut, luptă), Monede, Săculeț, seed, Viteză, Meniu;
   - stânga: dauna estimată (Putere × Rezonanță), Rostirile (lumânări), Schimbările;
   - sus, centru: **monstrul**;
   - centru: **cercul de rune** cu propoziția și estimarea;
   - dreapta sus: Talismanele (5 locuri);
   - dreapta: panoul „Vraja selectată” și sfaturile Maestrei Ilinca;
   - jos: mâna de pietre, iar în dreapta, **Rostește** și **Schimbă**.
3. **Sfârșit de luptă:** vezi secțiunea 3.
4. **Piața:** vezi secțiunea 7.
5. **Talismane și Sac:** vezi secțiunea 7.
6. **Compendiu:**
   - stânga: categoriile (Rune, Vrăji, Talismane, Monștri, Cercuri);
   - centru: **roata runelor** pe Elemente, iar la Vrăji, **Tabla Vrăjilor 8 × 8**;
   - dreapta: detaliile cu sensul istoric și efectul în joc.
7. **Hub-ul (Orașul Pragului):** alegerea Cercului și a părintelui, Cursul de seară, Aeva.

---

## 11. Arta: ce face codul și ce desenez eu
- **Codul face:** layout-ul, ramele procedurale, glifele runelor, particulele, luminile, fonturile, animațiile.
- **Eu desenez** (până atunci, placeholder-uri curate, cu numele scris pe ele):

| Ce | Câte | Mărime | Folder |
|---|---|---|---|
| fundaluri de Ținut și de ecran | ~12 | 1920×1080 | `art/backgrounds/` |
| portrete de monștri și boși | ~24 | 768×768 | `art/monsters/` |
| ilustrații de Talismane și Binecuvântări | ~40 | 360×480 | `art/talismans/`, `art/blessings/` |
| pietre de rună pe raritate | 4 materiale | 192×240 | `art/stones/` |
| glifele runelor primordiale | 3 | 128×128 | `art/runes/` |
| logo | 1 | după nevoie | `art/ui/` |
| texturi de ramă (opțional; înlocuiesc ramele procedurale) | câteva | 9-slice | `art/ui/` |

- **Dacă o parte din artă e generată cu AI:** itch.io și Steam cer să fie declarată. Scrie un fișier `docs/ARTA_SURSE.md` în care notez sursa fiecărei imagini.

---

## 12. Examenul: instruirea în 3 lecții
Folosește doar cele 6 rune de start. Profesoara e Maestra Ilinca; în Lecția 3 apare Kaldor.

**Lecția 1 — Runele sunt cuvinte** (Manechinul de antrenament, viață mică)
1. „Runele nu sunt cifre. Sunt cuvinte. Semnul din colț îți spune ce fel de cuvânt.” [lumină: semnele de rol]
2. „O vrajă e o propoziție: întâi Elementul, apoi Ținta. Alege Kenaz, apoi Tiwaz.” [așteaptă: selecție în ordinea asta]
3. „Citește în cerc: «Focul în Dușman». Vezi cât va lovi. Rostește.” [așteaptă: vraja rostită] → daună, Arsură.
4. „Acum invers: Tiwaz, apoi Kenaz.” → „Ordinea e greșită.” „Aceleași rune, altă ordine: nimic.”
5. „Termină-l.” [așteaptă: monstrul învins]

**Lecția 2 — Acțiunile și Schimbarea** (Câinele de bronz)
1. „O Acțiune pusă la mijloc schimbă vraja. Ehwaz: aleargă de două ori.”
2. Mâna nu are Ehwaz: „Nu ai Ehwaz în mână. Schimbă pietrele de care n-ai nevoie.” [așteaptă: Schimbare] → apare Ehwaz.
3. „Kenaz, Ehwaz, Tiwaz.” [așteaptă: vraja rostită] → lovește de 2 ori.
4. „Cinci pietre pot face două vrăji. A doua lovește mai tare.” [așteaptă: o Rostire cu 2 vrăji]
5. „Și dacă toate pietrele sunt din același Neam, magia răsună mai tare.” [lumină: semnele de Neam] [continuă]

**Lecția 3 — Slăbiciuni și Viață** (Kaldor, ca boss de examen)
1. **Kaldor:** „Eu sunt Kaldor. Gheața nu mă atinge. Focul, da. Citește-mi slăbiciunile.” [lumină: iconițele de pe Kaldor]
2. „Dacă nu mă dobori până se sting lumânările, pierzi o inimă. În lume, fără inimi, drumul se termină.” [lumină: inimile] (în Examen nu pierzi nimic)
3. Joc liber cu indicii. Victorie → **Ilinca:** „Ai trecut. Uite Pecetea. Dincolo de oraș sunt lucruri care nu citesc reguli.” → hub-ul.

**Indicii noi** (`hints.json`):
- prima slăbiciune lovită;
- prima imunitate;
- primul boss;
- prima inimă pierdută;
- prima rună rară;
- prima Legătură străveche;
- primul Cerc nou deschis.

Propune replicile, în același ton.

---

## 13. Pașii de lucru
**A — Auditul și planul (fără cod)**
Ce fișiere și sisteme rămân, se schimbă sau se șterg; cum se migrează salvarea; ce Talismane mai au sens; riscurile.
*Test:* citesc planul și îți dau OK.

**B — Miezul: lupta și magia ca daună**
Monstrul de test, formula, Elementele cu natura lor, Acțiunile și Țintele noi, 2 vrăji pe Rostire, bonusul de Neam, Lecțiile pe Elemente, previzualizarea cu „Ucide!”. Scoți Cuvintele, Poziția și Glasurile de bază. Teste pentru formulă, pentru slăbiciuni, rezistențe și imunități, și pentru limite.
*Test:* bat Manechinul cu Kenaz → Tiwaz, apoi cu Kenaz → Ehwaz → Tiwaz; văd dauna estimată și pe cea reală.

**C — Runele**
Cele 6 de start, deblocarea celor 24, datele pentru 12 / 6 / 3 (cu `enabled` după Cerc), materialul pietrei după raritate, Gravura Legătura.
*Test:* un Drum nou are doar 6 rune; după un boss se deblochează una nouă.

**D — Lumea**
8 Ținuturi, monștri și boși cu trăsături și reguli, Viața, eșecul (−1 / −2 inimi), ecranul Sfârșit de luptă cu recompensa 1 din 3.
*Test:* fac un Drum întreg, pierd o inimă la un monstru, un boss rămâne rănit după eșec.

**E — Piața și Cercurile**
Blochează, Binecuvântările, prețurile mici, Cercurile 1–8 cu însemne, alegerea Cercului în hub.
*Test:* termin un Drum (cu o comandă de test) → se deschide Cercul 2 și rarele apar în Piață.

**F — Stilul: UI Kit**
`Theme`, fonturile (cu OK-ul meu), paleta, toate componentele, efectele, scena `UIKit`, tabelul de contrast.
*Test:* deschid UIKit și văd toate componentele; diacriticele sunt corecte; textul se citește la 100% și la 150%.

**G — Ecranele noi**
Meniu, Lupta, Sfârșit de luptă, Piața, Talismane și Sac, Compendiu, Hub, după 10.6.
*Test:* compar fiecare ecran cu imaginea lui din `docs/referinte/`.

**H — Examenul**
Instruirea în 3 lecții, indiciile noi; ștergi lecțiile vechi.
*Test:* un prieten care n-a văzut jocul trece Examenul fără ajutorul meu.

**I — Balansul**
Simulatorul joacă Drumuri pe Cercurile 1–4 cu o strategie simplă. Arată-mi: procentul de victorii pe Cerc, cât de des se folosește fiecare vrajă, vrăjile prea puternice sau inutile, durata unei lupte.
*Ținte:* un jucător nou termină Cercul 1 după 2–4 încercări; fiecare Cerc e vizibil mai greu decât precedentul.

**După fiecare pas:** actualizează `docs/DESIGN.md`, `docs/ARTA.md` și `CLAUDE.md`.
