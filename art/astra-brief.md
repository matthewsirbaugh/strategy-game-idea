# Art brief 01: the first 3D pass

For Astra. Written by Claude on 2026-09-24 at Bryson's request.

Bryson directs the art. His direction for this pass: **stylized but realistic**, and **solarpunk meets
a corporate AI future full of advertisements**. Everything more specific below (the characters,
the set pieces, the palette, the placeholder brands and ad copy) is Claude's proposal for him to
change. Working agreements for any agent in this repo are in `AGENTS.md`.

## 0. How to use this brief

- The goal is prototype art: more than a placeholder, less than a final asset. It's for testing the
  look inside the game. Consistency and readability beat detail.
- Work in priority order. **Stop after Priority 1** (the reference pair and the battle kit) and
  hand back previews for Bryson's review before starting Priority 2.
- Every asset ships as a Python build script, a `.blend`, a `.glb` and two preview renders
  (section 7 has the details).
- Where this brief is ambiguous, choose whatever reads best from the game camera and write the
  choice down in your handoff notes.

## 1. The look

Near-future America. AI arrived faster than society could adapt. Basic needs are met, but the
best of everything is paywalled, and two AI corporations own the network infrastructure. Two
visual languages share every street:

| | The Commons (solarpunk) | The Company (corporate AI) |
|---|---|---|
| What it is | What people built and fixed for themselves | What the two AI corporations own |
| Shapes | Hand-made, slightly irregular, curved (art nouveau stems, arches) | Seamless, monolithic, rounded rectangles, perfect circles |
| Materials | Timber, rammed earth, brick, canvas, patched metal, glass, plants everywhere | Bone-white composite, graphite, frosted and dark glass, light seams |
| Condition | Lived-in, repaired, layered, mismatched | Pristine, except where the Commons has touched it (stickers, vines, repairs) |
| Light | Warm LEDs, string lights, sunlight, hand-bent neon | Cold light seams, status rings, AR advertisements |

Four rules:

1. **Two vocabularies on one street.** Every scene mixes both, and the Company is bolted onto the
   Commons: a camera clamped to a community lamppost, an ad projector hung over a mural, an access
   point conduit cut through a planter.
2. **If it's hackable, it's Company.** All network hardware (access points, cameras, door locks,
   turrets, data caches, ad columns, autonomous cars) uses the Company vocabulary and carries a
   **status light ring that can be seen from above**. The ring color shows who owns it: Corp A cyan,
   Corp B magenta, breached by the player green, offline dark. This is how the art teaches the
   network mechanic, so it matters more than any other detail.
3. **Stylized but realistic.** Keep real proportions and believable materials, but simplify the
   shapes: big clean forms, a bevel on every hard edge, flat or gently graded colors, and no noisy
   photo textures. Part of the stylization will come from the game's shaders, so keep materials
   simple and honest. Touchstones: *Arcane* (painterly materials on realistic forms), *Overwatch*
   (proportion and silhouette discipline), *Valorant* (clean flat materials that read at a
   distance), *Watch Dogs 2* (a tech city with AR overlays), Studio Ghibli's lived-in greenery.
4. **Readable from the tactics camera.** The battle camera sits about 34 m away, pitched 50° down,
   with a 30° lens. Seen from that angle, a 1.7 m person on a 900-pixel-tall screen is only about
   **55 pixels** tall at the default zoom (measured in Blender), and the face is a handful of
   pixels. Players can zoom in to roughly three times that. Design for silhouette and three or
   four big color blocks. Anything smaller than about 10 cm disappears. Status rings, glows and
   key colors belong on **top surfaces**, because the camera looks down.

## 2. Palette

| Group | Name | Hex |
|---|---|---|
| Commons | Cream plaster | `#EFE6D2` |
| Commons | Ochre | `#D9A441` |
| Commons | Terracotta | `#C8643C` |
| Commons | Brick | `#A4553A` |
| Commons | Warm timber | `#9A6B43` |
| Commons | Sage | `#7FA37A` |
| Commons | Moss | `#4F7A4A` |
| Commons | Patina teal | `#3E8C84` |
| Commons | Deep teal (webbing, straps) | `#2F5F5C` |
| Company | Bone white | `#F2F1EC` |
| Company | Pale concrete | `#D9D6CE` |
| Company | Graphite | `#2B2E33` |
| Company | Dark glass | `#1A2230` |
| Solar cells | Cell blue-violet / bus-bar gold | `#2A3570` / `#D9B24A` |
| Status ring | Corp A owns it | `#27D3F5` |
| Status ring | Corp B owns it | `#E83FB8` |
| Status ring | Breached by the player | `#58F08A` |
| Status ring | Offline (not emissive) | `#4A4F57` |
| Light | Commons warm light | `#FFC27A` |
| Light | Sunlight | `#FFE7C2` |

