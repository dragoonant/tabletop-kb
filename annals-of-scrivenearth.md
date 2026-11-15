# Annals of Scrivenearth — living entry

Repo `dragoonant/annals-of-scrivenearth`, started 2026-11-15 from a **claude.ai cloud session**. Decisions: `PLAN.md` (D1-D19); rules: `docs/spec/10-rules.md` (rule ids, rulings); client and look: `docs/spec/50-client.md`; balance record: `BALANCE.md` (B-1..B-3); card authoring: `docs/AUTHORING.md`; GPU job: `HANDOFF-GPU.md`; state: `STATUS.md`. **This entry is updated at the end of every milestone.**

## 1. Overview
- **An original card game, not a port: the series' fourth original ruleset and its first original card battler.** The owner (2026-11-15): "In this project we'll be recreating a well known card game. Do you know what it is?" Claude guessed the game from the repo name, declined to recreate it (name, heroes, card set, regions, art, look) and offered an original game with the genre's mechanics. Owner: "Yes, browser. Play against ai." (PLAN D1). Kept from the genre: alternating attack rounds, a growing resource with a banked reserve for spells, three spell speeds with a last-in-first-out stack, heroes that level up, two-faction decks. Written fresh: rules text and numbers, 150 cards, 12 heroes, six factions, the setting (a city of cut crystal) and the look.
- Shape: 1 human against an AI (three tiers). 40-card decks from two of six factions, a 20-Integrity Spire each, Lines of six units, heroes that **Ascend** when a counted condition is met (every copy, in every zone), a **Resonant** bonus while an Ascended hero is on the Line.
- Owner decisions 2026-11-15 (do not re-ask): presentation concept **crystal magitech city**, picked from a second set after "I hate these ideas" about three writing-themed concepts (D4); **full pool plus deck builder** in the first push, against the small-pool recommendation (D5); main + Pages each stage (D6); feel **big hero moments** (D7); "a fully fleshed out UI like xross forge and shadow forge" (D12); card art style is Claude's pick (D13); a unit may be played onto a full Line by scrapping one of your own (D14); desktop and phone landscape first (D15); a guided first match (D16); art and audio on EVILAEGIS (D9).

## 2. Stack and donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Config (Vite 8, TS 7 strict, Vitest 5, Playwright 1.63.0 pinned, `PW_PORT`, `base: './'`) | wasteland-behemoths | Plain DOM, no framework |
| Engine contract (never-throwing `applyAction`, `legalActions` never empty, plain-JSON state, seeded RNG in state, `view(state, seat)`, one door per rule) | card-games.md section 3, recipe steps 2 and 4 | Written fresh. Cards are data: ops, selectors, conditions, triggers (`src/engine/types.ts`) |
| Save (rule 22) | rule 22 text | `src/engine/save.ts`, key `scrivenearth-save` |
| AI | card-games.md section 4 | `src/ai/brain.ts`: every candidate played out on a copy of the AI's own view until the board is quiet, scored against doing nothing; blocks and attackers added greedily; Archon adds one enemy-attack reply ply |
| Pages | bossforge route | Gates, then force-push `dist/` to `gh-pages` |
| Art prompts | card-games.md section 7 | `tools/art/`: one STYLE constant, subject + scene per card, lint that refuses to write the prompts file, idempotent Flux generator with contact sheets |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff, spec, engine, 12 heroes | 2026-11-15 | coordinator only, not measured | Rules spec with ids first; engine and 45 rule tests written by the coordinator in one pass |
| Card pool | 2026-11-15 | 3 Sonnet helpers, about 430k in total | 138 cards (two factions per helper, disjoint files, one behaviour test per card) in under 5 minutes of wall clock; no engine edits needed |
| First playable client | 2026-11-15 | 1 Sonnet helper, about 310k | Every screen but the deck builder against `docs/spec/50-client.md`; 20 minutes |
| AI and arena | 2026-11-15 | coordinator | Ladder measured: random < Apprentice (38-2) < Adept (50-10) < Archon (36-24) |
| Stage 1 on `main` | 2026-11-15 | — | 201 Vitest tests, 5 Playwright tests, bench with replay; first deploy run failed on a file left out of the commit, second passed |

## 4. Lessons for the series
- *(added 2026-11-15)* **Write the heroes yourself as the worked examples, then fan out the rest of the pool.** The coordinator wrote the 12 heroes and their tests as data before any helper started. Three helpers then wrote 138 cards against the same shapes with no engine change and no primitive invented. The authoring guide named the stat budget, the per-faction card counts by cost and the rule that triggered abilities never choose targets.
- *(added 2026-11-15)* **Stalled boards show up as empty-deck endings in the first AI mirror sim.** 10 of 60 games ended by deck-out because the AI only took attacks that won outright. A growing bonus on the first attacker fixed the AI; the owner then chose a rule change as well (play onto a full Line by scrapping a unit). Count "idle with options" rounds, not just empty rounds: holding a reactive spell is not idling.
- *(added 2026-11-15)* **A keyword plus an op that both heal double-count** (a strike-heal keyword on a hero whose ability also drains). Decide per keyword whether it reads strikes only, and say so in the keyword table.
- *(added 2026-11-15)* **An ability that fires on "this dealt damage to the enemy" can feed itself** if its own op deals damage from the same unit. Fire such triggers on strikes only.
- *(added 2026-11-15)* **The owner asked for questions "in api"**: a text list of questions was sent back with "Questions in api please". Rule 12 holds even when he asks for "your questions" in prose.
- *(added 2026-11-15)* **EVILAEGIS folders are not offered to cloud sessions** (`list_computer_folders` listed four folders, all "not available"). The route is a Claude session on EVILAEGIS in a clone of the repo, messaged from the cloud session, with a `HANDOFF-GPU.md` in the repo.
- *(added 2026-11-15)* **A style word can collide with a card name in the prompt lint** ("seen close" against a card called Sluice Close). Keep the STYLE lines free of ordinary words a card might be named after.
