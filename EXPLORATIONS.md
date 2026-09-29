# Explorations

Every open thread on this project, one row per topic. Start or resume one in a fresh chat with
`/exploration start <topic>`. How explorations work is in AGENTS.md.

| Topic | Status | Next action | File |
|---|---|---|---|
| Battle MVP: first playable in Godot | open | Art, free camera and lit fog in (2026-09-28). Graduating toward an Alpha: a two-phase facility mission on new maps; the handover and the vault rule are open. Bryson's playtest answers still feed it | [battle-mvp.md](explorations/battle-mvp.md) |
| Battle core: turns, fog, network and hacking | open | Questions 5 and 6 remain; the MVP playtest feeds this thread next | [battle-core.md](explorations/battle-core.md) |
| Art pipeline: how 3D assets get made | open | Look set 2026-09-27 (house style in the file); Operators, guard and facility props built. Camera bots parked. The aesthetics pass runs from the environment thread | [art-pipeline.md](explorations/art-pipeline.md) |
| Environment art for the facility mission | open | The exterior map redesigned from shot 0A, access points as wall panels. Bryson plays it and says what to change | [environment-art.md](explorations/environment-art.md) |
| Wall occlusion: seeing past walls | decided | Ghosting, the conventional way (2026-09-28); built. Bryson plays with it | [wall-occlusion.md](explorations/wall-occlusion.md) |
| Environment fidelity: real walls, real ground | open | Research done: how it's done, Godot plugins, asset packs and tools. Bryson answers six questions, including whether to buy a cyberpunk kit | [environment-fidelity.md](explorations/environment-fidelity.md) |
| Terminal model for free-standing access points | parked | After the wall panels: Claude builds a monitor-on-a-podium terminal by hand, not with Meshy (Bryson, 2026-09-28) | [environment-art.md](explorations/environment-art.md) |
| Map editor for Bryson | parked | Something to build so Bryson can lay out levels himself (Bryson, 2026-09-28). Scope it when he picks it up | not started |
| The core idea and story | parked | World and premise are sufficient for gameplay exploration; resume character and plot development when Bryson returns to it | [core-idea-and-story.md](explorations/core-idea-and-story.md) |
| How exploring connects to turn-based fights | parked | Waiting on the core idea | not started |
| Between battles: the town | parked | Waiting on the story the town needs to tell; starts as one neighborhood | not started |
| Permadeath alongside an authored story | decided | Off, 2026-09-23; see DESIGN.md | [battle-core.md](explorations/battle-core.md) |

Status values: **open** (ready to pick up), **blocked** (waiting on something outside this
thread), **parked** (deliberately on hold), **decided** (conclusion has graduated to DESIGN.md
or AGENTS.md, and the file keeps the reasoning).

## Reading routes

- The build in progress is [battle-mvp.md](explorations/battle-mvp.md): the MVP spec, the placeholder map and stats, and the milestones. The game is in `game/`; README.md says how to run it.
- The design behind it is [battle-core.md](explorations/battle-core.md): what hacking is for, the working models for battle structure, hack resolution and stat axes, and the open questions. The minigame candidates are shelved at the bottom of that file.
- The 2026-09-23 decisions are in [DESIGN.md](DESIGN.md#decisions). The old "Skirmish shape" row was absorbed into the battle core on the same date.
- For the working concept, use the core exploration's [topic index](explorations/core-idea-and-story.md#topic-index).
- Read the core exploration's [latest clarifications](explorations/core-idea-and-story.md#september-22-clarifications) before treating older setting or digital-map language as current.
- For unresolved choices, use its [question guide](explorations/core-idea-and-story.md#question-guide).
- For earlier ideas and corrections, read its dated findings. Dates matter: the September 21
  physical/network battle and cyberpunk society follow the earlier virtual-world setting.
- Parked topics marked "not started" have no separate files yet; the parked core exploration
  retains its existing record.
