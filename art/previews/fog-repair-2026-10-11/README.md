# Request 17: fog repair verification

Status: implemented and verified by Astra, 2026-10-11. Bryson selected silhouette tone B
(faint top/side form shading and dark ink). Human mission playtest remains open.

[Look choices and matching-camera comparisons](look/README.md).
[Implementation findings](../../../explorations/fog-vision-ticks-fix.md#request-17-implementation-findings).

| Native sequence | Frames | What it establishes |
|---|---|---|
| [Operator before](ticks/operator-before.png), [square 1](ticks/operator-01.png), [square 4](ticks/operator-04.png) | `operator-01` through `operator-06` | The cell appears for squares 1–3, then returns to silhouette while movement continues. |
| [Moving drone](ticks/drone-03.png) | `drone-01` through `drone-07` | Drone vision changes while the Operator remains stationary. |
| [Visible enemy](ticks/enemy-05.png), [hidden again](ticks/enemy-08.png) | `enemy-01` through `enemy-08` | The enemy enters and leaves the seen strip; hidden steps still consume their ticks. |
| [Vehicle first square](ticks/vehicle-01.png) | `vehicle-01` through `vehicle-04` | Moving the car opens the sight line on the first square, rather than at the endpoint. |
| [Camera breach](ticks/camera-01.png), [camera off](ticks/camera-off-01.png), [Locate](ticks/locate-01.png) | One frame each | Discrete vision changes refresh; Locate grants no surrounding scenery sight. |
| [Door opening](ticks/door-open-01.png) | One frame | Geometry and newly visible cells reconcile at the action boundary. |
| [Final facility yard](ticks/yard-final.png) | One frame | Full team, selected tone B, restored ground and the initial game framing. |
| [Partial sign](static/level-sign-partial.png), [partial car](static/level-car-rotated.png), [alternate angle](static/level-car-reverse.png) | Native full-level fixtures | Actual detail and dark model-shaped silhouettes share the cell boundary; hidden lettering/glow disappears. |
| [Network](static/level-network.png), [physical return](static/level-physical-restored.png) | Native full-level fixtures | Both transitions complete with the selected scenery treatment. |

`samples.json` in [ticks/](ticks/samples.json) records each arrival while playback is busy,
its applied mask, unit visibility and timing. Captures occur on the next rendered frame;
fully hidden zero-duration steps can share a rendered frame. The small action fixtures use
copied definitions and temporary maps: sight 2 for the transient Operator/drone probe and
zero guard perception ranges for the crossing probe, so alert interruption cannot stop that
case. The game code resolves the actions and plays them through its real `_play` path.
No source stats, maps or assets were edited for these fixtures. Cameras, vehicle power, the
surveillance chip, door and Locate were exercised through valid rule actions.

Full-yard measurement: Godot 4.7.2, Apple M1 Pro, native Metal Forward+, 1280 × 800,
34 × 22 map, three Operators and eleven units total. Warm 60 frames, then five runs of
120 capture/display calls, varying the Operator across legal movement destinations.
0.353 ms median of run maxima; 0.350–0.434 ms range; 0.434 ms worst observed. The timed region includes `VisionTick.capture` and `_show_vision`,
including enqueueing texture updates. It excludes authoritative sight/light recomputation,
graphics processor execution and complete frame time. Settled draw calls: 1,141 at the initial
camera, matching the recorded pre-box count; this is not a frame-rate or speedup claim.

All six headless suites passed. Native tick and full-level checks passed with clean rendering
logs; the flat-outline probe also passed (zero hidden ink pixels). Characters were checked for
scenery opt-out. The Model Library is a separate project with independent shaders; its source
was unchanged, and its interface was not re-tested during this request.

Hidden scenery still follows live state. Moving silhouettes, door state, and lamplight spilling
onto the restored ground remain observable; Bryson's decision on those information leaks stays
open. Cones and aim lines reconcile after each action, as approved. No full mission playthrough
or additional human creative approval is claimed.
