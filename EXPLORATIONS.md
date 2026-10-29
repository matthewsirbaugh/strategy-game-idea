# Explorations

Every open thread on this project, one row per topic. Start or resume one in a fresh chat with
`/exploration start <topic>`. How explorations work is in AGENTS.md.

| Topic | Status | Next action | File |
|---|---|---|---|
| Project token efficiency | built | Built 2026-10-14: compact guidance, section reader and scoped search; measurements in the file | [token-efficiency.md](explorations/token-efficiency.md) |
| Rulebook V1: the whole game's rules | open | V1 built. After more art pipeline work, Bryson and Claude review the 37 readings and four questions raised 2026-10-10; V2 backlog, including Astra's balance questions, is in the file | [rulebook.md](explorations/rulebook.md), [RULES.md](RULES.md), [v1-implementation-brief.md](explorations/v1-implementation-brief.md) |
| Genre basics: what the game is missing against other stealth-tactics games | open | Bryson answers report decisions 46–52 and reviews the 16 code-made choices; research filed as one V2 item (2026-10-13) | [genre-basics.md](explorations/genre-basics.md), [the report](reports/Stealth%20tactics%20basics%20gap%20analysis.md) |
| Shared coding guide: efficient, readable and modular game code | decided | Adopted 2026-10-11; use its Working standard. Action blockers implemented; review history remains below it | [shared-coding-guide.md](explorations/shared-coding-guide.md) |
| Startup performance and clearer fog of war | open | Startup and fog work built (2026-10-13). Open: how live hidden scenery behaves; lighting stays on hold | [startup-and-fog.md](explorations/startup-and-fog.md) |
| Action blockers: the rules say why an action is unavailable | open | Built. Open: two remote-availability information leaks recorded in the file | [action-blockers.md](explorations/action-blockers.md) |
| Chip categories: how AI skills are grouped | open | Explore options from Bryson's starting guess: Surveillance, Weapon Systems, Infrastructure | not started |
| Battle core: turns, fog, network and hacking | open | RULES.md is current; action-point system built. Next: tuning. Early models and shelved minigames stay in this file | [battle-core.md](explorations/battle-core.md) |
| Art direction: back to the drawing board | open | Follow DESIGN.md: realistic California city, mid-2040s; OpenBrain is the villain. Eight city/campus references adopted 2026-10-10 | [art-direction.md](explorations/art-direction.md), [city and campus gallery](art/concepts/city-and-campus-study-2026-10-10/README.md) |
| Environment assets: the pipeline, from scratch | open | 31 prop models approved by look, 2026-10-11. Next: put art in game, then story/personalities, architecture and characters | [environment-assets.md](explorations/environment-assets.md) |
| Architecture: how the buildings, walls and bridges get made | open | Tier 2, free tools and Meshy; slice plan approved and greyboxed (2026-10-18). greybox proportions approved; look approved and the kit built into the battle's buildings (2026-10-28). Next: Bryson's call | [architecture.md](explorations/architecture.md) |
| How Claude and Astra work together | decided | Agreement adopted. Use Requests for assignments/claims: 32 open; next number 33 | [claude-and-astra.md](explorations/claude-and-astra.md) |
| Character models: how the people and robots get made | open | Stylized people in a realistic world. All three Operators modeled, rigged with finger bones and in the battle (2026-10-17). Next: none assigned. Animations past V2, except the shared walk, shoot and arms-down stand | [character-models.md](explorations/character-models.md) |
| Art pipeline: how 3D assets get made | open | Old house style retired. Props use environment-assets findings; characters use character-models findings. Tool research remains useful | [art-pipeline.md](explorations/art-pipeline.md) |
| UI rethink: how the player sees and drives the battle | open | A separate Claude session and Astra (Request 32) each write independent proposals from [the prompt](explorations/ui-rethink.md#the-prompt); then compare and pick experiments | [ui-rethink.md](explorations/ui-rethink.md) |
| Visual polish: interface and Network mode | built | Built 2026-10-05; changes follow Bryson's reported play | [visual-polish.md](explorations/visual-polish.md) |
| Level design: a map that exercises everything | open | Facility yard built 2026-10-07. Next: the file's open questions | [level-design.md](explorations/level-design.md) |
| Wall occlusion: seeing past walls | decided | Conventional ghosting adopted 2026-09-28 and built | [wall-occlusion.md](explorations/wall-occlusion.md) |
| Map maker: Bryson lays out levels himself | parked | Prototype joined project 2026-10-13; future level-authoring tool. Claude proposes loading current game assets when resumed; not yet decided | [side-project-map-maker/README.md](side-project-map-maker/README.md) |
| The core idea and story | open | Round 1, quick questions, S1–S4 and team backgrounds answered. Paused 2026-10-29: Bryson is putting the game's fun first. When resumed: S5–S12 and Round 2 R2–R5 | [STORY.md](STORY.md), [core-idea-and-story.md](explorations/core-idea-and-story.md#question-guide) |
| How exploring connects to turn-based fights | parked | Waiting on the core idea | not started |
| Between battles: the town | parked | Waiting on the story the town needs; starts as one neighborhood | not started |
| Permadeath alongside an authored story | decided | Off (2026-09-23); see DESIGN.md | [battle-core.md](explorations/battle-core.md) |

Status values: **open** (ready to pick up), **blocked** (waiting on something outside this
thread), **parked** (deliberately on hold), **built** (implemented; what's left surfaces as Bryson
plays), **decided** (conclusion has graduated to DESIGN.md, RULES.md
or AGENTS.md, and the file keeps the reasoning).

## Reading routes

- RULES.md is current; [rulebook.md](explorations/rulebook.md) holds reasoning and [v1-implementation-brief.md](explorations/v1-implementation-brief.md) records V1. [battle-core.md](explorations/battle-core.md) has earlier models and shelved minigames; RULES.md wins conflicts. Battle MVP history was archived (ARCHIVE.md).
- DESIGN.md's [Decisions](DESIGN.md#decisions) are current; later dated story findings supersede earlier ones. STORY.md holds agreed lore; use the core exploration's [topic index](explorations/core-idea-and-story.md#topic-index) and [question guide](explorations/core-idea-and-story.md#question-guide) for reasoning and open choices. The September 21 physical/network battle and cyberpunk setting superseded the virtual-world setting.
- README.md routes code work. Use `python3 tools/read_section.py <file.md>` for headings, then add the exact heading to read one section. Detailed delivery history stays in the linked topic files. Topics marked "not started" have no file.
