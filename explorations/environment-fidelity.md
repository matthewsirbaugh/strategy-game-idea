# Environment fidelity: real walls, real ground

- Feeds: [environment-art.md](environment-art.md), [wall-occlusion.md](wall-occlusion.md)
- Style: [environment-style-study.md](environment-style-study.md) (2026-09-29) says what the
  surfaces should look like; where the two disagree, it is newer.
- Status: open
- Next action: Bryson answers the questions at the bottom. Nothing gets built until then.

## The question

How to push the environment's fidelity as far as it can go in Godot: walls with contours, edges
and trims instead of cubes, a ground that reads as real asphalt with potholes, and so on. Bryson,
2026-09-28: ghosting is "much better. Still not perfect, but I can't tell if that's because of the
effect, or because our architecture is all made of cubes." He asked for research on the best ways
to do it, especially in Godot, before any building.

## Constraints this inherits

- Rules live on a grid of 1.5 m tiles; walls are whole tiles. Whatever the art does, a player
  must still read exactly which tiles are walls (wall-occlusion.md).
- Every surface has to take the fog (darkened where unseen) and the ghosting (dithered when in
  the team's way). Both live in our own shaders today.
- A free camera that zooms to 3 m, so detail shows up close as well as far.
- The look: gritty cyberpunk anime, Edgerunners (DESIGN.md). Characters are cel-shaded Meshy
  models. Current models and textures are alpha placeholder art.
- The goal for the exterior is the establishing shot 0A: night, wet street, floodlights, neon.
- Tools here: Godot 4.7 (Forward+ renderer), Blender 5.2 headless plus the Blender MCP with Poly
  Haven built in, Meshy (2,465 credits). Target platforms are still open (AGENTS.md).

## Why it looks like cubes today (Claude)

- Each wall is one box with one texture: no bevels, no cap profile, no base, no seams, no
  variation from tile to tile.
- Floor tiles are separate boxes with gaps, so the ground reads as a checkerboard, not a surface.
- The textures are color only: no normal, roughness or height maps, so nothing catches light.
- The light is one flat sun and ambient, and the characters' toon shader ignores scene lights.
  0A is lit by floodlights and neon on wet ground; we have none of that.
- No decals: no cracks, stains, puddles, road paint or graffiti.

## How it's usually done

### Structure: a modular kit

- The industry standard for grid games is a **modular kit**: straight wall, outer and inner
  corner, end, T-junction, pillar, door and window frames, all built to the grid with shared
  pivots so they snap together. Seams hide at pillars, trims and signage, never in the middle
  of a flat wall. One **trim sheet** texture is shared across pieces for consistency.
- **XCOM 2** builds maps from "plots" (street networks) with sockets for pre-built modular
  buildings, "parcels", in small, medium and large sizes. It authored cover props to sit inside
  80 of a tile's 96 units, so props never touch tile edges.
- **Choosing the piece** for each wall is autotiling: look at a wall's neighbors and pick end,
  straight, corner, T or cross, with a rotation. The "dual grid" or marching-squares trick needs
  only 16 pieces to cover every corner case, against 47 for the classic neighbor bitmask.
- **In Godot** the native tool is GridMap with a MeshLibrary: pieces painted onto a 3D grid in
  the editor. Community add-ons (AutoGrid, a GridMap autotile extension) add autotiling. GridMap
  is also a ready-made map editor, which connects to the map-editor row on the board.

### Surfaces: full texture sets

- Real-looking ground and walls use **PBR sets**: color plus normal, roughness and height maps.
  Poly Haven and ambientCG give them away under CC0; Poly Haven has several asphalts (worn,
  cracked, coarse) and concrete pavers. Our Blender MCP can pull from Poly Haven directly.
- **Depth without geometry**: Godot's standard material does parallax from a height map ("deep
  parallax", with self-shadowing), which fakes cracks and shallow potholes. It needs UV-mapped
  meshes; our current walls use a triplanar world-space shader, so our own shader would need a
  parallax step or the kit pieces need UVs.
- **Terrain3D** is the leading Godot terrain plugin: sculpting, holes, 32 texture sets, painted
  wetness. Built for open landscapes; our ground is flat city paving on a grid, so it's likely
  more than we need.

### Detail: decals

- Godot's **Decal** node projects color, normal and roughness onto whatever it covers: cracks,
  pothole rims, stains, road paint, hazard stripes, graffiti, slogans. A normal-and-roughness-
  only decal makes a wet puddle. Keep them thin for performance.
- **Catch**: decals can't run custom shaders. Where a decal lands, our fog darkening (done in
  the surface shader) may not apply. That needs a test; the fix is to move the fog darkening out
  of the surface color into the lighting or a post-process.

