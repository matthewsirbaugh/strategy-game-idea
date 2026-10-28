# Architecture: how the buildings, walls and bridges get made

- Feeds: DESIGN.md's look, [environment-assets.md](environment-assets.md) (the prop pipeline and
  the props already made), environment-fidelity.md (archived 2026-10-28; its Godot notes kept under Constraints) (modular kit,
  materials and lighting techniques)
- Status: open. Tier 2 verticality and free tools chosen; the slice plan approved (Bryson, 2026-10-18)
- Next action: Claude starts the look pass, step 2, against the picked target frame and element
  sheets in `art/sources/architecture/slice/`

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
  - Approved the slice plan and its kit dimensions; Claude starts the greybox, and Bryson relays
    Request 31 to Astra.
  - Approved the greybox's proportions. The look pass starts once Astra's target frame is picked.
- 2026-10-28: picked Request 31 on Claude's and Astra's recommendation: target frame C v3 (fewer
  lights, darker night, less greenery), wall bays B, roof edge A (the approved 1.1 m combined guard,
  not the brief's taller solid wall), outside stair B, skybridge A. Copied unchanged to
  `art/sources/architecture/slice/`; the [gallery](../art/concepts/architecture-slice-look-2026-10-18/README.md)
  keeps the rest.

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
- Godot notes kept from the archived environment-fidelity research (2026-09-28): Decal nodes
  can't run custom shaders, so fog darkening may not reach under a decal (untested); keep
  screen-space reflections to floors, since they're expensive; GridMap with autotiling is
  Godot's native grid-kit tool if level authoring needs one.

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

### 2026-10-18 — The slice greyboxed (Claude; Blender and Godot, no credits)

Built and captured; not played. `tools/build_architecture_kit.py` scripts 13 pieces in Blender
and exports each to `game/assets/architecture/<id>/` with a record (status `proof`): four wall bays
(panel, glass, door, ribbon window), a header over openings, a corner post, a floor slab, the
parapet, a stair flight, landing, rail and post, and a skybridge span. Every bay is its own piece,
so it can ghost alone. `game/preview/architecture_slice.tscn` assembles the slice from them on the
1.5 m grid, with the battle's environment, sun and camera (50 degrees down, turned 45, distance 32,
field of view 30), the existing roof and ground props, and the three Operators on the roof.

- Captures: [battle camera](../art/previews/architecture-slice-greybox-2026-10-18/battle-camera.png)
  and [wider](../art/previews/architecture-slice-greybox-2026-10-18/wide.png), beside
  [the 17 October battle](../art/previews/operator-writer-developer-in-battle-2026-10-17/game.png).
- Reads from the battle camera: two storeys, the roof terrace and its parapet, the switchback stair,
  the skybridge stub and the people's scale all read at the default zoom.
- Still greybox: flat colours, no trim sheet or decals, plain glass, interiors only a lit floor and
  three benches, the uplights barely wash the walls. That is step 2's work.
- The project checks pass.

### 2026-10-18 — Groundwork for the look (Claude; Godot, no credits)

Built and captured; not played. Bryson asked for the parts that don't depend on the target frame.

- **Window interiors:** `art/shaders/window_interior.gdshader` traces the view into a room behind
  each glass bay (interior mapping): a tiled floor under three ceiling light strips, two rows of
  lab benches with shadows, a back wall. Rooms have no side walls, so neighbouring bays read as one
  open lab, and their brightness drifts across the facade. Glass elsewhere (railings, skybridge)
  uses `clear_glass.gdshader`.
- **Fog and see-through:** `art/architecture_kit.gd` (`ArchitectureKit.dress`) turns the kit's
  imported materials into `architecture.gdshader`, which keeps colour, metal and roughness and takes
  the battle's fog and ghosting. The props' fog shader drops metal and transparency, so the kit
  doesn't use it. In the slice, pieces between the camera and an Operator ghost, H ghosts all and
  F shows a stand-in fog around the Operators; one Operator now stands on the ground behind the
  building to show it.
- **Paving:** the slice's ground is the battle's own `corporate` paving, wet: joints on the grid,
  puddles and rain ripples.
- Captures: [battle camera](../art/previews/architecture-slice-look-groundwork-2026-10-18/battle-camera.png),
  [close](../art/previews/architecture-slice-look-groundwork-2026-10-18/close.png),
  [fog](../art/previews/architecture-slice-look-groundwork-2026-10-18/fog.png),
  [all ghosted](../art/previews/architecture-slice-look-groundwork-2026-10-18/ghost-all.png).
- **Found for the rules review:** the fog is one value per tile, ignoring height, so an Operator on
  the roof reveals the ground below and the roof shares its fog with the street. Ghosting already
  takes the whole stack, roof slab included, when a unit stands behind a building.
- **Found in passing:** the bench prop shows flat white wherever the props' fog shader dresses it,
  because that shader replaces an emission texture with one flat glow colour. Any prop prepared
  with `--glow` would do the same. The bench is out of the slice until that's fixed; it isn't in
  the battle today.
- The project checks pass.

### 2026-10-28 — Look pass, first round (Claude; Blender and Godot, no credits)

Built and captured; not played. Matched to the Request 31 picks in `art/sources/architecture/slice/`.

- **Kit** (`tools/build_architecture_kit.py`, now 15 pieces): seams wide enough to read at the
  battle camera; sturdier black mullions and rails; lighter steel treads on the stair and landings;
  the skybridge with two light strips, a mid rail, heavier posts and dark-steel X bracing. New
  pieces: `accent_band`, OpenBrain's red line under the first floor's band, and `beacon`, a red
  aviation light on the roof's two back corners.
- **Surfaces:** the kit's stone takes 0.75 m paver joints and a shade per paver
  (`architecture.gdshader`'s `paving`), so the roof reads as the terrace sheet's tiles.
- **Lab windows** (`window_interior.gdshader`): the first bench row sits right behind the glass,
  so the battle camera's steep view finds it; monitors glow blue at the benches' backs; the light
  is brighter and less orange.
- **Slice:** two wall washes at the facade's ends instead of four; the green roof is a low, sparse
  bed along the south parapet; one planter. `--pitch <deg>` joins the capture options.
- Captures: [before](../art/previews/architecture-slice-look-pass-2026-10-28/before.png),
  [after, battle camera](../art/previews/architecture-slice-look-pass-2026-10-28/battle-camera.png),
  [facade, closer and lower](../art/previews/architecture-slice-look-pass-2026-10-28/facade.png).
- **Still short of the target:** the white walls read lavender because the battle's ambient light
  is blue (0.5, 0.53, 0.72); the target's walls are neutral. Fixing it means changing the battle's
  environment, which reaches every map, so it waits for Bryson. Not done yet: CC0 scanned
  materials, the trim sheet, decals and the OpenBrain emblem; the wet paving's reflections of the
  lit windows are weak.
- The project checks pass.

## The slice plan (approved by Bryson, 2026-10-18)

One corner of the research park, finished to final quality, shown in the battle
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

### Kit dimensions

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

1. Height rules and traversal mechanics: for the rules review (Bryson, 2026-10-18).
