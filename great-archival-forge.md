# Great Archival Forge (Grand Archive TCG) — living entry

Repo `dragoonant/great-archival-forge` (public), started 2026-10-30 from a **claude.ai cloud session**. Decisions: `PLAN.md` (D1-D11 at kickoff); rules: `docs/rules.md`, `docs/rulings.md`; sources: `docs/sources.md`, `docs/data-sources.md`; rights: `docs/rights.md`; donor map: `docs/PORTING.md`. **This entry is updated at the end of every milestone.**

**Status (2026-11-03): paused, will resume** (owner, 2026-11-03). The repo has only its initial commit (2026-10-30); nothing in the plan below has been built or pushed. The kickoff decisions stand, so the next session starts from them and from the Xross Forge scaffold.

## 1. Overview
- Grand Archive: an English-language TCG from Weebs of the Shore. Each player has a champion that levels up through a lineage (level 0 spirit, then levels 1-3), a main deck and a material deck; cards cost memory or reserve; 13 elements (official card API option list, 2026-10-30).
- **Official card API found at kickoff**: `https://api.gatcg.com/cards/search` and `/option/search`, public JSON, no key (probed 2026-10-30). Card fields include `cost_memory`, `cost_reserve`, `level`, `life`, `power`, `speed`, `durability`, `element`, `classes`, `legality`, `effect_raw`; sets carry a `prefix` (e.g. `PRDSD`).
- Owner decisions 2026-10-30 (do not re-ask): first slice = **four starters**, `PRDSD` (Dante vs Lorraine, 2026-08-21) and `DTRSD` (Ciel vs Diana, 2025-07-25) (D1, the owner chose both pairs over the recommended single pair); look = **living archive vault** (D2); public Pages (D3); art and audio on the owner's PC local studios (D4); then **ten competitive decks, one per distinct champion lineage** (D5); overnight budget about 9M tokens (D6).

## 2. Donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Infra, engine contract shape, ability-as-data ops, UI modules, sim, replay, art/audio pipelines | Xross Forge `d849223` (lorecannae infrastructure) | Structure only; no Xross skin (owner rule 21). Map: `docs/PORTING.md` |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff + KB review | 2026-10-30 | not measured | Plan proposed and approved; two question batches (scope, look, visibility, rendering; budget, Pages, PC, deck selection) |

## 4. Lessons so far
- *(kickoff)* **Ask for every overnight approval in one batch before the owner sleeps**: budget, a repo setting the session cannot change (GitHub Pages was off: `has_pages: false` in the repo metadata, and no MCP tool enables it), the Remote Control folder for GPU work (`list_computer_folders` was empty, and `request_computer_folder` can only be approved by a person), and the deck-selection rule.
