# Environment assets: the pipeline, from scratch

- Feeds: DESIGN.md's look and world decisions, [art-direction.md](art-direction.md),
  [art-pipeline.md](art-pipeline.md) (tool facts)
- Status: open
- Next action: put the art in the game. (Meshy's raw downloads moved to
  `~/Desktop/AI Strategy Game Model Archive/` on 2026-10-11; Bryson chose that over Git LFS.)

## The question

Which environment assets does V1 need, and how do we make them so they look good and belong
together, in the realistic direction? Starting from scratch.

## What Bryson has said (2026-10-10)

- Abandon the previous art. Start from scratch, to make a better, more cohesive version.
- Start the art pipeline with the environment assets. They're what's most lacking now.
- V1 proves the game is fun and can look good, and most of that comes from the environments, the
  interface and the rules, not the character models.
- Bryson loves the rules and the demo; the shift is to the art direction only.
- Characters come after V1, when the story is fleshed out. Their appearance should reflect their
  personality, which isn't decided yet. Character models get their own exploration.

## Constraints this inherits

- DESIGN.md: realistic; a California city, not Silicon Valley, in the late 2030s to early 2040s, visually close to today;
  more of it is the poor part of town; sleeker electric cars; pristine OpenBrain territory, white
  with black and red accents, against a familiar, poorer city; everything dim.
- The adopted references: [art/reference/](../art/reference/README.md) (2026-10-10), the city,
  OpenBrain's front and its research park.
- V1's facility mission starts in the research park, at the back of the campus; the team works its
  way into the main building later (Bryson, 2026-10-10). The map itself will be redesigned from
  scratch (Bryson, 2026-10-10).
- The game: a 1.5 m grid seen from above, about 50 degrees down; at the default zoom a person is
  about 55 pixels tall. Night. Fog of war is drawn as light in the shaders.
- Godot 4.7, Forward+, on an M1 Pro with 16 GB. No budget beyond the subscriptions; Meshy has
  2,465 credits.

## What the research park needs

From the references. The rules name each device kind; its look follows the references. Guards and
robot dogs are units, not environment, and wait for their own work.

| Group | Pieces |
|---|---|
| Architecture | White panel walls, black-framed glass curtain walls, parapets with rooftop units and solar panels, green roofs, roof stairs, enclosed skybridges, perimeter walls |
| Ground and landscape | Light stone paving, paths, white concrete planters, lawn, shrubs and trees, river boulders, the rocky hillside |
| Water | The river, with rapids around boulders |
| Crossings | Grated footbridges with cable railings |
| Fixtures | Bollard lights, uplights, pole lights, cameras and scanners on poles, barrier arms, EV chargers |
| Devices (rules) | Access point, door, automatic door (glass sliding doors), camera, night-vision camera, turret, Prime Data Cache, light, phone, machine, ad screen, car, truck, power hub |
| Interiors, later | Labs with robot arms and benches, the main building |

## The pipeline (Claude's recommendation; Bryson asked to start, 2026-10-10)

Each kind of asset gets the method that suits it:

| Assets | How | Who |
|---|---|---|
| Architecture, paving, crossings | Simple pieces built in Blender by script, sized exactly to the 1.5 m grid, with CC0 photoscanned materials (ambientCG, Poly Haven), a shared trim sheet and decals. AI generators can't make pieces that tile | Claude |
| Props and devices | A concept sheet per prop, then Meshy image to 3D, then cleanup in Blender: scale, origin at the base, polygon budget, material check | Sheets: Bryson in Astra, or Claude through Meshy's image tool. The rest: Claude |
| Boulders, rocks, plants | CC0 scanned assets from Poly Haven first; Meshy where none fits | Claude |
| Water | A water shader in Godot | Claude |
| Light and atmosphere | Real light fixtures, warm uplighting on campus, wet ground | Claude |

Engine work the realistic look needs: the game's surfaces use custom shaders that carry the fog of
war, so realistic materials need a shader of their own that does too.

### Concept sheets for Meshy

Meshy builds what it sees, so the sheet decides the result:
- One object, centered and whole, on a plain mid-grey background.
- Even, soft studio light, with no cast shadows and no strong reflections.
- A three-quarter front view from slightly above; for a tricky object, separate front, side and
  back views of the same object (Meshy takes up to four).
- No text. OpenBrain's emblem only where the object would really carry it.
- The style block below opens every prompt, so all props share one design language.

Style block: "Photorealistic product render of a single object for a game set in a California
city around 2040, belonging to OpenBrain, a powerful AI company. Clean, modern, minimal design:
matte white composite panels, black anodized aluminum, brushed steel, chamfered edges, warm white
LED accents, one small red indicator light. Real-world scale and proportions, new and well kept.
Isolated on a plain mid-grey background, even soft studio lighting, no cast shadows, three-quarter
view from slightly above, whole object in frame, no text."

