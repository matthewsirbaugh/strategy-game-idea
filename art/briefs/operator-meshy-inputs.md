# Brief: high-resolution Meshy inputs — the protagonist

Request 25. The protagonist is the pilot for modeling the Operators with Meshy (Bryson,
2026-10-13). His approved sheet is right, but its views are too small for Meshy and share one
image. This request redraws the same design as separate, larger views. No design changes.

Source of truth: [operator_protagonist/01-main.png](../sources/units/operator_protagonist/01-main.png)
(body) and the left column of the pack lineup,
[packs.png](../concepts/operator-revision-2026-10-13/packs.png) (his pack: olive case, orange
cables). Match them exactly: face mask, glasses, hair, jacket, tee, cargo pants, boots, colours,
wear.

## Why (Meshy's own guidance)

- One view per image, at least about 1040 px; ours are about 450 × 1000 now.
- Every view the same character size, camera height and lighting, plain background, even light.
- A T-pose input gives the most accurate proportions, and the model will be rigged in a T-pose.
- Packs modeled on a body come out flattened, so the pack is modeled as its own object and the
  body is drawn without it.

## The images

| File | View | Size |
|---|---|---|
| `body-front.png` | Body, straight-on front, eye-level camera | 1024 × 1536 |
| `body-back.png` | Body, straight-on back, same camera height and distance | 1024 × 1536 |
| `pack-back.png` | Pack and camera pole alone, straight-on back view | 1024 × 1024 |
| `pack-three-quarter.png` | Pack and pole alone, three-quarter rear view | 1024 × 1024 |

Body images:
- Strict T-pose: arms straight out horizontally, palms down, fingers together. Feet shoulder-width
  apart. The full figure fills the frame top to bottom with a small margin; nothing cropped.
- Without the pack, its straps and the camera pole. The jacket's back is plain where the pack sat.
- Plain mid-grey background, even soft light, no cast shadows. Same style and rendering as the
  sheet.
- The back view is the front view's character turned 180°: same proportions and scale.

Pack images: as the current pack images, larger, on the same plain mid-grey background. Shoulder
straps stay on the pack. The pole rises from the pack's top on the viewer's left in the back view,
as now.

## Also: the pack crops from Request 22

The 512 px pack crops in `art/sources/units/` are faulty. The protagonist's `02-pack-back.png`
shows the writer's pack, cut in half; his `03-pack-three-quarter.png` is the whole lineup. The
writer's and the developer's three-quarter crops cut off the top of the camera. This request's
pack images replace the protagonist's two; the other four get replaced when their own Meshy
inputs are made.

## Where they go

Candidates in `art/concepts/operator-protagonist-meshy-inputs-<date>/`, with a short README.
Bryson's pick is copied unchanged to `art/sources/units/operator_protagonist/`, and Claude models
from there. If the pilot holds up, the writer and the developer get the same request.
