# Explorations

Every open thread on this project, one row per topic. Start or resume one in a fresh chat with
`/exploration start <topic>`. How explorations work is in AGENTS.md.

| Topic | Status | Next action | File |
|---|---|---|---|
| Rulebook V1: the whole game's rules | open | V1 implemented from Astra's plan (2026-10-04), not yet played. Next: Bryson playtests, and answers the 37 implementation readings and choices listed in rulebook.md (the full sweep's 38 and 39 were accepted, 2026-10-05). V2 items are listed there too | [rulebook.md](explorations/rulebook.md), [RULES.md](RULES.md), [v1-implementation-brief.md](explorations/v1-implementation-brief.md) |
| Chip categories: how AI skills are grouped | open | Side assignment from the rulebook (2026-10-04). Bryson's starting guess: Surveillance, Weapon Systems, Infrastructure. Explore options | not started |
| Battle MVP: first playable in Godot | open | V1 replaced the MVP's rules, map and stats (2026-10-04); the file keeps them as history. Graduating toward an Alpha: a two-phase facility mission. The handover is decided (RULES.md rules 47–48) and its data is built; the vault is out of V1 | [battle-mvp.md](explorations/battle-mvp.md) |
| Battle core: turns, fog, network and hacking | open | Turns, context and hacking now live in RULES.md, and the AP action system is built (2026-10-04). Left: the tuning pass. The shelved minigame candidates stay in the file | [battle-core.md](explorations/battle-core.md) |
| Art pipeline: how 3D assets get made | open | Look set 2026-09-27 (house style in the file); Operators, guard and facility props built. Camera bots parked. The aesthetics pass runs from the environment thread | [art-pipeline.md](explorations/art-pipeline.md) |
| Environment art for the facility mission | open | The exterior map redesigned from shot 0A, access points as wall panels. Bryson plays it and says what to change | [environment-art.md](explorations/environment-art.md) |
| Visual polish: interface and Network mode | open | Playtest pass built 2026-10-05: hover card, condensed unit panel that follows clicks, scan badges for Breached devices, team and enemy markers in the network view, nested menus. Then the menus' overhaul, the two halves of a turn, AI pins and labels that don't overlap. Bryson plays it | [visual-polish.md](explorations/visual-polish.md) |
| Level design: a map that exercises everything | open | The facility yard map built from the research (2026-10-07): three layers on three networks, seven guards, combos placed on purpose. Bryson plays it and answers the open questions in the file | [level-design.md](explorations/level-design.md) |
| Wall occlusion: seeing past walls | decided | Ghosting, the conventional way (2026-09-28); built. Bryson plays with it | [wall-occlusion.md](explorations/wall-occlusion.md) |
| Environment fidelity: real walls, real ground | open | Second pass built (2026-09-30): characters lit by the scene, painted walls and ground, signs, the city around the map. Bryson plays it: how it feels, the frame rate, and whether Godot has enough juice | [environment-fidelity.md](explorations/environment-fidelity.md), [environment-style-study.md](explorations/environment-style-study.md) |
| Terminal model for free-standing access points | parked | After the wall panels: Claude builds a monitor-on-a-podium terminal by hand, not with Meshy (Bryson, 2026-09-28) | [environment-art.md](explorations/environment-art.md) |
| Map editor for Bryson | parked | Something to build so Bryson can lay out levels himself (Bryson, 2026-09-28). Scope it when he picks it up | not started |
| The core idea and story | parked | World and premise are sufficient for gameplay exploration; resume character and plot development when Bryson returns to it | [core-idea-and-story.md](explorations/core-idea-and-story.md) |
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