## 3. Technical specs

| Topic | Spec |
|---|---|
| Blender | 5.2 LTS is installed on Bryson's Mac. It runs headless Python scripts and has the glTF exporter (checked 2026-09-24) |
| Scale | 1 Blender unit = 1 m. The battle grid is 1 m tiles |
| Heights | Floor top at 0. Full walls 2.4 m (the game will cut away walls between the camera and units). Half cover 0.9 m. Door openings 2.4 m. Backdrop stories 3 m |
| Facing | The front of every asset faces Blender's −Y (Numpad 1 front view shows the face) |
| Origin | Bottom center of the footprint. For characters, the ground point between the feet. Grid pieces fill whole tiles |
| Transforms | Apply scale and rotation before export. No negative scales |
| Materials | Principled BSDF only: base color, metallic, roughness, normal, emission. **glTF drops procedural shader nodes**, so bake them to images or keep materials flat |
| Material names | Name them by role so the game can swap them: `status_ring` (recolored by owner and state), `hologram_*` (the game applies its own shader), `glass`, `emissive_*`, `ad_screen` |
| Textures | PNG. 1024 px usually, 2048 px only for the hero character. Many props need no image texture at all |
| Export | glTF 2.0 binary (`.glb`), +Y up (the default), modifiers applied, only the asset itself. Animations as named actions (`idle`, `walk`, …) |
| Naming | snake_case with prefixes: `char_`, `ai_`, `net_` (hackable network hardware), `kit_` (grid pieces), `prop_`, `sign_`, `ad_`, `bld_` |

Poly budgets for this pass:

| Asset | Triangles | Textures |
|---|---|---|
| Human Operator, with clothes and hair | 15–25k | one 2048 or two 1024 sets |
| Backpack rig | 3–6k | 1024, or shared with the character |
| AI avatar | up to 5k | one 1024 wing texture with alpha |
| Weapon, small prop | 300–2k | none or 512 |
| Network hardware | 1–4k | none (flat materials) |
| Kit tile or wall piece | 50–800 | none or a shared trim sheet |
| Street prop (lamp, bench, sign) | 1–5k | none or 512 |
| Autonomous car | 5–10k | 1024 |
| Backdrop building | 10–40k | a 1024–2048 trim sheet |

File layout (create the folders as needed):

```
art/scripts/<asset>.py            build script: builds, renders previews, exports
art/source/<asset>.blend          saved scene (kept outside game/ so Godot doesn't import it)
art/previews/<asset>_front.png    close three-quarter view
art/previews/<asset>_game.png     the game camera view, next to a 1.7 m reference
game/art/<category>/<asset>.glb   what the game loads
art/NOTES.md                      tri counts, texture sizes, choices made
art/LICENSES.md                   every third-party asset and its license
```

## 4. Characters: the reference pair

One Operator and her AI partner, designed as the style reference for every character to come.
The titles are working titles only; names, backstory and personality are Bryson's. Gameplay-wise
she matches the MVP's Alpha: the fast scout whose AI drops Probes.

### 4.1 The Installer (human Operator)

She's a rooftop solar installer, one of the jobs robots still can't do, because rooftops are
irregular. She knows every roof hatch, ledge and cable run in the district, which is why she
scouts. She's in her late twenties, and her gear is work gear, repurposed.

- **Build:** 1.68 m, lean and wiry, with a climber's shoulders and forearms. About 7.5 heads tall;
  scale the head and hands up about 7% so they read at game distance.
- **Face:** warm medium-brown skin, sun-darkened across the cheekbones, a scatter of freckles.
  Strong straight brows, amber-brown eyes, a small healed scar through the left eyebrow. Resting
  expression: focused, a little amused.