### Lighting: the biggest single lever

- 0A's mood is lighting: floodlights, neon glow, light pooling on a wet street. In Godot's
  Forward+ renderer: spot and omni lights with shadows, emissive neon, **screen-space
  reflections** on wet ground (expensive, so only on floors), **volumetric fog** for light beams,
  and **SDFGI** for bounce light. All available to us.
- Our toon shader draws characters with a fixed light. Standard Godot toon shading uses the
  scene's lights with banding instead, so characters would pick up the floodlights and neon too.
- Cel-shaded styles still use normal maps on environments; the banding just keeps the result
  graphic. Edgerunners itself pairs flat-shaded characters with dense, painted, neon-lit sets.

## Ready-made: plugins, assets and tools

Bryson, 2026-09-28: "Look into plugins, downloadable assets, anything that's easy to get that saves
us work as long as it is of really high quality, or the highest quality we can either find,
generate, or create."

Two facts shape everything here. First, almost every asset pack is made for Unity or Unreal, but
ships as GLB or FBX, which Godot imports; its materials get rebuilt anyway, because every surface
in our game has to run our shaders (toon, ink, fog, ghosting). That's also what unifies assets
from different sources. Second, Claude has not opened any paid pack; quality below is judged from
listings and descriptions, and buying is Bryson's call.

### Godot plugins

| Plugin | Does | Quality and fit |
|---|---|---|
| GridMap autotile add-ons (AutoGrid, GridMap autotile GDExtension) | Pick wall pieces by neighbor automatically in Godot's GridMap | Small community projects; the idea matters more than the add-on |
| func_godot with TrenchBroom | Build levels in TrenchBroom, a mature free Quake-style editor, and import them | Proven and well documented. Freeform brushes, not grid tiles, so our rules layer would need mapping |
| Cyclops, HammerForge, Duckboard, Roommate | Brush or room building inside the Godot editor | Newer and less proven; Roommate targets indoor rooms |
| Terrain3D | Sculpted terrain with holes, 32 texture sets, painted wetness | The best terrain system for Godot. Built for landscapes; our ground is flat paving |
| ProtonScatter | Scatters clutter by rules | Mature; useful later for litter and debris |
| Godot Rainy Weather Shader Pack (itch, paid) | Wet surfaces, puddles, rain, mist, made in Godot 4.6 | Exactly 0A's wet street on paper; unverified |
| TCA Weather System (GitHub, free) | Weather with a wetness shader | Unverified |

The level editors also feed the map-editor row on the board: GridMap is a grid-native editor that
ships with Godot, and TrenchBroom is the most proven external one.

### Materials

| Source | What | License | Quality |
|---|---|---|---|
| Poly Haven | Photoscanned asphalts, concretes, pavers; color, normal, roughness and height, up to 16K | CC0: anything goes | Top tier among free sources; our Blender MCP pulls from it directly |
| ambientCG | The same kind of sets | CC0 | High |
| Fab Megascans | Industry-standard photoscans; a free subset since 2025 | Fab Standard License allows any engine | The highest quality there is |
| Material Maker | Free procedural material editor, built on Godot; an open counterpart to Substance Designer | Free, open source | Good for our own grungy concrete and trim textures |
| Materialize | Makes normal and height maps from one image | Free | Would give our painted Astra textures real depth |

