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
