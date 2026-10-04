# Rules

V1, in progress. Only agreed rules go here. The reasoning, and anything still being worked out,
is in [the rulebook exploration](explorations/rulebook.md). Once V1 is done, this file is
published to Google Drive for sharing and comments.

## Glossary

| Term | Meaning |
|---|---|
| Operator | A human member of the team. They carry their AI in a backpack |
| AI | An Operator's agent. It acts in the network |
| Node | Anything on the network the AI can move to or hack |
| Breached | A node that has been hacked. The AI's team controls it |
| Context | The AI's context window. It lasts the whole battle, and every hack, tool call and ability adds to it |
| AP | Action points. Each action costs AP |
| Round | Every unit on the map takes one turn |
| Turn | One unit acting. An Operator's turn lasts until their AP is spent or they end it |
| Downed | An Operator who has taken their last hit, out of the battle |
| Skill chip | A retro-futuristic disk holding a skill, loaded into the AI's context when used |
| Gadget | Equipment an Operator uses in battle, at an AP cost. Robots are gadgets |

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
     moves into the Operator's line of fire.
   - Sprint: 3 tiles for 2 AP. On 8 AP an Operator can move up to 12 tiles in a turn, but an
     Operator who sprints can't shoot or set overwatch that turn.
   - Peeking through a door costs 1 AP. The Operator sees into the space beyond until their
     turn ends.
   - Opening an unlocked door is free. Locking a door costs 1 AP.
   - Deploying the AI to the network costs 1 AP.
   - Gadgets cost AP to use, depending on the gadget, and sit outside the one-shot limit. A
     flashbang costs 2 AP and blinds the guards in its blast radius for 3 turns.
5. AIs play aggressively, on their own AP, separate from the Operator's: the AI's autonomy is the
   point. For now they start each turn with 2 AP, and moving through the network costs 1 AP.
   The AI's action system is under review.
6. Refund: a single hack action that takes a node from untouched to Breached refunds its AP.
   Finishing the last part of a breach that took several turns does not.
7. AIs can share compute while their Operators stand adjacent, physically linked: each AP one AI
   gives up, another AI gains.
8. Context is not part of the action economy. It's the AI's battle-long resource, and the only
   limit on chaining refunds.
9. Hacking never fails. An action makes progress, or at worst none.

## Skills

10. Every AI skill is a chip, Cloak included. Chips are set before the battle and locked for its
    length. Each AI carries at most 3, plus the network-movement chip, which is free and doesn't
    count toward the cap but still has to be loaded. There's no randomness: every chip an AI
    carries can be used.
11. Using a chip loads it into context, which costs context and no AP. The player can see which
    chips are loaded and which aren't yet, and inspect any chip to see what it does.
12. Chips and post-training give AIs their specialties. AIs have no internet: they know
    only their training data and what's on their chips.
    - The protagonist's new partner AI starts general. After the tutorial battle, the player
      answers a series of questions that set its starting abilities and specialization.
    - The other two AIs arrive with set personalities and starting specialties. Any AI can be
      reshaped into anything over the game.
    - Chips do many different things. One possible kind multiplies hack power against a category
      of device, for example 1.5×. Context costs are high enough that loading every chip on the
      first turn isn't the obvious play.
    - Compaction degrades chips, defined chip by chip. A multiplier chip drops from 1.5× to 1.25×,
      then unloads and has to be loaded again.
    - The network-movement chip only unloads if a compaction takes context below its own cost.

## The network

13. A Breached node can be a lily pad. Jump: a compromised node extends the AI's reach that turn.
14. The network has its own opposition: ICE that blocks a route until it's broken, daemons that
   trigger when a node is Breached, and security hubs that re-lock things.
15. Breaching a device lets the AI use its verbs. Every device mixes from a short list, such as
    power, sense, move, lock, signal and harm.

## Surveillance and stealth

16. Detection is visibility only. There is no sound.
17. Every camera starts enemy-controlled and can spot Operators. Breaching it disables the
    threat and gives the team its vision.
18. A camera that spots an Operator alerts guards that someone is in the area, and the closest
    guards go to investigate. Some areas, such as deep inside an enemy headquarters, alert every
    enemy in a zone.
19. Cloak hides an Operator from surveillance, never from a guard's own eyes. It erases them
    from the cameras and the enemy network a guard's search relies on, so an Operator behind
    cover and cloaked drops off the radar.
20. There is no battle-wide clock.
21. Every guard's vision cone is visible at all times while the guard is outside the fog. A cone
    has two tiers:
    - Seen, the core: the guard is alerted.
    - Noticed, the outer part: the guard marks the spot, goes there to investigate on its turn,
      and if it finds nothing goes back to its patrol.
22. While the player plans a move, the tiles that would get the Operator noticed or seen are
    marked.
23. Light controls visibility. Darkness shortens a guard's cone, and a light that goes out draws
    a guard to investigate it. Lights are a hacking target: cover for the Operators, and a lure.
24. A move that reveals a guard stops at the tile where it was revealed. If the Operator is in
    that guard's seen tier, the guard is alerted at once, but the Operator's turn carries on.
25. An alerted guard acts on its own turn, never during the player's. If it loses track of the
    Operator, it searches, then gives up and goes back to its patrol.
26. After an alert, the area stays on caution for a while, with guards more watchful, before it
    settles.

## Enemies

27. Enemies have no HP. A hit stuns them: they stay in place without vision and skip their next
    3 turns (a placeholder for testing).
28. An Operator next to a stunned enemy can spend 2 AP to tie them up. A tied-up enemy is out of
    the battle unless another enemy finds and unties them.
29. A guard who finds a stunned or tied-up enemy raises an alert.
30. An Operator next to a stunned or tied-up enemy can move them at no extra AP: drag them along
    behind with normal movement, or push them ahead and step forward with them.
31. For now there is one standard enemy, with no special traits, so the rules can be tuned
    before enemy types are added.

## Defeat and recovery

32. An Operator goes down after one hit. Armor adds hits: basic armor takes one more, and heavy armor
    takes two more but costs 1 AP. A downed Operator is out for the rest of the battle.
33. A crashed AI is kicked back to its backpack, and its context is wiped.

## Robots

34. Robots are gadgets, such as a drone or a dog bot. Deploying one costs 3 AP.
35. A deployed robot has its own AP pool and a speed that puts it in the turn order. Its vision
    is shared with the Operators, so it lifts the fog.
36. Robots scout, distract enemies, and can carry a single-use stun. They never hack on their
    own. Instead, a robot is a relay: the Operator's AI can reach the network through it, which
    sends access behind enemy lines.
    - A robot relays from within tether range of an access point, like an Operator. Its link to
      the Operators has no range limit.
    - A robot that ends its turn at an access point lets any Operator, on their next turn, spend
      1 AP to send their AI in through it.
    - An AI connects through one Operator or robot at a time.
    - If the robot is hit while relaying, the connection is severed at once. The AI is pulled out
      and keeps its context.
37. One hit downs a robot, and no upgrade changes that. A downed robot is gone for the rest of
    the battle and rebuilt afterwards.

## Progression

38. In V1, every Operator has the same stats. They differ only in personality.
39. Operators upgrade through gear, and AIs through hardware, harness and post-training.
    Upgrades add abilities and options rather than bigger numbers.

## Not written yet

Combat, stealth and detection in full, hacking depth, enemy AIs, mission structure and
progression. The order of work is in [the rulebook exploration](explorations/rulebook.md#order-of-work).
