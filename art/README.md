# Artă

Pune PNG-urile aici, cu numele egal cu `id`-ul din `data/*.json` (ex.: `art/gods/varr.png`).
Dacă un fișier lipsește, jocul desenează singur un placeholder (dreptunghi colorat cu inițiala și numele).
Nu trebuie scris cod nou: fișierul apare în joc la următoarea pornire.

| Ce | Mărime | Folder | Exemplu |
|---|---|---|---|
| Erou, semizei (Dara, Nix, Toma) | 64×64 | `characters/` | `characters/dara.png` |
| Inamici | 64×64 | `enemies/` | `enemies/training_dummy.png` |
| Zei (boss / hub) | 128×128 | `gods/` | `gods/kaldor.png` |
| Portrete pentru dialog | 96×96 | `portraits/` | `portraits/aeva.png` |
| Iconițe cărți | 32×32 | `cards/` | `cards/strike.png` |
| Iconițe binecuvântări | 32×32 | `blessings/` | `blessings/varr_umbrella.png` |
| Fundaluri | 640×360 | `backgrounds/` | `backgrounds/main_menu.png` |
| Elemente de interfață | liber | `ui/` | |

Sfaturi: fundal transparent, fără anti-aliasing (jocul folosește filtrul Nearest, pixelii rămân clari).