### Models and kits

| Pack | What | Price and license | Fit |
|---|---|---|---|
| 3DT Stylized Cyberpunk Downtown (Superhive, Cubebrush) | 190 modular pieces: buildings, roads, doors, windows, signs, pipes, vending machines, lamps; 2K stylized PBR materials and decal trim sheets; GLB and FBX | $14 for one commercial project, $25 unlimited | The closest match found: stylized, cyberpunk, modular, game-ready |
| Modular Stylized Cyberpunk Street (Unity, Fab, ArtStation) | A modular street kit | Paid | Similar; less information |
| High Rise cyberpunk kitbash (Superhive) | Hero buildings and facade parts | Paid | For the tower and backdrops |
| Anime Tokyo, Idyllic Anime Japan and similar (Unity store) | Anime-styled city kits | Paid; non-restricted Unity assets may be used in other engines | Anime look, but daytime Japan rather than gritty cyberpunk; shaders need rebuilding |
| Poly Haven models | Photoscanned street props: concrete road barriers, street lamp, utility box, cones | CC0 | High, but photoreal |
| Buildify (Blender) | Free geometry-nodes building generator: facades, floors, roofs from a modular kit | Free | For the tower and the dock building's facades |

### Generating and making our own

- **Blender by script** (Claude): exact-size kit pieces with bevels, caps and panel seams. The only
  way to guarantee pieces fit our 1.5 m grid and each other.
- **Meshy** (2,465 credits): custom props that no pack has, like the terminal-adjacent gear and
  corporate furniture.
- **Astra**: concept, facade paintings, signage and slogans in our house style.

## Candidates

For each layer, how we'd do it:

| Layer | Recommended | Alternatives |
|---|---|---|
| Structure | Our own wall kit, built in Blender by script to fit the grid exactly, dressed with trims, doors, windows, pipes and signs from the 3DT Cyberpunk Downtown pack. Pieces chosen by autotiling from the map's text layout, so the layout and a future map editor keep working. Facades for the tower and dock building from Buildify with the pack's parts | Use the pack's walls as they are, if they happen to fit 1.5 m; GridMap as the level format |
| Surfaces | Poly Haven, ambientCG or free Megascans asphalt, concrete and paver sets, graded toward our palette, on one continuous ground instead of gapped tiles | Our Astra textures with depth from Materialize; Material Maker for custom grunge |
| Detail | Decals from the pack's trim sheets plus our own (cracks, potholes, puddles, road paint, stripes, graffiti, slogans), after fixing the fog so it covers them. Props from the pack and Poly Haven; Meshy for anything missing | Modeled potholes |
| Lighting | Night like 0A: floodlights as real spot lights, neon that lights its surroundings, a wet street with reflections (our own shader, or the Rainy Weather pack if it holds up), a toon shader that takes scene lights | Keep the flat light and put the effort into shapes and textures |

Claude's recommendation for the order, biggest change for the effort first:

1. **Lighting.** No new assets, and it changes everything on screen.
2. **Surfaces.** One continuous ground with real texture sets.
3. **Structure.** The wall kit and autotiling.
4. **Detail.** Decals and small props.

And to test it small first, per AGENTS.md: do all four on one **test patch**, the street entrance
(service door, access panel, booth and gate), judge it up close and far, then roll it out.

## Questions for Bryson

1. **How photographic?** Poly Haven textures are photos: they look real but pull away from a
   painted anime style unless graded hard. The other way is painted textures, ours from Astra,
   with depth maps generated from them. Or a mix: photo ground, painted signage.
   **Answered 2026-09-29 (Bryson): stylized, not photographic.** See
   [environment-style-study.md](environment-style-study.md).
