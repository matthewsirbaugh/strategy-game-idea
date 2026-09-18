---
description: Start, resume, list or close a project exploration
argument-hint: start <topic> | list | close <topic>
---

Explorations keep research and design tangents in their own chats and their own files, so
nothing derails the work in progress and nothing gets lost. The protocol is in AGENTS.md under
"Explorations". EXPLORATIONS.md is the board.

Request: $ARGUMENTS

1. Read EXPLORATIONS.md. Read AGENTS.md if it isn't already loaded.
2. `list`, or an empty request: show the board as a table — topic, status, next action — and
   say which ones are ready to pick up right now. Stop there.
3. `start <topic>`: check the board first for a topic that already covers this. If one matches,
   say so and resume that thread instead of opening a second one. Otherwise create
   `explorations/<slug>.md` with the question, the constraints it inherits, and a next action,
   and add a row to the board.
4. Resuming an existing thread: read its file and open with a short recap — the question, what
   is settled, what is still open, the next action. Then get to work. Don't re-derive what the
   file already says.
5. `close <topic>`: write Bryson's decision and its reasoning into the exploration file, move
   the conclusion itself into DESIGN.md (or AGENTS.md if it is a working rule) as a line or two
   with a link back, set the board row to decided, and commit.
6. If a session-title tool is available, set the chat title to the exploration's name.
7. Keep the file current while you work: findings dated, next action honest. Commit when the
   exploration pauses or ends.

Stay inside the topic. If something else interesting surfaces, add it to the board as its own
row and carry on with this one.
