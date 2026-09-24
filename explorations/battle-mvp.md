# Battle MVP

- Feeds: [battle-core.md](battle-core.md), [DESIGN.md decisions](../DESIGN.md#decisions).
- Status: scope and architecture agreed by Bryson, 2026-09-23. Building.
- Engine: Godot 4 (Bryson, 2026-09-23), set up for the long term rather than as a throwaway.

## The question it answers

Is the split human/AI turn, with fog of war and node hacking, fun and readable?

Bryson plays it and decides whether to pursue it. Art comes after the playtest validates it.

## Scope

| In | Out |
|---|---|
| Start menu, settings menu, pause menu | Town, story, dialogue |
| One ~12×12 map, greybox | Upgrade pipelines (builds are fixed) |
| 3 characters: a human plus an AI each | Enemy hacking, spoofing, corporations |
| 5 guards that obey the fog | Art, sound, saving |
| Speed-ordered turn queue | |
| Fog of war with last-known positions | |
| About 8 nodes: access points, doors, cameras, a turret, a data cache | |
| Context window, efficiency loss, compaction | |
| One signature ability per character | |
| Goal: breach the data cache, then extract | |

## Rules

All numbers are starting points for tuning, not balance decisions.

**Turn order.** Every unit has a speed stat. Each round, units act in speed order. A character's
turn is split: the human acts, then that character's AI acts.

**Humans.** Move up to 4 tiles, then take one action: attack (adjacent or short range) or wait.
Walls block movement and sight. A human at 0 HP is downed and out of the battle, not dead.

**The tether.** The agent runs in the backpack. An Operator within 2 tiles of an access point
can connect their AI there. If the Operator ends a move more than 2 tiles from the access point
they connected through, the AI is pulled out. Breach progress stays on the node.

**AI actions.** A connected AI takes one action per turn:

- Move along network links to any node within 3 hops. Physical distance doesn't matter.
- Hack the node it is on.
- Compact its context.
- Use its character's signature ability.

**Hacking.** Deterministic, with no dice. Each hack adds the agent's hack power (10) to the
node's breach total. When the total reaches the node's goal, the hack completes. Each hack also
fills the context window (0–100) by the node's context cost. When the context is full, only
50% of hack points count toward the goal.

**Compaction.** Uses the AI's action for that turn. Clears 75% of the current context.

**Nodes.**

| Node | Goal | Context cost | When breached |
|---|---|---|---|
| Access point | — | — | Entry point, no hack needed |
| Door | 10 | 15 | Open or lock it |
| Camera | 20 | 20 | Live vision of its area for the rest of the battle |
| Turret | 30 | 25 | Disabled |
| Data cache | 60 | 30 | Objective complete |

**Fog.** The map is always visible. Units show live only where the player has vision: the humans'
line of sight, breached cameras and probes. Anywhere else, an enemy shows as a marker at its
last-known position.

**Guards.** They patrol set routes. They act only on what they can see or last saw: chase, attack,
or investigate a last-known position. They never cheat past the fog.

**Signature abilities.** One per character, with placeholder names:

| Ability | Effect | Uses |
|---|---|---|
| Probe | Drop a probe on a node: permanent vision around it | 2 per battle |
| Locate | Reveal one enemy's live position for 2 rounds | Every 3 rounds |
| Cloak | Guards can't see this Operator for 2 rounds unless adjacent | Once per battle |

**Win and lose.** Win: breach the data cache, then get every standing Operator to the
extraction zone. Lose: all three Operators downed.

## Menus

- Title: New game, Settings, Quit.
- Settings: master volume, window mode (windowed, fullscreen), vsync. Saved between sessions.
- Pause during battle: Resume, Settings, Restart battle, Quit to title.

## Architecture (agreed 2026-09-23)

| Decision | Proposal | Why |
|---|---|---|
| Language | GDScript, with type hints | Godot's native language and what agents know best. No .NET install, and it keeps the web export open |
| Location | `game/` in this repo | Design docs and the game share one git history |
| Rules vs. visuals | The battle rules are plain data and functions with no scene nodes. The 3D scene reads that state and animates it | Rules can be tested without running the game, enemy AI can simulate moves, and saving later is easy. This is the one long-term bet |
| Content as data | Units, abilities, nodes and maps are Godot Resources (`.tres`) | Bryson can tune numbers in the editor without code |
| View | 3D scene with greybox meshes and a fixed-angle tactics camera that rotates in 90° steps | Blender art drops straight in, and height can come later. Characters can still be sprites if the art direction goes HD-2D |
| Input | Mouse and keyboard, through Godot's input actions | A controller can be added later without rewiring |
| Globals | Two autoloads: settings and scene switching | Kept minimal |
| Tests | A handful for the hack and context math, run headless, no test addon | Per AGENTS.md: only where it earns its keep |

## Build milestones

Each one runs, gets played, and is committed.

1. Project skeleton: menus, settings, a battle scene with the camera and an empty grid.
2. Physical layer: humans, guards, movement, attacks, the turn queue.
3. Fog of war and guard behavior.
4. Network layer: nodes, the tether, hacking, context, compaction.
5. Abilities, the objective, winning and losing.

## Playtest questions

1. Do the AI's turns stay quick?
2. Does human positioning and AI hacking affect each other every turn?
3. Is compaction an interesting decision, or just a chore?
4. Does the fog create tension without frustration?
5. After losing, do you want to go again?

## Findings

None yet.
