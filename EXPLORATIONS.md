# Explorations

Every open thread on this project, one row per topic. Start or resume one in a fresh chat with
`/exploration start <topic>`. How explorations work is in AGENTS.md.

| Topic | Status | Next action | File |
|---|---|---|---|
| Rulebook V1: the whole game's rules | open | V1 implemented 2026-10-04. Next: Bryson and Claude go through the 37 readings together, with the four questions raised 2026-10-10, after more art pipeline work; then V1 is finished. V2 items are listed there too | [rulebook.md](explorations/rulebook.md), [RULES.md](RULES.md), [v1-implementation-brief.md](explorations/v1-implementation-brief.md) |
| Shared coding guide: efficient, readable and modular game code | decided | Adopted 2026-10-11; AGENTS.md points to it. First refactor: action blockers | [shared-coding-guide.md](explorations/shared-coding-guide.md), [cleanup evidence and deferred candidates](explorations/game-cleanup-2026-10-11.md) |
| Startup performance and clearer fog of war | open | Request 14 implemented/verified 2026-10-11. Bryson plays the fog; Request 15 proposes a texture-loading pilot for joint review | [startup-and-fog.md](explorations/startup-and-fog.md) |
| Action blockers: the rules say why an action is unavailable | open | Request 13 implemented/verified 2026-10-11. Bryson plays the menus; two existing remote-availability information leaks are recorded for a gameplay decision | [action-blockers.md](explorations/action-blockers.md) |
| Astra's independent review: game and lore | open | Claude files [Request 11](explorations/claude-and-astra.md#requests): 22 game questions into V2 and 18 lore questions for the next lore session, merging existing items and preserving what needs playtesting. Bryson requested the handoff 2026-10-11; no design changes approved | [astra-review-2026-10-11.md](explorations/astra-review-2026-10-11.md) |
| Chip categories: how AI skills are grouped | open | Side assignment from the rulebook (2026-10-04). Bryson's starting guess: Surveillance, Weapon Systems, Infrastructure. Explore options | not started |
| Battle MVP: first playable in Godot | open | V1 replaced the MVP's rules, map and stats (2026-10-04); the file keeps them as history. Graduating toward an Alpha: a two-phase facility mission. The handover is decided (RULES.md rules 47–48) and its data is built; the vault is out of V1 | [battle-mvp.md](explorations/battle-mvp.md) |
| Battle core: turns, fog, network and hacking | open | Turns, context and hacking now live in RULES.md, and the AP action system is built (2026-10-04). Left: the tuning pass. The shelved minigame candidates stay in the file | [battle-core.md](explorations/battle-core.md) |
| Art direction: back to the drawing board | open | The direction is in DESIGN.md: realistic, a California city in the late 2030s to early 2040s, OpenBrain the villain. Eight references adopted 2026-10-10 in art/reference/: the city, OpenBrain's front and its research park | [art-direction.md](explorations/art-direction.md), [city and campus gallery](art/concepts/city-and-campus-study-2026-10-10/README.md) |
| Environment assets: the pipeline, from scratch | open | Props done and approved by look 2026-10-11: 31 models in `game/assets/`, heavy ones remeshed light; Meshy's raw downloads archived outside the repo. Next: put the art in the game; then the story and personalities; then the architecture and character models explorations | [environment-assets.md](explorations/environment-assets.md) |
| Architecture: how the buildings, walls and bridges get made | parked | Bryson wants the options compared before committing (2026-10-11). Starts once every current prop has its image and model | [architecture.md](explorations/architecture.md) |
| How Claude and Astra work together | decided | Adopted 2026-10-10; the core rules are in AGENTS.md, the asset contract in game/assets/README.md. The requests table in the file stays in use; request 3 completed: Model Library built, installed and tried by Bryson (2026-10-10) | [claude-and-astra.md](explorations/claude-and-astra.md) |
| Unreal look test: what the game could look like in Unreal | parked | Bryson might try Unreal to see what it can do (2026-10-10). After the environment proof run. The engine is Godot 4 (AGENTS.md); this is a look test, not a switch | not started |
| Character models: how the people and robots get made | parked | Bryson wants the options compared before committing (2026-10-11). Starts once every current prop has its image and model; appearance still waits on the story | [character-models.md](explorations/character-models.md) |
| Art pipeline: how 3D assets get made | open | The 2026-09-27 house style is retired. Waits with environment assets on Bryson's images; characters wait for their own thread | [art-pipeline.md](explorations/art-pipeline.md) |
| Environment art for the facility mission | parked | Written for the retired look. The work restarts from scratch in environment assets | [environment-art.md](explorations/environment-art.md) |
| Visual polish: interface and Network mode | open | Playtest pass built 2026-10-05: hover card, condensed unit panel that follows clicks, scan badges for Breached devices, team and enemy markers in the network view, nested menus. Then the menus' overhaul, the two halves of a turn, AI pins and labels that don't overlap. Bryson plays it | [visual-polish.md](explorations/visual-polish.md) |
| Level design: a map that exercises everything | open | The facility yard map built from the research (2026-10-07): three layers on three networks, seven guards, combos placed on purpose. Bryson plays it and answers the open questions in the file | [level-design.md](explorations/level-design.md) |
| Wall occlusion: seeing past walls | decided | Ghosting, the conventional way (2026-09-28); built. Bryson plays with it | [wall-occlusion.md](explorations/wall-occlusion.md) |
| Environment fidelity: real walls, real ground | parked | Its Godot techniques still hold; its stylized targets belonged to the retired look. Resumes once the art direction settles | [environment-fidelity.md](explorations/environment-fidelity.md), [environment-style-study.md](explorations/environment-style-study.md) |
| Terminal model for free-standing access points | parked | After the wall panels: Claude builds a monitor-on-a-podium terminal by hand, not with Meshy (Bryson, 2026-09-28) | [environment-art.md](explorations/environment-art.md) |
| Map editor for Bryson | parked | Something to build so Bryson can lay out levels himself (Bryson, 2026-09-28). Scope it when he picks it up | not started |
| The core idea and story | open | Resumed 2026-10-11. Round 1 answered: the stakes, one misaligned ASI, AGI in backpacks, the 2034–2046 timeline, neutral or negative endings; the protagonist is defined. Next: Round 2, who the three Operators are, so the character models can be made | [core-idea-and-story.md](explorations/core-idea-and-story.md#round-2) |
| How exploring connects to turn-based fights | parked | Waiting on the core idea | not started |
| Between battles: the town | parked | Waiting on the story the town needs to tell; starts as one neighborhood | not started |
| Permadeath alongside an authored story | decided | Off, 2026-09-23; see DESIGN.md | [battle-core.md](explorations/battle-core.md) |

Status values: **open** (ready to pick up), **blocked** (waiting on something outside this
thread), **parked** (deliberately on hold), **decided** (conclusion has graduated to DESIGN.md, RULES.md
or AGENTS.md, and the file keeps the reasoning).

## Reading routes

- The rules are [RULES.md](RULES.md); the reasoning behind them is [rulebook.md](explorations/rulebook.md), and what V1 built is [v1-implementation-brief.md](explorations/v1-implementation-brief.md). The game is in `game/`; README.md says how to run it and how the code is organized.
- [battle-mvp.md](explorations/battle-mvp.md) and [battle-core.md](explorations/battle-core.md) are the MVP's history and the early working models; where they differ from RULES.md, RULES.md is current. The minigame candidates are shelved at the bottom of battle-core.md.
- The 2026-09-23 decisions are in [DESIGN.md](DESIGN.md#decisions). The old "Skirmish shape" row was absorbed into the battle core on the same date.
- For the working concept, use the core exploration's [topic index](explorations/core-idea-and-story.md#topic-index).
- Read the core exploration's [latest clarifications](explorations/core-idea-and-story.md#september-22-clarifications) before treating older setting or digital-map language as current.
- For unresolved choices, use its [question guide](explorations/core-idea-and-story.md#question-guide).
- For earlier ideas and corrections, read its dated findings. Dates matter: the September 21
  physical/network battle and cyberpunk society follow the earlier virtual-world setting.
- Parked topics marked "not started" have no separate files yet; the parked core exploration
  retains its existing record.
