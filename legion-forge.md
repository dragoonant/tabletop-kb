# Legion Forge (Star Wars: Legion) — living entry

Repo `dragoonant/legion-forge` (private), started 2026-10-28 from a **claude.ai cloud session** (Linux container), not the Windows PC. Decision record: `KICKOFF.md`; decisions and milestones: `PLAN.md`. **This entry is updated at the end of every milestone** (what landed, real token spend, what worked, what bit). Cross-project lessons also go into [README.md](README.md) in the same commit.

## 1. Overview
- Star Wars: Legion (Atomic Mass Games; originally FFG 2018) as a 3D browser game, player vs AI first, hot-seat later, online not planned. Mechanics 1:1 with the current AMG Rules Reference and points; edition pinned and leak list written at M0 after source research.
- Owner decisions 2026-10-28 (do not re-ask): web/TypeScript; **vs AI first, AI early**, hot-seat later; "maybe public later" but **Mallet posture** (real names; prose ours; no official art) chosen over the Starbound posture; **MGSD figures of recognizable Star Wars designs**; push to `main` after each stage pre-approved, **repo private**, Pages when the owner goes public.

## 2. Where each subsystem comes from (donor map)
| Legion subsystem | Closest sibling | What to take |
|---|---|---|
| Engine contract (pure `step`, one `PendingDecision`, `view`, `query.*`, seeded RNG, replay, save) | Mancermundo `origin/main` | Copy wholesale with the quarantine-and-port table (`docs/spec/05-migration.md` shape) |
| Command phase: hidden simultaneous command-card pick, priority by pips, orders issued | Dead of Winner / Fell-in (`seat: 'all'` decisions), Mallet stratagems | Simultaneous decision answered by both seats; `view` hides the pick until the reveal; leak test in the sim |
| Order pool: random face-down draw by rank | Dead of Winner hidden information | Draw is engine RNG; the token is hidden until revealed; leak test covers it |
| Alternating unit activations, 2 actions + free actions | Murder Squad `firefight.ts`, Mancermundo action phase | Activation loop and action ledger; units, not single models |
| Multi-mini units, unit leader, cohesion, wound allocation, leader replacement | Mallet (40k units, coherency), Not Enough Minerals `squads.ts` | Unit container and coherency checks; Legion measures from the unit leader |
| Custom attack dice (red/black/white d8) and defence dice (red/white d6) with surges | Not Enough Minerals (D6 pipeline with Surge), Mallet fast-rolled batches | Face tables in data; one attack pipeline with named steps; test the face mapping (Mancermundo's ammo symbol sat on the wrong face) |
| Range bands 1-5 (and beyond) | Fell-in colour rulers | Engine stores inches and owns the band table |
| Movement tool (speed 1-3 template with hinges), notched bases | Murder Squad `move.path`, movement range overlay | Continuous decision constrained to the tool's geometry; new code |
| Line of sight with silhouettes, light/heavy cover | Murder Squad head point to silhouette samples, Mallet per-piece cover attribution | Sampling model; silhouettes per base size from data |
| Suppression, panic, courage | none | New module, one generic mechanism |
| Keywords (a very large set) | Murder Squad team-extension mechanism, card-series validation | Declarative JSON + `{"code"}` hooks; `{unimplemented}` refused from any playable army; firing test per hook; new timings as windows, never army branches |
| Command cards | Mallet stratagems, Murder Squad ploy windows | Windows open only when a seat can use something |
| Battle deck (objectives, deployments, conditions) | Mallet missions, Mancermundo scenarios | Data plus code hooks; layouts from a source file with a reachability test |
| Vehicles (repulsor, ground), turrets | Not Enough Minerals / WarMechForge split nodes | `split.mjs` for turret yaw; vehicles land after the infantry slice |
| AI | Murder Squad / Mancermundo utility decider in a worker | Score against do-nothing; count zero-action activations; bench both seats with holdout seeds |
| Client, presentation, dice tray, phone layer | Mancermundo client (from Murder Squad and Mallet) | Re-skin with the Starbound palette ([starbound-legions-ip.md](starbound-legions-ip.md)) |

## 3. What is new for the series
- First Disney property; owner kept the Mallet posture anyway (README rule 18).
- First project started from a cloud session: the engine, AI and client stages run there, but art (Gemini + Hunyuan) and audio (Audio Studio) need a session on the Windows PC.
- Units of several minis that activate together, measured from a unit leader. The 40k port had units, but its activation went by phase, not alternating with order tokens.
- A hidden simultaneous pick (command cards) inside an otherwise open-information skirmish.
- A physical movement tool instead of free inches.

## 4. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff + KB review | 2026-10-28 | not measured | Two question batches answered; KB copied from mancermundo and extended |
| M0 scaffold + sources + specs | 2026-10-28/29 | not measured in-session (7 agents: 1 Sonnet, 6 session model) | Mancermundo copied into `legacy/` with a 292-line KEEP/ADAPT/DELETE table; official AMG documents downloaded (Core Rule Book 2026-06-17 and others); primer + leak list; specs 00, 05, 10-14, 20, 40, 50, 60; 56 RULINGs; privacy hook that works in worktrees; shared KB repo created and linked as a submodule |
| M1 data | 2026-10-29 | 0.32M (1 Sonnet) | 196 records, schema frozen after the dry run; Legion HQ disagreed with AMG cards on 2 weapons |
| M2 engine (2a, 2b-flow, 2b-combat, integrate, rules review, 2c fixes) | 2026-10-29 | ~2.4M (5 Sonnet + 1 session-model reviewer) | Flow and combat built in parallel (combat in a worktree), integrated by a third agent; the read-only reviewer found 29 WRONG rules; 2c fixed all with failing-first tests, added melee charges, sim 0.14 -> ~1.2 games/s |
| M3 client | 2026-10-29 | 0.67M (1 Sonnet) | Playable vs random bot; ported from Mancermundo's client |
| M4 AI + reconcile | 2026-10-29 | 0.80M (2 Sonnet) | Normal beat random 279-1 then 40-0 after the M2c merge; 0 fallbacks; dodge filler fixed |
| M7 polish | 2026-10-29 | 0.44M (1 Sonnet) | Phone/touch, save/continue, term help, settings, AI audit recap, how to play; e2e desktop and phone profiles |
| **Total to playable vs AI (M0-M4)** | 2026-10-29 | **~6M subagent tokens** (4.35M counted + ~1.5M estimated for six M0 agents whose counts were lost in container restarts) plus the coordinator | Kickoff estimate was 5M; the overrun is M2 (combat bigger than planned, a 29-item fix stage, an integration stage and a reconcile stage) |

## 5. Lessons so far
- *(M5/M6)* **Art and audio need the PC, and cloud sessions cannot attach a Windows computer** (Remote Control folders are Mac/Linux only). The suggested-task cards (`spawn_task`) with a self-contained prompt were the hand-off; "do this task here" in the cloud session cannot run them. The owner also wanted the prompts as plain paste-ready text. D20 (at most 2 copies of a body per army) raised the figure count from 40 to 55 after the brief was written; change the brief before the PC session starts, since it reads the spec fresh from main.
- *(M7)* WebKit is not installed in the cloud sandbox, so iPhone Playwright profiles run on Chromium with the device metrics; real Safari behaviour (audio unlock, safe areas) is only checked on the owner's phone.
- *(M2)* **An independent read-only rules reviewer earns its cost** (0.46M): 29 WRONG findings on a green suite. The biggest root cause: keyword tests injected window context (`action`, `moveKind`, `unitId`) by hand that the real window opener never passed, so the keywords never fired in a real game. Every keyword needs at least one integration test driven through real `step()` calls, not hand-built windows.
- *(M2/M4)* **Building the AI in parallel with an engine fix stage costs a reconcile stage.** The fix stage added decision kinds (barricade placement, charges, card actions); the AI built against the old engine fell back on them. The exhaustive `POLICIES` table (a new kind fails to compile) and the bench's fallback counter caught it at merge time. Budget the reconcile stage up front or run AI after engine fixes.
- *(M2)* **Split one stage across two agents only with an agreed seam**: export names, append-only blocks in shared type files, and one agent owning the module table. Flow and combat merged with trivial conflicts; the wiring still needed its own integration agent (calls each side expected the other to make).
- *(M3/M4)* **Timing-sensitive tests flake when agents run in parallel** (load average 6-8 in the container): the sim gate needed a realistic timeout while the sim was slow, and an AI test comparing two searches needed a frozen clock because the wall-clock hard stop fired under load.
- *(M4)* Gate every commit in a detached worktree (`git worktree add --detach <tmp> HEAD`, symlink `node_modules`); it caught a commit that contained another agent's staged renames, a deleted-directory pathspec that silently skipped a commit, and both flaky tests. `node_modules/` in `.gitignore` does not match a `node_modules` symlink; use `node_modules`.
- *(M0)* **The product line changed under us.** AMG no longer sells a two-player core set; the entry products are single-faction 600-point Recon starter sets (no vehicles). Research before fixing the first slice: the kickoff default (Empire vs Rebels core set with speeder bikes) did not exist.
- *(M0)* **AMG card and battle-card PDFs have no text layer.** The Core Rule Book does (keyword glossary pp. 46-61). Battle cards were read by eye from rendered pages, and the Legion HQ 2 list builder's live JS bundle is the only machine-readable card data (909 cards, current to 2026-06-19, Fan-source). It disagreed with the AMG cards on at least two weapons' dice, so primary cards win and every playable army gets an eye check.
- *(M0)* **The cloud container restarted twice during background agent runs.** Files the agents had written survived, and so did the gitignored downloads; the agents' final summaries in their transcripts did not. Have every agent write its hand-back summary into a file it owns (e.g. `tools/out/<stage>-<agent>.md`), and commit finished work before starting the next batch.
- *(M0)* Rules primer written straight from the free official rulebook in one agent run; edition history (FFG RRG -> AMG Core Rulebook 2023 -> 2024-26 "new edition" with rolled cover, edge entry, 1000 points, 5 rounds) is in the primer's leak list.
- **Read the KB before proposing a stack.** The first strategy written for this project, before the KB review, proposed a pnpm monorepo and a 2D PixiJS client. The KB's proven recipe (one Vite + R3F package copied from the newest sibling, 3D from M3, Pages from `main`) replaced it. Ten ports' worth of tested decisions outweigh a fresh design.
- **The KB lives in sibling repos, not one place**, and the copies drift (README gotcha, 2026-10-28).
