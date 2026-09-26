# Priority 1 art review

Prototype interpretations of `astra-brief.md`; creative approval remains with Bryson. Models are exported for review, not installed into battle visuals.

## Installer refinement checkpoint — 2026-09-26

- Scope: `char_installer` only, at Bryson's request. Six geometry review iterations rebuilt the open canvas jacket, rolled sleeves, raised collar, pockets, trouser cuffs and approach shoes; refined the face and tied headwrap; and folded the worn backpack's solar panels vertically. The standalone backpack and rivet-driver assets were not revised.
- Delivery: 31,946 triangles including worn equipment (previously 32,520), one skinned mesh, three materials, 53 bones, up to four normalized weights per vertex, and three embedded 2048×2048 PNG maps: base color, tangent normals, and packed roughness/metallic. Blender dimensions: 1.010 × 0.593 × 1.693 m; crown at 1.694 m. `glass` and `status_heart` remain separate for game shading.
- Rebuild: `blender --background --python art/scripts/char_installer.py`. Add `-- --draft` for geometry/material review in `/tmp/installer-review` without overwriting the delivered source or export. `char_installer_review.py` is character-specific baking/review code; this delivery was also built with the committed version of `common.py`, so it does not require the unfinished shared material pass.
- Review: `previews/char_installer_front.jpg`, `_back.jpg`, `_detail.jpg`, `_pose.jpg`, `_game.jpg`, and `_godot.jpg`. The tactics sheet shows the 34 m default view enlarged 3× on the left and the 12 m closest view on the right; both include a 1.7 m reference. The pose image uses the existing skeleton with lowered upper arms and slightly bent elbows; the exported asset remains in its A-pose, with no animation clips.
- Verified: rebuilt, baked and exported in Blender; inspected the final close, back, face, tactics and lowered-arm renders; imported and rendered the actual GLB in Godot 4.7.2 with Metal/Forward+; checked one mesh, three surfaces and 53 skin binds. Embedded texture sizes and normalized four-weight skinning passed inspection. Godot import/render reported no errors.
- Limit: still prototype character art awaiting Bryson's visual review. Walking, crouching, aiming and extreme joint bends have not been validated. The battle still uses its existing placeholders; this model was not integrated into gameplay or human-playtested. Other uncommitted art work is outside this checkpoint.

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
| `kit_floor_commons` | 600 | 1.000 × 1.000 × 0.207 | static | No textures. Twelve salvaged pavers with sparse moss; whole-tile footprint. |
| `kit_wall_company` | 308 | 1.000 × 1.000 × 2.400 | static | No textures. Solid capped 1 m wall block; fixed cyan seam is architectural. |
| `kit_wall_commons` | 508 | 1.000 × 1.000 × 2.401 | static | No textures. Nine quiet earth strata under a timber cap. |
| `kit_wall_commons_moss` | 584 | 1.000 × 1.000 × 2.510 | static | No textures. Wall structure is 2.4 m; sparse cap growth reaches 2.51 m. |
| `kit_wall_greenwash` | 696 | 1.000 × 1.039 × 2.400 | static | No textures. Company composite behind a shallow timber trellis; leaves stay inside the tile. |
| `kit_cover_planter` | 556 | 0.900 × 0.900 × 0.850 | static | No textures. 1×1 tile; timber box is 0.65 m and foliage reaches 0.9 m. |
| `kit_cover_planter_wide` | 748 | 1.900 × 0.900 × 0.870 | static | No textures. 2×1 tile version shares the narrow planter construction. |
| `net_access_point` | 2,304 | 0.441 × 0.562 × 1.088 | static | No textures. Ownership ring, port halo and top cap share status_ring; unambiguous top beacon. |
| `net_camera` | 2,352 | 0.400 × 0.726 × 2.204 | static | No textures. Pole variant first; lens halo is repeated on top for tactics readability. |
| `net_data_cache` | 3,560 | 0.700 × 0.540 × 2.011 | static | No textures. Frosted faces are opaque for reliable sorting. Recolor status_ring green when secured; pulse in game. |
| `kit_exit_hatch` | 805 | 2.000 × 2.009 × 2.458 | static | No textures. 2×2 extraction vignette: six roofward steps, open hatch and hand-painted arrow. Layout is a proposal for review. |
| `prop_server_rack` | 1,816 | 0.720 × 0.705 × 2.000 | static | No textures. Warm activity LEDs only; deliberately no ownership ring because this rack is not interactive. |
| `prop_cable_tray` | 1,104 | 0.325 × 1.000 × 0.124 | static | No textures. One-metre segment; local Z=0 is its mounting surface. Rotate the parent to hang overhead. |
| `prop_salvage_crate` | 1,600 | 0.835 × 0.749 × 0.590 | static | No textures. Open crate of salvaged battery, conduit and cloth-wrapped cable. |
| `prop_cargo_bike` | 4,056 | 0.640 × 2.010 × 1.073 | static | No textures. Front-facing −Y; working cargo-bike proportions, boxed solar-install supplies, and a parked kickstand. |
| `net_probe_spore` | 1,200 | 0.059 × 0.059 × 0.080 | static | No textures. Actual 8 cm sensor spore; nearly invisible at default zoom, so gameplay needs a marker. |
| `prop_rivet_driver` | 1,520 | 0.100 × 0.289 × 0.186 | static | No textures. 28 cm solar-install rivet tool with tape-wrapped nozzle and removable battery; muzzle faces −Y. |
| `ai_moth` | 2,944 | 0.452 × 0.285 × 0.079 | hover_idle, fly, scan, deploy_probe, strain | One 1024×1024 RGBA wing atlas. Eight-bone rig, five clips. scan opens the wings; the travelling cell-light sweep remains a game shader hook. Place root ~1.82 m high for a 1.9 m hover center. |
| `net_door` | 1,616 | 1.000 × 0.452 × 2.540 | closed, open | No textures. Clear opening 2.4 m; lintel reaches 2.54 m. open slides 0.82 m into the adjacent wall; recolor status_ring in game. |
| `net_turret` | 3,576 | 0.720 × 0.874 × 0.899 | active, offline | No textures. active/offline clips extend or retract the emitter and slump the head. Set status_ring to non-emissive #4A4F57 for offline. |
| `prop_backpack_rig` | 5,910 | 0.610 × 0.448 × 0.562 | static | No textures. 42 cm frame, ~55 cm with two 30×22 cm solar flaps spread side by side. Positive Y straps face wearer; status_heart is independent. |
| `char_installer` | 31,946 | 1.010 × 0.593 × 1.693 | static | Three 2048 px baked maps; one mesh, three materials, 53 bones. Rebuilt clothing, face/headwrap, approach shoes and compact worn solar rig. A-pose export; lowered-arm review pose only. See the 2026-09-26 checkpoint above. |
