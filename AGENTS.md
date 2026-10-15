# AGENTS.md

Shared working agreements for Claude Code, Codex, Antigravity and other agents. Bryson has
final say. The game is in DESIGN.md; current work is in EXPLORATIONS.md.

## Who decides what

- Bryson designs systems, mechanics, story, world, characters, dialogue, art direction,
  levels, content and balance. Agents execute art and code under his direction.
- Architecture is designed together, never by an agent alone. This is a partnership:
  suggest, question and bring ideas; Bryson decides.

## How a design problem gets worked

1. Refine the core idea and story until they carry a world; mechanics, look, plot and dialogue follow.
2. Discuss the problem and compare existing games until the solution and tradeoffs are clear.
3. Narrow it down conceptually and agree a solid plan.
4. Build a small minimum viable prototype for Bryson to test and decide whether to pursue.

Don't build before step 3. Expect the plan to change through play.

## Communication

- Number questions and decision requests continuously through each message, answerable by number.
  Use tables, bullets and diagrams where useful; avoid walls of text and scattered bold phrases.
- Define new or in-game terms at the top. RULES.md holds each term in both its brief glossary
  and a full definition with implementation edge cases.
- Separate Bryson's statements, inferences, recommendations and undecided choices.
- Report what changed, what works, what is uncertain and what you need from Bryson. Distinguish
  written, run and played. Explain code changes briefly: what they do and how they fit the system.
- Keep it fun; this is a video game.

## Files

