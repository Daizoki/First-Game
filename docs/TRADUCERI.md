# Traducerile în engleză

> Generat cu `python3 tools/export_translations.py` din fișierele din `data/`. Nu-l edita de mână: schimbă
> textul în JSON și rulează din nou scriptul. `{name}`, `{n}` … sunt locuri pe care jocul le completează.

## Instruirea (`data/tutorial.json`)

### Intro

| Unde | Română | English |
|---|---|---|
| `intro.lines[0].text` | Deci tu ești {name}. Mâine dai Examenul de Moștenire și n-ai ținut o rună în mână. Minunat. | So you are {name}. Tomorrow you sit the Inheritance Exam and you have never held a rune. Wonderful. |
| `intro.lines[1].text` | Ai o seară. Eu am răbdare pentru o seară. Hai. | You have one evening. I have patience for one evening. Come. |
| `intro.learn` | Învață-mă | Teach me |
| `intro.skip` | Mă descurc singur | I'll manage on my own |
| `intro.confirm` | Sigur? Kaldor nu explică nimic. | Sure? Kaldor explains nothing. |
| `intro.confirm_yes` | Da, sar | Yes, skip |
| `intro.confirm_no` | Nu, rămân | No, I'll stay |

### Lecția 1 — Pietrele și Rostirea

| Unde | Română | English |
|---|---|---|
| `title` | Pietrele și Rostirea | Stones and Casting |
| `fail_text` | Mai încearcă. Nu se notează. | Try again. It isn't graded. |
| `pas 1.text` | Asta e mâna ta: opt pietre. Fiecare are o rună. | This is your hand: eight stones. Each one bears a rune. |
| `pas 2.text` | Ține mouse-ul pe o piatră ca să afli ce e. | Hover over a stone to find out what it is. |
| `pas 3.text` | Cifra din colț e Poziția. Culoarea e Neamul. Restul îl citești singur. | The number in the corner is the Position. The color is the Kin. The rest you can read yourself. |
| `pas 4.text` | Două pietre cu aceeași Poziție fac o Pereche. Fehu și Hagalaz au amândouă Poziția 1. Alege-le. | Two stones with the same Position make a Pair. Fehu and Hagalaz both have Position 1. Pick them. |
| `pas 4.wait_for.alt_text` | Și asta e o Pereche. Bine. | That is a Pair too. Fine. |
| `pas 4.wrong_text` | Nu astea. Uită-te la cifra din colț. | Not those. Look at the number in the corner. |
| `pas 5.text` | În cerc vezi ce Cuvânt ai format, înainte să-l rostești. | The circle shows which Word you have made, before you cast it. |
| `pas 6.text` | Rostește. | Cast. |
| `pas 6.phase_captions.word` | Cuvântul îți dă o Putere și o Rezonanță de bază. | The Word gives you a base Power and Resonance. |
| `pas 6.phase_captions.stone` | Fiecare piatră care punctează adaugă Putere. | Every stone that scores adds Power. |
| `pas 6.phase_captions.total` | Putere × Rezonanță. Asta e scorul. | Power × Resonance. That is the score. |
| `pas 7.text` | Scorurile se adună până atingi Ținta. Fiecare lumânare e o Rostire. Când se sting toate, ai picat. | Scores add up until you reach the Target. Each candle is a Cast. When they all go out, you have failed. |
| `pas 8.text` | Mai ai o Pereche în mână. Găsește-o singur. | There is another Pair in your hand. Find it yourself. |

### Lecția 2 — Schimbarea și Cuvintele mari

| Unde | Română | English |
|---|---|---|
| `title` | Schimbarea și Cuvintele mari | Swapping and big Words |
| `fail_text` | Mai încearcă. Nu se notează. | Try again. It isn't graded. |
| `pas 1.text` | Uneori mâna e proastă. Nu o rosti. Schimb-o. | Sometimes your hand is bad. Don't cast it. Swap it. |
| `pas 2.text` | Raidho și Wunjo nu te ajută acum. Alege-le și apasă Schimbă. | Raidho and Wunjo are no help right now. Pick them and press Swap. |
| `pas 3.text` | Acum ai trei pietre cu Poziția 3 și două cu Poziția 7. Asta e o Familie. | Now you have three stones with Position 3 and two with Position 7. That is a Family. |
| `pas 4.text` | Poți rosti cel mult cinci pietre. Cu cât un Cuvânt e mai rar, cu atât valorează mai mult. Alege Familia. | You can cast at most five stones. The rarer a Word, the more it is worth. Pick the Family. |
| `pas 4.wrong_text` | Trei de 3 și doi de 7. Numără. | Three 3s and two 7s. Count. |
| `pas 5.text` | Rostește. | Cast. |
| `pas 6.text` | Toate Cuvintele sunt în Cartea Cuvintelor. O deschizi de aici, oricând. | Every Word is in the Book of Words. Open it from here, any time. |

### Lecția 3 — Glasul runelor

| Unde | Română | English |
|---|---|---|
| `title` | Glasul runelor | The Voice of the runes |
| `fail_text` | Mai încearcă. Nu se notează. | Try again. It isn't graded. |
| `pas 1.text` | Runele nu sunt doar cifre. Fiecare are un Glas, un efect venit din sensul ei. | Runes are not just numbers. Each one has a Voice, an effect that comes from its meaning. |
| `pas 2.text` | Ține mouse-ul pe Hagalaz. | Hover over Hagalaz. |
| `pas 3.text` | Hagalaz e grindina și lovește de două ori. Fehu e avuția și îți aduce o monedă. | Hagalaz is hail and strikes twice. Fehu is wealth and brings you a Coin. |
| `pas 4.text` | Rostește-le împreună și uită-te ce se întâmplă. | Cast them together and watch what happens. |
| `pas 4.wrong_text` | Hagalaz și Fehu. Împreună. | Hagalaz and Fehu. Together. |
| `pas 4.phase_captions.voice:hagalaz` | Glasul lui Hagalaz: încă o dată! | Hagalaz's Voice: once more! |
| `pas 4.phase_captions.voice:fehu` | Glasul lui Fehu: +1 Monedă. | Fehu's Voice: +1 Coin. |
| `pas 5.text` | Citește Glasul fiecărei rune. Aici se câștigă examenele. | Read the Voice of every rune. That is where exams are won. |

### Lecția 4 — Vrăjile

| Unde | Română | English |
|---|---|---|
| `title` | Vrăjile | Spells |
| `fail_text` | Mai încearcă. Nu se notează. | Try again. It isn't graded. |
| `pas 1.text` | Acum ceva ce nu-ți spune nimeni la examen. Runele nu sunt doar cifre. Sunt cuvinte. | Now something nobody tells you at the exam. Runes are not just numbers. They are words. |
| `pas 2.text` | Uită-te la semnul din colț. Triunghiul e un Element, cercul e o Țintă, săgeata e o Acțiune. | Look at the sign in the corner. The triangle is an Element, the circle is a Target, the arrow is an Action. |
| `pas 3.text` | O vrajă e o propoziție: întâi Elementul, apoi Ținta. Alege Isaz, apoi Tiwaz. În ordinea asta. | A spell is a sentence: first the Element, then the Target. Pick Isaz, then Tiwaz. In that order. |
| `pas 3.wrong_text` | Întâi Isaz, apoi Tiwaz. Elementul vine primul. | Isaz first, then Tiwaz. The Element comes first. |
| `pas 4.text` | Citește sub cerc: «Gheața peste Țintă». Ce face? Nu știi până n-o rostești. | Read under the circle: “Ice on the Target”. What does it do? You won't know until you cast it. |
| `pas 5.text` | Rostește. | Cast. |
| `pas 6.text` | Acum invers. Alege Fehu, apoi Hagalaz. | Now the other way round. Pick Fehu, then Hagalaz. |
| `pas 6.wrong_text` | Întâi Fehu, apoi Hagalaz. | Fehu first, then Hagalaz. |
| `pas 7.text` | Aceleași rune, altă ordine: nimic. Ordinea contează. | Same runes, different order: nothing. Order matters. |
| `pas 8.text` | Pune o Acțiune la mijloc. Uruz, apoi Ehwaz, apoi Fehu: «Forța aleargă de două ori în Monede». | Put an Action in the middle. Uruz, then Ehwaz, then Fehu: “Strength runs twice into Coins”. |
| `pas 8.wrong_text` | Uruz, Ehwaz, Fehu. În ordinea asta. | Uruz, Ehwaz, Fehu. In that order. |
| `pas 9.text` | Rostește. | Cast. |
| `pas 10.text` | Opt Elemente, opt Acțiuni, opt Ținte. Sute de vrăji, toate citite ca propoziții. Restul îl afli singur. | Eight Elements, eight Actions, eight Targets. Hundreds of spells, all read as sentences. The rest you'll find out yourself. |

