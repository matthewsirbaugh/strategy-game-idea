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
     have AP, and when their turn ends they are in overwatch.
   - Sprint gives extra AP and makes noise that guards can hear.
   - Opening an unlocked door is free. Locking a door costs 1 AP.
   - Deploying the AI to the network costs 1 AP.
   - Gadgets cost AP to use, depending on the gadget. A flashbang costs 2 AP and blinds the
     guards in its blast radius for 3 turns.
5. AIs play aggressively. They start each turn with 2 AP, and moving through the network costs
   1 AP. Upgrades can raise this.
6. Refund: a single hack action that takes a node from untouched to Breached refunds its AP.
   Finishing the last part of a breach that took several turns does not.
7. Context is not part of the action economy. It's the AI's battle-long resource, and the only
   limit on chaining refunds.

## The network

8. A Breached node can be a lily pad. Jump: a compromised node extends the AI's reach that turn.
9. The network has its own opposition: ICE that blocks a route until it's broken, daemons that
   trigger when a node is Breached, and security hubs that re-lock things.
10. Breaching a device lets the AI use its verbs. Every device mixes from a short list, such as
    power, sense, move, lock, signal and harm.

## Surveillance and stealth

11. Every camera starts enemy-controlled and can spot Operators. Breaching it disables the
    threat and gives the team its vision.
12. A camera that spots an Operator alerts guards that someone is in the area, and the closest
    guards go to investigate. Some areas, such as deep inside an enemy headquarters, alert every
    enemy in a zone.
13. Cloak hides an Operator from surveillance, never from a guard's own eyes. It erases them
    from the cameras and the enemy network a guard's search relies on, so an Operator behind
    cover and cloaked drops off the radar.
14. There is no battle-wide clock.
15. Every guard's vision cone is visible at all times while the guard is outside the fog.
16. A move that reveals a guard stops at the tile where it was revealed. If the Operator is in
    that guard's cone, the guard is alerted at once, but the Operator's turn carries on.
17. An alerted guard acts on its own turn, never during the player's. If it loses track of the
    Operator, it searches, then gives up and goes back to its patrol.

## Enemies

18. Enemies have no HP. A hit stuns them: they stay in place without vision and skip their next
    3 turns (a placeholder for testing).
19. An Operator next to a stunned enemy can spend 2 AP to tie them up. A tied-up enemy is out of
    the battle unless another enemy finds and unties them.
20. Tougher enemies mix traits: they need two stuns, are immune to the basic shot, wake up
    faster, or wake nearby guards.

## Defeat and recovery

21. An Operator goes down after one hit. Armor adds hits: basic armor takes one more, and heavy armor
    takes two more but costs 1 AP. A downed Operator is out for the rest of the battle.
22. A crashed AI is kicked back to its backpack, and its context is wiped.

## Robots

23. Robots are gadgets, such as a drone or a dog bot. Deploying one costs 3 AP.
24. A deployed robot has its own AP pool and a speed that puts it in the turn order. Its vision
    is shared with the Operators, so it lifts the fog.
25. Robots scout, distract enemies, and can carry a simple hack or a single-use stun.
26. One hit downs a robot, and no upgrade changes that.

## Progression

27. Operators upgrade through gear, and AIs through hardware, harness and post-training.
    Upgrades add abilities and options rather than bigger numbers.

## Not written yet

Combat, stealth and detection in full, hacking depth, enemy AIs, mission structure and
progression. The order of work is in [the rulebook exploration](explorations/rulebook.md#order-of-work).
