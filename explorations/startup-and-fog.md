# Startup performance and clearer fog of war

- Status: approved for implementation by Bryson, 2026-10-11. Claude did not review; Bryson's
  approval replaces the proposed pre-construction review. Loading/animation architecture changes
  still follow evidence and joint review.
- Priority: startup diagnosis, fog prototype, full-level integration and verification, then
  [Request 13](action-blockers.md).
- Owner: Astra, through Request 14 in [the requests table](claude-and-astra.md#requests).

## Approved goal

Hidden scenery becomes shaded gray 3D boxes matching each logical asset's size, orientation
and position. Only the portion in visible cells shows the real model: a car's visible rear is
detailed while its hidden front remains a box. Unseen characters remain hidden.

## Implementation and acceptance

1. Measure five fresh-process battle entries and five same-process restarts before fog changes,
   then repeat afterward. Separate resources, rules/session, environment, characters, animation
   preparation and the first rendered frame. Report median/range, hardware and cache conditions;
   deliver one focused improvement proposal. The earlier 7.93-second headless observation is not
   a first-playable-frame measurement.
2. GridView owns a binary texture from the rules' visible cells, independent of brightness,
   fading and flicker. LevelView owns fitted proxies and logical asset registration. Shared
   model materials opt scenery in per instance, preserving characters and preview tools.
3. Fit combined bounds after placement and sizing, including compound devices and procedural
   assemblies. Detail and proxy sample the same world-position mask and clip opposite portions.
   Cover surfaces, outlines, lettering, screens, glow geometry and shadows. Hidden ground is
   plain gray. World advertisement lettering becomes flat, mask-compatible text meshes.
4. Boxes have neutral gray faces, lighter tops and darker sides, no texture or emission. Tile
   visibility changes immediately. Share geometry/materials, calculate bounds once, and cull
   detail/proxies wholly on one side of visibility; use fragment clipping for partial assets.
5. Verify a building, multi-tile car and sign in a small scene before full integration. Check
   rotated partial cars from multiple angles, crisp transitions, visible darkness versus hidden
   illumination, no hidden lettering/glow/outline/shadow leaks, doors, moving vehicles, wall
   ghosting, map edges and physical/Network transitions. Preserve Locate, last-seen and team
   visibility. Run tools/check.sh; record native checks/images separately from Bryson's playtest.

Scenery uses current environment state and positions; no remembered-scenery system is added.
The treatment covers the playable grid and existing fog border. Outside decorative scenery and
rain retain their current handling. Information leaks needing gameplay decisions are reported
for Bryson, rather than silently changing rules.

## Findings

Implementation and validation pending. Startup architecture has not been changed.