### Lecția 5 — Singur

| Unde | Română | English |
|---|---|---|
| `title` | Singur | On your own |
| `fail_text` | Mai încearcă. Tot ce înveți aici rămâne. | Try again. Everything you learn here stays with you. |
| `win_text` | Nu-i rău. Mâine dimineață e examenul. Kaldor nu e la fel de răbdător ca mine. | Not bad. The exam is tomorrow morning. Kaldor is not as patient as I am. |
| `idle_hint.text` | Caută o Pereche. Sau citește Glasurile. | Look for a Pair. Or read the Voices. |
| `pas 1.text` | Acum fără mine. Ținta e mică. Nu mă face de rușine. | Now without me. The Target is small. Don't embarrass me. |

## Gramatica runelor (`data/runes.json`, `data/spells_base.json`, `data/spell_actions.json`)

### Rolul fiecărei rune în propoziție

| Rună | Română | English |
|---|---|---|
| `fehu · target` | în Monede | into Coins |
| `uruz · element` | Forța | Strength |
| `thurisaz · element` | Spinul | Thorn |
| `ansuz · target` | în Cuvânt | into the Word |
| `raidho · action` | se întinde | spreads |
| `kenaz · element` | Focul | Fire |
| `gebo · action` | se dăruiește | is given away |
| `wunjo · target` | în Talismane | into the Talismans |
| `hagalaz · element` | Grindina | Hail |
| `naudiz · action` | cere un preț | asks a price |
| `isaz · element` | Gheața | Ice |
| `jera · action` | se coace | ripens |
| `eihwaz · action` | durează | endures |
| `perthro · action` | riscă | gambles |
| `algiz · target` | asupra Examinatorului | against the Examiner |
| `sowilo · element` | Soarele | Sun |
| `tiwaz · target` | peste Țintă | on the Target |
| `berkanan · action` | crește | grows |
| `ehwaz · action` | aleargă de două ori | runs twice |
| `mannaz · target` | în Mână | into the Hand |
| `laguz · element` | Apa | Water |
| `ingwaz · target` | în Viitor | into the Future |
| `dagaz · element` | Ziua | Day |
| `othala · target` | în Săculeț | into the Bag |

### Cele 64 de vrăji (nume și efect)

