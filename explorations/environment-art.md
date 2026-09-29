# Environment art for the corporate facility mission

- Feeds: [art-pipeline.md](art-pipeline.md), DESIGN.md's look decision
- Status: open
- Next action: Bryson plays the redesigned exterior map and says what to change. Later: a
  hand-built terminal model and a map editor for Bryson (both on the board).

## The question

Which environment objects the MVP battle needs, and how to make them so they belong together and
match the three Operators. Bryson asked for a full list to solve one at a time (2026-09-27).

Later the same day it became the art for the first Alpha mission: infiltrating a corporate
facility, outside and then inside (Findings).

## Constraints this inherits

- The look: gritty cyberpunk anime, Edgerunners-style, worn surfaces (DESIGN.md). Image prompts
  start from the [house style](art-pipeline.md#house-style).
- The Operators are Meshy models drawn with `game/art/shaders/toon.gdshader` and a
  silhouette-only ink outline. Their painted-in detail lines stay (Bryson, 2026-09-27).
- The world: a gritty, technofeudal corporate AI future full of advertisements, all the way
  through (DESIGN.md).
- Maps are grids of 1.5 m tiles with walls 2.8 m tall (2026-09-28), under a free camera that
  can zoom from close-ups to the whole map (Bryson, 2026-09-28). Objects have to read both close
  and far. New maps replace the 12×12 MVP map (Bryson, 2026-09-27).

## Method (Claude's recommendation, 2026-09-27)

What makes a set feel like one world, in order of impact:

1. **One style anchor.** Before any single object, one painted concept of each map from the
   battle camera's angle, made with the same image generator and
   [house style](art-pipeline.md#house-style) as the Operator sheets, with the Operators in it for scale. Every object sheet
   afterwards is cut from or checked against it.
2. **One shader for everything.** Every object uses the same toon shader, key light, shadow tint
   and ink outline as the Operators. This does more for cohesion than any modeling choice.
3. **One palette.** Grimy neutral cream, grey and charcoal base, shared with the Operators. Corporate spaces add
   neon accents in magenta, hot pink, red, orange and violet in screens and ads; back rooms, service
   areas and the street are darker and dirtier, lit mostly by signage. Full palette. Operators stay
   readable through silhouette, light and contrast, not reserved colors (Bryson, 2026-09-29).
4. **Two ways to build, split by job.**

   | Kind | How | Why |
   |---|---|---|
   | Grid pieces: floors, walls, doorways | Simple shapes built by script (Godot or Blender), sized exactly to 1 m, with worn textures in the house style | They must tile perfectly; Meshy can't hit exact dimensions |
   | Everything else: nodes, props, dressing | Concept sheet → Meshy → the same shader | Where Meshy shines, and it matches the Operators because it made them |

5. **Judge in place.** Each object is reviewed on the map at the battle camera, next to an
   Operator, not alone in the preview.

## The set (approved by Bryson, 2026-09-27)

The goal is "strictly better than the blank placeholders," not finished art. Twenty images in one
Astra batch, one copy each, so they stay consistent. An earlier, larger list is in git history.

| Phase | Textures (scripted floors and walls) | Props (Meshy) | Characters |
|---|---|---|---|
| Outside | Asphalt, concrete paving, perimeter wall | Guard booth, floodlight pole, loading dock (the way in), shipping crates, delivery van | Guard |
| Inside | Corporate floor tile, white wall panels | Security door, security camera, turret, vault door, server rack, reception desk, access point | Guard |

- Two establishing shots come first, one per phase: they are the style anchors.
- The guard wears a full helmet, so Meshy never has to make a face (Bryson agreed). He goes
  through the Operator pipeline and shares their clips.
- The corporation's color is magenta on white and charcoal. Inside is sleek and cold but worn at
  the edges, cleaner than the street (Claude's calls, in the approved prompt).
- States the rules need, made with lights and materials rather than extra models: door open,
  closed and locked; turret active, offline and destroyed; camera view direction.
- Props sit only on wall tiles or against walls, so nothing looks like cover the rules don't have.
- Meshy cost estimate: about 215 to 395 credits.

The prompt:

```
I need a batch of 20 separate images for a video game's environment art. Generate them in the order listed, each as its own image, labeled with its number. Exactly one image per item: no variations, no alternates, no retries.

STYLE FOR EVERY IMAGE: Gritty cyberpunk anime style in the vein of Cyberpunk: Edgerunners: bold ink outlines, hard-edged cel shading, flat saturated colors, sharp angular design. A technofeudal corporate AI city. Outside is gritty: grime, rust, stains, scuffs, graffiti. The corporation's own spaces are sleek and cold, white and charcoal with magenta light, worn at the edges but cleaner than the street. Accent colors only magenta, hot pink, red, orange and violet. Never use yellow, blue, cyan or green anywhere. Hazard stripes are orange and white. Any text is short invented words or pictograms, never real brands.

IMAGE 0A, EXTERIOR ESTABLISHING SHOT (make first; keep every exterior image consistent with it): A corporate facility at night, seen from high above at about 50 degrees looking down, like a tactics game camera. A walled compound off a gritty city street: a guard booth with a gate arm, floodlight poles, a loading dock at the side of the building with shipping crates and a delivery van, and a tall sleek corporate building of dark glass and concrete with a glowing magenta logo. A few small armored guards patrolling.

IMAGE 0B, INTERIOR ESTABLISHING SHOT (keep every interior image consistent with it): Inside the same corporate building, seen from high above at about 50 degrees with the ceiling cut away, like a tactics game camera. A lobby with a reception desk, corridors with sliding security doors, a wall-mounted security camera, an automated turret, and a sealed server room behind a massive vault door. A few small armored guards.

IMAGES 1 TO 12, OBJECTS: Each shows ONE object alone, centered on a plain white background, no people, no ground, no scenery. Three-quarter view from the front-left, camera slightly above at about 30 degrees, the whole object in frame. Even, neutral lighting with no dramatic shadows; lights and screens are drawn glowing. Wall-mounted objects have a flat back.
1. Guard booth, 2 m by 2 m by 2.8 m tall: a small concrete-and-steel security booth with tinted windows and a striped boom-gate arm.
2. Floodlight pole, 7 m tall: a steel pole topped with a bank of harsh white security floodlights.
3. Loading dock, 4 m wide by 4 m tall, wall-mounted: a roll-up steel door above a raised concrete dock edge with rubber bumpers and orange-and-white hazard stripes.
4. Shipping crates, 1.8 m tall: heavy plastic shipping crates stacked on a pallet, stenciled numbers, strapped down.
5. Delivery van, 5 m long: a boxy corporate self-driving delivery van with no windows in back, white with a magenta stripe, dented and dirty.
6. Security door, 1.2 m wide by 2.4 m tall, wall-mounted: a heavy sliding door in a thick frame, with a card reader and a magenta status light, scratched.
7. Security camera, 0.5 m long, wall-mounted: a boxy surveillance camera on a short wall arm, with one red lens light.
8. Turret, 1.3 m tall: a compact automated sentry turret on a squat armored pedestal, twin barrels and a single red sensor eye, white and charcoal armor plates.
9. Vault door, 3 m wide by 3 m tall, wall-mounted: a massive round steel vault door set in a thick square frame, closed, heavy locking bolts, a magenta status ring.
10. Server rack, 2.2 m tall: a black server cabinet with a glass door, rows of glowing magenta and red status lights, neat cable bundles.
11. Reception desk, 3 m long: a sleek curved corporate reception desk, glossy white top, an invented corporate logo on the front, a slim monitor.
12. Access point, 1 m tall, wall-mounted: a slim armored network terminal with a data socket and a small glowing screen.

IMAGES T1 TO T5, TEXTURES: Each is a square, perfectly flat, seamless tileable texture viewed straight on, with even lighting and no perspective.
T1. Asphalt, cracked and patched.
T2. Concrete paving slabs, stained, with expansion joints.
T3. Tall concrete perimeter wall, stained, with water streaks.
T4. Polished dark grey corporate floor tiles, scuffed.
T5. White corporate wall panels with thin seams, scuffs and marks.

IMAGE G, GUARD CHARACTER SHEET (different format): Character turnaround sheet, front view and back view side by side, full body, plain white background. Strict T-pose: arms straight out horizontally, palms facing down, gloved hands with fingers together, not spread. Feet shoulder-width apart. Realistic adult proportions. Nothing hangs below mid-thigh; no capes, long coats or loose straps. A corporate security guard: full-face helmet with a dark visor and a thin magenta light strip, charcoal and white body armor plates over a dark uniform, an invented corporate insignia on the shoulder, a holstered sidearm on the right hip, heavy boots. Empty hands, no weapon held.
```

The accent-color sentence in this prompt is lifted (Bryson, 2026-09-29: full palette). Drop it
before reusing the prompt; see [the style study](environment-style-study.md).

## Questions for Bryson

Earlier ones were settled on 2026-09-27 and 2026-09-28 (Findings). None open.

## Findings

### 2026-09-29 — The facility corp is Anthropomorphic: clay and cream (Bryson; Claude recolored)

- Bryson named the corps OpenBrain and Anthropomorphic, tongue-in-cheek, with no real brands.
  The facility is Anthropomorphic.
- The recolor was done by script:
  - Magenta turned clay orange in every facility prop texture and the guard's texture, and
    the wall neon changed to a clay glow (`NEON` in `level_view.gd`).
  - Light grays warmed toward cream.
  - The Operators were not touched.
- Bryson adopted the recolored 0A: "The recoloured one with the orange is incredible, keep
  that please." It replaced the original under the same name (the magenta version is in git
  history).
- The rest of the facility art was recolored to match:
  - the concepts in `art/reference/environment-facility/`
  - the Meshy renders of the props, guard and turret
  - the in-game floor and wall textures

  Orange hazard stripes stay.
- Checked by viewing the images, not in the game: Godot isn't installed in the cloud session.
- Logos and the van's "SENTINEL" text keep their shapes.

### 2026-09-28 — The cutaway walls are out; ghosting instead (Bryson)

- Bryson changed his mind about the cutaway: "we need ghosting on the walls so that the player
  knows that they're there, instead of what we have now." Research first; the thread is
  [wall-occlusion.md](wall-occlusion.md). Decided and built the same day: walls in the way of the
  team ghost, hidden units show as silhouettes, H ghosts every wall.

### 2026-09-28 — The map redesigned from 0A; panels in walls (Bryson asked; Claude built it; screenshots, not played)

- Bryson: "Use the reference image as the basis for how to build the map. Redesign it." That was
  the point of sharing 0A: it's the layout, not only the look.
- The battle now plays `facility_exterior.tres` (sketch in [battle-mvp.md](battle-mvp.md)): street
  along the south, perimeter wall with an orange hazard band, guard booth and boom beside an open
  vehicle lane, a service door into a side yard, floodlights, the tower's entrance with glass
  doors, a turret on the plaza, and the loading dock building with its dock door, the van, crates
  and the objective rack.
- Access points are panels set into walls, as Bryson asked; cameras and the cache rack too.
- Missing against 0A, for later: the tower's facade (windows, screens, logo, slogans), planters,
  barbed wire, the wet street and its poles, hazard stripes (a solid band stands in), the street
  painting.

### 2026-09-28 — Cutaway walls stay; models approved in play; two kinds of access point (Bryson)

- The walls that cut away in front of the camera stay for now as the answer to showing a
  ceiling: "it takes the shape of the solution I want, if not the aesthetic." Bryson doesn't
  expect it to last forever.
- "The models are looking great now that they're in the game." This answers the earlier critique.
- Access points looked wrong: the model is flat on one side, as if meant for a wall, but stood in
  the middle of the floor. Bryson wants several kinds of access point in time, two to start:
  - **Wall panel**: the existing access point model, mounted on a wall. No new generation.
  - **Terminal**: a monitor on a podium, like the terminals in No Man's Sky, placeable anywhere.
    Claude builds it by hand, not with Meshy. Later; the panels come first.
- The exterior establishing shot (0A): Bryson says Claude missed the point of it, and that it
  makes him think a map editor, so he can lay out levels himself, would be easier. The map
  editor is on the board as something to build.

### 2026-09-28 — The goal for the exterior, and a critique of the look (Bryson)

- The exterior establishing shot, `art/reference/environment-facility/0A-exterior-establishing.png`,
  is the goal for the first part of the level: a walled compound off a wet street, guard booth
  and gate, floodlights, the tower entrance with planters and screens, the loading dock with the
  van and crates, slogans and hazard stripes on the walls.
- "We need more aesthetic cohesion. Nothing looks like it belongs in the same world, the models
  themselves don't look good." Bryson also wants some indication of a ceiling, as seen in The
  Sims. Both wait for the aesthetics pass, after the fixes, docs and code review.
- Built the same day (details in [battle-mvp.md](battle-mvp.md)): 1.5 m tiles, 2.8 m walls that
  cut away in front of the camera, the fog as light, rings under units. The level is drawn by
  `game/battle/level_view.gd`, the grid and fog by `game/battle/grid_view.gd`.

### 2026-09-28 — Everything on the map; mouse camera; neutral stance (Bryson asked; Claude built it; scripted runs and screenshots, not played)

- Bryson wanted to see "the final product, everything we've created thrown at it," then refine.
- Walls get a charcoal cap and a magenta neon strip; the scene glows only where something emits.
  Some wall tiles are props that block the same way: crate stacks, a server rack, the reception
  desk. The map sits in a building shell (perimeter wall texture) on a paved apron and an asphalt
  yard with the loading dock at the Operators' start, the van, crates, floodlights and the guard
  booth. All of it is `dressing` lines on the map; a prop can now fill a run of wall tiles.
- A guard's "last seen" marker is a see-through copy of the guard model instead of a capsule.
- Camera, per Bryson: left-drag orbits (turn and tilt), middle-drag or Option-drag pans, wheel or
  pinch zooms, closer than before. A click selects on release, so a drag never selects. The view
  can pan past the map to see the yard.
- Units stand in a still "Neutral" pose, built from each rig's T-pose with the arms lowered,
  instead of Meshy's idle clip (Bryson: "not this strange idle animation"). Clips still play for
  running, shooting, hits and going down.
- Known mismatch: the reception desk is low but blocks sight, like the wall it replaces.

### 2026-09-28 — Models replace the MVP map's placeholders (Bryson asked; Claude built it; scripted runs and screenshots, not played)

- Operators and guards replace the capsules: Alpha is the main character, Bravo the headband
  Operator, Charlie the sage Operator (Claude's mapping, by the closest UI color). Each unit's
  model and pack are file paths in its unit data, so the rules and tests never load art.
- Animations: units run between tiles with the feet matched to their speed, turn to face where
  they go and what they shoot, draw and fire on an attack, flinch on a hit, and fall when downed.
  A hit still flashes white and a downed or offline unit greys out, now through the toon shader;
  a cloaked unit goes see-through. The turret swings round and kicks back.
- Nodes: access points stand as terminals, cameras mount on a neighbouring wall or on a pole,
  the door fills its gap and vanishes when open, the cache is a server rack. A breached node
  still takes the player's green. New map field `dressing` places props with no rules role:
  the MVP map gets the vault door on the server room's wall and two more racks inside.
- One `ToonModel` loads any Meshy model with the toon look, shared by the battle and the
  character preview. The server rack's stray fragment was removed in Blender.
- Readability, from the default battle camera: the Operators' cream and charcoal read muddy
  against the dark floor at about 40 px; the old capsules were brighter. Not yet addressed.

### 2026-09-28 — All 12 props built (Bryson's direction; Claude's results, rendered and inspected, not yet seen by Bryson)

- Bryson: hard-surface mode for the blockier props, Claude's judgement for each; keep the
  hard-surface turret. The Meshy 7 turret is deleted.
- Hard-surface (15 credits each): guard booth, floodlight pole, loading dock, shipping crates,
  security door, security camera, server rack, access point, turret. About 3–4k triangles each.
- Meshy 7 (30 each): delivery van, vault door, reception desk, for their curves and wheels, and
  because the vault is the mission's centerpiece. 26–38k triangles.
- 210 credits, 2,465 left. All succeeded on the first try. In `game/art/props/<name>/`.
- Checked in a lineup at real-world size next to the guard, with the toon shader. All read as
  their sketches. The server rack has a tiny stray fragment beside it that stretches its bounds;
  it gets trimmed on placement.

### 2026-09-28 — The guard, and the turret in two Meshy modes (Claude; rendered and inspected, not yet seen by Bryson)

- Spent 80 credits, 2,675 left. Everything succeeded on the first try.
- Guard: Meshy 7 from front and back, 4K texture, about 60k triangles, rigged. In
  `game/art/characters/guard/` and in the character preview. The shared clips work on him too:
  idle, quick draw, walk and hit reaction checked.
- Turret, same image both ways, in `game/art/props/`: hard-surface ("smart topology") mode, 15
  credits and 3,677 triangles, against Meshy 7, 30 credits and 28,299 triangles. Meshy 7 keeps the
  long barrels and the exact silhouette; the cheap one shortens the barrels. Both have clean
  guessed backs. At the battle camera the difference should be small, but that isn't checked yet.

### 2026-09-27 — Batch adopted; Meshy spend approved (Bryson)

- The batch moved to `art/reference/environment-facility/` as adopted reference.
- Astra's logo, slogans and names stay as placeholders. "We'll create new stuff later when we've
  deep dived the story; this is still gameplay proof of concept/alpha build."
- Approved: the guard (35 credits) and a Meshy mode test on the turret (45) before the other 11
  props.

### 2026-09-27 — Review of the batch; interior textures on the MVP map (Claude; run and screenshotted, not played)

- The 20 images are consistent with each other and with the house style: one corporate logo,
  magenta on white and charcoal, orange-and-white hazard stripes, none of the Operators' colors.
- Astra invented world details nobody has decided: the logo, a name on the van that reads like
  "Sentine(l)", slogans ("Sentience serves order", "Human data higher", "More obedient humans")
  and kanji on the tower. Keeping or replacing them is Bryson's call.
- Tiling, checked 2×2: asphalt, floor tile and wall panels are seamless. The paving shows a
  doubled joint line and the perimeter wall a faint band where copies meet; minor.
- The corporate floor and wall textures now cover the MVP map's floor tiles and wall blocks, in
  world space. The wall texture repeats every 2 m; at 1 m its seams read as noise from the
  battle camera.
- For Meshy: each object image is a clean three-quarter view on white, and the number labels in
  the corners get whited out first. The guard sheet is a clean T-pose, gloves closed, the holster
  on the same side in both views.

### 2026-09-27 — The approved 20-image batch was generated (Codex)

- Exactly one image was generated for each approved item, in the approved order, with no
  variations, alternates or retry generations.
- The 20 unique PNG files are in `art/concepts/environment-facility-batch/` (since moved to `art/reference/environment-facility/`). The five textures
  are square and use their filenames as identifiers so no label interrupts the texture pixels.
- These remain exploratory concepts in `art/concepts/` until Bryson reviews them; generation and
  file validation do not constitute creative approval or proof that the textures tile seamlessly
  in-engine.

### 2026-09-27 — The mission is a corporate facility, outside then inside (Bryson)

- Supersedes the city-street entry below. Bryson imagines the mission as a team infiltrating a
  corporate facility: first avoiding guards outside to get into the building, then inside,
  reaching a vault while avoiding turrets, cameras and guards.
- The vault is both a room and the objective: an access point the Operator must be inside the
  vault to use, and once inside, has to stay within a certain distance of. The rule itself is
  recorded in [battle-mvp.md](battle-mvp.md).
- New maps replace the 12×12, which only demonstrated the smallest version of the game. "We're
  slowly graduating to an Alpha build."
- Bryson approved the 20-image set above and agreed to helmeted guards.

### 2026-09-27 — The MVP map is a city street (Bryson)

- The MVP battle map is an urban city street, not a building interior.
- Skip the AI and network objects for now; build up the city environment first.
- The full street inventory Claude proposed was too much. The goal is "strictly better than the
  blank placeholders," enough to get an idea of the visuals, not a finished product.
- No yellow or cyan anywhere in the city. Hazard stripes are orange and white. (Color rule lifted
  2026-09-29, see [environment-style-study.md](environment-style-study.md).)
- Images are requested from Astra in one batch so they stay consistent, one copy each.
