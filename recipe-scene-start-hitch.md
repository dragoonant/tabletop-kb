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
