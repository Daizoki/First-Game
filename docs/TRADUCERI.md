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
| `pas 1.text` | Acum ceva ce nu-ți spune nimeni la examen. | Now something nobody tells you at the exam. |
| `pas 2.text` | Unele rune, puse împreună, fac mai mult decât scor. Se cheamă Vrăji. | Some runes, put together, do more than score. They are called Spells. |
| `pas 3.text` | Gheață. Grindină. Nevoie. Ce iese din ele? | Ice. Hail. Need. What comes of them? |
| `pas 3.wrong_text` | Gheața, grindina și nevoia: Isaz, Hagalaz, Naudiz. | Ice, hail and need: Isaz, Hagalaz, Naudiz. |
| `pas 4.text` | Simți? Cercul s-a trezit. Nu-ți spune ce Vrajă e. Ca s-o afli, trebuie s-o rostești. | Feel that? The circle has woken up. It won't tell you which Spell it is. To find out, you have to cast it. |
| `pas 5.text` | Hagalaz are Poziția 1. Adaugă Fehu și Tiwaz, tot cu Poziția 1, și ai și o Treime. Vrajă și scor în aceeași Rostire. | Hagalaz has Position 1. Add Fehu and Tiwaz, also Position 1, and you have a Triad too. A Spell and a score in the same Cast. |
| `pas 5.wrong_text` | Fehu și Tiwaz. Cifra 1, în colț. | Fehu and Tiwaz. The 1 in the corner. |
| `pas 6.text` | Rostește. | Cast. |
| `pas 7.text` | Iarna. Uite, Ținta a scăzut. | Winter. Look, the Target dropped. |
| `pas 8.text` | Sunt peste treizeci de Vrăji și toate se pot ghici din sensul runelor. Nu ți le spun. Nici eu nu le știu pe toate. | There are more than thirty Spells, and every one can be guessed from the meaning of its runes. I won't tell you them. I don't know them all myself. |

### Lecția 5 — Singur

| Unde | Română | English |
|---|---|---|
| `title` | Singur | On your own |
| `fail_text` | Mai încearcă. Tot ce înveți aici rămâne. | Try again. Everything you learn here stays with you. |
| `win_text` | Nu-i rău. Mâine dimineață e examenul. Kaldor nu e la fel de răbdător ca mine. | Not bad. The exam is tomorrow morning. Kaldor is not as patient as I am. |
| `idle_hint.text` | Caută o Pereche. Sau citește Glasurile. | Look for a Pair. Or read the Voices. |
| `pas 1.text` | Acum fără mine. Ținta e mică. Nu mă face de rușine. | Now without me. The Target is small. Don't embarrass me. |

## Indiciile (`data/hints.json`)

| Indiciu | Română | English |
|---|---|---|
| `first_laguz` | Laguz e apă: curge. Contează ca piatră din orice Neam. | Laguz is water: it flows. It counts as a stone of any Kin. |
| `idle_help` | Nu știi ce să faci? Ține mouse-ul pe pietre sau deschide Cartea Cuvintelor. | Not sure what to do? Hover over the stones or open the Book of Words. |
| `first_shop_1 (oprit)` | Bună seara, puiule. Aici cumperi ce te ține în viață la examen. | Good evening, dear. Here you buy what keeps you alive in the exam. |
| `first_shop_2 (oprit)` | Talismanele lucrează singure, de la stânga la dreapta. Ai cinci locuri. | Talismans work on their own, from left to right. You have five slots. |
| `first_shop_3 (oprit)` | Lecțiile cresc un Cuvânt. Gravurile schimbă pietrele. Săculețele… surpriză. | Lessons raise a Word. Engravings change stones. Bags… a surprise. |
| `first_reroll (oprit)` | Nu-ți place marfa? Rearanjez taraba, dar nu gratis. | Don't like the goods? I'll rearrange the stall, but not for free. |
| `first_talisman (oprit)` | Trage Talismanele ca să le schimbi ordinea. Ordinea contează. | Drag the Talismans to change their order. Order matters. |
| `first_examiner (oprit)` | Eu sunt Kaldor. Regula mea e scrisă acolo. N-o repet. | I am Kaldor. My rule is written there. I won't say it twice. |
| `first_lesson (oprit)` | O Lecție crește nivelul unui Cuvânt pentru tot examenul. | A Lesson raises a Word's level for the whole exam. |
| `first_engraving (oprit)` | O Gravură schimbă o piatră. Alege piatra din mână, apoi folosește Gravura. | An Engraving changes a stone. Pick the stone in your hand, then use the Engraving. |
| `first_bindrune (oprit)` | O legătură e o piatră cu două rune. Contează ca oricare dintre ele, iar Glasurile se aud amândouă. | A bind-rune is a stone with two runes. It counts as either of them, and both Voices are heard. |
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
| `rune_book_hint` | Cele 24 de rune, cu sensul și Glasul lor · Vrăjile pe care le-ai descoperit | The 24 runes with their meaning and Voice · the Spells you have discovered |
| `rune_book_position` | Poziția {n} · Putere {power} | Position {n} · Power {power} |
| `rune_book_spells` | Vrăjile · {n} din {total} descoperite | Spells · {n} of {total} discovered |
| `rune_book_spell_hidden` | Încă n-ai rostit-o. | You haven't cast it yet. |
| `rune_book_close` | Închide | Close |
