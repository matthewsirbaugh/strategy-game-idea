# Startup performance and clearer fog of war

- Status: implemented and verified by Astra, 2026-10-11; Bryson's playtest remains open.
  Approved by Bryson, 2026-10-11. Claude did not review; Bryson's
  approval replaces the proposed pre-construction review. Loading/animation architecture changes
  still follow evidence and joint review. Follow-up 2026-10-11: Bryson reports that the delivered
  fog does not meet the required movement-tick refresh or dark hidden appearance; see
  [the repair plan for Claude/Opus review](fog-vision-ticks-fix.md). Those fixes are not implemented.
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

### Startup baseline, 2026-10-11

Godot 4.7.2, Apple M1 Pro (10 CPU cores, 16 GPU cores), 16 GB RAM; native Metal Forward+
at 1280 × 800. Existing imported resources, warm operating-system disk cache and existing shader
cache; no cache flush, asset reimport or loading changes between samples. Five new processes,
then one additional fresh-process warm-up followed by five restarts in that process. Startup
begins immediately before loading battle.tscn, excluding engine/window initialization. First
frame is RenderingServer.frame_post_draw after synchronous battle construction; the player is
controllable at that point. Probe: [profile_startup.py](../tools/profile_startup.py), raw samples:
[before/samples.json](../art/previews/startup-and-fog-2026-10-11/before/samples.json).

| Stage, milliseconds | Fresh: median (range) | Restart: median (range) |
|---|---|---|
| Resources | 8,256.4 (8,244.5–8,348.6) | 84.5 (84.3–85.3) |
| Rules/session | 3.4 (3.3–3.4) | 2.3 (2.3–2.4) |
| Environment, excluding resource/animation work | 109.8 (106.7–112.9) | 58.4 (57.3–60.2) |
| Characters, excluding resource/animation work | 6.4 (6.2–7.0) | 6.8 (6.3–7.0) |
| Animation preparation, excluding resource loading | 141.8 (140.5–142.2) | 63.5 (63.0–65.8) |
| Interface and initial refresh | 25.6 (25.0–29.2) | 13.2 (12.9–13.3) |
| Total synchronous setup | 8,554.7 (8,540.5–8,652.7) | 233.9 (232.7–235.6) |
| Through first rendered frame | 8,710.2 (8,698.8–9,015.7) | 310.5 (307.8–312.3) |

Stages are exclusive; total setup also includes scene instantiation and unclassified overhead.
An instrumented headless cross-check measured 7,993.6 ms setup (one observation, not five).
Animation retargeting is a small fraction of startup. Each distinct large legacy scene costs
roughly 0.4–0.6 seconds on its first load, including textures; cached repeats are much faster.

Native settled rendering (60 warm-up frames, then 120 samples per entry) used a median 1.763 ms
of rendering CPU time across fresh entries (1.626–1.938), with 1,141 draw calls. Restart median
was 1.781 ms (1.616–1.868), 1,107 draws. These CPU figures include frame setup, not game-script
time. Godot's GPU-time monitor returned zero on this Metal build, so GPU duration is unavailable;
zero is not a zero-cost frame. They do not establish human playtest performance.

### Focused startup proposal for joint review

Pilot a smaller, GPU-compressed texture import for **one legacy security camera**, comparing
its first-load time and native appearance against the current 2048-pixel lossless import. Keep
the model geometry, original source and animation flow unchanged. Large scene loads dominate
the measured delay; first test whether the embedded textures account for that cost before
expanding to other assets. This is a proposal, not an approved asset-pipeline change. Claude and
Bryson review the import/visual tradeoff; no loading architecture or animation changes were made.

### Small fog prototype

Binary GridView visibility is separate from animated brightness. SceneryFog fits a shared cube
to combined local mesh bounds, so rotation and movement preserve the fit. Shared model, outline,
wall/sign and effect shaders use per-instance opt-in; character and preview instances retain
their existing behavior. Whole assets cull the unused representation, while partial ones clip
both passes at world-space tile boundaries, including shadow passes. Advertisement lettering
is now a flat TextMesh.

Native Metal captures of a building, sign and multi-tile car (straight and rotated, two camera
angles) are [prototype-0.png](../art/previews/startup-and-fog-2026-10-11/prototype-0.png),
[prototype-1.png](../art/previews/startup-and-fog-2026-10-11/prototype-1.png) and
[prototype-2.png](../art/previews/startup-and-fog-2026-10-11/prototype-2.png). The visible half is
detailed and the hidden half gray; the rendering log is clean. The headless regression checks
pass for immediate visibility independent of lighting, border handling, culling, movement,
rotation and preserving power/door state. These checks are not Bryson's art approval or playtest.
### Full-level integration and validation

LevelView registers 220 logical scenery groups on the facility yard. Connected building tiles
share one enclosure with their trims/rooftop fixtures; other wall tiles group their block,
trim, hazard/neon and fence. Compound devices include their screens, text and mounting poles.
Signs and standalone props have their own fitted boxes. Culling uses conservative transformed
bounds; detail/proxy shaders handle the actual surface boundary. Vehicle tween steps update
position and coverage together, avoiding a frame of stale culling during movement.