| Vraja | Română | English |
|---|---|---|
| `kenaz_tiwaz` | Pârjolul | Scorch |
| `kenaz_tiwaz · efect` | Ținta scade cu {percent}% pentru fiecare piatră care a punctat. | The Target drops by {percent}% for every stone that scored. |
| `uruz_tiwaz` | Asaltul | Onslaught |
| `uruz_tiwaz · efect` | Ținta scade cu {percent}% din Puterea acestei Rostiri. | The Target drops by {percent}% of this Cast's Power. |
| `isaz_tiwaz` | Iarna | Winter |
| `isaz_tiwaz · efect` | Ținta scade cu {percent}%. | The Target drops by {percent}%. |
| `hagalaz_tiwaz` | Prăpădul | Havoc |
| `hagalaz_tiwaz · efect` | Ținta scade cu {percent}%, dar pierzi o Schimbare. | The Target drops by {percent}%, but you lose a Swap. |
| `laguz_tiwaz` | Viitura | Flash Flood |
| `laguz_tiwaz · efect` | Ținta scade cu {percent}% acum; ținta rundei următoare crește cu 10%. | The Target drops by {percent}% now; next round's Target rises by 10%. |
| `sowilo_tiwaz` | Amiaza | High Noon |
| `sowilo_tiwaz · efect` | Scorul acestei Rostiri se adună încă o dată ({percent}%). | This Cast's score is added once more ({percent}%). |
| `thurisaz_tiwaz` | Ghimpele | The Barb |
| `thurisaz_tiwaz · efect` | Ținta scade cu {percent}%, dar Rezonanța acestei Rostiri devine 1. | The Target drops by {percent}%, but this Cast's Resonance becomes 1. |
| `dagaz_tiwaz` | Ziua lungă | The Long Day |
| `dagaz_tiwaz · efect` | +{count} Rostire în runda asta. | +{count} Cast this round. |
| `kenaz_fehu` | Fierăria | The Forge |
| `kenaz_fehu · efect` | +{amount} Monedă pentru fiecare piatră care a punctat. | +{amount} Coin for every stone that scored. |
| `uruz_fehu` | Târgul | The Fair |
| `uruz_fehu · efect` | +{amount} Monede. | +{amount} Coins. |
| `isaz_fehu` | Cămara | The Larder |
| `isaz_fehu · efect` | +{amount} Monedă pentru fiecare 5 Monede pe care le ai (cel mult +{max}). | +{amount} Coin for every 5 Coins you have (at most +{max}). |
| `hagalaz_fehu` | Ciobul | The Shard |
| `hagalaz_fehu · efect` | Spargi o piatră aleasă din mână (iese definitiv din săculeț) → +{amount} Monede. | Smash a stone you pick from your hand (it leaves the bag for good) → +{amount} Coins. |
| `laguz_fehu` | Izvorul | The Spring |
| `laguz_fehu · efect` | +{amount} Monedă pentru fiecare piatră din mână. | +{amount} Coin for every stone in your hand. |
| `sowilo_fehu` | Aurul | Gold |
| `sowilo_fehu · efect` | +{amount} Monede pentru fiecare piatră din Neamul lui Fehu din mână. | +{amount} Coins for every stone of Fehu's Kin in your hand. |
| `thurisaz_fehu` | Camăta | Usury |
| `thurisaz_fehu · efect` | +{amount} Monede, dar −1 Rostire. | +{amount} Coins, but −1 Cast. |
| `dagaz_fehu` | Simbria | Wages |
| `dagaz_fehu · efect` | La finalul rundei, +{amount} Monede pentru fiecare Rostire rămasă. | At the end of the round, +{amount} Coins for every Cast left. |
| `kenaz_othala` | Călirea | Tempering |
| `kenaz_othala · efect` | {count} pietre aleatorii din săculeț primesc +{amount} Putere, permanent. | {count} random stones in the bag get +{amount} Power for good. |
| `uruz_othala` | Ucenicia | Apprenticeship |
| `uruz_othala · efect` | Pietrele care au punctat primesc +{amount} Putere, permanent. | The stones that scored get +{amount} Power for good. |
| `isaz_othala` | Întoarcerea | The Return |
| `isaz_othala · efect` | Pietrele rostite acum se întorc imediat în săculeț. | The stones cast now go straight back into the bag. |
| `hagalaz_othala` | Cernerea | Sifting |
| `hagalaz_othala · efect` | Scoți definitiv până la {count} pietre alese din mână. | Remove up to {count} stones you pick from your hand, for good. |
| `laguz_othala` | Înfierea | Adoption |
| `laguz_othala · efect` | Muți {count} pietre alese din mână în alt Neam, la alegere. | Move {count} stones you pick from your hand into another Kin of your choice. |
| `sowilo_othala` | Prevestirea | Foresight |
| `sowilo_othala · efect` | Vezi primele {count} pietre din săculeț și le pui în ce ordine vrei. | See the top {count} stones of the bag and put them in any order. |
| `thurisaz_othala` | Altoiul | The Graft |
| `thurisaz_othala · efect` | O piatră aleatorie din mână se sparge; adaugi în săculeț {count} copii ale unei pietre alese. | A random stone in your hand breaks; add {count} copies of a stone you pick to the bag. |
| `dagaz_othala` | Ecoul | Echo |
| `dagaz_othala · efect` | Adaugi în săculeț câte {count} copie a fiecărei pietre care a punctat. | Add {count} copy of every stone that scored to the bag. |
| `kenaz_mannaz` | Vatra | The Hearth |
| `kenaz_mannaz · efect` | +{count} piatră în mână pentru restul rundei. | +{count} stone in your hand for the rest of the round. |
| `uruz_mannaz` | Încurajarea | Encouragement |
| `uruz_mannaz · efect` | Pietrele rămase în mână primesc +{amount} Putere în runda asta. | The stones left in your hand get +{amount} Power this round. |
| `isaz_mannaz` | Răbdarea | Patience |
| `isaz_mannaz · efect` | +{amount} Rezonanță pentru fiecare piatră rămasă în mână. | +{amount} Resonance for every stone left in your hand. |
| `hagalaz_mannaz` | Furtuna | The Storm |
| `hagalaz_mannaz · efect` | Arunci toată mâna și tragi alta, gratis. | Throw away your whole hand and draw a new one, for free. |
| `laguz_mannaz` | Valul | The Wave |
| `laguz_mannaz · efect` | Schimbi până la {count} pietre, gratis. | Swap up to {count} stones, for free. |
| `sowilo_mannaz` | Alegerea | The Choice |
| `sowilo_mannaz · efect` | Tragi {count} pietre și păstrezi una la alegere; celelalte se întorc în săculeț. | Draw {count} stones and keep the one you pick; the others go back into the bag. |
| `thurisaz_mannaz` | Jertfa | The Offering |
| `thurisaz_mannaz · efect` | Arunci 2 pietre alese → +{count} Rostire. | Throw away 2 stones you pick → +{count} Cast. |
| `dagaz_mannaz` | Răgazul | Respite |
| `dagaz_mannaz · efect` | +{count} Schimbare. | +{count} Swap. |
| `kenaz_ansuz` | Văpaia | Blaze |
| `kenaz_ansuz · efect` | ×{factor} Rezonanță. | ×{factor} Resonance. |
| `uruz_ansuz` | Strigătul | The Shout |
| `uruz_ansuz · efect` | +{amount} Putere. | +{amount} Power. |
| `isaz_ansuz` | Lecția | The Lesson |
| `isaz_ansuz · efect` | Cuvântul rostit crește cu {count} nivel, permanent. | The Word you cast goes up {count} level for good. |
| `hagalaz_ansuz` | Bâlbâiala | The Stutter |
| `hagalaz_ansuz · efect` | Pietrele care punctează mai punctează de {count} ori, dar Cuvântul scade cu 1 nivel (minimum 1). | The scoring stones score {count} more time, but the Word drops 1 level (at least 1). |
| `laguz_ansuz` | Revărsarea | Overflow |
| `laguz_ansuz · efect` | Cuvântul punctează ca următorul Cuvânt din listă (Pereche → Două perechi…). | The Word scores as the next Word on the list (Pair → Two Pairs…). |
| `sowilo_ansuz` | Lumina plină | Full Light |
| `sowilo_ansuz · efect` | ×{factor} Rezonanță dacă rostești 5 pietre. | ×{factor} Resonance if you cast 5 stones. |
| `thurisaz_ansuz` | Rana | The Wound |
| `thurisaz_ansuz · efect` | ×{factor} Rezonanță, dar o piatră aleatorie din Cuvânt se sparge definitiv. | ×{factor} Resonance, but a random stone of the Word breaks for good. |
| `dagaz_ansuz` | Zorii | Dawn |
| `dagaz_ansuz · efect` | ×{factor} Rezonanță dacă e prima Rostire a rundei. | ×{factor} Resonance if it is the round's first Cast. |
| `kenaz_ingwaz` | Jarul de mâine | Tomorrow's Embers |
| `kenaz_ingwaz · efect` | Următoarea Rostire are ×{factor} Rezonanță. | Your next Cast has ×{factor} Resonance. |
| `uruz_ingwaz` | Avântul | Momentum |
| `uruz_ingwaz · efect` | Următoarea Rostire are +{amount} Putere. | Your next Cast has +{amount} Power. |
| `isaz_ingwaz` | Merindea | Provisions |
| `isaz_ingwaz · efect` | Scorul peste țintă din runda asta trece în runda următoare ({percent}%). | The score above this round's Target carries into the next round ({percent}%). |
| `hagalaz_ingwaz` | Avansul | Head Start |
| `hagalaz_ingwaz · efect` | Runda următoare începe cu {percent}% din țintă atinsă, dar cu −1 Schimbare. | Next round starts with {percent}% of the Target reached, but with −1 Swap. |
| `laguz_ingwaz` | Mareea | The Tide |
| `laguz_ingwaz · efect` | La începutul rundei următoare tragi {count} pietre în plus și păstrezi 8. | At the start of next round, draw {count} extra stones and keep 8. |
| `sowilo_ingwaz` | Clarviziunea | Clairvoyance |
| `sowilo_ingwaz · efect` | În runda următoare vezi mereu următoarele {count} pietre din săculeț. | Next round, you always see the next {count} stones of the bag. |
| `thurisaz_ingwaz` | Datoria | The Debt |
| `thurisaz_ingwaz · efect` | Următoarea Rostire are ×{factor} Rezonanță, cea de după ×0,5. | Your next Cast has ×{factor} Resonance, the one after ×0.5. |
| `dagaz_ingwaz` | Ziua de mâine | Tomorrow |
| `dagaz_ingwaz · efect` | Runda următoare are +{count} Rostire. | Next round has +{count} Cast. |
| `kenaz_wunjo` | Scânteia | Spark |
| `kenaz_wunjo · efect` | Talismanul din stânga se declanșează de două ori la Rostirea asta. | The leftmost Talisman triggers twice on this Cast. |
| `uruz_wunjo` | Fanfara | Fanfare |
| `uruz_wunjo · efect` | +{amount} Putere pentru fiecare Talisman. | +{amount} Power for every Talisman. |
| `isaz_wunjo` | Conserva | Preserves |
| `isaz_wunjo · efect` | Talismanele care se consumă nu scad în runda asta. | Talismans that wear out don't wear this round. |
| `hagalaz_wunjo` | Lichidarea | Clearance |
| `hagalaz_wunjo · efect` | Vinzi un Talisman ales pe prețul întreg. | Sell a Talisman you pick for its full price. |
| `laguz_wunjo` | Metamorfoza | Metamorphosis |
| `laguz_wunjo · efect` | Un Talisman ales devine altul, aleatoriu, de aceeași raritate. | A Talisman you pick becomes another random one of the same rarity. |
| `sowilo_wunjo` | Vitrina | The Shop Window |
| `sowilo_wunjo · efect` | La următoarea Piață apare sigur un Talisman Rar. | A Rare Talisman surely appears at the next Market. |
| `thurisaz_wunjo` | Sacrificiul | The Sacrifice |
| `thurisaz_wunjo · efect` | Distrugi un Talisman ales → ×{factor} Rezonanță tot restul Probei. | Destroy a Talisman you pick → ×{factor} Resonance for the rest of the Trial. |
| `dagaz_wunjo` | Ziua de târg | Market Day |
| `dagaz_wunjo · efect` | +{count} Talisman în oferta Pieței următoare. | +{count} Talisman in the next Market's offer. |
| `kenaz_algiz` | Fumul | Smoke |
| `kenaz_algiz · efect` | Regula Examinatorului nu se aplică acestei Rostiri. | The Examiner's rule does not apply to this Cast. |
| `uruz_algiz` | Revolta | Revolt |
| `uruz_algiz · efect` | Regula e anulată tot restul rundei, dar ținta crește cu 10%. | The rule is cancelled for the rest of the round, but the Target rises by 10%. |
| `isaz_algiz` | Înghețul | The Freeze |
| `isaz_algiz · efect` | Regula e anulată tot restul rundei. | The rule is cancelled for the rest of the round. |
| `hagalaz_algiz` | Asurzirea | Deafening |
| `hagalaz_algiz · efect` | Regula e anulată pentru următoarele {count} Rostiri. | The rule is cancelled for the next {count} Casts. |
| `laguz_algiz` | Schimbul | The Trade |
| `laguz_algiz · efect` | Schimbi regula cu una din {count} reguli ale altor Examinatori, la alegere. | Swap the rule for one of {count} other Examiners' rules, your choice. |
| `sowilo_algiz` | Iscoada | The Scout |
| `sowilo_algiz · efect` | Vezi Examinatorii și regulile lor din următoarele {count} Probe. | See the Examiners and their rules for the next {count} Trials. |
| `thurisaz_algiz` | Înțepătura | The Sting |
| `thurisaz_algiz · efect` | Ținta Examinatorului scade cu {percent}%; regula rămâne. | The Examiner's Target drops by {percent}%; the rule stays. |
| `dagaz_algiz` | Amânarea | Extension |
| `dagaz_algiz · efect` | +{count} Rostire în runda asta. | +{count} Cast this round. |

