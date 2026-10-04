# V1 implementation brief

- Written: 2026-10-04, by Claude, at the end of the rulebook sessions.
- Purpose: a hand-off. Another AI drafts an implementation plan from this, and a third
  implements it. Bryson reviews the plan before anything is built.
- Source of truth for the rules: [RULES.md](../RULES.md). This brief doesn't restate them. It
  says what V1 includes, what changes from the current build, the test map, and the defaults
  Claude filled in that Bryson hasn't reviewed.
- Reasoning behind the rules: [rulebook.md](rulebook.md). Read only if a rule's intent is unclear.

## Read first

1. [AGENTS.md](../AGENTS.md): how we work. Architecture is designed together with Bryson, never
   decided by an agent alone, so the plan proposes and Bryson decides.
2. [RULES.md](../RULES.md), all of it. The full definitions at the end carry the edge cases.
3. This brief.
4. [battle-mvp.md](battle-mvp.md), "Architecture (agreed 2026-09-23)": the existing structure
   (rules as plain data and functions with no scene nodes, content as `.tres` resources, a 3D
   view that reads the rules state).

## What V1 is for

Testing the systems, not progression. Bryson plays a single standalone battle with fixed
loadouts and judges whether the action economy, stealth, hacking and devices are fun. Every
number is a placeholder he'll tune by playing.

## In and out

| In V1 | Out of V1 (V2 or later) |
|---|---|
| Everything numbered in RULES.md, rules 1–53 | Progression, shops, the town, caches |
| The V1 setup section: loadouts, robots, numbers | Network opposition: ICE, daemons, security hubs |
| The device sheet and the V1 chips | Enemy AIs, enemy types and traits |
| One test battle on the map below | The harness, post-training, the questionnaire |
| A loadout screen for swapping chips and gear between test runs | The facility interior, the vault, the second phase |
| | Electric fences (see Open items) |

## What changes from the current build

The current build (`game/`) predates the rulebook. The main differences:

| Area | Current build | V1 |
|---|---|---|
| Turn structure | Operator moves then attacks; the AI half runs as a separate block | Operator and AI spend separate AP pools, interleaved freely in one turn |
| Operator actions | Move up to N tiles, then attack or wait | 8 AP: movement, sprint, peek, doors, deploy AI, tie up, gadgets; one shot outside AP that doesn't end the turn; overwatch |
| Health | HP and damage | No enemy HP: a hit stuns. Operators go down after one hit plus armor |
| AI actions | Move up to 3 hops plus one action; Probe, Locate, Cloak abilities | 2 AP; move (1 AP, up to 3 hops), hack, compact (1 AP); refunds; shared compute; chips |
| Abilities | Probe, Locate, Cloak with uses and cooldowns | Chips: Locate, Predict, Extended thinking, Subagent, three exploits. Probe and Cloak are gone |
| Context | Skills cleared on compaction | Chips degrade one step per compaction; a crash is a forced compaction plus a reboot turn |
| Vision | Flat radius in every direction | Two-tier cones (seen, noticed), light and dark, move preview of risky tiles |
| Cameras | Only vision for the player once hacked | Enemy cameras spot Operators; Breached cameras become the team's |
| Guards | Patrol, chase, attack with damage | Patrol, investigate, alerted, aim then fire, search; caution; find and free bodies |
| Sound | None | Device sound radii, counted in walking steps |
| Devices | Access point, door, camera, turret, cache | The full device sheet with power, activate and lock |
| Network | One network, fully visible | Several networks per map, each revealed on first connection; power hub circuits |
| Bodies | None | Tie up, carry, hide in receptacles, waking and raising alerts |
| Robots | None | Drone and dog bot: own AP, turn order, relays |
| Losing | Battle ends | Restart the current phase from its entry snapshot |

## The test map (Claude's placeholder)

Level layout is Bryson's call; he asked Claude for this draft to mark up. It modifies
`game/content/maps/facility_exterior.tres` and plays as a standalone battle: breach the cache,
then extract. In the full game this map is phase 1 of the facility mission.

```
      0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
  0   # # # # # # B B B B B  B  B  B  B  B  B  B  B  B
  1   # . . . . . B B B B B  B  B  B  B  B  B  B  B  B
  2   # . . . . . B B B B B  B  B  B  B  B  B  B  B  B
  3   # . . . . . B B f B B  B  B  B  w  B  B  B  B  B
  4   # . 4 . . j . . . X X  .  .  .  .  k  B  B  B  B
  5   # . . . . . . . 2 . .  3  t  .  .  .  g  B  B  B
  6   b . . . . . . r . . .  .  .  .  .  X  B  B  B  B
  7   # . . . . . . . . . .  .  .  .  .  X  o  B  B  B
  8   # . . . . . . . . . .  .  #  #  .  .  z  B  B  B
  9   # . . . . . . . . . .  m  #  #  .  .  s  B  B  B
 10   # . . . . . . . . . .  .  .  5  .  .  c  B  B  B
 11   # h . . . . . . 1 . .  i  .  .  v  .  B  B  B  B
 12   # # d # a p # . . # e  #  #  #  #  #  B  B  B  B
 13   , , , , , , , , , , ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
 14   , P P , , , , , , , ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
 15   , P , , , , , , , , ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
```