2. **Night and wet, like 0A?** It's the biggest lighting win and matches the reference. It also
   decides a lot of the texture work.
3. **Test patch first**, the street entrance, before the whole map?
4. **Performance budget.** Reflections, volumetric fog and bounce light cost GPU. Target
   platforms are still open; is this Mac the bar for now?
5. **Potholes**: cosmetic only, or should rough ground matter to the rules later?
6. **Buying assets.** The strongest find is the 3DT Stylized Cyberpunk Downtown pack, $14 for one
   commercial project or $25 unlimited. Want it? The Rainy Weather shader pack is the other paid
   candidate. Purchases are yours to make; Claude can't buy.

## Findings

### 2026-09-30 — First environment pass on the exterior map (Claude; rendered, not played)

Built to [the style study](environment-style-study.md), across the whole exterior map. The
changes are in `game/art/shaders/world.gdshader`, `game/battle/level_view.gd` and
`game/battle/battle.tscn`.

- **Surfaces.** The photo textures are flattened toward their average color.
  - Walls: darker at the base and lighter at the top, with a dark band at the foot and thin
    seam lines every 1.5 m.
  - Every tile shifts its texture, and slow large-scale noise varies the tone, so nothing
    repeats evenly.
- **Ground.** One continuous surface, with no gaps and no checkerboard. The floor seams are
  drawn as faint light joints, so the grid still reads in the dark. Outdoors the ground is
  wet, with puddles that reflect.
- **Wall kit.**
  - Every wall: a darker plinth and a lighter cap that overhangs.
  - Perimeter walls: orange hazard stripes on a band at the foot, like 0A.
  - Buildings: a second clay neon line at storefront height.
- **Lights.**
  - A wide spotlight with shadows under each floodlight pole.
  - Clay neon light spilling off every other open wall face.
  - Dim cool moonlight and indigo ambient light.
  - Screen-space reflections on the wet ground.
  - Light distance haze (called haze, not fog, which means fog of war).
- **Rain.** Particle streaks over the map (`RAIN` in `level_view.gd` switches it off).
- **Checked:**
  - Rendered in the cloud container with Godot 4.7 on software Vulkan, from 5 camera views,
    with fog of war on and off. Tuned until the yard outside vision read as well as before.
  - Both headless test suites pass.
  - Not played, and the frame rate isn't known: software rendering says nothing about
    Bryson's Mac.
- **Known gaps:**
  - Characters and props still use the fixed-light toon shader, so they don't pick up the
    new lights. That's the open cel-shading question.
  - The wall faces still show some of the photo texture's drips.
  - The caps read flat and a little purple under the moonlight.
  - No neon signs, slogans or road markings yet.

### 2026-09-28 — Research (Claude)

The sections above. Sources:

