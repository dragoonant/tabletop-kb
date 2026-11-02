# Recipe: no hitch when a 3D scene starts (three.js / R3F, and in general)

*(added 2026-11-01, three-kingdoms-tactics)* The owner's words (2026-11-01, Three Kingdoms Tactics PLAN D30): "when starting a cutscene, the game slows down tremendously ... we've had this problem in other games, and we need to record how to fix this for future games." **The KB had no earlier entry on this** (no project file mentions start-of-scene stutter, shader warm-up or renderer reuse), so the sibling cases are not recorded; if one turns up, add its cause here.

**Sources:** `three-kingdoms-tactics` commit `8222214` (merge `4f9e36d`); `docs/spec/51-battle-cutins.md` "Performance: warm-up and reuse"; probe `tools/perf/cutin-hitch.mjs` with `?perf=1`; guards `tests/e2e/cutin-warm.spec.ts` and `tests/unit/cutins-warm.test.ts`. The numbers come from headless Chromium with SwiftShader (no GPU), so read them as ratios.

**Result there:** the longest main-thread task at cut-in start went from 3.2-5.1 s to 0. The first draw went from 1.8-3.1 s of main-thread time to 8-50 ms. WebGL contexts stay at 2 for the whole battle; before, the baseline run grew from 1 to 9 (a new one per cut-in, never freed). There are 21 shader programs after warm-up, with no new ones during cut-ins. Cost: about +18 MB JS heap at the first turn and a held cut-in drawing buffer (about 33 MB at 1280x720 with 4x MSAA). The warm-up took about 35 s on SwiftShader; the estimate for a real GPU is 1-4 s, not measured on hardware.

**Root cause in that game:** `CutinView` mounted a fresh R3F `<Canvas>` for every cut-in, so each cut-in paid for a new context and full shader compilation, then threw them away.

**Check this first in any game:** grep for a `<Canvas>` or `new WebGLRenderer` that mounts conditionally (a cinematic, menu or minigame) and for `frameloop="never"` canvases created on demand.

**Symptom.** The game freezes for a moment, or for seconds, when a cinematic, cut-in or new scene starts. Players read it as "it's loading all the models".

**What causes it, roughly from most to least costly:**
1. **A new WebGL context per scene.** Mounting an R3F `<Canvas>` (or calling `new WebGLRenderer`) when the scene starts creates a context: the drawing buffers are allocated, and every program, buffer and texture starts from nothing. With software GL this alone took 1.0–2.4 s.
2. **Shader compile and link on the first draw.** three.js compiles a program the first time it draws a material variant with a given set of lights, and the link blocks the main thread at first use. Objects that become visible later in the scene (arrows, FX) compile mid-scene and cause a second, third... hitch.
3. **GPU uploads** of every geometry, texture and instance buffer the first frame uses.
4. **JS scene build**: procedural rigs, crowds, layouts and set dressing built on the main thread when the scene mounts (70–250 ms here).
5. **Lazy chunk load** of the scene code on first use.

**How to measure it (do this first):**
- Put `performance.mark`s around the trigger, renderer creation, scene build, first render and later renders, and run a `PerformanceObserver({ type: 'longtask' })` from page load.
- Record per scene start: trigger → first frame *shown* (the start of the second rendered frame: rAF is held back while the GPU is busy), the longest task in the first second, the first 30 frame intervals against the steady-state interval, and `renderer.info.programs.length` / `info.memory.geometries` / `info.memory.textures` before, during and after. Count WebGL contexts by wrapping `HTMLCanvasElement.prototype.getContext`, and shader links by wrapping `WebGL2RenderingContext.prototype.linkProgram`.
- Drive the real game in headless Chromium (SwiftShader) and compare **ratios** to the steady frame, not absolute ms. A CPU profile (CDP `Profiler`) shows where a stall sits: inside `getProgramParameter` / `getUniformLocation` it is shader linking; inside plain `uniformMatrix4fv` / `drawElements` it is command-buffer backpressure (the GPU is behind).

**Fixes, in order of payoff:**
1. **One renderer for the whole session.** Mount the scene canvas once (when the level loads), hide it with `visibility: hidden` (not `display: none`, so it keeps its size), and keep `frameloop="never"` while it is idle. Never create a context mid-play. Render the scenes as hidden groups ("slots") inside that one canvas and show only the active one.
2. **Warm up behind a loading moment** (briefing, deploy or intro), one item per idle callback:
   - Mount a sample of every scene the level can play, built from the level's real actors, plus a gallery of every character, troop kind and palette, and every ground or terrain type.
   - Call `renderer.compileAsync(slotGroup, camera, slotGroup)`. Make the slot visible for the synchronous part of the call: lights are gathered with `traverseVisible`, while materials are found with `traverse`, so hidden FX are compiled too.
   - Do one real draw of the slot to the canvas inside a 1×1 scissor. This compiles the shadow-pass programs and uploads the shared buffers and textures. Shrink the shadow map to 16×16 for that draw (map size is not part of a program), then dispose it.
