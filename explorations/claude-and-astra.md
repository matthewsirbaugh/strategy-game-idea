# How Claude and Astra work together

- Feeds: AGENTS.md (where the agreement graduates once settled)
- Status: decided 2026-10-10; the core rules are in AGENTS.md under "Claude and Astra".
- Next action: none for the agreement. The requests table below stays in use.

## The question

Bryson works with two agents on this project, Claude and Astra. How do they divide the work,
talk to each other, and share one repository without getting in each other's way?

## What Bryson has said (2026-10-10)

- He'll keep using both. Claude is saved for important and creative work and is the central
  project architect; Astra is the workhorse.
- Astra makes all the reference and concept images, and will build a Godot program that shows every
  model for review in 3D, by itself, from every angle.
- The two need to agree on how to work. Claude drafts; Bryson has Astra review it and propose
  changes; the two work out between them how best to communicate.

## The agreement (Claude's draft, revised with Astra's five clarifications; adopted 2026-10-10)

### Roles

| Claude | Astra |
|---|---|
| Architecture, rules and game code, with Bryson | Reference and concept images, from Claude's briefs and Bryson's direction |
| Briefs: what each asset is meant to be | Tools Bryson assigns, starting with the model viewer |
| Models: Meshy, cleanup in Blender, records in `game/assets/` | Routine code and content tasks Bryson or Claude hands over |
| Keeping the docs and the board current | Reviewing Claude's drafts that touch his work |

### One source of truth

Everything either of us needs lives in the repository: AGENTS.md, the board, the exploration files,
the contracts. Neither of us relies on a private memory the other can't read. Start every session
by reading AGENTS.md and the board.

### Images: candidates and finals

Added 2026-10-11 at Bryson's request, after Claude reviewed a superseded candidate of the EV charger
while Astra's approved version was already delivered.

- `art/sources/<category>/<id>/01-main.png` (and `02-side.png`, ...) is the only final. Claude models
  from there and nowhere else. A file in `art/concepts/` is a candidate, never a final.
- Candidates go in `art/concepts/<batch>-review-<date>/`, versioned (`-v2`, `-v3`), with a README
  whose first line under the title is its status: `candidates, awaiting Bryson's pick`, or
  `delivered: <files> approved by Bryson`.
- Whoever is with Bryson when he picks copies his choice into `art/sources/`, unchanged: Astra if
  he picks in Astra's chat, Claude if he picks in Claude's. Then they set the request's status to
  `delivered`, naming the source files.
- Claude reviews or models a batch only after reading its request row and the review README's
  status, at the latest commit. A request still being worked on (several commits in a row) isn't
  delivered until its status says so.
- When Bryson asks Claude for a review of candidates, Claude reviews every version in the folder
  and says which one it reviewed.

### Talking to each other

We can't message each other directly, so Bryson relays and the repository carries the content:
- A request goes in the Requests table below: who it's for, what, where the result goes, and when
  it's done. Commit it, then Bryson tells the other agent to check the requests.
- The other answers in the table, links the commit, and sets the status: open, answered, done or
  declined, with the reason.
- Short context goes in commit messages; anything longer goes in the relevant exploration file.
- A request records work; it doesn't start the other agent. Each request says its scope and what
  counts as done. The receiving agent acts when Bryson activates or authorizes it. Requests that
  touch design, architecture, spending or agreed scope still need Bryson's decision.
- If we disagree, both positions go in the table, and Bryson decides.

### Who owns what

Ownership is coordination: the owner is the default maintainer. Anyone reads anything. Bryson can
assign either agent work in any area, and that assignment authorizes the edits it needs, after
checking for work already in progress there. Otherwise, to change something the other owns, make a
request, except for typo fixes. Astra may deliver Bryson's chosen images into the agreed folders in
`art/sources/`; Claude owns the models made from them and their records.

| Area | Owner |
|---|---|
| `art/concepts/` | Astra |
| `art/reference/`, `art/briefs/`, `art/sources/`, `game/assets/` | Claude |
| The model viewer and any tool Astra builds | Astra |
| `game/` code, rules and content apart from Astra's tools | Claude |
| AGENTS.md, DESIGN.md, RULES.md, EXPLORATIONS.md, `explorations/` | Both, under AGENTS.md's rules for editing them |
| Contracts, such as `game/assets/README.md` | Both: change only by request and agreement, then Bryson's approval |

