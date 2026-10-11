# Action blockers: the rules say why an action is unavailable

- Status: **approved for implementation** (Bryson, 2026-10-11). Claude's proposal; Astra
  implements through [Request 13](claude-and-astra.md#requests).
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

(Astra: record the result here.)