3. **Make the program set small and fixed.** Give every scene the same light rig (pad with intensity-0 lights), the same shadow settings, fog and tone mapping, and share materials from caches. Then one warm-up covers every scene.
4. **Reuse, don't rebuild.**
   - Cache shared geometry and textures at module level and mark them as kept.
   - Keep expensive derived data (merged or baked crowd geometry) pinned for the level.
   - On scene unmount, sweep: dispose every geometry and texture under the scene's root that is not kept, and call `dispose()` on its `InstancedMesh`es, so memory returns to the baseline.
   - **Pin programs** (one extra `usedTimes` on each program in `renderer.info.programs`). Otherwise disposing the last material of a kind deletes a program that the next scene needs again.
5. **Prebuild the next scene** when the next scene is known before it plays:
   - when the player's action preview opens, or when the AI's choice is known;
   - if the simulation is pure, plan it from a speculative step;
   - build it into a hidden slot in idle time, compile it, and draw it once;
   - key it by the plan's data, so that confirming finds it, and the start costs one ordinary frame.
6. **Draw the first frame in the animation frame**, not in a layout effect. A draw outside rAF lets the next frame queue straight behind it on a busy GPU. To avoid a stale image meanwhile, clear the canvas when a scene ends, and fade the layer in from 0.

**Regression test (e2e, after warm-up):**
- Play one of each scene type, including a chained one and one triggered by the AI.
- Assert that `renderer.info.programs.length` and the `linkProgram` count do not change, and that no new WebGL context is created.
- Assert that `info.memory.geometries` and `textures` return to the warm baseline after each scene.
- Add a wall-clock budget: the first frame shown and the longest task at scene start are each ≤ about 1.5 × the steady frame interval.
- Add a unit test for the pool and cache: pinning, the sweep skips kept resources, and a prebuilt slot is handed over without a rebuild.

**Pitfalls:**
- **Compiling with the wrong lights.** The program key includes the number of lights of each type and the number of shadow-casting lights. `compile(scene)` with the live scene's lights *plus* the slot's lights, or with none, compiles variants that are never used, and the real ones still compile at first draw. Compile a slot against its own lights (`targetScene = slot`).
- **Render targets are a different variant.** Rendering the warm-up to a `WebGLRenderTarget` uses linear output with no tone mapping, so it compiles different programs from the ones the canvas uses. Warm up on the canvas itself, scissored.
- **`castShadow` toggles.** Turning shadow casting on or off for a light changes `numDirLightShadows` etc. and forces a recompile of everything. Turning it on for a mesh adds depth-material variants (front, back, double side; instanced) that only a real shadow pass compiles.
- **Per-instance materials** (`material.clone()` per mesh, `new Material` per mount) are fine for programs if the parameters that form the key are the same, but each material is extra JS state. Anything that changes the key creates a new program: a texture present or absent, `side`, `transparent`, `vertexColors`, a different `onBeforeCompile` source, or `customProgramCacheKey`.
- **No `KHR_parallel_shader_compile`** (SwiftShader and some phones): `compileAsync` cannot hide the link, so the warm-up itself blocks. Keep it behind a loading moment and do one item per idle slice.
- **Context loss.** On `webglcontextrestored` every program and buffer is gone. Listen for it and run the warm-up again.
- **React StrictMode double mount** (dev only). Effects run mount → cleanup → mount. Defer disposals and sweeps a tick and cancel them if the effect mounts again. Do not tear down shared pools in a cleanup that StrictMode will immediately undo.
- **Async reconciler commits.** R3F commits its own tree after the page's React commit. Set `visible` and "active" flags on the scene objects imperatively before the first draw, or the first frame draws an empty or unanimated slot.
- **Memory on phones.** A persistent second context keeps its drawing buffers between scenes (about w×h×(samples×8+4) bytes). Cap the warm pool to what the level can field, prebuild at most a few scenes, and free the pool when the level ends.

## Part 2: the whole scene is choppy on a phone (per-frame budget)
*(added 2026-11-02, three-kingdoms-tactics D32)* Source: the owner tested on an iPhone after the start-hitch fix: "still a ton of slowdown", and when asked where, "whole cut-in choppy". Game files: `src/client/figures/compact.ts`, `src/client/cutins/quality.ts`, `casterPolicy.ts`, `hud.ts`, `tools/perf/cutin-frame.mjs`, `tests/e2e/cutin-budget.spec.ts`, `cutin-quality.spec.ts`, and spec 51 "Performance: per-frame budgets and quality tiers" (merge `cc25c5a`).