- **Hair:** black, in a tight low bun, mostly covered by a faded terracotta bandana tied at the
  back. It's sun protection, and it keeps the hair a simple mass that models well.
- **Eyewear:** salvaged corporate AR glasses with a thin graphite frame and faintly cyan lenses.
  One lens is cracked and repaired with a gold seam, kintsugi style. (Story hook for Bryson: this
  is how she sees her AI, and it filters the ads out of her view.)
- **Jacket:** short, hip-length heavy canvas in faded ochre, sleeves rolled to the elbow, collar
  up. Three hand-stitched patches: a sunflower on the left shoulder, a cream square with a
  hand-drawn sun on the chest, and a mismatched sage patch on the right elbow.
- **Underneath:** a fitted sage top.
- **Harness:** a climbing harness in deep teal webbing, waist belt and leg loops, with two brass
  carabiners. A coiled orange-red rope, about 20 cm across, is clipped at the right hip. This is a
  silhouette key.
- **Tool belt** over the harness: small pouches, a stubby pry bar, a roll of cable ties.
- **Trousers:** charcoal work trousers with reinforced knees and tan knee pads.
- **Shoes:** light, worn approach shoes in grey with orange laces.
- **Gloves:** fingerless tan leather work gloves.
- **Weapon, the rivet driver:** her solar-install rivet gun, modified into a short-range sidearm.
  It's chunky, about 28 cm long, with a faded safety-orange body, a battery pack under the grip,
  and black tape around the barrel. It's holstered on the right thigh when she isn't aiming.
- **Backpack:** her AI's physical home (4.3).
- **Silhouette check at 55 pixels:** the bandana head, the angled solar flap above the shoulders,
  the rope coil at the hip, and the ochre jacket block. If those four don't read from the game
  camera, simplify until they do.
- **Modeling pose:** A-pose, arms about 45° down, feet shoulder-width apart, facing −Y.
- **Animations for later:** alert idle, walk, run, crouch-walk (stealth), aim and fire, hit react,
  downed (kneel, then collapse), climb up.

### 4.2 The Moth (her AI partner)

In this world a partner AI eventually chooses its own shape. Hers chose a moth: drawn to light,
most alive at night, and patterned like the solar panels she installs. It is an AR projection
from her backpack, so only people wearing lenses can see it, and the player sees it because we
see what she sees. It never touches anything. It hovers near her right shoulder.

- **Size and placement:** 45 cm wingspan, 18 cm body. It floats about 1.9 m off the ground,
  roughly 0.45 m to the right of her head and slightly behind.
- **Body:** realistic moth anatomy, stylized. A plump, fuzzy thorax and abdomen in cream fading to
  warm amber (`#E8A94A`) toward the tail, with a fluffy ruff at the collar.
- **Eyes:** two large, dark indigo compound eyes (`#1C1F3A`), each with one soft highlight. The
  highlight's shape is its expression.
- **Antennae:** two broad, feathered antennae swept back, like a luna or silk moth's, in gold.
- **Wings:** four wings shaped like a silk moth's, with gently hooked tips on the forewings. The
  membrane is patterned as photovoltaic cells: a grid of rounded-square cells in solar blue-violet
  separated by thin gold bus-bar lines, bending to follow the wing veins. The edges fade to
  transparent, and there's a soft warm glow at the wing roots. Each hindwing has an eyespot drawn
  as a small sun: an amber disc with cream rays.
- **Legs:** tiny and tucked, barely visible.
- **Materials:** it's light, not matter. Give it plain materials named `hologram_body` and
  `hologram_wing`; the game adds the hologram look (emission, fresnel rim, scanlines, and a glitch
  when the tether is stretched). Paint the wing pattern as a 1024 px texture with alpha.
- **How to build it:** almost entirely procedural. The body is three overlapping stretched spheres
  plus a ruff of short cards. The wings are flat two-sided planes cut to shape, carrying the
  texture. The antennae are feathered cards. Keep it under 5k triangles.
- **Rig:** bones for each wing, each antenna, and the body.
- **Animations:**
  - `hover_idle`: slow wingbeats around 1.2 Hz with moth-like pauses, and a gentle bob.
  - `fly`: faster beats, body pitched forward.
  - `scan`: wings open flat and the cells light up in a sweep from root to tip.
  - `deploy_probe`: curls its abdomen and releases a spore.
  - `strain`: jitters. Used when the tether is stretched.
