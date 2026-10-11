# Architecture: how the buildings, walls and bridges get made

- Feeds: DESIGN.md's look, [environment-assets.md](environment-assets.md) (the pipeline and what
  the park needs), [environment-fidelity.md](environment-fidelity.md) (modular kit, materials and
  lighting research from the retired look; the techniques still hold)
- Status: parked
- Next action: parked until every current prop has its image and its model (Bryson,
  2026-10-11). Then research the options below, with examples, and bring Bryson a comparison.
  Start it with `/exploration architecture` in a fresh chat.

## The question

What are our options for making the research park's architecture: buildings, walls, roofs,
skybridges, footbridges, booths and perimeter walls? Which one puts our best foot forward, before
we commit to building anything?

## What Bryson has said (2026-10-11)

- Two big things are left, the character models and the architecture. Each gets an exploration
  before we commit, so he understands the options and we put our best foot forward. Not
  yet: first every current prop gets its image and its model.
- Props are going well through Astra and Meshy; batches 1 to 5 cover them.

## Constraints this inherits

- The look: realistic, a California city in the late 2030s to early 2040s; OpenBrain's campus
  pristine, white with black and red accents; everything dim, at night (DESIGN.md).
- The references in [art/reference/](../art/reference/README.md): white panel walls, black-framed
  glass curtain walls, parapets with rooftop units and solar panels, green roofs, enclosed
  skybridges, grated footbridges with cable railings over the river, light stone paving.
- The game: a 1.5 m grid seen from above, about 50 degrees down. Walls must ghost when they hide
  units ([wall-occlusion.md](wall-occlusion.md)), and surfaces carry the fog of war in their
  shaders, so whatever we build has to work with both.
- The map will be redesigned from scratch, and Bryson may want to lay out levels himself (the map
  editor, parked). Pieces that snap to the grid serve both.
- Godot 4.7, Forward+, an M1 Pro with 16 GB. No budget beyond the subscriptions; Meshy credits are
  for props first.

## Options to research (Claude's starting list, not yet researched)

| Option | In short |
|---|---|
| A modular kit built by script in Blender | Wall, corner, window bay, door frame, roof edge and bridge span, sized to the grid, with CC0 scanned materials and a trim sheet. The pipeline's current plan |
| Whole buildings, hand-assembled | Each building modelled as one piece in Blender from kit parts, then placed whole |
| A kit built inside Godot | CSG or GridMap pieces assembled in the editor or by code; fast to iterate, simpler shapes |
| AI 3D for building facades or chunks | Meshy or another generator for whole small buildings, or detail pieces such as parapets and rooftop clutter; poor at tiling |
| Bought or free kits | Existing modular sci-fi or modern architecture kits (CC0 or paid), restyled to the references |
| Procedural buildings | Buildings generated from footprints by rules, in Blender (geometry nodes) or Godot |
| A mix | For example: kit walls, AI rooftop clutter, procedural window patterns |

For each: how it looks from the battle camera, how it works with ghosting and fog, how fast new
levels can be made, cost, and what Astra could contribute, such as reference sheets of the kit's
look.

## Findings

None yet.

## Open questions

1. Should Astra make reference sheets of the kit's look (a wall bay, a glass bay, a parapet, a
   skybridge, a footbridge) before anything is built?
