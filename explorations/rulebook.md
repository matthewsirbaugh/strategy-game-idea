# Rulebook V1

- Status: open, started 2026-10-02.
- Output: `RULES.md` at the root is the working copy. Once V1 is done, it's published to Google
  Drive as a document for sharing and comments (Bryson, 2026-10-02).
- Scope: the whole game, not only battle: upgrades, enemies, abilities, the Operators' own
  upgrade path, and whatever outside battle feeds them (Bryson, 2026-10-02).
- Method: one concept at a time, like any exploration. Tangents for research are welcome.
- Inherits: the rules so far in [battle-core.md](battle-core.md) and [battle-mvp.md](battle-mvp.md).

## Order of work

1. Action system (in progress).
2. Combat: cover, hit model, what a non-lethal weapon means for enemies.
3. Stealth and detection.
4. Downed and recovery.
5. Hacking depth.
6. Enemy AIs and enemy hacking.
7. Mission structure: phases, handover, the vault rule.
8. Progression: stats, the AI's three pipelines, the Operators' upgrade path.

## 2026-10-02 — Action system: direction (Bryson)

- Why it's needed: few units, so each one needs real flexibility, doing several things in one
  turn. Creative play is rewarded, not punished, without becoming overpowered.
- No Fire Emblem rigidity. Its simplicity works because of the weapon triangle and units that
  persist across the game; here it would be boring and limiting.
- Context stays its own resource, not part of the action economy. Compaction and skills get
  formalized later as a system that works alongside it.
- Direction: stealth tactics, plus letting clever, risky play continue the turn.
- The split economy, a working idea: Operators play in the style of Invisible Inc., careful and
  stealth-first, because they're real people. AIs play in the style of Gears Tactics,
  aggressive with refunds, because a crashed AI isn't gone for good.
- Only AIs get refunds. It abstracts the idea that AI capability grows exponentially, while
  human capability grows linearly.
- A downed Operator is out for the rest of the battle. Nothing carries over.
- An AI that "dies" is kicked back to the backpack and its context is wiped.
- The network needs a rework to give the aggressive AI economy something to work on, since it
  is nearly empty of enemies before the first boss. This needs research first.

## 2026-10-03 — Network rework: direction (Bryson, after research)

- Playtest finding: on small maps a hacked camera mostly shows what the team already sees. A
  camera is worth hacking when it watches somewhere far off, like a chokepoint. Cloak has the
  mirror problem: it matters against surveillance, not against a guard looking right at you.
- Surveillance is an enemy. Every camera in a level starts out enemy-controlled and can spot
  Operators. Hacking one is mainly about disabling the threat; the vision is a bonus. Bryson
  thought this was already in the build, and it isn't. It's a gap to fill.
- The network gets its own opposition, and the AI uses enemy pieces as lily pads to set up
  bigger plays, the way checkers lets you jump twice in one turn. Taking out an enemy piece
  sets up a combo.
- Breaches pull physical levers, as many as we can conceive of. Hacking's identity lives in its
  utility.
- A playground: anything the team can access, it should be able to manipulate somehow. How you
  beat a level depends on creativity and strategy, not on pattern recognition finding the one
  optimal route. The hard part is keeping quality high while widening player agency.
- Lily pads aren't only enemies: anything the AI hacks can be one. An idea, not yet confirmed
  for the game: finishing a hack in a single action refunds that action point, so the AI can
  start another action. The reasoning: a smarter, more efficient model finishes a hack in fewer
  tokens, so it has time left over to attempt another.
- Enemy AIs ramping up after the first boss (battle-core, 2026-09-23) is still the intent. Its
  shape waits until more of the rulebook is filled in.
- No battle-wide clock, like an alarm or trace. Most hacks are limited by whether they can be
  done, not by time.

Research behind this, all from the chat on 2026-10-02: Invisible Inc. (cameras as threats,
daemons, PWR), Midnight Protocol (trace, ICE, a deck of programs), Watch Dogs (environment as a
weapon), Rainbow Six Siege (cameras worth having because the level hides the key spots).

