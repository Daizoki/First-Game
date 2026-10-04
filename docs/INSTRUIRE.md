# Etapa 2½ — Instruirea: „Seara dinaintea examenului”

> Specificația primită de la Relax (PROMPT_INSTRUIRE.md), păstrată aici ca referință pentru sesiunile viitoare.
> Valorile lecțiilor (ținte, Rostiri, seed-uri) sunt în `data/tutorial.json`; deciziile luate pe parcurs sunt în
> jurnalul din `docs/DESIGN.md`.

## 0. Context
- Etapa 2 (miezul: o rundă, Cuvintele, Glasurile, primele 8 Vrăji) e gata.
- Acum facem **instruirea**, ca un jucător nou să înțeleagă jocul fără să citească un manual.
- Regulile din `CLAUDE.md` și `PROMPT_START.md` rămân valabile: pe pași, oprire după fiecare pas, raport, commit,
  OK-ul lui Relax.
- Textele sunt în română; **traducerea în engleză o face Claude** și i-o arată lui Relax la final.
- Ce nu e construit încă (Piața, Talismanele, Examinatorii, Aeva) **nu intră acum**. Pentru ele se pregătește doar
  sistemul de indicii (secțiunea 4).

## 1. Principii
1. **Înveți făcând, nu citind.** Fiecare explicație e urmată imediat de o acțiune a jucătorului.
2. **Un singur lucru nou o dată.**
3. **Bule scurte:** maximum 2 rânduri (~120 de caractere), text literă cu literă; un clic îl afișează complet,
   al doilea trece mai departe.
4. **Nu bloca mai mult decât trebuie.** Mouse-ul pe orice merge mereu; se blochează doar acțiunile care ar strica
   lecția.
5. **Personajul vorbește, nu sistemul.** Profesoara e **Maestra Ilinca**: severă, ironică, scurtă, dar corectă.
6. **Toată instruirea durează 5–7 minute.**
7. **Se poate sări:** la început (alegere), din meniul de pauză și din Setări („Reia instruirea”).

## 2. Povestea
- **Locul:** sala de curs a Școlii de Rune, seara dinaintea examenului. Bănci vechi, tablă cu rune desenate cu
  cretă, o lampă.
- Pornește automat la prima pornire, după ce jucătorul își scrie numele.
- **Intro (Ilinca):** „Deci tu ești {nume}. Mâine dai Examenul de Moștenire și n-ai ținut o rună în mână. Minunat.”
  / „Ai o seară. Eu am răbdare pentru o seară. Hai.” Butoane: **„Învață-mă”** → Lecția 1; **„Mă descurc singur”**
  → „Sigur? Kaldor nu explică nimic.” [Da, sar] [Nu, rămân].
- Fiecare lecție e o mini-rundă cu **mână fixă** (fără trageri reale). Ținta, Rostirile și Schimbările le
  stabilește Claude, ținând cont de Glasuri, și i le arată lui Relax.

Legendă: **[continuă]** = bulă de citit; **[așteaptă: …]** = merge mai departe doar după acțiunea jucătorului;
**[lumină: …]** = restul ecranului se întunecă.

## 3. Lecțiile

### Lecția 1 — Pietrele și Rostirea
Mâna: Fehu (1), Hagalaz (1), Gebo (7), Isaz (3), Raidho (5), Dagaz (7), Wunjo (8), Ingwaz (6). Schimbări: 0
(butonul ascuns). Rostiri: 3. Ținta: atinsă cu exact două Perechi.
1. „Asta e mâna ta: opt pietre. Fiecare are o rună.” [lumină: mâna] [continuă]
2. „Ține mouse-ul pe o piatră ca să afli ce e.” [așteaptă: mouse pe orice piatră]
3. „Cifra din colț e Poziția. Culoarea e Neamul. Restul îl citești singur.” [continuă]
4. „Două pietre cu aceeași Poziție fac o Pereche. Fehu și Hagalaz au amândouă Poziția 1. Alege-le.” [lumină: Fehu,
   Hagalaz] [așteaptă: o Pereche selectată]. Altă Pereche (Gebo + Dagaz) e acceptată: „Și asta e o Pereche. Bine.”
5. „În cerc vezi ce Cuvânt ai format, înainte să-l rostești.” [lumină: cercul] [continuă]
6. „Rostește.” [lumină: Rostește] [așteaptă: Rostire]. Animația merge încet, cu o bulă pe fază: „Cuvântul îți dă o
   Putere și o Rezonanță de bază.” / „Fiecare piatră care punctează adaugă Putere.” / „Putere × Rezonanță. Asta e
   scorul.”
