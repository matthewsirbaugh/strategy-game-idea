# Brief: fixes to the writer's and the developer's Meshy inputs

Request 30, following [Request 29](operator-writer-developer-meshy-inputs.md) (read that brief
first; everything in it still holds). Bryson reviewed the twenty candidates on 2026-10-15 and
wants every problem fixed in the images, not after modeling: "I would rather get the right images
than try fixing it once it's a model." Above all, the three Operators must look like one cast in
one style.

Candidates reviewed: [Request 29 gallery](../concepts/operator-writer-developer-meshy-inputs-2026-10-15/README.md).

## What Bryson accepted

The writer's style is right ("the girl is fine"). These views stay as they are, unless a check
below shows a problem:

| Writer | Developer |
|---|---|
| `body-front`, `body-back` | `body-front`, `body-back` |
| all four `head-*` (subject to the scale check, fix 3) | all three `pack-*` |
| all three `pack-*` | |

## The house style

DESIGN.md: the world is realistic; the characters are stylized, neither anime nor realistic, after
the adopted [protagonist sheet](../reference/operator-protagonist-style.png). The protagonist's
Meshy inputs are the working example:
[head-front](../sources/units/operator_protagonist/head-front.png),
[head-side](../sources/units/operator_protagonist/head-side.png),
[body-front](../sources/units/operator_protagonist/body-front.png). The writer's Request 29 heads
are the same style on a second character.

What makes it that style, as seen in those images:
- Simplified, sculpted forms: clean planes on the face, smooth skin with soft shading, no pores,
  fine wrinkles or blemishes.
- Slightly enlarged, clear eyes; a strong, readable brow and nose; slightly exaggerated proportions.
- Hair as sculpted clumps and locks with clear shapes, not thousands of photographic strands.
- Cloth as broad folds with painted wear, not fabric weave.
- Warm, even light; the look of a polished animated-film render, not a photograph or a scan.

## Fix 1: the developer's head, all four views (redraw)

Problem: the four views are near-photographic (pore-level skin, forehead wrinkles, strand hair,
photographic gaiter fabric). Next to the protagonist and the writer he reads as a different game.

Likely cause, from `prompts.json`: the head prompt asked for "realistic visible crown scalp", and
the side, back and three-quarter views were each generated from the realistic `head-front.png`,
so the look carried through all four.

Do:
- Redraw `head-front.png` first, with the protagonist's `head-front.png` and the writer's
  `head-front.png` as style references, and his
  [approved sheet](../sources/units/operator_developer/01-main.png) (the full figures and the
  portrait inset) as the identity reference. Do not use the current developer heads as an input.
- Same man, now in the house style: heavyset, middle-aged, warm light skin, black rectangular
  glasses as a distinct object, muted green gaiter over nose and mouth down to the neck cut, short
  curly greying brown hair. His thinning crown stays, drawn in the style: a stylized patch of
  scalp among sculpted curls, as on the sheet's back view, not photographic skin.
- Avoid the words "realistic", "photorealistic", "detailed skin" in the prompts. Use the house
  style terms above.
- Then the other three views from the new front, as in Request 29: true left profile,
  three-quarter front on his left side, straight-on back. Same framing rules (head and bare neck
  only, clean cut, same head size and camera height in all four).
- Check before delivery: put the new developer head-front beside the protagonist's and the
  writer's at the same size. They should look like three characters from the same film.

## Fix 2: both side body views (redraw)

Problem: both `body-side.png` views look flatter and cut out compared with their front and back,
with a faint edge around the figure. The developer leans slightly forward and looks less heavyset
than in his front view. Both figures are about 6% shorter than the front view.

Likely cause, from `prompts.json`: revision 2 asked the image tool to shrink and reposition the
figure. The tool re-rendered the whole image, which cost quality and still didn't hit the size.

Do:
- Regenerate each side view from that character's `body-front.png` and approved sheet, as in
  Request 29's revision 1: strict T-pose turned 90 degrees, true left profile, nose to image
  left, the near arm foreshortened toward the camera. Same rendering quality and lighting as the
  front and back.
- The developer stands upright, weight over his feet, with the same heavy belly and broad build
  as his front view, which reads in profile: belly in front, vest padding front and back.
- Don't correct size with an image-tool edit. If the figure comes out at the wrong size, correct
  it without regenerating: scale the image uniformly (e.g. with `sips`) and pad or crop the
  plain grey background back to 1024 × 1536. That's possible because the background is plain.
- Check before delivery: measure, in pixels, the top of the hair and the bottom of the boot soles
  in front, back and side. Height and baseline match the front within about 2% (about 25 px).
  Record the numbers in the README.

## Fix 3: check the writer's head scale (measure; redraw only if needed)

Claude thought the writer's `head-front.png` might be framed smaller than her other three head
views. On a second look it may be fine: a profile is naturally deeper than a front is wide.
Measure eye line, the top of the skull (under the hair) and the bottom of the bandana at the cut
in all four views. If they match within about 3%, keep them as they are and record the numbers.
If not, correct the odd one out by uniform scaling and padding, as in fix 2, not by redrawing.
Her style is accepted; do not restyle her.

## Small detail check

The developer's pack: the sheet and Request 29's brief mention old stickers on the rig, and none
are visible. Don't redraw the packs for this. Note it in the README for Bryson, who decides.

## Where they go

Candidates in `art/concepts/operator-writer-developer-meshy-fixes-<date>/`, one folder per
character, holding only the redrawn or corrected views, under the same file names as Request 29.
The README links Request 29's accepted views, so the full set of twenty for each character can be
seen from one page. Include the measurements from fixes 2 and 3, `prompts.json` and
`manifest.json` as in Request 29, and the side-by-side style check from fix 1.

After Bryson picks, whoever is with him copies the full set of twenty for each character (accepted
Request 29 views and chosen fixes) unchanged to `art/sources/units/operator_writer/` and
`operator_developer/`, removes the old `02-pack-back.png` and `03-pack-three-quarter.png` crops,
and marks Requests 29 and 30 delivered. No Meshy run until then.
