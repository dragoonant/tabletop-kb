# Xross Forge (Xross Stars) — living entry

Repo `dragoonant/xross-forge` (public), started 2026-10-29 from a **claude.ai cloud session**. Decisions: `PLAN.md` (D1-D15); rules: `docs/rules.md`, `docs/rulings.md`; sources: `docs/sources.md`; rights: `docs/rights.md`; donor map: `docs/PORTING.md`. **This entry is updated at the end of every milestone.**

## 1. Overview
- Xross Stars (クロスタ): a Japanese TCG from Brave group, developed by Game & Co. and SAMURAI KOBO, released 2025-08-22. Cards are real VTubers and streamers (VSPO!, Crazy Raccoon, Neo-Porte, REJECT). Each player has 4 two-sided leaders that awaken when they down an enemy leader, a 50-card deck of attack and memoria cards, and a 5-card tactics deck. PP grow 3/4/5 by round; best of 3 rounds, or a one-round quick match (PLAN D1, `docs/rules.md`).
- The owner called it "Xross Gates" at kickoff; no game of that name exists, and the owner confirmed Xross Stars (2026-10-29).
- Owner decisions 2026-10-29 (do not re-ask): real names with our own generated art of each avatar, no cloned voices (D2); **scaffold from lorecannae** over GRAND LINE (D3, owner's suggestion after a side-by-side); **Gemini image API and ElevenLabs run from the cloud session** with keys as environment secrets, not the PC studios (D4, D5); **$25** art and audio budget for the first slice (D6); esports-broadcast look (D7); first slice = the original starters ST01 vs ST02 (D8).

## 2. Donor map
| Subsystem | Donor | Notes |
|---|---|---|
| Infra (ns, rng, harness, test runner, gate, check-pages, stamp-assets, serve) | lorecannae `9c8016d` | Ported in M0; namespace `XS` |
| Engine contract, ability-authoring guide, UI modules, sim, replay, art/audio tools | lorecannae | ADAPT in M2-M6 per `docs/PORTING.md` |
| Effects layer (attack arrow, K.O. burst, spotlight, turn ribbon), arena, bug report | GRAND LINE `b816d3c` | Closest game shape: a Japanese leader TCG with a pay-per-card resource |

## 3. Milestone log
| Milestone | Date | Tokens (actual) | Notes |
|---|---|---|---|
| Kickoff + KB review | 2026-10-29 | not measured | Two question batches; scaffold switched from GRAND LINE to lorecannae on the owner's question |
| M0 sources, rules, rights, scaffold | 2026-10-29 | ~0.55M subagent (rules 0.19M on the session model; rights 0.16M and scaffold 0.19M on Sonnet) plus the coordinator | Three agents in parallel with disjoint files; coordinator did hygiene, API discovery, decklists, PLAN; gate green in a detached worktree |
| M1 card data (ST01/ST02) | 2026-10-29 | 0.13M (1 Sonnet) | 50 cards generated from the API dump + hand-written English text; validator self-test with 29 mutations; the agent caught a wrong cross-check claim in the coordinator's docs |
| M2 engine + rules review | 2026-10-29 | 0.71M (engine 0.41M Sonnet; read-only reviewer 0.30M session model) | Contract frozen first and signalled by a file; 145 tests, 200-game sim clean; reviewer found 0 WRONG (a small ruleset plus FAQ-checked rulings), 2 RISKs for future cards |
| M3 first playable client | 2026-10-29 | 0.42M (1 Sonnet) | Built in parallel against the frozen contract; e2e 172/172 incl. a whole quick match by clicks and six viewports; integrated in one commit gated in a clean worktree |
| **Total to playable vs random bot (M0-M3)** | 2026-10-29 | **~1.8M subagent tokens** plus the coordinator | Kickoff estimate was 2.5-3.5M to playable vs AI; M4 AI still to come |

## 4. Lessons so far
- *(M0)* **Grep the publisher site's JS bundle for API hosts before planning data entry.** The Next.js chunks of xross-stars.com named `api.xross-stars.com/v1/cards`, `/faq` and `/cards/restrictions`: an unauthenticated JSON API with every card's stats, printed text and awakened stats, plus 136 official FAQ entries. Filters are singular (`product=ST01`, `color=red`); `limit=100&page=N` pages. This replaced the image-reading and fan-bundle routes Legion needed (README gotcha, 2026-10-29).
- *(M0)* **Image-only PDFs with CID fonts**: `pdftotext` returns nothing and `pdftoppm` prints font errors but still renders legible pages. At 160 dpi an agent read all 19 pages of the Playing Manual by eye. Check one page image before handing them off.
- *(M0)* **Starter quantities came from the product page's card-list images**, cross-checked: each list sums to 50 and every API `is_ace` card is x2. (The coordinator first claimed the x2 cards were exactly the ACE cards; the M1 agent found two non-ACE x2 cards, and full-size crops confirmed the counts. Verify a cross-check claim before writing it down.) The ST01/ST02 page lived at `/product/st01-02`, not `/product/ST01` (404). Find the page through a web search when the obvious slug fails.
- *(M0)* **Give the rules agent the official FAQ from the start.** It wasn't in the brief; the coordinator's check afterwards confirmed 4 of the 7 open rulings and **reversed one default**: R-025 had awakening once per multi-attack card, but FAQ #81 says after each downing attack.
- *(M0)* **Starters can be illegal as sold.** エナジーチャージャー was banned on 2026-07-13 but ships in both original starters (PLAN D15: play them as printed).
- *(M0)* The Wayback Machine resets connections from the cloud session; affiliation tags exist in the card API's tag list but not on each card, and no tag filter works (PLAN D13: a hand table).
- *(M0)* The session's stop hook asks to commit untracked files while background agents are still writing them. Don't commit half-written agent output to quiet it: commit each agent's files by explicit path once it hands back and its gate passes.
- *(M2/M3)* **Signal the frozen contract with a file and start the UI on it.** The engine agent wrote `tools/out/m2-contract-ready` when `docs/ENGINE-API.md` was complete; a background `until [ -f … ]` wait woke the coordinator, which then launched the UI agent. The UI was built against the contract while the engine was still being written, and integration needed no engine changes. Only additions were allowed after the freeze, each logged at the bottom of the contract.
- *(M2)* **Back up unreviewed agent work without touching the shared index**: build a commit through a temporary index (`GIT_INDEX_FILE=<tmp> git read-tree HEAD && git add -A && git commit-tree $(git write-tree) -p HEAD`) and force-push it to a backup branch. The agents' working tree and the real index are untouched. Deleting that branch afterwards was refused by the session's git proxy ("remote end hung up"), so expect to leave it for the owner.
- *(M2)* **The rules review found 0 WRONG on a small ruleset whose open rulings were checked against the official FAQ first** (compare Legion's 29). Choose the reviewer by budget: on Xross Forge it cost 0.30M and confirmed the slice rather than fixing it.
