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
| 9 | Claude → Astra | Batch 6, revisions: generate a main view for each item in [the briefs](../art/briefs/batch-6-revisions.md#for-astra), under Bryson's direction, and save the ones he picks. Done when they're saved, committed, and Bryson has told Claude | `art/sources/<category>/<id>/01-main.png` | active 2026-10-11: revised EV charger v3 generated and inspected: taller pole-mounted design with one intricate housing and blank screen area, requested by Bryson. [Review set](../art/concepts/batch-6-review-2026-10-11/README.md). Awaiting Bryson's selection before final source delivery; batches 4 and 5 needed no redos |

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
