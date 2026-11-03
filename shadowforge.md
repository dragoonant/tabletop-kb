# Shadowforge (Shadowverse: Evolve) — living entry

Repo `dragoonant/shadowforge` (public, Pages at `dragoonant.github.io/shadowforge/`), started 2026-10-29 (PLAN drafted before the first commit). Built on the owner's Windows PC: the art and audio were rendered locally ("rendered on this PC", HANDOFF; PLAN D11 "Cloud keys are dead"). Decisions: `PLAN.md` (D1-D17, the only place a decision lives); rules: `docs/rules.md` (Comprehensive Rules index), `DEVIATIONS.md`; engine contract: `docs/ENGINE-API.md`; card scripts: `docs/ABILITIES.md`; the look: `docs/look/README.md`; lessons: `kb/SVE-LESSONS.md`. **This entry is updated at the end of every milestone.**

## 1. Overview
- Shadowverse: Evolve, the physical TCG by Cygames and Bushiroad (English edition, 2023-). 1v1 only (D13), Standard format (D14), Comprehensive Rules v1.26.1 (D4). Regime: reproduction, "fidelity is the product", real card names and printed text, original generated art and sound (D1, D2). Modes: vs AI (easy/normal/hard), hot-seat, AI-vs-AI, tutorial, deck builder (D7). Pool: 15 decks, 348 cards, all scripted, 0 defects (D5). Crossover rules (Vanguard, Umamusume) only where a registered deck needs them (D6).
- Owner decisions 2026-10-29 (do not re-ask): "Let's move", accepting every default; template is lorecannae (D3); the pool widened to the Grand Showdown 2026 winners after the owner asked for "the latest competitive decks from shadowverse.gg/tier-list", which is the digital game Worlds Beyond and cannot be played under Evolve rules (D5). "Push to pages for playtesting" (deployed the same day).
- Owner decisions 2026-10-30 (do not re-ask): "The look and feel is too much like Lorecannae. I wanted it to be unique look and feel for each game" (Xross Forge as the model) led to concept A "the evolution rite", kept with "Let's keep it as is." (D17). Art row B of `art/audition.jpg` (large-head figures, anime card-game look, glossy cel shading): "Keep B" (D16). "Keep the game public" (D12).
- **The worked example of README rule 21.** PLAN §4.12 set only a palette ("dark-fantasy card-arena"), so the first skin was lorecannae re-coloured. Before and after, from `git show 37bf487^:styles.css` and the current `styles.css`:

