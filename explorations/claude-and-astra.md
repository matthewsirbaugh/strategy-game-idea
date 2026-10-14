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

Open requests. Closed ones are summarized under [Closed requests](#closed-requests); their full rows were archived on
2026-10-13 (see [ARCHIVE.md](../ARCHIVE.md)).

| # | From → to | Request | Result goes | Status |
|---|---|---|---|---|
| 11 | Bryson, through Astra → Claude | File [Astra's independent review](astra-review-2026-10-11.md): 22 game questions in the V2 open questions and ideas, and 18 lore questions for the next lore exploration. Merge duplicates, preserve observation versus hypothesis, and cross-reference the pending V1 readings. Done when every item is filed or linked to an existing question and this row points to the filing commit. Full instructions and evidence are in the handoff | `rulebook.md` V2 backlog; `core-idea-and-story.md` open-question guide; the board as needed | lore half filed 2026-10-11, in [the story exploration's question guide](core-idea-and-story.md#question-guide). The game half is held: Bryson asked to leave the game notes for now |
| 15 | Astra → Claude | Review the [measured startup breakdown and single-texture import pilot](startup-and-fog.md#focused-startup-proposal-for-joint-review). Resource loading dominates; animation preparation does not. Recommend whether to run the bounded pilot and what visual tradeoff is acceptable. Review only; implementation and asset-pipeline changes await Bryson's decision | `startup-and-fog.md`, this table | parked 2026-10-13 by Claude: the pilot measures loading the placeholder models, which the new art is replacing. Revisit once the new props are in the game |
| 22 | Bryson, through Claude → Astra | Revise the Operators from [the brief](../art/briefs/operator-revision.md): distinct outfits for the writer and the developer, a more feminine writer from the face reference Bryson attaches, and packs that are wearable computers with a 360° camera, one kind per backstory. Four images: three sheets and a pack lineup. Exploratory. Also, two small things: (a) commit `art/concepts/operator-style-test-2026-10-13/v2/`, since the adopted [style reference](../art/reference/operator-protagonist-style.png) was copied from its `style-clean-hero.png`; (b) Request 10, merged here: answer if you'd word the rule on where finals live ("Images: candidates and finals" above, and AGENTS.md) differently. For your information: Bryson made `side-project-map-maker/` part of the project on 2026-10-13, and Claude committed it | `art/concepts/operator-revision-<date>/`, the v2 folder, this table | four candidates generated 2026-10-13: [sheets, packs, prompts and 55-pixel silhouette check](../art/concepts/operator-revision-2026-10-13/README.md), delivered 2026-10-13: Bryson picked all four as the definitive Operators, filed in `art/sources/units/operator_*/` (Claude). For the writer he picked the first pass, before the complexion edit. The adopted [v2 style original](../art/concepts/operator-style-test-2026-10-13/v2/README.md) is included. Request 10 answered under [Findings](#astra-review-of-image-source-wording-2026-10-13); proposed clarification awaits agreement |

<a id="closed-requests"></a>

### Closed requests

| # | What | Where the result lives |
|---|---|---|
| 1 | Astra reviews this agreement and the asset contract | Accepted with five clarifications ([Findings](#findings)) |
| 2 | Proof-run images: bollard light, camera head, access terminal | Modeled, `game/assets/devices/` |
| 3 | The Model Library viewer | `game/preview/model_viewer/`, [README](../game/preview/model_viewer/README.md) |
| 4 | Agree the rule that hand-offs travel through the repository | Agreed as written; in AGENTS.md |
| 5–9 | Prop image batches 2 to 6 | `art/sources/`, modeled in `game/assets/` |
| 10 | Agree the rule on where finals live | Merged into Request 22 |
| 12 | Review the shared coding guide | Adopted: [shared-coding-guide.md](shared-coding-guide.md) |
| 13 | Action blockers | [action-blockers.md](action-blockers.md#findings) |
| 14 | Startup measurements and clearer scenery fog | [startup-and-fog.md](startup-and-fog.md) |
| 16 | Review the fog repair plan | [fog-vision-ticks-fix.md](fog-vision-ticks-fix.md) |
| 17 | The fog repair | [fog-vision-ticks-fix.md](fog-vision-ticks-fix.md#request-17-implementation-findings) |
| 18 | Fading fog and menus named after objects | [fog-fade-and-object-menus.md](fog-fade-and-object-menus.md#findings) |
| 19 | Six Operator look sheets | [Gallery](../art/concepts/operator-looks-2026-10-12/README.md) |
| 20 | The Operators' style test | [Gallery](../art/concepts/operator-style-test-2026-10-13/README.md) |
| 21 | The writer's and the developer's sheets | [Gallery](../art/concepts/operator-sheets-2026-10-13/README.md) |

## Findings

<a id="astra-review-of-image-source-wording-2026-10-13"></a>

### 2026-10-13 — Astra's answer on where finals live (Request 10, bundled with 22)

Astra agrees with the rule: candidates stay versioned in `art/concepts/`, Bryson's chosen
modeling images are copied unchanged into `art/sources/`, the request names those exact files,
and Claude reads the current status before modeling. No extra storage location is needed.

One proposed wording clarification: use **approved modeling source** for what the rule calls a
"final", so an approved style or setting reference in `art/reference/` has an explicit role.
Suggested wording for the first bullet: "Approved modeling-source images live only in
`art/sources/<category>/<id>/01-main.png` (and `02-side.png`, ...). Claude models from the files
named in the delivered request. `art/reference/` holds approved visual guides; `art/concepts/`
holds candidates and their history."

This is Astra's proposal for Claude and Bryson to consider. The adopted wording in AGENTS.md and
the agreement above remains current.

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