| Where | What |
|---|---|
| DESIGN.md / RULES.md / STORY.md | Game intent, touchstones, constraints, decisions and questions / agreed rules (V1 in progress) / agreed world, history and characters |
| AGENTS.md / CLAUDE.md | Shared agreements / Claude's import of them |
| EXPLORATIONS.md / `explorations/*.md` | Current topics, status and next action / one research or design thread per file |
| README.md / `game/` | Setup, running, checks, code routes and boundaries / Godot project |
| `side-project-map-maker/` | Astra's separate Godot map maker; the start of Bryson's level authoring |
| `tools/` | Verification, source reading, profiling and model preparation; [tool index](README.md#tools) |
| `art/reference/` / `art/concepts/` | Bryson's chosen references (new art follows them) / exploratory candidates |
| `art/briefs/` / `art/sources/` / `art/previews/` | Claude's briefs for Bryson and Astra / source images and raw model downloads / build captures |
| ARCHIVE.md | What moved to `~/Desktop/Archive/`, when and why; don't read that external archive unless Bryson asks |
| `.claude/commands/exploration.md` | Claude's `/exploration` command |

Old ideas and assets with value go to that external archive, recorded in ARCHIVE.md.
No NOW.md. Project knowledge lives in shared files, not private tool memory.

## Reading efficiently

- On a cold start, use these instructions (don't reread if already supplied), EXPLORATIONS.md
  and the relevant exploration. Read its opening context and relevant sections; expand when
  dependencies or conflicting findings require it. Rules work also uses RULES.md; story uses STORY.md.
- `python3 tools/read_section.py <file.md>` lists headings and line numbers. Add an exact heading
  in quotes to read that section and its children. This reads the current file, not a cached summary.
- Code work: use README.md's **Code reading routes** and **Implementation boundaries**, then
  named functions and callers. Read the coding guide's **Working standard**; its review history is
  evidence, not another required read. Read the agreement's **Requests** for assignments and claims.
- Scope `rg` to relevant paths; use `rg -l` for filenames and `rg -n` for matching lines, then bounded
  excerpts. `.rgignore` filters binary assets, generated metadata and captures from default searches;
  explicit paths or `rg --no-ignore <pattern> <path>` include them when needed. Source, resources,
  asset records and research remain searchable. Full output belongs in logs; inspect failures.

## Explorations

- One topic, one chat, one file. EXPLORATIONS.md is the sole current-work board: status, next action,
  link. Keep detailed delivery history in the topic file. New tangents get a board row.
- Each exploration holds its question, inherited constraints, candidates, dated findings, open
  questions and eventual decision. Agents gather, compare and recommend; Bryson makes the call.
- Only conclusions graduate: a line or two in DESIGN.md, RULES.md for rules, STORY.md for story,
  or AGENTS.md for working rules, with a link back. Reasoning stays in the exploration.
- Claude's `/exploration` follows this route. Don't re-derive recorded conclusions.

## Editing these files, and git

- Record only what Bryson said or approved; inferences stay in chat until confirmed. For new
  files, write them for Bryson to review with the diff. Propose changes to agreed wording in chat
  first. Fix typos, formatting and answered questions directly, then list the edits.
- Work on `main`. Commit each agreed change with a short message; push to GitHub after milestones
  or larger tasks so local and cloud agents share the same state.
- One working copy and staging area: only one agent stages/commits at a time. First run
  `git diff --cached --quiet`; if anything is staged, leave it and wait. Stage only owned paths;
  never `git add -A`, `git add .` or `git commit -a`. Stage, inspect the full staged diff and commit
  in one command that stops on failure. Never discard, stash, reset or commit another's work.
  Concurrent edits use distinct files; check claims before editing shared files.
- Claude's commits carry a Claude Co-Authored-By line; Astra's subjects end with `(Astra)`.

## Claude and Astra

Adopted 2026-10-10; full agreement and requests: [claude-and-astra.md](explorations/claude-and-astra.md).

- Claude is the central architect working with Bryson on new features; Astra (the OpenAI agent,
  whichever model runs it) handles most maintenance, images and assigned tools (2026-10-11).
- Owners are default maintainers. Bryson can assign either agent any area after checking work in
  progress. Requests name scope, destination and completion criteria; Bryson activates them.
  Design, architecture, spending and scope remain his calls.
- Hand-offs travel through repository files and the requests table; Bryson relays one line naming
  the request. Put everything the receiving agent needs there.
- Models follow [game/assets/README.md](game/assets/README.md).
- An image is final only in `art/sources/<category>/<id>/`; `art/concepts/` holds candidates.
  Whoever is with Bryson when he picks copies the choice there and marks the request delivered.
  Claude models only from sources after checking delivery status. Chosen visual references live
  in `art/reference/`.

## Tools, models and spending

- Claude Pro and ChatGPT Pro today, possibly one $100 plan; roughly 90% of work uses Opus and Sol.
  Astra usually runs on Sol because the Astra model uses usage quickly (2026-10-10).
- Lower-level subagent searches, inventories, mechanical edits and routine fixes can use Sonnet
  instead of Opus. Reserve expensive models for real need or polish.
- Astra is better at 3D prototypes (beyond placeholders, below final assets); use deliberately.
  Final art waits until late as 3D tooling improves; Meshy is an option for generating models.
- Art workflow: Claude writes the brief; Bryson and Astra refine the design; Astra makes all
  references and concepts; Claude turns Bryson's supplied images into Meshy models. Meshy's
  credits go to models, never its image tool (2026-10-10).

## Code and tests

Prototype code should stay lean; comments and tests cost tokens to write and reread.

- Comment only non-obvious reasons. Test only subtle rules math or a recurring bug, never for
  coverage. Revisit these constraints when moving toward a finished product.
- Verify by running and playing; report which happened. Bryson plays as he goes: never list his
  playing as a next action or open item; record what he reports (2026-10-13).
- Preserve the established look. Compare visual changes to the previous build in the same camera
  framing; flag unrequested appearance changes before delivery (2026-10-11).
- After committing game changes, restart from the root: `pkill -f "^godot --path"`, then
  `godot --headless --path game --import`, then `godot --path game`. Import registers new
  `class_name` scripts, including those brought by a pull.
- Follow the adopted [shared coding guide](explorations/shared-coding-guide.md#working-standard)
  for style, boundaries, caches, tests and claiming shared files before refactors (2026-10-11).

## Not agreed yet

Godot 4 with GDScript is decided (2026-09-23). Structure is in README.md's **How `game/` is
organized** and **Implementation boundaries**. Art pipeline and target platforms remain open;
don't assume them, ask.
