# Battle MVP

- Feeds: [battle-core.md](battle-core.md), [DESIGN.md decisions](../DESIGN.md#decisions).
- Status: scope and architecture agreed by Bryson, 2026-09-23. All five milestones built
  2026-09-24, with fixes on 2026-09-27. Art, the free camera and the lit fog went in on
  2026-09-28 (Findings). Graduating toward an Alpha; Bryson's playtest answers still feed it.
- 2026-10-04: the V1 build replaced the MVP's rules, map and stats. The current rules are in
  [RULES.md](../RULES.md), what V1 built in the [V1 brief](v1-implementation-brief.md), and the
  code's structure in [README.md](../README.md). Sections marked below are kept as history.
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

The table is the scope as agreed. Since then, at Bryson's request, the models and textures
replaced the greybox (2026-09-28), ahead of the playtest.

## Rules

> 2026-10-04: superseded by V1. The current rules are in [RULES.md](../RULES.md).

All numbers are starting points for tuning, not balance decisions.

**Turn order.** Every unit has a speed stat. Each round, units act in speed order. A character's
turn is split: the human acts, then that character's AI acts.

**Humans.** Move up to 4 tiles, then take one action: attack (adjacent or short range) or wait.
Walls block movement and sight. A human at 0 HP is downed and out of the battle, not dead.

**The tether.** The agent runs in the backpack. An Operator within 2 tiles of an access point
can connect their AI there. If the Operator ends a move more than 2 tiles from the access point
they connected through, the AI is pulled out. Breach progress stays on the node.

**AI actions.** A connected AI takes one action per turn (changed 2026-09-29: it can now move
and then act, and the AI's half can come before the Operator's; see
[battle-core.md](battle-core.md#2026-09-29--context-as-a-battle-long-resource-and-interim-turn-rules-bryson)):

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

How the fog looks (Bryson, 2026-09-28): the parts of the level no one can see keep their shape
and texture but sit in the dark, and enemies there are hidden entirely. When the team sees a
place, it lights up like an overhead light turning on.

**Guards.** They patrol set routes. They act only on what they can see or last saw: chase, attack,
or investigate a last-known position. They never cheat past the fog.

Placeholder fog rules Claude chose while building (2026-09-24), each easy to change: a hidden
enemy in the way stops a move one tile short, and a move that reveals an enemy can't be undone.
The pre-mission intel that showed every guard's post at the start was removed on 2026-09-28,
since Bryson wants enemies in the fog unseen.

**Network view** (Bryson, 2026-09-24). The network layer isn't visible at all times. It appears
automatically during the AI phase, is hidden during the human phase, and can be shown with a button
(N). While it's up it must read as clearly separate from the map, so the map behind it is blurred and
washed in light blue. Claude's reading, easy to change: during the human phase N still lets you peek
at the network, and clicks on the map are ignored while peeking.

Showing the network is a transition (Bryson, 2026-09-24): the camera tilts to look straight down on
the field, the network fades in over the map so the player sees it line up, and then the map fades
behind it. Hiding runs the same steps in reverse.

**Action menu** (Bryson, 2026-09-24). A turn doesn't start in movement. The active unit is
highlighted, and clicking it opens a menu of what it can do: move, attack (only when an enemy is in
range), end the turn and so on. The AI phase works the same way through the AI's token on the
network. Claude's additions: the menu reopens after a move, right-click steps back, and Undo move
lives in the menu.

**Access zones over move tiles** (Bryson, 2026-09-30). The blue move tiles hid the faint access
zones, so a move could land one tile outside a zone unnoticed. Fixed the way XCOM 2 shows ranges:
the zones get a glowing outline drawn above the move tiles, and hovering a move tile says "AI can
plug in here" (or, when already connected, whether the AI stays connected or gets pulled out).

**Signature abilities.** One per character, with placeholder names:

| Ability | Effect | Uses |
|---|---|---|
| Probe | Drop a probe on a node: permanent vision around it | 2 per battle |
| Locate | Reveal one enemy's live position for 2 rounds | Every 3 rounds |
| Cloak | Guards can't see this Operator for 2 rounds unless adjacent | Once per battle |

**Win and lose.** Win: breach the data cache, then get every standing Operator to the
extraction zone. Lose: all three Operators downed.

## Facility exterior map

> 2026-10-04: superseded by V1. The test map now follows the
> [V1 brief](v1-implementation-brief.md), and `mvp.tres` is gone: the tests build small maps of
> their own.

Since 2026-09-28 the battle plays `game/content/maps/facility_exterior.tres`, the first part of
the facility mission, laid out from the exterior establishing shot (0A) at Bryson's request.
The MVP map below stays as the map the rules tests run on.

```
      0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
  0   # # # # # # B B B B B  B  B  B  B  B  B  B  B  B
  1   # . . . . . B B B B B  B  B  B  B  B  B  B  B  B
  2   # . . . . . B B B B B  B  B  B  B  B  B  B  B  B
  3   # . . . . . B B f B B  B  B  B  B  B  B  B  B  B
  4   # . 4 . . . . . . X X  .  .  .  .  .  B  B  B  B
  5   # . . . . . . . 2 . .  3  t  .  .  .  g  B  B  B
  6   b . . . . . . . . . .  .  .  .  .  X  B  B  B  B
  7   # . . . . . . . . . .  .  .  .  .  X  B  B  B  B
  8   # . . . . . . . . . .  .  #  #  .  .  z  B  B  B
  9   # . . . . . . . . . .  .  #  #  .  .  B  B  B  B
 10   # . . . . . . . . . .  .  .  5  .  .  c  B  B  B
 11   # . . . . . . . 1 . .  .  .  #  #  #  B  B  B  B
 12   # # d # a # # . . # e  #  #  #  #  #  B  B  B  B
 13   , , , , , , , , , , ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
 14   , P P , , , , , , , ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
 15   , P , , , , , , , , ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
```

`B` is a building (the tower at the top, the dock building at the right), `,` is the street,
the rest as in the MVP legend below. The team starts on the street. Two ways in: the open vehicle
lane past the guard booth (5–6,12) and its guard, or the service door d into the side yard. The
exits are the tower's glass doors and the loading dock door. Crates and the van are obstacles.

| Node | Kind | Role |
|---|---|---|
| a | Access point | A panel on the street side of the wall, by the start. Safe. Reaches the service door and the gate camera |
| b | Access point | A panel on the side yard's wall |
| c | Access point | A panel on the dock building, beside a patrol. One hop from the cache |
| d | Door | The service door into the side yard |
| e | Camera | Over the gate, watching the lane and courtyard |
| f | Camera | On the tower, watching the entrance plaza |
| g | Camera | On the dock building, watching the dock |
| t | Turret | Covers the entrance plaza |
| z | Data cache | The dock's security rack, beside the dock door |

Network links: a–d, a–e, d–b, b–f, e–f, f–t, t–g, g–z, c–z, c–g. The cache is 5 hops from the
safe panel, 4 from the side yard's, and 1 from the dock's.

A node set into a wall line, with wall on both sides, is part of the wall: panels and wall
cameras block sight like the wall, and are used from the tile in front. An access point in the
open will be a terminal (Bryson, 2026-09-28).

## Map sketch

> 2026-10-04: history. `game/content/maps/mvp.tres` was deleted in the V1 build. The map legend
> now lives in `game/rules/map_data.gd`.

Claude's placeholder, drawn 2026-09-24 at Bryson's request. Level layout is Bryson's call, so
mark it up freely. The live copy is `game/content/maps/mvp.tres`; editing its layout changes
the game directly.

```
      0 1 2 3 4 5 6 7 8 9 10 11
  0   X X . . . . . . # . .  .
  1   X X . . c . . f # . z  .
  2   . . . . . . 2 . # . .  .
  3   # # # d # # . . # # #  #
  4   . . . . . . . . . t .  .
  5   . e . . # . b . . . 3  .
  6   . . 1 . . . . . # . .  .
  7   . . . . . . . . . . .  .
  8   # # . # # . . # # . #  #
  9   . . . # . 4 . . # . .  .
 10   . 5 . # . . a . # P P  .
 11   . . . . . . . . . . P  .
```

`.` floor, `#` wall, `X` extraction, `P` Operator start, `1`–`5` guard start. Letters are
network nodes.

| Node | Kind | Role |
|---|---|---|
| a | Access point | Near the start and fairly safe. Reaches the atrium camera and the door |
| b | Access point | In the atrium, in the turret's line of fire. One hop from the cache |
| c | Access point | By the exit, on the north patrol's route. One hop from the cache |
| d | Door | Shortcut from the atrium to the exit corridor |
| e | Camera | Watches the atrium |
| f | Camera | Watches the exit corridor |
| t | Turret | Covers the atrium |
| z | Data cache | In a sealed server room; reachable only through the network |

Network links: a–e, a–d, e–t, t–b, b–z, d–f, f–c, c–z. The cache is 4 hops from the safe
access point and 1 hop from the two exposed ones. That's the intended tension: safe and slow, or
exposed and fast.

Guard patrols loop through these waypoints after their start tile: guard 1 (7,7) (7,4) (2,4);
guard 2 (2,2) (2,0) (6,0); guard 3 (11,7) (7,7); guard 4 (7,11) (4,11); guard 5 (2,7) (0,4).

With the default camera, the start (bottom right of the sketch) is at the bottom of the screen
and the exit (top left) is at the top.

## Placeholder stats

> 2026-10-04: superseded by V1. The current numbers are in [RULES.md, V1 setup](../RULES.md#v1-setup).

Placeholders for tuning (Bryson, 2026-09-24: "placeholder numbers are fine"). Distances are in
tiles with no diagonals. Attacks beyond 1 tile need line of sight, and damage is deterministic.

| Unit | HP | Move | Damage | Range | Speed | Sight |
|---|---|---|---|---|---|---|
| Alpha (Probe) | 10 | 5 | 3 | 3 | 7 | 5 |
| Bravo (Locate) | 12 | 4 | 4 | 4 | 6 | 5 |
| Charlie (Cloak) | 12 | 4 | 6 | 1 | 4 | 5 |
| Guard (×5) | 8 | 4 | 3 | 3 | 5 | 5 |
| Turret | 10 | 0 | 4 | 5 | 3 | 5 |

Alpha, Bravo and Charlie are placeholder code names. A human moves, then acts; attacking ends
the turn, and a move can be undone until then. A guard that spots an Operator while patrolling
is alerted and acts on its next turn rather than shooting immediately.

## Menus

> 2026-10-04: the title's first button now reads "Deploy to facility" and opens the loadout
> screen; the pause menu says "Restart phase".

- Title: New game, Settings, Quit.
- Settings: master volume, window mode (windowed, fullscreen), vsync. Saved between sessions.
- Pause during battle: Resume, Settings, Restart battle, Quit to title.

## Architecture (agreed 2026-09-23)

> 2026-10-04: the decisions below stand, but abilities became chips and loadouts, gathered in
> `content/battle.tres`. The current structure is in [README.md](../README.md).

| Decision | Proposal | Why |
|---|---|---|
| Language | GDScript, with type hints | Godot's native language and what agents know best. No .NET install, and it keeps the web export open |
| Location | `game/` in this repo | Design docs and the game share one git history |
| Rules vs. visuals | The battle rules are plain data and functions with no scene nodes. The 3D scene reads that state and animates it | Rules can be tested without running the game, enemy AI can simulate moves, and saving later is easy. This is the one long-term bet |
| Content as data | Units, abilities, nodes and maps are Godot Resources (`.tres`) | Bryson can tune numbers in the editor without code |
| View | 3D scene with greybox meshes and a fixed-angle tactics camera that rotates in 90° steps. Changed by Bryson, 2026-09-28: a free, RTS-style camera, still over a grid | Blender art drops straight in, and height can come later. Characters can still be sprites if the art direction goes HD-2D |
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

### 2026-09-28 — Fog as light, a free camera, real scale (Bryson's list; Claude built it; scripted runs and screenshots, not played)

- Bryson's list, in no particular order: colored rings under the units; the map looked crowded
  and short, with characters taller than the walls; enemies showed see-through in the fog and
  shouldn't show at all; the fog should keep the level's shape and texture, darkened, and light up
  like an overhead light when the team walks in; some sign of a ceiling, as The Sims does; drop
  the isometric camera for a free RTS-style one ("we're still on a grid"); and the models and
  set don't look like one world.
- Built: each unit stands on a ring in its UI color. Unseen enemies are hidden; a last-seen spot
  is a red ring with the name. Unseen tiles and walls are dark, seen ones brighter than their
  texture, and a tile coming into view flickers on like a fluorescent tube.
- Scale: a tile is now 1.5 m, so a 1.8 m person has room, and walls stand 2.8 m. Walls between
  the camera and what it looks at drop to a stub, like The Sims; not when looking steeply down.
  Tile counts in the rules are unchanged.
- Camera: left-drag orbits freely, middle- or Option-drag and WASD pan, Q and E turn smoothly, the
  wheel or a pinch zooms from 3 m to 45 m. Labels stay the same size on screen at any zoom.
  Remapped by Bryson the same day: left-drag pans and right-drag orbits. A right-click without a
  drag still steps back, and a click without a drag still selects.
- The cutaway walls were replaced the same day by ghosting (decision in
  [wall-occlusion.md](wall-occlusion.md)).
- Open, for the aesthetics pass: the ceiling, and the look as a whole. Recorded in
  [environment-art.md](environment-art.md).

### 2026-09-27 — Toward an Alpha: a two-phase facility mission (Bryson)

- "The 12x12 was just to demonstrate the smallest version of the game. We're slowly graduating
  to an Alpha build," with new maps.
- The mission Bryson imagines: the team infiltrates a corporate facility. Outside, they avoid
  guards to get into the building; then the game moves inside, where they reach a vault while
  avoiding turrets, cameras and guards.
- The vault holds an access point. The Operator has to be inside the vault for their AI to
  reach it, and once inside has to stay within a certain distance.
- Open, not designed yet: how the outside map hands over to the inside one (what carries
  across, whether it is one battle or two), map sizes, and how the vault rule differs from the
  existing tether. The art for both phases is in [environment-art.md](environment-art.md).

### 2026-09-27 — Fixes from Bryson's bug list and Claude's code review (Claude; tests, bot runs and scripted clicks in the cloud, not played)

- Guards plan only around Operators they can see. Claude's choice, easy to change: like players,
  they walk into a hidden Operator and stop one tile short, which puts it in plain view.
- Stacked AI tokens are clicked where they're drawn, and the white ring marks the active AI's own
  token.
- The rules refuse illegal actions: only the active unit acts, in its phase, and an AI gets one
  action per turn.
- A broken map shows its errors on screen, naming the file and field, instead of loading corrupted.
  The objective is the map's one data cache, whatever its letter.
- AI destinations come from one cached network search, so large networks stay fast.
- From the code review: a move that shows a guard's last-seen spot to be empty can't be undone,
  like one that reveals an enemy. A destroyed turret's node can't be hacked and an offline turret
  can't be shot. One probe per node. Node labels drop below stacked AIs, and the access zones on
  the map use the active Operator's own tether range.

### 2026-09-24 — Milestone 5 build notes (Claude; scripted and bot runs, not yet played by Bryson)

- Probe, Locate and Cloak work as AI actions from the menu. Locate opens a second menu listing
  the guards you can't currently see.
- The objective now drives the win: breach the cache, then every Operator still standing on the
  exit tiles. An objective line tracks it at the top left.
- A simple bot (fight what's in range, send the AIs to the cache, then run for the exit) won in
  round 13: cache breached in round 5, then Alpha and Charlie went down on the way out and Bravo
  extracted alone. Two things for Bryson to weigh: with three AIs stacking hacks the cache falls
  fast, and the win currently allows leaving downed teammates behind.

### 2026-09-24 — Bryson's first playtests

- Camera: "great".
- Asked for an action menu instead of turns starting in movement, and for the overhead transition
  into the network view. Both built the same day (see Rules).
- After the transition: the network layer finally feels like a real mechanic.
- Fix requested: tiles lit up under the cursor even over the menu. Indicators must only show when
  intended; Bryson considers this necessary for reviewing builds, not polish. Now the hover
  highlight only marks tiles a click would act on (the active unit, valid move tiles, attackable
  enemies, reachable nodes) and never while the cursor is over the menu or a panel.

### 2026-09-24 — Milestone 2 build notes (Claude, scripted run; not yet played by Bryson)

- A scripted run with real clicks: Alpha and Bravo move, the turn queue follows speed, Guard 4
  patrols into view of the loading dock in round 1, closes in and shoots in round 2, and Alpha
  and Bravo focus fire to down it in round 3.
- On this map the first fight happens right at access point a, the "safe" one. Worth deciding
  whether that's the right opening.
- Enemy turns currently pan the camera to guards anywhere on the map. Fog of war in milestone 3
  should limit the camera to guards the player can see.

### 2026-09-24 — Milestones 3 and 4 build notes (Claude, scripted runs; not yet played by Bryson)

- Fog: unseen guards now act instantly, so enemy turns take about a quarter of the time.
- Network: in a scripted run, Alpha's AI connects at access point a, hops to the atrium camera and
  breaches it in two hacks; the team's vision goes from 35 to 61 tiles and a guard in the fog
  shows up live.
- Choices made while building, easy to change: the AI connects automatically when its human ends
  their part of the turn in range; being pulled out keeps the AI's context (it is still running
  in the backpack); and a breached door can be toggled open or locked by an AI sitting on it.
