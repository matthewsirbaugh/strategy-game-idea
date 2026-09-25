# Priority 1 art review

Prototype interpretations of `astra-brief.md`; creative approval remains with Bryson. Models are exported for review, not installed into battle visuals.

Rebuild one asset from the project root: `blender --background --python art/scripts/<asset>.py`. The asset collection exports; `PREVIEW_ONLY` contains the excluded studio and scale reference. Blender front is −Y; the standard glTF conversion makes that Godot +Z. All dimensions below are Blender X × Y × Z, in metres. Floor slabs end at Z=0.

| Asset | Exported triangles | Dimensions | Animation clips | Choices and limits |
|---|---:|---|---|---|
| `kit_floor_company` | 120 | 1.000 × 1.000 × 0.200 | static | No textures. Restrained geometric terrazzo; slab spans −0.2 to 0 m. |
| `kit_floor_company_light` | 132 | 1.000 × 1.000 × 0.203 | static | No textures. Fixed cyan architectural guide; not an ownership indicator. |
| `kit_floor_commons` | 600 | 1.000 × 1.000 × 0.207 | static | No textures. Twelve salvaged pavers with sparse moss; whole-tile footprint. |
| `kit_wall_company` | 308 | 1.000 × 1.000 × 2.400 | static | No textures. Solid capped 1 m wall block; fixed cyan seam is architectural. |
