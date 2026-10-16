# Brief: high-resolution Meshy inputs — the writer and the developer

Request 29. Bryson, 2026-10-15: make the writer and the developer the way the protagonist was
made, and get them looking as good as he does. Their approved sheets are right, but each figure
is about 450 × 1000 px, with arms down and the pack on. This request redraws the same designs as
separate, larger views: body, head and pack apart, each with a side view. No design changes.

Source of truth: [operator_writer/01-main.png](../sources/units/operator_writer/01-main.png) and
[operator_developer/01-main.png](../sources/units/operator_developer/01-main.png), with
[packs.png](../concepts/operator-revision-2026-10-13/packs.png) for pack detail. Where they
disagree, the sheet wins: the writer's camera pole is on her left shoulder (Request 23). Match
them exactly: faces, masks, glasses, hair, clothes, colours, wear.

## What the protagonist taught us

| Lesson | So this request |
|---|---|
| From only a front and a back, Meshy painted skin onto everything facing sideways: hair, strap edges | Every part gets a true side view; the head is drawn on its own from four views |
| Packs modeled on a body come out flattened | Bodies are drawn without the pack; packs are drawn alone |
| A T-pose input gives the best proportions, and the models are rigged in a T-pose | Bodies in a strict T-pose |
| Meshy wants one view per image, at least about 1024 px, the same size, camera height and light in every view | The sizes below; plain mid-grey background, even soft light, no cast shadows |
| Glasses drawn flat came out painted on the face | Glasses are distinct objects, frames visible in profile |

His set, to match in style and layout: [art/sources/units/operator_protagonist/](../sources/units/operator_protagonist/)
(`body-*`, `head-*`, `pack-*`).

## The images, for each of the two

| File | View | Size |
|---|---|---|
| `body-front.png` | Body, straight-on front, eye-level camera | 1024 × 1536 |
| `body-back.png` | Body, straight-on back, same camera height and distance | 1024 × 1536 |
| `body-side.png` | Body, true profile of their left side, same camera | 1024 × 1536 |
| `head-front.png` | Head, straight-on front, eye-level camera | 1024 × 1024 |
| `head-three-quarter.png` | Head, three-quarter front, their left side | 1024 × 1024 |
| `head-side.png` | Head, true profile, their left side | 1024 × 1024 |
| `head-back.png` | Head, straight-on back | 1024 × 1024 |
| `pack-back.png` | Pack and camera alone, straight-on back | 1024 × 1024 |
| `pack-three-quarter.png` | Pack and camera alone, three-quarter rear | 1024 × 1024 |
| `pack-side.png` | Pack and camera alone, true profile of the camera's side | 1024 × 1024 |

Body images:
- Strict T-pose: arms straight out horizontally, palms down, fingers together. Feet shoulder-width
  apart. The full figure fills the frame top to bottom with a small margin; nothing cropped.
- Without the pack, its straps and the camera. Where the pack sat, the clothing is plain.
- The head is drawn as on the sheet; it is cut away and replaced by the head model.
- The back and side views are the front view's character turned: same proportions and scale.

Head images:
- Head and bare neck only, ending at a clean cut where the head joins the body. No coat, vest,
  collar, shirt or shoulders. The mask, glasses and anything on the head stay on.
- Every view the same head size, camera height and light; the head fills most of the frame.
- Hair is hair all the way through, with no skin between curls except where the sheet shows skin.

Pack images: shoulder straps stay on the pack. The camera and its stalk or arm in full, nothing
cropped.

## The two of them

| | Writer | Developer |
|---|---|---|
| Body | Feminine build. Long worn brown coat, open at the front, knee-length, sleeves rolled once; grey sweater; the magenta scarf's ends hanging on her chest; slim dark trousers rolled at the ankle; laced brown boots; ink on her fingers | Heavyset. Charcoal padded vest, open, over a brown plaid flannel, sleeves down; black tee; worn dark jeans; brown trail boots |
| Head | Round wire glasses with the dark flip-up IR lenses raised; magenta bandana over nose and mouth, wrapped round the neck to the cut; long dark curly hair, tied loosely at the nape | Black rectangular glasses; green neck gaiter over nose and mouth, down to the cut; short curly greying hair, thin on the crown |
| Pack | Old scuffed olive consumer case with a vent, a cracked corner taped over, mismatched panel; folded papers under the strap on her left side; thin taped pole with the camera on her left shoulder | Open-frame rig of salvaged server parts: heat-sink fins, fan, hand-routed cables, latches, old stickers; camera on an articulated arm over his right shoulder; a cable coiled on his right strap |
| Camera side, for `pack-side.png` | Her left | His right |

## The writer's hair (Claude's recommendation; Bryson confirms when he activates this)

Her hair is long and falls over the coat's shoulders and back, which the protagonist's short hair
never did. If the body views show it, Meshy fuses hair and coat into one surface that can't be
cut apart. So:
- In the three body views, her hair is pinned up on her head, off the collar, shoulders and back,
  so the coat is seen whole. It's a stand-in, cut away with the head.
- In the four head views, her hair is at its full length as on the sheet, hanging as it would rest
  on her shoulders and back, with nothing under it.

The developer's hair is short, like the protagonist's, so his body views draw him as on the sheet.

## Also: the old pack crops

The 512 px crops `02-pack-back.png` and `03-pack-three-quarter.png` in both source folders are
faulty (Request 25's brief). The new pack images replace them.

## Where they go

Candidates in `art/concepts/operator-writer-developer-meshy-inputs-<date>/`, one folder per
character inside it, with a short README. Bryson's picks are copied unchanged to
`art/sources/units/operator_writer/` and `art/sources/units/operator_developer/`, the old crops
removed, and this request marked delivered. Done when all twenty images are delivered.

Then Claude models each one as the protagonist was: body from its three views, head from its four,
pack from its three, Meshy multi-image with 4K textures, grafted at the collar, rigged, fingers
added, and given the game's shared clips.