### Cele 8 Acțiuni

| Acțiune | Română | English |
|---|---|---|
| `raidho` | Dacă vraja atinge o singură piatră sau un singur Talisman, le atinge pe toate, la jumătate de putere; altfel, valorile ×1,5. | If the spell touches a single stone or Talisman, it touches all of them at half strength; otherwise its values ×1.5. |
| `ehwaz` | Efectul se aplică de 2 ori. | The effect happens twice. |
| `eihwaz` | Efectul se aplică din nou la începutul următoarelor 2 runde, la jumătate de putere. | The effect happens again at the start of the next 2 rounds, at half strength. |
| `berkanan` | +50% pentru fiecare dată când ai mai rostit aceeași vrajă în acest examen. | +50% for every time you have already cast this spell in this exam. |
| `jera` | Efectul vine abia la finalul rundei, dar dublu. | The effect only comes at the end of the round, but doubled. |
| `perthro` | 50%: efect ×3; 50%: nimic. | 50%: effect ×3; 50%: nothing. |
| `naudiz` | Alegi pe loc: pierzi 1 Rostire sau 4 Monede; efect ×2,5. | Choose on the spot: lose 1 Cast or 4 Coins; effect ×2.5. |
| `gebo` | Vraja nu se aplică acum: primești un Pergament cu ea și îl folosești când vrei. | The spell doesn't happen now: you get a Scroll with it and use it whenever you want. |

## Examenul (`data/examiners.json`, `talismans.json`, `lessons.json`, `engravings.json`, `dialogs.json`)

### Examinatorii

| Examinator | Română | English |
|---|---|---|
| `kaldor · title` | Garda sus! | Guard up! |
| `kaldor · text` | Trebuie să rostești exact 5 pietre. | You must cast exactly 5 stones. |
| `kaldor · intro` | Mănușile pe mâini. Cinci pietre, nu patru. Garda sus! | Gloves on. Five stones, not four. Guard up! |
| `kaldor · defeated` | Bun croșeu. Treci. | Nice hook. You pass. |
| `kaldor · won` | Ai lăsat garda jos. | You dropped your guard. |
| `selvia · title` | Fluxul | The Tide |
| `selvia · text` | După fiecare Rostire, pietrele din mână se întorc în săculeț și tragi altele. | After every Cast, the stones in your hand go back into the bag and you draw new ones. |
| `selvia · intro` | Apa nu stă pe loc. Nici mâna ta. | Water never stands still. Neither does your hand. |
| `selvia · defeated` | Ai înotat bine. Ieși la mal. | You swam well. Come ashore. |
| `selvia · won` | Te-a luat valul. | The wave took you. |
| `varr · title` | Fulgerul | Lightning |
| `varr · text` | La fiecare Rostire, o piatră aleatorie din Cuvânt nu punctează. | Every Cast, a random stone of the Word doesn't score. |
| `varr · intro` | Urcă, urcă, că plecăm! Și ține-te bine, trăsnește. | Get on, we're leaving! And hold tight, there's lightning. |
| `varr · defeated` | Stația ta. Coboară, campionule. | Your stop. Off you get, champ. |
| `varr · won` | Ai pierdut troleibuzul. | You missed the trolleybus. |
| `ignar · title` | Taxa | The Fee |
| `ignar · text` | Fiecare Schimbare costă 1 Monedă. | Every Swap costs 1 Coin. |
| `ignar · intro` | La mine nimic nu e gratis. Nici măcar o Schimbare. | Nothing's free at my place. Not even a Swap. |
| `ignar · defeated` | Ai plătit cinstit. Ia o shaorma din partea casei. | You paid fair. Have a shawarma on the house. |
| `ignar · won` | Fără bani, fără shaorma. | No money, no shawarma. |
| `lunet · title` | Visul | The Dream |
| `lunet · text` | Primele 3 pietre trase de fiecare dată vin cu fața în jos. | The first 3 stones drawn each time come face down. |
| `lunet · intro` | Închide ochii. Pietrele vorbesc și în vis. | Close your eyes. Stones speak in dreams too. |
| `lunet · defeated` | Te-ai trezit la timp. Rar. | You woke up in time. Rare. |
| `lunet · won` | Ai adormit pe examen. | You fell asleep on the exam. |
| `gronn · title` | Greutatea | The Weight |
| `gronn · text` | Runele cu Poziția 1–3 nu punctează. | Runes with Position 1–3 don't score. |
| `gronn · intro` | Pe șantierul meu, pietrele ușoare nu contează. | On my site, light stones don't count. |
| `gronn · defeated` | Ai construit ceva solid. Treci. | You built something solid. Pass. |
| `gronn · won` | S-a dărâmat tot. | It all came down. |
| `morrah · title` | Ține minte | Remember |
| `morrah · text` | Un tip de Cuvânt deja rostit în runda asta nu mai punctează. | A Word already cast this round no longer scores. |
| `morrah · intro` | Liniște. Aici nimic nu se spune de două ori. | Quiet. Nothing is said twice in here. |
| `morrah · defeated` | Îmi voi aminti de tine. | I will remember you. |
| `morrah · won` | Te-ai repetat. | You repeated yourself. |
| `ilinca · title` | Corectura | The Correction |
| `ilinca · text` | Rună singură și Pereche dau scor 0. | Single Rune and Pair score 0. |
| `ilinca · intro` | Azi corectez cu pixul roșu. Nimic ușor nu trece. | Today I grade with the red pen. Nothing easy passes. |
| `ilinca · defeated` | Notă de trecere. Sunt mândră de tine. | A passing grade. I'm proud of you. |
| `ilinca · won` | Mai citește lecțiile. | Read your lessons again. |
| `dara · title` | Competiția | The Competition |
| `dara · text` | Ținta crește cu 10% după fiecare Rostire. | The Target grows by 10% after every Cast. |
| `dara · intro` | Hai să vedem cine e mai bun. Eu, evident. | Let's see who's better. Me, obviously. |
| `dara · defeated` | …Data viitoare nu mai ai noroc. | …Next time you won't be so lucky. |
| `dara · won` | Ți-am spus. | Told you. |
| `nix · title` | Păcăleala | The Trick |
| `nix · text` | Talismanul din stânga e dezactivat în runda asta. | The leftmost Talisman is switched off this round. |
| `nix · intro` | Ups. Unde ți-e Talismanul? Nu, nu l-am luat eu. | Oops. Where's your Talisman? No, I didn't take it. |
| `nix · defeated` | Bine, bine. Ți-l dau înapoi. | Fine, fine. Here, have it back. |
| `nix · won` | Ha! Te-am păcălit. | Ha! Got you. |
| `aeva · title` | Clepsidra | The Hourglass |
| `aeva · text` | O singură Rostire, dar Schimbări nelimitate. După a treia, fiecare Schimbare costă 1 Monedă. | A single Cast, but unlimited Swaps. After the third, every Swap costs 1 Coin. |
| `aeva · intro` | Am văzut dimineața asta de o mie de ori. Arată-mi una nouă. | I've seen this morning a thousand times. Show me a new one. |
| `aeva · defeated` | Timpul îți aparține. Moștenirea e a ta. | Time is yours. The inheritance is yours. |
| `aeva · won` | Din nou. Ne vedem dimineață. | Again. See you in the morning. |

### Talismanele

