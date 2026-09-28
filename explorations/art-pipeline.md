# Art pipeline: how 3D assets get made

- Feeds: DESIGN.md open question 2
- Status: open
- Next action: Bryson makes the three pack sheets in Astra (prompts in the latest finding);
  Claude builds each pack as a separate piece with Meshy, attached to the spine bone, then rigs
  the `_v2` Operators.
- All art made before 2026-09-27 was removed at Bryson's request. Files under `art/` and
  `game/art/` linked below no longer exist; they are still in git history at commit
  `9a638e8` (for example `git show 9a638e8:art/NOTES.md`).

## The question

Which art pipeline this project uses. Bryson wants to understand the available pipelines, what
they cost in money and in his time, and see examples of what each one actually produces before
committing to anything.

2026-09-24: the game is 3D, and Bryson wants it to be good looking (DESIGN.md). He plans to
start on art with the Blender MCP as soon as the battle MVP playtest validates the game. The
MVP's 3D scene is built so that models can replace its greybox shapes directly.

## Constraints this inherits

- About 10 hours a week (DESIGN.md).
- No budget beyond the existing AI subscriptions, though Fable- or Astra-level spending is on
  the table when it is genuinely needed or for polish (AGENTS.md).
- Final polished assets are deliberately deferred toward the end of the project. The style and
  scale decisions are not.
- Bryson directs the art. Agents and external tools execute it.

## House style

The look that produced the approved Operators (2026-09-27). Every new image prompt, for
characters, enemies, props or places, starts from it so the set stays one world. DESIGN.md holds
the decision; this is the working detail.

- **Style:** gritty cyberpunk anime in the vein of Cyberpunk: Edgerunners. Bold ink outlines,
  hard-edged cel shading, saturated colors, sharp angular design.
- **Surfaces:** worn and lived-in. Scuffs, grime, tape repairs, patches, scratched hard plates,
  faded prints and defaced corporate stickers.
- **Clothes:** near-future street techwear, layered and asymmetric, with one eccentric,
  memorable detail per character.
- **Color:** grimy neutral bases (cream, grey, charcoal) with one strong accent per character.
  The Operators own yellow, electric blue and sage green; nothing else on the map should use them.
- **Silhouette first:** a character must read at about 55 px tall from the battle camera, so each
  one gets a distinct shape (a tall collar, a harness, headphones) and not just a color swap.

Rules that keep a sheet usable by Meshy:

- Character sheets are front and back views side by side on white, in a strict T-pose, arms
  horizontal, palms down.
- Gloves, fingers together. The rig has no finger bones, so bare spread fingers stay spread in
  every animation.
- Nothing hangs below mid-thigh or dangles loose: no capes, long coats or loose cables. They tear
  when rigged.
- Rigid gear that must keep its shape, such as backpacks, is generated as a separate object with
  its own multi-view sheet (front, back, side, three-quarter), then attached to a bone. Meshy
  flattened every pack that was modeled on the body.
- Name sides in viewer terms ("on the viewer's right in the front view"). The generator flips
  sides otherwise.

The prompt block for characters, as used for the Operators:

```
Character turnaround sheet, front view and back view side by side, full body, plain white background. Gritty cyberpunk anime style in the vein of Cyberpunk: Edgerunners: bold ink outlines, hard-edged cel shading, flat saturated colors, sharp angular design. Near-future street techwear, layered and asymmetric, worn and lived-in: scuffed fabric, tape repairs, patches, scratched hard plates, faded prints. Strict T-pose: arms straight out horizontally, palms facing down, gloved hands relaxed with fingers together and gently curled, not spread. Feet shoulder-width apart. Realistic adult proportions, not chibi. Every outfit piece ends above mid-thigh, no capes, no long coats, no loose hanging cables or straps.
```

Operators add their compute backpack and camera bot to this. For props and places, keep the
style and surface sentences and swap the rest; that adaptation is untested.

## Candidates

