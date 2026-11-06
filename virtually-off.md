# Virtually Off — living entry

Repo `dragoonant/virtually-off` (public, Pages at https://dragoonant.github.io/virtually-off/), started 2026-11-05 from a
session on the owner's PC. Decisions: `PLAN.md` (D1-D9); state: `STATUS.md`. **This entry is updated at the end of every
milestone.**

## 1. Overview
- **The series' first real-time action game:** a one-on-one 3D arena mech fighter played on an Xbox Series X controller.
  It is an original spiritual successor to Sega's Cyber Troopers Virtual-On (1995), with no names, machine designs,
  stages, music or interface art from it. The owner kept the pun title "Virtually Off" knowingly (2026-11-05, D5).
- Owner decisions 2026-11-05 (do not re-ask): modern pad layout plus a twin-lever toggle (D1); 6 tuned machines reused
  from assembly-forge (D2); a vs-CPU ladder plus training, no local two-player yet (D3); public repo plus Pages (D4);
  presentation concept "orbital proving ground" (D6); every overnight GPU run approved (D7); 3 arenas (D8).
- Asked at about 23:00 for "a prototype game that i can play tomorrow morning". It was built overnight in one session,
  with one Sonnet agent for the GPU assets running in parallel.

## 2. Donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Machines (rigged GLBs, 8 clips: idle, walk, jump, fly, melee, shoot, hit, destroyed; 17-bone shared skeleton) | assembly-forge `public/assets/models/u*.glb`, `docs/figures.md` | Copied as-is, all 15; 6 enabled. "fly" plays for dashes; the chest bone is turned toward the target after the mixer runs |
| Portraits | assembly-forge `public/assets/portraits` | The select tiles and versus art |
| Normal smoothing | assembly-forge `src/client/board/smoothNormals.ts` | Needed for Hunyuan meshes |
| Studio APIs | [local-ai-studios.md](local-ai-studios.md) | The agent brief pointed at it; no other doc was needed |
| Everything else | written fresh | Plain three.js + TypeScript, no React: a fixed-step action loop does not need R3F |

## 3. Milestone log
| Milestone | Date | Tokens | Notes |
|---|---|---|---|
| Kickoff | 2026-11-05 | — | Two question batches (4 + 4), then "Go" |
| Overnight prototype | 2026-11-06 | coordinator + 0.19M Sonnet (assets, 30 min) | The playable game, 3 arenas, ladder with Continue, training, 4 e2e tests, deployed. The asset agent produced Flux skies and textures, 4 Hunyuan props, 7 music tracks, 26 effects and 15 announcer lines in one run, then stopped every studio |

## 4. Lessons
- **A hidden Browser pane throttles `requestAnimationFrame` to about 1 fps**, so held keys and timed presses go wrong when
  the game is driven through it. Expose a deterministic hook (`window.__voff.advance(sec)` steps the fixed 60 Hz sim and
  draws one frame) and test through it; headless Playwright runs at full rate.
- **Polling input misses taps shorter than a frame** (Playwright's `keyboard.press`, and quick real taps). Record
  keydowns in a per-frame "taps" set that is cleared at the end of each frame.
- **A CPU-vs-CPU hook** (`__voff.autopilot(level)`) makes a whole match an e2e test and a balance probe: between two
  Veteran CPUs a round lasted about 20 s on the first pass.
- **Additive glow and fog:** additive `MeshBasicMaterial` keeps `fog: true` by default and turns into a solid wall of fog
  colour at a distance. Set `fog: false` on every additive effect.
- **Stacked additive explosion particles white out the screen** under bloom. Darken the fire toward deep red before
  adding, keep the flash sphere under 0.7x the radius, and keep point lights at about 14 x radius.
- **Smoke drawn with a "cools from white-hot" tint reads as white clouds.** Give smoke and glow different tint curves.
- **Flux has no 2:1 aspect**, so the agent made the panoramas at 16:9 2 MP, stretched them to 2048x1024 and blended the
  wrap seam (`tools/gen/pano.py`). The horizon sits a little low.
- **Image-to-3D props have their own long axis:** turn them to lie along the long side of their collision box before
  scaling, or a barricade stretches sideways.
- **Gamepad presses may not unlock Web Audio** (they are not a user activation in every browser), so the title asks for a
  click if no sound plays.