| Talisman | Română | English |
|---|---|---|
| `ilinca_chalk` | Creta Maestrei Ilinca | Master Ilinca's Chalk |
| `ilinca_chalk · efect` | +{value} Rezonanță la fiecare Rostire. | +{value} Resonance on every Cast. |
| `gronn_helmet` | Casca de șantier a lui Gronn | Gronn's Hard Hat |
| `gronn_helmet · efect` | +{value} Putere la fiecare Rostire. | +{value} Power on every Cast. |
| `varr_umbrella` | Umbrela lui Varr | Varr's Umbrella |
| `varr_umbrella · efect` | Pietrele din Neamul lui Hagalaz dau +{value} Rezonanță când punctează. | Stones of Hagalaz's Kin give +{value} Resonance when they score. |
| `selvia_shell` | Scoica Selviei | Selvia's Shell |
| `selvia_shell · efect` | +{value} Schimbare în fiecare rundă. | +{value} Swap every round. |
| `lunet_coffee` | Cafeaua de noapte a lui Lunet | Lunet's Night Coffee |
| `lunet_coffee · efect` | +{value} piatră în mână. | +{value} stone in hand. |
| `ignar_shawarma` | Shaorma lui Ignar | Ignar's Shawarma |
| `ignar_shawarma · efect` | +{value} Rezonanță; scade cu 1 după fiecare Rostire și dispare la 0. | +{value} Resonance; drops by 1 after every Cast and is gone at 0. |
| `trolley_ticket` | Biletul pe troleibuzul 22 | Ticket for Trolleybus 22 |
| `trolley_ticket · efect` | +{value} Monedă de fiecare dată când rostești un Șir. | +{value} Coin every time you cast a Row. |
| `market_granny` | Bunica din piață | The Market Granny |
| `market_granny · efect` | Totul în Piață costă cu {value} Monedă mai puțin. | Everything at the Market costs {value} Coin less. |
| `kaldor_gloves` | Mănușile lui Kaldor | Kaldor's Gloves |
| `kaldor_gloves · efect` | ×{value} Rezonanță dacă în Cuvânt punctează exact 5 pietre. | ×{value} Resonance if exactly 5 stones score in the Word. |
| `ignar_lighter` | Bricheta lui Ignar | Ignar's Lighter |
| `ignar_lighter · efect` | Prima piatră care punctează în fiecare Rostire punctează de două ori. | The first stone that scores in each Cast scores twice. |
| `morrah_bookmark` | Semnul de carte al Morrei | Morrah's Bookmark |
| `morrah_bookmark · efect` | +{value} Rezonanță, permanent, pentru fiecare tip de Cuvânt nou rostit în examen (acum: +{now}). | +{value} Resonance, for good, for every new kind of Word cast in the exam (now: +{now}). |
| `toma` | Toma, fiul lui Gronn | Toma, Gronn's Son |
| `toma · efect` | +{value} Putere pentru fiecare piatră rămasă în săculeț. | +{value} Power for every stone left in the bag. |
| `nix` | Nix, copilul lui Lunet | Nix, Lunet's Child |
| `nix · efect` | Copiază efectul Talismanului din dreapta lui. | Copies the effect of the Talisman to its right. |
| `dara` | Dara, fiica lui Kaldor | Dara, Kaldor's Daughter |
| `dara · efect` | ×{value} Rezonanță; crește cu +{step} după fiecare Examinator învins. | ×{value} Resonance; grows by +{step} after every Examiner beaten. |
| `aeva_hourglass` | Clepsidra Aevei | Aeva's Hourglass |
| `aeva_hourglass · efect` | O dată pe examen: dacă pici o rundă, o iei de la capăt. Apoi Clepsidra se sparge. | Once per exam: if you fail a round, you play it again. Then the Hourglass breaks. |

### Lecțiile și Gravurile

| Consumabil | Română | English |
|---|---|---|
| `lesson_single` | Lecția despre Runa singură | The Lesson on the Single Rune |
| `lesson_single · text` | Cea mai scurtă lecție din școală. Ilinca a ținut-o în trei secunde. | The shortest lesson in the school. Ilinca gave it in three seconds. |
| `lesson_pair` | Lecția despre Perechi | The Lesson on Pairs |
| `lesson_pair · text` | Kaldor a picat-o de două ori. Ironic. | Kaldor failed it twice. Ironic. |
| `lesson_two_pairs` | Lecția despre Două perechi | The Lesson on Two Pairs |
| `lesson_two_pairs · text` | Varr a venit cu doi prieteni. Nu se pune. | Varr came with two friends. Doesn't count. |
| `lesson_triad` | Lecția despre Treimi | The Lesson on Triads |
| `lesson_triad · text` | Trei pietre, trei pagini, trei cafele. | Three stones, three pages, three coffees. |
| `lesson_kin` | Lecția despre Neamuri | The Lesson on Kins |
| `lesson_kin · text` | Toată familia la masă, fiecare cu culoarea lui. | The whole family at the table, each in their colour. |
| `lesson_family` | Lecția despre Familie | The Lesson on the Family |
| `lesson_family · text` | Gronn a adus poze cu Toma. Multe poze. | Gronn brought photos of Toma. Lots of photos. |
| `lesson_row` | Lecția despre Șiruri | The Lesson on Rows |
| `lesson_row · text` | Ca stațiile troleibuzului 22: una după alta, fără sărituri. | Like the stops of trolleybus 22: one after another, no skipping. |
| `lesson_four` | Lecția despre Patru | The Lesson on Four |
| `lesson_four · text` | Patru pietre la fel. Selvia zice că e noroc de pescar. | Four of the same. Selvia calls it fisherman's luck. |
| `lesson_chant` | Lecția despre Descântec | The Lesson on the Chant |
| `lesson_chant · text` | Lunet a cântat-o la radio la trei noaptea. Nimeni n-a dormit. | Lunet sang it on the radio at 3 a.m. Nobody slept. |
| `lesson_ancient_word` | Lecția despre Cuvântul Vechi | The Lesson on the Old Word |
| `lesson_ancient_word · text` | Pagina e ruptă. Morrah zice că așa a găsit-o. | The page is torn. Morrah says she found it that way. |
| `bone` | Gravura de Os | Bone Engraving |
| `bone · text` | O piatră din mână devine de os: +{value} Putere când punctează. | A stone in your hand becomes bone: +{value} Power when it scores. |
| `amber` | Gravura de Chihlimbar | Amber Engraving |
| `amber · text` | O piatră din mână devine de chihlimbar: +{value} Rezonanță când punctează. | A stone in your hand becomes amber: +{value} Resonance when it scores. |
| `gold` | Gravura de Aur | Gold Engraving |
| `gold · text` | O piatră din mână devine de aur: +{value} Monede dacă rămâne în mână la finalul rundei. | A stone in your hand becomes gold: +{value} Coins if it stays in hand at the end of the round. |
| `iron` | Gravura de Fier | Iron Engraving |
| `iron · text` | O piatră din mână devine de fier: ×{value} Rezonanță cât timp rămâne în mână când rostești. | A stone in your hand becomes iron: ×{value} Resonance while it stays in hand when you cast. |
| `glass` | Gravura de Sticlă | Glass Engraving |
| `glass · text` | O piatră din mână devine de sticlă: ×{value} Rezonanță când punctează, dar se poate sparge (1 din 4). | A stone in your hand becomes glass: ×{value} Resonance when it scores, but it may break (1 in 4). |
| `binding` | Legătura | The Binding |
| `binding · text` | Leagă 2 pietre din mână într-o legătură runică: contează ca oricare dintre cele două rune, iar când punctează se aud ambele Glasuri. | Binds 2 stones in your hand into a bind-rune: it counts as either rune, and when it scores both Voices are heard. |
| `reshaping` | Prefacerea | The Reshaping |
| `reshaping · text` | Schimbă runa unei pietre din mână într-o rună la alegere din același Neam. | Changes the rune of a stone in your hand into a rune of your choice from the same Kin. |
| `double` | Dublura | The Double |
| `double · text` | Adaugă în săculeț o copie a unei pietre din mână. | Adds a copy of a stone in your hand to the bag. |
| `shatter` | Sfărâmarea | The Shattering |
| `shatter · text` | Scoate definitiv din săculeț până la {count} pietre din mână. | Removes up to {count} stones in your hand from the bag for good. |
| `relocation` | Strămutarea | The Relocation |
| `relocation · text` | Mută până la {count} pietre din mână în alt Neam (runa rămâne). | Moves up to {count} stones in your hand to another Kin (the rune stays). |

### Replicile Tantei Vera

| Replică | Română | English |
|---|---|---|
| `vera_market 1` | Bună seara, puiule. Ce-ți trebuie azi? | Good evening, dear. What do you need tonight? |
| `vera_market 2` | Runele astea le vând de patruzeci de ani. Nu s-au plâns niciodată. | I've sold these runes for forty years. They never complained. |
| `vera_market 3` | Ia și tu ceva, că mă uit la tine de un sfert de oră. | Buy something, I've been watching you for a quarter of an hour. |
| `vera_market 4` | Kaldor a cumpărat de aici mănușile. Și le-a pierdut de trei ori. | Kaldor bought his gloves here. Lost them three times. |
| `vera_market 5` | Shaorma e de la Ignar, nu de la mine. Eu doar o vând. | The shawarma is Ignar's, not mine. I just sell it. |
| `vera_market 6` | Prețurile nu se negociază. Bine, puțin. Nu. | Prices aren't negotiable. Well, a little. No. |
| `vera_market 7` | Ai față de om care trece examenul. Sau de om care n-a dormit. | You look like someone who'll pass. Or someone who hasn't slept. |

