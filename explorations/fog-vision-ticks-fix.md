# Fog repair: movement ticks and dark hidden scenery

Vision tick: one completed square of movement, or a discrete action that changes what the team
can see. It is not a rendered frame or a battle-wide clock.

Vision snapshot: a detached record of what the rules let the player see at one tick, saved so
the graphics can show that moment even after the rules have finished the action.

- Status: approved by Bryson 2026-10-11 with Claude/Opus's amendments; Astra builds it under
  Request 17, following [the build guide](#approved-plan-and-astras-build-guide).
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

Claude/Opus, 2026-10-11, reviewing `775415f`. Review only; nothing below is approved until Bryson
says so.

Silhouette: a hidden piece of scenery drawn as a flat dark shape, with no texture, lettering,
screen, glow or lamp shading. Visibility mask: the one-texel-per-tile texture saying which tiles
are seen right now.

### What Bryson added in this review (2026-10-11)

- Hidden models are meant to be silhouettes, not just darker versions of themselves.
- Every square a vision source moves updates the silhouettes and reveals: whatever parts of models
  and whatever units the new view covers appear, and what it leaves goes back to silhouette.
- This applies to everything that gives vision: Operators, drone, dog bot, cameras.
- The look is part of the deliverable. Request 14 replaced the dark textured ground with light
  gray and made hidden scenery near-white boxes, which broke the game's established look.

### Verdict

The diagnosis is right and the snapshot direction is right: keep the rules synchronous, record
what the team saw at each square, and play it back on arrival. Rejecting the live-`state` refresh
and the square-by-square rules rewrite is correct too.

Two amendments change the shape of the work: shrink the snapshot to what the screen needs (1–4
below), and draw hidden scenery as silhouettes inside the existing shaders instead of fitted boxes
(5–8), which fixes the look, removes most of Request 14's machinery and makes every tick nearly free.

### Why the look broke (source, checked against the Request 14 captures)

| Cause | Where | Effect on screen |
|---|---|---|
| Boxes are `unshaded` with albedo 0.48 / 0.34 / 0.28. Albedo is linear, so 0.48 shows on screen at roughly 0.7 | `fog_box.gdshader` | Near-white boxes that night lighting can't touch: the brightest objects in a night scene are the ones you *can't* see |
| Hidden ground is a flat 0.32 albedo, still lit by every lamp, with no `fog_light` darkening | `ground.gdshader` | Hidden ground is lighter than seen ground; joints, grime and wet puddles vanish |
| The visibility mask holds only `visible_cells`, but brightness also lights walls beside a seen tile | `GridView.set_visibility` | The building the team is standing next to stays a box ([level-initial.png](../art/previews/startup-and-fog-2026-10-11/level-initial.png)) |

For Astra: the starting point for the look is the last build before fog,
[vision-glow.png](../art/previews/visual-polish/vision-glow.png). A visual change is compared
against the build before it in the same camera framing, and anything that changes the established
look without being asked for is flagged before it's delivered, not after.

### Amendments: vision ticks

1. **A small tick.** Add `rules/vision_tick.gd`, a `VisionTick` with four copied dictionaries:
   `cells` (visible), `lit`, `shown` (id → cell for every non-player unit the team sees, Locate
   included) and `known`. `VisionTick.capture(state)` builds it. Leave devices, cones and aim
   lines out of it: nothing changes them mid-move except the vehicle itself, and they reconcile in the
   final `_refresh()`. If Bryson notices a cone appearing late after playing it, cones are the
   first thing to add.
2. **Three capture points, not a general recorder.** `BattleState.move` after each `refresh()`;
   `BattleState.step` after `_update_known()`, before overwatch; `Devices._drive`, which moves the
   vehicle one square at a time with `move_node` + `refresh()` + capture, since a vehicle blocks
   people's sight. The `move` and `vehicle` events gain `ticks`, one per walked square, aligned
   with `path`. Every other key keeps its meaning, so Predict, logs and tests keep working.
3. **No separate cleanup snapshot.** Each tick already carries the Locate and peek state of its own
   moment, so `_finish_turn` shrinking them before playback can't leak into the walk. The final
   `_refresh()` after `_play` then shows the cleanup. That covers Astra's end-turn concern with no
   extra mechanism.
4. **One display path.** `Battle._show_vision(tick)` updates the mask, brightness targets, unit
   visibility and last-seen markers. `_refresh_fog()` becomes `_show_vision(VisionTick.capture(state))`,
   so the playback path and the final reconcile can't drift apart. `UnitView.walk(points, on_arrive)`
   and `LevelView.drive(id, path, on_arrive)` call back after each square's tween; the walk's `shown`
   array and `_any_seen` read the ticks instead of the final state. Hidden steps are instant, so
   their callbacks still fire in order. `GridView.set_visibility` takes `(cells, lit)` instead of
   the state.

Section C mostly exists already: every discrete action (door, peek, breach, power, lights,
deploy, Locate) ends `_play` with `_refresh()`. The one gap found is the hack's 0.3-second pause,
which runs before that refresh; show vision before the pause. Alerts, hits and overwatch keep
playing after the walk as they do today. Interrupting a walk mid-path to play a shot is a separate
improvement and isn't needed for this fix.

### Amendments: silhouettes instead of boxes

5. **Draw silhouettes in the scenery's own shaders.** Wherever `scenery && !fog_visible(world)`,
   the toon, wall and fog-surface shaders output `ALBEDO = 0`, `EMISSION = SILHOUETTE` (with a
   slight top/side difference so form still reads), `SPECULAR = 0` and `ROUGHNESS = 1`. Emission
   on black albedo stays flat whatever lamps are nearby: the same trick `fog_surface`'s unshaded
   branch already uses. Lettering, sign faces, screens and glow meshes discard when hidden.
   The ink outline either stays or discards; that's for the captures to decide.
6. **What that removes.** Proxy boxes, fitted bounds, the 220-group registration, the
   VISIBLE/HIDDEN/PARTIAL classification, per-asset culling, `fog_partial`, the vehicle
   `_pose_vehicle` fog refresh and `fog_box.gdshader`. `SceneryFog` keeps only the
   StandardMaterial → masked-material conversion and the per-instance `scenery` opt-in, which
   still protect characters and previews. Partial models work for free, since each fragment
   reads the mask at its own world position.
7. **What it costs per tick.** One upload of a roughly 30×30 R8 texture plus a loop over the unit
   views. No GDScript loop over scenery and no shader-parameter calls. Draw calls return to about
   the pre-fog count (1,141, measured at 1.76 ms rendering CPU before Request 14), since hidden
   scenery is drawn again instead of culled. Measure the worst tick on the facility yard (rules
   capture plus `_show_vision`) and report it; it should be well under a millisecond.
8. **Ground and walls.** Restore the pre-fog `ground.gdshader` (`37e8413`): textured, darkened by
   `fog_light`. The mask uses the same seen set as brightness, including walls beside a seen tile
   and the border ring, built once and written to both textures.

If Bryson keeps boxes (decision 1), amendments 1–4 and 8 still apply. Fix the boxes' tone by
dropping `unshaded`, or by using the emission trick with a charcoal value; skip unchanged assets
in `refresh_visibility`; and drive the per-tick refresh from the same `_show_vision`.

### Verification

- One rules test, because it's easy to get subtly wrong: Astra's 14×3 probe, asserting
  `ticks.size() == path.size()`, that the midway cell is seen at the middle ticks and not at the
  last, and that a move cut short by a reveal has no ticks beyond where it stopped.
- Native captures, not tests, for everything else: a frame at each square of one walk with a
  transient reveal, an enemy crossing a seen strip, a car driving through a sight line, and the
  pre-fog framing beside the new one. Bryson approves the look from those before it's committed
  as done.
- Report headless, native-scripted and Bryson's playtest separately, as the plan says.

### Decisions for Bryson

1. Silhouette shape: the model's own shape (recommended: simplest, cheapest, and closest to
   "silhouettes"), or a fitted box (hides what the object is, at the cost of the extra
   machinery)? Request 14's approved goal said boxes.