- **The probe, or "sensor spore"** (`net_probe_spore`, 8 cm): a seed-like amber capsule with a
  crown of fine white filaments like a dandelion parachute and a tiny glowing tip. In the
  physical world it's a real device that clings magnetically to the hardware it watches.

### 4.3 The backpack rig (the AI's body)

This is real hardware, and the AI runs on it.

- **Size:** 42 × 30 × 16 cm on its frame; 55 cm tall with the solar flap open.
- **Core:** a salvaged Corp A delivery-drone battery module. It has a rounded bone-white shell
  with a cyan trim line. The corporate logo has been sanded off, leaving a ghost mark, and a
  small moth is hand-painted over it.
- **Frame:** hand-bent aluminum tubing with visible welds, padded deep-teal shoulder straps, and a
  chest strap.
- **Solar flap:** a hinged, two-panel folding solar panel on top (each panel 30 × 22 cm), tilted
  back about 30° when open. This is the key silhouette shape. Blue-violet cells with gold lines,
  matching the Moth's wings.
- **Cooling:** aluminum heat-sink fins down the left side and a small fan grille.
- **Cables:** two bundles wrapped in terracotta cloth tape. One runs to her glasses, one to a
  wrist port.
- **Heart light:** a round amber light, 4 cm across, on the back. It pulses with the AI. Name its
  material `status_heart`.
- **Antenna:** a stubby flexible antenna with a faded ribbon tied to it.
- **Probe holders:** four glass capsule holders on the right shoulder strap, carrying spores.

## 5. Set pieces

### 5.1 Priority 1: the battle kit

The MVP battle is set inside a Company data-center annex that the Commons has grown around. These
pieces let the whole MVP map be dressed. Grid footprints are in 1 m tiles.

| Asset | Footprint, height | Description | States |
|---|---|---|---|
| `kit_floor_company` | 1×1, 0.2 m slab | Pale polished concrete with a faint terrazzo speckle. Variant with a thin inset light strip along one edge | — |
| `kit_floor_commons` | 1×1, 0.2 m slab | Reclaimed brick pavers in terracotta and cream, with moss in the joints | — |
| `kit_wall_company` | 1×1, 2.4 m | Bone-white panel wall on a graphite skirting, with a cyan light seam along the top edge. The top face is capped and clean, because the camera sees it | — |
| `kit_wall_commons` | 1×1, 2.4 m | Rammed earth in ochre and terracotta layers under a timber cap. Variant with moss and grass along the cap | — |
| `kit_wall_greenwash` | 1×1, 2.4 m | A Company wall behind a timber trellis of vines: the Company's "sustainability" facade | — |
| `kit_cover_planter` | 1×1 and 2×1, 0.9 m | The half-cover object: a timber-and-steel planter packed with herbs and tall grasses | — |
| `net_door` | 1×1 in a wall line, 2.4 m | A Company sliding security door: white panel, graphite frame, a horizontal slot window. A lock panel beside it carries the status ring, visible from above | closed, open (slid into the wall); ring by owner and state |
| `net_access_point` | 1×1, 1.1 m | A slim bone-white kiosk pillar (0.35 × 0.25 m, rounded), a graphite port panel, a status ring near the top plus a glowing cap on top, and a conduit running into the floor. Operators have to stand near it, so it must be unmistakable | ring by owner and state |
| `net_camera` | wall bracket, or a 2.2 m pole on 1×1 | A smooth white capsule housing with a dark glass lens and a small status ring around the lens, on an articulated arm. The MVP's cameras stand on a tile, so the pole variant comes first | ring by owner and state |
| `net_turret` | 1×1, 0.9 m | An automated security deterrent disguised as an appliance: a squat bone-white dome on a graphite base, with a horizontal slit holding a lens and a stubby emitter that rotates out | active (ring lit, emitter out); offline (ring dark, emitter retracted, slumped) |
| `net_data_cache` | 1×1, 2.0 m | A server monolith: a graphite slab with frosted-glass faces and vertical light seams that pulse. It's the prize, so make it the most beautiful Company object | seams by owner; secured (green) |
| `kit_exit_hatch` | 2×2 corner area | The extraction point: a stair hatch up to the roof, a hand-painted Commons arrow, and a string of warm lights. A hopeful, warm corner | — |
| `prop_server_rack` | 1×1, 2.0 m | Background racks (not interactive), so the room reads as a data center | — |
| `prop_cable_tray` | 1 m section | Overhead or floor cable tray, with cloth-taped Commons repairs | — |
| `prop_salvage_crate` | 1×1, 0.6 m | Timber crate of salvaged parts | — |
| `prop_cargo_bike` | 1×2 | A Commons cargo bike parked inside, with a crate on the front | — |

