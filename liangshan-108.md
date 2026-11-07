# Liangshan: 108 Stars — living entry

An original browser strategy game set in the public-domain novel *Water Margin*, started 2026-11-07 from a **claude.ai cloud session**. It is a spiritual successor to Koei's *Bandit Kings of Ancient China* (1989), not a port. Until the owner creates its own repo (suggested `dragoonant/liangshan-108`), it lives on the orphan branch `claude/inspiring-hypatia-73p6th` of `dragoonant/three-kingdoms-tactics`, which holds only this game (its PLAN D1). **This entry is updated at the end of every milestone.**

## 1. Overview
- Owner decisions 2026-11-07 (its PLAN D1-D8, do not re-ask): new repo created by the owner; the first playable is the **full map at once**; presentation concept **outlaw hideout ledger** (lantern-lit reed-marsh map on oiled paper, heroes as wanted posters, ink stamps for orders); **all 108 heroes** in the first playable; a deadline that is always visible and set by difficulty; solo vs AI; specs + data + engine overnight on the session branch; working title "Liangshan: 108 Stars".
- Defaults taken (its PLAN D9-D15): the sibling stack, hex battles (the square-grid sibling is three-kingdoms-tactics), the KB engine contract, the three-kingdoms-tactics IP posture (novel names, our prose, no Koei names, numbers or UI), house figure style, rules 22 and 24-27 from the first playable.
- **Kickoff began with complaint research** (owner, 2026-11-07: "Find the problems that people complained about from the original game so we can fix those in our release"). 13 complaints (C1-C13) are in its `docs/research/original-complaints.md`, each with a source, and every one must be answered by a rule id in `10-rules.md` (its PLAN D15). The main ones: a long Popularity grind before the villain can be attacked (C1), a hard deadline (C2), the villain escaping battles over and over (C4), opaque systems (C5), an RPG layer that did not matter (C6), slow battles with opaque fatigue (C7), messages that vanished before they could be read (C8), surprise revolts (C9), obscure saving (C10), and a Japanese-only modern re-release (C12).

## 2. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff: research + questions | 2026-11-07 | not measured | Complaint research from 6 readable sources; two question batches of 4; the owner chose the bigger scope on two of them (full map, all 108 heroes) |
| M0 specs + M1 data (2 Sonnet in parallel) | 2026-11-07 | running | A frozen data contract in the shared brief (`docs/briefs/overnight-2026-11-07.md`: hero, court and map record shapes, closed skill list) lets the spec agent and the data agent start together |

## 3. Lessons for the series
- *(added 2026-11-07, liangshan-108)* **For a spiritual successor, research the original's complaints before the first question batch.** A complaint table with sources and ids turns "make it better than the original" into requirements that rules can cite, and it showed which mechanics people loved and must keep (sworn brotherhood gated by personality).
- *(added 2026-11-07, liangshan-108)* **A game without its own repo yet can live on an orphan branch of a sibling repo** (`git worktree add --orphan -b <branch> <path>`, git 2.42+). The branch holds only the new game, so it moves later with one `git push <new-remote> <branch>:main`, and the sibling's `deploy.yml` (on `main` only) never fires for it.
