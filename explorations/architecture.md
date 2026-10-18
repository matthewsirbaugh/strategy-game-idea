# Architecture: how the buildings, walls and bridges get made

- Feeds: DESIGN.md's look, [environment-assets.md](environment-assets.md) (the prop pipeline and
  the props already made), [environment-fidelity.md](environment-fidelity.md) (modular kit,
  materials and lighting techniques)
- Status: open. Tier 2 verticality and free tools chosen (Bryson, 2026-10-18); the slice is planned
- Next action: Bryson approves [the slice plan](#the-slice-plan-claudes-proposal-2026-10-18) and
  relays Request 31 to Astra; Claude starts the greybox

## The question

What are our options for making the research park's architecture: buildings, walls, roofs,
stairs, skybridges, footbridges, booths and perimeter walls? Which one puts our best foot forward,
before we commit to building anything?

## What Bryson has said

- 2026-10-11: two big things are left, the character models and the architecture. Each gets an
  exploration before we commit, so he understands the options and we put our best foot forward.
- 2026-10-18: the characters look good; architecture is the last art component. He wants
  verticality and interesting buildings.
- 2026-10-18, on [the options presentation](https://claude.ai/artifact/SaCx7rjoFEfJxDxUgF99Bn):
  - Tier 2 verticality: walkable roofs, catwalks and bridges.
  - Whether height changes combat waits for a rules review. He wants the verticality, and hopes to
    add traversal mechanics.
  - Free tools only, or Meshy, since the credits are already bought.
  - Astra makes kit sheets if Claude thinks they improve the final result.
  - Yes to the one-bay prototype, and go all out on it: the small slice has to prove the aesthetic
    for the rest of the game.
  - Claude and Astra split the work so they run in parallel; Astra's images take a while.

## Terms

- **Verticality tier:** how much height the game uses. Tier 1, tall buildings but play on the
  ground; Tier 2, walkable roofs, catwalks and bridges joined by stairs and ladders; Tier 3, full
  floors inside buildings with a cutaway camera.
- **Modular kit:** building pieces sized to the grid that snap together. **Trim sheet:** one shared
  texture of detail strips (seams, frames, vents) that every kit piece uses.
- **The slice:** the prototype below, one small finished piece of campus that sets the look.
- **Target frame:** an image of the slice from the battle camera, the look the build must match.

## Constraints this inherits

- The look: realistic, a California city in the late 2030s to early 2040s; OpenBrain's campus
  pristine, white with black and red accents; everything dim, at night (DESIGN.md).
- The references in [art/reference/](../art/reference/README.md): white panel walls, black-framed
  glass curtain walls, parapets with rooftop units and solar panels, green roofs, roof terraces,
  steel stairs up the outside of buildings, enclosed skybridges with diagonal bracing, grated
  footbridges with cable railings over the river, light stone paving.
- The game: a 1.5 m grid seen from above, about 50 degrees down. Walls ghost when they hide units
  ([wall-occlusion.md](wall-occlusion.md)), and surfaces carry the fog of war in their shaders.
  Today every unit stands on one flat floor; walls are 2.8, 3 or 9 m tall boxes built in
  `level_view.gd`.
- Bryson may lay out levels himself later (the map maker, parked). Pieces that snap to the grid
  serve both.
- Godot 4.7, Forward+, an M1 Pro with 16 GB. Free tools and Meshy only; 1,610 credits on
  2026-10-18. Props already made that dress roofs and paving: `rooftop_unit`, `solar_rack`,
  `planter`, `uplight`, `bench`, `terrace_table`, `robot_dock`, `pole_light`.

## Findings

### 2026-10-18 — Options compared (Claude; research, nothing tested)

The full comparison, with sources, is [the options presentation](https://claude.ai/artifact/SaCx7rjoFEfJxDxUgF99Bn).
What carries forward:

- **Buildings differ from characters for AI.** A character is one organic object; generators
  handle it well. Architecture needs straight, repeated, grid-exact pieces and spaces to walk into,
  where generators are weak: walls bow, parts fuse into one shell, interiors are empty, and style
  drifts between outputs. AI's role moves from making the model to making concept images, detail
  parts, and the Blender scripts that build exact pieces.
- **Three layers are chosen separately:** pieces (the shapes), surfaces (materials, trims, decals,
  light) and assembly (how a level is laid out). The cube look found on 2026-09-28 came from the
  surface layer: flat colour textures, no bevels, no decals, flat light.
- **Routes for the pieces, within free tools and Meshy:**

| Route | Use |
|---|---|
| A kit Claude builds by script in Blender | Everything a unit walks on, through or behind; exact to the grid, ghosting and fog; supports Tier 2 |
| Free Blender add-ons (HiFi Architecture Builder) | Optional help for one-off shapes; not built for a game grid; untested |
| Meshy parts | Rooftop and terrace detail, the way the 31 props were made |
| Meshy whole buildings | Only where nobody walks: skyline and backdrop. Sealed shells that can't ghost wall by wall |
| AI world generators (gaussian splats) | Not usable for play; mood studies at most |

- **Surfaces:** Poly Haven and ambientCG scanned materials (CC0), our own trim sheet, Godot decals,
  and a lighting pass. Blender's procedural materials often don't survive import into Godot, so
  textures get baked.
- **Assembly:** today's code builds walls from level data. Godot's GridMap paints pieces in layers,
  one per height, which suits Tier 2 and could serve the map maker. Choosing it is part of the
  rules review's height work, not the slice.

## The slice plan (Claude's proposal, 2026-10-18)

Not agreed yet. One corner of the research park, finished to final quality, shown in the battle
camera beside [today's capture](../art/previews/operator-writer-developer-in-battle-2026-10-17/game.png).

### What's in it

- A two-storey lab building, about 12 x 9 m (8 x 6 tiles). Ground floor: black-framed glass curtain
  wall with a lit lab behind it. Upper floor: white composite panels with a glazed band.
- A walkable roof terrace: parapet with glass railing, `rooftop_unit`s, `solar_rack`s, a strip of
  green roof, planters.
- A steel stair up the outside, ground to roof, with landings, as in the terrace reference.
- A skybridge stub leaving the upper floor: glass, black frame, diagonal bracing, lit inside.
- Stone paving, uplights, a pole light, a bench, and the three Operators for scale.
- Night lighting matched to the references: interiors glowing through glass, uplit white walls,
  wet reflections.

### Kit dimensions (proposed)

| Measure | Value | Why |
|---|---|---|
| Panel and mullion module | 1.5 m | One tile; seams fall on tile edges |
| Storey, floor to floor | 4.5 m | Three tiles, so heights stay on a cube grid; close to real lab buildings |
| Parapet and railing | 1.1 m | Real guard height on a walkable roof |
| Stair width | 1.5 m | One tile |
| Skybridge | 3.0 m wide, one storey tall | Two tiles, room for two units to pass |

### How it's built

- **Pieces:** Claude scripts the kit in Blender: solid bay, glass bay, door bay, outer and inner
  corner, floor and roof slab, parapet, stair flight and landing, railing, skybridge span and end.
  Each wall bay is its own piece so it can ghost alone.
- **Surfaces:** CC0 scanned materials, a trim sheet for seams, frames and vents, decals for wear,
  signage and OpenBrain's emblem.
- **Glass:** a fake-interior shader, so windows show lit rooms with depth without modelled
  interiors. Interiors stay later (Bryson, 2026-10-11).
- **In Godot:** a standalone slice scene using the battle's camera and lighting. It doesn't touch
  the level format, so the height rules stay open for the rules review.

### Who does what, in parallel

| Step | Astra | Claude | Bryson |
|---|---|---|---|
| 1 | Request 31: the target frame and four element sheets | Greybox kit and slice in Blender, then in the battle camera | Approves the greybox's proportions and the target frame |
| 2 | Request 32, if the greybox shows gaps: Meshy inputs for new rooftop or terrace parts | Materials, trim sheet, glass shader, lighting, matched to the chosen frame | Approves the parts' costs before Meshy runs |
| 3 | — | Meshy parts modelled; dressing; final captures beside today's | Judges whether the slice sets the look |

Claude needs nothing from Astra to start step 1; the greybox fixes shape and scale while Astra
works on the look, and his images steer step 2.

## Open questions

1. Does Bryson approve the slice plan, including the kit dimensions?
2. Height rules and traversal mechanics: for the rules review (Bryson, 2026-10-18).