### The first proof run

Three props that each test something different, taken all the way into a Godot test scene under
night lighting, before anything else is made:

| Prop | Device | Tests |
|---|---|---|
| Bollard light | Light | A simple hard-surface object that appears everywhere; compares Meshy 7 (30 credits) with the cheaper smart-topology model (15) |
| Pole camera with a scanner | Camera | A thin, detailed object |
| Access terminal pillar | Access point | The most-used device, with screen and emblem detail |

About 105 credits with the comparison, out of 2,465. Each asset gets a record: its sheet, prompt,
Meshy task, credits and cleanup notes.

## Findings

None yet.

## Findings

### 2026-10-10 — How the work runs, and the proof run's tools (Bryson; Claude built the tools)

- Bryson: Astra makes all the reference images. Claude says what's being made; Bryson works with Astra
  to the right design and hands Claude the images; Claude takes them to Meshy. Meshy's image tool
  isn't used, to save its credits for models. Recorded in AGENTS.md.
- Bryson approved the proof run, to judge how close Meshy can get us. He might also try Unreal to
  see what it can do (on the board).
- Built: [the briefs](../art/briefs/proof-run.md) for the bollard light, the camera head and the
  access terminal; `tools/prep_prop.py`, which readies a Meshy model in Blender, tested on an old
  prop; `game/preview/prop_preview.tscn`, a night look-dev stage with the battle camera's view and
  a 1.8 m person for scale; and a log of Meshy runs, which became each asset's record the same day.

### 2026-10-10 — Folders for assets, and a contract for the model viewer (Bryson approved; Claude built)

Bryson plans for Astra to build a Godot model viewer, and approved restructuring the folders for it.
Every model now lives in `game/assets/`, one folder per asset with a record of what it is and how
it was made; the retired models moved to `game/assets/legacy/`, still loaded as placeholders, and
the game looks the same. Sources for Meshy go to `art/sources/`. The record format is a draft
contract, [game/assets/README.md](../game/assets/README.md), for Astra to review, alongside
[how Claude and Astra work together](claude-and-astra.md).

### 2026-10-11 — The bollard light, first through Meshy (Bryson approved; Claude ran it)

Bryson approved all three of Astra's main views, the 45-credit bollard comparison, and the
terminal's emblem as a decal from [the logo](../art/reference/openbrain-logo-white.png).
Both Meshy models of the bollard came out faithful to the image and almost identical in shape:

| Model | Credits | Triangles | Asset |
|---|---|---|---|
| Meshy 7, textured, PBR | 30 | 62,946 | `devices/bollard_light_meshy7` |
| Smart topology (meshy-t2), textured, PBR | 15 | 3,834 | `devices/bollard_light` |

Claude recommends smart topology for hard-surface props: half the credits and a sixteenth of the
triangles, with no visible loss at this size. Not yet seen in the night stage or played. The
light band isn't emissive yet; that's a cleanup step.

Bryson, the same day: smart topology is the default for props; the Meshy 7 bollard is rejected.
`tools/prep_prop.py --glow` now turns a model's lit parts into emission: texels brighter than a
threshold and saturated reds. The bollard's band and status dot glow; its body stays dark.

### 2026-10-11 — The camera head and the access terminal (Bryson chose option C; Claude ran it)

Smart topology takes only one image, so Bryson chose: the camera from both its views with Meshy 7
(30 credits), the terminal from its main view with smart topology (15). The proof run cost 90
credits in all.

- **Camera head:** faithful, bracket and lidar puck included, 0.6 m long. Meshy 7 gave 644,646
  triangles. Cutting to 8,000 in Blender shredded the surface; 30,000 holds up at game scale.
  Lesson: Meshy 7's dense meshes don't survive a hard cut, which is one more reason for smart topology.
- **Access terminal:** clean at 4,172 triangles; Astra's emblem came through in the texture. Meshy
  dropped the red edge strip, so Claude added it by hand as a glowing bar. The screen doesn't glow
  yet.
- `--glow` by brightness would light up white bodies too, so `--glow 2` now lights only reds. It
  finds nothing on these two: the camera's red light is too faint in Meshy's texture.

Seen in Blender renders only; not yet in the night stage or played.

### 2026-10-11 — Proof run approved; batch 2 briefed (Bryson)

Bryson saw the three props in the night stage: "they look good". The Meshy route works for this
game, and the three are approved. Batch 2 is the seven remaining standalone devices,
[briefed here](../art/briefs/batch-2-devices.md), about 115 credits; vehicles and doors come after.

