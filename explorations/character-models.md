# Character models: how the people and robots get made

- Feeds: DESIGN.md's look, [art-pipeline.md](art-pipeline.md) (tool research, and the 2026-09-27
  Meshy characters from the retired look: generated, rigged and animated), the story in
  [core-idea-and-story.md](core-idea-and-story.md)
- Status: open for the look (2026-10-13); the modeling comparison is still parked.
- Next action: none on animation; Bryson stopped it on 2026-10-15 (below). Finger bones are built
  ([operator-finger-rig.md](operator-finger-rig.md)).
  The comparison of how to model and animate them (the options below) still waits on Bryson.

## The question

What are our options for making the game's characters: the Operators, OpenBrain's guards, and the
robot dogs and drones? Which one puts our best foot forward, before we commit to making any?

## What Bryson has said

- 2026-10-10: characters come after V1, when the story is fleshed out. Their appearance should
  reflect their personality, which isn't decided yet.
- 2026-10-11: two big things are left, the character models and the architecture. Each gets an
  exploration before we commit, so he understands the options and we put our best foot forward. Not
  yet: first every current prop gets its image and its model.
- 2026-10-11: Operators cover their faces, each in their own way. V1's models are masked only (mask,
  helmet or visor); unmasked versions are planned for V2
  ([lore](core-idea-and-story.md#follow-ups-2026-10-11)).
- 2026-10-13, on the first concept sheets ([Request 19](../art/concepts/operator-looks-2026-10-12/README.md)):
  he doesn't like the outfits, they're bad, and he'd rather the Operators just look cool. Maybe the
  humans aren't anime characters, but they aren't realistic either: he's not a fan. Not decided yet.
- 2026-10-13, decided: the characters are stylized, the world stays realistic: "we'll miss the
  target, but we'll get close enough to be visually impressive." The styles to test are painterly
  (Dishonored, Deathloop) and clean hero (Overwatch, Valorant), in
  [the style test](../art/briefs/operator-style-test.md), Request 20. DESIGN.md's "characters
  included" wording changes once Bryson approves it.
- 2026-10-13: Astra's protagonist sheet is "essentially perfect"; it's adopted as
  [the style reference](../art/reference/operator-protagonist-style.png). The writer and the
  developer follow it, one sheet each ([Request 21](../art/briefs/operator-sheets.md)).
- 2026-10-13, on Request 21's sheets: all three wear basically the same outfit; each needs more
  personality. The writer should be more feminine, with longer hair and a face like a reference he
  attaches. The packs are computers worn on the back, made to look like a cool backpack, with a
  360° camera on a stalk for the AI's vision, and each reflects its owner's backstory: DIY, cheap
  and old, newer and sleeker. Briefed as [Request 22](../art/briefs/operator-revision.md).
- 2026-10-13, on the Meshy plan: the protagonist is the pilot, from high-resolution inputs
  ([Request 25](../art/briefs/operator-meshy-inputs.md)), with 4K textures. The writer keeps her
  knee-length coat; we see what the rig does with it.
- 2026-10-15: no more work on animations for now. They move past V2; he'll return to them as a
  finishing step.

Claude's reading: this exploration covers *how* characters get made. *What* each one looks like
still waits on the story.

## Constraints this inherits

- The look: realistic, around 2040, visually close to today; guards are ordinary people with work
  equipment, AR glasses and compute pucks
  ([threshold reference](../art/reference/openbrain-front-security-threshold.png)); robot dogs
  patrol with them ([river crossing](../art/reference/openbrain-research-park-river-crossing.png)).
- The game: seen from above at about 50 degrees, a person about 55 pixels tall at the default
  zoom. Silhouette, team colour and pose matter more than faces at that size; close-ups, if any,
  matter for faces.
- They must animate: idle, walk, run, crouch behind cover, shoot, hack, take a hit, fall. Several
  share clips. The four legacy characters are rigged and still in the game as placeholders.
- Godot 4.7 on an M1 Pro with 16 GB; no budget beyond the subscriptions; Meshy credits shared
  with props.

## Options to research (Claude's starting list, not yet researched)

| Option | In short |
|---|---|
| Meshy, image to 3D, rigged and animated in Meshy | Astra's character sheets in, auto-rig and stock clips out. Tried in September for the retired look |
| Meshy or another generator, then a proper rig | Generated mesh, rigged with Mixamo or Blender's Rigify, clips from Mixamo or motion capture libraries |
| A shared base body, dressed per character | One rigged, animated human; heads, clothes and gear swapped on it. Consistent proportions, one set of animations |
| MetaHuman-style or parametric humans | MakeHuman / MPFB in Blender, or similar: realistic bodies and faces from sliders, already rigged |
| Bought or free character packs | Modern or near-future soldier and civilian packs, restyled |
| Different routes for people and robots | Robots are hard surface, like the props, so Meshy suits them; people may need another route |

For each: how it reads from the battle camera, how faces hold up if we ever zoom in, animation
quality and how clips get shared, cost, and what Astra could contribute.

## Findings

### 2026-10-13 — Meshy best practices for the Operators (Claude; research, nothing generated)

What Meshy's own docs say (verified), and what it means for our three sheets:

| Practice | Source | Our sheets |
|---|---|---|
| One view per image, 1–4 images, the front first; the rest in any order | API docs | Each sheet holds four views in one image, so the front and back get cropped apart |
| Same character size, camera height and lighting in every view; a true side or back, not a near-duplicate | Multi-view tutorial | Front and back match. The elevated rear view has a different camera height, and the portrait is unmasked: both stay out |
| Plain background, even light, the subject filling the frame | Multi-view tutorial | Plain blue-grey, even light: fine. Crop tight |
| At least about 1040 px; low resolution smooths detail | Multi-view tutorial | Each figure crop is about 450 × 1000; packs are 512 × 512. Below the guide |
| A or T-pose in the input gives the best proportions; `pose_mode` sets the output pose, and rigging needs a model close to one | Tutorial, rigging docs | Arms hang relaxed; ask for `t-pose` or `a-pose` in the output |
| Rigging: humanoid, textured, 300k faces or fewer, standard proportions; remesh first | Rigging docs | Fine, after a remesh |
| Accessories hidden in every view float or detach; show each part clearly once | Multi-view tutorial | The camera pole shows in front and back |

- Models: the API now lists `meshy-7.1` (the default "latest") and calls `meshy-7` deprecated.
  Our MCP server (v0.5.x) only offers `meshy-7` and "latest", and its notes still say "latest"
  plus `remove_lighting` stays on Meshy 6. The two disagree; the first task's record will show
  which model ran.
- Not in any Meshy doc, but general rigging experience: long coats and skirts stretch and tear
  between the legs under auto-rig weights. The writer's coat reaches her knees, which breaks the
  old "nothing below mid-thigh" sheet rule. Her coat is the riskiest piece of the three.
- Our own lesson from September still applies: Meshy flattened every backpack modeled on a body,
  and the packs came out right as separate objects on the `Spine` bone.

Sources: [Meshy multi-image API](https://docs.meshy.ai/en/api/multi-image-to-3d),
[Meshy rigging API](https://docs.meshy.ai/en/api/rigging),
[Meshy rigging guide](https://docs.meshy.ai/en/webapp/guides/3d-model/rigging),
[Meshy multi-view tutorial](https://www.meshy.ai/tutorials/multi-view-image-to-3d),
[Meshy image to 3D help](https://intercom.help/meshy/en/articles/9996860-how-to-use-meshy-image-to-3d),
[Meshy 7.1 notes (third party)](https://blog.neural4d.com/comparisons/meshy-7-release-date-and-alternative/).

### 2026-10-13 — The pilot's body (Claude; step A of the plan, Bryson reviewing before rigging)

Meshy multi-image from `body-front.png` and `body-back.png`, model "latest", T-pose, textured at
4K, 30 credits, task `01a13856-bb22-7179-9ebb-7fda1f0ed31c`. Raw download:
`art/sources/units/operator_protagonist/meshy-body.glb`; captures in
[art/previews/operator-protagonist-meshy-body-2026-10-13/](../art/previews/operator-protagonist-meshy-body-2026-10-13/).
One mesh, 899,544 faces, 1.90 m tall as delivered, one 4096² base-colour texture. Not yet
remeshed, scaled, rigged or placed in the game.

### 2026-10-14 — The pilot's head and pack (Claude; Bryson reviewing before the graft)

The body's hair and strap edges came out skin-coloured: Meshy saw only a front and a back, and
guessed skin for everything facing sideways. So the head was modeled on its own from four views
and the pack got a side view ([Request 27](../art/briefs/operator-protagonist-head.md)). Both
Meshy multi-image, model "latest", textured at 4K, 30 credits each.

| Part | Task | Faces | Result |
|---|---|---|---|
| Head, from front, three-quarter, side and back | `01a1388d-29e9-763c-9f25-71f2aa3bc0bd` | 4.0 million | Dark hair through every curl, dark straps on every edge, real glasses |
| Pack, from back, three-quarter and side | `01a1388d-3b7c-727f-b242-0e5d0052f68f` | 3.1 million | Solid case, pole and cables in the round; the body-side padding is Meshy's invention |

Captures: [art/previews/operator-protagonist-meshy-head-pack-2026-10-14/](../art/previews/operator-protagonist-meshy-head-pack-2026-10-14/).
Lesson for the writer and the developer: give Meshy a side view of everything, and a head of its
own. The raw models are over GitHub's 100 MB limit and are not in git.

### 2026-10-14 — Graft and remesh (Claude; in Blender, no credits)

The head was scaled to the body by the respirator's filter width (0.196) and set at the old
mask's height. The body's old head was cut away above the collar, and the old mask's leftovers
were removed by colour and position, keeping only the jacket. Meshy's remesh needs a public URL,
so the remesh was done in Blender: each part rebuilt lighter, given a fresh texture layout, and
its colour baked from the detailed original. Shrinking Meshy's own texture layout breaks it into
speckles, so the bake is the step that matters.

| Model | File | Faces | Texture |
|---|---|---|---|
| Body and head, one mesh, 1.75 m, feet at the origin | `art/sources/units/operator_protagonist/prepared.glb` | 56,344 | 4096² |
| Pack, seated on his back as the sheet shows | `art/sources/units/operator_protagonist/prepared-pack.glb` | 12,140 | 2048² |

Captures: [art/previews/operator-protagonist-graft-2026-10-14/](../art/previews/operator-protagonist-graft-2026-10-14/).
Known: the lower respirator strap dips into the collar on his right side; the filter grilles
softened; the pack's waist strap floats beside his jacket until it is fitted after rigging.
Not yet rigged, and not in the game.

### 2026-10-14 — Rigged (Claude; Meshy auto-rig, 5 credits)

Sent to Meshy's rigging API directly with the model inline, since the MCP tool only takes a URL
(Bryson approved reading the key from the Keychain). Task `01a13d40-ea1c-778e-b14f-51718895ccfe`;
its downloads expire about three days after the run. Standard Meshy skeleton, walk and run included.
In `game/assets/units/operator_protagonist/` as a proof. The pack is skinned to `Spine` inside the
same mesh: parented to the bone, Blender's exporter put it 4.8 m off, because Meshy's armature is
stored at 0.01 scale. Checked: two walk frames rendered in Blender, pack following.

Next, Bryson (2026-10-14): try Meshy text-to-animation on him.

### 2026-10-14 — Cleanup (Claude; Blender, no credits)

Bryson saw a hole in the jacket back, scalp through the hair and scraps at the collar in the lit
full-detail renders. Causes: the head cut left the collar saw-toothed; Meshy's front-and-back body
had small holes and orange smears; Meshy's head had skin patches between curls. Each now a step
in [tools/prep_operator.py](../tools/prep_operator.py): weld, fill small holes (not the lapel
edges), straighten the collar hem, drop old collar hugging or loose by the neck, repaint small
orange specks as jacket (piping, which borders the lining, stays) and small skin patches above
the hairline as hair. The head is rebuilt at 1.5 mm voxels: at 3 mm the glasses survived only by
luck. `--rig` copies the existing Meshy rig's weights onto the re-baked mesh, so no re-rig.
[Captures](../art/previews/operator-protagonist-cleanup-2026-10-14/).

### 2026-10-14 — Hands (Bryson's call: finger bones)

Running, his fingers stay splayed: Meshy's rig gives each hand one bone and no finger bones, and
its API has no option for more. Bryson chose to add finger bones in Blender with a relaxed curl as
the rest pose, over new Meshy hands (still rigid, and the join would sit on bare forearm skin) or a
different rigger. The plan, with guidance for whoever builds it:
[operator-finger-rig.md](operator-finger-rig.md).

### 2026-10-15 — Fingers built (Claude; Blender, no credits)

Each hand now has five digits on Mixamo-named bones, with a relaxed curl as the rest pose. Walking,
running and standing, his hands hang relaxed; nothing else about him changed. `tools/add_fingers.py`
made them and is ready for the writer and the developer. Measurements and limits:
[operator-finger-rig.md](operator-finger-rig.md#findings).

## Open questions

None yet.