- Modular kits: [World of Level Design, Modular Environment Design 101](https://www.worldofleveldesign.com/categories/game_environments_design/modular-environment-design-101.php),
  [Polycount wiki, Modular environments](http://wiki.polycount.com/wiki/Modular_environments),
  [Skyrim's modular approach (Game Developer)](https://www.gamedeveloper.com/design/skyrim-s-modular-approach-to-level-design)
- XCOM 2: [Plot and Parcel, GDC 2018 (slides)](https://media.gdcvault.com/gdc2018/presentations/Hess_Brian_PlotAndParcel.pdf)
- Autotiling: [Red Blob Games, Autotiling](https://www.redblobgames.com/articles/autotile/claude/),
  [Boris the Brave, Quarter-tile autotiling](https://www.boristhebrave.com/2023/05/31/quarter-tile-autotiling/),
  [Dual tilemap autotiling (Excalibur)](https://excaliburjs.com/blog/Dual%20Tilemap%20Autotiling%20Technique/)
- Godot GridMap: [Using GridMaps (Godot docs)](https://docs.godotengine.org/en/4.3/tutorials/3d/using_gridmaps.html),
  [AutoGrid](https://github.com/XLIVE99/AutoGrid),
  [GridMap autotile GDExtension](https://github.com/8f00ff/gdextension_gridmap_autotile)
- Decals: [Using decals (Godot docs)](https://docs.godotengine.org/en/stable/tutorials/3d/using_decals.html),
  [Decal class (Godot docs)](https://docs.godotengine.org/en/stable/classes/class_decal.html)
- Parallax: [Deep parallax rework (Godot PR 97646)](https://github.com/godotengine/godot/pull/97646)
- Terrain: [Terrain3D](https://github.com/TokisanGames/Terrain3D)
- Textures: [Poly Haven asphalt](https://polyhaven.com/textures/asphalt),
  [Asphalt 04](https://polyhaven.com/a/asphalt_04),
  [Concrete pavement](https://polyhaven.com/a/concrete_pavement)
- Lighting: [Environment and post-processing (Godot docs)](https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html),
  [Volumetric fog (Godot docs)](https://docs.godotengine.org/en/stable/tutorials/3d/volumetric_fog.html),
  [SDFGI announcement](https://godotengine.org/article/godot-40-gets-sdf-based-real-time-global-illumination/)
- Toon shading: [Toon shading, how it works (Moonjump)](https://moonjump.com/game-dev-mechanics-toon-shading-cel-shading-how-it-works/)

Ready-made (second pass, same day):

- Plugin lists: [awesome-godot](https://github.com/godotengine/awesome-godot),
  [Best Godot plugins (Vagon)](https://vagon.io/blog/best-plugins-for-godot)
- Level editors: [func_godot map editor setup](https://func-godot.github.io/func_godot_docs/FuncGodot%20Manual/pages/guide_map_editor_config.html),
  [TrenchBroom (Level Design Book)](https://book.leveldesignbook.com/appendix/tools/trenchbroom),
  [HammerForge](https://github.com/saworbit/hammerforge), [Duckboard](https://github.com/graphnode/duckboard)
- Weather: [Godot Rainy Weather Shader Pack](https://gameidea-studio.itch.io/godot-rainy-weather-shader-pack),
  [TCA Weather System](https://github.com/kS222138/TCA_Weather_System)
- Licenses: [Fab launch and Standard License](https://www.unrealengine.com/en-US/blog/fab-epics-new-unified-content-marketplace-launches-today),
  [Megascans after 2024 (80.lv)](https://80.lv/articles/megascans-no-longer-free-after-2024),
  [Unity assets in other engines (GameFromScratch)](https://gamefromscratch.com/using-asset-store-assets-in-other-engines-is-it-legal/),
  [Poly Haven license](https://polyhaven.com/license)
- Materials: [Material Maker 1.4](https://www.cgchannel.com/2025/10/material-maker-1-4/),
  [Materialize guide](https://yelzkizi.org/materialize-pbr-texture-tool-7-powerful-tips-guide/)
- Kits: [3DT Stylized Cyberpunk Downtown (Superhive)](https://superhivemarket.com/products/stylized-cyberpunk-downtown-modular-kitbash-pack-for-blender--game-design--3d-asset-pack),
  [Modular Stylized Cyberpunk Street (Fab)](https://www.fab.com/listings/1577ab5b-ee19-430b-a02b-3524dc6f157d),
  [High Rise kitbash (Superhive)](https://superhivemarket.com/products/cyberpunk-high-rise---3d-kitbash-pack),
  [Anime Tokyo (Unity)](https://assetstore.unity.com/packages/3d/environments/urban/anime-tokyo-japanese-city-258316),
  [Poly Haven concrete road barrier (BlenderKit)](https://www.blenderkit.com/asset-gallery-detail/1da29004-f3c0-4bc7-a675-fd6e500c2aa7/),
  [Buildify (CG Channel)](https://www.cgchannel.com/2022/07/download-free-blender-3d-building-generator-buildify/)
