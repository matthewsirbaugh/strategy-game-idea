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
4. Resuming: read the file's opening context and list headings with
   `python3 tools/read_section.py <file.md>`, then add an exact heading in quotes to read the
   relevant sections. Follow dependencies and later corrections; don't load unrelated history.
   Open with a short recap: question, settled points, open choices, next action. Then work;
   don't re-derive recorded conclusions. The board owns current status when an older intro lags.
5. `close <topic>`: write Bryson's decision and its reasoning into the exploration file, move
   the conclusion itself into DESIGN.md (RULES.md if it is a game rule, STORY.md if it is story, AGENTS.md if it is a
   working rule) as a line or two
   with a link back, set the board row to decided, and commit.
6. If a session-title tool is available, set the chat title to the exploration's name.
7. Keep the file current while you work: findings dated, next action honest. Commit when the
   exploration pauses or ends.

Stay inside the topic. If something else interesting surfaces, add it to the board as its own
row and carry on with this one.
