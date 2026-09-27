# Human characters: how they're built

The shared Blender pipeline for realistic human characters, and what building the Installer
taught us (2026-09-26). Read this before starting any human model. The record of that build is
the rebuild checkpoint in [NOTES.md](NOTES.md).

## The approach

Everything is modeled by Python scripts run in Blender: no image-to-3D output, no downloaded
clothing or hairstyles. Bryson chose this route for characters on 2026-09-26. One body base,
garments grown from its surface, CC0 textures for detail, procedural wear, one skeleton for
every character.

| Step | What happens | Time on the M1 Pro |
|---|---|---|
| Base | MPFB2 generates the body, skeleton, eyes, brows and lashes from the character's body spec | 1 min |
| Garments | Cut from the body surface, given ease, draped with the cloth solver | trousers ≈ 5 min, shirt ≈ 1 min |
| Gear | Hard-surface pieces fitted to the draped cloth (belts, pouches, straps, shoes, gloves, glasses) | ≈ 1 min |
| Rig | Weights copied from the body; rigid parts bound to one bone; hidden skin under clothes removed | ≈ 1 min |
| Previews | Cycles hero, back, face, tactics sheet and a side-by-side with the concept | ≈ 12 min |
| Export | Decimate, bake cloth and gear atlases, write the GLB | ≈ 10 min |

The first build (the Installer) took about 6 hours of agent time, mostly debugging the
toolkit. The lessons below are the part not to pay for twice.

## The kit

Everything reusable lives in `art/scripts/human/`. A character is a spec module:
[char_installer.py](scripts/char_installer.py) is the reference to copy.

| File | Holds |
|---|---|
| `build.py` | Stage runner and the stages every character shares: base, retarget, rig, previews, export |
| `base.py`, `../make_base.py`, `fetch_sources.py` | Body generation from a spec's BODY with MPFB2, and the source download |
| `body.py` | Loading a base; skin, eye, brow and lash materials from a spec's LOOK |
| `garments.py`, `trousers.py`, `shirt.py`, `vest.py` | The cloth toolkit and the garment builders |
| `shoes.py`, `gloves.py`, `gear.py`, `backpack.py`, `accessories.py`, `head.py` | Footwear, gloves, belt kit, solar pack and camera bot, glasses, headband and hair |
| `details.py`, `decals.py` | Padded panels (pockets, flaps, pads), snaps, generated emblems and patches |
| `materials.py`, `shading.py` | The material library (`DEFAULTS`) and node helpers |
| `fit.py` | Layering fixes, covered-skin removal, retargeting to another body |
| `rig.py`, `export.py`, `previews.py`, `studio.py` | Skinning and pose, bake and GLB, review renders, preview lighting |

The builders are tuned to one body: the Installer's, the *reference mannequin*. They always
run on it. When a character's BASE is a different body, the `retarget` stage moves the finished
outfit onto it. Cloth follows the new surface point by point, hard gear moves as whole
assemblies (RIGID), and footwear rides the foot bones (ON_BONES). This works because every MPFB
body has the same vertex order.

### Adding a character

1. Once per machine: `python3 art/scripts/human/fetch_sources.py` (about 570 MB into the
   git-ignored `art/vendor/_sources/`).
2. Copy the Installer spec to `art/scripts/char_<name>.py`. Set NAME, BASE
   (`art/vendor/<name>_base.blend`), CONCEPT, BODY (MPFB macros, face targets, eyes, brows,
   lashes, skin, height), LOOK, PALETTE, then STAGES and the BONES, RIGID, ON_BONES, COVER,
   TUCK and EXPORT tables.
3. `blender -b --factory-startup -P art/scripts/make_base.py -- char_<name>`
4. `blender -b --factory-startup -P art/scripts/char_<name>.py` for everything, or
   `-- --from STAGE --to STAGE` to iterate on part of it. Caches go to `art/source/cache/<name>/`.
   For a quick look at any cached stage, run
   `blender -b --factory-startup -P art/scripts/preview_cache.py -- char_<name> 04_shoes feet,front`.
5. Review the previews against the concept, reimport in Godot, update NOTES.md, commit.

To put an existing outfit on another body without re-simulating, copy its last outfit stage
from `art/source/cache/<outfit>/` into the new character's cache with the same number, and
run the new spec `-- --from retarget`.

### Gaps the Operator trio will need

A zip jacket and a hoodie jacket, a tee, straight trousers and jeans (a hem break instead of
the jogger cuff), short hairstyles (a curly crop, a messy short cut), stubble, and variations
of the pack and camera bot. MakeHuman's CC0 pack already has young male and female skins.

## Lessons

### Approach and workflow

- Put the concept's front and back views side by side with the renders early and often
  (`_compare.jpg`). Crop the concept at 2 to 4× zoom to read details before modeling them.
- Heavy steps (cloth, bakes, previews) run headless in the background. MCP calls time out after
  a few minutes and lose the result. Use the live MCP session only for quick look-dev (head,
  glasses, hair), with the code in files and `exec`'d there.
- Stage everything and cache each stage to a `.blend`, so fixing the hair doesn't re-run the
  cloth. Always pass `--factory-startup` to headless runs, or the MCP add-on loads and fights
  the live session for its port.
