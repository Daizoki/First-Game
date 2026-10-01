# Artă

Ghidul complet (stil, simboluri de evitat, ordinea în care desenezi): [`docs/ARTA.md`](../docs/ARTA.md).

Pune PNG-urile aici, cu numele egal cu `id`-ul din `data/*.json` (ex.: `art/talismans/ilinca_chalk.png`).
Dacă un fișier lipsește, jocul desenează singur un placeholder. Nu trebuie scris cod nou: fișierul apare în joc la
următoarea pornire.

| Ce | Mărime (px) | Folder |
|---|---|---|
| Piatra de bază (+ variante: os, chihlimbar, aur, fier, sticlă) | 160×200 | `stones/` |
| Rune desenate (opțional; înlocuiesc liniile din cod) | 128×128, fundal transparent | `runes/` |
| Talismane | 300×420 | `talismans/` |
| Lecții / Gravuri | 240×336 | `lessons/`, `engravings/` |
| Examinatori, Aeva, Tanti Vera | 512×512 | `examiners/`, `portraits/` |
| Fundaluri | 1920×1080 | `backgrounds/` |
| Rame UI (9-slice) | după nevoie | `ui/` |

Nume de fișiere pe care codul le caută deja:
- `stones/stone.png` — piatra de bază (runa o desenează codul peste ea);
- `runes/<id>.png` — de ex. `runes/fehu.png`;
- `examiners/<id>.png` — portretul rotund din cartea examinatorului (de ex. `examiners/ilinca.png`);
- `backgrounds/round_table.png` — fundalul ecranului de rundă;
- `backgrounds/classroom.png` — sala de curs a Școlii de Rune (numele, instruirea);
- `portraits/<id>.png` — portretul din bulele de dialog (de ex. `portraits/ilinca.png`); dacă lipsește, se folosește
  `examiners/<id>.png`, apoi cercul cu inițiala.
