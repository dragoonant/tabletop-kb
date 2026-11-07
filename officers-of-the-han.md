# Officers of the Han — living entry

Working title. Repo `dragoonant/officers-of-the-han` (waiting for the owner to create it on 2026-11-07; until then the history is committed locally in the cloud session). Started 2026-11-07 from a **claude.ai cloud session**. Decisions: `PLAN.md` (D1-D19); world rules: `docs/spec/10-rules.md`; hex battles: `docs/spec/20-battle.md`; duels and debates: `docs/spec/30-duel-debate.md`; events: `docs/spec/40-events.md`; data: `docs/spec/12-data.md`; skin: `docs/spec/50-presentation.md`. **This entry is updated at the end of every milestone.**

## 1. Overview
- **The series' second original Three Kingdoms game.** Owner, 2026-11-07: "build a spiritual successor to the game of romance of the three kingdoms 8". It is not a port or a recreation: you play one officer in a living world (free officer to ruler), with our own rules, names of systems, text and art. Same posture as three-kingdoms-tactics (its D10): historical names from the public-domain novel and the record, stat values set by our own rubric from the record (`12-data.md` §3), never copied from any game.
- Owner decisions 2026-11-07, asked before the owner slept (two multiple-choice batches, 4 + 3; do not re-ask): new repo the owner creates (D1); **new hex field battles**, chosen over reusing the tactics square-grid battles (D2); full map, one scenario, play as any officer (D3); **190, the coalition against Dong Zhuo** (D4); presentation concept **Han lacquerware**: vermilion on black lacquer, cloud-scroll bands, cities as bronze mirrors, letters on silk (D5); all four pillars in the first playable: personal ties, duels and debates, novel events, create your own officer (D6); overnight run approved for specs, engines and a first playable, about 5-6M tokens (D7).
- Defaults taken: sibling stack; 2D SVG map with 3D R3F battles; monthly turns with 30 days per officer; posts Ruler, Prefect, Officer, Wanderer (Viceroy later); the AI never executes the player's officer; portraits copied from the tactics game where officers match, a lacquer medallion otherwise; saves per rule 22 under `oth-save`; no audio until a session on the owner's PC.

## 2. Donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Config (vite, tsconfig, playwright `PW_PORT`, deploy.yml) | three-kingdoms-tactics | Base path `/officers-of-the-han/`, port 5317, Playwright pinned to 1.63.0 |
| sfc32 RNG | three-kingdoms-tactics `src/engine/rng.ts` | Copied to `src/shared/rng.ts` with `d100`, `chance`, `childSeed` |
| Portraits | three-kingdoms-tactics `public/portraits` (128 webp) | Copied for matching officer ids; generics for created officers |
| Engine contract pattern | KB recipe | Four pure engines (world, battle, duel, debate) joined by frozen setup/outcome types in `src/contracts/` |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff + M0 specs and contracts | 2026-11-07 | coordinator only | Seven specs and four contract files written by the session model before any agent (lesson from three-kingdoms-tactics: an original game needs rule ids first). Then M1 data, M2a world and M2b battle/duel/debate started at once in three worktrees with `node_modules` symlinked |

## 4. Lessons for the series
- *(added 2026-11-07, officers-of-the-han)* **Have the owner create the new repo before they leave.** A cloud session cannot create repos, and the auto-mode classifier refused pushing the new game's unrelated history to a session branch of a sibling repo as a stopgap. Work stays committed locally until the repo exists, so put "create the empty repo and enable Pages (Source: GitHub Actions)" in the kickoff message, not after the questions.
- *(added 2026-11-07, officers-of-the-han)* **Split an officer-play strategy game into separate engines joined by setup/outcome types.** The world hands a `BattleSetup`, `DuelSetup` or `DebateSetup` to its engine as a pending decision and validates the returned outcome. That lets the world and the contests be built at the same time with no shared files, and AI-vs-AI contests auto-resolve by formula in the world, so the sim doesn't depend on the battle engine.
