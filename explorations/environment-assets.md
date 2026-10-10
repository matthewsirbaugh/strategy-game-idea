# Environment assets: the pipeline, from scratch

- Feeds: DESIGN.md's look and world decisions, [art-direction.md](art-direction.md),
  [art-pipeline.md](art-pipeline.md) (tool facts)
- Status: open
- Next action: Bryson answers the open questions; then a test slice of the map is built in the
  new pipeline and compared in the game.

## The question

Which environment assets does V1 need, and how do we make them so they look good and belong
together, in the realistic direction? Starting from scratch.

## What Bryson has said (2026-10-10)

- Abandon the previous art. Start from scratch, to make a better, more cohesive version.
- Start the art pipeline with the environment assets. They're what's most lacking now.
- V1 proves the game is fun and can look good, and most of that comes from the environments, the
  interface and the rules, not the character models.
- Characters come after V1, when the story is fleshed out. Their appearance should reflect their
  personality, which isn't decided yet. Character models get their own exploration.

## Constraints this inherits

- DESIGN.md: realistic; Silicon Valley in the late 2030s to early 2040s, visually close to today;
  more of it is the poor part of town; sleeker electric cars; pristine OpenBrain territory, white
  with black and red accents, against a familiar, poorer city; everything dim.
- The latest concept Bryson preferred is the creekside campus
  ([04-creekside-campus-v2](../art/concepts/valley-composition-study-2026-10-08/04-creekside-campus-v2.png)).
  No environment reference is adopted into `art/reference/` yet.
- The game: a 1.5 m grid seen from above, about 50 degrees down; at the default zoom a person is
  about 55 pixels tall. Night. Fog of war is drawn as light in the shaders.
- Godot 4.7, Forward+, on an M1 Pro with 16 GB. No budget beyond the subscriptions; Meshy has
  2,465 credits.

## What V1's map needs

From `facility_yard.tres` and RULES.md's device list. The rules name each kind; what it looks like
in 2040 is open.

| Group | Pieces |
|---|---|
| Ground | Street asphalt, sidewalk, yard paving, the campus's clean paving, curbs, lane and crosswalk paint |
| Structure | Perimeter wall, building walls (the backdrop B tiles), the annex compound, a gatehouse booth, the street-facing facades |
| Low cover | Crates, dumpsters, the barricade, the annex's server racks |
| Devices | Access point, door, automatic door, camera, night-vision camera, turret, Prime Data Cache, light (floodlight and street lamp), phone, machine (generator), ad screen, car, truck, power hub |
| Dressing | Signs and logos, road markings, trash and grime, the city beyond the map |

## Candidate pipelines (Claude's, not yet agreed)

Realism in an environment comes mostly from materials, lighting and dressing, not from the
models. Each group of assets suits a different method:

| Group | Method | Why |
|---|---|---|
| Ground and structure | Simple pieces built in Blender by script, sized exactly to the grid, with photoscanned materials from CC0 libraries (ambientCG, Poly Haven), one shared trim sheet for edges and caps, and decals for grime, cracks and stains | These must tile on the grid, which AI generators can't do. Photoscans are what make concrete and asphalt read as real, and CC0 means free with no strings |
| Props and devices | Concept images in one shared style, then Meshy image to 3D, cleaned up and sized in Blender. CC0 photoscanned props where one fits (Poly Haven has some) | Each prop is unique; this is where AI 3D is strong. Meshy makes full PBR textures |
| Landscape | CC0 plants and rocks from Poly Haven, or Meshy | Only if the map grows a creek and brush like the creekside concept |
| City beyond the map | Low-detail blocks with realistic facades and lit windows | Seen from far off and dim |
| Light and atmosphere | Real light fixtures, wet ground, haze, Godot's global illumination tested for cost | The mood lives here |

How to keep it cohesive (Claude's recommendation):
1. Adopt one or two concept images as the look target, in `art/reference/`.
2. Build a small material library first (asphalt, sidewalk concrete, stucco, OpenBrain's white
   panel, glass, painted metal, chain-link) and make every asset draw from it.
3. Write one fixed style block for every prop concept prompt, keyed to the look target.
4. Prove it on a test slice before building the rest: a few tiles of street, wall and gate, with
   one of each kind of fixture, compared in the game against what's there now.

Sources: [Poly Haven license](https://polyhaven.com/license),
[free texture sources, license-checked](https://gamineai.com/blog/25-free-environment-texture-and-trim-sheet-sources-for-indie-teams-2026-license-checked-edition),
[trim sheets](https://3dtexel.com/trim-sheets-texture-atlases-the-game-environment-workflow/),
[modular environments](http://wiki.polycount.com/wiki/Modular_environments),
[Meshy PBR texturing](https://www.meshy.ai/tutorials/pbr-texturing-with-meshy),
[Meshy's game asset pipeline](https://github.com/meshy-dev/game-asset-pipeline),
[AI texture tools compared](https://www.3daistudio.com/blog/best-ai-texture-and-pbr-generators-2026),
[Megascans no longer free](https://80.lv/articles/megascans-no-longer-free-after-2024/),
[SDFGI in Godot](https://docs.godotengine.org/en/4.4/tutorials/3d/global_illumination/using_sdfgi.html).

## Findings

None yet.

## Open questions

1. Which concept image or images become the environment's look target?
2. Does the map keep the facility yard's layout and get new art, or follow a concept's layout,
   such as the creekside campus with its creek, brush and footbridge? A new layout changes the
   asset list, and water and brush would be new rules.
3. What does each device look like around 2040? For example the power hub as a substation
   transformer, the truck as an electric delivery truck (RULES.md calls it diesel), the phone as a
   payphone or a public kiosk.
4. Free CC0 sources and Meshy credits only, or is a paid asset allowed when it clearly helps?
5. Which part of the map becomes the test slice?
