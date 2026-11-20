# Stellar Derelict — living entry

Repo `dragoonant/StellarDerelict` (public since 2026-11-13; live at https://dragoonant.github.io/StellarDerelict/),
started 2026-11-12 from a **claude.ai cloud session**.
Decisions: `PLAN.md` (D1–D9). Rules: `docs/spec/10-rules.md` (rule ids, balance B-0..B-8, the boarding run R-1..R-5,
rulings); missions in specs 11–13 with their own balance tables. Look: `docs/spec/50-presentation.md` (the Molt seat is
MOLT-1..5). Audio: `docs/spec/60-audio.md`. Art: `docs/spec/70-art.md` (ART-1..9). State: `STATUS.md`.

## 1. Overview
- *(added 2026-11-19)* **Owner's verdict, 2026-11-19, the day M7 to M10 were merged and went live: "This is one of the best games we've developed."**
  The owner gave no reason, and the session does not know whether the merged build had been played when it was said.
  Section 5 lists what this build did, as the session's reading. The day before, on five before and after pictures of
  the M10 wreck look: "Looks right" (2026-11-18).
- **Live:** https://dragoonant.github.io/StellarDerelict/ (public since 2026-11-13). Owner after the first playtest with
  figures and audio, 2026-11-13: "I'm super impressed with my playtest so far. This is how you get a working prototype."
- **An original game, not a port.** The owner asked for "a spiritual successor to a board game" and confirmed the guess
  (the classic armoured-marines-versus-aliens corridor game). Owner, 2026-11-12: "I love the setting - aliens vs heavily
  armored marines, let's keep that." The premise carries over; the names, numbers, missions and look are written fresh
  (PLAN D1). As with three-kingdoms-tactics and wasteland-behemoths, "the spec is the product".
- Owner decisions 2026-11-12 (one batch of four questions): 3D board (D3); Wardens vs AI first, playable aliens later
  (D4); presentation concept "scanner ghost-map" (D5); push to `main` and Pages after every stage (D6).
- Shape: five Wardens (4 AP each plus a shared command-point roll) against the Molt, who arrive at ducts as pings that
  hide one to three stalkers until a Warden sees them. First mission "Dead Reckoning": unseal the archive at a terminal,
  take the core, carry it back to the airlock within 16 rounds.
- Rules of its own: repeater **heat** (a shot adds 1, locked at 4, cools 2 a round, vent for 1 AP) instead of random
  jams; hardsuit **plating** (the first lethal hit breaches, the second kills); **ship systems** at terminals
  (seal/unseal bulkheads, lights, a one-use purge); a timed Warden phase as a client rule.

## 2. Stack and donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Config (Vite 8, React 19, three 0.186, R3F 9, drei 10, zustand 5, TS 7 strict, Vitest 5, Playwright pinned 1.63.0, `PW_PORT`) | three-kingdoms-tactics | `base: './'` as in wasteland-behemoths |
| Deploy | wasteland-behemoths / bossforge route | Gates, then force-push `dist/` to `gh-pages`; first run green in under a minute |
| Engine contract | KB recipe steps 2 and 4 | Written fresh: `step` never throws, plain-JSON state, sfc32 in state, `legalActions` never empty, `view(state, seat)`, `query.*` |
| Camera and picking (rules 25, 27) | assembly-forge `src/client/board/mapController.ts`, `cameraModel.ts`, `viewApi.ts` | Adapted to a square grid |
| Save (rule 22) | Rule 22 text | Envelope with snapshot + actions; key `stellar-derelict-save` |
| Presentation | none (fresh) | "Scanner ghost-map": teal on black, square corners, mono type; must-not-look-like table in spec 50 |

## 3. Milestone log
| Milestone | Date | Agents | Notes |
|---|---|---|---|
| Kickoff + KB read | 2026-11-12 | coordinator | One question batch (4). The owner said "Go" after the plan |
| M0 scaffold + specs | 2026-11-12 | coordinator | Specs 00/10/11/50 and the mission map written by the session model before any agent ran |
| M1–M2 data + engine | 2026-11-13 | 1 Sonnet | 97 tests by rule id, golden round, sim with invariants. A container restart killed the agent after the code was written; the coordinator finished balance and the golden fixture |
| M3 first playable | 2026-11-13 | 1 Sonnet (~23 min, ~0.3M tokens) | Screens, board, HUD, director, scripted Molt bot, autosave + Continue; 14 e2e tests covering rules 8, 22, 24, 25, 27 and the timer |
| M4 Molt AI + Warden policy | 2026-11-13 | 1 Sonnet, two runs (~0.9M tokens) | Utility Molt AI in a worker, tiers, bench gates; then a utility Warden policy and re-tune (B-6..B-8). 130 unit tests, 16 e2e |
| M5 figures (GPU PC) | 2026-11-12 | session model only | 44 Flux klein concepts (image edit with the style reference, about 26 s per 4), one re-roll (the sergeant's maul never appeared until the weapon line led the prompt); Hunyuan 2.1 shape / 2.0 paint / finalize for 11 models in about 25 min of GPU; props decimated at the shape stage; gallery gate on close-ups |
| M6 audio (GPU PC) | 2026-11-12 | session model only | 79 Audio Studio jobs (Stable Audio Open 5 s each, ACE-Step 10 s a track, Qwen voice design 8 s a line), about 20 min of GPU; three takes for two effects, one layered transient; levelled by kind; enabled, not verified by ear |
| Pages live, first owner playtest | 2026-11-13 | session model only | Repo made public; Pages had been left on the "GitHub Actions" build type, so the gh-pages pushes never served (one `PUT` to the Pages API fixed it). The owner played the live build and approved the prototype |
| Visor mode, TOP DOWN (owner requests) | 2026-11-14 | session model only | First-person helmet view with brackets and engine odds; a north-up top-down button. Owner: "It works great." |
| M8 audio through ElevenLabs | 2026-11-15 | session model only (PC session) | The owner handed over a one-day ElevenLabs key ("make it as fully featured as possible"). 121 files in one background run (61 effects at 10 credits a second, 7 tracks at 12.5 a second, 53 lines at a credit a character, about 11,400 of the Starter plan's 40,512 by the subscription counter; four near-silent takes re-rolled); six voices designed from the manifest descriptions with the characters' own lines as preview text and adopted unheard; carrier lines per Warden, a briefing narration per mission, two new effects. Not verified by ear |
| Merge, live, owner's verdict | 2026-11-19 | session model only (PC session) | Pull request 1 of `dragoonant/StellarDerelict` (M7 to M10, five commits) merged into `main` as a merge commit on the owner's "Yes."; the deploy workflow ran the gates and published; the session opened the live site and the game reported 40 images enabled and none failed. Owner the same day: "This is one of the best games we've developed." Audio still not verified by ear |
| M10 the wreck pass (owner feedback) | 2026-11-15 | session model only (PC session) | Owner on M9: "The ship looks too plain, lots of blue, it's supposed to be a derelict ship, ruined walls, fires, claw marks etc". 25 more Flux jobs (about 9 min): board textures made again as a wreck and shown in colour (lit where seen, a cold ghost where only mapped), weighted ruined variants, burning breaches with shader flames and light pools, claw-mark and debris decals, new title and mission stills. PLAN D9, spec 70 ART-3 rewritten and ART-9 new. Owner on the before and after pictures, 2026-11-18: "Looks right" |
| M9 graphics pass (Flux Studio) | 2026-11-15 | session model only (PC session) | Owner: "Let's do a graphics pass too. Use evilaegis. Flux. And Gemini if needed." 28 images in one background batch (112 candidates, about 12 min of GPU, no failures, no re-rolls; Gemini not needed): 9 greyscale board textures tinted with the state colours, 8 faces (image edits of the figures' picked concepts), 8 stills shown as sensor feeds, 3 scar decals; scars tallied from engine events; `art.html` review page; a link-preview card. Spec `docs/spec/70-art.md` (ART-1..8). Checked on the real GPU by headless Chromium on D3D11. The owner saw it and asked for the wreck pass (M10) |
| M7 missions, Molt seat, boarding run | 2026-11-14 | session model only (PC session, about 5 hours) | Two more missions (Cold Berth, Last Light) with their own balance tables; the Warden policy made mission-generic through `missionPlan` and `aiHints` in the data (Dead Reckoning's sim count identical before and after); a playable Molt seat against the squad AI; a three-mission boarding run with survivors carried over; a debrief tallied from events; a `cpSpent` event. 204 unit tests, 27 e2e |

## 4. Lessons for the series
- *(added 2026-11-19, stellar-derelict)* **Ask about a look with before and after pictures and one question, and
  record what the answer was an answer to.** After M10 the session sent five side-by-side pictures (the first pass on
  the left, the wreck on the right: map, close map, visor, title, briefing) and asked one thing, "Is the wreck look
  right, or should I push it further?" The owner answered "Looks right" in one message without opening the game.
  `STATUS.md` records it as an approval of the pictures, not of play, so the next session does not read it as more.
- *(added 2026-11-15, stellar-derelict M10; this corrects the M9 lesson below)* **Do not put the whole scene under the
  interface colour, and make damage the subject of the prompt.** M9 shipped clean greyscale plates multiplied with the
  HUD's teal so every state read survived; the owner's answer was "too plain, lots of blue, it's supposed to be a derelict
  ship, ruined walls, fires, claw marks". What worked: colour textures lit by brightness (lit where the squad sees, a dim
  cold ghost where it only has the map: the state read moves from hue to light), rarer ruined variants by weight, damage
  named as the subject ("four long deep parallel claw gouges raked diagonally right across the plate", "burnt out by an
  old fire: blackened in a tall fan shape", "a ragged hole ripped through the middle"), and live fire. The setting's
  word ("derelict") is a brief for the art, not only for the title: check the first textures against it before wiring.
- *(added 2026-11-15, stellar-derelict M10)* **Scenery fire must not look like the rule's fire.** The game has a
  "burning square" state. Wreck fires stand in walls (which nobody can enter), their light is a soft round pool that
  crosses square edges, and the rule state keeps its hard-edged square fill. Ruined walls are painted ruined but keep
  their full shape: a gap the eye can see through would promise a line of sight the rules do not give.
- *(added 2026-11-15, stellar-derelict M10)* **A material ref on one face of a multi-material box updates one face.** M9
  attached six materials to an instanced wall box and kept a ref to the first; the per-frame colour change reached one
  side and the other three kept their first colour, unnoticed while everything was dark teal. Build the materials once
  and pass the array (`[side, side, top, top, side, side]`), so the four sides are one object.
- *(added 2026-11-15, stellar-derelict M9; superseded by the M10 lesson above for anything meant to look like a place)* **Generated textures go in as greyscale multipliers, not as pictures.**
  Publish each board texture greyscale, stretched and levelled to one mean (0.5), load it as plain numbers
  (`NoColorSpace`) and multiply it with the colour the flat surface already had, times one gain. Every state read the
  game had (seen, mapped, sealed, torn, purged) survives untouched, one tint gain suits all nine textures, and the art
  can be switched off (`?art=none`) to the exact old look. Loading them as sRGB pictures made everything too dark and
  needed a different gain per texture.
- *(added 2026-11-15, stellar-derelict M9)* **A graphics pass on a finished game is mostly wiring, and the generation
  is the cheap part.** 28 Flux jobs took 12 minutes in the background; the manifest, the publish recipes, the loader, the
  screens, the tests and the docs took the rest of the session. Start the batch first (one command, candidates to a
  gitignored folder), write the client while it renders, publish picks kind by kind as each sheet lands, and look at the
  game after each kind (KB rule 13).
- *(added 2026-11-15, stellar-derelict M9)* **Make a face from the concept the figure was built from.** Each Warden
  portrait is a FLUX.2 klein image edit of the picked concept in `art/concepts/picks.json` ("a close-up head-and-shoulders
  portrait of the same armoured trooper ... the same helmet, pauldrons, pack and paint"), with one line per character for
  what makes it that one. Five distinct, matching busts in 4 of 4 candidates each, none re-rolled.
- *(added 2026-11-15, stellar-derelict M9)* **Look at a real-GPU build without the owner: Playwright's Chromium with
  `--use-angle=d3d11 --enable-gpu --ignore-gpu-blocklist`** renders on the PC's card headless (the renderer string said
  RTX 5080), so the "only seen on SwiftShader" caveat can be closed from a PC session. Drive the screens through the test
  hooks, save PNGs at desktop, phone landscape and phone portrait, and read them.
- *(added 2026-11-15, stellar-derelict M9)* **Re-run the unit tests after the last data edit of a stage, not before it.**
  M8 changed one sound's `promptInfluence` during re-rolls after the unit gate had passed; the commit went out with a
  failing test and a status line that said 212 passed. M9 found it. The gate list is run once more as the last thing
  before the commit.
- *(added 2026-11-13, stellar-derelict)* **The gh-pages push route still needs one Pages setting.** The workflow
  force-pushed `dist/` to `gh-pages` four times with green runs, and the site was a 404: the repo's Pages source was
  the "GitHub Actions" build type (set when the repo was created), which only serves artifacts from
  `actions/deploy-pages`. After making a repo public, check `gh api repos/<o>/<r>/pages` shows `build_type: legacy`
  and `source.branch: gh-pages`; one `PUT` fixes it and the first build follows within a minute.
- *(added 2026-11-12, stellar-derelict M5)* **Check the facing convention of the gallery against the loader before
  trusting a "face the arrow" gate.** The cloud-written gallery said "+Z", the loader turned every model to -Z (the
  board's facing N), so a correct figure showed its back in "Front view". The wide grid is also too small to see a
  face at all: judge facing one model at a time (`?gallery=<slug>`), and write the arrow from the board's facing table.
- *(added 2026-11-12, stellar-derelict M5)* **A textured Hunyuan mesh cannot be simplified afterwards.** Paint
  exports a triangle soup (30k vertices for 10k faces, every edge a UV seam), so meshopt's simplifier returns it
  unchanged. Prop budgets are met with `stage_shape.py --faces N` before painting; the optimiser only warns.
- *(added 2026-11-12, stellar-derelict M5)* **FLUX.2 klein image-edit copies the reference's props.** Handcuffs, a
  hose and a skull buckle from the style photo kept appearing; a long shared prompt body pushed the per-figure weapon
  line out of the picture (no maul in 4 of 4). Put the weapon line first in the per-figure text and name both hands.
- *(added 2026-11-15, stellar-derelict M8)* **A one-day API key is a budget problem first.** Before planning a
  regeneration, probe one request of each kind and read the `character-cost` header (ElevenLabs: effects 10 credits a
  second, music 12.5 a second, speech a credit a character, voice design about its preview text); a `--dry-run` that
  prints the estimate and a `--budget` stop turned 121 files into one unattended background run. Keep the key in the
  environment of that one command (`export KEY=$(cat scratchpad/key)`), never in a repo file; the dry-run test asserts
  the log never contains `sk_`.
- *(added 2026-11-15, stellar-derelict M8)* **Design voices from the manifest, with the characters' own lines as the
  preview text,** and record the adopted voice id in the manifest's cast table so every line of a speaker is one voice
  and a re-roll of one line matches the rest. Carrier lines per Warden (instead of one neutral "carrier" voice) cost
  twenty short lines and remove the only voice that did not belong to anyone.
- *(added 2026-11-12, stellar-derelict M6)* **Generated audio needs levelling before anyone listens.** Stable Audio
  Open takes ranged from -11 to -56 LUFS for the same prompt family (two of 54 files were effectively silent), and
  ACE-Step tracks from -13 to -28 LUFS with peaks over 0 dBFS. Level by kind in the measure pass (effects -18 LUFS,
  beds -24, music and voice -16), level gunshot-class sounds by peak so the crest gate still means something, flag
  files under -42 LUFS as failed takes, and re-roll with a seed offset rather than lifting them 30 dB.
- *(added 2026-11-12, stellar-derelict M6)* **Two ffmpeg traps in a measuring tool.** `-ac 1` / `-ac 2` rematrix with
  -3 dB coefficients, so a mono-downmixed stereo file reads 2 dB hot and an upmixed mono file 3 dB quiet: decode at the
  file's own channel count and mix in code. `alimiter` auto-levels to its ceiling by default (`level=false` to use
  it as a ceiling). And a dev server that just streamed a file holds it on Windows: retry the in-place rename.
- *(added 2026-11-12, stellar-derelict M5)* **Long creatures need their own footprint cap.** A 0.95-square cap sized
  the stalkers at half a Warden; 1.25 squares (tail overhang) brought them back to about 0.7 of one.
- *(added 2026-11-13, stellar-derelict)* **A container restart kills background agents but keeps their files.** The
  engine agent's code survived on disk, uncommitted; its hand-back report and its balance notes did not. Tell every
  agent to commit locally at checkpoints and to overwrite a progress report file after each one, and have the
  coordinator checkpoint-commit in-flight work to the feature branch (never `main`) when a stop hook asks.
- *(added 2026-11-13, stellar-derelict)* **In an asymmetric squad game, find out what kills the squad before tuning
  the clock.** Scripted Wardens won 23%. Two more rounds: no change. A lower alarm arrival rate: no change. A softer
  contact mix: +10 points but duller contacts. Removing the swarm's +1 melee bonus: 23% to 56% with the soft mix, 36.9%
  with the original mix (adopted). The sim's reason split (squad lost 69%, out of time 8%) pointed at melee from the
  first row.
- *(added 2026-11-13, stellar-derelict)* **When an agent's report is lost, the session model's read of the rules file
  against the spec is cheap** (about 800 lines) and doubles as the independent review the Legion Forge lesson asks for.
- *(added 2026-11-13, stellar-derelict)* **A cloud session may be refused push access to the KB repo** even when the
  repo is public and readable. Keep the entry as a draft file in the game repo and tell the owner.
- *(added 2026-11-13, stellar-derelict)* **Wall tops drawn with the same grid as the deck read as floor.** On a
  corridor board the walls must be the quietest surface; check the first board screenshot for "where can I walk".
- *(added 2026-11-13, stellar-derelict)* **Bench each scripted side against a random opponent before trusting any
  balance row.** The first scripted Wardens "won 36.9%" against the scripted Molt, and five balance rows were tuned on
  that. The M4 bench then showed a *random* Molt beating them 85%, all on the clock: in one-wide corridors the column
  faced itself and nothing cleared blockers. A utility Warden policy (formation, clearing blockers, flushing contacts
  round corners, a clock budget) beat random 100% with no time-outs, and the tier ladder came out at 73 / 43 / 24%
  Warden wins (recruit / regular / veteran, 400 games each) with no rule change. The earlier rows are kept in the spec
  but marked as measured with the weak policy.
- *(added 2026-11-13, stellar-derelict)* **A bench policy that actually uses every action finds client bugs.** The
  utility Wardens scorched often enough to show that the presented state never spent a scorcher charge.
- *(added 2026-11-14, stellar-derelict M7)* **When spawn points can be blocked, the spawn rate is not a balance lever.**
  Doubling arrivals (2 → 3 a round, alarm 3 → 4) changed the Warden win rate by under one point on two maps, and halving
  the alarm rate changed nothing: the sim's event counts showed 50–100 `pingHeld` events a game, because the scripted
  Molt parks contacts on their ducts and an occupied duct is not open (P-2). Count the held-over spawns before touching
  rates; on these maps the levers were geometry (how many lanes reach the squad's file unseen) and the start positions.
- *(added 2026-11-14, stellar-derelict M7)* **Make a scripted side mission-generic by moving its constants into the
  mission data, then prove it with an identical sim count.** The Warden policy carried Dead Reckoning's terminal ids
  and formation squares as constants. They became `aiHints` in the mission JSON plus a `missionPlan` derived from the
  terminals and sealed doors; the 400-game sim gave the same 171 wins before and after, so every earlier balance row
  still stands. New maps then only need hints (or none: the policy falls back to generic goals).
- *(added 2026-11-14, stellar-derelict M7)* **Geometry sets the difficulty of a corridor map more than its numbers.** An
  open hall with pillars: 0% Warden wins (flanks everywhere). Three lanes each way: 90% (nothing can approach a file
  that looks down every lane). Five by five lanes: 25%. Five by four: 49%, in band. For a spine map, two side doors into
  the one-wide spine took the AI squad from 46% to 25% on their own; removing them beat every number change.
- *(added 2026-11-14, stellar-derelict M7)* **A sim that takes a JSON override of the mission makes map tuning a loop of
  minutes.** `--override '{...}'` / `--override-file` (deep-merged into the registered mission) and `--roster a,b` (a
  run's short-handed squad) let five variants run in parallel without touching the data files; the adopted one is then
  written back and the rejected ones go into the mission spec's balance table with their numbers.

## 5. What this build did (the owner's verdict, and the session's reading of it)
Owner, 2026-11-19: "This is one of the best games we've developed." No reason came with it, so nothing in this section is the owner's. It is the
session's list of what this project did, each item taken from the log above, for the next game to copy and for the owner
to correct.

1. **The premise was the owner's and was kept; everything else was written as a spec.** "I love the setting - aliens vs
   heavily armored marines, let's keep that" (2026-11-12). Names, numbers, missions and look were written fresh with
   rule ids, and the tests carry those ids.
2. **It was playable on Pages on the second day, and every stage after that began with a sentence from the owner.**

   | Date | The owner | What followed |
   |---|---|---|
   | 2026-11-13 | "I'm super impressed with my playtest so far. This is how you get a working prototype." | The prototype with figures and audio was the base for everything below |
   | 2026-11-14 | Asked for a helmet view and a top-down button; then "It works great." | Visor mode, TOP DOWN |
   | 2026-11-14 | "keep going and finish out the rest of the plan." | M7: two more missions, the Molt seat, the boarding run |
   | 2026-11-15 | Handed over a one-day ElevenLabs key: "Make it as fully featured as possible" | M8: the whole soundtrack, a voice per character |
   | 2026-11-15 | "Let's do a graphics pass too. Use evilaegis. Flux. And Gemini if needed." | M9: textures, faces, stills, scars |
   | 2026-11-15 | "The ship looks too plain, lots of blue, it's supposed to be a derelict ship, ruined walls, fires, claw marks etc" | M10: the wreck pass, the same session |
   | 2026-11-18 | "Looks right" | Merge and deploy the next day |

3. **Nothing in the shipped build is a stand-in.** 11 generated figure models; 61 effects, 7 music tracks and 53 voice
   lines in six designed voices; 40 generated images (17 board textures, 8 faces, 8 stills,
   7 decals); three missions, both seats, a three-mission run, a debrief tallied from events.
4. **Balance was measured.** Each mission has its own table in its spec with the rejected variants and their numbers;
   each scripted side was benched against a random opponent; the tier ladder is 73 / 43 / 24% Warden wins.
5. **The one outright correction to the look was answered in the same session and shown as pictures.** M9 went out under
   the interface's teal; the owner's sentence became PLAN D9 and M10 the same day (25 Flux jobs, about 9 minutes).
6. **Cost.** Eight days from the first commit (2026-11-12) to the verdict (2026-11-19), 40 commits on `main` at the merge. Helper
   agents were used for M1 to M4 only (one Sonnet at a time); every stage after that was the session model alone. GPU time:
   about 45 minutes for figures and the first audio, about 21 minutes of Flux for the 2D art. ElevenLabs: about 11,400
   credits. Last gates: 238 unit tests, 31 browser tests, a 300-game sim with 0 violations.

Still open on the day of the verdict: the audio has never been confirmed by ear ([rules.md](rules.md) rule 9).