### 2026-10-11 — Batch 2: five devices modelled, the turret sent back (Bryson)

Bryson approved five of Astra's six images; the turret read as a camera with a gun, so its
revision went to [batch 4](../art/briefs/batch-4.md). The five went through smart topology, 75
credits: the Prime Data Cache, the phone, the machine (a backup generator), the ad screen and the
power hub, all faithful to their images. The night-vision camera, a re-texture of the camera head,
cost 10 more. Seen in Blender renders only.

### 2026-10-11 — Batch 3: vehicles and fixtures modelled (Bryson approved; Claude ran it)

Bryson approved seven of the eight; the EV charger read as an access terminal, so its revision
went to [batch 6](../art/briefs/batch-6-revisions.md), held until batch 5 lands. The vehicles went
through Meshy 7 with both views (30 credits each) and were collapsed from about 900,000 triangles
to 40,000; the rest through smart topology (15 each): 135 credits. The planter was a test of
foliage: Meshy turned the grass into broad leaves, which read fine from above. Seen in Blender
renders only.

### 2026-10-11 — Batch 4 modelled; only real lights glow (Bryson)

Bryson approved all five: the revised turret, the equipment cases, the waste station, the rooftop
unit and the terrace table set, 75 credits through smart topology. The turret now reads as a
weapon, and the chairs' thin frames came through cleanly. Seen in Blender renders only.

Astra's images give most props warm LED strips. Claude's suggestion, which Bryson agreed: only real
light fixtures glow (the bollard, pole lights, uplights, screens), and decorative strips on
furniture and equipment stay dark, so light keeps meaning a light, which is a device in the rules.

### 2026-10-11 — Batch 5 modelled: the exterior props are done (Bryson approved)

The uplight, solar rack, turnstile and robot dog dock, 60 credits through smart topology. Two
needed Blender surgery: Meshy modelled the uplight's buried housing, so Claude sliced it off at the
rim; and Meshy can't make transparency, so the turnstile's glass wings were cut away and rebuilt as
real glass. With this batch every exterior prop the research park needs has a model, except the
EV charger, whose revision is with Astra (batch 6). Seen in Blender renders only.

### 2026-10-11 — Batch 6 and the finishing pass (Bryson asked; Claude built)

- The EV charger: Bryson's approved v4, adapted from his own photo, its open frame keeping it apart
  from the access terminal. 15 credits.
- `tools/build_fixtures.py` builds what AI 3D can't: black poles under the pole light, the camera,
  the night-vision camera and the scanner, the barrier's 4 m arm, and the OpenBrain emblem as
  decals on the car's doors and the van's flanks.
- Glow, by Bryson's rule that only real lights glow: `prep_prop.py --glow-box` limits the
  brightness test to one region, so the terminal's screen glows while its white body doesn't.
- Not done: the camera's red recording light, too faint in Meshy's texture to find. Everything
  is seen in Blender renders only, not yet in the night stage.

### 2026-10-11 — Max quality: no reductions, Ultra regenerations (Bryson)

Bryson found the car rough in the night stage. Claude traced it to its own triangle cut, 900,000
to 40,000, which tore the texture seams; Meshy's full model was clean. Bryson: "Just use the max
render. We're not hurting for resources, and the smoothness will hurt us with reflections." So the
car, the van and both camera heads are back at full resolution, and the turret and the EV charger
were regenerated with Meshy 7 Ultra and 8K textures (40 credits each). The Ultra charger fixed a
fan of spiked triangles smart topology had put across its open frame; the Ultra turret lost its
red visor, which Claude rebuilt as a glowing bar. The models now total about 1 GB on disk.

### 2026-10-11 — Max quality only where it's needed; the plan from here (Bryson)

- Ultra is for props that need it, the less angular ones: the car, van, turret and charger. The
  other props are fine as they are, and smart topology stays the default.
- Bryson saw everything in the night stage: "everything looks good." Only the EV charger loaded
  slowly.
- Next, in order: decide how the repository stores large models; lower the heavy models'
  triangle counts while keeping them looking good; put the art in the game; then the story and
  personalities, so the character models are made informed.

### 2026-10-11 — Lighter heavy models (Bryson approved; Claude ran it)

Tested on the EV charger: a Blender bake to 30,000 triangles came out greyer and smudged; Meshy's
remesh to 27,000 looked nearly identical to the 343,000-triangle original; 2K textures looked the
same as 8K and quartered the file. So the six heavy models (car, van, turret, both camera heads,
charger) were remeshed (5 credits each, 30 in all) and shrunk to 2K textures: 11 to 16 MB each,
down from 30 to 60 MB. The turret's visor, the emblems and the camera poles were rebuilt on the
new meshes. Seen in Blender renders only.

## Open questions

None for now.