- Concepts often contradict themselves between views, such as which shoulder a camera sits
  on. Pick one, usually the front view, and note it.
- Colors: the first pass came out too bright and saturated next to painterly concepts. Start
  darker and less saturated than the concept looks, with strong grime.

### The body (MPFB2)

- Fit eyes, brows and lashes *before* removing MakeHuman's helper geometry: their fitting data
  points at helper vertices. `create_human` only masks the helpers, so apply the mask last.
- Face likeness comes from MPFB targets (`head-oval`, cheek bones, lip volumes, nose width);
  a resting expression comes from the CC0 expression units (`mouth-corner-puller`,
  `eye-*-slit`). Keep them small (0.1 to 0.5).
- MakeHuman skin textures paint dark lips and some eye makeup. A vertex-color lip mask in the
  skin shader fixes the lips; brows `eyebrow008` and lashes `eyelashes01` read natural.
- The eye mesh maps its cornea to the bottom-right of the eye texture: split it into its own
  transmissive material, or the eyes render as dark glass.

### Cloth

- Bunching at the ankles comes from extra length, not extra area. Start the leg longer
  (`DROP`) and animate the pinned cuff up to the ankle with a shape key during the simulation.
  Negative shrink crumples everything like paper.
- Spread the extra length with `smoothstep(top, cuff)**2.4`, so the slack stacks near the
  hem; a linear profile makes a ruffle band where the stretch starts.
- Bending stiffness has to scale with mesh density. The shirt at 1 cm resolution with bending
  2.5 wrinkled like a washboard. Simulate at about 2 cm with bending 9, then subdivide.
- Compression stiffness high (60 to 70) makes the fabric fold instead of shrinking.
  Self-collision is slow but makes stacked folds look right; use it on trousers.
- Before simulating, relax the shell over concave body areas the fabric would bridge: crotch,
  seat cleft, cleavage, backs of the knees. Simulate shirts against a smoothed collider (a
  "sports top") so nipples and navel don't pucker the cloth.
- Tuck a shirt by pulling its hem vertices inside the trousers after both are simulated
  (`fit.keep_inside`).

### Blender API traps (each cost real time)

- Read every vertex normal *before* moving any vertex. Writing `co` makes Blender recompute
  normals, and each move then bends the next one: the result looks like crumpled cloth.
- Never build a BVH from an object's evaluated mesh when it has Solidify. Nearest-point
  lookups land on the inner shell, and decals, straps and pockets sink or spike. Use
  `garments.base_tree`.
- Solidify's even-thickness mode spikes at the odd degenerate vertex left by draping: keep it off.
- Copy data out of a bmesh before `bm.free()`, and copy `(group, weight)` pairs before removing
  vertex groups. Both leave dangling references otherwise.
- Materials with no users are dropped on save: set a fake user on library materials.
- Cutting by deleting faces leaves jagged edges; `smooth_boundary` relaxes them along the edge.
- When growing a collar from boundary edges, filter by region, or the armhole tops grow collars too.

### Look

- Flat colors read as clay. Every material needs real texture detail (CC0 weave, grain, tread
  normals) and wear layers: mottled fading, grime from ambient occlusion, edge wear from
  pointiness. Keep the edge-wear ramp narrow (0.53 to 0.62), or thin parts turn white.
- Generated images, such as the leaf emblem, need checking by eye before use. The first
  emblem drew every leaf on one side.
- Ringlet hair reads as curls when the tube radius is about 0.6 of the helix radius and the
  pitch is about 2.5 tube radii; thin springs read as phone cords. Root scalp curls only on the
  scalp cap, and never under the headband.
- Glasses need a thin-wall transmissive material; real refraction makes crystal blocks.

### Retargeting to another body

- Move multi-part gear as one assembly (a RIGID group). Moving each piece by its own centre pulled
  assemblies apart in the smoke test: the pack's trims and the shoes' heel tabs drifted off.
- Footwear rides the foot bones (ON_BONES), scaled by bone length. Following the foot surface
  crushed the shoes into lumps.
- Check prefixes against every object name: `tool_` also matched `tool_belt`.

### Rig, export and Godot

- Copy weights from an intact body copy (`POLYINTERP_NEAREST`) *before* deleting covered skin,
  or garments pick up weights from whatever skin remains.
- Leave the glasses out of the covered-skin test, or it deletes the face behind the lenses.
- Decals with alpha bake to black in the atlas. Export them separately on an alpha-tested strip.
- The game file is single-sided cloth with double-sided materials. Budget triangles per part;
  hair and gloves are the surprises.
- When a GLB replaces an older one, delete the textures Godot extracted from the old file.
  The first reimport complains about their IDs; the second is clean.
- In the preview camera, yaw −25° puts the camera at the character's right-front, the concept
  sheets' three-quarter view.

## Known weak spots

Hair looks sculpted up close. MakeHuman faces are generic without more target work. There's
no stitching or real dirt yet. The backpack is simpler than the concepts, and the baked GLB is
softer than the Cycles previews.

The shoes need work first: the uppers still carry the foot's toe bumps, and the panel borders are
blocky because materials are assigned per face. Build the upper from a proper shoe last before
the next character.