7. „Scorurile se adună până atingi Ținta. Fiecare lumânare e o Rostire. Când se sting toate, ai picat.” [lumină:
   Ținta + lumânările] [continuă]
8. „Mai ai o Pereche în mână. Găsește-o singur.” [așteaptă: runda câștigată]
- Dacă pică: „Mai încearcă. Nu se notează.” Lecția o ia de la capăt.

### Lecția 2 — Schimbarea și Cuvintele mari
Mâna: Isaz (3), Ehwaz (3), Gebo (7), Dagaz (7), Raidho (5), Wunjo (8), Kenaz (6), Naudiz (2). Primele pietre din
săculeț: Thurisaz (3), Jera (4). Schimbări: 1. Rostiri: 2. Ținta: se poate atinge doar cu o Familie.
1. „Uneori mâna e proastă. Nu o rosti. Schimb-o.” [continuă]
2. „Raidho și Wunjo nu te ajută acum. Alege-le și apasă Schimbă.” [lumină: Raidho, Wunjo, Schimbă]; se pot selecta
   doar Raidho, Wunjo, Kenaz și Naudiz. [așteaptă: o Schimbare]
3. „Acum ai trei pietre cu Poziția 3 și două cu Poziția 7. Asta e o Familie.” [lumină: cele 5 pietre] [continuă]
4. „Poți rosti cel mult cinci pietre. Cu cât un Cuvânt e mai rar, cu atât valorează mai mult. Alege Familia.”
   [așteaptă: Familie selectată]
5. „Rostește.” [așteaptă: runda câștigată]
6. „Toate Cuvintele sunt în Cartea Cuvintelor. O deschizi de aici, oricând.” [lumină: butonul Cartea Cuvintelor]
   [așteaptă: cartea deschisă și apoi închisă]

### Lecția 3 — Glasul runelor
Mâna: Hagalaz (1), Fehu (1), Isaz (3), Berkanan (2), Wunjo (8), Kenaz (6), Raidho (5), Ingwaz (6). Schimbări: 0.
Rostiri: 2. Ținta: atinsă doar dacă Hagalaz punctează de două ori.
1. „Runele nu sunt doar cifre. Fiecare are un Glas, un efect venit din sensul ei.” [continuă]
2. „Ține mouse-ul pe Hagalaz.” [lumină: Hagalaz] [așteaptă: mouse pe Hagalaz]
3. „Hagalaz e grindina și lovește de două ori. Fehu e avuția și îți aduce o monedă.” [continuă]
4. „Rostește-le împreună și uită-te ce se întâmplă.” [așteaptă: Rostire cu Hagalaz și Fehu]. Animația lentă: „Glasul
   lui Hagalaz: încă o dată!” / „Glasul lui Fehu: +1 Monedă.”
5. „Citește Glasul fiecărei rune. Aici se câștigă examenele.” [continuă]. Dacă ținta nu e atinsă, jucătorul
   termină singur runda.

### Lecția 4 — Vrăjile
Mâna: Isaz (3), Hagalaz (1), Naudiz (2), Fehu (1), Tiwaz (1), Gebo (7), Sowilo (8), Berkanan (2). Schimbări: 0.
Rostiri: 2. Ținta: mai mare decât o Treime, dar atinsă după ce Iarna o scade.
1. „Acum ceva ce nu-ți spune nimeni la examen.” [continuă]
2. „Unele rune, puse împreună, fac mai mult decât scor. Se cheamă Vrăji.” [continuă]
3. „Gheață. Grindină. Nevoie. Ce iese din ele?” [lumină: Isaz, Hagalaz, Naudiz, cu sensul scris sub fiecare]
   [așteaptă: toate trei selectate]
4. „Simți? Cercul s-a trezit. Nu-ți spune ce Vrajă e. Ca s-o afli, trebuie s-o rostești.” [lumină: cercul] [continuă]
5. „Hagalaz are Poziția 1. Adaugă Fehu și Tiwaz, tot cu Poziția 1, și ai și o Treime. Vrajă și scor în aceeași
   Rostire.” [așteaptă: exact aceste 5 pietre selectate]
6. „Rostește.” [așteaptă: Vraja Iarna descoperită] → animația mare de descoperire.
7. „Iarna. Uite, Ținta a scăzut.” [lumină: Ținta] [continuă]
8. „Sunt peste treizeci de Vrăji și toate se pot ghici din sensul runelor. Nu ți le spun. Nici eu nu le știu pe
   toate.” [continuă]
