# Environment assets: the pipeline, from scratch

- Feeds: DESIGN.md's look and world decisions, [art-direction.md](art-direction.md),
  [art-pipeline.md](art-pipeline.md) (tool facts)
- Status: blocked
- Next action: Bryson provides images for the new art direction. No pipeline is proposed until
  then (Bryson, 2026-10-10).

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

## Findings

None yet.

## Open questions

None until Bryson's images arrive. A pipeline Claude proposed on 2026-10-10 was set aside at
Bryson's request, so it doesn't steer the work before the direction is clear; it's in git history.
