# Ghidul de artă

## Stilul
- **Desenat de mână:** contur de tuș gros, umbre adânci, texturi de piatră și hârtie. Paleta de bază e de noapte
  (bleumarin, violet închis, aproape negru), cu accente în culorile Neamurilor:
  **Neamul lui Fehu = auriu**, **Neamul lui Hagalaz = albastru-gheață**, **Neamul lui Tiwaz = roșu-cărămiziu**.
  Runele **strălucesc**.
- Fiecare Neam are și un mic semn propriu pe piatră (**monedă** / **fulg de grindină** / **stea**), ca să se distingă
  și fără culori.
- Referința lui Relax e o scenă nordică (Valhalla, corbi, noduri celtice). **Lumea noastră e alta:** Orașul Pragului
  noaptea, cu blocuri, firele troleibuzelor, tarabe cu becuri și ruine de temple printre blocuri.
  **Pietre de rune vechi + oraș est-european modern = stilul nostru.**
- **Simboluri de evitat:** folosim formele simple, singure, ale runelor. NU folosim:
  - Valknutul (cele trei triunghiuri împletite);
  - Othala cu „aripi” sau serife;
  - două Sowilo puse una lângă alta;
  - „soarele negru”.
  Variantele astea sunt folosite și de grupări extremiste, iar platformele le pot semnala.
- Interfața: panouri închise la culoare, cu contur de tuș și o linie interioară violet; rame de piatră și fier;
  colțuri cu mici gravuri runice (nu noduri celtice copiate din referință).
- Așezarea ecranului de rundă și efectele (linii care „fierb”, granulație de hârtie, pietre care se leagănă,
  animația Vrăjilor) sunt descrise în `docs/DESIGN.md` → 3.16.
- Balatro e doar inspirație pentru **mecanică**: nu copiem interfața, aranjarea ecranului sau efectele lui vizuale
  caracteristice.

## Paleta
| Nume | Culoare | Folosire |
|---|---|---|
| Noapte | `#0A0C18` | fundal |
| Violet | `#241B3A` | umbre, ceață |
| Cerneală | `#05060A` | contur (singurul negru pur) |
| Os | `#E9E3D2` | text, Putere |
| Jar | `#FF6A3D` | Rezonanță, butonul Rostește, bara de scor |
| Lumânare | `#FFB347` | lumini calde, ferestre, flăcări |
| Fehu | `#EBAA3C` | Neamul lui Fehu |
| Hagalaz | `#63C6F2` | Neamul lui Hagalaz |
| Tiwaz | `#E8573F` | Neamul lui Tiwaz |

Text secundar: `#A39DB4`.

## Fonturi
**Grenze Gotisch** (titluri, Vrăji, examinatori) + **Grenze** (text, interfață, cifre), ambele de pe Google Fonts,
licență OFL, cu ă â î ș ț. **Se descarcă doar după OK-ul lui Relax**; până atunci, fontul implicit.

## Tehnic
- Rezoluție de bază **1920×1080**, stretch `canvas_items`, aspect `expand`, filtru **Linear** cu mipmaps.
- Renderer **Compatibility**: strălucirea și fundalul animat se fac cu shadere proprii pe `CanvasItem` sau cu
  sprite-uri aditive, nu cu glow-ul din `WorldEnvironment`.
- **Runele se desenează din cod** (linii groase + strălucire în culoarea Neamului), din segmentele din `runes.json`.
  Dacă există `art/runes/<id>.png`, imaginea lui Relax o înlocuiește pe cea din cod.
- **Placeholder-uri:** dacă lipsește `art/<categorie>/<id>.png`, codul desenează o ramă închisă la culoare cu numele
  și o iconiță simplă. Pietrele sunt o formă de piatră procedurală, cu runa strălucind pe ea.

## Ce desenează Relax (dimensiuni)
| Ce | Câte | Mărime (px) | Folder |
|---|---|---|---|
| Piatra de bază (fără rună; runa o pune codul) | 1 + variante pentru materiale (os, chihlimbar, aur, fier, sticlă) | 160×200 | `art/stones/` |
| Rune desenate (opțional, înlocuiesc liniile din cod) | 24 | 128×128, fundal transparent | `art/runes/` |
| Talismane (ilustrația principală) | ~30 | 300×420 | `art/talismans/` |
| Lecții și Gravuri | ~20 | 240×336 | `art/lessons/`, `art/engravings/` |
| Examinatori, Aeva, Tanti Vera | ~12 | 512×512 | `art/examiners/`, `art/portraits/` |
| Fundaluri (masa de joc, Piața, Dimineața, cadrele din intro) | ~8 | 1920×1080 | `art/backgrounds/` |
| Rame UI (9-slice) | câteva | după nevoie | `art/ui/` |

**Ordinea în care desenează Relax:** piatra de bază → 3 Talismane (Creta Ilincăi, Umbrela lui Varr, Shaorma lui
Ignar) → fundalul mesei de joc. Cu atât, jocul arată deja „al lui” și se pot face primele clipuri.

Numele fișierelor = `id`-ul din `data/*.json` (ex.: `art/talismans/ilinca_chalk.png`).