Ground and road paint inside the grid/border lose their texture. Outside road/decorative city
geometry and rain retain their presentation. Doors' live open/closed state controls their proxy;
power controls screen detail without revealing it through fog. Ghosting follows wall/model
occlusion; a combined building proxy uses the maximum ghost amount of its wall pieces.

`bash tools/check.sh` passed all six suites. Native Metal checks via
[verify_fog.gd](../tools/verify_fog.gd) passed for partial cars (including rotation and reverse
camera), driving, opening/closing hidden doors, power cycling, wall-ghost input, both Network
transitions, Locate, hidden characters, last-seen markers and team visibility. Captures were
visually inspected: [normal level](../art/previews/startup-and-fog-2026-10-11/level-initial.png),
[rotated car](../art/previews/startup-and-fog-2026-10-11/level-car-rotated.png),
[clipped sign and lettering](../art/previews/startup-and-fog-2026-10-11/level-sign-partial.png),
[Network](../art/previews/startup-and-fog-2026-10-11/level-network.png).
The car/sign fixtures were moved/sized in the verification tool to expose a clean boundary;
the playable map/content were not changed. This is native scripted interaction, not a full
mission playthrough or Bryson's creative approval. Bryson's playtest remains open.

### After fog: identical five-run procedure

Raw samples: [after/samples.json](../art/previews/startup-and-fog-2026-10-11/after/samples.json).
The conditions, start point, camera and sample counts match the baseline. GPU time remains
unavailable from this Metal monitor. This comparison measures the initial static battle view;
it does not establish worst-case camera/mission performance.

| Measurement | Before | After |
|---|---|---|
| Fresh setup, ms: median (range) | 8,554.7 (8,540.5–8,652.7) | 8,660.6 (8,565.6–8,668.1) |
| Fresh first rendered frame, ms | 8,710.2 (8,698.8–9,015.7) | 8,798.9 (8,702.2–8,852.9) |
| Restart setup, ms | 233.9 (232.7–235.6) | 258.6 (257.5–259.8) |
| Restart first rendered frame, ms | 310.5 (307.8–312.3) | 336.7 (336.5–339.8) |
| Fresh rendering CPU, ms | 1.763 (1.626–1.938) | 1.415 (1.344–1.526) |
| Restart rendering CPU, ms | 1.781 (1.616–1.868) | 1.283 (1.120–1.323) |
| Fresh / restart draw calls | 1,141 / 1,107 | 347 / 340 |

After-fog stage medians, fresh / restart in milliseconds: resources 8,322.4 / 87.7; rules
3.3 / 2.4; environment 129.5 / 72.9; characters 6.8 / 7.2; animations 150.1 / 65.1;
interface/refresh 33.2 / 17.5. Environment construction increased by about 20 ms fresh and
15 ms on restart; the total differences also include resource-loading variation.

Resource loading still dominates startup; fog does not solve that delay. The texture-loading
pilot in Request 15 remains a proposal for review. Box/detail joins intentionally follow the
enclosing box rather than the model's contour, so a stepped profile at the boundary is expected.
No remembered-scenery system or visibility/Locate rules were added.

### Final outline review and final measurements

Final review found that the two-pixel ink hull can extend into a hidden tile even when the
underlying mesh bounds are wholly visible. Its expanded points now always sample visibility;
whole-hidden detail culling and the partial-only surface/proxy checks remain. The focused native
[outline probe](../tools/verify_fog_outline.gd) holds a mesh 0.001 world units inside a visible
cell and samples beyond the boundary. The previous condition produced 10 hidden ink pixels;
the fixed condition produced zero. The full native fog checks passed again and the level
captures above were refreshed.

Five fresh entries and five warm restarts were repeated after the outline correction and
Request 13, with the same hardware, cache procedure and viewport. This is the final delivered
version; the earlier `after/` data remains as an intermediate record. Raw samples:
[after-final/samples.json](../art/previews/startup-and-fog-2026-10-11/after-final/samples.json).

| Measurement | Before fog | Final version |
|---|---|---|
| Fresh setup, ms: median (range) | 8,554.7 (8,540.5–8,652.7) | 8,570.9 (8,552.6–8,741.9) |
| Fresh first rendered frame, ms | 8,710.2 (8,698.8–9,015.7) | 8,719.8 (8,691.0–8,926.3) |
| Restart setup, ms | 233.9 (232.7–235.6) | 254.7 (251.9–257.2) |
| Restart first rendered frame, ms | 310.5 (307.8–312.3) | 335.4 (329.0–338.0) |
| Fresh rendering CPU, ms | 1.763 (1.626–1.938) | 1.448 (1.178–1.635) |
| Restart rendering CPU, ms | 1.781 (1.616–1.868) | 1.466 (1.450–1.508) |
| Fresh / restart draw calls | 1,141 / 1,107 | 351 / 344 |

Final exclusive stage medians, fresh / restart in milliseconds: resources 8,242.5 / 85.3;
rules/session 3.3 / 2.5; environment 122.9 / 69.7; characters 6.0 / 6.7;
animations 149.9 / 67.2; interface/refresh 32.7 / 17.1. Fresh entry remains dominated by
resource loading, with essentially unchanged first-frame time within the observed ranges.
The final environment stage adds about 13 ms fresh and 11 ms on restart over the baseline.
GPU duration and worst-case mission/camera cost remain unmeasured. Request 15 is still the
focused proposal for reducing the loading delay.
