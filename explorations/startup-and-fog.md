# Startup performance and clearer fog of war

- Status: implemented and verified by Astra, 2026-10-11.
  Approved by Bryson, 2026-10-11. Claude did not review; Bryson's
  approval replaces the proposed pre-construction review. Loading/animation architecture changes
  still follow evidence and joint review. Follow-up 2026-10-11: Bryson reports that the delivered
  fog did not meet the required movement-tick refresh or dark hidden appearance. Request 17
  now implements and verifies the approved repair: model-shaped silhouettes, restored ground
  and per-square vision. Bryson selected tone B; see [the repair findings](fog-vision-ticks-fix.md#request-17-implementation-findings).
  The original box goal, captures and measurements below are Request 14 history.
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

### Request 26 handoff: performance and polish pass, 2026-10-13

Claude reviewed the game for speed, smoothness and token cost. Bryson approved the items below and
assigned them to Astra (2026-10-13). This also decides Request 15: Bryson accepts a slight loss of
texture quality in exchange for the startup time. Lighting items (AreaLight3D for shopfronts and
screens, a reflection probe for the wet ground) are **on hold**; don't build them.

**Evidence.** Claude ran these on an M1 Pro at 1600×900, in the physical view. These are single runs, not the five-run
protocol:
- Fresh setup is 10.5 s, and resource loading is 9.8 s of that. Each of 14 legacy models takes about 0.4–0.8 s to load.
- All 137 texture imports under `game/assets/` are `compress/mode=0` (Lossless). The 14 textures the
  battle loads are 4096². Video memory in use is 2.0 GB.
- Pilot: the security door's texture was switched to `compress/mode=2` and reimported. `security_door.glb`
  then loaded in 4 ms, down from 405 ms. The pilot was reverted afterwards.
- The frame rate holds the 59–60 fps refresh cap, and rendering CPU is 1.7 ms.
- The physical view uses 1,153 draw calls: 2,135 MeshInstance3Ds but 1,208 distinct meshes, because `_add_box`
  makes a new `BoxMesh` per call. This count isn't comparable with the table above, which was
  taken at 1280×800 in the starting view.
- Characters are about 100k triangles each.

**Work.** One commit per item, so each can be undone on its own. Claim the files in the requests table first.

1. **Textures:**
   - Set every texture `.import` under `game/assets/` to `compress/mode=2`, with resolution unchanged, and reimport. Note how long the
     reimport takes, since every machine pays it once.
   - Use Godot's default S3TC; use `high_quality=true` (BC7) only if captures show blocky artifacts.
   - Add `[importer_defaults]` `texture={"compress/mode": 2}` to `project.godot`, so new Meshy downloads import compressed.
   - Add a one-line guard to `tools/check.sh` that fails on any `compress/mode=0` texture under `game/assets/`.
   - Add one line about it to the asset contract, `game/assets/README.md`.
2. **Debanding and SMAA:** in `project.godot`, set `anti_aliasing/quality/use_debanding=true`, and set
   `anti_aliasing/quality/screen_space_aa` to SMAA (check the enum value). MSAA 2× stays.
3. **Shared meshes:**
   - Add a static `LevelView.box(size)` cache, used by `_add_box` and `_toon_body` in `level_view.gd`, and by
     `_add_box` and `_add_glow` in `city_backdrop.gd`.
   - Cache `CityBackdrop._glow_material` by color, as `ToonModel.flat` does.
   - Small cleanups in the same commit: compute `_filled_cells()` once in `build()` and pass it to
     `_build_ground`; have `_glow_quad` create its instance under `root` directly.
   - If draw calls don't drop, say so; the change still removes about 1,000 duplicate mesh resources.
4. **Eased zoom:**
   - In `camera_rig.gd`, the wheel and pinch set a `_zoom_target`, and `_process` eases `_distance` toward it with
     the same `1 - exp(-rate * delta)` form as `_follow_step`, through an exported `zoom_rate`.
   - `_set_distance` stays immediate and syncs the target, so `_glide`, overhead mode and the tools are unchanged.
5. **Archive the one-off tools:**
   - Move these to `~/Desktop/Archive/strategy-game-idea/2026-10-13-one-off-verifiers/`, with any `.uid` files:
     `tools/verify_blocker_menus.gd`, `verify_fog.gd`, `verify_fog_fade.gd`, `verify_fog_outline.gd`, `verify_object_menus.gd`,
     `verify_vision_ticks.gd`, `review_fog_look.gd` and `fog_prototype.gd`.
   - Keep the profilers, `prep_prop.py`, `build_fixtures.py` and `check.sh`.
   - Record the batch in the archive's README and `INDEX.md`, and in `ARCHIVE.md`, noting that older explorations still link these paths.
   - Update the two rows in `README.md` that name them.
6. **Orphan:** delete `game/art/shaders/fog_box.gdshader.uid`, whose shader is gone.
7. **Linter:**
   - Install `gdtoolkit` 4.x with pipx.
   - Add a `.gdlintrc` that encodes the [shared coding guide](shared-coding-guide.md), and turn off rules the guide doesn't state,
     such as line length.
   - Fix real violations. Where gdlint's defaults differ from something the guide doesn't set, change the config, not the code.
   - `check.sh` runs gdlint when it's installed, and otherwise prints that it skipped it.
   - Add the install line to `README.md`, one line to the guide's Style section, and "and the linter" to the `tools/` row in
     AGENTS.md.

**Verify and record:**
- `tools/check.sh` passes after each item.
- Measure startup before and after with `tools/profile_startup.py`, using the five-run protocol.
- Take before and after captures in a fixed physical-view framing, each in its own process after
  ghosting settles. Flag any change to the look: blockiness, SMAA softening, banding.
- Run the build to check that zoom eases and that overhead mode (N) still glides and restores.
- Record the results here as a dated finding, close Requests 15 and 26, and update the board row.
- Push, then restart the game.

### Request 26 implementation findings, 2026-10-13

Bryson activated Request 26 after Request 25 was delivered. Astra is executing the seven approved
items, one commit per item. Lighting remains on hold.

#### 1. Texture compression

All 137 existing asset texture imports now use `compress/mode=2`, default S3TC, unchanged source
resolution and unchanged quality/mipmap options. New imports inherit the setting. The asset
contract records it, and `tools/check.sh` rejects lossless imports before launching Godot; a
throwaway bad import confirmed that refusal. The full six project checks passed.

The first conversion took 6.05 s. The sandbox blocked system certificate access and saving Godot's
editor preferences afterwards; a clean import and all project checks passed outside the sandbox.
This is the one-time import cost on this machine, separate from game startup.

The existing profiler ran five fresh processes, then one warm-up and five warm restarts on Godot
4.7.2, Metal Forward+, Apple M1 Pro, facility yard at 1280×800. The native capture probe warmed the
fixture first. Fresh means a new game process with imported assets and a warm filesystem cache.
Values below are medians with minimum–maximum ranges; both sets use the same profiler and fixture.

| Measurement | Before compression | After compression |
|---|---|---|
| Fresh setup, ms | 8,746.4 (8,629.3–8,899.9) | 753.5 (729.9–985.6) |
| Fresh first frame, ms | 9,050.8 (8,774.3–9,454.1) | 902.0 (889.7–1,149.0) |
| Warm restart setup, ms | 248.2 (242.3–261.6) | 240.3 (236.1–245.7) |
| Warm restart first frame, ms | 326.8 (313.4–393.6) | 324.8 (324.3–334.6) |

[Raw baseline samples](../art/previews/request-26-2026-10-13/baseline/samples.json) and
[compressed samples](../art/previews/request-26-2026-10-13/compressed-startup/samples.json).
The fixed initial physical view uses 1,371,285,120 → 196,814,464 texture bytes and
2,036,006,912 → 686,718,976 total video-memory bytes. Draw calls remain 1,141 at this stage.
GPU timing reports zero on this Metal backend, so no GPU-duration claim is made.

[Before captures](../art/previews/request-26-2026-10-13/before/) and
[compressed captures](../art/previews/request-26-2026-10-13/compressed/) use the same three camera
framings, separate processes and 150 settling frames per view. Initial view plus close view:
pitch 50°, yaw 45°, distance 20, position at the active unit plus (2.5, 0, −2.5); partial car view:
pitch 45°, yaw 30°, distance 13. Rain, idle animation and cursor hover vary between captures.
Reviewed close characters and the partially visible car/nearby prop: no conspicuous block artifacts
or unrequested change in the established look, so BC7 was not needed.

#### 2. Debanding and SMAA

Enabled debanding and `screen_space_aa=2`. The native engine constant confirms
`VIEWPORT_SCREEN_SPACE_AA_SMAA=2`; matching [captures](../art/previews/request-26-2026-10-13/smaa/)
show slightly softer fine edges without a change in palette, framing or fog. No new obvious banding
or block artifacts appeared. The full six project checks passed.

The handoff called the retained multisample setting 2×. The existing project value is
`msaa_3d=2`, which the installed engine maps to 4× (`VIEWPORT_MSAA_2X=1`, `VIEWPORT_MSAA_4X=2`).
The existing value stays unchanged. At the same framing, SMAA's additional targets increase total
video-memory use from 686,718,976 to 702,808,064 bytes; draw calls remain 1,141.

#### 3. Shared box meshes and glow materials

`LevelView.box(size)` owns immutable box meshes keyed by exact `Vector3` dimensions;
`CityBackdrop` owns immutable glow materials keyed by `Color`, with fixed energy. Both caches
last for the process and never mutate cached resources; different geometry/color gets a new key.
Level boxes, primitive device bodies and city boxes/glows use these caches. Ground/device setup
shares one `_filled_cells()` result, and glow quads attach directly to their final parent.

The fixed initial view keeps 2,135 mesh instances, but distinct meshes fall 1,208 → 386;
distinct box meshes fall 1,029 → 207, removing 822 duplicates. Draw calls fall 1,141 → 582
in that same settled framing. These are one-frame resource/count observations, not a frame-rate
or GPU-duration measurement. The full six project checks passed; matching
[shared-mesh captures](../art/previews/request-26-2026-10-13/shared/) preserve the scenery, materials,
fog and ghosted walls. No additional visual change was observed beyond the approved SMAA.

#### 4. Eased zoom

Wheel and pinch input update a clamped `_zoom_target`; processing eases distance with
`1 - exp(-zoom_rate * delta)`, default rate 10. The immediate `_set_distance` synchronizes the
target, preserving tool framing and overhead tween behavior.

The full six project checks passed. A native 1280×800 battle probe sent actual wheel press/release,
magnify and N-key events through `Viewport.push_input`. It verified easing between the old/target
distances, accumulation, settling, minimum/maximum clamps, immediate setter synchronization,
intermediate overhead pitch, complete Network transition and restored position/distance/pitch/yaw.
No failures: [input measurements](../art/previews/request-26-2026-10-13/camera/input-check.json),
[overhead capture](../art/previews/request-26-2026-10-13/camera/network.png),
[restored physical capture](../art/previews/request-26-2026-10-13/camera/restored.png).
These are automated native interaction checks, separate from Bryson's own play reports.

#### 5. Archive the one-off tools

The eight named scripts were copied to
`~/Desktop/Archive/strategy-game-idea/2026-10-13-one-off-verifiers/files/tools/`, with SHA-256 and
byte-count verification before removal. No adjacent `.uid` files existed. The batch README and
manifest, project archive README, archive index and `ARCHIVE.md` record the two-sided handoff;
README's two reading routes now point to findings/permanent tests and the archive. Older dated
explorations intentionally retain their historical paths. The full six project checks passed.
