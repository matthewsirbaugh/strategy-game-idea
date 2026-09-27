# Priority 1 art review

Prototype interpretations of `astra-brief.md`; creative approval remains with Bryson. Models are exported for review, not installed into battle visuals.

## Installer rebuild by Claude — 2026-09-26

- Scope: `char_installer` only, rebuilt from scratch in Blender to match the direction C turnaround (`concepts/installer-2026-09-26/direction-c-turnaround.png`), at Bryson's request for a best-effort Blender build of a well-defined character. Everything is modeled by script; no image-to-3D output is used.
- Build: `blender --background --factory-startup --python art/scripts/char_installer.py`. The Installer is now a spec for the shared human kit in `art/scripts/human/`; how it works and what the build taught us is in [human-pipeline.md](human-pipeline.md). Stages, each cached in `art/source/cache/char_installer/NN_stage.blend` so `-- --from STAGE --to STAGE` rebuilds only what changed: base, trousers (cloth-simulated stacking at the jogger cuffs), shirt (simulated, rolled cuffs), vest (draped canvas and stand collar), shoes, gear (belt kit, pouch, carabiners, thigh holster), head (twisted headband, ringlet hair, glasses with the temple camera, earrings), backpack (solar panel, bottle, camera bot), gloves, details (pockets, snaps, leaf emblem and patches), rig, previews, export. A full rebuild takes about 35 minutes on the M1 Pro: roughly 5 for the trouser simulation, 12 for the preview renders and 10 for the export bake.
- Base: `art/scripts/make_base.py -- char_installer` regenerates `art/vendor/installer_base.blend` from the pinned MPFB2 checkout (`human/fetch_sources.py` downloads it): the same body macros, face and expression targets for likeness and a slight resting smile, and fitted CC0 eyes, eyebrows and eyelashes. Skin, fabric, leather and rubber detail come from CC0 textures listed in `LICENSES.md`; colors, fading, grime and edge wear are procedural.
- Delivery: 67,074 triangles, one skinned mesh, 53 bones, ten materials: `char_installer_skin`, `char_installer_cloth` and `char_installer_gear` (baked 2048 px base color, tangent normal and packed roughness/metallic atlases), `char_installer_decals` (alpha-tested), eyes, brows and lashes (MakeHuman textures), `char_installer_hair` (flat), `glass` and `status_heart` (the camera bot's lens). Garments are single-sided with double-sided materials. A-pose rest; no animation clips.
- Review: `previews/char_installer_front.jpg` (posed hero three-quarter), `_back.jpg`, `_detail.jpg` (face), `_game.jpg` (34 m default view enlarged 3× beside the 12 m closest view, with the 1.7 m reference), `_compare.jpg` (concept beside the renders) and `_godot.jpg` (the exported GLB rendered in Godot).
- Verified: every stage built headless; inspected the hero, back, face, chest, tactics and comparison renders; imported the GLB in Godot 4.7.2 and rendered it with its own renderer: one mesh, ten surfaces, 67,074 triangles, 53 skin binds, no errors on the clean reimport. Rebuilding through the kit reproduced the earlier renders. A throwaway smoke test moved the finished outfit onto a generated 1.80 m male body through the retarget stage; it fitted, apart from the shoe weakness noted in human-pipeline.md.
- Limits: the previews show the full-detail authoring model (about 400k triangles, Cycles, procedural materials). The GLB is decimated and baked, so hair and folds are softer in the game, and the cloth atlas shows a few faint orange bleed streaks on the right thigh. Only the relaxed review pose was checked; walk, run, aim and extreme bends are untested, and weights come from nearest-surface transfer. Hair is sculpted ringlets, which read well at game distance and look sculpted up close. The triangle count is over the brief's 15–25k budget. The battle still uses its placeholders; nothing is integrated or playtested.

## Handoff — 2026-09-25

- All 24 Priority 1 assets/variants have scripts, Blender sources, GLBs and both previews; individual model commits are on `main`. Stop before Priority 2, per the brief.
- Blender builds/renders completed. Key close and tactics views were inspected. Godot imported the set successfully, but the final Operator revision was built afterward. Native visual/animation validation and Bryson's review remain.
- Next: reimport, inspect the models in Godot, exercise the Moth's five clips and door/turret states, and pose-check the Operator's weights. Human animation clips are deliberately deferred; Moth `scan` supplies the pose, while its moving light sweep still needs a game shader.
- Operator: 32,520 triangles including backpack (5,910) and rivet driver (1,520); 1.69 m including bandana. Last pass smoothed garment edges, closed trouser cuffs and limited weights to four influences. Clothes and weights still need pose review.
- Moth exports 76 skinned mesh objects: merge compatible parts before integration. Hatch is 805 triangles and slightly exceeds its 2 m footprint; cargo bike is 2.01 m long. Measured dimensions are below.
- No gameplay integration or native playtest. The CC0 human base is committed; normal builds need no MPFB installation. License and optional base regeneration details are in `LICENSES.md`.

## Asset measurements

Rebuild one asset from the project root: `blender --background --python art/scripts/<asset>.py`. The asset collection exports; `PREVIEW_ONLY` contains the excluded studio and scale reference. Blender front is −Y; the standard glTF conversion makes that Godot +Z. All dimensions below are Blender X × Y × Z, in metres. Floor slabs end at Z=0.

| Asset | Exported triangles | Dimensions | Animation clips | Choices and limits |
|---|---:|---|---|---|
| `kit_floor_company` | 120 | 1.000 × 1.000 × 0.200 | static | No textures. Restrained geometric terrazzo; slab spans −0.2 to 0 m. |
| `kit_floor_company_light` | 132 | 1.000 × 1.000 × 0.203 | static | No textures. Fixed cyan architectural guide; not an ownership indicator. |
| `kit_wall_commons_moss` | 584 | 1.000 × 1.000 × 2.510 | static | No textures. Wall structure is 2.4 m; sparse cap growth reaches 2.51 m. |
| `kit_wall_greenwash` | 696 | 1.000 × 1.039 × 2.400 | static | No textures. Company composite behind a shallow timber trellis; leaves stay inside the tile. |
| `kit_cover_planter_wide` | 748 | 1.900 × 0.900 × 0.870 | static | No textures. 2×1 tile version shares the narrow planter construction. |
| `net_data_cache` | 3,560 | 0.700 × 0.540 × 2.011 | static | No textures. Frosted faces are opaque for reliable sorting. Recolor status_ring green when secured; pulse in game. |
| `kit_exit_hatch` | 805 | 2.000 × 2.009 × 2.458 | static | No textures. 2×2 extraction vignette: six roofward steps, open hatch and hand-painted arrow. Layout is a proposal for review. |
| `prop_server_rack` | 1,816 | 0.720 × 0.705 × 2.000 | static | No textures. Warm activity LEDs only; deliberately no ownership ring because this rack is not interactive. |
| `net_probe_spore` | 1,200 | 0.059 × 0.059 × 0.080 | static | No textures. Actual 8 cm sensor spore; nearly invisible at default zoom, so gameplay needs a marker. |
| `prop_rivet_driver` | 1,520 | 0.100 × 0.289 × 0.186 | static | No textures. 28 cm solar-install rivet tool with tape-wrapped nozzle and removable battery; muzzle faces −Y. |
| `ai_moth` | 2,944 | 0.452 × 0.285 × 0.079 | hover_idle, fly, scan, deploy_probe, strain | One 1024×1024 RGBA wing atlas. Eight-bone rig, five clips. scan opens the wings; the travelling cell-light sweep remains a game shader hook. Place root ~1.82 m high for a 1.9 m hover center. |
| `prop_backpack_rig` | 5,910 | 0.610 × 0.448 × 0.562 | static | No textures. 42 cm frame, ~55 cm with two 30×22 cm solar flaps spread side by side. Positive Y straps face wearer; status_heart is independent. |
| `char_installer` | 67,074 | 1.008 × 0.692 × 1.763 | static | Rebuilt by Claude 2026-09-26: baked 2048 px cloth, gear and skin atlases, one skinned mesh, ten materials, 53 bones, A-pose export. Height includes the camera bot on the pack. See the rebuild checkpoint above. |
| `prop_salvage_crate` | 1,600 | 0.835 × 0.749 × 0.590 | static | Baked 1024 px albedo, normal and roughness/metal atlas. No textures. Open crate of salvaged battery, conduit and cloth-wrapped cable. |
| `kit_wall_commons` | 508 | 1.000 × 1.000 × 2.401 | static | Baked 1024 px albedo, normal and roughness/metal atlas. No textures. Nine quiet earth strata under a timber cap. |
| `kit_cover_planter` | 556 | 0.900 × 0.900 × 0.850 | static | Baked 1024 px albedo, normal and roughness/metal atlas. No textures. 1×1 tile; timber box is 0.65 m and foliage reaches 0.9 m. |
| `net_turret` | 3,576 | 0.720 × 0.874 × 0.899 | active, offline | Baked 1024 px albedo, normal and roughness/metal atlas. No textures. active/offline clips extend or retract the emitter and slump the head. Set status_ring to non-emissive #4A4F57 for offline. |
| `kit_floor_commons` | 600 | 1.000 × 1.000 × 0.207 | static | Baked 1024 px albedo, normal and roughness/metal atlas. No textures. Twelve salvaged pavers with sparse moss; whole-tile footprint. |
| `kit_wall_company` | 308 | 1.000 × 1.000 × 2.400 | static | Baked 1024 px albedo, normal and roughness/metal atlas. No textures. Solid capped 1 m wall block; fixed cyan seam is architectural. |
| `net_camera` | 2,352 | 0.400 × 0.726 × 2.204 | static | Baked 1024 px albedo, normal and roughness/metal atlas. Pole variant first; lens halo is repeated on top for tactics readability. |
| `prop_cargo_bike` | 4,056 | 0.640 × 2.010 × 1.073 | static | Baked 1024 px albedo, normal and roughness/metal atlas. Front-facing −Y; working cargo-bike proportions, boxed solar-install supplies, and a parked kickstand. |
| `net_access_point` | 2,304 | 0.441 × 0.562 × 1.088 | static | Baked 1024 px albedo, normal and roughness/metal atlas. Ownership ring, port halo and top cap share status_ring; unambiguous top beacon. |
| `prop_cable_tray` | 1,104 | 0.325 × 1.000 × 0.124 | static | Baked 1024 px albedo, normal and roughness/metal atlas. One-metre segment; local Z=0 is its mounting surface. Rotate the parent to hang overhead. |
| `net_door` | 1,616 | 1.000 × 0.452 × 2.540 | closed, open | Baked 1024 px albedo, normal and roughness/metal atlas. Clear opening 2.4 m; lintel reaches 2.54 m. open slides 0.82 m into the adjacent wall; recolor status_ring in game. |