## Indiciile (`data/hints.json`)

| Indiciu | Română | English |
|---|---|---|
| `first_laguz` | Laguz e apă: curge. Contează ca piatră din orice Neam. | Laguz is water: it flows. It counts as a stone of any Kin. |
| `idle_help` | Nu știi ce să faci? Ține mouse-ul pe pietre sau deschide Cartea Cuvintelor. | Not sure what to do? Hover over the stones or open the Book of Words. |
| `first_wrong_order` | Elementul vine primul, Ținta la urmă. Așa vorbesc runele. | The Element comes first, the Target last. That's how runes speak. |
| `first_scroll` | Ai păstrat vraja pe pergament. Folosește-o când ai nevoie. | You kept the spell on a scroll. Use it when you need it. |
| `first_two_actions` | Două Acțiuni. Te dai mare. Îmi place. | Two Actions. Showing off. I like it. |
| `first_shop_1` | Bună seara, puiule. Aici cumperi ce te ține în viață la examen. | Good evening, dear. Here you buy what keeps you alive in the exam. |
| `first_shop_2` | Talismanele lucrează singure, de la stânga la dreapta. Ai cinci locuri. | Talismans work on their own, from left to right. You have five slots. |
| `first_shop_3` | Lecțiile cresc un Cuvânt. Gravurile schimbă pietrele. Săculețele… surpriză. | Lessons raise a Word. Engravings change stones. Bags… a surprise. |
| `first_reroll` | Nu-ți place marfa? Rearanjez taraba, dar nu gratis. | Don't like the goods? I'll rearrange the stall, but not for free. |
| `first_talisman` | Trage Talismanele ca să le schimbi ordinea. Ordinea contează. | Drag the Talismans to change their order. Order matters. |
| `first_examiner` | Eu sunt Kaldor. Regula mea e scrisă acolo. N-o repet. | I am Kaldor. My rule is written there. I won't say it twice. |
| `first_rule` | Al treilea vine Examinatorul. Are o regulă, scrisă pe fișa lui. Citește-o înainte să rostești. | Third comes the Examiner. They have a rule, written on their card. Read it before you cast. |
| `first_lesson` | O Lecție crește nivelul unui Cuvânt pentru tot examenul. | A Lesson raises a Word's level for the whole exam. |
| `first_engraving` | O Gravură schimbă o piatră. În rundă, apasă pe Gravură, apoi alege piatra din mână. | An Engraving changes a stone. In a round, click the Engraving, then pick the stone in your hand. |
| `first_bindrune` | O legătură e o piatră cu două rune. Contează ca oricare dintre ele, iar Glasurile se aud amândouă. | A bind-rune is a stone with two runes. It counts as either of them, and both Voices are heard. |
| `first_loss_1 (oprit)` | Ai picat. Se întâmplă. Ție ți se întâmplă des. | You failed. It happens. It happens to you a lot. |
| `first_loss_2 (oprit)` | Te întorc în dimineața examenului. Tu ții minte tot, ceilalți nu. Nu mă întreba de ce. | I'm sending you back to the morning of the exam. You remember everything, the others don't. Don't ask me why. |
| `first_loss_3 (oprit)` | Ce ai adunat se numește Amintiri. Cheltuiește-le cu cap. | What you gathered is called Memories. Spend them wisely. |
| `first_evening_class (oprit)` | În ultima bancă stau Kaldor și Varr. Repetă cursul. Nu fi ca ei. | Kaldor and Varr sit in the back row. They're repeating the class. Don't be like them. |
| `first_torn_page (oprit)` | Am găsit-o într-o carte veche. Spune ce rune trebuie. Restul e treaba ta. | I found it in an old book. It says which runes you need. The rest is up to you. |
| `first_curse (oprit)` | Nu toate Vrăjile sunt prietenoase. Ai învățat ceva azi. | Not every Spell is friendly. You learned something today. |
| `first_old_word (oprit)` | Cuvântul ăsta e scris pe pietre mai vechi decât orice zeu. De unde îl știi? | This Word is carved on stones older than any god. How do you know it? |

## Textele interfeței (`data/ui_text.json`)