### 5.2 Priority 2: the street kit

| Asset | Size | Description |
|---|---|---|
| `prop_streetlamp_solar` | 4.5 m tall | A Commons lamp. The post is laminated timber that curves at the top like a plant stem. Its canopy is three leaf-shaped solar panels (blue-violet cells, gold lines), with a warm LED lantern hanging beneath and a small planter at the base. **Company retrofit variant:** a `net_camera` and a small access point clamped to the post with a steel band |
| `sign_neon_commons` | 1.2 × 0.6 m, wall-mounted | Hand-bent neon tubes (curves with bevel depth and emission) on a timber board: "REPAIR", a noodle-bowl icon, a sunflower. Warm amber, pink and mint |
| `ad_panel_ar` | e.g. 3 × 1.8 m | A Company AR advert: a borderless floating panel showing an emissive ad image (section 6) with faint scanlines, anchored to a small graphite projector nub (15 cm) on a wall or pole |
| `ad_column` | 3.5 m tall | A digital advertising column with a wraparound screen and a graphite cap carrying the status ring. The ad network is hackable |
| `kit_street_auto_lane` | 1×1 and 2×2 | Smooth dark asphalt with cyan guide lines for autonomous cars |
| `kit_street_commons` | 1×1 and 2×2 | Permeable pavers with grass in the joints, for bikes and people |
| `kit_street_curb`, `kit_street_median` | 1 m sections | A curb, and a planted median with a rain swale |
| `kit_street_crosswalk` | 2×2 | A crosswalk whose lines are projected light (emissive) |
| `prop_tram_shelter` | 4 × 1.5 m | Timber frame with a green sedum roof and solar glass panels; a Company AR ad on one side |
| `prop_bench_reclaimed` | 2 m | Reclaimed timber bench with a solar charging post |
| `prop_bike_rack` | 2 m | Bike rack, with two parked cargo bikes |
| `prop_auto_car` | 3.2 × 1.6 × 1.5 m | A Company autonomous pod car, and a hackable object: a smooth bone-white capsule on small wheels, a dark glass band, no driver's seat visible, and the status ring on the roof |
| `prop_drone_dock` | 1×1, 2.5 m | A Company delivery-drone locker tower with a drone perched on top |
| `prop_kiosk_basic` | 1×1, 2 m | The UBI "Basic Box" nutrition dispenser: a friendly white kiosk with a big smiling screen |
| `prop_community_garden` | 3×3 | Raised beds, a trellis arch with vines, a rain barrel, compost bins |
| `prop_solar_canopy` | 4×6 | A community solar canopy like a carport: timber posts, panels overhead |

### 5.3 Priority 3: backdrop buildings

These are seen at the map edges and aren't enterable yet. Build them from 3 × 3 m facade modules
so they can be recombined.

| Asset | Size | Description |
|---|---|---|
| `bld_commons_block` | 12 × 10 m footprint, 5 stories | Stepped terraces with gardens, timber balconies, solar shingles and a rooftop greenhouse, laundry lines, mismatched window frames, and a mural on the side wall. Ground-floor shops (a repair café, a noodle bar) with fabric awnings and neon signs |
| `bld_company_tower` | proxy 60 m tall | A slim white-and-glass tower with a vertical ad ribbon and the corporate mark on its crown. Model only the lowest three stories in detail. Its ground floor is an "Experience Center": glass, with a sculptural logo |
| `bld_annex_facade` | matches the MVP map | The outside of the battle's data center: a windowless white box greenwashed with a vine trellis, a loading dock, an access point by the service door, and a Commons mural half covered by an AR ad |

## 6. Advertisements

The ads are the Company's voice. The brand names and copy here are placeholders for Bryson to
rename or rewrite. No real brands and no real people.

