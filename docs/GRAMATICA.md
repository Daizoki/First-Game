# Etapa 2b — Gramatica runelor: vrăjile se formează după tip și ordine

> Specificația primită de la Relax (PROMPT_GRAMATICA.md), păstrată aici ca referință pentru sesiunile viitoare.
> Valorile (efecte, nume, limite) sunt în `data/spells_base.json`, `data/spell_actions.json` și `data/economy.json`;
> deciziile luate pe parcurs sunt în jurnalul din `docs/DESIGN.md`.

## 0. Ce se schimbă
- **Secțiunea 3.15 din `PROMPT_START.md` (Vrăjile cu rețete fixe) e înlocuită de documentul ăsta.** Notează asta în `docs/DESIGN.md` și în `CLAUDE.md`.
- Ce **rămâne** din Etapa 2: săculețul, mâna, Rostirea/Schimbarea, Cuvintele (Pereche, Șir, Neam…), Putere × Rezonanță și Glasurile.
- Ce se **înlocuiește**: cele 8 Vrăji fixe din `spells.json`. Rămân doar Cuvintele vechi ascunse (ALU, LAÞU, AUJA), care sunt separate.
- Ideea, pe scurt: **fiecare rună are un rol (Element, Acțiune sau Țintă). Pui runele în ordine, ca într-o propoziție, și propoziția devine vrajă. Altă ordine înseamnă altă vrajă sau nicio vrajă.**
- Regulile de lucru din `CLAUDE.md` rămân: pași, oprire după fiecare pas, raport, commit, aștepți OK-ul meu.

## 1. Rolurile runelor
Fiecare din cele 24 de rune primește un **rol**, ales după sensul ei. Neamul și Poziția rămân ca acum (pentru Cuvinte).

**Elementele** — din ce e făcută vraja:
| Rună | Neam, Poz. | În propoziție |
|---|---|---|
| Kenaz | Fehu, 6 | Focul |
| Uruz | Fehu, 2 | Forța |
| Thurisaz | Fehu, 3 | Spinul |
| Isaz | Hagalaz, 3 | Gheața |
| Hagalaz | Hagalaz, 1 | Grindina |
| Sowilo | Hagalaz, 8 | Soarele |
| Laguz | Tiwaz, 5 | Apa |
| Dagaz | Tiwaz, 7 | Ziua |

**Acțiunile** — cum lucrează vraja:
| Rună | Neam, Poz. | În propoziție |
|---|---|---|
| Raidho | Fehu, 5 | se întinde |
| Gebo | Fehu, 7 | se dăruiește |
| Naudiz | Hagalaz, 2 | cere un preț |
| Jera | Hagalaz, 4 | se coace |
| Eihwaz | Hagalaz, 5 | durează |
| Perthro | Hagalaz, 6 | riscă |
| Berkanan | Tiwaz, 2 | crește |
| Ehwaz | Tiwaz, 3 | aleargă de două ori |

**Țintele** — asupra a ce lucrează vraja:
| Rună | Neam, Poz. | În propoziție | Ce atinge |
|---|---|---|---|
| Tiwaz | Tiwaz, 1 | peste Țintă | ținta rundei |
| Fehu | Fehu, 1 | în Monede | banii |
| Othala | Tiwaz, 8 | în Săculeț | pietrele, permanent |
| Mannaz | Tiwaz, 4 | în Mână | mâna, în runda asta |
| Ansuz | Fehu, 4 | în Cuvânt | Rostirea de acum |
| Ingwaz | Tiwaz, 6 | în Viitor | următoarea Rostire sau rundă |
| Wunjo | Fehu, 8 | în Talismane | Talismanele *(pornește în Etapa 3)* |
| Algiz | Hagalaz, 7 | asupra Examinatorului | regula examinatorului *(pornește în Etapa 3)* |

## 2. Regulile propoziției
- **Ordinea de rostire = ordinea în care selectezi pietrele.**
  - Pe fiecare piatră selectată apare un număr (1–5).
  - Dacă deselectezi o piatră, celelalte se renumerotează.
  - Butoanele de sortare schimbă doar ordinea din mână, nu ordinea de rostire.
- **Formele valide**, cu pietrele **una după alta** în ordinea de rostire:
  - **Element → Țintă** (vrajă simplă);
  - **Element → Acțiune → Țintă**;
  - **Element → Acțiune → Acțiune → Țintă** (maximum 2 Acțiuni).
