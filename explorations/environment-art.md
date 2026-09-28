# Environment art for the battle MVP

- Feeds: [art-pipeline.md](art-pipeline.md), DESIGN.md's look decision
- Status: open
- Next action: Bryson decides on Claude's trimmed 12-image set (latest finding) and runs it
  in Astra; Claude then builds the props with Meshy and dresses the MVP map.

## The question

Which environment objects the MVP battle needs, and how to make them so they belong together and
match the three Operators. Bryson asked for a full list to solve one at a time (2026-09-27).

## Constraints this inherits

- The look: gritty cyberpunk anime, Edgerunners-style, worn surfaces (DESIGN.md). Image prompts
  start from the [house style](art-pipeline.md#house-style).
- The Operators are Meshy models drawn with `game/art/shaders/toon.gdshader` and a
  silhouette-only ink outline. Their painted-in detail lines stay (Bryson, 2026-09-27).
- The world: a gritty, technofeudal corporate AI future full of advertisements, all the way
  through (DESIGN.md).
- The map is a 12×12 grid of 1 m tiles, seen mostly from the battle camera: 50° down, about 34 m
  away, where a person is about 55 px tall. Objects have to read at that size first.

## Method (Claude's recommendation, 2026-09-27)

What makes a set feel like one world, in order of impact:

1. **One style anchor.** Before any single object, one painted concept of the MVP map's key
   space (the atrium) from the battle camera's angle, made with the same image generator and
   [house style](art-pipeline.md#house-style) as the Operator sheets, with the Operators in it for scale. Every object sheet
   afterwards is cut from or checked against it.
2. **One shader for everything.** Every object uses the same toon shader, key light, shadow tint
   and ink outline as the Operators. This does more for cohesion than any modeling choice.
3. **One palette.** Grimy neutral cream, grey and charcoal base, shared with the Operators. Corporate spaces add
   neon accents in magenta, hot pink, red, orange and violet in screens and ads; back rooms, service
   areas and the street are darker and dirtier, lit mostly by signage. The Operators' own accents (yellow, blue, sage) stay reserved
   for the Operators so they never blend into the set.
4. **Two ways to build, split by job.**

   | Kind | How | Why |
   |---|---|---|
   | Grid pieces: floors, walls, doorways | Simple shapes built by script (Godot or Blender), sized exactly to 1 m, with worn textures in the house style | They must tile perfectly; Meshy can't hit exact dimensions |
   | Everything else: nodes, props, dressing | Concept sheet → Meshy → the same shader | Where Meshy shines, and it matches the Operators because it made them |

5. **Judge in place.** Each object is reviewed on the map at the battle camera, next to an
   Operator, not alone in the preview.

## The list

Priority: **1** the MVP can't show its rules without it; **2** makes the map read as a place;
**3** dressing. Status starts at "todo" for everything.

### Grid and structure

| # | Object | Priority | Notes |
|---|---|---|---|
| 1 | Floor tile, corporate interior | 1 | The default floor |
| 2 | Wall segment, 1 m | 1 | Blocks movement and sight; needs to stay readable from above (a cutaway top) |
| 3 | Wall corner and wall end | 1 | So wall runs join cleanly |
| 4 | Extraction zone | 1 | The exit tiles (`X`): roof access or a hatch, readable as "go here" |
| 5 | Operator start zone | 3 | The loading dock (`P`) |
| 6 | Floor variants (server room, corridor) | 2 | Tells rooms apart at a glance |

### Network nodes (each needs an idle look and a hacked/secured look)

| # | Object | Priority | Notes |
|---|---|---|---|
| 7 | Access point | 1 | Where an Operator plugs in their AI |
| 8 | Door | 1 | Open, closed and locked states |
| 9 | Security camera | 1 | Wall or pole mount, with its view direction readable |
| 10 | Turret | 1 | A unit with HP: active, offline and destroyed looks |
| 11 | Data cache | 1 | The objective, so the most striking object on the map |
| 12 | Probe | 1 | Dropped on a node; small, so it needs a marker |

### Characters that aren't Operators

| # | Object | Priority | Notes |
|---|---|---|---|
| 13 | Guard | 1 | Humanoid, so it goes through the Operator pipeline. Not environment, listed so it isn't forgotten |

### Dressing (makes it a place)

| # | Object | Priority | Notes |
|---|---|---|---|
| 14 | Advertisement screens and holo-billboards | 2 | The world's signature; the main carrier of the neon accents |
| 15 | ~~Planters and greenery~~ | — | Cut 2026-09-27: the world is gritty all the way through |
| 16 | Server racks | 2 | Fills the sealed server room around the cache |
| 17 | Desks, benches, lobby seating | 3 | Atrium and corridor |
| 18 | Crates and loading-dock clutter | 3 | The start zone |
| 19 | Cable trays and conduit | 3 | Ties the network to the physical space |
| 20 | Lights: ceiling panels, lamps | 3 | |
| 21 | Vending machine or kiosk | 3 | More ads |

Dressing can't block movement or sight unless the rules say so. Until there's a cover mechanic,
it stays against walls or on tiles that are already walls, so the map never looks like it has
cover it doesn't.

## Questions for Bryson

1. ~~What is the MVP map, as a place?~~ A city street (Bryson, 2026-09-27).
2. Should the style anchor painting come first, before any object?
3. Is the split right: grid pieces by script, everything else through Meshy?
4. Anything missing from the list, or anything to cut?

## Findings

### 2026-09-27 — The MVP map is a city street (Bryson)

- The MVP battle map is an urban city street, not a building interior.
- Skip the AI and network objects for now; build up the city environment first.
- The full street inventory Claude proposed was too much. The goal is "strictly better than the
  blank placeholders," enough to get an idea of the visuals, not a finished product.
- No yellow or cyan anywhere in the city. Hazard stripes are orange and white.
- Images are requested from Astra in one batch so they stay consistent, one copy each.
