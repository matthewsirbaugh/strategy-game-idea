# Fog repair: movement ticks and dark hidden scenery

Vision tick: one completed square of movement, or a discrete action that changes what the team
can see. It is not a rendered frame or a battle-wide clock.

Vision snapshot: a detached record of what the rules let the player see at one tick, saved so
the graphics can show that moment even after the rules have finished the action.

- Status: proposed repair plan for Claude/Opus review, 2026-10-11. No game changes implemented.
- Author: Astra. Review handoff: [Request 16](claude-and-astra.md#requests).
- Source reviewed: `7a72375e1cfddded8faba9da084bf0128397e0f2` on `main`.
- Follows [startup-and-fog.md](startup-and-fog.md). That delivery's static checks did not
  establish the movement behavior Bryson requires; this is its playtest follow-up.

## What Bryson asked for

On 2026-10-11, Bryson clarified that vision and its graphics must update with each square a
character, enemy or other object moves, ideally instantly. The same applies whenever another
action gains vision. Waiting until the turn ends is a minimum fallback, not the target.
Hidden scenery must stay dark; its real assets appear when the team can see it.
This request is to review the code and prepare a plan for Opus, not to implement the repair.

Inherited constraints: team sight, darkness, Breached cameras, robots and peeks still come from
[RULES.md](../RULES.md#stealth). Locate reveals an enemy's live position without granting scenery
vision around it. Keep current live vision and last-known behavior; this plan does not propose
remembered scenery or a permanent union of every cell ever seen. The fitted boxes and partial
asset clipping from Request 14 remain the starting point.

## Findings from the current code

| Finding | Evidence | Consequence |
|---|---|---|
| Player movement already calculates vision on every square, synchronously before playback. | [BattleState.move](../game/rules/battle_state.gd#L617) places the mover and calls `refresh()` inside its path loop. Its returned move event contains `path` and cost, with no intermediate visibility. | The rules know the intermediate views, then discard them. The controller receives the endpoint state. |
| Graphics refresh after the entire event list. | [Battle._play](../game/battle/battle.gd#L594) awaits `_walk` and other events; `_refresh()` is after the loop. [UnitView.walk](../game/battle/unit_view.gd#L123) has position/visibility tween callbacks, but no vision tick callback. | Scenery remains under the old mask while the character walks. End-of-action refresh exists, so adding another end-turn refresh alone does not fix this. |
| Movement playback reads final-state visibility. | [Battle._walk](../game/battle/battle.gd#L887) calculates every `shown` entry using the same current `state.visible_cells`; [_any_seen](../game/battle/battle.gd#L906) also reads that mask. | Calling `_refresh_fog()` at each tween callback without saved tick data would reveal endpoint information too early and miss transient views. |
| The renderer can update immediately when supplied correct cells. | [GridView.set_visibility](../game/battle/grid_view.gd#L65) immediately uploads the binary mask. [Battle._refresh_fog](../game/battle/battle.gd#L672) then refreshes scenery culling and characters/markers. [SceneryFog.refresh](../game/battle/scenery_fog.gd#L57) updates both representations. | Keep this separation between visibility and brightness. The missing part is delivering the right tick to all consumers together. |
| Enemy steps and vehicle motion need explicit coverage. | [BattleState.step](../game/rules/battle_state.gd#L674) updates known enemies but does not recompute team vision. [EnemyAI._walk](../game/rules/enemy_ai.gd#L183) collapses steps into one move event. [Devices._drive](../game/rules/devices.gd#L136) moves the rules vehicle straight to the endpoint. [LevelView.drive](../game/battle/level_view.gd#L168) refreshes that vehicle's coverage during its tween, against the existing mask. | An enemy entering/leaving sight needs a tick even when the cell mask is unchanged. A vehicle can change line of sight and lighting; moving its box alone does not update the team's vision. |
| Hidden scenery bypasses the old darkening. | [fog_box.gdshader](../game/art/shaders/fog_box.gdshader#L2) is unshaded, with fixed face values `0.48`, `0.28`, `0.34`. [ground.gdshader](../game/art/shaders/ground.gdshader#L38) gives hidden ground `0.32`, outside its `fog_light` branch. | The boxes read as gray geometry regardless of the old fog brightness. Changing the visibility timing will not correct their appearance. |
| Existing fog checks bypass this interaction. | [test_scenery_fog.gd](../game/tests/test_scenery_fog.gd#L17) assigns visible cells directly. [verify_fog.gd](../tools/verify_fog.gd#L103) supplies an artificial half-map mask; its drive checks happen after movement. [test_battle_flow.gd](../game/tests/test_battle_flow.gd#L145) waits for the move to finish. | These checks establish masking, fitting and final state, but cannot establish per-square reveal during actual action playback. |

### Read-only diagnostic

Ran one temporary headless probe with Godot 4.7.2. Fixture: an open 14-by-3 map in daylight,
one Operator at `(0, 1)` with test-only sight 2, no guards, moving six squares to `(6, 1)`.
Cell `(2, 0)` is unseen initially; its visibility after successive steps is
`true, true, true, false, false, false`. The current move returned only
`type, unit, path, cost`, and its final state excludes that cell. GridView retained its old
mask until explicitly updated; applying the final cells immediately revealed the destination.

This confirms both transient visibility loss in the event contract and a working mask upload
when called. The probe changed no repository source, map or stats. The engine emitted its macOS
certificate-access warning. No full test suite, native rendering check or playthrough was run
for this planning request. Shader appearance findings above are from source, not a new capture.

## Recommended repair, pending review

Keep the rules synchronous and headless. Add value snapshots to the existing action events,
then play those snapshots at square boundaries. This is a proposed event-contract change,
requiring the joint review in the [shared coding guide](shared-coding-guide.md#boundaries).

| Approach | Tradeoff | Recommendation |
|---|---|---|
| Refresh from live `state` during the existing tween. | Small change, but `state` is already at the endpoint. It skips intermediate vision and can reveal the future. | Reject. |
| Save snapshots while resolving the action, apply them during playback. | Keeps current rules/action flow; adds a bounded amount of plain event data and a tick callback. | Preferred. |
| Resolve authoritative rules one square at a time during animation. | Could work, but changes action execution, previews, interruption, costs and turn flow. | Larger alternative; outside this repair unless jointly chosen. |

### A. Save the information before it is lost

Capture one snapshot after each authoritative movement square and each other visibility change.
Use the same perception queries for Operators, robots and automatic enemy actions. Ensure an
enemy step observes changes such as a sight-providing teammate going down earlier in its turn.
For vehicles, record intermediate node positions and recompute sight/light at each square;
preserve the existing route, collision, stun, action cost and final sound behavior.

The proposed payload contains copied visible cells and lit cells; unit ids with the tick's cell,
facing and display visibility/body flags; known positions and revealed membership; and the device
display changes needed for that tick. Visibility-dependent cones/aim lines must use that moment's
facts too, either captured as derived data or produced from a detached tick record. Do not store
mutable Unit/device references as historical facts or clone the entire battle for every square.

Keep movement snapshots aligned with the actual walked path, including early stops. Preserve
the order of reveal, alert, hit and overwatch effects: a snapshot before an effect must not contain
its result, and a snapshot after it must. End-turn cleanup is a separate final snapshot when it
removes a peek or expires Locate. Audit event consumers such as Predict, logs, previews and tests
before changing the shape; the existing event names/path/cost meanings should stay compatible.

### B. Apply a tick when the moving piece reaches its square

Add a controller-owned arrival callback to unit and vehicle playback. Keep the previous square's
vision while travelling between centers; on arrival, apply that square's snapshot before the
next rendered frame. Process ticks for fully hidden moves even when they have no tween duration.

One presentation operation must update the binary mask, brightness targets, scenery detail/proxy
culling, character visibility, last-known markers and visibility-dependent overlays from the
same snapshot. Tick visibility must not depend only on whether the cell dictionary changed:
an enemy can cross into an unchanged visible region, or Locate can reveal it separately.
Use the tick's information for `_walk`'s show/hide decisions and `_any_seen`'s camera decisions.

Do not call the full `_refresh()` at every square: it snaps all views to their final rules cells
and updates devices from their endpoint state. Apply tick display data without mutating live
rules or cancelling the mover's tween. Keep the existing full refresh after the event list as
the final reconciliation before input is restored.

### C. Cover vision gained or lost outside movement

Use the same operation at the relevant action boundary for opening/closing a door, peek and its
expiry, camera breach or power changes, lights/hub blackout or restoration, robot deployment or
loss, Locate activation/expiry, and other on-map unit changes. An AI's network hop alone grants
no physical sight; its later breach or device action can. Update in physical and Network views,
so returning to the physical view cannot restore a stale mask.

Synchronize device geometry, screens and power with the tick that changes sight. Refresh before
a cosmetic pause where the action is already complete; a hack's existing 0.3-second pause must
not hold newly granted camera vision back. Snapshot action-end/turn-start transitions as needed
so automatic cleanup cannot erase the last movement tick before it is displayed.

### D. Restore the dark hidden treatment

Use a dark charcoal palette for hidden boxes, with only enough top/side variation to read shape.
Make hidden ground equally restrained and plain. Keep actual textures, lettering, screens,
emission, outlines and real-model shadows clipped out of hidden portions. Scene lights must
not turn a hidden placeholder into bright gray scenery.

Reveal the actual asset immediately from the binary mask, even in an unlit cell the rules say
the team can see. Set its visibility-driven brightness to the tick's value immediately; the
current reveal-triggered fluorescent flicker must not postpone that appearance. Review whether
to keep a subtle cosmetic effect separately from real light-device changes. Exact charcoal
values and any remaining effect are proposals for Bryson's visual review. Keep the fitted boxes,
rotation/motion, partial clipping and wall ghosting; preserve character/preview opt-out.

### E. Verify the player's interaction

Extend the existing fog/battle-flow checks with a focused movement regression, rather than a
new general test framework. Sample while `_play` is still running; assigning a mask and calling
refresh manually is not sufficient. After the focused checks pass, run `bash tools/check.sh`
and native Metal checks, then restart the committed game for Bryson as AGENTS.md requires.

| Acceptance case | Required result |
|---|---|
| Multi-square Operator move; second teammate or robot contributes sight. | Each reached square's mask and real/proxy geometry agree before its next rendered frame, while the move is still busy. Shared sight is retained. |
| A cell visible only midway; a cell visible only at the endpoint. | Midway detail appears and hides at the correct ticks; endpoint detail does not appear early. A stopped move grants no unwalked square's sight. |
| Enemy crosses a visible area, including fully hidden stretches. | It appears/disappears with the correct tick and Locate exception; markers and visible cones use that tick, not a future position. Hidden enemies grant no team sight. |
| Door, peek, camera breach/power, light/hub, robot deployment/loss and Locate. | Gains and losses display at the corresponding action boundary, without waiting for another move or turn. Locate grants no surrounding scenery vision. |
| Vehicle passes a sight line or moves a light source. | Team sight and light use the intermediate rules position; real/proxy geometry follows the displayed vehicle. |
| Unlit visible tile, brightly illuminated hidden tile, partial car/sign from two angles. | Visibility selects actual assets immediately; hidden portions stay dark/plain. No lettering, emission, outline or hidden-detail shadow leaks. |
| Turn completion, automatic turn, Network return, restart and previews. | Final graphics agree with authoritative state; peek/Locate cleanup is timely; clone/preview actions do not change the live display. |

Inspect native frames at square arrivals, including a transient reveal, and save a short sequence
for Bryson. Report headless behavior, native scripted interaction and Bryson's playtest separately.
Watch the representative facility yard for tick stalls; upload masks only when they change and
retain cached asset bounds. Do not add per-frame perception queries or claim a performance gain
without the guide's measurements. Release action snapshot data after playback/restart.

## For Claude/Opus

1. Review the snapshot approach and its capture points, especially enemy hits/overwatch, vehicle
   motion and end-turn cleanup. Record accepted parts, amendments or a concrete smaller alternative.
2. Review the dark treatment and immediate reveal against Bryson's clarification. Keep exact
   palette/effect decisions for his visual review.
3. Record the response here, link its commit in Request 16, and identify any remaining decisions
   for Bryson. This handoff authorizes review; implementation/file claims come after plan approval.

## Review response

Awaiting Claude/Opus review. No architecture or palette proposal above has been accepted yet.