- **O singură vrajă pe Rostire:** prima propoziție completă, citită de la piatra 1 încolo.
- Pietrele din afara propoziției nu fac vrajă, dar punctează normal în Cuvânt. **O piatră poate face parte și din Cuvânt, și din vrajă.** Exemplu: Hagalaz (Element, Poz. 1) + Tiwaz (Țintă, Poz. 1) = o Pereche **și** vraja „Grindina peste Țintă”.
- **Ordine greșită = nicio vrajă.** Tiwaz → Isaz nu face nimic. Previzualizarea explică de ce: „Ordinea e greșită: Elementul vine primul.”
- **Glasurile care țin de ordine** folosesc acum ordinea de rostire (schimbă textele):
  - Gebo: „Copiază Glasul pietrei rostite înaintea ei.”
  - Ehwaz: „Piatra rostită după ea punctează încă o dată.”
  - Tiwaz: „×2 Rezonanță dacă e rostită prima.”
- Cuvintele vechi ascunse (ALU, LAÞU, AUJA) rămân separate și se citesc tot în ordinea de rostire.

## 3. Vrăjile de bază: Element × Țintă (64)
Fiecare pereche Element → Țintă are un efect de bază. Valorile sunt **orientative**: balansează-le cu simulatorul și arată-mi ce ai schimbat. Coloana „Când” spune momentul: **înainte** = schimbă scorul Rostirii de acum; **după** = după scor; **mai târziu** = următoarea Rostire sau rundă.

Fiecare vrajă are și un **nume**. Propune tu numele (scurte, în română, potrivite cu sensul). Câteva sunt deja date mai jos.

### Peste Țintă (Tiwaz)
| Element | Efect | Când |
|---|---|---|
| Focul | ținta scade cu 3% pentru fiecare piatră care a punctat | după |
| Forța | ținta scade cu Puterea acestei Rostiri | după |
| Gheața — **„Iarna”** | ținta scade cu 15% | după |
| Grindina | ținta scade cu 25%, dar pierzi o Schimbare | după |
| Apa | ținta scade cu 20% acum; ținta rundei următoare crește cu 10% | după |
| Soarele | scorul acestei Rostiri se adună de două ori | după |
| Spinul | ținta scade cu 35%, dar Rezonanța acestei Rostiri devine 1 | înainte |
| Ziua — **„Ziua lungă”** | +1 Rostire în runda asta | după |

### În Monede (Fehu)
| Element | Efect | Când |
|---|---|---|
| Focul | +1 Monedă pentru fiecare piatră care a punctat | după |
| Forța — **„Târgul”** | +4 Monede | după |
| Gheața | +1 Monedă pentru fiecare 5 Monede pe care le ai (maximum +5) | după |
| Grindina | spargi o piatră aleasă din mână (iese definitiv din săculeț) → +6 Monede | după |
| Apa | + Monede egale cu numărul de pietre din mână | după |
| Soarele | +2 Monede pentru fiecare piatră din Neamul lui Fehu din mână | după |
| Spinul | +9 Monede, dar −1 Rostire | după |
| Ziua | la finalul rundei, +2 Monede pentru fiecare Rostire rămasă | mai târziu |

### În Săculeț (Othala) — schimbări permanente
| Element | Efect | Când |
|---|---|---|
| Focul | 2 pietre aleatorii din săculeț primesc +5 Putere permanent | după |
| Forța | pietrele care au punctat primesc +3 Putere permanent | după |
| Gheața | pietrele rostite acum se întorc imediat în săculeț | după |
| Grindina | scoți definitiv până la 2 pietre alese din mână | după |
| Apa | muți 2 pietre alese din mână în alt Neam, la alegere | după |
| Soarele | vezi primele 5 pietre din săculeț și le pui în ce ordine vrei | după |
| Spinul | o piatră aleatorie din mână se sparge; adaugi în săculeț 2 copii ale unei pietre alese | după |
| Ziua | adaugi în săculeț câte o copie a fiecărei pietre care a punctat | după |