### Sharing one working copy

We both work in the same folder, sometimes at the same time. Claude has twice found Astra's work in
progress there, uncommitted. We also share one git staging area, so staging by path alone can't
stop one commit from picking up the other's staged work.
- Only one agent stages and commits at a time. Before staging, check that nothing is staged
  already (`git diff --cached --quiet`); if something is, it's the other agent's, so leave it and
  wait. Check the complete staged diff before committing.
- Concurrent edits use distinct files. Overlapping work needs a handoff, or separate working
  copies (`git worktree`).
- Stage your own files by path. Never `git add -A`, `git add .` or `git commit -a`.
- Stage and commit in one command that stops if staging fails (`git add <paths> && git commit`),
  and check what's staged before committing. On 2026-10-10 Claude's staging failed on a stale path
  and the commit went out with only half the change; a second commit fixed it.
- Never discard, stash, reset or rewrite changes you didn't make, and never commit them.
- Commit small and often, so work in progress doesn't sit around; push after milestones, as
  AGENTS.md says.
- Say who made a commit: Claude's end with a Co-Authored-By line naming Claude; Astra's end the
  subject with "(Astra)".

## Requests

| # | From → to | Request | Result goes | Status |
|---|---|---|---|---|
| 1 | Claude → Astra | Review this proposal and the asset contract, [game/assets/README.md](../game/assets/README.md). Answer here with changes you'd make | This table, and edits by agreement | answered: accepted in principle, with five clarifications, all taken in (see Findings) |
| 2 | Claude → Astra | Generate the images for the three proof-run props from the prompts in [the briefs](../art/briefs/proof-run.md#prompts-for-astra), under Bryson's direction, and save the ones he picks there. Done when the images are saved and Bryson has told Claude | `art/sources/devices/bollard_light/`, `.../camera_head/`, `.../access_terminal/` | images delivered 2026-10-11: Bryson approved all three main views and authorized the follow-ups and delivery. Camera main + side and terminal main + back saved as numbered PNGs, main first, in their source folders; Astra visually inspected the follow-ups. [Complete handoff](../art/concepts/proof-run-review-2026-10-10/DELIVERY.md), with source links and exact prompts. Claude already delivered the bollard image and is modeling it. Remaining coordination step: Bryson tells Claude "Request 2: images delivered." The [logo PNG](../art/reference/openbrain-logo-white.png) is the interlaced version Bryson chose 2026-10-11 |
| 3 | Bryson → Astra | The model viewer: a Godot program that shows each model by itself, from every angle, reading the records the contract describes. Done when it lists every asset by category and status, shows each from every angle, and reports broken records without stopping | Astra's tool, in `game/preview/` | done 2026-10-10: Model Library built and installed; folder/list browsing, refresh, camera and inspection controls, record errors and animation playback verified. Bryson tried it: "it works great". See [viewer README](../game/preview/model_viewer/README.md); implementation [8ab5285](https://github.com/matthewsirbaugh/strategy-game-idea/commit/8ab5285) |
| 4 | Claude → Astra | Bryson approved a new rule in AGENTS.md (2026-10-11): hand-offs travel through the repository, and Bryson's message to the other agent is one line naming the request. The agreement asks for both of us to agree to changes; answer here if you'd word it differently | This table | answered: Astra agrees with the wording as written; no changes proposed. The repository carries the complete handoff and Bryson activates it by request number. [d165105](https://github.com/matthewsirbaugh/strategy-game-idea/commit/d165105) |
| 5 | Claude → Astra | Batch 2: generate a main view for each of the six devices in [the briefs](../art/briefs/batch-2-devices.md#for-astra), under Bryson's direction, and save the ones he picks. The night-vision camera needs no image. Done when the six images are saved and Bryson has told Claude | `art/sources/devices/<id>/01-main.png`, the ids in the briefs | done 2026-10-11: Bryson approved the cache, phone, machine, ad screen and power hub, and Claude copied them from the [review set](../art/concepts/batch-2-device-review-2026-10-11/README.md) into `art/sources/devices/`. The turret read as a camera; its revision moved to [batch 4](../art/briefs/batch-4.md) (Bryson) |
| 6 | Claude → Astra | Batch 3: generate the images for the eight items in [the briefs](../art/briefs/batch-3-vehicles-and-fixtures.md#for-astra), under Bryson's direction: a main view each, plus a side view for the two vehicles. Save the ones he picks. Done when they're saved, committed, and Bryson has told Claude | `art/sources/<category>/<id>/`, the paths in the briefs | done 2026-10-11: Bryson approved the car, van, pole light head, scanner head, barrier housing, planter and bench (v2), and Claude copied them from the [review set](../art/concepts/batch-3-review-2026-10-11/README.md) into `art/sources/`. The EV charger read as an access terminal; its revision went to [batch 6](../art/briefs/batch-6-revisions.md) (Bryson) |
| 7 | Claude → Astra | Batch 4: generate a main view for each of the five items in [the briefs](../art/briefs/batch-4.md#for-astra), under Bryson's direction, starting with the revised turret. Save the ones he picks. Done when they're saved, committed, and Bryson has told Claude | `art/sources/<category>/<id>/01-main.png`, the paths in the briefs | done 2026-10-11: Bryson approved all five from the [review set](../art/concepts/batch-4-review-2026-10-11/README.md); Claude copied them into `art/sources/` |
| 8 | Claude → Astra | Batch 5, the last exterior props: generate a main view for each of the four items in [the briefs](../art/briefs/batch-5.md#for-astra), under Bryson's direction, and save the ones he picks. Done when they're saved, committed, and Bryson has told Claude | `art/sources/props/<id>/01-main.png` | done 2026-10-11: Bryson approved all four from the [review set](../art/concepts/batch-5-review-2026-10-11/README.md); Claude copied them into `art/sources/props/`. The turnstile's glass wings get replaced by real glass in Blender |
| 9 | Claude → Astra | Batch 6, revisions: generate a main view for each item in [the briefs](../art/briefs/batch-6-revisions.md#for-astra), under Bryson's direction, and save the ones he picks. Done when they're saved, committed, and Bryson has told Claude | `art/sources/<category>/<id>/01-main.png` | images delivered 2026-10-11: Bryson approved EV charger v4, adapted from his real-world photo. Approved main copied unchanged to [the source](../art/sources/props/ev_charger/01-main.png). [Complete handoff](../art/concepts/batch-6-review-2026-10-11/README.md), including revised direction and photo reference. Ready for Claude to model; remaining coordination: Bryson tells Claude "Request 9: images delivered." Batches 4 and 5 needed no redos |
| 10 | Claude → Astra | Bryson asked for a rule on where finals live (2026-10-11): see "Images: candidates and finals" above, and the line in AGENTS.md. The agreement asks for both of us to agree to changes; answer here if you'd word it differently | This table | open |
| 11 | Bryson, through Astra → Claude | File [Astra's independent review](astra-review-2026-10-11.md): 22 game questions in the V2 open questions and ideas, and 18 lore questions for the next lore exploration. Merge duplicates, preserve observation versus hypothesis, and cross-reference the pending V1 readings. Done when every item is filed or linked to an existing question and this row points to the filing commit. Full instructions and evidence are in the handoff | `rulebook.md` V2 backlog; `core-idea-and-story.md` open-question guide; the board as needed | lore half filed 2026-10-11, in [the story exploration's question guide](core-idea-and-story.md#astras-review-2026-10-11). The game half is held: Bryson asked to leave the game notes for now |
| 12 | Bryson, through Astra → Claude | Review [the proposed shared coding guide](shared-coding-guide.md) and [cleanup evidence/deferred refactoring](game-cleanup-2026-10-11.md). Record accepted sections, concrete amendments and remaining disagreements in the guide's response section; link your response commit here. Done when Claude and Astra have recorded their positions and Bryson can decide adoption. Major refactoring and module splits wait for agreement, with Bryson retaining the final decision; this request authorizes review, not those refactors | `shared-coding-guide.md` response section and this table | done 2026-10-11: both agents agreed, and Bryson adopted [the guide](shared-coding-guide.md). The first refactor is Request 13 |
| 13 | Bryson, through Claude → Astra | Implement [action blockers](action-blockers.md): the rules return why an action is refused, and the menus only word it. In the same pass, swap the battle-flow test's prose checks for blocker codes. This is also the claim on `battle_state.gd`, `devices.gd`, `battle_menus.gd`, `battle.gd` and `test_battle_flow.gd` under the guide's claiming rule. Done when the file's "Done when" list holds and its Findings are recorded | The game code, and the Findings in `action-blockers.md` | done 2026-10-11: [f393f67](https://github.com/matthewsirbaugh/strategy-game-idea/commit/f393f67). [Findings](action-blockers.md#findings), native menu captures and two existing remote-availability information leaks recorded for Bryson. Playtest remains open; file claims released |
| 14 | Bryson → Astra | Implement [startup measurements and clearer scenery fog](startup-and-fog.md), ahead of Request 13. Claim: `game/battle/battle.gd`, `grid_view.gd`, `level_view.gd`, `unit_view.gd`, new startup/fog presentation helpers; `game/art/toon_model.gd`, affected fog/model/surface shaders; `game/project.godot`; profiling/prototype tools and meaningful fog regression checks; README and these handoff files. Preserve shared material behavior for characters/previews. Done when the approved acceptance checks and before/after measurements are recorded, with separate commits | Game code, tools, review captures and `startup-and-fog.md` findings | done 2026-10-11: integration in [52118e1](https://github.com/matthewsirbaugh/strategy-game-idea/commit/52118e1), followed by the verified outline correction and final five-run timings. [Final findings/captures](startup-and-fog.md#final-outline-review-and-final-measurements). Bryson's playtest remains open; proposed loading pilot is Request 15. File claims released |
| 15 | Astra → Claude | Review the [measured startup breakdown and single-texture import pilot](startup-and-fog.md#focused-startup-proposal-for-joint-review). Resource loading dominates; animation preparation does not. Recommend whether to run the bounded pilot and what visual tradeoff is acceptable. Review only; implementation and asset-pipeline changes await Bryson's decision | `startup-and-fog.md`, this table | proposed 2026-10-11; Bryson activates review |

## Findings

### 2026-10-10 — Astra's review, and Claude's answer

Astra (relayed by Bryson): accepted in principle, with no change to the division of work or to
Bryson's authority, and five clarifications before calling it settled. Astra will mark commits
"(Astra)". Claude took all five in:

1. Ownership is coordination, and Bryson's assignments take precedence. Taken as worded.
2. One shared staging area: one agent stages and commits at a time, the full staged diff is
   checked, concurrent edits use distinct files, overlapping work needs a handoff or separate
   working copies. Taken, with one addition from Claude: check that nothing is staged before
   staging, which is how each of us knows the other is mid-commit.
3. A request records work and doesn't start the other agent; Bryson activates it; design,
   architecture, spending and scope still need his decision. Taken as worded.
4. Astra may deliver Bryson's chosen images into `art/sources/`; Claude owns what's made from them.
   Taken as worded.
5. The asset contract: every field required, with `null`, `[]` or `""` when empty; ids unique
   across the whole tree; `height_m` is the actual imported height, with scaling done during
   preparation; a reader reports a broken record or missing model and carries on. Taken. On
   whether legacy models keep the guarantees, Claude measured them: the four people are real
   scale and stand at y = 0; the nine props are made at unit size and centred on their middle, and
   the game resizes them as it loads. The contract adds `fit_to_height`, true only for those nine,
   so a reader scales them to `height_m` and stands them on the ground.

## Decision

Adopted 2026-10-10. Claude drafted the agreement and the asset contract; Astra accepted both in
principle and proposed five clarifications; Claude took all five in. Bryson left the call to
Claude, as it's Claude's agreement, and Claude agreed. The core rules graduated to AGENTS.md under
"Claude and Astra"; the contract, `game/assets/README.md`, is marked adopted. Changes to either
go through a request, agreement between the two, and Bryson's approval.
