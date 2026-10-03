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
| Downed | An Operator at 0 HP, out of the battle |

## Turns

1. Each unit's turn has two halves: the Operator in the physical world, and the AI in the
   network.
2. A unit can do several things in one turn.
3. Operators play carefully and stealth-first. They never get refunds.
4. AIs play aggressively. They start each turn with 2 AP, and moving through the network costs
   1 AP. Upgrades can raise this.
5. Refund: a single hack action that takes a node from untouched to Breached refunds its AP.
   Finishing the last part of a breach that took several turns does not.
6. Context is not part of the action economy. It's the AI's battle-long resource, and the only
   limit on chaining refunds.

## The network

7. A Breached node can be a lily pad. Jump: a compromised node extends the AI's reach that turn.
8. The network has its own opposition: ICE that blocks a route until it's broken, daemons that
   trigger when a node is Breached, and security hubs that re-lock things.
9. Breaching a device lets the AI use its verbs. Every device mixes from a short list, such as
   power, sense, move, lock, signal and harm.

## Surveillance and stealth

10. Every camera starts enemy-controlled and can spot Operators. Breaching it disables the
    threat and gives the team its vision.
11. A camera that spots an Operator alerts guards that someone is in the area, and the closest
    guards go to investigate. Some areas, such as deep inside an enemy headquarters, alert every
    enemy in a zone.
12. Cloak hides an Operator from surveillance, never from a guard's own eyes.
13. There is no battle-wide clock.

## Defeat and recovery

14. A downed Operator is out for the rest of the battle.
15. A crashed AI is kicked back to its backpack, and its context is wiped.

## Not written yet

Combat, stealth and detection in full, hacking depth, enemy AIs, mission structure and
progression. The order of work is in [the rulebook exploration](explorations/rulebook.md#order-of-work).
