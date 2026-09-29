# Environment style study: stylized walls and ground

- Feeds: [environment-fidelity.md](environment-fidelity.md) (the technical how),
  [environment-art.md](environment-art.md), [art-pipeline.md](art-pipeline.md#house-style)
- Status: open
- Next action: Bryson picks how the reference frames arrive (decision 4); an agent checks the
  study against them. Then an implementing agent builds one test patch from this file.

Written for the agent that implements the environment pass. It says what the walls and ground
should look like and why, with the games that prove it. For tools, plugins and packs, read
environment-fidelity.md. Where the two disagree, this file is newer.

## The problem (Bryson, 2026-09-29)

"In anime games, you can still have a really nice, colorful, sharp aesthetic... High fidelity
doesn't mean photorealistic, it means more detailed, more cohesive, with better silhouettes.
The lights that we generated are great, as is the Van because it serves a purpose of blocking
view. But the walls are bad, they have a low resolution repeated texture that looks
amateurish, and the same is true of the ground, the walls on the building. We have some mixed
to great individual props, but the literal brick and mortar is very lacking... do it in a
stylized way that's cohesive with our character design and inspirations."

## What's wrong today

What the code does now, and why it reads badly. This is Claude's diagnosis; the research backs
it up.

- Every wall and floor is a box with one color-only texture, laid in world space by
  `game/art/shaders/world.gdshader`. Walls repeat every 2 m, asphalt every 4 m, and floors once
  per tile (`game/battle/level_view.gd`, `_world()`).
- The environment gets plain lighting and no ink outline. The characters get hard cel bands and
  an ink line. So the two are drawn in different languages. This is a cohesion problem, not a
  resolution problem.
- `T3-perimeter-wall.png` is photo grit: fine speckle at one frequency, near-black blotches on
  mid grey, and drips that start at the top of every repeat. That puts a new row of drips every
  2 m up a 2.8 m wall.
- At battle zoom a character is about 55 px for about 1.8 m, so roughly 30 px per metre, and a
  tile is about 45 px wide. The texture shrinks about 20 times on screen. Mipmapping turns the
  grit into grey mush, and the repeat grid is all that survives. More pixels of the same noise
  would not help.
- The target, `art/reference/environment-facility/0A-exterior-establishing.png`, gets its walls
  from structure:
  - a dark plinth with orange hazard stripes
  - a lighter cap with a bright top edge
  - panel joints
  - a few big stains
  - one slogan or logo per stretch of wall

  None of that needs a high-resolution texture.

## Principles

Each principle gives the rule, who does it, and what it means for us. How sure we are:
**sourced** means a talk or article said it (seen in search summaries, not opened; see
Sources). **Observed** means visible in 0A or our own files. **Frame** means visible in a
reference frame Bryson chose, in [art/reference/look/](../art/reference/look/README.md).
**Inferred** means the agents' judgment.

### 1. Big shapes carry the look; texture doesn't

- The rule: anything that must read at battle zoom is geometry, about 10 to 15 cm or larger.
  At 30 px per metre, 10 cm is 3 px and a 3 cm bevel is 1 px.
- Who does it:
  - 0A: plinth, cap, joints (observed).
  - Cyberpunk 2077's Japantown: a plain concrete barrier wall read entirely by a chunky
    chamfered cap and a red-painted base band (frame, `cp2077-japantown-barrier-wall.webp`).
  - Hi-Fi Rush's keywords were "Colorful, Sharp, Clean" (sourced).
  - The stylized cyberpunk breakdowns on 80.lv build chunky bevelled pieces with one trim
    sheet, not unique textures (sourced).
- For us: each wall piece gets the following, built in Blender by script:
  - a plinth of 15 to 20 cm
  - a cap of about 10 cm that overhangs by about 5 cm
  - a vertical groove of 5 to 8 cm at each 1.5 m tile seam
  - a pilaster or buttress every few tiles

  Every change of surface direction then catches its own cel band and, if Bryson wants it, an
  ink line. This is where "better silhouettes" comes from.
- Watch out: the outline shader, `ink_outline.gdshader`, pushes the model outward along its
  normals. On sharp box corners the normals split and the line breaks. Kit pieces need averaged
  normals stored for the outline pass. (Inferred; test it.)

### 2. The environment's values are compressed; units own the contrast

- The rule: walls and ground sit in a narrow, darkish value band with low saturation. The
  widest value range, the strongest saturation and the heaviest outline go to characters,
  neon and hazard marks.
- Who does it:
  - Ruiner darkens everything outside the action and uses saturation to steer the eye
    (sourced).
  - Gears Tactics balanced floor albedo and tiling "between readability, noise and
    interest", because the game is mostly seen from above (sourced).
  - The Ascent limited each asset to three colors (sourced).
  - Genshin and Zenless Zone Zero keep backgrounds greyer than characters (inferred).
- For us: T3 breaks this rule. Its black blotches are as contrasty as a character. Wall and
  ground albedo should sit at roughly 20 to 45% value. Check it by making the frame greyscale:
  the Operators should still be the first thing you see.

### 3. Flat value blocks, not photo noise

- The rule: a surface is 3 to 5 flat tones, with painted stains kept inside the panel shapes. Anime
  background painters work this way, and hard cel bands already split a face into 2 or 3
  tones. Photo grit under cel light reads as "a dirty photo under a cartoon".
- Who does it:
  - Edgerunners' Afterlife bar: flat panel fills, grime as soft mottled patches clipped to
    each panel, no photo speckle (frame, `edgerunners-afterlife-bar.webp`).
  - Sea of Thieves cuts the noise inside its color blocks (sourced, GDC 2018).
  - Hi-Fi Rush wanted no color gradations (sourced, GDC 2024).
  - Arknights: Endfield puts anime characters in more realistic environments. Even so, its
    concrete walls were hand-adjusted until they matched the character rendering (sourced,
    Light Zhong interview).
- For us: replace the photo albedo with a flat palette plus a soft grayscale grunge mask.
  The stain edges stay soft and mottled, as in the Afterlife frame, but stop at panel seams,
  so each panel reads as its own painted shape. Don't threshold the mask to a hard line. The palette colors are
  uniforms, so one material covers every wall style.

### 4. Grime has a cause and a place

- The rule: stains start where water starts. Drips run from caps and seams, and a darker
  contact band sits at the ground. The middle of a wall stays calm.
- Who does it: 0A (observed). The Edgerunners agent read the anime's painted grime as drip
  wedges below joints and a dark band at the base (inferred from memory; check it against real
  frames).
- For us: anchor drips to the cap and seam geometry, not to the texture's repeat. The shader
  can place a streak mask by height below the cap. Add a contact-dirt band from 0 to 20 cm.
  One tile in three or four gets a large stain; the rest stay clean.

### 5. A height gradient on every wall

- The rule: walls are darker at the base and lighter toward the top, in 2 or 3 hard steps to
  match the cel look. Painters do this; stylized games bake it into the texture or the vertex
  colors.
- Who does it: Overwatch bakes AO and edge lines into its diffuse. Breath of the Wild paints
  shading into vertex colors and keeps textures at 1024 px or less (both sourced).
- For us: compute the gradient from world height in `world.gdshader`. Every wall gets it for
  free, with no bake, and it survives the fog and the ghosting.

### 6. The top of a wall is its most-seen face

- The rule: a high camera sees caps more than faces, so the cap gets its own material. It
  should be one value step lighter than the face, with a thin lit edge and no drips.
- Who does it: 0A's walls read mostly by their pale coping and bright edge line, plus the
  posts, razor wire and lamps on top (observed). Tactical Breach Wizards keeps tops flat and
  graphic (sourced that it is flat-shaded; the detail about tops is inferred).
- For us: `level_view.gd` already has a flat `_cap_material`. Promote it to a real bevelled cap
  mesh. Face and cap must ghost together, so no cap is left floating.

### 7. Repetition breaks through placed layers, and signage does texture's job

- The rule: a big surface never shows one texture repeating without interruption. It is
  broken by the following:
  - per-tile variation
  - large-scale world-space tint
  - hand-placed marks: road paint, manholes, patches, cracks
  - one slogan, logo or hazard panel every 3 to 5 tiles

  Detail clusters at the gameplay focal points (gate, doors, corners, vents), and long runs of
  wall stay quiet.
- Who does it:
  - 0A: lane marks, STOP text, corner brackets, manholes, and slogans spaced along the wall
    (observed).
  - Cyberpunk 2077 by day: ads, murals and stripe bands are the wall texture on plain dark
    faces; graffiti sits at street level (frame, `cp2077-daytime-street.webp`).
  - Cyberpunk 2077 seen from above: billboards and rooftop clutter (dishes, fans, corrugated
    roofs) carry the buildings; the street is a calm grey ribbon with lane paint and red curbs
    (frame, `cp2077-street-from-above.webp`, the closest to our camera).
  - The stylized cyberpunk scenes on 80.lv keep the base tile plain and put leaks, cracks and
    puddles in decals (sourced).
  - Arcane-style environments keep painted detail near the characters and the rest quiet
    (sourced).
  - The Ascent put its density in signs, pipes and vertical mass (sourced that it had tools
    for pipes, cables and signs; the rest is inferred).
- For us:
  - Per-tile variation: hash the 1.5 m tile coordinate in the shader to pick a texture offset,
    a mirror, and a small value or hue shift. That gets most of the benefit of stochastic
    tiling for one extra line; skip hex tiling.
  - Large-scale tint: add world-space noise at 4 to 8 m scale.
  - Hazard stripes can be procedural below 0.9 m.
  - Decals: Godot decals skip our fog, so either bake the marks into `world.gdshader` as
    atlas layers picked by the tile hash, or place thin mesh cards that use the world shader.

### 8. Color lives in light, not in material

- The rule: materials stay neutral. Neon is an emissive strip plus a real light that spills
  magenta onto nearby walls and ground. Wet ground is drawn as streaks of the light's color
  on a flat dark base, not a blurry mirror. Between the pools of light the ground falls
  toward black.
- Each place has one dominant light color that tints everything in it: the Afterlife is
  green and cyan throughout. For the exterior map that is magenta and floodlight white.
- Who does it:
  - 0A: pink streaks under the sign, white light pools under the floodlights (observed).
  - Afterlife bar: one light color floods the scene; neon is flat bright bands with a glow
    (frame).
  - Neon street render: dark neutral buildings, all color from signs, which the wet road
    repeats as vertical streaks (frame, `neon-street-render.webp`).
  - Ruiner and Cloudpunk carry their look with neon on wet ground (sourced).
  - Triangle Strategy's HD-2D gets its richness from lighting over simple assets (sourced).
- For us: this agrees with environment-fidelity.md putting lighting first. The dark areas
  between pools also make our fog read better.

### 9. Resolution: fewer pixels, better shapes

- The rule: about 340 to 512 px per metre is plenty for a mostly high camera. Texel density
  should be the same across all pieces. Fine grain fades out as the camera rises, because
  the overhead view needs only the big shapes.
- Who does it: Breath of the Wild ships nothing above 1024 px (sourced). The texel density
  guides aim at about 512 px per metre for props (sourced).
- For us: a 512 px texture per 1.5 m tile, or 1024 px per 3 m. Turn on anisotropic
  filtering. Make the fade by camera height a uniform. Measure the pixels per metre at the
  3 m close-up in the engine before settling the density; nobody has measured it yet.

## Per surface

| Surface | What it should look like | Where to look |
|---|---|---|
| Perimeter wall | Flat grey-blue concrete panels in 3 to 4 tones. A dark plinth with procedural orange hazard stripes. A pale bevelled cap with a lit edge. A groove at every tile seam. Drips only below the cap and seams. One slogan or graffiti panel per 3 to 5 tiles. Razor wire, posts and lamps on top | 0A left and bottom-right walls; `cp2077-japantown-barrier-wall.webp` |
| Facility tower facade | A smooth corporate monolith: big flat dark sheets, strong vertical mullions, and a magenta emissive logo and slogan panels. Cleaner than the street: grime only at the base. The Edgerunners agent says Cyberpunk 2077's "Neo-militarism" style for corporations is exactly this (sourced). Color blocking in big bands and panels, strong ledges | 0A center tower; `cp2077-facades-looking-up.webp` |
| Street asphalt | A calm, dark, low-contrast base. Richness from white lane marks, STOP text, manholes, patched squares, and wet streaks catching neon and floodlight color. No visible repeat at 4 m scale: large-scale tint plus a per-tile hash | 0A bottom-left street; `cp2077-street-from-above.webp`; wet ground painted in `painted-neon-street.webp` |
| Sidewalk and curb | A curb is geometry: a 15 cm lip with a lit top edge. Paving slabs as flat tone blocks with thin dark joints, one value step lighter than the asphalt. Painted curb edges (red, orange) are a cheap strong accent | 0A curbs around the booth and gate; `cp2077-japantown-barrier-wall.webp` |
| Yard concrete | Between sidewalk and asphalt in value, with orange painted corner brackets and parking lines | Loading area on the right |
| Interior floor and wall | Same rules, cleaner. Corporate interiors are flat tones, with seams as geometry and value steps. The color comes from screens and neon | 0B, not studied in depth |

## What to avoid

- Photo-sourced textures, whether Poly Haven or AI-generated grit. They fight the cel
  characters. This replaces environment-fidelity.md's recommendation of Poly Haven for
  surfaces.
- Any landmark baked into a tiling texture (a big stain, a symbol, a drip row). It turns into
  a visible grid.
- Raising the resolution of the current textures.
- Normal maps generated from flat textures (Materialize, DeepBump). Under hard cel bands they
  add only micro-relief. Put the relief in geometry.
- Decals for anything that has to sit in fog, until the fog moves out of the surface color.
- Detail spread evenly everywhere. Busy everywhere reads as noise; calm runs make focal points
  land.
- Meshy for walls and ground. It is built to texture meshes, not tiling surfaces (sourced,
  Meshy blog). Keep it for props.
- If generating a tiling texture anyway:
  - prompt for flat, shadowless albedo, low-frequency, with no unique features
  - always preview it tiled 4 × 4 before accepting
  - AI tiling textures fail through baked lighting, invented details, seams and wrong scale
    (sourced)

## Suggested order for the implementing agent

This is a recommendation, not a decision. It is ranked by the research agent that studied
techniques, and the others agree. It fits the test patch environment-fidelity.md proposes, the
street entrance.

1. Shader-only, in `world.gdshader`:
   - the height gradient
   - the contact-dirt band
   - the per-tile hash variation
   - the large-scale world-space tint
   - the flat palette plus thresholded grunge mask, replacing the photo albedo
   - procedural hazard stripes

   No new assets. Look at it before going further.
2. The wall kit in Blender by script: plinth, cap, seam groove, pilaster, corner, end. Normals
   stored for the outline pass.
3. Placed marks: road paint, manholes, slogans and stains, as shader atlas layers or mesh cards.
4. A trim atlas for caps, plinths and hazard bands, once the kit geometry exists.
5. Vertex-color AO on subdivided kit parts and props. Not on plain boxes.

The lighting work in environment-fidelity.md (floodlights as real lights, neon spill, wet
ground, a toon shader that takes scene lights) runs alongside and matters as much.

## Decisions for Bryson

Answered 2026-09-29 (Bryson):

1. Painted. "I want it to be able to be taken seriously."
2. Thin lines, for now. The Afterlife frame shows exactly this: thin dark lines on the
   architecture, lower in contrast than the characters'. "I'm not committed to the cel shading entirely yet, in fact I'm leaning
   against it, though I like the anime style." DESIGN.md's look decision still says hard-edged
   cel shading; nothing there changes until he decides.
3. Clean tower, weathered perimeter wall, dirty street.
4. Agreed: real frames get checked. Which route, screencaps or network access, is still open.
5. Confirmed; closed in environment-fidelity.md.

The options as they were put:

1. **How the environment is shaded.**
   - (a) Painted: flat value blocks under plain lighting, with cel characters on top. This is
     the anime convention and how Edgerunners itself looks; Genshin and Zenless Zone Zero do
     the same.
   - (b) Full toon world: the environment gets the same hard light bands as the characters,
     like Hi-Fi Rush.

   Claude recommends (a), with the lighting quantized softly so the environment still sits
   with the characters.
2. **Ink lines on architecture.**
   - (a) None.
   - (b) Thin, lower-contrast lines on silhouettes and cap edges only.
   - (c) The same line as the characters.

   Claude recommends (b). The research is split: Hi-Fi Rush outlines everything, and anime
   backgrounds and miHoYo games mostly don't.
3. **How much grime on the corporate facility.** The Edgerunners research suggests corporate
   buildings are clean monoliths and the grime belongs to the street and the perimeter.
   Claude recommends: clean tower, weathered perimeter wall, dirty street. Or everything as
   worn as 0A?
4. **Real reference frames.** No web page could be opened from this session, so no image link
   below was checked, and none of the Edgerunners rules above were checked against real
   frames. Two fixes; either works:
   - (a) Bryson saves 8 to 12 Edgerunners screencaps of streets, walls and rooftops into
     `art/reference/edgerunners/`.
   - (b) Bryson allows these hosts in the cloud environment's network settings (the
     environment menu in the session title bar, then Edit): artstation.com, 80.lv,
     gdcvault.com, store.steampowered.com, cyberpunk.fandom.com, creativeuncut.com.

   Then an agent re-checks the rules and the links.
