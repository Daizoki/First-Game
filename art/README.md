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

> Folderele vechi (`characters/`, `enemies/`, `gods/`, `cards/`, `blessings/`) sunt din v2 și dispar la migrarea la v3.