### În Mână (Mannaz) — doar runda asta
| Element | Efect | Când |
|---|---|---|
| Focul | +1 piatră în mână pentru restul rundei | după |
| Forța | pietrele rămase în mână primesc +5 Putere în runda asta | după |
| Gheața | +3 Rezonanță pentru fiecare piatră rămasă în mână | înainte |
| Grindina — **„Furtuna”** | arunci toată mâna și tragi alta, gratis | după |
| Apa — **„Valul”** | schimbi până la 3 pietre, gratis | după |
| Soarele | tragi 3 pietre, păstrezi una la alegere; celelalte se întorc în săculeț | după |
| Spinul | arunci 2 pietre alese → +1 Rostire | după |
| Ziua | +1 Schimbare | după |

### În Cuvânt (Ansuz) — Rostirea de acum
| Element | Efect | Când |
|---|---|---|
| Focul | ×1,5 Rezonanță | înainte |
| Forța | +30 Putere | înainte |
| Gheața — **„Lecția”** | Cuvântul rostit crește cu 1 nivel, permanent | după |
| Grindina | pietrele care punctează punctează de două ori, dar Cuvântul scade cu 1 nivel (minimum 1) | înainte |
| Apa | Cuvântul punctează ca următorul Cuvânt din listă (Pereche → Două perechi etc.) | înainte |
| Soarele | ×2 Rezonanță dacă rostești 5 pietre | înainte |
| Spinul | ×3 Rezonanță, dar o piatră aleatorie din Cuvânt se sparge definitiv | înainte |
| Ziua | ×2 Rezonanță dacă e prima Rostire a rundei | înainte |

### În Viitor (Ingwaz)
| Element | Efect | Când |
|---|---|---|
| Focul — **„Jarul de mâine”** | următoarea Rostire are ×2 Rezonanță | mai târziu |
| Forța | următoarea Rostire are +40 Putere | mai târziu |
| Gheața | scorul peste țintă din runda asta trece în runda următoare | mai târziu |
| Grindina | runda următoare începe cu 20% din țintă atinsă, dar cu −1 Schimbare | mai târziu |
| Apa | la începutul rundei următoare tragi 12 pietre și păstrezi 8 | mai târziu |
| Soarele | în runda următoare vezi mereu următoarele 3 pietre din săculeț | mai târziu |
| Spinul | următoarea Rostire are ×3 Rezonanță, cea de după ×0,5 | mai târziu |
| Ziua | runda următoare are +1 Rostire | mai târziu |

### În Talismane (Wunjo) — scrie datele acum, pornește-le în Etapa 3
| Element | Efect |
|---|---|
| Focul | Talismanul din stânga se declanșează de două ori la Rostirea asta |
| Forța | +10 Putere pentru fiecare Talisman |
| Gheața | Talismanele care se consumă (ca Shaorma) nu scad în runda asta |
| Grindina | vinzi un Talisman ales pe prețul întreg |
| Apa | un Talisman ales devine altul, aleatoriu, de aceeași raritate |
| Soarele | la următoarea Piață apare sigur un Talisman Rar |
| Spinul | distrugi un Talisman ales → ×1,5 Rezonanță tot restul Probei |
| Ziua | +1 Talisman în oferta Pieței următoare |

### Asupra Examinatorului (Algiz) — scrie datele acum, pornește-le în Etapa 3
În rundele fără Examinator, toate vrăjile de aici dau doar +3 Monede.
| Element | Efect |
|---|---|
| Focul | regula Examinatorului nu se aplică acestei Rostiri |
| Forța | regula e anulată tot restul rundei, dar ținta crește cu 10% |
| Gheața | regula e anulată tot restul rundei |
| Grindina | regula e anulată pentru următoarele 2 Rostiri |
| Apa | schimbi regula cu una din 2 reguli ale altor Examinatori, la alegere |
| Soarele | vezi Examinatorii și regulile lor din următoarele 3 Probe |
| Spinul | ținta Examinatorului scade cu 20%; regula rămâne |
| Ziua | +1 Rostire în runda asta |

## 4. Acțiunile: cum schimbă vraja (8)
O Acțiune pusă între Element și Țintă modifică efectul de bază. Cu două Acțiuni, se aplică în ordine.