The full list, with what each is for and its license caveats, is in section 7 of
[the art brief](../art/astra-brief.md#7-how-to-make-it-a-free-pipeline-that-ai-can-drive). In
short: headless Blender driven by Python build scripts for hard-surface work; MPFB2 or an
image-to-3D generator (TRELLIS, Hunyuan3D, Hyper3D Rodin) for organic shapes; Rigify, Mixamo and
Quaternius's CC0 animation library for rigging and motion; Poly Haven and ambientCG for textures.

## Findings

### 2026-09-24 — Bryson's art direction, and what this Mac can do (Claude)

- Bryson: "stylized but realistic," and "a sort of solar punk meets corporate AI future with
  advertisements." He asked Claude to design one Operator and AI pair plus set pieces as a brief
  for Astra's first Blender pass, with advice on free, AI-driven ways to make 3D models. The brief
  is [art/astra-brief.md](../art/astra-brief.md).
- Checked on Bryson's Mac: Blender 5.2 LTS runs headless Python build scripts and exports glTF, so
  an agent can build, render and export assets without the UI. The brief's preview-camera code
  was run there, and a 1.7 m figure comes out about 55 pixels tall from the battle camera at
  default zoom.
- The Blender MCP server is configured and its addon is installed, but it only responds while
  Blender is open and connected, so which generators it has enabled (Hyper3D, Hunyuan3D, Poly
  Haven, Sketchfab) is still unchecked. MPFB2 (MakeHuman for Blender) is not installed.

### 2026-09-24 — Review of Astra's first pass against the sharpened direction (Claude)

Bryson: "attractive, cool, stylized models. For the humans, realistic, like Watch Dogs meets
Cyberpunk. For the AI, something more cute/chibi as a contrast for now." He also asked for
terrain models, and for Claude to judge each asset against that direction, then improve what fits
and rebuild what doesn't.

What Astra delivered is technically sound: every asset rebuilds from a script, exports cleanly,
and is measured in [art/NOTES.md](../art/NOTES.md), and the CC0 human base is licensed
correctly. The look is the problem.

| Assets | Fits? | Verdict |
|---|---|---|
| `char_installer` | No | Reads as a clay mannequin: clothes painted onto the body, a bandana that reads as a swim cap, slab shoes, flat colors. Nothing of Watch Dogs or Cyberpunk. Rebuild |
| `ai_moth` | No | A realistic moth rather than chibi, and a 15-pixel speck at default zoom. Exports as 76 separate skinned objects. Rebuild |
| `prop_backpack_rig`, `prop_rivet_driver` | No | Toy-like. The two solar flaps spread flat read as a plank balanced on her head. Rebuild with the Installer |
| `kit_exit_hatch` | No | Reads as a diorama of stairs up to a teal board, not a roof hatch. Rebuild |
| Floors, walls, planters | Yes, but plain | Right vocabulary and scale. Flat pastel colors and blank faces make them read as toy blocks. The rammed-earth wall reads as stacked planks |
| Network hardware | Yes | The status-ring language works from above. The turret is a white ball with a handle, and the data cache is not yet the most beautiful Company object |
| Other props | Yes | Server rack, cable tray, crate, cargo bike and spore are sound; they share the flat-material problem |
| Terrain | Missing | Nothing outdoors yet: ground surfaces, height changes, stairs, curbs, trees |

Causes, in order of impact:

1. Every material is one flat color: no ambient occlusion, edge wear, grain, grime or normal
   detail. This, more than the shapes, is what makes the set look like toys.
2. Pastel, low-contrast colors.
3. Clothes are skin-tight offsets of the body, so they read as paint.
4. The game-view previews are 95% empty grey, which makes them hard to review.
5. Each full rebuild adds about 60 MB of PNG previews to git.

Plan for this pass, one commit per stage: shared pipeline upgrade (baked stylized materials,
readable previews) and a rebuild of the environment; the chibi AI; the Installer and her gear;
fixes to the weak environment pieces; a terrain kit; notes and an import check in Godot.

### 2026-09-26 — Hand-built Installer and a shared human kit (Claude)

- Bryson asked for a best-effort Blender build of the direction C Installer, "even though it's
  not the best route" compared with image-to-3D, then for lessons and a reusable base because
  more human models are coming.
- Built entirely by script: the MPFB body, cloth-simulated trousers and shirt, draped vest, gear,
  ringlet hair, CC0 textures with procedural wear, baked into a 67k-triangle GLB. The record is
  the rebuild checkpoint in [art/NOTES.md](../art/NOTES.md); previews are
  `art/previews/char_installer_*.jpg`.
- Cost: about 6 hours of agent time for the first character, most of it debugging the toolkit.
  A full rebuild then runs unattended in about 35 minutes on the M1 Pro.
- The reusable part is now a kit, `art/scripts/human/`: one spec file per character, with a
  retarget stage that moves an outfit built on the reference mannequin onto any MPFB body. The
  recipe, timings and lessons are in [art/human-pipeline.md](../art/human-pipeline.md).
- Image-to-3D was not used. The Blender MCP's Rodin trial key had no credit left, and the
  Hugging Face demos' anonymous quota ran out after one untextured shape.
- The same day, the first baked texture pass gave eleven environment, network and prop assets
  baked procedural atlases ([art/NOTES.md](../art/NOTES.md#baked-texture-pass--2026-09-26)).

### 2026-09-27 — Where the 2026-09-24 plan stands (Claude, from the commit history)

| Stage | State |
|---|---|
| Baked materials and readable previews | Done for eleven assets; the rest are still flat color |
| Installer and her gear | Rebuilt 2026-09-26; the separate backpack and rivet-driver props are the Astra versions |
| Chibi AI | Not started; `ai_moth` is still the realistic moth |
| Weak environment pieces | Not started: the hatch is unchanged, and the rammed-earth wall got baked materials but no shape changes |
| Terrain kit | Not started |
| Import check in Godot | Done for the Installer only |

### 2026-09-27 — All existing art removed; hyper-simplify (Bryson)

- Bryson: "I think we need to hyper simplify the art, so that it's easy for you to produce, but
  we also need to make sure that there is some kind of art." And: "I don't like any of the art so
  far," so every model, script, preview, concept image and vendored source was removed. "We don't
  want the models you created, as I'm going to have you create more later."
- Open, for Bryson: what "hyper simplified" means, and whether it replaces the 2026-09-24 character
  direction in DESIGN.md (realistic humans, chibi AI). The hand-built human kit is gone with the
  rest.

### 2026-09-27 — The new look (Bryson)

- "A simple, almost Ghibli inspired look." Cel-shaded, "maybe anime inspired, like ghibli style
  but cyberpunk. I don't think I've seen anyone try something like that." The realistic-human and
  chibi-AI direction is eliminated. Graduated to DESIGN.md.
- Neighbors worth studying (Claude): Eastward (Ghibli-feeling, but pixel art and post-apocalyptic),
  Sable (cel-shaded, Moebius rather than Ghibli), Ni no Kuni (actual Ghibli, but fantasy), and
  Hi-Fi Rush (cel-shaded and corporate, but cartoon). None combine Ghibli softness with a
  cyberpunk city, so the gap Bryson sees looks real.
- Bryson's answers, the same day: the color palette of Cyberpunk 2077 applied to Ghibli-style
  characters and art; ink outlines; Ghibli-inspired proportions, "I think that will translate
  better on the map"; flat color for now. Graduated to DESIGN.md.

### 2026-09-27 — The three Operators' references (Bryson)

Bryson supplied front and back views of the three Operators in `art/reference/` and asked that
the next designs adhere to them. The main character is `main-character.webp`; the other two are
`operator-headband.webp` and `operator-sage.webp` (Claude's file names, after what sets each one
apart). What they show, for tools that can't read images:

| Part | [Main character](../art/reference/main-character.webp) | [Headband](../art/reference/operator-headband.webp) | [Sage](../art/reference/operator-sage.webp) |
|---|---|---|---|
| Accent color | Yellow | Electric blue | Sage green, rust red |
| Role | Street courier | Hardware tinkerer | Ex-military field medic, clearly a woman |
| Head | Messy dark-brown hair, yellow goggles, easy smile | Curly dark hair in a high puff, braided blue cable headband, blue eyepiece over one eye, headphones | Short wavy dark-brown bob, metal hair clip, dark rectangular glasses |
| Top | Grimy cream cropped techwear jacket with a tall collar, a diagonal black-and-yellow hazard stripe, one sleeve covered in defaced ad stickers; faded yellow tee | Dirty cream long-sleeve top, sleeves pushed up, under a grey utility harness vest full of tool pockets and a coiled blue cable | Cropped olive field jacket, sleeves rolled, one cream shoulder plate; olive chest rig with pouches over a cream high-neck top; a wrist device |
| Hands | Black gloves, yellow knuckle plates | Black gloves, blue fingertips | Cream and olive gloves |
| Trousers | Charcoal cargo trousers, a holster pouch on one thigh, worn knee patches | Charcoal cargo joggers, one leg rolled to the knee over a blue knee pad | Loose grey cargo trousers cinched at the ankle, a medical pouch on the belt |
| Shoes | Chunky grey and cream sneakers, yellow soles | Mismatched: one grey and blue, one cream and blue | Grey and sage sneakers |
| Backpack | Dented cream hard shell, hazard stripe, tape repair, vent | Scratched grey metal shell, exposed circuit window, blue side pods, vent | Cream shell, rust-red medical stripe, small cross, side canister, vent |

The table describes the redesigned sheets from later on 2026-09-27; earlier references are in git
history. The camera bot is drawn correctly on the left shoulder in both views of every sheet. All three carry a small camera bot on a short mast. Bryson, 2026-09-27: it sits over the
character's **left** shoulder. The image generator put it over the right shoulder in every front
view, so the back views are the correct ones.

The shared base (greys and cream) with one accent per Operator should read well on the map.
Yellow is Cyberpunk 2077's signature color; blue and sage are softer than that game's cyan and
red, which is worth keeping in mind when the city palette gets picked (Claude).

### 2026-09-27 — What Meshy can do for us (Claude)

Bryson installed the Meshy MCP server (key in the macOS Keychain, launcher `~/.local/bin/meshy-mcp`)
and asked what it offers, especially rigging and animation. From Meshy's docs and the server's
own tool definitions (v0.5.2); nothing generated yet. Balance on 2026-09-27: 3,100 credits.

| Step | Tool | Credits | Notes |
|---|---|---|---|
| Model from front and back views | `meshy_multi_image_to_3d` | 30 textured | Ask for a T-pose when it will be rigged |
| Lower the polycount | `meshy_remesh` | 5 | Rigging needs 300k faces or fewer |
| Rig | `meshy_rig` | 5 | Humanoid only, textured, facing +Z. Walk and run included |
| Each extra animation | `meshy_animate` | 3 | Library of 590+ clips: idles, crouch walks, shooting, reloads, hit reactions, deaths, climbing, vaulting |

- Paid plans own their output outright; the free tier is CC BY 4.0.
- Limits: non-humanoids (a bot or a drone partner) can't be auto-rigged. Clips are generic motion
  capture, so anything specific to the game, such as hacking at a terminal, may not exist.
  Every rigged character shares Meshy's skeleton, so clips carry across all three Operators.
- For our look: Meshy makes the shape and a base-color texture; the ink outlines and cel shading
  would come from a toon shader in Godot. How well its texture reads as flat Ghibli color is
  untested.
- The front views in `art/reference/` put the camera bot on the wrong shoulder. Meshy would build
  what it sees, so those images need correcting before generating.

### 2026-09-27 — First Meshy test: the main character (Claude; rendered and inspected, not yet seen by Bryson)

- Bryson supplied a T-pose front and back sheet, now `art/reference/main-character.webp`. It
  changes the outfit from the first reference: a yellow tee instead of black, and a hard-shell
  pack with a solar panel instead of the soft pack and bottle. Both views put the camera bot on
  his right shoulder, so Claude mirrored both halves for Meshy's input (`art/meshy/main-character/`),
  which puts it on the left as Bryson decided.
- Spent 50 credits (3,050 left): model 30, rig 5, five clips 15. Every step succeeded on the first
  try and took one to two minutes.
- Result: 31k triangles, one 24-bone skeleton, one texture. In the game at
  `game/art/characters/main_character/` with seven clips: Idle, Walk, Run, Cautious Crouch Walk
  Forward, Cowboy Quick Draw Shooting, Hit Reaction and Knock Down.
- A flat two-tone toon shader with screen-space ink outlines (`game/art/shaders/`) and a preview
  scene (`game/preview/`) to judge it. Clips play in place, since the game moves units itself.
- Honest read: the outfit, colors and silhouette follow the reference well, and at the battle
  camera's default distance he is about 55 pixels tall and reads by his cream jacket and yellow
  tee. Up close the face is Meshy's weak spot, soft and generic. Meshy also paints soft shading
  into the texture, so the result reads more like a 3D anime game than flat Ghibli cels. Several
  clips are generic motion capture: the shooting clip has no gun, and the idle is stiff.

### 2026-09-27 — The other two Operators (Claude; rendered and inspected, not yet seen by Bryson)

- Bryson: Meshy is fine for now. Faces only need to hold up at battle distance, since dialogue
  uses 2D portraits (graduated to DESIGN.md), and this is the MVP.
- Bryson supplied T-pose sheets for both, now in `art/reference/`. Same mirroring fix for the
  camera bot. Same five clips as the main character, so all three share one set.
- 100 credits for the pair, 2,950 left. Everything succeeded on the first try.
- Defects: the sage Operator came out with a camera bot on *both* shoulders, which is in the
  geometry and needs a regeneration to fix. None of the three packs kept the solar panel; from
  behind they are plain dark boxes.
- The shooting clip stays Cowboy Quick Draw for now: a one-handed draw suits a sidearm pulse
  weapon. It changes once the weapon exists.

### 2026-09-27 — Redesigned Operators, round one (Bryson's direction; Claude's results, rendered and inspected, not yet seen by Bryson)

- Bryson's critique of the first three: the clothes are plain and all alike, the sage Operator
  reads too androgynous, and the hands are awkward. He wants them more cyberpunk: grittier,
  eccentric, near-future and cool, keeping each one's color scheme. For the image prompts he
  dropped Ghibli and solarpunk. Whether DESIGN.md's look and world lines change too is still open.
- Hands: Meshy's rig has no finger bones, so a hand keeps its modeled shape in every clip. The
  new sheets use gloves with fingers together, which Meshy builds cleanly.
- Bryson made new T-pose sheets in Astra (now in `art/reference/`): a street courier (yellow),
  a hardware tinkerer (blue) and an ex-military medic (sage). All three put the camera bot on the
  left shoulder, so no mirroring was needed.
- Bryson chose to judge the models before rigging: Meshy 7, 4K texture, about 100k triangles,
  30 credits each, 90 in total (2,860 left). All succeeded on the first try. In the game as
  `game/art/characters/*_v2/`, unrigged; the preview now shows unrigged models in T-pose.
- Result: faces, outfits, gloves and colors follow the sheets far better than round one. The
  hands are clean mitten shapes. But **all three lost their backpacks**: Meshy turned each one
  into straps or a flat pouch. The main character's camera bot lost its lens, and the sage
  Operator's is a small stub. Meshy also added details that weren't asked for, like a chest rig
  and knee pads on the main character.

### 2026-09-27 — Packs become separate pieces (Bryson)

- Bryson likes the redesigned models: "they look great."
- Packs: Bryson chose to build each pack as its own object, attached to the spine bone, rather
  than regenerating the bodies. A hard shell shouldn't bend anyway. The camera bot is planned as
  its own piece too, which would let it turn and look around; one per Operator or shared is open.
- Claude wrote Astra prompts for four-view pack sheets: the pack alone, no straps or camera bot,
  a flat back panel, an empty mount socket at the top left corner for the bot.
- Bryson asked for the docs to carry the new look for future environment and enemy work: DESIGN.md
  and the House style section above.
- Bryson, the same day: Edgerunners is the right reference. "If people play my game and say it
  looks like Edgerunners specifically, then we were successful." The world goes gritty all the
  way through, with no solarpunk half (DESIGN.md has his reasons). The packs have no solar
  panels.

## Questions to answer

1. How much does this depend on what the game turns out to be?
2. What does each pipeline cost per asset, in money and in Bryson's own hours?
3. What counts as "substantial enough to judge the look" for a prototype asset?
4. What has to be decided early anyway — style, scale, camera, animation needs — even though
   final assets come late?

## Decision

None yet.
