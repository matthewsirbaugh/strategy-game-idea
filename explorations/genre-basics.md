# Genre basics: what the game has, and what it's missing

- Status: open. The missing items below are one V2 item, listed in
  [the rulebook's V2 list](rulebook.md#v2-after-implementation-and-playtesting) (Bryson, 2026-10-13).
- Sources: the research report,
  [Stealth tactics basics gap analysis](../reports/Stealth%20tactics%20basics%20gap%20analysis.md),
  and its notes in `research_notes/Stealth tactics basics gap analysis/`. "Report item N" means that
  report's numbered item.
- Method: Claude read the rules code (`game/rules/`) and the battle scene and HUD (`game/battle/`)
  against each of the report's 45 items, 2026-10-13. This is a reading of the code, not a playtest.
- Nothing here is a decision. The report's decisions 46–52 are still Bryson's.

## Terms

| Term | Meaning here |
|---|---|
| Has | The game does it today |
| Partial | Some of it is there; the line says what's missing |
| Missing | Nothing in the code does it |
| Code-decided | The code answers a question RULES.md never asks. Somebody chose; it wasn't Bryson |
| Manhattan distance | Steps counted across and down, no diagonals: what "walking steps" means on a 4-way grid |
| Round distance | Straight-line distance, so a radius looks like a circle rather than a diamond |

## What the game already has

| Report item | What the code does |
|---|---|
| 8, guard-state icons (partial) | "?" over an investigating or searching guard, "!" over an alerted one; the hover card names the state and counts stun and blind turns |
| 10, danger zones (partial) | Every visible cone is always drawn, so the union is always on screen |
| 17, finding bodies | A guard who sees a body in its seen tier finds it; a camera that sees one sends the closest guard. A guard who sees a colleague get stunned finds them in the same sweep |
| 23, hack preview (mostly) | The hack menu shows the power after chips and the full-context halving, the context cost, the AI AP and "N to go". The refund is explained in the tip, but there's no badge saying this hack will refund |
| 28, event log | `battle_log.gd` narrates every event from the player's side of the fog: an unseen enemy is "Someone" |
| 29, move previews (partial) | Move tiles show AP cost and whether the tile gets you noticed or seen. Sprint is its own action and the HUD marks the shot "given up". Verbs are previewed on a copy of the battle (sound, responders), and the flashbang's area shows before throwing |
| 31, ending with AP left | Ending one half of a turn moves to the other half when it can still spend AP |
| 26, verb use | Each device's verb can be used once per turn per AI. Report item 26 stays a watch item |

One finding that matters for undo: `BattleState.clone()` already copies the whole battle; Predict and
the verb preview run on that copy. Undo, a turn reset and restarting from a round would be built on
snapshots of this, so part of the groundwork exists. How to use it is still an architecture
decision to make together.

## What the code decided that RULES.md doesn't say

These have answers in the code today. Each is for Bryson to confirm or change; once confirmed, it
goes into RULES.md's geometry and enemy sections (report item 18–20).

1. **The grid is 4-way.** Units move up, down, left and right, never diagonally.
2. **Two distance metrics are mixed.** Manhattan distance for movement, Operator and robot sight,
   the shot's range 5, overwatch, the tether, the flashbang's throw and radius, and sound. Round
   distance for guard and camera cones and light pools. So the flashbang's "radius 2" is a diamond,
   while a light's "radius 3" is a circle.
3. **Line of sight** runs from tile centre to tile centre. Two walls touching only at a corner leave
   a gap that sight slips through.
4. **Cones** point along the guard's facing, which is the direction of its last step, and take
   every tile within 45° of it. Looking around turns the guard through the four directions.
5. **What blocks what:**

   | | Walk | Sight | Sound |
   |---|---|---|---|
   | Wall | yes | yes | yes |
   | Closed door | yes | yes | yes |
   | Open door | no | no | no |
   | Low obstacle | yes, except flying | yes, except cameras and drones | no |
   | Vehicle | yes, except flying | yes, except cameras and drones | no |
   | Ally | no, but can't stop on its tile | no | no |
   | Enemy or body the unit knows about | yes | no | no |
   | Enemy the unit hasn't seen | no: walking into it stops the move a tile short | no | no |

6. **Every Operator action is silent:** the shot, sprinting, the flashbang, tying up, carrying,
   doors, and a robot going down. Only devices and turret shots make sound (report items 15–16).
7. **A body in a guard's noticed tier does nothing.** Turrets never find bodies (report item 17).
8. **Guards never open doors.** A closed door is a wall to them: they walk around it or don't
   move.
9. **Turn order ties** among guards go by their order in the map file. The team wins ties with the
   enemy; tied Operators are the player's pick.
10. **Targeting:** an alerted guard aims at an Operator before a robot, then the nearest by
    straight-line distance; an exact tie goes to whichever comes first in the unit list.
11. **"Closest guard"** for sounds and lures counts walking steps; ties go by unit order. Only
    patrolling guards answer, so when two lures fire at once, each guard answers the first.
12. **Overwatch** fires mid-move, at the first enemy that steps onto a tile within range 5 that the
    Operator can see. A guard that only turns doesn't trigger it.
13. **Patrols** are a looping list of waypoints from the map: walked in order, wrapping back to the
    start, with no waits and no set facings.
14. **Friendly fire:** a driven car stops short of any Operator, robot or body and hits only guards.
    The flashbang blinds only enemies. The Operator's shot passes through other units to its
    target. A guard's shot hits the first team unit in the line and passes through other guards.
15. **Walking directly behind a guard,** outside its cone, is always safe.
16. **No unit can hold its turn** to act later in the round. Tied Operators can only swap before
    the active one has acted.

## V2: the missing basics, as one item

Everything the game doesn't do yet, from the report, grouped. Each line names its report item.

### Pressure and escalation

17. Settle what rule 22 rules out: only a turn-driven alarm or trace, or any lasting escalation
    (report items 1 and 46). The code has no escalation of any kind.
18. Check-ins: a guard tied up or hidden for a few rounds is missed, and the closest guard goes
    looking (item 2).
19. Exfil escalation: breaching the Prime Data Cache makes the escape harder (item 3). Today it
    only unlocks the win.
20. A rounds-taken par on the end screen (item 4). The round counter exists; the end screen
    doesn't use it.
21. Log rounds per phase and rounds with no Operator action, to measure whether waiting is the
    dominant strategy (item 5).
22. The telegraphed radio call: an alerted guard who still sees an Operator next turn calls its zone
    (item 6). Today a guard's alert reaches no one; only the zone's caution changes.
23. Chain of command built on the radio call (item 7; already on the V2 list as caution as
    escalation).

### Reading the enemy

24. A line to where an investigating guard is going, and the last-known position a searching guard
    is working (item 8).
25. How much of a patrol route is free: once watched for a full loop, its facing only, or Predict
    only (item 9).
26. Pin a single guard's or camera's cone (item 10).

### Undo, save and restart

27. Undo anything that taught you nothing, up to a commit point (item 11). Needs Bryson's yes: it
    changes rule 4.
28. A suspend save: quit mid-phase and resume (item 12).
29. Restart from the start of a recent round, alongside the phase restart (item 13).
30. Later, a once-per-battle turn reset, framed in the fiction (item 14).

### Rules that need writing

31. A sound table for Operator and robot actions; whether sprint makes sound (items 15–16).
32. Whether a body in a guard's noticed tier draws an investigation, and whether turrets find
    bodies (item 17).
33. A geometry section and an enemy-decision section for RULES.md, starting from 1–16 above
    (items 18–20).

### Downed Operators

34. Carry a downed Operator to extraction (item 21). Today only guards can be carried.
35. What leaving one behind costs: heat, capture, or lost time (item 22; already on the V2 list as
    how they escape).

### The network fights back

36. A badge in the hack menu when this hack will refund, and the number of hacks still needed
    (item 23).
37. Caution reaches the network: the zone's devices gain a firewall and can't refund (item 24).
38. Guards who investigate a Breached device return it to the enemy (item 25).

### The interface floor

39. Enemy-turn speed (normal, fast, instant) and a skip key (item 27). Today every visible enemy's
    turn pauses 0.35 seconds and there's no setting; unseen enemies already take no screen time.
40. Group the event log by round, and log context changes (item 28).
41. An end-of-move summary: in an aim line, beyond the tether (item 29). The noticed and seen
    warnings exist.
42. Double-code everything coloured: cone tiers, caution, dark against fog (item 30). The "!" and
    "?" icons are already double-coded. The red in OpenBrain's accents against red for danger is an
    open question for art direction.

### Campaign basics

43. Guard roles by perception and behaviour, when rule 40 opens (item 32).
44. Objective variants built from existing verbs (item 33; pairs with the V2 list's win and lose
    conditions per level).
45. Two to four badges per mission (item 34).
46. Intel from town that reveals part of the next map (item 35). The loadout menu covers choosing
    gear and chips.
47. An onboarding ladder, one interlocking system per map, with a callout the first time each rule
    triggers (item 36).
48. A level checklist and a measured length target (item 37; the
    [level-design exploration](level-design.md) holds the map work so far).

### Optional ideas

49. The report's Tier 3 table, items 38–45: Operator hiding spots, cover and height, credentials,
    civilians, noisy tiles, a context-relief console, intel terminals, and trace. None are in the
    code. Each would add a system, so DESIGN.md's cost principle applies.