## 2026-10-03 — Closing the network loop (Bryson)

- "Breached" is the formal term for a node that has been hacked.
- The refund is in: a single hack action that takes a node from untouched to breached refunds
  that action point. Finishing the last part of a breach that took several turns doesn't count.
- Context is the only brake on chains, with no hard cap. It mimics the real world: someone who
  knows nothing about AI could get good at this game and come away with the basic principles of
  steering one.
- Overflow (leftover hack points carrying into the next hack) is dropped. There's no real-world
  correlate for it, and on top of the refund it's a hat on a hat that risks being overpowered.
- An AI starts with 2 AP, and moving through the network costs 1. Upgrades can raise the AP an
  AI starts with or can hold.
- Network opposition: ICE that blocks a route until it's broken, daemons that trigger when a
  node is breached, and security hubs that re-lock things. They get fleshed out with the network
  layer's UI later.
- A camera that spots an Operator alerts guards that someone is in the area, and the closest
  guards go to investigate. Tougher areas, such as deep inside an enemy headquarters, can alert
  every enemy in a zone.
- Cloak hides an Operator from surveillance only, never from a guard's own eyes. The fiction:
  the AI edits the video stream in real time to cut the Operator out.
- Device verbs are the backbone of the playground. Every device mixes from a short list, such as
  power, sense, move, lock, signal and harm. Bryson imagines a radial menu: point the stick to
  pick a verb, or press its key (L for lock, M for move).
