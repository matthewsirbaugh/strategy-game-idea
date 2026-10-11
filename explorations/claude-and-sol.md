# How Claude and Sol work together

- Feeds: AGENTS.md (where the agreement graduates once settled)
- Status: open
- Next action: Sol reviews the proposal below and the asset contract
  ([game/assets/README.md](../game/assets/README.md)), and answers in the Requests table.

## The question

Bryson works with two agents on this project, Claude and GPT-6 Sol. How do they divide the work,
talk to each other, and share one repository without getting in each other's way?

## What Bryson has said (2026-10-10)

- He'll keep using both. Claude is saved for important and creative work and is the central
  project architect; Sol is the workhorse.
- Sol makes all the reference and concept images, and will build a Godot program that shows every
  model for review in 3D, by itself, from every angle.
- The two need to agree on how to work. Claude drafts; Bryson has Sol review it and propose
  changes; the two work out between them how best to communicate.

## The proposal (Claude's draft, for Sol's review)

### Roles

| Claude | Sol |
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
- If we disagree, both positions go in the table, and Bryson decides.

### Who owns what

Anyone reads anything. To change something the other owns, make a request, except for typo fixes.

| Area | Owner |
|---|---|
| `art/concepts/` | Sol |
| `art/reference/`, `art/briefs/`, `art/sources/`, `game/assets/` | Claude |
| The model viewer and any tool Sol builds | Sol |
| `game/` code, rules and content apart from Sol's tools | Claude |
| AGENTS.md, DESIGN.md, RULES.md, EXPLORATIONS.md, `explorations/` | Both, under AGENTS.md's rules for editing them |
| Contracts, such as `game/assets/README.md` | Both: change only by request and agreement, then Bryson's approval |

### Sharing one working copy

We both work in the same folder, sometimes at the same time. Claude has twice found Sol's work in
progress there, uncommitted.
- Stage your own files by path. Never `git add -A`, `git add .` or `git commit -a`.
- Stage and commit in one command that stops if staging fails (`git add <paths> && git commit`),
  and check what's staged before committing. On 2026-10-10 Claude's staging failed on a stale path
  and the commit went out with only half the change; a second commit fixed it.
- Never discard, stash, reset or rewrite changes you didn't make, and never commit them.
- Commit small and often, so work in progress doesn't sit around; push after milestones, as
  AGENTS.md says.
- Say who made a commit: Claude's end with a Co-Authored-By line naming Claude; Sol's could end the
  subject with "(Sol)".

## Requests

| # | From → to | Request | Result goes | Status |
|---|---|---|---|---|
| 1 | Claude → Sol | Review this proposal and the asset contract, [game/assets/README.md](../game/assets/README.md). Answer here with changes you'd make | This table, and edits by agreement | open |
| 2 | Claude → Sol | When Bryson picks the final images for the three proof-run props ([briefs](../art/briefs/proof-run.md)), save them where Meshy's input lives | `art/sources/devices/bollard_light/`, `.../camera_head/`, `.../access_terminal/` | open |
| 3 | Bryson → Sol | The model viewer: a Godot program that shows each model by itself, from every angle, reading the records the contract describes | Sol's tool, in `game/preview/` | open, once the contract is agreed |

## Findings

None yet.
