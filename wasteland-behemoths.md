# Wasteland Behemoths — living entry

Repo `dragoonant/gammarauders` (private), started 2026-11-05 from a **claude.ai cloud session**. Work is on branch `claude/wasteland-behemoths`, which was not merged and not on Pages as of 2026-11-05 (`9581e4d`).
Decisions: `PLAN.md` (D1-D8). Rules: `docs/spec/10-rules.md` (rule ids, balance record B-1..B-3, rulings). State: `STATUS.md`. **This entry is updated at the end of every milestone.**

## 1. Overview
- **An original game, not a port: the series' second original ruleset after [three-kingdoms-tactics.md](three-kingdoms-tactics.md).** The owner asked (2026-11-05): "In this project I'd like to make a digital version of the gammarauders game" (Gammarauders, TSR 1987). Claude declined to recreate that game (its name, creatures, card text, art, and rules 1:1) and offered an original game in the same family. Owner: "Original game, browser-based, play against the AI. I'd like the rules to be as similar to gammarauders as possible." So the genre mechanics carry over: one giant bio-mech per warlord, a hex map, grafting weapons and mutations into body slots, resource sites, dice combat and a VP race. The rules, numbers, the 66-card deck, names and look are written fresh (PLAN D1). As with three-kingdoms-tactics, "fidelity is the product" (rule 2) becomes "the spec is the product".
- Owner later (2026-11-05): "Use our GitHub repo dragoonant/tabletop-kb as your basis for what you are doing. Update it based on your findings and implementations." The first playable was then brought in line with rules 8, 11, 22, 24 and 25 and the recipe's gates (section 3).
- Shape: 1 human (seat 0) against 1–3 AI warlords. Radius-6 hex map with point-symmetric random terrain, 7 Rad Wells (a 2-VP Heart Well at the center), 25 VP to win by default, 30-round cap. Kills are worth 5 VP; a destroyed Behemoth loses all its grafts and respawns at its base.

## 2. Stack and donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Config (Vite 8, TS 7 strict, Vitest 5, Playwright, `PW_PORT`, `.gitattributes`, sub-path `base: './'`) | KB recipe step 1 | No React, R3F or three: the board is one SVG with plain DOM (PLAN D2), so rules 26 and 27 do not apply yet |
| Engine contract (pure actions that never throw and change nothing on rejection, seeded mulberry32 RNG, queries own every number, plain-JSON state) | KB recipe steps 2 and 4 | `src/engine/rules.ts` `applyAction` returns `{ok, error, events}` |
| Save (rule 22) | Rule 22 text (MANAFORGE/Mallet shapes) | `src/engine/save.ts`: v2 envelope {game, version, savedAt, setup+seed, actions, snapshot}; key `wasteland-behemoths-save` |
| Pages deploy | [bossforge.md](bossforge.md) route (gates, then force-push to `gh-pages`, `.nojekyll`) | `.github/workflows/deploy.yml`, on `main` only. The repo is private, so Pages needs the owner's choice (PLAN open question 1) |
| Presentation | none (fresh) | Concept "a salvage-yard war map": dark rust-and-amber survey table, heavy uppercase wordmark, spiked crest tokens (PLAN D4). The rule 21 side-by-side comparison has not been done |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| First playable (engine, AI, SVG client) | 2026-11-05 | not measured (coordinator only, no sub-agents) | Engine, 66-card deck, symmetric map generator, heuristic AI (`planAction`: graft by card value, move by a position score of wells + attack value − threat, fire at the best expected damage, tactics by simple triggers), and an SVG board with a side panel. A 6-turn scripted browser game ran with no console errors and no sideways scroll at 390 px |
| Seat balance | 2026-11-05 | — | 200 AI games per seat count: seat 1 won 63.5% of 2-player games. +1 energy per later seat alone changed almost nothing (61.5%). Adding 1 stun to the first player's opening turn gave 54/46, with 3p and 4p close to even (spec B-1) |
| KB conformance | 2026-11-05 | not measured (coordinator only) | Rule 22 envelope, Continue naming sides/round/turn/VP/time, replace-confirm, damaged/finished/refused-storage messages; rule 24 CSS and listeners; rule 25 tile-only picking with a hex inspector; rule 8 (no `title` tooltips, numbers from engine queries); spec with rule ids; sim invariants; save round-trip and replay test; bench vs random 100/100; 6 Playwright e2e; CLAUDE/PLAN/STATUS; KB submodule; deploy workflow (`9581e4d`) |

## 4. Gates (2026-11-05)
- `npm test`: 17 Vitest tests named by rule id. They include 30 AI games (2–4 players) with invariants checked after every action: card conservation (66), hand limit, energy cap, hull within 1..max, no shared or impassable hexes. Games averaged 10.8 rounds (9–14), and all 30 were won on VP.
- Save: the envelope round-trips, setup + actions replay to the snapshot, and playing on from the reopened snapshot ends identical to never saving. Bad JSON, a foreign game id, an old version, a missing card and a finished game are each refused with a reason.
- Bench: the AI beat a uniformly random legal-action bot (`randomAction`) in 100/100 games, alternating seats (recipe step 6 gate: at least 95%).
- `npm run e2e` (6 tests): smoke plus a text sweep for `undefined`/`NaN`/`null`; rule 24 at 390×844 (`userSelect === 'none'`, a triple click leaves no selection); rule 25 (`elementFromPoint` at an enemy token's centre returns that hex's tile, and the click inspects it); rule 22 with `launchPersistentContext` (play, close, reopen, Continue, compare round, log length, action count and hand; New game asks to replace); corrupt, finished and refused-storage saves.

## 5. Lessons for the series
- *(added 2026-11-05, wasteland-behemoths)* **Measure seat balance in the first engine milestone, and test each fix separately.** The AI-vs-AI sim showed a 63/37 first-player edge in 2-player games within minutes. The obvious fix (more starting energy for later seats) did nothing measurable. A one-hex opening-move penalty for the first player did (54/46). Keep the per-step table in the spec (B-1).
- *(added 2026-11-05, wasteland-behemoths)* **On a 2D SVG board, rule 25 is one CSS rule:** `pointer-events: none` on the token and effects layers, with every handler on the tile `<g data-key>`, and one tap resolver (armed action, then move, then inspect). Gate it with `document.elementFromPoint` at the token's centre returning the tile's key.
- *(added 2026-11-05, wasteland-behemoths)* **A control that stays enabled while an action animates swallows clicks silently.** End Turn looked live during a move's step animation, but the handler ignored it because the game was busy. A human would click twice; the e2e hung. Re-render (disable) the controls the moment an action starts. The e2e only found it once it waited for "Round 2" instead of the first enabled button.
- *(added 2026-11-05, wasteland-behemoths)* **Write the save before the first render**, or a "browser is not storing saves" line (rule 22) appears only after the next action.
- *(added 2026-11-05, wasteland-behemoths)* **Rule 8 sweeps include SVG `<title>` children**, not only `title=` attributes. Both were in the first playable. Move their content into a visible inspector fed by an engine query, so numbers like rad damage come from `RULES`.