| Acțiune | În propoziție | Ce face |
|---|---|---|
| Raidho | se întinde | dacă efectul atinge **o singură** piatră sau un singur Talisman, le atinge pe toate de același fel, la jumătate de putere; altfel, valorile ×1,5 |
| Ehwaz | aleargă de două ori | efectul se aplică de 2 ori |
| Eihwaz | durează | efectul se aplică din nou la începutul următoarelor 2 runde, la jumătate de putere |
| Berkanan | crește | +50% pentru fiecare dată când ai mai rostit aceeași vrajă în acest examen |
| Jera | se coace | efectul vine abia la finalul rundei, dar dublu |
| Perthro | riscă | 50%: efect ×3; 50%: nimic |
| Naudiz | cere un preț | alegi pe loc: pierzi 1 Rostire sau 4 Monede; efect ×2,5 |
| Gebo | se dăruiește | vraja nu se aplică acum; primești un **Pergament** cu ea și îl folosești când vrei (un loc pentru Pergament, lângă mână) |

**Tehnic:** fiecare efect de bază declară în JSON care valori sunt **scalabile** (`amount`, `percent`, `count`) și dacă atinge un singur obiect (`single: true`). Acțiunile modifică doar acele câmpuri. Unde o Acțiune nu are sens (de exemplu, „×1,5” la o vrajă fără număr), nu face nimic în plus, iar previzualizarea spune asta.

**Limite de siguranță** (în `economy.json`, ca să nu se strice jocul):
- ținta unei runde nu poate scădea sub 40% din valoarea ei inițială;
- maximum +2 Rostiri pe rundă din vrăji;
- Pergamente: maximum 1, deocamdată.

## 5. Descoperirea și Cartea de rune
- Când selectezi pietre, sub cerc apare **propoziția** cu 3–4 locuri care se umplu pe rând: „Gheața → se întinde → peste Țintă”.
  - Dacă vraja **nu e descoperită**, efectul apare ca „???”. Jucătorul știe ce *spune* propoziția, dar nu știe ce *face* până nu o rostește.
  - Dacă e descoperită: numele și efectul.
  - Mesaje de ajutor: „propoziție neterminată”, „Ordinea e greșită: Elementul vine primul.”
- **Prima rostire** a unei vrăji de bază pornește animația mare de descoperire (din Etapa 2), cu numele vrăjii. Prima folosire a unei Acțiuni are o animație mică: „Ai învățat: se întinde”.
- Vrăjile și Acțiunile descoperite rămân pentru totdeauna și dau +Amintiri (când există Amintirile).
- **Cartea de rune** primește **Tabla Vrăjilor**: o grilă de 8 × 8, cu Elementele pe coloane și Țintele pe rânduri. Căsuțele descoperite arată numele vrăjii, cele nedescoperite „?”. Dedesubt sunt cele 8 Acțiuni. E colecția pe care jucătorul vrea s-o umple.
- **Semnul rolului pe piatră** (colțul din dreapta sus, culoare os):
  - Element = triunghi plin;
  - Acțiune = săgeată;
  - Țintă = cerc cu punct.
  Fișa de la mouse arată și rolul: „Element — Gheața”.

## 6. Instruirea: Lecția 4 nouă
Dacă `PROMPT_INSTRUIRE.md` n-a fost făcut încă, folosește Lecția 4 de mai jos în locul celei de acolo. Dacă a fost făcut deja, înlocuiește Lecția 4.

**În Lecțiile 1–3 vrăjile sunt oprite.** Altfel, Hagalaz + Fehu din Lecțiile 1 și 3 ar forma din greșeală vraja „Grindina în Monede”, înainte ca jucătorul să știe ce e o vrajă.

**Mâna:** Isaz (E), Tiwaz (Ț), Fehu (Ț), Hagalaz (E), Uruz (E), Ehwaz (A), Mannaz (Ț), Gebo (A).
**Rostiri:** 3. **Schimbări:** 0. Lecția se termină după pasul 9, indiferent de scor.