5. **Environment-fidelity question 1 ("how photographic?")** reads as answered by the quote
   above: stylized, not photographic. Confirm and Claude will close it there.

## Sources

None of these were opened from this session: the network policy blocked every host except
GitHub. The claims marked "sourced" above come from search-result summaries of these pages.
Open them in a browser. The one verified image is our own 0A.

What to look at, best first:

- Hi-Fi Rush toon rendering, the closest shipped 3D example of "sharp, graphic, clean":
  [GDC 2024 talk](https://gdcvault.com/play/1034330/3D-Toon-Rendering-in-Hi),
  [80.lv article](https://80.lv/articles/the-making-of-hi-fi-rush-s-3d-toon-rendering-style)
- Genshin Impact's environment pipeline (painted environments beside cel characters, layered
  terrain): [GDC 2021 talk](https://www.gdcvault.com/play/1027538/-Genshin-Impact-Crafting-an)
- Arknights: Endfield, anime characters in realistic-material environments tuned to match:
  [Light Zhong interview](https://www.gamespress.com/Arknights-Endfield-Reimagined-An-In-depth-Interview-with-Light-Zhong-a)
- Gears Tactics, floors from a high camera:
  [Substance magazine](https://www.adobe.com/products/substance3d/magazine/destroyed-beauty-texturing-gears-tactics-with-splash-damage.html)
- The Ascent, isometric cyberpunk density:
  [GDC talk](https://gdcvault.com/play/1027800/Building-the-World-of-The),
  [Bjorn Hurri concepts](https://www.artstation.com/artwork/KrYgly)
- Ruiner, dark edges and a saturated center:
  [City hub, Benedykt Szneider](https://www.artstation.com/artwork/g88ne)
- Stylized cyberpunk scene workflow (one trim sheet, bevelled pieces, color variation in
  engine): [80.lv](https://80.lv/articles/making-a-stylized-cyberpunk-scene-in-blender-and-ue4)
- Cyberpunk alley (plain base tile; leaks, cracks and puddles in decals):
  [80.lv](https://80.lv/articles/creating-cyberpunk-alley-in-real-time-engine)
- Anime background in 3D (Yan Ru, Anime Tokyo):
  [ArtStation](https://yan3ru.artstation.com/projects/VJ89oX),
  [80.lv](https://80.lv/articles/an-anime-style-recreation-of-tokyo-made-with-unreal-engine-5)
- Sea of Thieves, noise cut inside color blocks:
  [GDC 2018 summary](https://80.lv/articles/gdc18-visual-adventures-on-sea-of-thieves)
- Overwatch, bevels and edges painted into the diffuse:
  [80.lv](https://80.lv/articles/overwatch-technical-overview)
- Edgerunners backgrounds:
  - Staff, including background director Masanobu Nomura and the background studio Bihou:
    [ANN](https://www.animenewsnetwork.com/encyclopedia/anime.php?id=25775)
  - A painting used as a background base (Ward Lindhout, "Moonstation"):
    [ArtStation](https://www.artstation.com/artwork/B3AmL6)
  - [Screencap gallery](https://cyberpunk.fandom.com/wiki/Cyberpunk:_Edgerunners/Gallery)
  - The art book *The Art of Cyberpunk: Edgerunners*, 318 pages with background settings and
    boards, is the best primary source if Bryson gets it
- Cyberpunk 2077's corporate architecture:
  [Olborski, Megabuilding](https://www.artstation.com/artwork/WmWPDQ),
  [Night City's design (Domus)](https://www.domusweb.it/en/architecture/gallery/2020/12/21/night-city-how-the-cyberpunk-2077s-megalopolis-was-built.html)
- Zenless Zone Zero art: [official gallery (Creative Uncut)](https://www.creativeuncut.com/art_zenless-zone-zero_a.html)
- Persona 5's raw field textures, to see how flat the source colors are:
  [TCRF](https://tcrf.net/Proto:Persona_5/December_4th,_2015/Textures/Field_Textures)

## Findings

### 2026-09-29 — Research (Claude, five research agents)

Five parallel agents covered:

1. The Edgerunners backgrounds
2. 3D anime games
3. High-camera tactics games
4. Stylized surface techniques
5. Stylized cyberpunk environment art and AI-made textures

The network policy blocked every page fetch, so the findings come from search summaries and
the agents' own knowledge, and are marked that way above.

- **They agreed on:** structure over texture, compressed environment values, flat tones over
  photo grit, and color in light.
- **They split on:** ink lines on architecture (decision 2).
- **Weakest area:** no primary source was found on how Edgerunners' backgrounds are painted.
  That section is inference from memory until checked against real frames (decision 4).

### 2026-09-29 — First reference frames (Bryson's picks; Claude's reading)

Five frames in [art/reference/look/](../art/reference/look/README.md), one from the anime. The
Afterlife frame confirms thin lines on architecture, flat panel fills and one dominant light
color. It corrects the grime: soft mottled patches inside panels, not hard-edged blobs
(principle 3 changed). The rest confirm signage as texture and color from light. The drip and
base-band reading of the anime's grime is still unchecked: the Afterlife is an interior.

### 2026-09-29 — Second batch of frames (Bryson's picks; Claude's reading)

Four more, mostly Cyberpunk 2077. The Japantown barrier wall is the perimeter wall kit in one
image: plain face, chamfered cap, painted base band. The view from above is the closest to our
battle camera and confirms a calm street with the detail on buildings and roofs. The painted
neon street shows wet ground as broad painted strokes. The looking-up shot shows facade color
blocking. None is an Edgerunners exterior, so the anime's street grime is still unchecked.
