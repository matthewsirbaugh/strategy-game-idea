# Brief: the protagonist's head, and his pack's side view

Request 27. The Meshy pilot's body came out well, but from only a front and a back view Meshy
painted skin onto everything facing sideways: the sides of the curls (so the hair looks
see-through), the edges of the mask straps, the sides of the head. The glasses came out painted
flat on the face. The head also filled only about 150 px of the body image, so the face is soft.

The fix (Bryson, 2026-10-13): model the head on its own from four large views, and graft it onto
the body at the jacket collar. The pack gets a true side view before it is modeled, for the same
reason. No design changes.

Source of truth: [body-front.png](../sources/units/operator_protagonist/body-front.png) and
[body-back.png](../sources/units/operator_protagonist/body-back.png), with
[01-main.png](../sources/units/operator_protagonist/01-main.png) for detail. The pack:
[pack-back.png](../sources/units/operator_protagonist/pack-back.png) and
[pack-three-quarter.png](../sources/units/operator_protagonist/pack-three-quarter.png). What the
first model got wrong is in
[the captures](../previews/operator-protagonist-meshy-body-2026-10-13/).

## The images

| File | View | Size |
|---|---|---|
| `head-front.png` | Head, straight-on front, eye-level camera | 1024 × 1024 |
| `head-side.png` | Head, true profile, his left side, same camera height and distance | 1024 × 1024 |
| `head-back.png` | Head, straight-on back | 1024 × 1024 |
| `head-three-quarter.png` | Head, three-quarter front, his left side | 1024 × 1024 |
| `pack-side.png` | Pack alone, true profile of the side the pole is on | 1024 × 1024 |

Head images:
- Head and neck, down to the top of the jacket collar and the tee's neckline, so the cut line
  shows. Nothing above the head cropped; the head fills most of the frame.
- Every view the same head size, camera height and lighting: plain mid-grey background, even
  soft light, no cast shadows. Same style and rendering as the body images.
- The curls are dark hair all the way through, with no skin showing between them except where the
  sheet shows skin (hairline, sideburns).
- The mask, its straps and the strap around the back of the head are dark grey and black with the
  orange filter rims, on every edge, seen clearly from the side and back.
- The orange-tinted glasses are a distinct object, frames visible in profile, sitting on the
  nose and ears above the mask.

Pack image: the same pack, same background and light as the other two pack images. The pole and
its cables in profile, shoulder straps attached. The three-quarter view already shows the side
without the pole.

## Where they go

Candidates in `art/concepts/operator-protagonist-head-<date>/`, with a short README. Bryson's pick
is copied unchanged to `art/sources/units/operator_protagonist/`, and Claude models from there:
the head from all four head views, the pack from its back, three-quarter and side views.
