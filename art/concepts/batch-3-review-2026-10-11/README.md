# Batch 3: vehicles and research-park fixtures

Request 6. Generated with the built-in image generation tool on 2026-10-11 from
[the batch 3 briefs](../../briefs/batch-3-vehicles-and-fixtures.md). Eight main views and two vehicle
side views, ready for Bryson's review.

| # | Item | Main view | Side view | Source folder after selection |
|---|---|---|---|---|
| 1 | Fleet car | [Main](01-fleet-car-main.png) | [Side](01-fleet-car-side.png) | `art/sources/devices/fleet_car/` |
| 2 | Service van | [Main](02-service-van-main.png) | [Side](02-service-van-side.png) | `art/sources/devices/service_van/` |
| 3 | Pole light head | [Main](03-pole-light-head-main.png) | — | `art/sources/props/pole_light_head/` |
| 4 | Security scanner head | [Main](04-scanner-head-main.png) | — | `art/sources/devices/scanner_head/` |
| 5 | Barrier gate housing | [Main](05-barrier-housing-main.png) | — | `art/sources/props/barrier_housing/` |
| 6 | Electric vehicle charger | [Main](06-ev-charger-main.png) | — | `art/sources/props/ev_charger/` |
| 7 | Concrete planter | [Main](07-planter-main.png) | — | `art/sources/props/planter/` |
| 8 | Bench | [Main](08-bench-main-v2.png) | — | `art/sources/props/bench/` |

Prompts used the proof-run style and framing blocks, the object descriptions in the brief, and
the campus forecourt, threshold and river-crossing images as design references. Approved
proof-run props supplied material references, within the tool's five-reference limit.

The fleet car was revised under Bryson's direction to a lower, sleeker futuristic fastback with
Tesla-like proportions and a smaller roof sensor. Bryson responded "Much better." Its side view
was regenerated from the revised main. The scanner's first render was too similar to the camera
head; the saved version has the upright capsule shape, horizontal glass band and compact rear
clamp requested in the brief. The bench was then refined at Bryson's request with sharper chamfers, a recessed black base,
a bevelled side panel and a warm strip beneath the wood seat, to tie it to the campus fixtures.
The [first bench](08-bench-main.png) is retained for comparison; the table points at its revision.

Astra visually inspected the ten images and checked their PNG files. Each contains one whole
object on grey, without ground, text or scene clutter. Both vehicles have matching side profiles.
The light head shows its underside panel and collar; the scanner includes its clamp; the barrier
housing includes its hub. Long poles and the barrier arm are omitted as the brief requires. The
charger includes its cable and dock. The planter contains its soil and planting, and the bench
has a concrete body with wood slats and no back.

No model generation, Godot checks or playtests were performed. After Bryson selects images, copy
each main to `01-main.png` and each vehicle side to `02-side.png` in the source folders above,
then finish Request 6's delivery status.
