# AGENTS.md

Working agreements for this project, for any AI agent working in this folder: Claude Code,
Codex, Antigravity or anything else. The game itself is in DESIGN.md.

Bryson is the human you are working with, and has the final say.

## Who decides what

- Bryson does the design: systems and mechanics, story, world, characters, dialogue,
  art direction, level and content layout, balancing.
- Agents execute art and code, and offer options and suggestions, under Bryson's
  direction.
- Architecture is designed together. It is never a solo agent decision.
- This is a partnership, not a work queue. Suggest things, push back, bring ideas.
  Bryson still decides.

## How a design problem gets worked

1. The core idea and story come first, refined until they can carry a story and a world.
   Mechanics, look, plot and dialogue grow out of that.
2. For a specific problem: discuss it and compare it against existing games until the shape of
   the problem, the shape of the solution, and the tradeoffs are clear.
3. Narrow it down conceptually.
4. Build a small MVP so Bryson can test it and decide whether to pursue it.

Don't start building before step 3. Bryson wants a solid plan before construction, and
expects that plan to change as ideas surface while playing.

## Communication

- Numbered questions and decision requests. Tables, bullets and diagrams where they earn their
  place. No walls of text with bold phrases scattered through them.
- Say what changed, what actually works, what is still uncertain, and what you need from
  Bryson. Report honestly when something was written but not run, or run but not played.
- Separate what Bryson said, what you inferred, what you recommend, and what is
  undecided. A recommendation is not a decision.
- When you write code, give a short, high-level explanation of what it does and how it fits
  into the larger system. Bryson does not read every line, but has to understand the
  system. Enough for it to click. They will ask if it doesn't.
- Keep it fun. This is a video game. It should be enjoyable to make on both sides. Don't be
  dry.

## Files

| File | Holds |
|---|---|
| DESIGN.md | The game: intent, touchstones, constraints, decisions, open questions |
| AGENTS.md | This file: how we work |
| CLAUDE.md | One line pointing Claude Code at this file |
| EXPLORATIONS.md | The board: every open topic, its status and its next action |
| explorations/*.md | One file per research or design thread |
| .claude/commands/exploration.md | The `/exploration` command, for Claude Code |

README.md (setup and run instructions) gets created when there is code to run. There is no
NOW.md — the board covers what is current. Project knowledge lives in these files, not in a
tool's private memory, which the other tools can't see.

## Explorations

Research and design tangents run as separate threads, so they don't derail the work in
progress and don't get lost. One topic, one chat, one file.

- EXPLORATIONS.md is the board: every open topic, its status and its next action. It is the
  only place that says what is current.
- `explorations/<topic>.md` is the thread itself: the question, inherited constraints,
  candidates, dated findings, open questions, and the decision once it lands.
- Only conclusions graduate. A decision moves into DESIGN.md, or AGENTS.md if it is a working
  rule, as a line or two with a link back. The reasoning stays in the exploration file, so the
  design docs never become a research dump.
- A new tangent gets a row on the board, not a detour in the current chat.
- Starting cold in any tool: read AGENTS.md, EXPLORATIONS.md and the one exploration file.
  Nothing else should be needed. In Claude Code, `/exploration` does this.
- Bryson makes the call at the end of an exploration. Agents gather, compare and recommend.

## Editing these files, and git

- These files hold only what Bryson said or approved. Inferences stay in the
  conversation until they confirm them.
- A brand new file: write it, then Bryson reviews the file itself with the diff.
- Changing wording that is already agreed: propose it in chat first.
- Routine edits — typos, formatting, closing a question that has been answered — just make
  them, then list what you changed.
- Local git, branch `main`. Commit after each agreed change with a short message, so any
  single change can be undone on its own.

## Tools, models and spending

- Claude Pro and ChatGPT Pro subscriptions today, possibly consolidating into one $100 plan.
- Roughly 90% of the work runs on Opus and Sol.
- Astra is better at 3D and is used for art prototypes: more than a placeholder, less than a
  final asset. It burns through usage quickly, so use it deliberately.
- Fable- and Astra-level spending is reserved for when it is genuinely needed, or for polish.
- Final art is deliberately deferred toward the end of the project, on the expectation that 3D
  tooling keeps improving.
- Services like Meshy are options for generating 3D assets.

## Code and tests

The project is at the prototype stage. Code gets thrown away and rewritten, so keep it lean.
Every comment and test is paid for in tokens twice: once to write, and again each time an agent
reads it later.

- Comment only when the reason behind the code isn't obvious from the code itself. No comments
  that restate what a line does.
- Write a test only when it earns its keep: rules math that's easy to get subtly wrong, or a bug
  that has already come back once. Never for coverage, and never "just because".
- Verify by running and playing the build. Report which of the two actually happened.
- Revisit this when the project moves from prototype toward a finished product.

## Not agreed yet

Engine: Godot 4 with GDScript, decided 2026-09-23. Project structure is recorded in
[the battle MVP exploration](explorations/battle-mvp.md). Still open: art pipeline, target
platforms. Don't assume these. Ask.