1. „Acum ceva ce nu-ți spune nimeni la examen. Runele nu sunt doar cifre. Sunt cuvinte.” [continuă]
2. „Uită-te la semnul din colț. Triunghiul e un Element, cercul e o Țintă, săgeata e o Acțiune.” [lumină: semnele de pe Isaz, Tiwaz, Ehwaz] [continuă]
3. „O vrajă e o propoziție: întâi Elementul, apoi Ținta. Alege Isaz, apoi Tiwaz. În ordinea asta.” [așteaptă: Isaz selectat 1, Tiwaz selectat 2]
4. „Citește sub cerc: «Gheața peste Țintă». Ce face? Nu știi până n-o rostești.” [lumină: propoziția] [continuă]
5. „Rostește.” [așteaptă: vraja Iarna descoperită] → animația mare; ținta scade.
6. „Acum invers. Alege Fehu, apoi Hagalaz.” [așteaptă: Fehu selectat 1, Hagalaz selectat 2] → previzualizarea arată „Ordinea e greșită”.
7. „Aceleași rune, altă ordine: nimic. Ordinea contează.” [continuă] → selecția se golește.
8. „Pune o Acțiune la mijloc. Uruz, apoi Ehwaz, apoi Fehu: «Forța aleargă de două ori în Monede». Rostește.” [așteaptă: vraja rostită] → +8 Monede (4 × 2) și animația mică „Ai învățat: aleargă de două ori”.
9. „Opt Elemente, opt Acțiuni, opt Ținte. Sute de vrăji, toate citite ca propoziții. Restul îl afli singur.” [continuă]

**Indicii noi** în `hints.json` (pornite acum):
| id | Când | Cine | Text |
|---|---|---|---|
| `first_wrong_order` | prima ordine greșită în afara instruirii | Ilinca | „Elementul vine primul, Ținta la urmă. Așa vorbesc runele.” |
| `first_scroll` | primul Pergament (Gebo) | Ilinca | „Ai păstrat vraja pe pergament. Folosește-o când ai nevoie.” |
| `first_two_actions` | prima vrajă cu două Acțiuni | Ilinca | „Două Acțiuni. Te dai mare. Îmi place.” |

## 7. Pașii de lucru

**Pasul A — Datele și logica**
- `runes.json`: câmpurile `role` și `phrase {ro, en}`;
- `spells_base.json` (64 de vrăji, cu nume, efect, moment, câmpuri scalabile; cele cu Talismane și Examinator au `enabled: false`);
- `spell_actions.json` (8 Acțiuni);
- `SentenceParser` (curat, testabil): primește pietrele în ordinea de rostire și întoarce vraja, Acțiunile sau motivul pentru care nu e vrajă;
- `SpellResolver`: aplică efectul cu Acțiunile, la momentul corect, cu limitele de siguranță;
- scoți cele 8 Vrăji vechi; schimbi textele Glasurilor Gebo, Ehwaz și Tiwaz.

*Teste:*
- E→Ț, E→A→Ț, E→A→A→Ț;
- ordine greșită; propoziție întreruptă de altă piatră; două propoziții în aceeași Rostire (contează doar prima);
- fiecare Acțiune pe un efect numeric și pe unul cu `single`;
- limitele (ținta minimum 40%, +2 Rostiri maximum).

**Pasul B — Interfața**
- semnul rolului pe pietre;
- numerele de ordine pe pietrele selectate;
- propoziția sub cerc, cu „???” și mesajele de ajutor;
- animațiile de descoperire;
- locul pentru Pergament;
- Tabla Vrăjilor în Cartea de rune;
- rolul în fișa de la mouse.

*Test (îl face Relax):*
- selectez Isaz, apoi Tiwaz → văd „Gheața peste Țintă ???” → rostesc → descopăr Iarna;
- invers → „Ordinea e greșită”;
- Uruz → Ehwaz → Fehu → +8 Monede;
- Tabla Vrăjilor are 2 căsuțe completate.

**Pasul C — Balans**
- Rulează simulatorul cu o strategie simplă care caută vrăji.
- Arată-mi: cât de des apare o vrajă într-o Rostire, ce vrăji sunt prea puternice sau inutile, și cât de des se atinge limita de 40% la țintă.
- Propune ajustări. **Dacă vrăjile apar în aproape orice Rostire și fac jocul prea ușor**, propune-mi variante. De exemplu: vrăjile simple (E→Ț) mai slabe, sau cel mult 2 vrăji pe rundă.

**Pasul D — Instruirea și documentele**
- Lecția 4 nouă și indiciile noi din secțiunea 6;
- `docs/DESIGN.md`: secțiunea „Gramatica runelor” în locul vechii 3.15;
- `CLAUDE.md`: o notă că vrăjile funcționează după acest document;
- traducerile în engleză, ca să le vadă Relax.

**Notă despre complexitate:** o piatră are acum patru lucruri de citit: Poziție, Neam, Glas, Rol. Dacă la test pare prea mult, Relax spune. Opțiunea `rune_voices_start_awake` există deja: putem porni cu Glasurile adormite și le trezim mai târziu cu o Gravură.
