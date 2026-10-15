# Project token efficiency

- Request: Bryson, 2026-10-14: make the project maximally token efficient.
- Scope: shared instructions, document navigation, searches and verification output.
- Coordination: [Request 28](claude-and-astra.md#requests).
- Delivered: `77c26f3` (2026-10-14); all file claims released after the implementation commit.

## Findings

At `dccf7e2`, the task-to-file routes in README.md and quiet `tools/check.sh` already served
the project well. No game-code split or test removal was justified for this task.

The recurring waste was document loading: AGENTS.md had 1,906 words, EXPLORATIONS.md repeated
delivery history, and reading the full coding guide included its superseded review discussion.
The story exploration alone was 84,080 bytes; it already had a topic index and question guide.

The cleanup condenses the standing guidance and board; CLAUDE.md keeps its single AGENTS.md
import. Task-specific sections are read directly from source with `tools/read_section.py`.
The design/rules/story documents and exploration histories remain intact. The board retains
each topic, status and outstanding action; completed details remain in linked evidence.

`.rgignore` narrows ordinary ripgrep searches, not Git tracking or Godot loading. Explicit files
or `--no-ignore` on a relevant directory restore asset/import access. Code, scenes, resources,
asset records, SVGs and research stay searchable. No global model, plugin, permission or account
settings changed; the project-local Claude configuration only contained permissions, no hooks.

## Verification and measurements

Verified 2026-10-14 against the pre-change checkout at `dccf7e2`:

| Read or listing | Before | After | Reduction |
|---|---:|---:|---:|
| AGENTS.md (bytes) | 11,457 | 9,069 | 20.8% |
| EXPLORATIONS.md (bytes) | 10,245 | 7,206 | 29.7% |
| Combined startup documents (bytes) | 21,702 | 16,275 | 25.0% |
| Combined startup documents (words) | 3,250 | 2,257 | 30.6% |
| Coding guide: full file vs Working standard read (bytes) | 13,917 | 4,780 | 65.7% |
| Default `rg --files` inventory (paths) | 1,176 | 310 | 73.6% |

- Section reader: exact boundaries, child headings, fenced-code exclusion, case matching,
  closing heading markers, missing/duplicate headings, missing files, and original line endings
  passed temporary smoke checks. Live sections match source text exactly; no permanent test suite added.
- All 23 original board topics and statuses retained. Reviewed the instructions against the
  original: authority, design process, communication, source roles, archiving, approvals, staging,
  ownership, hand-offs, art workflow, spending, tests, visual checks and restart rules retained.
- All local Markdown links in changed documents resolve, including anchors. Claude still imports
  AGENTS.md; its entry file shrank from 168 to 11 bytes.
- All 286 existing code/scene/resource/record/vector/Markdown files outside captures remain in
  ordinary searches. Opt-in access found 200 asset import settings and 12 captured JSON files;
  explicit filtered-file searches also worked.
- This change does not edit game code, art, DESIGN.md, RULES.md, STORY.md, the adopted coding
  guide or existing checks. Concurrent protagonist-model edits are outside the owned paths.
  No game build or playtest was run for this document/search-tool change.

Counts include the new audit/reader and board row. Section-output size includes its source-range
header. Reproduce with `wc -c -w AGENTS.md EXPLORATIONS.md`, `rg --files | wc -l`, and
`python3 tools/read_section.py explorations/shared-coding-guide.md "Working standard" | wc -c`;
use `git show dccf7e2:<path>` for the old text. Inventory uses normal, non-hidden ripgrep defaults.

These sizes measure reading volume, not billed model tokens or guaranteed subscription savings.
Prompt caching, tool instructions, conversation length and model tokenizers also affect usage;
this task does not measure those.

## Sources

OpenAI documents [automatic instruction loading](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
and recommends [task-specific document reading](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra).
The actual project files and commands were the basis for this cleanup; no provider-specific
settings or new context service are needed.