- Lily pads: Jump is in (a compromised node extends the AI's reach that turn). Borrowed power
  (a compromised piece lends its abilities for the turn) is liked, but it needs a way to make
  moving power between pieces intuitive in the UI.

## 2026-10-03 — The Operator half (Bryson, after studying Invisible Inc.)

Research in the chat: Invisible Inc. (AP spent only on movement and peeking, attacks free and
capped at one per turn, sprint trades noise for AP, knockouts that wear off unless the guard is
pinned, ambush stance, always-visible vision cones), XCOM 2 concealment, Mutant Year Zero
silent takedowns, Desperados III and Shadow Tactics (readable cones, queued combos).

- The lessons Bryson adopted: movement is the scarce resource, attacks are capped separately,
  the rules are readable, risk dials, a non-lethal hit buys time and creates follow-up
  decisions, and the player chooses when a fight starts.
- HP-based combat trades a good puzzle for more RPG. The puzzle wins.
- Operators spend AP from one pool on movement, so moving is part of the turn's whole economy.
- One shot per turn, outside the AP pool, and it doesn't end the turn: it can come in the middle.
- Sprint is in. It needs every guard's vision cone visible at all times while the guard is
  outside the fog.
- An ambush or overwatch stance is in.
- The Operator's and the AI's AP interleave freely within a unit's turn. This replaces TURN-01
  and TURN-02 in [battle-core.md](battle-core.md).
- Gear: weapons and gadgets that restrain enemies non-lethally are equipment, gained outside
  battle and used in it. Bryson's example: a drone with a small circle of vision, upgradable
  with a single-use ability, such as stunning an enemy or hacking one small target (a goal-10
  node at today's numbers).
- Level design follows from this: medium-small maps, dense with things to manipulate, which
  suits an AI moving around a network. It means investing in good environment models and
  objects so maps read as tactical spaces, not mazes of one repeated wall.

## 2026-10-03 — Enemies, Operators and gear (Bryson)

- North star: "more of a puzzle with RPG progression and a story, like Into the Breach if it were
  a stealth game and had a story and proper upgrades."
- Enemies have no HP. Enemy variety comes from mixing traits, alone or in combination: needs two
  stuns, immune to the basic shot so it takes a specific gadget, wakes up faster, wakes nearby
  guards.
- Operators follow the Invisible Inc. model: one or two hits and they're downed. Getting spotted
  is the real cost.
- A stun lasts 4 turns by default, to be tuned. That leaves time for an Operator to tie the guard
  up, which takes them out for the battle unless another enemy finds and unties them.
- Gear is the Operators' upgrade path, alongside the AI's three pipelines. Upgrades should feel
  like new abilities and options, not a bigger number.

## 2026-10-03 — Armor, the warning beat, turns and stuns (Bryson)

- Every Operator starts at one hit. Basic armor absorbs one more. Heavy armor absorbs two, but
  costs 1 AP because it's heavier and slows the Operator down.
- The warning beat, in Bryson's example: an Operator moves forward, and the move stops when it
  reveals a guard. The guard is alerted at once if the Operator is in its cone, but it's still the
  player's turn. The Operator sprints behind cover, and their AI spends an action to cloak them,
  so they drop off the radar. If the guard can't reach them on its next turn, the Operator moves
  around the other side of the cover, the guard loses track, gives up the search and goes back to
  its patrol.
- Tying up costs 2 AP, adjacent only.
- A round is every unit on the map taking a turn. Hidden enemies take theirs out of sight and join
  the turn-order display once revealed. An Operator's turn lasts until their AP is spent or they
  end it.
- A stun lasts a number of turns, not rounds, and drops from 4 to 3 for testing. The stunned enemy
  stays in place with no vision. The point is time to tie them up without stuns being
  overpowered.
- The Into the Breach comparison is about being a puzzle rather than a statistical back-and-forth.
  It isn't about copying its mechanics.

## 2026-10-03 — Clarifications and the end-game feeling (Bryson)

- Cloak works in the warning-beat example because the Operator is behind cover: it erases them
  from the cameras and the enemy network the guard's search relies on.
- A stun counts the stunned enemy's own turns, so 3 turns is roughly 3 rounds.
- Heavy armor means three hits in total.
- An alerted guard acts on its own turn, never during the player's (rule 17 as worded).
- An early upgrade: a predictive algorithm that shows what each enemy intends to do next turn,
  given the current situation.
- What hacking is for: gather intelligence on enemies, keep yourself hidden, and use the
  environment to stay hidden on the way to the goal, incapacitate enemies, or open shortcuts. The
  map itself should feel manipulable if the player's hacking is strong enough. By the end of the
  game, the player enters a new level, surveys it, and is already planning how to chain abilities
  into a combo.
- So the visuals and the UI have to make clear what can be manipulated and how. Some cases are
  easy (a light switch, a self-driving car rolling into a guard); harder ones need real thought.
- Map size: not as small as Into the Breach's 8×8, but small and dense. Spending most of your AP
  on movement should be an intentional positioning choice, because the same AP could go to any
  number of other actions.

## 2026-10-03 — Operator AP, overwatch, gadgets and robots (Bryson)

- Operators start with 8 AP, to see how it plays.
- Opening an unlocked door is free; locking one costs 1 AP. Deploying the AI to the network costs
  1 AP.
- Overwatch belongs to the weapon economy, one per turn. It's a disposition, almost a status: the
  Operator can still move after setting it if they have AP, and when the turn ends they're in
  overwatch.
- Gadgets cost different amounts of AP. Example: a flashbang costs 2 AP and blinds the guards in
  its blast radius for 3 turns.
- Robots are gadgets with a high deployment cost (3 AP) and then their own action economy: an AP
  pool, a speed that puts them in the turn order, and vision shared with the Operators. They
  scout, distract, and can carry a simple hack or a single-use stun. One hit downs them, and no
  upgrade changes that. Two so far: a drone, and a dog bot like Boston Dynamics' Spot.
- Peeking needs its own aside: Bryson isn't sure what it is or how it would work here.

## Parked for playtesting, outside V1

- Injuries or permadeath. There may be good narrative reasons for some form of permadeath, or
  for injuries that do more than cost health, such as a movement or aiming penalty. Bryson
  prefers Chained Echoes-style full recovery for now. Revisit only after a lot of playtesting.
