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

## Gramatica runelor (`data/runes.json`, `data/spells_base.json`, `data/spell_actions.json`)

### Rolul fiecărei rune în propoziție

| Rună | Română | English |
|---|---|---|
| `fehu · target` | în Monede | into Coins |
| `uruz · element` | Forța | Strength |
| `thurisaz · element` | Spinul | Thorn |
| `ansuz · target` | în Glas | into the Voice |
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
| `algiz · target` | asupra Stăpânului | upon the Lord |
| `sowilo · element` | Soarele | Sun |
| `tiwaz · target` | în Dușman | into the Enemy |
| `berkanan · action` | crește | grows |
| `ehwaz · action` | aleargă de două ori | runs twice |
| `mannaz · target` | în Tine | into You |
| `laguz · element` | Apa | Water |
| `ingwaz · target` | în Viitor | into the Future |
| `dagaz · element` | Ziua | Day |
| `othala · target` | în Săculeț | into the Bag |

### Cele 64 de vrăji (nume, efect și versul de pe Pagina ruptă)

| Vraja | Română | English |
|---|---|---|
| `kenaz_tiwaz` | Pârjolul | Scorch |
| `kenaz_tiwaz · efect` | Natura dublă: Arsură {double} pe strat. | Nature doubled: Burn {double} per stack. |
| `kenaz_tiwaz · vers` | Unde trece focul, fiecare piatră arde puțin din ce ți se cere. | Where the fire passes, every stone burns away a little of what is asked. |
| `uruz_tiwaz` | Asaltul | Onslaught |
| `uruz_tiwaz · efect` | Natura dublă: ignoră Scutul și îl sparge pentru toată lupta. | Nature doubled: ignores the Shield and breaks it for the whole fight. |
| `uruz_tiwaz · vers` | Taurul nu ocolește zidul. Cu cât lovește mai tare, cu atât zidul e mai mic. | The aurochs does not go around the wall. The harder it hits, the smaller the wall. |
| `isaz_tiwaz` | Iarna | Winter |
| `isaz_tiwaz · efect` | Natura dublă: Îngheț pentru {double} Rostiri. | Nature doubled: Freeze for {double} Casts. |
| `isaz_tiwaz · vers` | Gerul nu se grăbește. Doar face totul mai mic. | Frost is in no hurry. It just makes everything smaller. |
| `hagalaz_tiwaz` | Prăpădul | Havoc |
| `hagalaz_tiwaz · efect` | Natura dublă: lovește de {double} ori. | Nature doubled: strikes {double} times. |
| `hagalaz_tiwaz · vers` | Grindina sparge ce-i cerut, dar îți ia și o mână de ajutor. | Hail breaks what is asked, but takes a helping hand with it. |
| `laguz_tiwaz` | Viitura | Flash Flood |
| `laguz_tiwaz · efect` | Natura dublă: ignoră rezistențele, iar imunitățile devin rezistențe. | Nature doubled: ignores resistances, and immunities become resistances. |
| `laguz_tiwaz · vers` | Apa dărâmă azi zăgazul și se întoarce mâine mai mare. | Water breaks the dam today and comes back bigger tomorrow. |
| `sowilo_tiwaz` | Amiaza | High Noon |
| `sowilo_tiwaz · efect` | Natura dublă: ×{double} contra creaturilor nopții. | Nature doubled: ×{double} against creatures of the night. |
| `sowilo_tiwaz · vers` | La prânz, umbra dispare și orice faptă se vede de două ori. | At noon the shadow is gone and every deed is seen twice. |
| `thurisaz_tiwaz` | Ghimpele | The Barb |
| `thurisaz_tiwaz · efect` | Natura dublă: +{double} Rezonanță pentru fiecare Acțiune. | Nature doubled: +{double} Resonance for every Action. |
| `thurisaz_tiwaz · vers` | Spinul taie mult din ce ți se cere, dar ecoul tău rămâne mut. | The thorn cuts deep into what is asked, but your echo falls silent. |
| `dagaz_tiwaz` | Ziua lungă | The Long Day |
| `dagaz_tiwaz · efect` | Natura dublă: +{double}% daună pentru fiecare Rostire rămasă. | Nature doubled: +{double}% damage for every Cast left. |
| `dagaz_tiwaz · vers` | Când ziua se lungește, mai ai timp pentru încă o vorbă. | When the day grows long, there is time for one more word. |
| `kenaz_fehu` | Fierăria | The Forge |
| `kenaz_fehu · efect` | +{amount} Monedă pentru fiecare piatră din vrajă. | +{amount} Coin for every stone in the spell. |
| `kenaz_fehu · vers` | Fierarul plătește fiecare lovitură bună. | The smith pays for every good blow. |
| `uruz_fehu` | Târgul | The Fair |
| `uruz_fehu · efect` | +{amount} Monede. | +{amount} Coins. |
| `uruz_fehu · vers` | Taurul dus la târg nu se întoarce cu mâna goală. | The aurochs taken to the market never comes back empty-handed. |
| `isaz_fehu` | Cămara | The Larder |
| `isaz_fehu · efect` | +{amount} Monedă pentru fiecare 5 Monede pe care le ai (cel mult +{max}). | +{amount} Coin for every 5 Coins you have (at most +{max}). |
| `isaz_fehu · vers` | Ce ții la rece se înmulțește. Cămara plină naște cămară. | What you keep cold multiplies. A full pantry breeds a pantry. |
| `hagalaz_fehu` | Ciobul | The Shard |
| `hagalaz_fehu · efect` | Spargi o piatră aleasă din mână (iese definitiv din săculeț) → +{amount} Monede. | Break a chosen stone in your hand (it leaves the Bag for good) → +{amount} Coins. |
| `hagalaz_fehu · vers` | Spargi o piatră și din cioburi curg bani. | Break a stone and coins pour from the shards. |
| `laguz_fehu` | Izvorul | The Spring |
| `laguz_fehu · efect` | +{amount} Monedă pentru fiecare piatră din mână. | +{amount} Coin for every stone in your hand. |
| `laguz_fehu · vers` | Izvorul plătește pentru fiecare piatră pe care o atinge. | The spring pays for every stone it touches. |
| `sowilo_fehu` | Aurul | Gold |
| `sowilo_fehu · efect` | +{amount} Monede pentru fiecare piatră din Neamul lui Fehu din mână. | +{amount} Coins for every stone of the Kin of Fehu in your hand. |
| `sowilo_fehu · vers` | Soarele face aur doar din ce era deja avere. | The sun makes gold only from what was already wealth. |
| `thurisaz_fehu` | Camăta | Usury |
| `thurisaz_fehu · efect` | +{amount} Monede, dar −1 Rostire. | +{amount} Coins, but −1 Cast. |
| `thurisaz_fehu · vers` | Spinul îți umple punga, dar îți ia o vorbă. | The thorn fills your purse, but takes one of your words. |
| `dagaz_fehu` | Simbria | Wages |
| `dagaz_fehu · efect` | La finalul luptei, +{amount} Monede pentru fiecare Rostire rămasă. | At the end of the fight, +{amount} Coins for every Cast left. |
| `dagaz_fehu · vers` | La apus, fiecare vorbă nespusă se plătește. | At sunset, every unspoken word is paid for. |
| `kenaz_othala` | Călirea | Tempering |
| `kenaz_othala · efect` | {count} pietre aleatorii din săculeț primesc +{amount} Putere, permanent. | {count} random stones in the Bag gain +{amount} Power for good. |
| `kenaz_othala · vers` | Focul trece prin săculeț și călește pietre la întâmplare. | Fire runs through the Bag and tempers stones at random. |
| `uruz_othala` | Ucenicia | Apprenticeship |
| `uruz_othala · efect` | Pietrele acestei vrăji primesc +{amount} Putere, permanent. | The stones of this spell gain +{amount} Power for good. |
| `uruz_othala · vers` | Cine a muncit azi e mai tare mâine. | Whoever worked today is stronger tomorrow. |
| `isaz_othala` | Întoarcerea | The Return |
| `isaz_othala · efect` | Pietrele rostite acum se întorc imediat în săculeț. | The stones cast now go straight back into the Bag. |
| `isaz_othala · vers` | Gheața oprește timpul: pietrele rostite se întorc acasă. | Ice stops time: the spoken stones go back home. |
| `hagalaz_othala` | Cernerea | Sifting |
| `hagalaz_othala · efect` | Scoți definitiv până la {count} pietre alese din mână. | Remove up to {count} chosen stones in your hand for good. |
| `hagalaz_othala · vers` | Grindina cerne săculețul. Ce e slab nu se mai întoarce. | Hail sifts the Bag. What is weak never comes back. |
| `laguz_othala` | Înfierea | Adoption |
| `laguz_othala · efect` | Muți {count} pietre alese din mână în alt Neam, la alegere. | Move {count} chosen stones in your hand to another Kin of your choice. |
| `laguz_othala · vers` | Apa nu întreabă de neam. Te duce unde vrei. | Water does not ask about kin. It takes you where you want. |
| `sowilo_othala` | Prevestirea | Foresight |
| `sowilo_othala · efect` | Vezi primele {count} pietre din săculeț și le pui în ce ordine vrei. | See the top {count} stones of the Bag and put them in any order. |
| `sowilo_othala · vers` | Soarele luminează fundul săculețului și tu alegi ordinea. | The sun lights the bottom of the Bag and you choose the order. |
| `thurisaz_othala` | Altoiul | The Graft |
| `thurisaz_othala · efect` | O piatră aleatorie din mână se sparge; adaugi în săculeț {count} copii ale unei pietre alese. | A random stone in your hand breaks; add {count} copies of a chosen stone to the Bag. |
| `thurisaz_othala · vers` | Spinul taie o ramură ca să altoiască alta de două ori. | The thorn cuts one branch to graft another twice. |
| `dagaz_othala` | Ecoul | Echo |
| `dagaz_othala · efect` | Adaugi în săculeț câte {count} copie a fiecărei pietre din vrajă. | Add {count} copy of every stone of the spell to the Bag. |
| `dagaz_othala · vers` | Ce a sunat bine azi se aude iar în săculeț. | What rang true today echoes again in the Bag. |
| `kenaz_mannaz` | Vatra | The Hearth |
| `kenaz_mannaz · efect` | +{count} piatră în mână pentru restul luptei. | +{count} stone in hand for the rest of the fight. |
| `kenaz_mannaz · vers` | La vatră încape încă un om. | There is room for one more by the hearth. |
| `uruz_mannaz` | Încurajarea | Encouragement |
| `uruz_mannaz · efect` | Pietrele rămase în mână primesc +{amount} Putere în lupta asta. | The stones left in your hand gain +{amount} Power for this fight. |
| `uruz_mannaz · vers` | Cine rămâne în mână primește putere de la cei care au plecat. | Those who stay in hand draw strength from those who left. |
| `isaz_mannaz` | Pavăza | The Bulwark |
| `isaz_mannaz · efect` | +{count} Scut de inimă: oprește o pierdere de inimă. | +{count} Heart Shield: stops one lost heart. |
| `isaz_mannaz · vers` | Fiecare piatră care așteaptă cântă puțin. | Every stone that waits sings a little. |
| `hagalaz_mannaz` | Furtuna | The Storm |
| `hagalaz_mannaz · efect` | Arunci toată mâna și tragi alta, gratis. | Throw away your whole hand and draw a new one, for free. |
| `hagalaz_mannaz · vers` | Furtuna ia toată mâna și îți aduce alta. | The storm takes the whole hand and brings you another. |
| `laguz_mannaz` | Valul | The Wave |
| `laguz_mannaz · efect` | Schimbi până la {count} pietre, gratis. | Swap up to {count} stones, for free. |
| `laguz_mannaz · vers` | Valul ia pietrele și nu cere nimic în schimb. | The wave takes stones and asks nothing in return. |
| `sowilo_mannaz` | Alegerea | The Choice |
| `sowilo_mannaz · efect` | Tragi {count} pietre și păstrezi una la alegere; celelalte se întorc în săculeț. | Draw {count} stones and keep one; the others go back into the Bag. |
| `sowilo_mannaz · vers` | Soarele îți arată mai multe. Tu iei una. | The sun shows you many. You keep one. |
| `thurisaz_mannaz` | Jertfa | The Offering |
| `thurisaz_mannaz · efect` | Arunci 2 pietre alese → +{count} Rostire. | Discard 2 chosen stones → +{count} Cast. |
| `thurisaz_mannaz · vers` | Dai două pietre spinului și primești o vorbă în plus. | Give two stones to the thorn and get one more word. |
| `dagaz_mannaz` | Răgazul | Respite |
| `dagaz_mannaz · efect` | +{count} Schimbare. | +{count} Swap. |
| `dagaz_mannaz · vers` | Zorii îți mai dau o dată ocazia să alegi altfel. | Dawn gives you one more chance to choose again. |
| `kenaz_ansuz` | Văpaia | Blaze |
| `kenaz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `kenaz_ansuz · vers` | Focul pus în cuvânt îl face să răsune mai tare. | Fire put into a word makes it ring louder. |
| `uruz_ansuz` | Strigătul | The Shout |
| `uruz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `uruz_ansuz · vers` | Strigi cu forța taurului și cuvântul crește. | Shout with the aurochs' strength and the word grows. |
| `isaz_ansuz` | Lecția | The Lesson |
| `isaz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `isaz_ansuz · vers` | Ce îngheți în cuvânt rămâne învățat. | What you freeze into a word stays learned. |
| `hagalaz_ansuz` | Bâlbâiala | The Stutter |
| `hagalaz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `hagalaz_ansuz · vers` | Grindina bate de multe ori, dar cuvântul se bâlbâie. | Hail strikes many times, but the word stammers. |
| `laguz_ansuz` | Revărsarea | Overflow |
| `laguz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `laguz_ansuz · vers` | Apa urcă și cuvântul se revarsă peste el însuși. | The water rises and the word spills over itself. |
| `sowilo_ansuz` | Lumina plină | Full Light |
| `sowilo_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `sowilo_ansuz · vers` | Lumina plină vine doar când mâna e plină. | Full light comes only with a full hand. |
| `thurisaz_ansuz` | Rana | The Wound |
| `thurisaz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `thurisaz_ansuz · vers` | Spinul face cuvântul puternic, dar lasă o rană în săculeț. | The thorn makes the word strong, but leaves a wound in the Bag. |
| `dagaz_ansuz` | Zorii | Dawn |
| `dagaz_ansuz · efect` | Elementul crește cu {count} nivel tot Drumul (cel mult +3 așa). | The Element gains {count} level for the whole Journey (at most +3 this way). |
| `dagaz_ansuz · vers` | Primul cuvânt al zilei sună cel mai frumos. | The first word of the day sounds the sweetest. |
| `kenaz_ingwaz` | Jarul de mâine | Tomorrow's Embers |
| `kenaz_ingwaz · efect` | Și Rostirea următoare are ×{factor} Rezonanță. | And the next Cast has ×{factor} Resonance. |
| `kenaz_ingwaz · vers` | Jarul de azi aprinde vorba de mâine. | Today's embers light tomorrow's word. |
| `uruz_ingwaz` | Avântul | Momentum |
| `uruz_ingwaz · efect` | Și Rostirea următoare are +{amount} Putere. | And the next Cast has +{amount} Power. |
| `uruz_ingwaz · vers` | Taurul își ia avânt acum și lovește data viitoare. | The aurochs gathers speed now and strikes next time. |
| `isaz_ingwaz` | Merindea | Provisions |
| `isaz_ingwaz · efect` | Și {percent}% din dauna peste viața monstrului trece în lupta următoare. | And {percent}% of the damage past the monster's life carries to the next fight. |
| `isaz_ingwaz · vers` | Ce prisosește azi se păstrează la rece pentru mâine. | What is left over today is kept cold for tomorrow. |
| `hagalaz_ingwaz` | Avansul | Head Start |
| `hagalaz_ingwaz · efect` | Și monstrul următor începe cu −{percent}% viață, dar tu cu −1 Schimbare. | And the next monster starts with −{percent}% life, but you with −1 Swap. |
| `hagalaz_ingwaz · vers` | Grindina pleacă înainte și îți face drum, dar îți ia o mână. | Hail runs ahead and clears your way, but takes a hand. |
| `laguz_ingwaz` | Mareea | The Tide |
| `laguz_ingwaz · efect` | Și la începutul luptei următoare tragi {count} pietre în plus și păstrezi 8. | And at the start of the next fight you draw {count} extra stones and keep 8. |
| `laguz_ingwaz · vers` | Mareea de mâine aduce mai multe pietre la mal. | Tomorrow's tide brings more stones to the shore. |
| `sowilo_ingwaz` | Clarviziunea | Clairvoyance |
| `sowilo_ingwaz · efect` | Și în lupta următoare vezi mereu următoarele {count} pietre din săculeț. | And in the next fight you always see the next {count} stones of the Bag. |
| `sowilo_ingwaz · vers` | Mâine soarele îți arată ce vine. | Tomorrow the sun shows you what comes. |
| `thurisaz_ingwaz` | Datoria | The Debt |
| `thurisaz_ingwaz · efect` | Și Rostirea următoare are ×{factor} Rezonanță, cea de după ×0,5. | And the next Cast has ×{factor} Resonance, the one after ×0.5. |
| `thurisaz_ingwaz · vers` | Spinul îți dă azi pe datorie. Mâine plătești. | The thorn lends to you today. Tomorrow you pay. |
| `dagaz_ingwaz` | Ziua de mâine | Tomorrow |
| `dagaz_ingwaz · efect` | Și lupta următoare are +{count} Rostire. | And the next fight has +{count} Cast. |
| `dagaz_ingwaz · vers` | Ziua de mâine va fi mai lungă. | Tomorrow will be a longer day. |
| `kenaz_wunjo` | Scânteia | Spark |
| `kenaz_wunjo · efect` | Talismanul din stânga lucrează încă o dată la Rostirea asta. | The leftmost Talisman acts once more on this Cast. |
| `kenaz_wunjo · vers` | O scânteie și primul talisman se aprinde de două ori. | One spark and the first talisman lights up twice. |
| `uruz_wunjo` | Fanfara | Fanfare |
| `uruz_wunjo · efect` | +{amount} Putere pentru fiecare Talisman. | +{amount} Power for every Talisman. |
| `uruz_wunjo · vers` | Fiecare talisman bate tobele pentru tine. | Every talisman beats the drum for you. |
| `isaz_wunjo` | Conserva | Preserves |
| `isaz_wunjo · efect` | Talismanele care se consumă nu scad în lupta asta. | Talismans that wear down do not wear down this fight. |
| `isaz_wunjo · vers` | Gheața păstrează talismanele care altfel s-ar topi. | Ice keeps the talismans that would otherwise melt away. |
| `hagalaz_wunjo` | Lichidarea | Clearance |
| `hagalaz_wunjo · efect` | Vinzi un Talisman ales pe prețul întreg. | Sell a chosen Talisman for its full price. |
| `hagalaz_wunjo · vers` | Grindina face lichidare: vinzi fără să pierzi. | Hail holds a clearance sale: you sell without losing. |
| `laguz_wunjo` | Metamorfoza | Metamorphosis |
| `laguz_wunjo · efect` | Un Talisman ales devine altul, aleatoriu, de aceeași raritate. | A chosen Talisman becomes another one, at random, of the same rarity. |
| `laguz_wunjo · vers` | Apa schimbă forma unui talisman, dar nu și prețul lui. | Water changes a talisman's shape, but not its worth. |
| `sowilo_wunjo` | Vitrina | The Shop Window |
| `sowilo_wunjo · efect` | La următoarea Piață apare sigur un Talisman Rar. | At the next Market a Rare Talisman is sure to appear. |
| `sowilo_wunjo · vers` | Soarele luminează vitrina de la Piață. | The sun lights up the Market's window. |
| `thurisaz_wunjo` | Sacrificiul | The Sacrifice |
| `thurisaz_wunjo · efect` | Distrugi un Talisman ales → ×{factor} Rezonanță tot restul Ținutului. | Destroy a chosen Talisman → ×{factor} Resonance for the rest of the Realm. |
| `thurisaz_wunjo · vers` | Spinul cere un talisman și îți dă o Probă de putere. | The thorn asks for a talisman and gives you a Trial of strength. |
| `dagaz_wunjo` | Ziua de târg | Market Day |
| `dagaz_wunjo · efect` | +{count} Talisman pe taraba Pieței următoare. | +{count} Talisman on the next Market stall. |
| `dagaz_wunjo · vers` | Mâine e zi de târg și taraba e mai lungă. | Tomorrow is market day and the stall is longer. |
| `kenaz_algiz` | Fumul | Smoke |
| `kenaz_algiz · efect` | Trăsătura și regula monstrului nu se aplică acestei Rostiri. | The monster's trait and rule do not apply to this Cast. |
| `kenaz_algiz · vers` | Prin fum, Examinatorul nu vede o singură vorbă. | Through the smoke, the Examiner misses one word. |
| `uruz_algiz` | Revolta | Revolt |
| `uruz_algiz · efect` | Trăsătura și regula sunt oprite tot restul luptei, dar monstrul își reface {cost}% din viață. | The trait and rule are stopped for the rest of the fight, but the monster heals {cost}% of its life. |
| `uruz_algiz · vers` | Taurul rupe regula, dar Examinatorul se supără. | The aurochs breaks the rule, but the Examiner gets angry. |
| `isaz_algiz` | Înghețul | The Freeze |
| `isaz_algiz · efect` | Trăsătura și regula sunt oprite tot restul luptei. | The trait and rule are stopped for the rest of the fight. |
| `isaz_algiz · vers` | Gheața îngheață regula până la sfârșitul rundei. | Ice freezes the rule until the end of the round. |
| `hagalaz_algiz` | Asurzirea | Deafening |
| `hagalaz_algiz · efect` | Trăsătura și regula sunt oprite pentru următoarele {count} Rostiri. | The trait and rule are stopped for the next {count} Casts. |
| `hagalaz_algiz · vers` | Grindina bate atât de tare că Examinatorul nu aude câteva vorbe. | Hail beats so hard the Examiner can't hear a few words. |
| `laguz_algiz` | Schimbul | The Trade |
| `laguz_algiz · efect` | Schimbi regula cu una din {count} reguli ale altor Stăpâni, la alegere. | Swap the rule for one of {count} other Lords' rules, your choice. |
| `laguz_algiz · vers` | Apa aduce regulile altora. Alegi una. | Water brings other people's rules. You pick one. |
| `sowilo_algiz` | Iscoada | The Scout |
| `sowilo_algiz · efect` | Regula nu se aplică acestei Rostiri și vezi Stăpânii următoarelor {count} Ținuturi. | The rule does not apply to this Cast and you see the Lords of the next {count} Realms. |
| `sowilo_algiz · vers` | Soarele îți arată cine stă la catedră în zilele care vin. | The sun shows you who sits at the desk in the days to come. |
| `thurisaz_algiz` | Înțepătura | The Sting |
| `thurisaz_algiz · efect` | Regula rămâne, dar monstrul pierde {percent}% din viață. | The rule stays, but the monster loses {percent}% of its life. |
| `thurisaz_algiz · vers` | Spinul înțeapă Examinatorul. Cere mai puțin, dar tot cere. | The thorn pricks the Examiner. They ask less, but they still ask. |
| `dagaz_algiz` | Amânarea | Extension |
| `dagaz_algiz · efect` | +{count} Rostire în lupta asta. | +{count} Cast in this fight. |
| `dagaz_algiz · vers` | Zorii amână sentința: mai ai o vorbă. | Dawn delays the verdict: you have one more word. |

### Cele 8 Acțiuni

| Acțiune | Română | English |
|---|---|---|
| `raidho` | Ce depășește viața monstrului trece la monstrul următor. | Whatever goes past the monster's life carries on to the next monster. |
| `ehwaz` | Vraja lovește de 2 ori. | The spell strikes twice. |
| `eihwaz` | Vraja lovește din nou la începutul următoarelor 2 Rostiri, cu jumătate din daună. | The spell strikes again at the start of the next 2 Casts, for half the damage. |
| `berkanan` | +50% pentru fiecare dată când ai mai rostit aceeași vrajă în Drumul ăsta. | +50% for every time you have already cast this spell on this Journey. |
| `jera` | Dauna vine după următoarea Rostire, dar dublă. | The damage comes after the next Cast, but doubled. |
| `perthro` | 50%: ×3; 50%: nimic. | 50%: ×3; 50%: nothing. |
| `naudiz` | Alegi pe loc: pierzi 1 Schimbare sau 3 Monede; vraja face ×2,5. | Choose on the spot: lose 1 Swap or 3 Coins; the spell does ×2.5. |
| `gebo` | Vraja nu se aplică acum: devine Pergament și o folosești când vrei. | The spell does not happen now: it becomes a Scroll you use whenever you like. |

## Lumea și Călătoria (`data/elements.json`, `targets.json`, `realms.json`, `monsters.json`,
`talismans.json`, `lessons.json`, `engravings.json`, `dialogs.json`, `parents.json`)

### Elementele și Țintele

| Rună | Română | English |
|---|---|---|
| `kenaz · natura` | Arsură: monstrul pierde {value} la fiecare Rostire următoare pentru fiecare strat (cel mult {stacks} straturi). | Burn: the monster loses {value} on every later Cast for each stack (at most {stacks} stacks). |
| `uruz · natura` | Zdrobire: ignoră Scutul monstrului. | Crush: ignores the monster's Shield. |
| `thurisaz · natura` | Spini: +{value} Rezonanță pentru fiecare Acțiune din vrajă. | Thorns: +{value} Resonance for every Action in the spell. |
| `isaz · natura` | Îngheț: monstrul nu-și folosește trăsătura și regula la următoarea Rostire ({value}). | Freeze: the monster's trait and rule rest for the next Cast ({value}). |
| `hagalaz · natura` | Ploaie: lovește de {value} ori. | Rain: strikes {value} times. |
| `sowilo · natura` | Lumină: ×{value} contra creaturilor nopții. | Light: ×{value} against creatures of the night. |
| `laguz · natura` | Val: ignoră rezistențele (nu și imunitățile). | Wave: ignores resistances (not immunities). |
| `dagaz · natura` | Timp: +{value}% daună pentru fiecare Rostire rămasă. | Time: +{value}% damage for every Cast left. |
| `tiwaz · Ținta` | 100% din daună; natura Elementului e dublă. | 100% of the damage; the Element's nature is doubled. |
| `fehu · Ținta` | 50% din daună, plus Monede. | 50% of the damage, plus Coins. |
| `othala · Ținta` | 50% din daună, plus pietre mai bune în săculeț. | 50% of the damage, plus better stones in the Bag. |
| `mannaz · Ținta` | 50% din daună, plus ajutor pentru tine și mâna ta. | 50% of the damage, plus help for you and your hand. |
| `ansuz · Ținta` | 50% din daună; Elementul crește cu 1 nivel tot Drumul. | 50% of the damage; the Element gains 1 level for the whole Journey. |
| `ingwaz · Ținta` | Nimic acum; 200% din daună la Rostirea următoare. | Nothing now; 200% of the damage on the next Cast. |
| `wunjo · Ținta` | 50% din daună, plus ajutor pentru Talismane. | 50% of the damage, plus help for the Talismans. |
| `algiz · Ținta` | 50% din daună; oprește trăsătura sau regula monstrului. | 50% of the damage; stops the monster's trait or rule. |

### Tărâmurile și monștrii

| Cine | Română | English |
|---|---|---|
| `realm_1` | Marginea Orașului | The Edge of the City |
| `realm_2` | Codrul | The Deep Forest |
| `realm_3` | Mlaștina | The Marsh |
| `realm_4` | Satul blestemat | The Cursed Village |
| `realm_5` | Munții | The Mountains |
| `realm_6` | Cetatea în ruină | The Ruined Citadel |
| `realm_7` | Peștera Zmeului | The Zmeu's Cave |
| `realm_8` | Poarta | The Gate |
| `dummy · name` | Manechinul de antrenament | The Training Dummy |
| `dummy · description` | Paie, sfoară și o găleată pe post de cap. A supraviețuit la patruzeci de generații de elevi. | Straw, string and a bucket for a head. It has survived forty generations of students. |
| `bronze_dog · name` | Câinele de bronz | The Bronze Dog |
| `bronze_dog · description` | Statuia de la poarta școlii. Ilinca o trezește la examene. Nu mușcă. De obicei. | The statue at the school gate. Ilinca wakes it for exams. It doesn't bite. Usually. |
| `kaldor · name` | Kaldor | Kaldor |
| `kaldor · description` | Zeul războiului, antrenor de box. Ține examenul de Moștenire de trei sute de ani și încă se încălzește înainte. | God of war, boxing coach. He has held the Inheritance Exam for three hundred years and still warms up first. |
| `spiridus · name` | Spiriduș | Spiriduș (Sprite) |
| `spiridus · description` | Duh mic de casă, poznaș și hoț. Îți ia o Monedă și apoi o caută cu tine. | A small house spirit, a trickster and a thief. Takes a Coin, then helps you look for it. |
| `moroi · name` | Moroi | Moroi |
| `moroi · description` | Duhul unui mort care nu-și găsește liniștea. Bântuie noaptea și ia ce nu e al lui. | The spirit of a dead one who finds no rest. Haunts the night and takes what isn't his. |
| `pricolici · name` | Pricolici | Pricolici |
| `pricolici · description` | Om care se face lup sau câine mare și umblă noaptea. Nu-i spune „cuțu”. | A man who turns into a wolf or a great dog and roams at night. Don't call him "doggy". |
| `fata_padurii · name` | Fata Pădurii | Fata Pădurii (Forest Maiden) |
| `fata_padurii · description` | Duhul pădurii care îi rătăcește pe drumeți. Cărările se mută când nu te uiți. | The forest spirit who leads travellers astray. The paths move when you're not looking. |
| `varcolac · name` | Vârcolac | Vârcolac |
| `varcolac · description` | Fiara care mușcă din lună și din soare: de aici eclipsele. Acum a coborât să muște din tine. | The beast that bites the moon and the sun: hence eclipses. Now it has come down to bite you. |
| `iele · name` | Ielele | The Iele |
| `iele · description` | Zâne ale nopții care dansează în poieni. Cine le vede dansul nu mai merge drept. | Night fairies who dance in the glades. Whoever sees their dance never walks straight again. |
| `strigoi · name` | Strigoi | Strigoi |
| `strigoi · description` | Mort care se ridică din mormânt. Usturoiul ajută. Runele ajută mai mult. | A dead one risen from the grave. Garlic helps. Runes help more. |
| `joimarita · name` | Joimărița | Joimărița |
| `joimarita · description` | Vine în Joia Mare la fetele care n-au tors tot cânepa. Tu ai tors? Nici noi. | Comes on Holy Thursday to girls who haven't spun all their hemp. Have you? Neither have we. |
| `martolea · name` | Marțolea | Marțolea |
| `martolea · description` | Duhul care îi pedepsește pe cei ce lucrează marți seara. E marți. E seară. | The spirit that punishes those who work on Tuesday evening. It's Tuesday. It's evening. |
| `zburatorul · name` | Zburătorul | Zburătorul (the Flyer) |
| `zburatorul · description` | Duh care zboară noaptea ca o flacără și tulbură somnul. Poeții l-au iubit. Tu nu trebuie. | A spirit that flies at night like a flame and troubles sleep. Poets loved him. You don't have to. |
| `hala · name` | Hala | Hala (Hail Spirit) |
| `hala · description` | Duhul grindinei, mânat de solomonari peste sate. Bate tare și nu cere voie. | The spirit of hail, driven over villages by the solomonars. Hits hard and never asks. |
| `valva_bailor · name` | Vâlva Băilor | Vâlva Băilor (Mine Keeper) |
| `valva_bailor · description` | Păzitoarea minelor din munți. Le dă aur celor cinstiți și pietre celorlalți. | Keeper of the mountain mines. Gives gold to the honest and rocks to everyone else. |
| `capcaun · name` | Căpcăun | Căpcăun (Ogre) |
| `capcaun · description` | Uriaș care mănâncă oameni. Mare, flămând și foarte răbdător la masă. | A giant who eats people. Big, hungry and very patient at the table. |
| `urias · name` | Uriașul | The Giant |
| `urias · description` | Din basme: aruncă stânci ca pe pietricele și se supără ușor. | From the tales: throws boulders like pebbles and takes offence easily. |
| `gheonoaia · name` | Gheonoaia | Gheonoaia |
| `gheonoaia · description` | Monstrul-pasăre din „Tinerețe fără bătrânețe”. Ciocănește pădurea întreagă. | The bird-monster from "Youth Without Age". Pecks the whole forest down. |
| `pui_de_balaur · name` | Pui de balaur | Young Balaur |
| `pui_de_balaur · description` | Un balaur tânăr, cu un singur cap deocamdată. Celelalte cresc. | A young balaur, with only one head so far. The others are growing. |
| `statu_palma · name` | Statu-Palmă-Barbă-Cot | Statu-Palmă-Barbă-Cot |
| `statu_palma · description` | Piticul cât o palmă, cu barba cât un cot. Mai puternic decât pare și foarte mândru de barbă. | The dwarf a palm tall with a beard an elbow long. Stronger than he looks, very proud of the beard. |
| `statu_palma · rule_text` | Mic, dar încăpățânat: o vrajă îi ia cel mult {value}% din viață. | Small but stubborn: one spell takes at most {value}% of his life. |
| `muma_padurii · name` | Muma Pădurii | Muma Pădurii (Forest Mother) |
| `muma_padurii · description` | Stăpâna codrului, bătrână și urâtă ca un trunchi scorburos. Nu-i place să fie deranjată. | Mistress of the deep forest, old and gnarled like a hollow trunk. Hates being disturbed. |
| `muma_padurii · rule_text` | Focul e interzis în pădurea ei: vrăjile de Foc nu se leagă. | Fire is forbidden in her forest: Fire spells do not form. |
| `stima_apelor · name` | Știma Apelor | Știma Apelor (Water Spirit) |
| `stima_apelor · description` | Duhul care păzește apele adânci. Îi cere fiecărui râu tribut. Și ție. | The spirit guarding deep waters. Demands tribute from every river. And from you. |
| `stima_apelor · rule_text` | După fiecare Rostire, mâna se întoarce în săculeț și tragi alta. | After every Cast your hand goes back into the Bag and you draw a new one. |
| `baba_cloanta · name` | Baba Cloanța | Baba Cloanța |
| `baba_cloanta · description` | Vrăjitoarea din basme, cu dinți de fier. Râde de vrăjile scurte. | The witch from the tales, with iron teeth. Laughs at short spells. |
| `baba_cloanta · rule_text` | Vrăjile simple (Element → Țintă, fără Acțiune) nu fac daună. | Simple spells (Element → Target, no Action) do no damage. |
| `solomonarul · name` | Solomonarul | The Solomonar |
| `solomonarul · description` | Stăpânul furtunilor, călare pe un balaur. A învățat la școala de sub pământ. Nu i-a plăcut. | Master of storms, riding a balaur. Studied at the school under the earth. Didn't enjoy it. |
| `solomonarul · rule_text` | La fiecare Rostire, o piatră din mână devine Hagalaz. | On every Cast, a stone in your hand turns into Hagalaz. |
| `scorpia · name` | Scorpia | Scorpia |
| `scorpia · description` | Sora zmeilor din „Tinerețe fără bătrânețe”, cu multe capete și mult venin. Păzește cetatea. | Sister of the zmei from "Youth Without Age", many-headed and full of venom. Guards the citadel. |
| `scorpia · rule_text` | Primele {value} pietre din fiecare tragere vin cu fața în jos. | The first {value} stones of every draw come face down. |
| `zmeul · name` | Zmeul | The Zmeu |
| `zmeul · description` | Fura fete împărătești și aruncă buzduganul de la o zi distanță. Acum te așteaptă pe tine. | Stole emperors' daughters and threw his mace a day's walk ahead. Now he's waiting for you. |
| `zmeul · rule_text` | Fiecare Rostire trebuie să aibă o vrajă cu Acțiune. | Every Cast must hold a spell with an Action. |
| `balaur · name` | Balaurul cu trei capete | The Three-Headed Balaur |
| `balaur · description` | Balaurul de la Poartă. Trei capete, trei păreri, nicio milă. | The Balaur at the Gate. Three heads, three opinions, no mercy. |
| `balaur · rule_text` | Trei capete, unul după altul; fiecare cap are alte slăbiciuni. | Three heads, one after another; each head has other weaknesses. |

### Talismanele

| Talisman | Română | English |
|---|---|---|
| `ilinca_chalk` | Creta Maestrei Ilinca | Master Ilinca's Chalk |
| `ilinca_chalk · efect` | +{value} Rezonanță la fiecare vrajă. | +{value} Resonance on every spell. |
| `gronn_helmet` | Casca de șantier a lui Gronn | Gronn's Hard Hat |
| `gronn_helmet · efect` | +{value} Putere la fiecare vrajă. | +{value} Power on every spell. |
| `varr_umbrella` | Umbrela lui Varr | Varr's Umbrella |
| `varr_umbrella · efect` | Grindina lovește de {value} ori în plus. | Hail strikes {value} more time. |
| `selvia_shell` | Scoica Selviei | Selvia's Shell |
| `selvia_shell · efect` | +{value} Schimbare în fiecare luptă. | +{value} Swap in every fight. |
| `lunet_coffee` | Cafeaua de noapte a lui Lunet | Lunet's Night Coffee |
| `lunet_coffee · efect` | +{value} piatră în mână. | +{value} stone in hand. |
| `ignar_shawarma` | Shaorma lui Ignar | Ignar's Shawarma |
| `ignar_shawarma · efect` | +{value} Rezonanță la fiecare vrajă; scade cu 1 după fiecare Rostire (acum {now}). | +{value} Resonance on every spell; drops by 1 after every Cast (now {now}). |
| `trolley_ticket` | Biletul pe troleibuzul 22 | Ticket for Trolleybus 22 |
| `trolley_ticket · efect` | +{value} Monedă la fiecare Rostire cu 2 vrăji. | +{value} Coin on every Cast with 2 spells. |
| `market_granny` | Bunica din piață | The Market Granny |
| `market_granny · efect` | Totul în Piață costă cu {value} Monedă mai puțin. | Everything at the Market costs {value} Coin less. |
| `kaldor_gloves` | Mănușile lui Kaldor | Kaldor's Gloves |
| `kaldor_gloves · efect` | ×{value} Rezonanță dacă rostești 5 pietre. | ×{value} Resonance if you cast 5 stones. |
| `ignar_lighter` | Bricheta lui Ignar | Ignar's Lighter |
| `ignar_lighter · efect` | Arsura poate avea {value} straturi în plus. | Burn can have {value} more stacks. |
| `morrah_bookmark` | Semnul de carte al Morrei | Morrah's Bookmark |
| `morrah_bookmark · efect` | +{value} Rezonanță pentru fiecare vrajă diferită rostită în Drum (acum +{now}). | +{value} Resonance for every different spell cast this Journey (now +{now}). |
| `toma` | Toma, fiul lui Gronn | Toma, Gronn's Son |
| `toma · efect` | +1 Putere la fiecare vrajă pentru fiecare 2 pietre din săculeț. | +1 Power on every spell for every 2 stones in the Bag. |
| `nix` | Nix, copilul lui Lunet | Nix, Lunet's Child |
| `nix · efect` | Copiază efectul Talismanului din dreapta lui. | Copies the effect of the Talisman to its right. |
| `dara` | Dara, fiica lui Kaldor | Dara, Kaldor's Daughter |
| `dara · efect` | ×{value} Rezonanță; crește cu +{step} după fiecare Examinator învins. | ×{value} Resonance; grows by +{step} after every Examiner beaten. |
| `aeva_hourglass` | Clepsidra Aevei | Aeva's Hourglass |
| `aeva_hourglass · efect` | O dată pe examen: dacă pici o rundă, o iei de la capăt. Apoi Clepsidra se sparge. | Once per exam: if you fail a round, you play it again. Then the Hourglass breaks. |

### Lecțiile și Gravurile

| Consumabil | Română | English |
|---|---|---|
| `lesson_kenaz` | Lecția despre Foc | The Lesson on Fire |
| `lesson_kenaz · text` | Ignar a ținut-o cu șorțul de la shaormerie. A mirosit a ceapă tot semestrul. | Ignar taught it in his shawarma apron. It smelled of onions all term. |
| `lesson_uruz` | Lecția despre Forță | The Lesson on Strength |
| `lesson_uruz · text` | Gronn a explicat-o mutând catedra. De două ori. | Gronn explained it by moving the teacher's desk. Twice. |
| `lesson_thurisaz` | Lecția despre Spini | The Lesson on Thorns |
| `lesson_thurisaz · text` | Pagina are urme de degete înțepate. Multe. | The page has marks of pricked fingers. Lots of them. |
| `lesson_isaz` | Lecția despre Gheață | The Lesson on Ice |
| `lesson_isaz · text` | Se predă iarna, cu fereastra deschisă. Pentru atmosferă. | Taught in winter, with the window open. For atmosphere. |
| `lesson_hagalaz` | Lecția despre Grindină | The Lesson on Hail |
| `lesson_hagalaz · text` | Varr a scris-o cu greșeli. Grindina a ieșit oricum. | Varr wrote it with mistakes. The hail came out anyway. |
| `lesson_sowilo` | Lecția despre Soare | The Lesson on the Sun |
| `lesson_sowilo · text` | Strigoii nu vin la ora asta. Din motive evidente. | Strigoi never attend this class. For obvious reasons. |
| `lesson_laguz` | Lecția despre Apă | The Lesson on Water |
| `lesson_laguz · text` | Selvia a predat-o la ștrand. Toată lumea a trecut. | Selvia taught it at the pool. Everyone passed. |
| `lesson_dagaz` | Lecția despre Zi | The Lesson on Day |
| `lesson_dagaz · text` | Aeva o ține în fiecare dimineață. De o mie de ori. | Aeva gives it every morning. A thousand times over. |
| `bone` | Gravura de Os | Bone Engraving |
| `bone · text` | O piatră din mână devine de os: +{value} Putere vrăjii în care intră. | A stone in your hand becomes bone: +{value} Power to the spell it is part of. |
| `amber` | Gravura de Chihlimbar | Amber Engraving |
| `amber · text` | O piatră din mână devine de chihlimbar: +{value} Rezonanță vrăjii în care intră. | A stone in your hand becomes amber: +{value} Resonance to the spell it is part of. |
| `gold` | Gravura de Aur | Gold Engraving |
| `gold · text` | O piatră din mână devine de aur: +{value} Monede dacă rămâne în mână la finalul luptei. | A stone in your hand becomes gold: +{value} Coins if it stays in hand at the end of the fight. |
| `iron` | Gravura de Fier | Iron Engraving |
| `iron · text` | O piatră din mână devine de fier: +{value} Rezonanță tuturor vrăjilor cât timp rămâne în mână. | A stone in your hand becomes iron: +{value} Resonance to every spell while it stays in hand. |
| `glass` | Gravura de Sticlă | Glass Engraving |
| `glass · text` | O piatră din mână devine de sticlă: ×{value} Rezonanță vrăjii în care intră, dar se poate sparge (1 din 4). | A stone in your hand becomes glass: ×{value} Resonance to the spell it is part of, but it may break (1 in 4). |
| `binding` | Legătura | The Binding |
| `binding · text` | Leagă 2 pietre din mână într-o singură piatră: în propoziție contează ca cele două, una după alta. | Binds 2 stones in your hand into one stone: in a sentence it counts as the two, one right after the other. |
| `reshaping` | Prefacerea | The Reshaping |
| `reshaping · text` | Schimbă runa unei pietre din mână într-o altă rună cu același rol. | Changes the rune of a stone in your hand into another rune with the same role. |
| `double` | Dublura | The Double |
| `double · text` | Adaugă în săculeț o copie a unei pietre din mână. | Adds a copy of a stone in your hand to the bag. |
| `shatter` | Sfărâmarea | The Shattering |
| `shatter · text` | Scoate definitiv din săculeț până la {count} pietre din mână. | Removes up to {count} stones in your hand from the bag for good. |
| `relocation` | Strămutarea | The Relocation |
| `relocation · text` | Mută până la {count} pietre din mână în alt Neam (runa rămâne). | Moves up to {count} stones in your hand to another Kin (the rune stays). |

### Replicile (Tanti Vera, Aeva în Dimineață)

| Replică | Română | English |
|---|---|---|
| `vera_market 1` | Bună seara, puiule. Ce-ți trebuie azi? | Good evening, dear. What do you need tonight? |
| `vera_market 2` | Runele astea le vând de patruzeci de ani. Nu s-au plâns niciodată. | I've sold these runes for forty years. They never complained. |
| `vera_market 3` | Ia și tu ceva, că mă uit la tine de un sfert de oră. | Buy something, I've been watching you for a quarter of an hour. |
| `vera_market 4` | Kaldor a cumpărat de aici mănușile. Și le-a pierdut de trei ori. | Kaldor bought his gloves here. Lost them three times. |
| `vera_market 5` | Shaorma e de la Ignar, nu de la mine. Eu doar o vând. | The shawarma is Ignar's, not mine. I just sell it. |
| `vera_market 6` | Prețurile nu se negociază. Bine, puțin. Nu. | Prices aren't negotiable. Well, a little. No. |
| `vera_market 7` | Ai față de om care trece examenul. Sau de om care n-a dormit. | You look like someone who'll pass. Or someone who hasn't slept. |
| `aeva_morning_first 1` | Bună dimineața, {name}. Eu sunt Aeva, directoarea examenului. Azi afli ce ai moștenit. | Good morning, {name}. I'm Aeva, head of the exam. Today you find out what you inherited. |
| `aeva_morning 1` | Iar tu? A {n}-a oară în dimineața asta. | You again? That makes {n} of this same morning. |
| `aeva_morning 2` | Bună dimineața, {name}. Pentru tine e a {n}-a. Pentru ceilalți e prima. | Good morning, {name}. For you it's morning number {n}. For everyone else it's the first. |
| `aeva_morning 3` | Cafeaua e aceeași. Examinatorii sunt aceiași. Tu ești puțin mai deștept. | The coffee is the same. The examiners are the same. You are a little smarter. |
| `aeva_morning 4` | Am mai văzut dimineața asta de o mie de ori. Pe tine doar de {n}. | I've seen this morning a thousand times. You only {n} times. |
| `aeva_morning 5` | Nu te grăbi. Timpul e treaba mea. | Don't rush. Time is my business. |
| `aeva_morning 6` | Kaldor încă nu știe că l-ai mai bătut. Nu-i spune. | Kaldor doesn't know you've beaten him before. Don't tell him. |
| `aeva_morning_passed 1` | Ai trecut. Și totuși ești iar aici. Unii nu se pot opri. | You passed. And yet here you are again. Some people can't stop. |
| `aeva_morning_passed 2` | Pecetea e a ta, {name}. Dar dimineața asta încă are ceva de spus. | The Seal is yours, {name}. But this morning still has something to say. |
| `aeva_morning_after_loss 1` | Ai picat la Proba {trial}. Data trecută. Adică azi. E complicat. | You failed at Trial {trial}. Last time. Which is today. It's complicated. |
| `aeva_morning_after_loss 2` | Ții minte tot? Bine. Ceilalți nu țin minte nimic. | You remember everything? Good. The others remember nothing. |
| `aeva_morning_after_loss 3` | Încă o dimineață. Încă o șansă. Încă o cafea. | Another morning. Another chance. Another coffee. |

### Părinții (`data/parents.json`)

| Părinte | Română | English |
|---|---|---|
| `varr · bonus` | +1 Rostire în fiecare rundă. | +1 Cast every round. |
| `varr · replică` | Fulgerul nu întârzie niciodată. Eu da. Tu nu. Hai. | Lightning is never late. I am. You won't be. Go. |
| `selvia · bonus` | +1 Schimbare în fiecare rundă. | +1 Swap every round. |
| `selvia · replică` | Dacă un val nu-ți place, mai vine unul. Așa și cu pietrele. | If you don't like a wave, another one comes. Same with stones. |
| `ignar · bonus` | Începi examenul cu 2 Gravuri aleatorii. | You start the exam with 2 random Engravings. |
| `ignar · replică` | Ți-am gravat două pietre. Și ți-am pus o shaorma în ghiozdan. | I engraved two stones for you. And put a shawarma in your bag. |
| `gronn · bonus` | +1 loc de Talisman, dar −1 piatră în mână. | +1 Talisman slot, but −1 stone in hand. |
| `gronn · replică` | Mai puțin în mâini. Mai mult pe umeri. Construiește. | Less in your hands. More on your shoulders. Build. |
| `morrah · bonus` | Săculeț de doar 24 de pietre, câte una din fiecare rună. Mai greu, dar fiecare piatră contează. | A Bag of only 24 stones, one of each rune. Harder, but every stone matters. |
| `morrah · replică` | Fiecare piatră își amintește de tine. Ai grijă de ele. | Every stone remembers you. Take care of them. |

## Indiciile (`data/hints.json`)

| Indiciu | Română | English |
|---|---|---|
| `first_laguz (oprit)` | Laguz e apă: curge. Contează ca piatră din orice Neam. | Laguz is water: it flows. It counts as a stone of any Kin. |
| `idle_help` | Nu știi ce să faci? Pune un Element, apoi o Țintă. Cercul îți arată cât lovește. | Not sure what to do? Put an Element, then a Target. The circle shows how hard it hits. |
| `first_wrong_order` | Elementul vine primul, Ținta la urmă. Așa vorbesc runele. | The Element comes first, the Target last. That's how runes speak. |
| `first_scroll` | Ai păstrat vraja pe pergament. Folosește-o când ai nevoie. | You kept the spell on a scroll. Use it when you need it. |
| `first_two_actions` | Două Acțiuni. Te dai mare. Îmi place. | Two Actions. Showing off. I like it. |
| `first_shop_1` | Bună seara, puiule. Aici cumperi ce te ține în viață la examen. | Good evening, dear. Here you buy what keeps you alive in the exam. |
| `first_shop_2` | Talismanele lucrează singure, de la stânga la dreapta. Ai cinci locuri. | Talismans work on their own, from left to right. You have five slots. |
| `first_shop_3` | Lecțiile cresc un Cuvânt. Gravurile schimbă pietrele. Săculețele… surpriză. | Lessons raise a Word. Engravings change stones. Bags… a surprise. |
| `first_reroll` | Nu-ți place marfa? Rearanjez taraba, dar nu gratis. | Don't like the goods? I'll rearrange the stall, but not for free. |
| `first_talisman` | Trage Talismanele ca să le schimbi ordinea. Ordinea contează. | Drag the Talismans to change their order. Order matters. |
| `first_examiner (oprit)` | Eu sunt Kaldor. Regula mea e scrisă acolo. N-o repet. | I am Kaldor. My rule is written there. I won't say it twice. |
| `first_rule` | Al treilea vine Stăpânul Tărâmului. Are o regulă, scrisă pe fișa lui. Citește-o înainte să rostești. | Third comes the Lord of the Realm. It has a rule, written on its card. Read it before you cast. |
| `first_lesson` | O Lecție crește nivelul unui Element pentru toată Călătoria. | A Lesson raises an Element's level for the whole Journey. |
| `first_engraving` | O Gravură schimbă o piatră. În rundă, apasă pe Gravură, apoi alege piatra din mână. | An Engraving changes a stone. In a round, click the Engraving, then pick the stone in your hand. |
| `first_bindrune` | O legătură e o piatră cu două rune. Contează ca oricare dintre ele, iar Glasurile se aud amândouă. | A bind-rune is a stone with two runes. It counts as either of them, and both Voices are heard. |
| `first_loss_1` | Ai picat. Se întâmplă. Ție ți se întâmplă des. | You failed. It happens. It happens to you a lot. |
| `first_loss_2` | Te întorc în dimineața examenului. Tu ții minte tot, ceilalți nu. Nu mă întreba de ce. | I'm sending you back to the morning of the exam. You remember everything, the others don't. Don't ask me why. |
| `first_loss_3` | Ce ai adunat se numește Amintiri. Cheltuiește-le cu cap. | What you gathered is called Memories. Spend them wisely. |
| `first_evening_class` | În ultima bancă stau Kaldor și Varr. Repetă cursul. Nu fi ca ei. | Kaldor and Varr sit in the back row. They're repeating the class. Don't be like them. |
| `first_torn_page` | Am găsit-o într-o carte veche. Spune ce rune trebuie. Restul e treaba ta. | I found it in an old book. It says which runes you need. The rest is up to you. |
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
| `rune_check_hint` | Ține mouse-ul pe o rună ca să vezi sensul ei și ce face într-o vrajă. | Hover a rune to see its meaning and what it does in a spell. |
| `rune_tooltip` | Sens istoric: {meaning} În joc: {does} | Historical meaning: {meaning} In the game: {does} |
| `number_millions` | {n} mil. | {n}M |
| `number_decimal_point` | , | . |
| `number_thousands_separator` |   | , |
| `round_practice` | Luptă de antrenament | Practice fight |
| `round_coins` | Monede | Coins |
| `round_bag` | Săculeț | Bag |
| `round_bag_value` | {left} / {total} | {left} / {total} |
| `round_seed` | Seed: {seed} | Seed: {seed} |
| `round_casts` | Rostiri | Casts |
| `round_swaps` | Schimbări | Swaps |
| `round_cast_button` | Rostește | Cast |
| `round_swap_button` | Schimbă | Swap |
| `round_sort` | Sortează: | Sort: |
| `round_sort_kin` | Neam | Kin |
| `round_speed` | Viteză ×{n} | Speed ×{n} |
| `round_menu` | Meniu | Menu |
| `round_talisman_slot` | Talisman | Talisman |
| `round_consumable_slot` | Lecție / Gravură | Lesson / Engraving |
| `circle_hint` | Alege pietrele: Element → Țintă | Pick stones: Element → Target |
| `circle_awakening` | ceva se trezește în cerc… | something stirs in the circle… |
| `circle_spell` | Vrajă: {name} | Spell: {name} |
| `word_hidden` | ??? | ??? |
| `float_power` | +{n} | +{n} |
| `float_add_res` | +{n} Rez. | +{n} Res. |
| `float_mul_res` | ×{n} Rez. | ×{n} Res. |
| `float_money` | +{n} Monede | +{n} Coins |
| `spell_reveal_title` | Ai descoperit o Vrajă! | You discovered a Spell! |
| `spell_reveal_memories` | +{n} Amintiri | +{n} Memories |
| `spell_reveal_continue` | Apasă oriunde ca să continui | Click anywhere to continue |
| `result_won_title` | Ai învins! | You won! |
| `result_lost_title` | Monstrul a rezistat | The monster held on |
| `result_money` | +{n} Monede la finalul luptei | +{n} Coins at the end of the fight |
| `result_again` | Încă o luptă | Another fight |
| `result_menu` | Meniu | Menu |
| `menu_tutorial` | Antrenament | Practice |
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
| `card_meaning` | Sens istoric: {meaning} | Historical meaning: {meaning} |
| `card_power` | Putere {n} | Power {n} |
| `hint_close` | clic ca să închizi | click to close |
| `pause_rune_book` | Cartea de rune | Book of Runes |
| `rune_book_title` | Cartea de rune | Book of Runes |
| `rune_book_hint` | Cele 24 de rune, cu sensul, rolul lor și ce fac într-o vrajă · Tabla Vrăjilor | The 24 runes with their meaning, their role and what they do in a spell · the Table of Spells |
| `rune_book_spells` | Vrăjile · {n} din {total} descoperite | Spells · {n} of {total} discovered |
| `rune_book_close` | Închide | Close |
| `spell_unknown` | {sentence} · ??? | {sentence} · ??? |
| `spell_dormant` | {sentence} · se trezește mai târziu | {sentence} · wakes up later |
| `spell_incomplete` | {sentence} → … · propoziție neterminată | {sentence} → … · unfinished sentence |
| `spell_wrong_order` | Ordinea e greșită: Elementul vine primul. | Wrong order: the Element comes first. |
| `spell_interrupted` | Propoziția e întreruptă: între Element și Țintă încap cel mult două Acțiuni. | The sentence is broken: at most two Actions fit between the Element and the Target. |
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
| `choice_price` | Naudiz cere un preț pentru ×2,5. Ce dai? | Naudiz asks a price for ×2.5. What do you give? |
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
| `exam_trial` | Tărâmul {n} din {total} · {name} | Realm {n} of {total} · {name} |
| `exam_round_small` | Monstrul mic | The small monster |
| `exam_round_big` | Monstrul mare | The big monster |
| `exam_title_small` | Tărâmul {n} · Monstrul mic | Realm {n} · The small monster |
| `exam_title_big` | Tărâmul {n} · Monstrul mare | Realm {n} · The big monster |
| `exam_rule` | Regula Stăpânului: {text} | The Lord's rule: {text} |
| `exam_no_rule` | Fără regulă. Doar dinți și gheare. | No rule. Just teeth and claws. |
| `exam_money` | Monede: {n} | Coins: {n} |
| `exam_start_round` | Începe | Begin |
| `exam_peek` | Soarele îți arată cine urmează: {list} | The Sun shows you who comes next: {list} |
| `exam_round_won` | Monstrul a căzut! | The monster fell! |
| `exam_defeated` | L-ai învins pe Stăpân: {name} | You beat the Lord: {name} |
| `exam_reward_small` | Monstrul mic: +{n} Monede | The small monster: +{n} Coins |
| `exam_reward_big` | Monstrul mare: +{n} Monede | The big monster: +{n} Coins |
| `exam_reward_casts` | Rostiri rămase: +{n} Monede | Casts left: +{n} Coins |
| `exam_reward_interest` | Dobândă pentru economii: +{n} Monede | Interest on savings: +{n} Coins |
| `exam_reward_total` | Total: +{n} · acum ai {money} Monede | Total: +{n} · you now have {money} Coins |
| `exam_continue` | Mai departe | Onwards |
| `exam_passed_title` | Ai trecut de Balaur! | You got past the Balaur! |
| `exam_failed_title` | Ai căzut | You fell |
| `exam_stats` | Ai ajuns la Tărâmul {trial} din {total} · Stăpâni învinși: {defeated} · lupte câștigate: {rounds} | You reached Realm {trial} of {total} · Lords beaten: {defeated} · fights won: {rounds} |
| `card_face_down` | Piatră cu fața în jos | Face-down stone |
| `card_face_down_text` | Visul lui Lunet: afli ce rună e abia când o rostești. | Lunet's Dream: you find out which rune it is only when you cast it. |
| `circle_face_down` | o piatră doarme cu fața în jos | a stone sleeps face down |
| `round_swaps_endless` | Schimbări: fără sfârșit | Swaps: endless |
| `round_swap_button_cost` | Schimbă · {n} Mon. | Swap · {n} Coin |
| `float_rule_zero` | Regula: nicio daună | The rule: no damage |
| `choice_swap_rule` | Apa schimbă regula. Alege regula altui Stăpân. | Water changes the rule. Pick another Lord's rule. |
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
| `exam_second_chance_text` | Nisipul curge înapoi. Ai încă o încercare cu același monstru. | The sand runs back. You get one more try at the same monster. |
| `exam_retry` | Încă o dată | Once more |
| `consumable_lesson` | Lecție | Lesson |
| `consumable_engraving` | Gravură | Engraving |
| `consumable_use_hint` | Apasă ca s-o folosești. | Click to use it. |
| `consumable_cannot` | Nu se poate folosi acum. | It can't be used now. |
| `lesson_effect` | {element} crește cu 1 nivel pentru toată Călătoria (+50% Putere, +1 Rezonanță). | {element} rises by 1 level for the whole Journey (+50% Power, +1 Resonance). |
| `lesson_learned` | {element} a urcat la nivelul {n}. | {element} rose to level {n}. |
| `choice_engrave_material` | Alege piatra din mână pe care o gravezi. | Pick the stone in your hand to engrave. |
| `choice_bind_chosen` | Alege 2 pietre din mână, cu rune diferite: devin o singură piatră cu ambele rune. | Pick 2 stones in your hand with different runes: they become one stone with both runes. |
| `choice_change_rune_chosen` | Alege piatra din mână, apoi runa în care se preface (din același Neam). | Pick the stone in your hand, then the rune it turns into (same Kin). |
| `card_bound` | Legată cu {rune}: {does} | Bound with {rune}: {does} |
| `material_bone` | Os: +{value} Putere vrăjii în care intră | Bone: +{value} Power to its spell |
| `material_amber` | Chihlimbar: +{value} Rezonanță vrăjii în care intră | Amber: +{value} Resonance to its spell |
| `material_gold` | Aur: +{value} Monede dacă rămâne în mână la final | Gold: +{value} Coins if it stays in hand at the end |
| `material_iron` | Fier: +{value} Rezonanță cât stă în mână | Iron: +{value} Resonance while held |
| `material_glass` | Sticlă: ×{value} Rezonanță, se poate sparge | Glass: ×{value} Resonance, may break |
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
| `morning_title` | Dimineața examenului | The Morning of the Exam |
| `morning_attempt` | Încercarea {n} | Attempt {n} |
| `morning_memories` | Amintiri: {n} | Memories: {n} |
| `morning_continue` | Continuă examenul | Continue the exam |
| `morning_continue_info` | Proba {trial} din {total} · {round} · {money} Monede | Trial {trial} of {total} · {round} · {money} Coins |
| `morning_new_exam` | Începe examenul | Begin the exam |
| `morning_unlocks` | Amintirile | Memories |
| `morning_rune_book` | Cartea de rune | The Book of Runes |
| `morning_collection` | Colecția | The Collection |
| `morning_evening_class` | Antrenament cu Manechinul | Practice with the Dummy |
| `morning_settings` | Setări | Settings |
| `morning_menu` | Meniul principal | Main menu |
| `morning_stats` | Cea mai bună probă: {trial} din {total} · Examene trecute: {passed} · Cea mai mare Rostire: {cast} | Best trial: {trial} of {total} · Exams passed: {passed} · Biggest Cast: {cast} |
| `morning_you` | {name}, 16 ani, semizeu | {name}, 16, demigod |
| `morning_abandon_title` | Ai un examen început | You have an exam in progress |
| `morning_abandon_text` | Dacă începi altul, Aeva îl închide pe acesta. Primești Amintirile pentru ce ai făcut până acum. | If you begin another one, Aeva closes this one. You get the Memories for what you did so far. |
| `morning_abandon_yes` | Începe altul | Begin another |
| `morning_abandon_no` | Înapoi | Back |
| `parents_title` | Alege părintele | Choose your parent |
| `parents_aeva` | Cine te-a adus azi la examen? De la părintele tău moștenești puterea. | Who brought you to the exam today? Your power comes from them. |
| `parents_choose` | Alege | Choose |
| `parents_locked_attempts` | Vine după primul examen. | Comes after your first exam. |
| `parents_locked_memories` | Se deblochează cu {n} Amintiri (în Amintirile). | Unlocks for {n} Memories (in Memories). |
| `parents_back` | Înapoi | Back |
| `unlocks_title` | Amintirile | Memories |
| `unlocks_text` | Aeva îți lasă ce ții minte. Cheltuiește Amintirile pe părinți noi și pe Talismane noi în Piața de noapte. | Aeva lets you keep what you remember. Spend Memories on new parents and new Talismans in the Night Market. |
| `unlocks_parents` | Părinții | Parents |
| `unlocks_talismans` | Talismane pentru Piață | Talismans for the Market |
| `unlocks_buy` | {n} Amintiri | {n} Memories |
| `unlocks_owned` | Deblocat | Unlocked |
| `unlocks_after_exam` | După primul examen | After the first exam |
| `unlocks_none` | Ai deblocat tot. Aeva e impresionată. Nu-i spune nimănui. | You unlocked everything. Aeva is impressed. Don't tell anyone. |
| `close` | Închide | Close |
| `exam_memories_title` | Amintiri: +{n} | Memories: +{n} |
| `exam_memories_rounds` | Lupte câștigate: +{n} | Fights won: +{n} |
| `exam_memories_examiners` | Stăpâni învinși: +{n} | Lords beaten: +{n} |
| `exam_memories_passed` | Examenul trecut: +{n} | Exam passed: +{n} |
| `exam_memories_total` | Acum ai {n} Amintiri. | You now have {n} Memories. |
| `exam_to_morning` | Înapoi în dimineață | Back to the morning |
| `exam_parent` | Copilul lui {name} | {name}'s child |
| `rewind_text` | Aeva întoarce timpul… | Aeva turns back time… |
| `settings_name` | Numele: {name} | Name: {name} |
| `settings_change_name` | Schimbă numele | Change the name |
| `collection_title` | Colecția | The Collection |
| `collection_tab_talismans` | Talismane | Talismans |
| `collection_tab_engravings` | Gravuri | Engravings |
| `collection_count` | Văzute: {n} din {total} | Seen: {n} of {total} |
| `collection_unknown` | ??? | ??? |
| `collection_unknown_talismans` | Încă nu l-ai văzut în Piață. | Not seen in the Market yet. |
| `collection_unknown_engravings` | Încă n-ai văzut Gravura asta. | Not seen this Engraving yet. |
| `shop_kind_page` | Pagină ruptă | Torn Page |
| `page_name` | Pagina ruptă | The Torn Page |
| `page_text` | O căsuță nedescoperită din Tabla Vrăjilor: ce rune trebuie și un vers ca indiciu. | An undiscovered cell of the Spell Table: which runes it needs and a verse as a hint. |
| `page_where` | Pagina rămâne în Cartea de rune, pe Tabla Vrăjilor. Restul e treaba ta. | The page stays in the Book of Runes, on the Spell Table. The rest is up to you. |
| `rune_book_torn` | ? · pagină | ? · page |
| `round_won_at_start` | Ce ai adus din lupta trecută ajunge: monstrul cade din prima! | What you carried from the last fight is enough: the monster falls at once! |
| `round_estimate` | Daună estimată | Estimated damage |
| `round_estimate_kill` | Ucide! | Kills! |
| `round_estimate_max` | cu noroc, până la {n} | with luck, up to {n} |
| `round_estimate_later` | lovește mai târziu | strikes later |
| `round_sort_role` | Rol | Role |
| `peek_label` | Urmează din Săculeț | Next from the Bag |
| `circle_no_spell` | nicio vrajă | no spell |
| `circle_second_spell` | + {name} (în lanț) | + {name} (chained) |
| `circle_kin_bonus` | Același Neam: ×{n} Rezonanță | One Kin: ×{n} Resonance |
| `circle_zero_by_rule` | Regula Stăpânului: nicio daună | The Lord's rule: no damage |
| `circle_estimate` | ≈ {n} | ≈ {n} |
| `circle_dealt` | −{n} | −{n} |
| `blocked_exact_count` | Stăpânul vrea exact {n} pietre. | The Lord wants exactly {n} stones. |
| `blocked_min_stones` | Stăpânul vrea cel puțin {n} pietre. | The Lord wants at least {n} stones. |
| `blocked_need_action` | Zmeul vrea o Acțiune în vrajă. | The Zmeu wants an Action in the spell. |
| `monster_weak` | Slab la {list} | Weak to {list} |
| `monster_resist` | Rezistă la {list} | Resists {list} |
| `monster_immune` | Imun la {list} | Immune to {list} |
| `monster_plain` | Nicio slăbiciune cunoscută | No known weakness |
| `monster_burn` | Arde ×{n} (−{value} la Rostire) | Burning ×{n} (−{value} per Cast) |
| `monster_frozen` | Înghețat ({n}) | Frozen ({n}) |
| `monster_shield_broken` | Scut spart | Shield broken |
| `monster_head` | Capul {n} din {total} | Head {n} of {total} |
| `monster_rule_resting` | (oprită acum) {text} | (stopped now) {text} |
| `monster_kind_exam` | Examen | Exam |
| `monster_kind_small` | Monstru mic | Small monster |
| `monster_kind_big` | Monstru mare | Big monster |
| `monster_kind_boss` | Stăpânul Tărâmului | Lord of the Realm |
| `float_hit` | −{n} | −{n} |
| `float_hits` | +{n} lovitură | +{n} hit |
| `float_tick_burn` | Arsura: −{n} | Burn: −{n} |
| `float_tick_future` | Viitorul sosește: −{n} | The Future arrives: −{n} |
| `float_tick_lasting` | Încă o dată: −{n} | Again: −{n} |
| `float_tick_ripen` | S-a copt: −{n} | Ripened: −{n} |
| `float_mult_weak` | Slab! ×{n} | Weak! ×{n} |
| `float_mult_resist` | Rezistă ×{n} | Resists ×{n} |
| `float_mult_immune` | Imun! | Immune! |
| `float_mult_light` | Lumina în noapte ×{n} | Light in the night ×{n} |
| `float_mult_time` | Timpul ×{n} | Time ×{n} |
| `float_mult_chain` | Lanț ×{n} | Chain ×{n} |
| `float_nature_burn` | Arde! ({n} straturi) | Burning! ({n} stacks) |
| `float_nature_freeze` | Înghețat! | Frozen! |
| `float_nature_shield_broken` | Scutul s-a spart! | The Shield broke! |
| `float_later_future` | Pleacă în Viitor: {n} | Off into the Future: {n} |
| `float_later_ripen` | Se coace: {n} | Ripening: {n} |
| `float_new_head` | Alt cap! | Another head! |
| `float_rule_struck` | lovită de fulger | struck by lightning |
| `float_fizzled` | n-a mers | fizzled |
| `float_scroll` | pe Pergament | onto the Scroll |
| `result_damage` | Daună în total: {n} · cea mai mare Rostire: {best} | Total damage: {n} · best Cast: {best} |
| `rune_does_element` | Putere {power} × Rezonanță {res}. {nature} | Power {power} × Resonance {res}. {nature} |
| `choice_pay_swap` | {n} Schimbare | {n} Swap |
| `exam_round_boss` | Stăpânul Tărâmului | The Lord of the Realm |
| `exam_title_boss` | Tărâmul {n} · Stăpânul | Realm {n} · The Lord |
| `exam_monster_hp` | Viață: {n} | Life: {n} |
| `exam_reward_boss` | Stăpânul: +{n} Monede | The Lord: +{n} Coins |
| `exam_passed_text` | Poarta e deschisă. Moștenirea e a ta. | The Gate is open. The inheritance is yours. |
| `exam_failed_by` | Te-a oprit: {name} | Stopped by: {name} |
| `exam_failed_text` | Aeva întoarce clepsidra. Încă o dată, de la Marginea Orașului. | Aeva turns the hourglass. Once more, from the Edge of the City. |
| `collection_tab_monsters` | Bestiarul | Bestiary |
| `collection_unknown_monsters` | Încă nu l-ai întâlnit. | You haven't met it yet. |