2. Silhouette tone: flat charcoal, or charcoal with a faint top/side difference and the ink
   outline? Pick from captures.
3. Hidden ground: restore the pre-fog dark textured ground (recommended), or something plainer?
4. Hidden scenery shows its live state: a door opening, a car moving, lamplight spilling. Is that
   acceptable, or is any of it an information leak? Remembered scenery stays out, as before.
5. Walls beside a seen tile display as seen (recommended; presentation only, the rules don't
   change)?

## Approved plan, and Astra's build guide

Bryson approved the review's plan on 2026-10-11 ("I like your plans"), which settles decisions 1,
3 and 5 as recommended: silhouettes in each model's own shape, the pre-fog ground restored, and
walls beside a seen tile shown as seen. Decision 2 (silhouette tone) is picked from captures in
step 1. Decision 4 (live state of hidden scenery) stays open: keep today's behavior and list any
leaks the captures show. Work under [Request 17](claude-and-astra.md#requests).

Build in three commits, each one playable, so any of them can be undone on its own.

### Step 1: the look

1. Restore `ground.gdshader` from `37e8413` (textured, darkened by `fog_light`), then keep the
   `scenery` instance flag only if something still needs it.
2. In `fog.gdshaderinc`, add the silhouette color and a helper that returns it with a slight
   top/side difference. Have the toon, wall and fog-surface shaders call it wherever
   `scenery && !fog_visible(world)`: `ALBEDO = 0`, `EMISSION = silhouette`, `SPECULAR = 0`,
   `ROUGHNESS = 1`. The sign shader, lettering, screens and glow meshes discard when hidden.
3. `GridView` builds the seen set once (visible cells, walls beside them, the border ring) and
   writes it to both the mask and the brightness targets.
4. Delete the boxes: `fog_box.gdshader`, the proxy and bounds code in `SceneryFog`, the coverage
   enum, `fog_partial`, culling, the 220-group registration in `LevelView` and `_pose_vehicle`'s
   fog refresh. `SceneryFog` keeps the material conversion and the `scenery` opt-in (or that moves
   into `LevelView` if it's all that's left). Check that characters and the Model Library are
   untouched.
5. Captures, same camera framing as
   [vision-glow.png](../art/previews/visual-polish/vision-glow.png) and
   [level-initial.png](../art/previews/startup-and-fog-2026-10-11/level-initial.png), each beside
   its new version: two tones (flat charcoal; charcoal with a faint top/side difference and the ink
   outline), plus a partial car and the building beside the team. Bryson picks the tone from these
   before step 2 is delivered. If silhouettes vanish against the dark ground, say so, with the
   capture.

### Step 2: vision ticks

1. `rules/vision_tick.gd`: `VisionTick` with copied `cells`, `lit`, `shown` (id → cell for every
   non-player unit the team sees, Locate included) and `known`; `static func capture(state)`.
2. Capture in `BattleState.move` after each `refresh()`, in `BattleState.step` after
   `_update_known()` (before overwatch), and in `Devices._drive`, which now moves the vehicle a
   square at a time with `move_node`, `refresh()` and a capture. `move` and `vehicle` events gain
   `ticks`, aligned with `path`; no other key changes meaning.
3. `Battle._show_vision(tick)` updates the mask, brightness, unit visibility and last-seen
   markers. `_refresh_fog()` calls it with a fresh capture. `GridView.set_visibility(cells, lit)`.
4. `UnitView.walk(points, on_arrive)` and `LevelView.drive(id, path, on_arrive)` call back after
   each square's tween, including instant hidden steps. `_walk` and `_any_seen` read the ticks,
   replacing the `shown` array and the final-state reads.
5. Show vision before the hack's 0.3-second pause.
6. One rules test in the existing suites: the 14×3 probe from this plan, asserting one tick per
   walked square, the midway cell seen at the middle ticks and not the last, and no ticks past a
   move cut short by a reveal.

### Step 3: verify and hand over

1. `bash tools/check.sh`.
2. Native frames at each square of one walk with a transient reveal; a drone or dog bot moving
   while an Operator stands still; an enemy crossing a seen strip; a car driving through a sight
   line; and a door, a camera breach and Locate.
3. The worst tick on the facility yard (capture plus `_show_vision`) in milliseconds, and the
   settled draw calls. No speedup claims beyond what's measured.
4. Report headless, native-scripted and Bryson's playtest separately, update this file and
   Request 17, then restart the game for Bryson as AGENTS.md says.

Out of scope: interrupting a walk to play a shot mid-path, cones and aim lines per tick (they
reconcile at the end of the action; add them only if Bryson notices), and remembered scenery.