- Iarna rămâne descoperită și după instruire.

### Lecția 5 — Singur
Mâna trasă normal din săculețul întreg, cu un seed fix ales ca să fie rezonabilă. Rostiri: 4. Schimbări: 3. Ținta:
mică (2–3 Cuvinte obișnuite).
1. „Acum fără mine. Ținta e mică. Nu mă face de rușine.” [continuă]
2. Joc liber. După 25 s fără nicio acțiune: „Caută o Pereche. Sau citește Glasurile.” (o singură dată)
3. Victorie: „Nu-i rău. Mâine dimineață e examenul. Kaldor nu e la fel de răbdător ca mine.” → instruirea e
   terminată (salvat) → meniul principal (până există Dimineața examenului, Etapa 4).
4. Înfrângere: „Mai încearcă. Tot ce înveți aici rămâne.” → Lecția 5 de la capăt.

## 4. Indiciile contextuale (pentru tot jocul)
Bule mici cu portret, **o singură dată**, prima dată când se întâmplă ceva; nu blochează, se închid cu un clic,
apar pe rând; se salvează cele văzute; **oprite în timpul instruirii**; „Indicii: pornite / oprite” în Setări.
Stau în `data/hints.json`; cele pentru elemente care nu există încă au `"enabled": false` și se pornesc în etapa
care construiește elementul.

| id | Când apare | Cine | Text | Activ din |
|---|---|---|---|---|
| `first_laguz` | prima dată când Laguz e în mână | Ilinca | „Laguz e apă: curge. Contează ca piatră din orice Neam.” | acum |
| `idle_help` | 40 s fără acțiune într-o rundă (doar în primele 3 examene) | Ilinca | „Nu știi ce să faci? Ține mouse-ul pe pietre sau deschide Cartea Cuvintelor.” | acum |
| `first_shop_1` | prima Piață | Tanti Vera | „Bună seara, puiule. Aici cumperi ce te ține în viață la examen.” | Etapa 3 |
| `first_shop_2` | imediat după | Tanti Vera | „Talismanele lucrează singure, de la stânga la dreapta. Ai cinci locuri.” | Etapa 3 |
| `first_shop_3` | imediat după | Tanti Vera | „Lecțiile cresc un Cuvânt. Gravurile schimbă pietrele. Săculețele… surpriză.” | Etapa 3 |
| `first_reroll` | prima dată când „Rearanjează taraba” e disponibil | Tanti Vera | „Nu-ți place marfa? Rearanjez taraba, dar nu gratis.” | Etapa 3 |
| `first_talisman` | primul Talisman cumpărat | Tanti Vera | „Trage Talismanele ca să le schimbi ordinea. Ordinea contează.” | Etapa 3 |
| `first_examiner` | primul Examinator | Kaldor | „Eu sunt Kaldor. Regula mea e scrisă acolo. N-o repet.” | Etapa 3 |
| `first_lesson` | prima Lecție primită | Ilinca | „O Lecție crește nivelul unui Cuvânt pentru tot examenul.” | Etapa 3 |
| `first_engraving` | prima Gravură primită | Ilinca | „O Gravură schimbă o piatră. Alege piatra din mână, apoi folosește Gravura.” | Etapa 3 |
| `first_bindrune` | prima legătură runică | Ilinca | „O legătură e o piatră cu două rune. Contează ca oricare dintre ele, iar Glasurile se aud amândouă.” | Etapa 3 |
| `first_loss_1` | primul examen picat | Aeva | „Ai picat. Se întâmplă. Ție ți se întâmplă des.” | Etapa 4 |
| `first_loss_2` | imediat după | Aeva | „Te întorc în dimineața examenului. Tu ții minte tot, ceilalți nu. Nu mă întreba de ce.” | Etapa 4 |
| `first_loss_3` | imediat după | Aeva | „Ce ai adunat se numește Amintiri. Cheltuiește-le cu cap.” | Etapa 4 |
| `first_evening_class` | prima vizită la Cursul de seară | Ilinca | „În ultima bancă stau Kaldor și Varr. Repetă cursul. Nu fi ca ei.” | Etapa 4 |
| `first_torn_page` | prima Pagină ruptă | Tanti Vera | „Am găsit-o într-o carte veche. Spune ce rune trebuie. Restul e treaba ta.” | Etapa 4 |
| `first_curse` | primul blestem descoperit | Ilinca | „Nu toate Vrăjile sunt prietenoase. Ai învățat ceva azi.” | Etapa 5 |
| `first_old_word` | primul Cuvânt vechi (ALU…) | Ilinca | „Cuvântul ăsta e scris pe pietre mai vechi decât orice zeu. De unde îl știi?” | Etapa 5 |

