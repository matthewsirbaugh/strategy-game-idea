# Action blockers: the rules say why an action is unavailable

- Status: implemented and verified by Astra, 2026-10-11, through
  [Request 13](claude-and-astra.md#requests). Bryson approved Claude's proposal; his playtest
  and the information-leak decision remain open.
- Origin: the first refactor that the [shared coding guide](shared-coding-guide.md) review
  recommended.

## The problem

Today the rules answer *whether* an action is legal, and the menus work out *why not* on their own,
by re-checking state. Each menu holds its own copy of the rules' refusal logic:

| Menu code (`battle_menus.gd`) | Copies the logic of |
|---|---|
| `door_actions` blocker cascade | `BattleState.door_options` / `_hands_free` |
| `_verb_blocker` | `Devices.can_use` |
| `_chip_blocker` | `BattleState.chip_ready` |
| `deploy_blocker` | `BattleState.deploy_options` |

When a rule changes, the copy goes stale without anyone noticing, and the menu ends up explaining
the wrong reason. The door menu already falls back to the vague "This Operator cannot act right
now."

## The contract

Each of these four rule checks becomes a **blocker function**. It returns a short code saying why
the action is refused, or `""` when it is legal. Legality is defined as `blocker == ""`, so the
reason and the yes/no answer can never disagree.

| Rules function (new) | Replaces / backs | Codes, in check order |
|---|---|---|
| `Devices.blocker(state, unit, id, verb, direction) -> String` | `can_use`, which becomes `blocker(...) == ""` | `disconnected`, `not_breached`, `other_network`, `used`, `hub_off`, `no_power`, `locked`, `occupied`, `blocked`, `open` |
| `BattleState.door_blocker(unit, id, action) -> String` | the checks inside `door_options`, which builds its list from it | `cannot_act`, `carrying`, `locked`, `occupied`, `no_ap` |
| `BattleState.chip_blocker(unit, id) -> String` | `chip_ready`, which becomes `chip_blocker(...) == ""` | `cannot_act`, `disconnected`, `waiting`, `no_ai_ap`, `no_target` |
| `BattleState.deploy_blocker(unit) -> String` | the guard at the top of `deploy_options` | `cannot_act`, `rebooting`, `carrying`, `no_ap`, `out_of_reach` |

- **Check order is part of the rule.** The first failing check wins, so the player hears the most
  useful reason. Keep the order the current menus use; the table lists it.
- **Codes are facts, and wording stays in the menus.** `battle_menus.gd` gets one table that maps
  each code to its sentence, with the numbers it needs, such as AP costs or the tether range.
  The four hand-built blocker functions in the menus are deleted.
- **Verb options carry the code.** `verb_options` adds a `blocker` field beside `enabled`, so the
  menu never calls the rules twice.
- **Fog:** a code may only rest on facts the player can see. `occupied` (adjacent doorway) and
  `blocked` (a vehicle's path) are the two to check: if a hidden unit is the cause, the sentence
  must not give it away. Report what you find; don't invent new behaviour to cover it.
- Public signatures that other code calls (`can_use`, `chip_ready`, `door_options`,
  `deploy_options`) keep working. `BattleMenus.deploy_blocker` moves to the rules, and
  `battle.gd:215` follows it.

## Not in scope

- Which actions are shown or hidden. Operator actions that are simply absent when unavailable
  (move, shoot, tie up, and so on) stay absent.
- New player-facing wording, except replacing the vague door fallback.
- A generic action-descriptor class or framework. Four functions and a table are enough.
- `_door_at` duplicating `_adjacent_nodes`, and the door header's `UNLOCKED`. Fix them only if the
  change touches them anyway.

## Tests

Follow the [guide](shared-coding-guide.md#tests):
- Extend the existing availability-vs-execution loop in `test_battle_flow.gd` to doors and chips.
  For each option on a cloned state, an empty blocker means the action executes, and a non-empty
  blocker means it returns `[]`.
- Add one check that every code the rules can return has a sentence in the menu table.
- In the same pass, replace the battle-flow test's prose assertions (`"Already used this turn."`,
  `contains("visible guard")` and similar) with blocker-code checks. Keep the input regression,
  the door traversal checks, and the browsable-group, cost and effect checks.

## Done when

- The four menu-side blocker functions are gone, and every disabled row's reason comes from a
  rules code.
- `bash tools/check.sh` passes. The door, device, chip and deploy menus have been exercised in the
  native game, and each refusal there shows the right reason.
- README.md's implementation boundaries gain one line: rules return blocker codes, and menus own
  the wording.
- Anything the fog check turned up is written below, for Bryson.

## Findings

### Implemented and verified, 2026-10-11 — Astra

The four rules functions now return codes; `can_use` and `chip_ready` wrap them, door options
come from `door_blocker`, and deployment options use `deploy_blocker`. Verb options carry their
code and enabled state from one check. Menus use `BLOCKER_TEXT` for wording, including the
deployment banner; the copied refusal cascades are gone. Action visibility, costs, effects and
target validation remain intact. README records the rules/menu boundary.

Three additional codes preserve existing rejection paths that the proposal's list omitted:
`invalid_action` for unsupported verbs, invalid door operations or nonadjacent doors;
`invalid_chip` for a chip absent from the loadout or not active; `connected` for deployment
while already in the network. These guards add no new gameplay rule. Check order follows the
contract, with invalid-input guards before the corresponding device/target state is read.
Locate and Predict retain their target checks and do not acquire next-hack waiting behavior.

`bash tools/check.sh` passed all six suites. The cloned-state availability/execution checks now
cover doors, active chips with valid targets, deployment and device verbs, with refusal-order
checks and wording coverage for all 21 nonempty codes. Input, door traversal, browsable groups,
costs and chip effect checks remain. Refusal assertions use codes rather than prose.

The battle-flow suite also passed with the native Metal renderer, driving the real menus,
clicks and keys. [verify_blocker_menus.gd](../tools/verify_blocker_menus.gd) separately verified
native deployment notes and disabled door/device/chip rows, including their hover reasons.
Its four captures were visually inspected:
[deployment cost](../art/previews/action-blockers-2026-10-11/deploy-no-ap.png),
[device power](../art/previews/action-blockers-2026-10-11/device-no-power.png),
[waiting chip](../art/previews/action-blockers-2026-10-11/chip-waiting.png),
[locked door](../art/previews/action-blockers-2026-10-11/door-locked.png).
These are native scripted checks, not Bryson's playtest or a full mission playthrough.

### Fog information audit — existing behavior, Bryson's decision remains open

Reproduced on `facility_yard.tres`, with the active Operator beside access B, its AI connected
there, other Operators down and no Breached cameras providing sight:

| Case | Observation |
|---|---|
| Adjacent open doorway | An Operator one tile south of O sees an occupant on O. `occupied` rests on visible information in this case. |
| Remote automatic door O, Breached, powered, unlocked and open | An enemy on O is unseen (`player_sees == false`, cell absent from team vision), but its Close action returns `occupied`; moving the enemy away makes it legal. The generic sentence gives no identity, but availability reveals occupancy. |
| Powered, Breached truck V, forward | A stunned unseen guard on the next tile (30,10) returns `blocked`; moving it away makes driving legal. An unstunned unseen guard instead leaves driving legal because the vehicle can strike it. Availability can therefore reveal a hidden body immediately ahead. |

The old `Devices.can_use` checked the same occupants/path, so neither leak was introduced by
this refactor. The menu still says "Something is in the way." for the remote device/vehicle;
changing wording alone cannot hide a disabled action. No visibility or action rule was changed
to conceal it. Bryson and Claude need to decide whether remote control is allowed to expose
these facts, or whether availability should remain uncertain until an action is attempted.
The approved scenery fog also follows current scenery positions/state, so it is not a
remembered-state system; that remains the explicit Request 14 default.
