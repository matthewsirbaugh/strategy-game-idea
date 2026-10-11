# Environment assets: the pipeline, from scratch

- Feeds: DESIGN.md's look and world decisions, [art-direction.md](art-direction.md),
  [art-pipeline.md](art-pipeline.md) (tool facts)
- Status: open
- Next action: Bryson approves the first proof run below (three props, about 105 Meshy
  credits), and says who makes the prop sheets.

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
| Props and devices | A concept sheet per prop, then Meshy image to 3D, then cleanup in Blender: scale, origin at the base, polygon budget, material check | Sheets: Bryson in GPT-6 Sol, or Claude through Meshy's image tool. The rest: Claude |
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

## Open questions

1. Does Bryson make the prop sheets in GPT-6 Sol, or Claude through Meshy's image tool (3 to 9
   credits a sheet)?
2. Approve the first proof run: three props, about 105 credits?
