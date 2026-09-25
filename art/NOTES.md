# Priority 1 art review

Prototype interpretations of `astra-brief.md`; creative approval remains with Bryson. Models are exported for review, not installed into battle visuals.

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
| `net_door` | 1,616 | 1.000 × 0.452 × 2.540 | open | No textures. Clear opening 2.4 m; lintel reaches 2.54 m. open slides 0.82 m into the adjacent wall; recolor status_ring in game. |
| `net_turret` | 3,576 | 0.720 × 0.874 × 0.899 | offline | No textures. active/offline clips extend or retract the emitter and slump the head. Set status_ring to non-emissive #4A4F57 for offline. |
| `kit_exit_hatch` | 805 | 2.000 × 2.009 × 2.458 | static | No textures. 2×2 extraction vignette: six roofward steps, open hatch and hand-painted arrow. Layout is a proposal for review. |
| `prop_server_rack` | 1,816 | 0.720 × 0.705 × 2.000 | static | No textures. Warm activity LEDs only; deliberately no ownership ring because this rack is not interactive. |
| `prop_cable_tray` | 1,104 | 0.325 × 1.000 × 0.124 | static | No textures. One-metre segment; local Z=0 is its mounting surface. Rotate the parent to hang overhead. |
| `prop_salvage_crate` | 1,600 | 0.835 × 0.749 × 0.590 | static | No textures. Open crate of salvaged battery, conduit and cloth-wrapped cable. |
| `prop_cargo_bike` | 4,056 | 0.640 × 2.010 × 1.073 | static | No textures. Front-facing −Y; working cargo-bike proportions, boxed solar-install supplies, and a parked kickstand. |