**Check this first:** a smooth start (Part 1) does not mean a smooth scene. If it is choppy all the way through, count draw calls in the main pass and the shadow pass. In this game every cut-in was drawing 1,170-3,507 a frame, shadows included. The tiers below bring the peak down to 50-203 at Low and 308-542 at High.

1. **Measure what doesn't depend on the device.** Record draw calls and triangles for the main and shadow passes (wrap `shadowMap.render` to split them), plus the number of shadow casters. Time JS separately for update and render submit, both at 1x and under a 4x CDP CPU throttle. Before each timed frame, drain the GPU with a 1-pixel `readPixels`. Tag root objects (`userData.perf`) and group draws by tag to find the biggest group. Headless SwiftShader fps is meaningless; draw-call counts carry over to a phone.
2. **Kitbashed or procedural models are usually the cost.** Each small mesh is one draw per pass: a mounted hero here had about 110 meshes, and every one also cast a shadow. Make each figure one `SkinnedMesh` whose bones are its existing joint objects, with weight 1 per vertex (the same transform as parenting) and identity bone inverses. Then the animation code and the joint contract stay unchanged. Bake materials into vertex attributes (colour, roughness, metalness, emissive). Keep parts the code hides or looks up (weapons, an arrow node) as separate meshes. Cache merged geometry by its sources, and give each skinned figure a culling sphere that follows its pose. Merge static dressing per material. Result: about 110 draws became 4-5, with the same triangles, and no visible change (contact-sheet pixel diff of at most 0.03/255 mean).
3. **Shadows double the bill.** Choose casters per tier: all of them, then figures and stage, then named characters only. Keep each mesh's built `castShadow` value so the policy can be raised again.
4. **Turn `preserveDrawingBuffer` off** except for screenshot tools and tests. On iOS it forces a full-buffer copy every frame.
5. **One module owns the quality tiers.** MSAA and shadow type are fixed when the context or programs are created, so set them at canvas creation. Pixel ratio, shadow-map size, casters and particle counts can change live. Crowd size, background action and figure detail apply to the next scene built. Auto starts from the device (here, iOS or a touch screen with a short side of 820 px or less starts at Medium). It drops one tier when the median of the last 15 frame intervals is over 25 ms, remembers that in localStorage (inside try/catch), and never steps up mid-scene. Give a manual setting and a `?quality=` URL override. Warm every possible caster during the Part 1 warm-up, so a tier change never compiles a shader.
6. **Gate and show.** Add an e2e at phone viewport (390×844) that fails if any scene's peak draw calls, shadows included, exceed the tier's budget (here 300 for Low and 500 for Medium). Add an e2e showing Auto steps down with no new context. Ship an on-screen `?perf=hud` (fps, median and p95 frame ms, draw calls, triangles, tier) so the owner can read the real numbers on the phone. A cloud container cannot measure a phone.

7. **Count what the page draws, not only WebGL.** *(added 2026-11-02, three-kingdoms-tactics D33)* After step 1 to 6 the owner's iPhone still dropped to "what looks like 3-5 fps" on Low, exactly when the cavalry charged with "wind all around". The cause was the HTML overlay above the canvas: speed lines as a full-screen SVG through `feTurbulence` + `feDisplacementMap` that changed every frame, a depth-of-field `backdrop-filter: blur()` running most of the scene, and a whip-pan SVG blur on the whole canvas. WebKit rasterises SVG filters on the CPU, and a backdrop blur over a canvas re-samples it every frame. None of this shows up in `renderer.info`. The fix is an `overlay: full | lite` field on each quality tier: lite has no CSS, SVG or backdrop filter anywhere in the cut-in, and the speed lines become plain shapes with a fixed ragged edge, moved by a transform. Add an e2e that walks every beat at the lite tiers and fails on any computed `filter`, `backdrop-filter` or `<filter>` element. **Check this first** when a phone stutters on one specific effect: grep the overlay CSS and SVG for `filter`, `backdrop-filter` and `feTurbulence`. **Result on a real phone:** with steps 1 to 7 in place, the owner measured "near 60fps the whole time for multiple strategems" on an iPhone, using `?perf=hud` (2026-11-02). Part 1 alone and Part 2 steps 1 to 6 alone had each still left it choppy.

**Pitfalls:** instanced crowds with frustum culling turned off still cost draws every frame. Each skinned figure uploads a small bone texture every frame. A tier that removes every caster removes every shadow in some shots. A live step-down only fully applies from the next scene.