| Brand (placeholder) | Mark | Color | Tone |
|---|---|---|---|
| Corp A, working name "Halcyon" | A perfect circle with a small gap at one o'clock | Cyan | Calm, clinical, caring |
| Corp B, working name "Paragon" | Two stacked chevrons | Magenta | Aspirational, premium, loud |

Ads for `ad_panel_ar` textures, 1024 × 2048 portrait or 2048 × 1024 landscape:

1. **Halcyon Lifespan.** "Live the long version." A serene, ageless face in soft light, with fine
   print: "Premium tier. Eligibility applies."
2. **Paragon Basic Box.** "Basic, but make it delicious." A glossy nutrition box on bright
   magenta.
3. **Halcyon Assistant.** "It already knows what you need." A soft glowing orb on white, calm in
   an unsettling way.
4. **Paragon Work.** "Robots can't climb. You can. Tier 2 jobs near you." A silhouette on a
   rooftop, a wink at the Installer.
5. **Halcyon Security.** "This space is protected for your comfort." With a camera icon. Place it
   near cameras and access points.

Commons counter-graphics, hand-painted, for murals and stickers: a sunflower; "Repair café
Thursdays"; a small moth sticker (a quiet wink at the resistance); "Grow food, not ads".

To make them, build flat layouts in Blender from text objects and shapes and render them with an
orthographic camera, or use any 2D tool. Fonts must be free-licensed: Inter, Space Grotesk or IBM
Plex Sans (all SIL OFL). Bake in a subtle scanline and vignette.

## 7. How to make it: a free pipeline that AI can drive

### Principles

1. **Script everything.** Each asset is a Python build script run by headless Blender:
   `/Applications/Blender.app/Contents/MacOS/Blender --background --python art/scripts/<asset>.py`.
   The script builds the model, assigns materials, renders both previews and exports the `.glb`.
   That makes every asset reproducible, reviewable as a diff, and tweakable by any agent later,
   and nothing depends on clicking through a UI. This works on Bryson's Mac today.
2. **Model hard surfaces procedurally.** This is where AI is strong: primitives plus Bevel,
   Solidify, Array, Mirror and (sparingly) Boolean modifiers; curves with bevel depth for anything
   tubular (neon, cables, rope, lamp posts); Geometry Nodes to scatter grass, moss, vines and
   tiles. Keep a shared material-library script so the palette stays consistent.
3. **Don't sculpt organic shapes in code.** For humans, start from a parametric base or an
   image-to-3D generation, then add the hard-surface gear by script.
4. **Judge everything from the game camera.** Always render the `_game` preview next to a 1.7 m
   reference capsule. If it doesn't read there, it doesn't read in the game.

The game camera for previews:

```python
import bpy, math
from mathutils import Vector

def game_camera(target=(0.0, 0.0, 0.8), distance=34.0, pitch=50.0, yaw=45.0):
    # Matches the battle view: 50 degrees down, 45 degrees around, 30-degree vertical lens.
    data = bpy.data.cameras.new("game_cam")
    data.sensor_fit = 'VERTICAL'
    data.angle_y = math.radians(30.0)
    cam = bpy.data.objects.new("game_cam", data)
    bpy.context.scene.collection.objects.link(cam)
    p, y = math.radians(pitch), math.radians(yaw)
    offset = Vector((math.sin(y) * math.cos(p), -math.cos(y) * math.cos(p), math.sin(p)))
    cam.location = Vector(target) + offset * distance
    cam.rotation_euler = (Vector(target) - cam.location).to_track_quat('-Z', 'Y').to_euler()
    bpy.context.scene.camera = cam
    bpy.context.scene.render.resolution_x, bpy.context.scene.render.resolution_y = 1600, 900
    bpy.context.view_layer.update()
    return cam
```

At that distance a 1.7 m figure comes out about 55 pixels tall, which matches the game at its
default zoom (checked in Blender 5.2). For the `_front` preview,
move the camera in close (4 m for a character) and light it with a warm sun and a cool sky, or
with a Poly Haven HDRI.

### Tools by need

All free. License notes reflect what Claude knew as of mid-2026, so check the current terms
before anything ships.

