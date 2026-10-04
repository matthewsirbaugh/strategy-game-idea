# Rules

V1, in progress. Only agreed rules go here. The reasoning, and anything still being worked out,
is in [the rulebook exploration](explorations/rulebook.md). Once V1 is done, this file is
published to Google Drive for sharing and comments.

Terms are defined twice: briefly in the glossary below, and in full, with edge cases, under
[Definitions in full](#definitions-in-full) at the end. The full definitions are what an
implementation follows. Numbers marked placeholder are for tuning.

## Glossary

| Term | Brief meaning |
|---|---|
| Battle | One mission, every phase, area and map of it |
| Round | Every unit on the map takes one turn |
| Turn | One unit acting. An Operator's turn lasts until their AP is spent or they end it |
| Turn order | The order units act in each round, shown at the top of the screen |
| Unit | Anything that takes turns: Operators, guards, robots |
| Operator | A human member of the team, carrying their AI in a backpack |
| AI | An Operator's agent. It acts in the network |
| Guard | The standard enemy |
| Gadget | Equipment an Operator uses in battle, at an AP cost |
| Robot | A gadget with its own turns: a drone or a dog bot |
| AP | Action points, spent on actions each turn |
| Shot | The Operator's one weapon use per turn, outside the AP pool |
| Overwatch | A shot held for the first enemy that moves into the line of fire |
| Sprint | 3 tiles for 2 AP, at the cost of the turn's shot |
| Peek | 1 AP to see through a door until the turn ends |
| Refund | A one-action breach gives the AI its AP back |
| Shared compute | Adjacent Operators' AIs passing AP between them |
| Network | The layer of nodes and links the AI moves through |
| Node | Anything on the network the AI can move to or hack |
| Access point | A node where an AI enters the network |
| Tether | The range an Operator must stay within for their AI to stay connected |
| Relay | A robot the AI connects through instead of its Operator |
| Breach | Hacking a node until its goal is reached |
| Breached | A node that has been hacked. The team controls it |
| Hack power | How much breach progress one hack action adds |
| Goal | The breach progress a node needs |
| Lily pad | A Breached node used as a stepping stone for the next play |
| Jump | A compromised node extending the AI's reach that turn |
| ICE | Network opposition that blocks a route until broken |
| Daemon | A trap that triggers when a node is Breached |
| Security hub | Network opposition that re-locks things |
| Device | A physical object on a node: a camera, a door, a light, a car |
| Device verb | What a Breached device can do: power, activate, lock |
| Activate | Makes a powered device do its thing: a car drives, a phone rings |
| Autonomous | A device that acts on its own, like a turret or drone. Breaching one gives type-specific controls |
| Context | The AI's context window, a resource for the whole battle |
| Compaction | Clearing most of the context. It takes an AI action and degrades loaded chips |
| Chip | A skill on a retro-futuristic disk, loaded into context when used |
| Loaded | A chip currently in context and usable |
| Movement chip | The free chip for moving through the network |
| Pulled out | The AI drops out of the network and keeps its context |
| Crashed | Knocked out of the network by opposition: a forced compaction and a lost turn |
| Fog | Map areas the team has no vision on |
| Last-known position | Where an unseen enemy was last seen |
| Cone | A guard's or camera's field of vision, in two tiers |
| Seen | The cone's core. An Operator here causes an alert |
| Noticed | The cone's outer tier. An Operator here draws an investigation |
| Investigate | A guard going to check a spot, then returning to patrol |
| Alerted | A guard that has seen an Operator directly: a full alert |
| Searching | An alerted guard that lost track of the Operator |
| Caution | A zone's heightened state after an alert, on a countdown |
| Zone | An area of a map that shares alerts and caution, drawn by the map author |
| Light and dark | Darkness shrinks the seen tier |
| Sound radius | How far a device's sound carries to guards |
| Cloak | A chip that erases an Operator from surveillance |
| Stunned | An enemy knocked out by a shot, skipping turns |
| Tied up | A stunned enemy restrained, out of the battle unless freed |
| Carry | Holding a stunned or tied-up enemy over the shoulder |
| Receptacle | A place to hide a body: dumpster, trunk, locker, closet, trash can |
| Hidden | A body out of sight or in a receptacle |
| Armor | Gear that lets an Operator take extra hits |
| Downed | An Operator who has taken their last hit, out of the battle |

## Turns

1. Each round, every unit on the map takes a turn. Hidden enemies take theirs out of sight.
   When an enemy is revealed, it joins the turn order shown at the top of the screen.
2. Each unit's turn has two halves: the Operator in the physical world, and the AI in the
   network.
3. A unit can do several things in one turn. The Operator's and the AI's actions interleave
   freely.
4. Operators play carefully and stealth-first. They never get refunds.
   - An Operator starts each turn with 8 AP. Movement comes out of the same pool as their other
     actions.
   - One shot per turn, outside the AP pool. It doesn't end the turn.
   - Overwatch uses that shot. It's a disposition: the Operator can still move afterwards if they
     have AP, and when their turn ends they are in overwatch. It fires at the first enemy that
     moves into the Operator's line of fire, and drops at the start of the Operator's next turn.
   - Sprint: 3 tiles for 2 AP. On 8 AP an Operator can move up to 12 tiles in a turn, but an
     Operator who sprints can't shoot or set overwatch that turn.
   - Peeking through a door costs 1 AP. The Operator sees into the space beyond until their
     turn ends.
   - Opening an unlocked door is free. Locking a door costs 1 AP and needs the Operator at the
     door. An AI can lock or unlock a Breached door remotely.
   - Deploying the AI to the network costs 1 AP.
   - Gadgets cost AP to use, depending on the gadget, and sit outside the one-shot limit. A
     flashbang costs 2 AP and blinds the guards in its blast radius for 3 turns.
5. AIs play aggressively, on their own AP, separate from the Operator's: the AI's autonomy is the
   point. For now they start each turn with 2 AP. Moving through the network costs 1 AP, and so
   does compacting (placeholder). The AI's action system is under review.
   Unspent AP doesn't carry over, for Operators or AIs.
6. Refund: a single hack action that takes a node from untouched to Breached refunds its AP.
   Finishing the last part of a breach that took several turns does not.
7. AIs can share compute while their Operators stand adjacent, physically linked: each AP one AI
   gives up, another AI gains.
8. Context is not part of the action economy. It's the AI's battle-long resource, and the only
   limit on chaining refunds.
9. Hacking never fails. An action makes progress, or at worst none.

## Skills

10. Every AI skill is a chip, Cloak included. Chips are set before the battle and locked for its
    length. Each AI carries at most 3, plus the movement chip, which is free and doesn't count
    toward the cap but still has to be loaded. There's no randomness: every chip an AI carries
    can be used.
11. Using a chip loads it into context, which costs context and no AP. The player can see which
    chips are loaded and which aren't yet, and inspect any chip to see what it does.
12. Chips and post-training give AIs their specialties. AIs have no internet: they know only
    their training data and what's on their chips.
    - The protagonist's new partner AI starts general. After the tutorial battle, the player
      answers a series of questions that set its starting abilities and specialization.
    - The other two AIs arrive with set personalities and starting specialties. Any AI can be
      reshaped into anything over the game.
    - Chips do many different things. One possible kind multiplies hack power against a category
      of device, for example 1.5×. Context costs are high enough that loading every chip on the
      first turn isn't the obvious play.
    - Compaction degrades chips, defined chip by chip. A multiplier chip drops from 1.5× to 1.25×,
      then unloads and has to be loaded again.
    - The movement chip only unloads if a compaction takes context below its own cost.

## The network

13. A Breached node can be a lily pad. Jump: a compromised node extends the AI's reach that turn.
14. The network has its own opposition: ICE that blocks a route until it's broken, daemons that
    trigger when a node is Breached, and security hubs that re-lock things.
15. Breaching a device gives the AI access to its verbs. Devices and other non-autonomous
    systems share one list: power, activate and lock.
    - Activate makes a device do its thing: a car or an elevator moves, a phone rings with a fake
      call. Powering a phone on makes no sound.
    - Every verb a Breached device has can be used, but each verb only once per turn. An electric
      car can be powered on and activated in the same turn, but not powered on and off. Each AI gets
      its own uses in its own turn.
    - Verbs cost no AP, but each use costs context.
    - An AI connected to a network can use every Breached device on that network, wherever the AI
      is on it.
16. Breaching something autonomous, such as a turret, drone or dog bot, gives manual control
    through a set of controls specific to its type. A Breached turret doesn't let the player
    pick targets, but they can tell it, for free, either to target enemies and shoot or to
    target nothing.
    - A Breached turret set to shoot fires on its own turn at the nearest enemy: guards and
      anything under their control, including robots and other turrets. An enemy turret doesn't
      treat it as hostile until it's hit, and shoots back once it recovers from the stun.
    - A Breached enemy robot joins the team's turn order with its own AP, and keeps whatever
      upgrades it had. A single-use ability is only available if it wasn't used before the
      breach.

## Surveillance and stealth

17. Operators move silently. Devices and objects make sound, and a guard who hears one goes to
    investigate it. Only seeing an Operator directly causes a full alert.
    - Each device has a sound radius, counted in walking steps like a movement range: around
      walls, through open doors, and stopped by closed ones.
    - The device decides who responds. A small sound draws only the closest guard in range; a
      big one, like a diesel truck, draws every guard in range.
    - Before the player uses a device verb, its sound area is shown, and the visible guards who
      would respond are marked. Guards in the fog respond too, unseen.
    - A guard who hears a sound walks to its source, looks around for one turn, then goes back to
      its patrol.
    - Each use of a verb makes one sound, a single moment.
18. Every camera starts enemy-controlled and can spot Operators. A Breached camera is the team's
    camera now, so it never reports the team's Operators or units to the enemy, even right in
    front of it. While powered on, it gives the team its vision. Powering it off is a lure: a
    camera going dark draws a guard to investigate. Cameras can't be activated. Cameras see only
    in light; an upgraded camera with night vision needs a higher-level hack.
19. Guards share vision through their cameras. That's their biggest strength and their biggest
    weakness: a hacked camera stops reporting the team to them.
20. A camera that spots an Operator alerts guards that someone is in the area, and the closest
    guards go to investigate. Some areas, such as deep inside an enemy headquarters, alert every
    enemy in a zone.
21. Cloak hides an Operator from surveillance, never from a guard's own eyes. It erases them
    from the cameras and the enemy network a guard's search relies on, so an Operator behind
    cover and cloaked drops off the radar.
22. There is no battle-wide clock.
23. Every guard's vision cone is visible at all times while the guard is outside the fog. A cone
    has two tiers:
    - Seen, the core: the guard is alerted.
    - Noticed, the outer part: the guard marks the spot, goes there to investigate on its turn,
      and if it finds nothing goes back to its patrol.
24. While the player plans a move, the tiles that would get the Operator noticed or seen are
    marked.
25. Light controls visibility. In darkness a guard's seen tier shrinks to a short range and the
    rest of its cone counts as noticed. A light that goes out draws a guard to investigate it.
    Lights are a hacking target: cover for the Operators, and a lure.
26. A move that reveals a guard stops at the tile where it was revealed. If the Operator is in
    that guard's seen tier, the guard is alerted at once, but the Operator's turn carries on.
27. An alerted guard acts on its own turn, never during the player's. If it loses track of the
    Operator, it searches, then gives up and goes back to its patrol.
28. After an alert, the zone goes on caution for 3 rounds (placeholder), with a visible countdown. During
    caution, the noticed tier counts as seen. When the countdown ends, the zone settles back to
    normal.

## Enemies

29. Enemies have no HP. A hit stuns them: they stay in place without vision and skip their next
    3 turns (placeholder).
30. An Operator next to a stunned enemy can spend 2 AP to tie them up. A tied-up enemy is out of
    the battle unless another enemy finds and unties them.
31. A guard who finds a stunned or tied-up enemy raises an alert.
32. An Operator can pick up a stunned or tied-up enemy and carry them over their shoulder. Picking
    up and putting down are free. While carrying, the Operator can only move, with no movement
    penalty.
33. A body is hidden when it's out of sight, or inside a receptacle such as a dumpster, a car's
    trunk, a locker, a closet or a trash can. Putting a body down on a receptacle's tile puts it
    inside, hidden.
34. A stunned enemy who wasn't tied up raises an alert when they wake. Inside a receptacle, they
    make noise instead, and a guard passing within its sound radius comes to let them out.
    Guards don't otherwise search receptacles.
35. For now there is one standard enemy, with no special traits, so the rules can be tuned
    before enemy types are added.

## Defeat and recovery

36. An Operator goes down after one hit. Armor adds hits: basic armor takes one more, and heavy
    armor takes two more but costs 1 AP. A downed Operator is out for the rest of the battle.
37. ICE, daemons and enemy AIs can crash an AI. A crashed AI goes back to its backpack, is
    compacted as if it had compacted itself, and loses its next turn while it reboots. After
    that, its Operator can deploy it again for 1 AP, or leave it out.

## Robots

38. Robots are gadgets, such as a drone or a dog bot. Deploying one costs 3 AP.
39. A deployed robot has its own AP pool and a speed that puts it in the turn order. Its vision
    is shared with the Operators, so it lifts the fog.
40. Robots scout, distract enemies, and can carry a single-use stun. They never hack on their
    own. Instead, a robot is a relay: the Operator's AI can reach the network through it, which
    sends access behind enemy lines.
    - A robot relays from within tether range of an access point, like an Operator. Its link to
      the Operators has no range limit.
    - A robot that ends its turn at an access point lets any Operator, on their next turn, spend
      1 AP to send their AI in through it.
    - An AI connects through one Operator or robot at a time.
    - If the robot is hit while relaying, the connection is severed at once. The AI is pulled out
      and keeps its context.
41. One hit downs a robot, and no upgrade changes that. A downed robot is gone for the rest of
    the battle and rebuilt afterwards.

## Progression

42. In V1, every Operator has the same stats. They differ only in personality.
43. Operators upgrade through gear, and AIs through hardware, harness and post-training.
    Upgrades add abilities and options rather than bigger numbers.

## Not written yet

Combat, stealth and detection in full, hacking depth, enemy AIs, mission structure and
progression. The order of work is in [the rulebook exploration](explorations/rulebook.md#order-of-work).

## Definitions in full

Each entry gives the full rule and the edge cases agreed so far. "Open" marks a case that
hasn't been decided; an implementation should flag it rather than guess.

### Structure

**Battle.** One mission, from start to extraction, including every phase, area and map in it.
Context, stuns, caution and downed Operators all last at most one battle. Robots that went down
are rebuilt after it. Open: how a multi-map battle hands over from one map to the next.

**Round.** Every unit on the map takes one turn, in turn order. Hidden enemies take their turns
out of sight. A round ends when the last unit in the order has acted.

**Turn.** One unit acting. An Operator's turn holds both halves, the Operator's and their AI's,
interleaved freely. It ends when the Operator's AP is spent or the player ends it. Durations
counted "in turns" count the affected unit's own turns: a guard stunned for 3 turns skips its
next 3 turns, which is about 3 rounds.

**Turn order.** Units act in speed order each round. It's shown at the top of the screen. An
enemy joins the display only once it has been revealed; before that, its turn still happens,
unseen. Robots have their own speed and their own place in the order.

**Unit.** Anything that takes turns: Operators, guards and robots. An AI is not a separate unit;
it acts within its Operator's turn.

### People and equipment

**Operator.** A human member of the team, carrying their AI in a backpack. In V1 all Operators
have identical stats and differ only in personality. Operators never get refunds, move silently,
and go down after one hit unless wearing armor.

**AI.** An Operator's agent. It runs locally in the backpack, has no internet, and knows only
its training data and its chips. It acts in the network on its own AP, interleaved with its
Operator's actions. The protagonist's AI starts general and is shaped by a questionnaire after
the tutorial; the other two arrive with set personalities and starting specialties.

**Guard.** The standard enemy in V1, with no special traits. It has no HP. It patrols, can be
noticed by or see Operators through its cone, shares vision with the cameras its side controls,
investigates sounds and noticed spots, and acts only on what it knows. It never acts during the
player's turn.

**Gadget.** Equipment an Operator brings into battle and uses at an AP cost that depends on the
gadget. Using a gadget is an Operator action and doesn't use up the turn's shot. Example: a
flashbang costs 2 AP and blinds the guards in its blast radius for 3 turns.

**Robot.** A gadget that becomes its own unit once deployed, such as a drone or a dog bot.
Deploying one costs the Operator 3 AP. A robot has its own AP pool and speed, takes its own
turns, and shares its vision with the team. It can scout, distract, and carry a single-use stun.
It never hacks; it relays (see Relay). One hit downs it, with no upgrade to change that, and a
downed robot is gone for the rest of the battle and rebuilt afterwards.

**Armor.** Gear that adds hits before an Operator is downed. Basic armor adds one, for two hits
in total. Heavy armor adds two, for three in total, and costs 1 AP from the Operator's starting
AP because it slows them down.

### The action economy

**AP.** Action points. Operators start each turn with 8. AIs have their own, separate pool,
currently 2 per turn, with moving through the network costing 1; the AI's system is under
review. Unspent AP doesn't carry over in V1.

**Shot.** The Operator's weapon: one per turn, outside the AP pool, and it doesn't end the turn,
so the Operator can keep moving and acting after it. It stuns. Sprinting gives up the shot for
that turn. Setting overwatch uses it.

**Overwatch.** The shot held as a disposition. The Operator sets it at any point in their turn,
can still spend remaining AP afterwards, and is in overwatch when the turn ends. It fires at the
first enemy that moves into the Operator's line of fire. If nothing triggers it, it drops at the
start of the Operator's next turn, so they can choose again. It's meant for controlled setups:
lure a guard into a hallway, stun it from overwatch, tie it up next turn.

**Sprint.** Moving 3 tiles for 2 AP instead of 3. It adds no AP and makes no noise. An Operator
who sprints can't shoot or set overwatch that turn. On 8 AP, sprinting moves up to 12 tiles.

**Peek.** 1 AP, through a door only. The Operator sees into the space beyond until their turn
ends, without moving into it.

**Refund.** When a single AI hack action takes a node from untouched to Breached, that action's
AP is refunded. A hack that finishes a breach begun on an earlier action doesn't refund. Context
is the only brake on chains of refunds; there is no cap. Only AIs get refunds.

**Shared compute.** An AI gives some of its AP to another AI, one for one. Only possible while
the two Operators stand adjacent, physically linked like daisy-chained computers. Linking costs
nothing.

### The network

**Network.** The layer of nodes and links over the physical map. An AI moves along links,
unconstrained by physical distance. An AI connected to a network can use every Breached device on
it without moving to that device's node. Open: whether a map can hold several separate networks.

**Node.** Anything on the network an AI can move to or hack: access points, devices, and network
opposition.

**Access point.** A node where an AI enters the network. In a wall it's a panel; in the open,
a terminal.

**Tether.** The AI runs in the backpack, so its Operator must stay near the access point it
entered through: within 2 tiles in the current build (placeholder, upgradeable). Ending a move
beyond the tether pulls the AI out. Deploying the AI costs the Operator 1 AP.

**Relay.** A robot the AI connects through instead of its Operator. The robot must be within
tether range of the access point; its link back to the Operators has no range limit. A robot
that ends its turn at an access point lets any Operator, on their next turn, spend 1 AP to send
their AI in through it. An AI connects through one Operator or robot at a time. If the robot is
hit while relaying, the AI is pulled out at once and keeps its context.

**Breach.** Hacking a node. Each hack action adds the AI's hack power to the node's breach
progress, which persists across turns and even if the AI leaves. Hacking never fails: an action
adds progress or, at worst, none. When progress reaches the node's goal, the node is Breached.

**Breached.** A node whose goal has been reached. The team controls it and can use its device's
verbs. A Breached camera becomes the team's camera: it never reports the team's Operators or
units to the enemy, and while powered on it gives the team its vision. Other devices change only
when a verb is used.

**Hack power.** The breach progress one hack action adds: 10 in the current build
(placeholder). Multiplier chips raise it against their category. When context is full, only
half of it counts (current build).

**Goal.** The breach progress a node needs. Current placeholders: door 10, camera 20, turret 30,
data cache 60.

**Lily pad.** Any Breached node used as a stepping stone for the next play; not only enemy
pieces. Jump is the first agreed form.

**Jump.** A compromised node extends the AI's reach that turn.

**ICE, daemon, security hub.** The network's own opposition. ICE blocks a route until it's
broken. A daemon triggers when a node is Breached. A security hub re-locks things. Their details
come with the network UI work.

**Device.** A physical object tied to a node: a camera, a door, a light, a car, a machine. Each
has a sound radius.

**Device verb.** What a Breached device lets the AI do, drawn from one shared list: power,
activate and lock. Power switches a device on or off. Activate makes a powered device do its
thing: a car or elevator moves, a phone rings with a fake call. A device has to be powered on
before it can be activated. Cameras can't be activated; powering one off is the camera lure.
Lock locks or unlocks; most doors are opened by Operators, while an AI locks and unlocks them
remotely. There is no sense verb (a powered camera already gives vision) and no signal verb
(activate covers it). No new verbs are planned. Verbs aren't chips. There is no harm verb: a harmful effect comes from an
ordinary verb, like powering an electric fence. Every verb a Breached device has can be used,
each once per turn, so an electric car can be powered on and activated in one turn but not
powered on and off. Each AI gets its own uses in its own turn, so one AI can power a light off and
another power it back on later in the round. Verbs cost no AP but cost context, and an AI
anywhere on the device's network can use them. The more devices the team holds, the more options
it has each turn. The names and functions of the verbs are under review.

**Autonomous.** Something that acts on its own, like a turret, a drone or a dog bot. Breaching
one gives manual control through controls specific to its type, not the shared verbs. A Breached
turret: the player can't pick its targets, but can tell it, for free, either to target enemies
and shoot or to target nothing. Set to shoot, it fires on its own turn at the nearest enemy:
guards and anything they control, including robots and other turrets. An enemy turret doesn't
recognize a Breached turret as hostile until it's hit, then shoots back once it recovers from
the stun. A Breached enemy robot joins the team's turn order with its own AP and keeps its
upgrades; a single-use ability is available only if it hadn't been used before the breach.

### Context and chips

**Context.** The AI's context window: 100M in the setting, shown as 0–100 in the current build.
It lasts the whole battle and resets afterwards. Hacking, chips and abilities add to it. It isn't
part of the action economy. When full, hacks count for half.

**Compaction.** The AI spends 1 AP (placeholder) to clear most of its context (in the current
build it keeps 25%). Compaction degrades loaded chips, defined chip by chip.

**Chip.** A skill on a retro-futuristic disk. Every AI skill is a chip, Cloak included. An AI
carries at most 3, plus the movement chip, set before the battle and locked for its length.
Using a chip loads it into context, which costs context but no AP. The player can see which chips
are loaded and inspect any chip. A multiplier chip, one possible kind, raises hack power against
a category of device (for example 1.5×), degrades to 1.25× on the first compaction, and unloads
on the second.

**Loaded.** A chip currently in context and usable. A chip that has been unloaded has to be
loaded again, paying its context cost again.

**Movement chip.** The chip for moving through the network. It's free, doesn't count toward the
cap of 3, and still has to be loaded. It only unloads if a compaction takes context below its own
cost.

**Pulled out.** The AI drops out of the network but keeps its context: when its Operator moves
beyond the tether, or when its relay is hit.

**Crashed.** The AI is knocked out of the network by ICE, a daemon or an enemy AI. It goes back
to its backpack, takes a forced compaction (25% of context stays, loaded chips degrade), and
loses its next turn while it reboots. Then its Operator can deploy it again for 1 AP, or cut
their losses. A crash is always worse than compacting on purpose (a whole turn instead of 1 AP,
at a moment the player didn't choose), so it can never be used as a better reset. Being pulled
out costs none of this: only the disconnection.

### Stealth

**Fog.** The whole map is always visible, but units show live only where the team has vision:
the Operators' sight, Breached cameras, robots and peeks. Unseen enemies are hidden entirely.

**Last-known position.** Where an unseen enemy was last seen, marked on the map.

**Cone.** The field of vision of a guard or camera, shown at all times while its owner is
outside the fog. It has two tiers, seen and noticed. While the player plans a move, the tiles
that would get the Operator noticed or seen are marked.

**Seen.** The cone's core. An Operator there causes a full alert: the guard is alerted at once,
even mid-move, but the Operator's turn carries on. In darkness the seen tier shrinks to a short
range. During caution, the noticed tier counts as seen.

**Noticed.** The cone's outer tier. An Operator there doesn't alert the guard; the guard marks
the spot and investigates it on its next turn. In darkness, everything beyond the shrunken seen
tier counts as noticed.

**Investigate.** A guard goes to a marked spot: a noticed position, a sound, or a light that
went out. It looks around for one turn, and if it finds nothing, it returns to its patrol. Hearing a sound causes an
investigation, never a full alert.

**Alerted.** A guard that has seen an Operator directly, by its own eyes or through a camera
alert. It acts on its own turn only. If it loses track of the Operator, it starts searching.

**Searching.** An alerted guard that lost track of the Operator. It searches, then gives up and
returns to its patrol. Cloak can make an Operator drop off its radar.

**Caution.** After an alert, the zone stays on caution for 3 rounds (placeholder), with a
visible countdown. During caution, the noticed tier counts as seen. When the countdown ends, the
zone settles back to normal.

**Zone.** A named area of a map, drawn by the map author, roughly one per room or yard. Camera
alerts and caution act on zones.

**Light and dark.** Light controls visibility. In darkness a guard's seen tier shrinks to a
short range and the rest of the cone counts as noticed. Ordinary cameras see only in light;
night-vision cameras see in the dark and take a higher-level hack. A light that goes out draws a
guard to investigate.

**Sound radius.** Devices and objects make sound when used; Operators don't. Each has its own
radius, for example about 1 tile for an electric car, about 5 for a typical object, about 10 for
a diesel truck. The radius is counted in walking steps, like a movement range: it goes around
walls and through open doors, and a closed door stops it. Each device also sets who responds: a
small sound draws only the closest guard in range, a big one every guard in range. Before the
player uses a device verb, the sound area is drawn and the visible guards who would respond are
marked; guards in the fog respond too, unseen. In V1, each use of a verb makes one sound, a
single moment.

**Cloak.** A chip that hides an Operator from surveillance: it edits them out of the cameras and
the enemy network a guard's search relies on. It never hides an Operator from a guard's own
eyes. An alerted guard that can't currently see a cloaked Operator loses track of them.

### Bodies

**Stunned.** An enemy hit by a shot. It stays in place without vision and skips its next 3 turns
(placeholder). A guard who finds it raises an alert. If it wakes without having been tied up, it
raises an alert itself. If it wakes inside a receptacle, it makes noise instead, and a guard
passing within its sound radius comes to let it out.

**Tied up.** A stunned enemy restrained by an adjacent Operator for 2 AP. It's out of the battle
unless another enemy finds and unties it. A guard who finds it raises an alert.

**Carry.** An Operator picks up a stunned or tied-up enemy over their shoulder. Picking up and
putting down are free. While carrying, the Operator can only move, with no movement penalty.

**Receptacle.** A place a body fits: a dumpster, a car's trunk, a locker, a closet, a trash can.
Putting a carried body down on the receptacle's tile puts it inside.

**Hidden.** A body out of every enemy's sight, or inside a receptacle. Guards don't search
receptacles; the only way a hidden body is found from inside one is by waking and making noise.

**Downed.** An Operator who has taken their last hit. They're out for the rest of the battle;
nothing carries over afterwards. If every Operator is downed, the battle is lost.
