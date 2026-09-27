# Art pipeline: how 3D assets get made

- Feeds: DESIGN.md open question 2
- Status: open
- Next action: work out with Bryson what "hyper simplified" art looks like, then make a small
  set of it (see the 2026-09-27 finding).
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

## Questions to answer

1. How much does this depend on what the game turns out to be?
2. What does each pipeline cost per asset, in money and in Bryson's own hours?
3. What counts as "substantial enough to judge the look" for a prototype asset?
4. What has to be decided early anyway — style, scale, camera, animation needs — even though
   final assets come late?

## Decision

None yet.