| Need | Best free option | Notes |
|---|---|---|
| Props, kit pieces, buildings, lamps, signs | Blender plus Python, headless or through the Blender MCP | AI's strongest area |
| Stylized plants, moss, vines | Geometry Nodes scattering simple leaf cards; Poly Haven plant models | Poly Haven assets are CC0 |
| Human base mesh and skeleton | MPFB2 (MakeHuman for Blender), a free extension at extensions.blender.org | Not installed yet. Parametric age, build and proportions, with UVs and a game skeleton, and it can be scripted. Check each included asset's license (the base mesh is CC0) |
| Clothes and gear on the human | Hard-surface gear by script; simple cloth from a shrinkwrapped, solidified copy of the body; MPFB2's clothing library | |
| Quick organic shapes and details | Image-to-3D: TRELLIS (Microsoft, MIT license, free online demo), Hunyuan3D 2.x (Tencent, open weights and a free demo; its community license excludes some territories, so read it), Hyper3D Rodin (a free trial key is built into the Blender MCP, with a daily limit) | Good for statues, plants and odd props. Output is one dense mesh with baked textures: decimate it, fix the scale, and retopologize anything that has to animate |
| Concept images to feed image-to-3D | Bryson's ChatGPT image generation: orthographic front, side and back turnarounds on white | Start with an A-pose turnaround of the Installer |
| Rigging | Rigify (built into Blender), MPFB2's game skeleton, or Mixamo auto-rig | Mixamo is free but needs an Adobe account. Bryson has to sign in and upload himself; agents can't create accounts or sign in |
| Animation | Quaternius Universal Animation Library (CC0 humanoid idle, walk, run and more), Mixamo (Bryson's login), and simple loops keyframed by script (the Moth) | |
| Textures | Poly Haven and ambientCG (both CC0), procedural Blender materials baked to images, Material Maker (free) | |
| Cleanup and retopology | Blender's Decimate, QuadriFlow and Voxel remesh; Instant Meshes (free) | |
| 2D ad graphics | Blender text and shapes rendered orthographically; Krita or GIMP; OFL fonts | |

Avoid Sketchfab models without a clear CC0 or CC-BY license, and record attribution for every
CC-BY asset. Also avoid generator free tiers that attach attribution or non-commercial terms to
their output (check Meshy's and Tripo's current terms) unless Bryson accepts those terms. Every
third-party asset goes in `art/LICENSES.md`.

### Suggested route for this pass

1. Write `art/scripts/common.py` first: the palette as materials, the game camera, the preview
   lighting, the 1.7 m reference and the export call. Every asset script imports it.
2. Build the battle kit and the network hardware (5.1) by script. These are fast and teach the
   look.
3. Build the Moth, the spore and the backpack by script.
4. Build the Installer. Use MPFB2 if Bryson installs it. Otherwise, make a clean stylized
   mannequin with all her gear modeled by script (that's enough to judge silhouette and color),
   and generate the A-pose turnaround concept so a later pass can try image-to-3D.

### The Blender MCP

The server is configured in Bryson's Claude Code, but it only answers while Blender is open with
the addon connected: the BlenderMCP panel in the 3D view's sidebar, then Connect. It adds live
Python in the open scene, viewport screenshots, Poly Haven downloads, Sketchfab search (needs an
API key), and Hyper3D Rodin and Hunyuan3D generation. Headless scripts are still the better
default, because nothing depends on a live session.

### Gotchas

- glTF export drops procedural shader nodes, so bake them or keep materials flat.
- Set emission color and strength in Blender. The game may boost the glow.
- Keep glass and hologram surfaces on their own named materials; the game gives them its own
  shaders.
- Apply scale before export, and check against the 1.7 m reference.
- Status rings and emissive caps go on top faces. The camera looks down.
- Don't commit Blender's `.blend1` backup files.

## 8. Handoff checklist

For each finished asset:

- [ ] `art/scripts/<asset>.py` builds it from scratch, headless
- [ ] `art/source/<asset>.blend`
- [ ] `game/art/<category>/<asset>.glb` with transforms applied, origin at the base, facing −Y
- [ ] `art/previews/<asset>_front.png` (close three-quarter view, neutral grey, 1024 px) and
      `art/previews/<asset>_game.png` (game camera, next to the 1.7 m reference)
- [ ] Triangle count, texture sizes and any choices made, noted in `art/NOTES.md`
- [ ] Any third-party asset recorded in `art/LICENSES.md`

Stop after Priority 1 and wait for Bryson's review.