| Surface | First skin (lorecannae re-coloured) | "The evolution rite" (`37bf487`) |
|---|---|---|
| Palette | obsidian `#0d0a12`, smoked steel, gold `#e8c27a`, ember `#ff8a4a`; your side warm gold, the opponent's steel-violet | midnight indigo `#04070f`-`#17325a`, moon `#e8f4ff`, evolution cyan `#7fe6ff`; your side cyan, the opponent's rose `#ff6f91` |
| Type | Cinzel / Palatino book serif for display | Bahnschrift (DIN fallbacks), capitals, wide tracking; Segoe for running text |
| Frames and shapes | rounded gold filigree frames, the same menu dialog, star card backs, the same board frame and hand fan (owner's list, `kb/SVE-LESSONS.md`) | cut corners at 45 degrees, hairlines, bright corner brackets, pointed blade buttons; no rounded frames |
| Board | lorecannae's board frame | a drawn floating stone dais (`js/ui/boardart.js`): slab, notched sockets, leader obelisks, a turning circle of light carrying the six class gems |
| Title and menu | centred menu dialog | original geometric wordmark drawn as SVG strokes and lit on the splash (`js/ui/title.js`), leader medallions face to face, leader gallery, ring wipe between screens |
| Game-specific effects | generic | the evolve rite (turning circle with a hexagram, white flash, rays from the screen edges on super-evolve); the leader's defense is a crystal that cracks on a hit |
| Cards and cost | gold frame | new card frame and back, diamond cost gem, crystal-shard play points; class colour only in gems, never in frames |
| Backdrops and sound | warm arena scenes | 8 backdrops re-rendered as cool night scenes; evolve, super-evolve, turn-start and menu theme re-voiced (unheard by the owner at the time) |

  What did not change: layout, modules, rules and engine (the commit message says "Structure, layout and rules unchanged"). The commit touched 34 files (+1213/-749); `styles.css` went from 1,142 to 1,314 lines.
- **The gate that keeps it from coming back:** `tools/check-look.mjs`, part of `tools/gate.mjs`. It fails on lorecannae and first-skin typefaces (Cinzel, Palatino, Georgia, Nunito, Trajan and others), ornament words (filigree, parchment, storybook), 29 listed old-palette colours, and any `border-radius` of 6-40 px; it also requires the concept tokens (`--night-0`, `--moon`, `--cyan`, `--side-mine`, `--side-theirs`, `--font-display`). It reported 145 problems on the previous stylesheet. The visual half is `docs/look/compare.jpg` (title and board for lorecannae, Xross Forge, the first skin and the current skin; "nothing in the last row may read as a row above it") and `docs/look/audition.jpg` (three concepts offered under the three references).

## 2. Donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Engine spine (seeded RNG, state copy, jobs queue, `Ask` + replay, `settle()`, doors `ask/pay/move/dealDamage/chars`) | lorecannae | Renamed `LC` to `SV`; Lorcana's "bag" maps to Evolve's Confirmation Timing (PLAN §3.1, §4) |
| AI search (one-ply + one opponent ply on determinized copies) | lorecannae `js/ai.js` | Search kept, evaluation terms rewritten (leader defense, board, EX area, lethal detection) |
| UI structure (16 modules in `js/ui/`, drag, preview, log drawer, deck builder, tutorial), `sounds.html` | lorecannae | Layout and modules kept, re-zoned for leader defense, field and EX area of 5, evolve deck, PP / EP / super-EP; the skin was replaced by D17 |
| Presentation approach (one concept from the game's world, carried through every surface) | Xross Forge | The model the owner named; D17 cites README rule 21 |
| Tools (serve, test, sim, gate, check-pages, check-art, stamp-assets, replay-report, audit-cards, gen-art, shrink-art), `kb/`, NOTICE, takedown lever | lorecannae | Auditor keyword table and art-prompt lint list changed |
| Quick window (opponent acts mid-turn) | Built as a queue step with the other seat as controller | PLAN §4.2 names it the FAB reactive-window pattern |
| Card data | New: official English site scraper, Decklog JSON API | `tools/fetch-cards.mjs`, `tools/build-cards.mjs`; HTML pages, no card API |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff + PLAN | 2026-10-29 | not recorded | Four owner questions with defaults; "Let's move" |
| Sources, rules index, card data, engine, 348 card scripts, AI, interface, art, audio, deploy | 2026-10-29 | not recorded (HANDOFF: "one session, about 4 hours") | Six card agents in parallel, one class each, about 30 min for 348 cards. Two independent reviews found 4 engine and 14 script bugs, all fixed. Gate: 414 tests, audit 0 FAIL, random and AI games 0 errors. Hard beat Normal 13/20, Normal beat Easy 17/20 (`docs/ai.md`). 348 plates (FLUX.1 dev, about 20 s each) plus 8 backdrops; 31 effects and 6 tracks, not heard by anyone. Deployed to Pages (`da997fd`) |
| Inspector above every panel; Hide / Show on pop-ups (`c6c3858`) | 2026-10-30 | not recorded | `U.peekable` helper (see lessons) |
| Re-skin "the evolution rite" (`37bf487`, merged `7464d4e`) | 2026-10-30 | not recorded | Section 1 table. Checked in the real page at 1440x900 and phone sizes: splash, menu, gallery, a full computer-vs-computer game, log drawer, evolve rite, defense crack |
| Owner keeps the look, art row B and the public site (`1e67737`, `4ae8d71`) | 2026-10-30 | not recorded | D17, D16, D12 final; concepts B and C retired |
| UI polish (`cce5e29`) | 2026-10-31 | not recorded | No text selection on long press; phone menu clears the notice |

Open (`TODO.md`, `HANDOFF.md`): the owner has not listened to the audio; phone-sized screens are small when held upright; two rules debts in `DEVIATIONS.md` (damage-modifier order and mulligan order are not asked); four engine tidy-ups in `TODO.md`.

## 4. Lessons for the series
- *(added 2026-10-30, shadowforge)* **A palette is not a presentation concept; write the concept and a "must not look like" list at kickoff.** PLAN §4.12 said "dark-fantasy card-arena" and named colours, and the result was the template re-coloured. D17 instead states a scene (two summoners on a floating dais under the moon), a shape language, a type rule, signature moments and a colour rule, then ships a test for it.
- *(added 2026-10-30, shadowforge)* **Make "looks like the template" a failing check, not a judgement.** `check-look.mjs` lists the old skins' fonts, colours, ornament words and rounded radii and exits 1 on any hit, so a later edit cannot drift back. Pair it with a side-by-side sheet (template, sibling, old skin, new skin) that the owner can judge at a glance.
- *(added 2026-10-30, shadowforge)* **Offer the owner an audition of whole concepts, not a colour swatch, and build the default while they decide.** Three concepts were shown under the references; concept A was built as the default (D17), so the owner's "Let's keep it as is." came on a live page, not a mock-up.
- *(added 2026-10-30, shadowforge)* **Pop-up helpers belong in one shared function.** Only the choice panel had Hide; the Quick prompt, targeting bar, results screen and tutorial bubble did not. `U.peekable` plus one `.peek` CSS block fixed them all. The inspector was also raised above every panel (z 110, hover preview 105) because a long-press enlargement opened behind the mulligan panel (z 58) and the deck builder (z 80) on a phone.
- *(added 2026-10-29, shadowforge)* **Check that the owner's named source is the right game before building to it.** "shadowverse.gg/tier-list" is Worlds Beyond (digital, different cards and classes), not Evolve. The plan took the Grand Showdown 2026 winners as the nearest full English lists and recorded why (D5).
- *(added 2026-10-29, shadowforge)* **Independent reviewers find bugs that every self-test missed.** 14 script bugs after all tests passed (Aura ignored in `canPlay`, a cost loop that stopped early, a crest counting the wrong card in a Fuse). Prove each regression test fails on the old code; two passed on the broken code until rewritten.
- *(added 2026-10-29, shadowforge)* **Audit the authored spec, not the compiled function.** 318 auditor FAILs were false because the card sugar wrapped abilities in closures, hiding their source.
- *(added 2026-10-29, shadowforge)* **Ask agents to mark "needs engine: X" and add X centrally.** It kept six card writers off the engine file while doors (leader defense, Maneuver, choose-any-number, leave replacements and others) were added on request.
- *(added 2026-10-29, shadowforge)* **A reactive window sits inside the queue, so "queue empty" cannot mean "may act now".** A reviewer found Quick activated abilities could never be used in the opponent's window.
- *(added 2026-10-29, shadowforge)* **Official card sites can be the database.** The English site's card pages carry every field, icons as `alt` tokens and dated Q&A; Bushiroad Decklog has a JSON API (`POST /system/app/api/view/<code>`, view page as `Referer`). Details in `kb/SVE-LESSONS.md`.