## 5. Ajutor permanent
- **Mouse pe o piatră:** fișă cu runa, sensul istoric, Poziția, Neamul (culoare + semn), Glasul și, dacă există,
  materialul sau legătura.
- **Mouse pe preview-ul din cerc:** ce Cuvânt e, ce pietre punctează (luminate în mână) și valorile lui.
- **Cartea Cuvintelor** (buton lângă cerc + o tastă): cele 10 Cuvinte în ordinea valorii, fiecare cu un exemplu
  desenat cu pietre mici, nivelul și Putere × Rezonanță actuale; Cuvântul Vechi apare „???” până îl descoperi.
- **Cartea de rune** (din meniul de pauză): cele 24 de rune cu Glasurile și Vrăjile descoperite; nedescoperitele „???”.
- Mai târziu (Etapa 3): aceeași fișă pentru Talismane, consumabile și regula Examinatorului.

## 6. Partea tehnică
- `data/tutorial.json`: lecțiile, fiecare cu `hand`, `bag_top`, `target`, `casts`, `swaps`, `seed` și `steps`
  (`speaker`, `text`, `spotlight` — id-uri de UI sau `stone:<rune_id>`, `wait_for`, `allow`, opțional `wrong_text`,
  `slow_scoring` + `phase_captions`).
- **EventBus** (autoload): `stone_hovered`, `selection_changed`, `cast`, `swap`, `scoring_phase`,
  `spell_discovered`, `round_won`, `round_lost`, `book_opened`, `book_closed` (mai târziu `shop_opened`,
  `item_bought` …). Instruirea și indiciile **doar ascultă**; nicio logică de instruire în codul de joc.
- **ID-uri de UI:** metadata `tutorial_id` (`hand`, `circle`, `btn_cast`, `btn_swap`, `target`, `candles`,
  `btn_word_book` …).
- **TutorialOverlay:** strat întunecat cu găuri luminate cu margini moi (shader, Compatibility), bula cu portretul
  (`art/portraits/ilinca.png` sau placeholder) și text literă cu literă, săgeată desenată, bula se așază singură
  fără să iasă din ecran.
- **Blocarea acțiunilor:** cu `allow`, celelalte butoane devin inactive (vizibil mai stinse); mouse-ul pe pietre
  merge mereu; o selecție greșită nu se blochează — Ilinca spune `wrong_text`.
- **Animația încetinită:** mod lent (×0,5) cu bule la fazele din `phase_captions`.
- **Salvare:** `tutorial_done`, `hints_seen[]`, `hints_enabled`.
- **Meniu și Setări:** „Instruire” în meniul principal; „Reia instruirea” și „Indicii pornite/oprite” în Setări;
  „Sari peste instruire” în pauză.
- **Teste:** un test headless parcurge fiecare lecție și verifică: că se ajunge la final; că mâna fixă permite exact
  Cuvântul sau Vraja cerută; că ținta se atinge cu jocul descris și **nu** fără el.

## 7. Pașii de lucru
- **A — Sistemul:** EventBus, TutorialOverlay, `tutorial.json`, mâinile fixe, blocarea acțiunilor, salvarea, meniul,
  setările. *Test:* joc nou → nume → Ilinca cu cele două butoane; „Mă descurc singur” sare peste instruire.
- **B — Lecțiile 1–5:** textele, animația încetinită, testul headless. *Test:* toate lecțiile în 5–7 minute;
  corecturile Ilincăi; Iarna rămâne în Cartea de rune.
- **C — Ajutorul permanent:** fișele, Cartea Cuvintelor, indiciile (doar cele „acum” pornite). *Test:* fișa pe
  orice piatră; Cartea Cuvintelor din buton și cu tastă; Laguz → indiciul o singură dată.
- **D — Documente:** secțiunea „Instruirea și indiciile” în `docs/DESIGN.md`; regula în `CLAUDE.md` (în fiecare
  etapă viitoare: pornești indiciile pentru ce construiești și adaugi fișă la mouse pentru orice element nou);
  traducerile în engleză.
- **Testul final (Relax):** un prieten care n-a văzut jocul îl joacă fără ajutor; reparăm ce a fost neclar.