| Cheie | Română | English |
|---|---|---|
| `game_title` | Examenul de Moștenire | The Inheritance Exam |
| `game_subtitle` | Universul Coborârea · Jocul 1 | The Descent universe · Game 1 |
| `game_motto` | Puterea o moștenești. Runele le înveți. | Power is inherited. Runes are learned. |
| `version` | v{version} | v{version} |
| `menu_play` | Joacă | Play |
| `menu_runes` | Cele 24 de rune | The 24 runes |
| `menu_settings` | Setări | Settings |
| `menu_quit` | Ieșire | Quit |
| `menu_play_soon` | Aeva încă pregătește sălile de examen. Revino curând. | Aeva is still preparing the exam halls. Come back soon. |
| `data_errors_title` | Erori în fișierele din data/ ({count}) | Errors in the data/ files ({count}) |
| `data_errors_close` | Continuă oricum | Continue anyway |
| `settings_title` | Setări | Settings |
| `settings_language` | Limba | Language |
| `settings_volume` | Volum | Volume |
| `settings_volume_value` | {value}% | {value}% |
| `settings_back` | Înapoi | Back |
| `language_ro` | Română | Română |
| `language_en` | English | English |
| `rune_check_title` | Cele 24 de rune ale Futharkului vechi | The 24 runes of the Elder Futhark |
| `rune_check_hint` | Ține mouse-ul pe o rună ca să vezi sensul și Glasul ei. | Hover a rune to see its meaning and Voice. |
| `rune_position` | Poz. {n} · Putere {power} | Pos. {n} · Power {power} |
| `rune_tooltip` | Sens istoric: {meaning} În joc: {voice} | Historical meaning: {meaning} In game: {voice} |
| `number_millions` | {n} mil. | {n}M |
| `number_decimal_point` | , | . |
| `number_thousands_separator` |   | , |
| `round_practice` | Rundă de antrenament | Practice round |
| `round_coins` | Monede | Coins |
| `round_bag` | Săculeț | Bag |
| `round_bag_value` | {left} / {total} | {left} / {total} |
| `round_seed` | Seed: {seed} | Seed: {seed} |
| `round_score_of` | din {target} | of {target} |
| `round_casts` | Rostiri | Casts |
| `round_swaps` | Schimbări | Swaps |
| `round_cast_button` | Rostește | Cast |
| `round_swap_button` | Schimbă | Swap |
| `round_sort` | Sortează: | Sort: |
| `round_sort_position` | Poziție | Position |
| `round_sort_kin` | Neam | Kin |
| `round_speed` | Viteză ×{n} | Speed ×{n} |
| `round_menu` | Meniu | Menu |
| `round_target` | Ținta: {target} | Target: {target} |
| `round_practice_rule` | Rundă de antrenament: fără regulă specială. | Practice round: no special rule. |
| `round_talisman_slot` | Talisman | Talisman |
| `round_consumable_slot` | Lecție / Gravură | Lesson / Engraving |
| `circle_hint` | Alege 1–5 pietre | Pick 1–5 stones |
| `circle_scoring_one` | 1 piatră punctează | 1 stone scores |
| `circle_scoring_many` | {n} pietre punctează | {n} stones score |
| `circle_level` | nivel {n} | level {n} |
| `circle_awakening` | ceva se trezește în cerc… | something stirs in the circle… |
| `circle_spell` | Vrajă: {name} | Spell: {name} |
| `word_hidden` | ??? | ??? |
| `kenaz_peek` | Făclia lui Kenaz: următoarele pietre | Kenaz's torch: the next stones |
| `float_power` | +{n} | +{n} |
| `float_add_res` | +{n} Rez. | +{n} Res. |
| `float_mul_res` | ×{n} Rez. | ×{n} Res. |
| `float_money` | +{n} Monede | +{n} Coins |
| `float_swap` | +{n} Schimbare | +{n} Swap |
| `float_grow` | +{n} Putere pentru totdeauna | +{n} Power for good |
| `float_copy` | o copie intră în săculeț | a copy joins the bag |
| `float_rule` | regula nu se aplică | the rule is lifted |
| `spell_reveal_title` | Ai descoperit o Vrajă! | You discovered a Spell! |
| `spell_reveal_memories` | +{n} Amintiri | +{n} Memories |
| `spell_reveal_continue` | Apasă oriunde ca să continui | Click anywhere to continue |
| `word_discovered` | Ai descoperit: {name}! | You discovered: {name}! |
| `futhark_message` | F-U-Þ-A-R: ai scris începutul alfabetului runic! | F-U-Þ-A-R: you wrote the start of the runic alphabet! |
| `result_won_title` | Ai trecut runda! | Round passed! |
| `result_lost_title` | Ai picat runda | Round failed |
| `result_score` | Scor: {score} din {target} | Score: {score} of {target} |
| `result_money` | +{n} Monede la final de rundă | +{n} Coins at the end of the round |
| `result_again` | Încă o rundă | Another round |
| `result_menu` | Meniu | Menu |
| `menu_tutorial` | Instruire | Evening class |
| `name_title` | Cum te cheamă? | What is your name? |
| `name_hint` | Maestra Ilinca vrea să știe pe cine pregătește. | Master Ilinca wants to know who she is teaching. |
| `name_placeholder` | Numele tău | Your name |
| `name_ok` | Mai departe | Continue |
| `settings_tutorial` | Instruirea | Evening class |
| `settings_tutorial_replay` | Reia instruirea | Replay the evening class |
| `settings_hints` | Indicii | Hints |
| `settings_on` | pornite | on |
| `settings_off` | oprite | off |
| `pause_title` | Pauză | Paused |
| `pause_resume` | Continuă | Resume |
| `pause_main_menu` | Meniul principal | Main menu |
| `pause_skip_tutorial` | Sari peste instruire | Skip the evening class |
| `tutorial_lesson_title` | Lecția {n} · {title} | Lesson {n} · {title} |
| `tutorial_click` | clic » | click » |
| `float_retrigger` | încă o dată! | once more! |
| `card_position_kin` | Poziția {n} · {kin} | Position {n} · {kin} |
| `card_meaning` | Sens istoric: {meaning} | Historical meaning: {meaning} |
| `card_power` | Putere {n} | Power {n} |
| `card_voice` | Glas: {voice} | Voice: {voice} |
| `word_book_title` | Cartea Cuvintelor | Book of Words |
| `word_book_hint` | De la cel mai puternic la cel mai obișnuit · tasta C o deschide oricând | From the strongest to the most common · press C to open it any time |
| `word_book_close` | Închide | Close |
| `word_book_values` | {power} × {res} | {power} × {res} |
| `word_book_button` | Cuvinte | Words |
| `hint_close` | clic ca să închizi | click to close |
| `word_card_scoring` | Punctează {n} din {total} pietre · ele strălucesc în mână | {n} of {total} stones score · they glow in your hand |
| `word_card_values` | Putere {power} × Rezonanță {res} | Power {power} × Resonance {res} |
| `pause_rune_book` | Cartea de rune | Book of Runes |
| `rune_book_title` | Cartea de rune | Book of Runes |
| `rune_book_hint` | Cele 24 de rune, cu sensul, rolul și Glasul lor · Tabla Vrăjilor | The 24 runes with their meaning, role and Voice · the Table of Spells |
| `rune_book_position` | Poziția {n} · Putere {power} | Position {n} · Power {power} |
| `rune_book_spells` | Vrăjile · {n} din {total} descoperite | Spells · {n} of {total} discovered |
| `rune_book_close` | Închide | Close |
| `spell_unknown` | {sentence} · ??? | {sentence} · ??? |
| `spell_dormant` | {sentence} · se trezește mai târziu | {sentence} · wakes up later |
| `spell_incomplete` | {sentence} → … · propoziție neterminată | {sentence} → … · unfinished sentence |
| `spell_wrong_order` | Ordinea e greșită: Elementul vine primul. | Wrong order: the Element comes first. |
| `spell_interrupted` | Propoziția e întreruptă: între Element și Țintă încap cel mult două Acțiuni. | The sentence is broken: at most two Actions fit between the Element and the Target. |
| `float_set_res` | Rez. = {n} | Res. = {n} |
| `spell_scroll_kept` | {name} așteaptă pe Pergament. | {name} waits on a Scroll. |
| `spell_fizzled` | {name}: n-a mers de data asta. | {name}: no luck this time. |
| `action_learned_title` | Ai învățat | You learned |
| `sentence_unknown` | ??? | ??? |
| `sentence_spell` | {name}: {effect} | {name}: {effect} |
| `sentence_repeats` | (de {n} ori) | ({n} times) |
| `sentence_ignored` | „{phrase}” nu schimbă nimic aici | “{phrase}” changes nothing here |
| `sentence_dormant` | se trezește mai târziu | wakes up later |
| `sentence_incomplete` | propoziție neterminată | unfinished sentence |
| `role_element` | Element | Element |
| `role_action` | Acțiune | Action |
| `role_target` | Țintă | Target |
| `card_role` | {role} — {phrase} | {role} — {phrase} |
| `scroll_empty` | Pergament | Scroll |
| `scroll_title` | Pergamentul | The Scroll |
| `scroll_use` | apasă ca s-o pregătești | click to make it ready |
| `scroll_armed` | pleacă la următoarea Rostire | goes with the next Cast |
| `scroll_card_empty` | Gol. Pune Gebo („se dăruiește”) într-o propoziție și vraja ei așteaptă aici până o folosești. | Empty. Put Gebo (“gives itself”) in a sentence and its spell waits here until you use it. |
| `scroll_card_use` | Apasă pe Pergament: vraja se întâmplă odată cu următoarea Rostire. | Click the Scroll: the spell happens together with the next Cast. |
| `scroll_card_armed` | Pregătit: se întâmplă odată cu următoarea Rostire. Apasă din nou ca să-l păstrezi. | Ready: it happens together with the next Cast. Click again to keep it. |
| `scroll_happened` | Din Pergament · {name}: {effect} | From the Scroll · {name}: {effect} |
| `choice_title` | Alege | Choose |
| `choice_price` | Naudiz cere un preț. Ce dai? | Naudiz asks a price. What do you give? |
| `choice_pay_cast` | {n} Rostire | {n} Cast |
| `choice_pay_money` | {n} Monede | {n} Coins |
| `choice_break_chosen_money` | Alege din mână piatra care se sparge. Iese definitiv din săculeț și dă +{amount} Monede. | Pick the stone in your hand that breaks. It leaves the bag for good and gives +{amount} Coins. |
| `choice_remove_chosen` | Alege din mână până la {n} pietre. Ies definitiv din săculeț. | Pick up to {n} stones in your hand. They leave the bag for good. |
| `choice_change_kin_chosen` | Alege din mână până la {n} pietre, apoi Neamul în care trec. | Pick up to {n} stones in your hand, then the Kin they move to. |
| `choice_reorder_bag_top` | Primele pietre din săculeț. Apasă-le în ordinea în care vrei să le tragi. | The top stones of the bag. Click them in the order you want to draw them. |
| `choice_copy_chosen_to_bag` | Alege o piatră din mână: {n} copii ale ei intră în săculeț. | Pick a stone in your hand: {n} copies of it go into the bag. |
| `choice_free_swap_chosen` | Alege din mână până la {n} pietre de schimbat, gratis. | Pick up to {n} stones in your hand to swap, for free. |
| `choice_draw_keep` | Păstrează una dintre pietre. Celelalte se întorc în săculeț. | Keep one of the stones. The others go back into the bag. |
| `choice_discard_chosen` | Alege din mână {n} pietre de aruncat. | Pick {n} stones in your hand to throw away. |
| `choice_put_back` | Ai tras pietre în plus. Alege {n} de pus înapoi în săculeț. | You drew extra stones. Pick {n} to put back into the bag. |
| `choice_confirm` | Gata | Done |
| `choice_keep_order` | Lasă așa | Leave them |
| `choice_picked` | Alese: {n} din {max} | Picked: {n} of {max} |
| `rune_book_tab_runes` | Runele | The runes |
| `rune_book_tab_spells` | Tabla Vrăjilor | Table of Spells |
| `rune_book_table_corner` | Elementul sus, Ținta în stânga | Element on top, Target on the left |
| `rune_book_actions` | Acțiunile | The Actions |
| `rune_book_action_unknown` | Încă n-ai folosit-o. Pune-o între Element și Țintă. | Not used yet. Put it between an Element and a Target. |
| `exam_trial` | Proba {n} din {total} | Trial {n} of {total} |
| `exam_round_small` | Întrebarea mică | The Small Question |
| `exam_round_big` | Întrebarea mare | The Big Question |
| `exam_round_examiner` | Examinatorul | The Examiner |
| `exam_title_small` | Proba {n} · Întrebarea mică | Trial {n} · The Small Question |
| `exam_title_big` | Proba {n} · Întrebarea mare | Trial {n} · The Big Question |
| `exam_title_examiner` | Proba {n} · Examinatorul | Trial {n} · The Examiner |
| `exam_rule` | Regula · {title}: {text} | The rule · {title}: {text} |
| `exam_no_rule` | Fără regulă. Examinatorul doar se uită. | No rule. The examiner just watches. |
| `exam_money` | Monede: {n} | Coins: {n} |
| `exam_start_round` | Începe | Begin |
| `exam_peek` | Iscoada îți șoptește cine urmează: {list} | The Scout whispers who comes next: {list} |
| `exam_round_won` | Ai răspuns! | Answered! |
| `exam_defeated` | L-ai învins pe Examinator: {name} | You beat the Examiner: {name} |
| `exam_reward_small` | Întrebarea mică: +{n} Monede | The Small Question: +{n} Coins |
| `exam_reward_big` | Întrebarea mare: +{n} Monede | The Big Question: +{n} Coins |
| `exam_reward_examiner` | Examinatorul: +{n} Monede | The Examiner: +{n} Coins |
| `exam_reward_casts` | Rostiri rămase: +{n} Monede | Casts left: +{n} Coins |
| `exam_reward_interest` | Dobândă pentru economii: +{n} Monede | Interest on savings: +{n} Coins |
| `exam_reward_total` | Total: +{n} · acum ai {money} Monede | Total: +{n} · you now have {money} Coins |
| `exam_continue` | Mai departe | Onwards |
| `exam_passed_title` | Ai trecut Examenul de Moștenire! | You passed the Inheritance Exam! |
| `exam_failed_title` | Ai picat | You failed |
| `exam_stats` | Ai ajuns la Proba {trial} din {total} · Examinatori învinși: {defeated} · runde câștigate: {rounds} | You reached Trial {trial} of {total} · Examiners beaten: {defeated} · rounds won: {rounds} |
| `exam_again` | Încă un examen | Another exam |
| `card_face_down` | Piatră cu fața în jos | Face-down stone |
| `card_face_down_text` | Visul lui Lunet: afli ce rună e abia când o rostești. | Lunet's Dream: you find out which rune it is only when you cast it. |
| `circle_face_down` | o piatră doarme cu fața în jos | a stone sleeps face down |
| `round_swaps_endless` | Schimbări: fără sfârșit | Swaps: endless |
| `round_swap_button_cost` | Schimbă · {n} Mon. | Swap · {n} Coin |
| `float_rule_blocked` | nu punctează | doesn't score |
| `float_rule_zero` | Regula: scor 0 | The rule: score 0 |
| `choice_swap_rule` | Apa schimbă regula. Alege una dintre regulile altor Examinatori. | Water changes the rule. Pick one of the other Examiners' rules. |
| `rarity_common` | Comun | Common |
| `rarity_rare` | Rar | Rare |
| `rarity_legendary` | Legendar | Legendary |
| `talisman_disabled` | Nix l-a ascuns: nu lucrează în runda asta. | Nix hid it: it doesn't work this round. |
| `talisman_drag_hint` | Lucrează de la stânga la dreapta. Trage-l ca să schimbi ordinea. | They work left to right. Drag it to change the order. |
| `talisman_gone` | {name} s-a terminat. | {name} is used up. |
| `choice_sell_talisman_full` | Grindina vinde un Talisman pe prețul întreg. Care? | Hail sells a Talisman for its full price. Which one? |
| `choice_transform_talisman` | Apa schimbă un Talisman în altul de aceeași raritate. Care? | Water turns a Talisman into another of the same rarity. Which one? |
| `choice_destroy_talisman_res` | Spinul distruge un Talisman: ×{factor} Rezonanță tot restul Probei. Care? | The Thorn destroys a Talisman: ×{factor} Resonance for the rest of the Trial. Which one? |
| `exam_second_chance_title` | Clepsidra s-a spart | The Hourglass broke |
| `exam_second_chance_text` | Nisipul curge înapoi. Ai încă o încercare la aceeași întrebare. | The sand flows back. You get one more try at the same question. |
| `exam_retry` | Încă o dată | Once more |
| `consumable_lesson` | Lecție | Lesson |
| `consumable_engraving` | Gravură | Engraving |
| `consumable_use_hint` | Apasă ca s-o folosești. | Click to use it. |
| `consumable_cannot` | Nu se poate folosi acum. | It can't be used now. |
| `lesson_effect` | Cuvântul {word} crește cu 1 nivel pentru tot examenul. | The Word {word} goes up 1 level for the whole exam. |
| `lesson_learned` | {word} a urcat la nivelul {n}. | {word} rose to level {n}. |
| `choice_engrave_material` | Alege piatra din mână pe care o gravezi. | Pick the stone in your hand to engrave. |
| `choice_bind_chosen` | Alege 2 pietre din mână, cu rune diferite: devin o singură piatră cu ambele rune. | Pick 2 stones in your hand with different runes: they become one stone with both runes. |
| `choice_change_rune_chosen` | Alege piatra din mână, apoi runa în care se preface (din același Neam). | Pick the stone in your hand, then the rune it turns into (same Kin). |
| `card_bound` | Legată cu {rune}: {voice} | Bound with {rune}: {voice} |
| `material_bone` | Os: +{value} Putere când punctează | Bone: +{value} Power when it scores |
| `material_amber` | Chihlimbar: +{value} Rezonanță când punctează | Amber: +{value} Resonance when it scores |
| `material_gold` | Aur: +{value} Monede dacă rămâne în mână la final | Gold: +{value} Coins if it stays in hand at the end |
| `material_iron` | Fier: ×{value} Rezonanță cât stă în mână | Iron: ×{value} Resonance while held |
| `material_glass` | Sticlă: ×{value} Rezonanță, se poate sparge | Glass: ×{value} Resonance, may break |
| `float_glass_break` | s-a spart! | shattered! |
| `shop_title` | Piața de noapte | The Night Market |
| `shop_leave` | Pleacă din Piață | Leave the Market |
| `shop_money` | Monede: {n} | Coins: {n} |
| `shop_reroll` | Rearanjează taraba · {n} | Rearrange the stall · {n} |
| `shop_sold` | Vândut | Sold |
| `shop_buy` | Cumpără · {n} | Buy · {n} |
| `shop_no_slot` | Nu mai ai loc. Vinde ceva întâi. | No room left. Sell something first. |
| `shop_your_talismans` | Talismanele tale ({n} din {max}) | Your Talismans ({n} of {max}) |
| `shop_your_consumables` | Lecții și Gravuri ({n} din {max}) | Lessons and Engravings ({n} of {max}) |
| `shop_sell` | Vinde · {n} | Sell · {n} |
| `shop_learn` | Învață | Learn |
| `shop_kind_talisman` | Talisman | Talisman |
| `shop_kind_pack` | Săculeț · alegi 1 din 3 | Bag · pick 1 of 3 |
| `shop_kind_pack_big` | Săculeț mare · alegi 2 din 5 | Big Bag · pick 2 of 5 |
| `pack_talismans` | Săculeț cu Talismane | Bag of Talismans |
| `pack_lessons` | Săculeț cu Lecții | Bag of Lessons |
| `pack_engravings` | Săculeț cu Gravuri | Bag of Engravings |
| `pack_stones` | Săculeț cu pietre | Bag of Stones |
| `pack_text` | Îl deschizi și alegi un lucru din trei. Lecțiile se învață pe loc. | Open it and pick one thing out of three. Lessons are learned on the spot. |
| `pack_text_big` | Îl deschizi și alegi două lucruri din cinci. Lecțiile se învață pe loc. | Open it and pick two things out of five. Lessons are learned on the spot. |
| `pack_pick` | Mai poți lua: {n} | You can still take: {n} |
| `pack_skip` | Gata | Done |
| `pack_take` | Ia | Take |