Changes from the current exterior: lights on the four floodlight poles, a phone in the guard
booth, a power hub on the tower, a generator by the crates, an ad screen on the dock building,
an electric car parked in the lane, the delivery van as a one-tile diesel truck, the dock's
loading door as an automatic door, the dock camera upgraded to night vision, and the network
split in two.

| Node | Device | Network | Notes |
|---|---|---|---|
| a | Access point | Street | By the start. Safe |
| b | Access point | Facility | Side yard wall |
| c | Access point | Facility | Dock building, beside a patrol. One hop from the cache |
| d | Door | Street | Service door into the side yard |
| e | Camera | Street | Over the gate |
| f | Camera | Facility | On the tower, watching the plaza |
| g | Night-vision camera | Facility | On the dock, watching the cache. Sees in a blackout |
| t | Turret | Facility | Covers the plaza |
| z | Data cache | Facility | The objective |
| w | Power hub | Facility | On the tower wall |
| h, i, j, k | Light | Facility (h, j, k); Street (i) | The floodlight poles |
| p | Phone | Street | In the guard booth |
| m | Machine | Facility | Generator by the crates |
| s | Ad screen | Facility | On the dock building, facing the courtyard |
| r | Electric car | Street | Parked facing south. Driving it runs down guard 1's patrol |
| v | Diesel truck | Facility | Parked facing north. Driving it runs up guard 5's patrol, and wakes everyone in range |
| o | Automatic door | Facility | The loading dock door |

- Street network links: a–d, a–e, e–p, e–i, i–r.
- Facility network links: b–h, b–j, b–f, f–w, f–t, w–k, t–g, g–z, g–o, c–z, c–g, c–s, s–m,
  m–v. The cache is 4 hops from b and 1 from c, as before.
- The street network reaches no facility node, so the facility network needs an Operator at b
  or c.
- Hub w's circuit: lights h, i, j, k; cameras f, g; ad screen s; automatic door o. Cutting it
  blacks out the yard, turns off both cameras (each a lure), which is the way past the
  night-vision camera g, and stops the dock door.
- Zones: Street (rows 13–15), Side yard (columns 1–5, rows 1–11), Plaza (columns 6–15, rows
  4–7), Courtyard (columns 6–15, rows 8–11).
- Guards and patrols are unchanged from the current exterior. Extraction is the X tiles.
- Facings: car r south, truck v north, camera e north, the rest as in the current map.

## Defaults Claude filled in, not yet reviewed by Bryson

The rules leave these unstated, and an implementation needs an answer. Each is Claude's
placeholder; flag them in the plan so Bryson can confirm or change them.

1. Night: unlit tiles on the test map are dark, so the floodlights matter.
2. Searching: an alerted guard that loses sight walks to the last-known position, searches there
   for 2 turns, then returns to its patrol.
3. A guard that wakes untied becomes alerted, and its zone goes on caution.
4. Enemy turrets behave like guards with a camera's cone and no movement: alerted on sight, aim,
   then fire next turn.
5. Robots spend 1 AP per tile, can't sprint, can't open doors and can't carry bodies.
6. The dog bot's stun: an adjacent enemy, 1 of the robot's AP, once per battle.
7. Vehicles occupy one tile.
8. Predict draws each predicted guard's next path as a ghost line, ending in its aim line if it
   will aim.
9. The loadout screen is a test tool, opened before the battle starts.

## Open items the plan should flag, not decide

1. Electric fences can't stun anyone under the current rules, because a fence is a wall and
   nothing moves into a wall. Left off the test map until Bryson decides how they work.
2. Every other "Open" in RULES.md's full definitions.

## UI the rules require

Listed so the plan doesn't miss them. Visual design is Bryson's direction, and the menus are due
an aesthetic overhaul (see [visual-polish.md](visual-polish.md)).

- Turn order bar, with the player choosing among tied Operators.
- AP for the Operator and the AI, the context ring, chip panel with loaded, unloaded and
  degraded states, and an inspect view for every chip.
- Two-tier cones at all times for guards outside the fog, and the move preview marking tiles
  that would get an Operator noticed or seen.
- Aim lines, the caution countdown per zone, stun counters.
- Sound area and responding guards shown before a verb is used.
- Darkness greyed out like the fog, with lit areas visible from the dark.
- Network revealed per network on first connection; circuit lines from hubs.
- A way to see which devices can be manipulated and how (Bryson's "what can I manipulate?"
  problem; Hitman's Instinct mode is the reference).

## How Bryson will judge it

The playtest questions from [battle-mvp.md](battle-mvp.md) still apply, plus:

1. Does the Operator's AP economy give creative turns without feeling fiddly?
2. Do the AI's refunds and chips produce chains that feel clever?
3. Is the aim-then-fire warning beat tense but fair?
4. Do devices and darkness make the map feel manipulable?
5. How dense is the network, and does its topology need to change before network opposition?
