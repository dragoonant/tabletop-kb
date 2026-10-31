# Three Kingdoms Tactics — living entry

Repo `dragoonant/three-kingdoms-tactics` (public), started 2026-10-31 from a **claude.ai cloud session**. Decisions: `PLAN.md` (D1-D12); rules: `docs/spec/10-rules.md`; battle: `docs/spec/11-battle-daxing-hill.md`; skin: `docs/spec/50-presentation.md`. **This entry is updated at the end of every milestone.**

## 1. Overview
- **The series' first original game (not a port).** It is a spiritual successor to Koei's Dynasty Tactics (2002) and Dynasty Tactics 2 (2003, both PS2; Japanese title Sangokushi Senki). The ruleset is our own, so "fidelity is the product" (README rule 2) becomes "the spec is the product": rules are written with ids first, every ambiguity is a `RULING:` line, and balance changes need a sim or bench result.
- Owner decisions 2026-10-31 (do not re-ask): browser/TypeScript on the sibling stack (D1); first milestone one playable battle (D2); art direction "from the knowledge base", meaning MGSD figures (D3); presentation concept **war-council sand table** (D4); first battle **Daxing Hill**, Romance ch.1 (D5); push to `main` + Pages after each stage (D6).
- Defaults taken: square grid with 4 facings; side phases; signature **linked stratagems** (tag/`follows` chains of up to 4 links with a sworn-brother bond bonus); historical names from the public-domain novel, with no Koei names, art or UI.

## 2. Donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Config (vite, tsconfig, playwright `PW_PORT`, deploy.yml) | warmechforge (public, cloned anonymously) | Patterns only; Vite 8/rolldown folds three into the r3f chunk |
| Engine contract (pure step, never-empty legalActions, query.* owns numbers, sfc32 replay, sim invariants) | KB build recipe | Written fresh against our own rules |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff + KB review | 2026-10-31 | not measured | Two question batches (3 + 4); the art answer was "check the KB" |
| M0 scaffold + specs | 2026-10-31 | ~0.07M Sonnet + coordinator | Scaffold agent ran while the questions were open (rule 20). Pages failed at "Configure Pages" because Pages was not enabled on the new repo; the owner must enable Source: GitHub Actions |
| M1+M2 data + engine | 2026-10-31 | ~0.29M (1 Sonnet, ~25 min) | 183 rule-id tests, golden + replay, sim 200 games with 0 invariant failures; 17 rulings. Random play never reaches a 4-link chain (covered by a hand-built test) |

## 4. Lessons for the series
- **A new repo's first Pages deploy fails at `actions/configure-pages`** until Pages is enabled with Source "GitHub Actions"; the default GITHUB_TOKEN cannot enable it. Ask the owner at kickoff.
- **Original games need a spec with rule ids before code.** Writing `10-rules.md` with ids and numbers let one Sonnet agent build the whole engine in one pass, logging 17 rulings instead of blocking.
