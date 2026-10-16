# Operator finger rig: relaxed, poseable hands

- Feeds: [character-models.md](character-models.md) (the Meshy pilot, all 2026-10-13/14 findings)
- Status: built, 2026-10-15 ([Findings](#findings)). Bryson chose option B, finger bones added in
  Blender; this plan was written by Claude and approved by Bryson.
- Next action: none. Bryson stopped animation work on 2026-10-15 (below). The writer and the
  developer get fingers from the same tool.

## Terms

- **Rest pose**: the shape the mesh and skeleton have before any animation moves them. Ours is the T-pose.
- **Weights**: how strongly each bone moves each vertex. Per vertex they sum to 1; glTF and Godot carry 4 per vertex.
- **MCP / PIP / DIP**: a finger's three joints, knuckle to tip. The thumb's are CMC (at the wrist), MCP, IP.
- **Curl axis**: the axis a finger bends around, running across the palm.

## Context

The protagonist is the Meshy pilot for the Operators (see `explorations/character-models.md`, all
2026-10-13/14 findings). He is modeled, grafted, cleaned, rigged and in the model viewer as a proof
(`game/assets/units/operator_protagonist/`). When he runs, his fingers stay splayed wide open.

Cause (verified 2026-10-14): Meshy's auto-rig gives each hand one bone, `LeftHand` / `RightHand`, and no
finger bones. Its rigging API has no option for more. The fingers are rigid and frozen in the T-pose spread.

Bryson chose option B (2026-10-14): add finger bones ourselves in Blender, with a relaxed curl as his
default, so the hands look natural now and can grip, point or type later (he's a hacker: tablets,
wall panels). Generating new hands with Meshy was rejected for now: a new hand is still one rigid lump,
and the join would sit on bare forearm skin.

Bryson also wants Meshy text-to-motion tried **after** this (his note, 2026-10-14). That work is
sketched at the end so this plan doesn't block it.

## The goal, as Bryson would judge it

- Running, walking and standing, his hands read as relaxed human hands from the game camera and up close.
- Nothing else about him changes: body, pack, texture, height, clips. The established look is part of
  the deliverable (AGENTS.md); compare before and after in the same camera framing.
- The step is repeatable: the writer and the developer go through the same pipeline next.
- No Meshy credits are needed. If you find a reason to spend some, ask first.

## Where things stand (read before touching anything)

| What | Where |
|---|---|
| Game asset: armature, cleaned mesh, pack skinned to `Spine`, two materials | `game/assets/units/operator_protagonist/operator_protagonist.glb` + `.json` record |
| Clips, armature only, no finger tracks | `game/assets/units/operator_protagonist/walk.glb`, `run.glb` |
| The pipeline that made it | `tools/prep_operator.py` (graft, tidy, remesh, bake; `--rig` moves Meshy's rig onto the re-baked mesh) |
| Meshy's raw rigged download | `art/sources/units/operator_protagonist/meshy-rig.glb`: **gitignored, local only**, re-downloadable from rig task `01a13d40-ea1c-778e-b14f-51718895ccfe` until about 2026-10-17 21:50 EDT |
| Viewer clip loading | `game/preview/model_viewer/stage.gd` `_attach_clip`: matches tracks to skeleton bones by name; Stop calls `reset_bone_poses()` (back to rest) |
| Battle character loading | `game/art/toon_model.gd` `_library` / `_neutral`; `game/art/character_rig.gd` `retarget`, `attach_pack` |
| Asset contract | `game/assets/README.md` |
| Reference for how relaxed hands should look | `art/sources/units/operator_protagonist/01-main.png` (front and back views, hands at his sides) |

Work from the game asset GLB, not `meshy-rig.glb`: it already holds the cleaned mesh, the weights and
the pack, it's in git, and it doesn't expire.

## Recommended approach (the calls inside it are yours to make)

### 1. Confirm with Bryson first (numbered, in text; he doesn't want clickable question dialogs)
1. Resting hand shape: a relaxed half-curl, as hands hang when walking, is the recommendation. A loose fist reads tenser. He hasn't answered this yet.
2. Should the writer and the developer get fingers the same way? Probably yes; it decides whether you build a tool or a one-off.

### 2. Build it as a tool step
Suggested: `tools/add_fingers.py`, run as `blender -b --python tools/add_fingers.py -- <rigged.glb> <out.glb> [--curl ...]`.
Either have `prep_operator.py --rig` call it, or document the order in README's tool index. A separate file
keeps `prep_operator.py` (already about 480 lines) from growing, and lets you re-run fingers alone.
Reuse the patterns in `prep_operator.py`'s `--rig` block (`bring`, `select`, `apply`, the export call).
Follow the shared coding guide's **Working standard** and AGENTS' comment and test rules: comments only
for the non-obvious why, and no tests unless the math earns one.

### 3. Find the fingers
- Hand vertices: those whose largest weight is `LeftHand` / `RightHand`. Skip the pack's faces; the mesh has two materials.
- Work in metres (`armature.matrix_world`). Meshy's armature object is at 0.01 scale, so edit-bone coordinates are in its local units (about ×100).
- Axes: in the T-pose, palms face down (−Z), fingers point along ±X, and the front is −Y (glTF +Z forward becomes Blender −Y), so the thumb is on the −Y side. Check this rather than trusting it: work out each hand's own axis from the `Hand` bone, or a principal-component fit of its vertices.
- The finger roots: slice the hand at increasing distance from the wrist and count connected pieces. Where four separate pieces appear, the fingers begin; the thumb branches off earlier, on the −Y side. **Weld first**: Meshy's exports split vertices along texture seams, so every vertex looks like an edge until merged (`bmesh.ops.remove_doubles`, about 0.3 mm). If decimation fused the fingers, fall back to binning vertices by position across the hand's width.

### 4. Make the bones
- Use Mixamo's finger names: `LeftHandThumb1`–`3`, `LeftHandIndex1`–`3`, `LeftHandMiddle1`–`3`, `LeftHandRing1`–`3`, `LeftHandPinky1`–`3` (optional `4` tip bones), and the `Right…` equivalents, each parented to `LeftHand` / `RightHand`. Meshy's other bone names already follow Mixamo minus the `mixamorig:` prefix, so these keep the door open to Mixamo or motion-capture clips that include fingers.
- Joints along each finger's centre line. A starting split: proximal 45%, middle 30%, distal 25% of the finger's length. The thumb's first bone starts near the wrist.
- **Set each bone's roll so the curl axis is the same local axis on every finger.** Then a curl is one rotation, whether authored in Blender or driven by code in Godot later (for grips).

### 5. Weights
- Start with procedural weights: project each finger vertex onto its finger's centre line and assign it to the segment it falls in, blending across each joint with a short smooth falloff (about ±15% of a segment). The knuckle (MCP) blends with the `Hand` bone. Palm and the back of the hand stay on `Hand`. Normalise, keep no more than 4 influences, and smooth lightly within the hand only.
- Blender's Automatic Weights (bone heat) is the alternative. It often fails ("failed to find solution") on meshes that aren't watertight, which Meshy's are. If you try it, do it on the hand region only.

### 6. The relaxed curl becomes the rest pose
- Pose the finger bones into the curl, apply the armature to the mesh (a copy of the Armature modifier, applied), then make the pose the rest pose (`bpy.ops.pose.armature_apply`). Only the finger bones move, so nothing else changes.
- Why rest and not an animation: Meshy's walk and run have no finger tracks, so finger bones sit at rest during them. The viewer's Stop resets to rest. Making the curl the rest pose makes it the default everywhere with no code.
- Starting angles (MCP / PIP / DIP), increasing from index to pinky, the natural cascade: index 15/30/15, middle 20/35/18, ring 25/40/20, pinky 30/45/22. Thumb: drawn in toward the index (about 20° at the CMC), MCP 15, IP 15. Also close the finger spread by about 5–10°. **These are starting points, not answers.** Judge against `01-main.png` and real hands, and tune.

### 7. Godot: two code facts to handle
- **`CharacterRig.retarget` (`game/art/character_rig.gd`) mishandles bones the source rig lacks.** `from.find_bone()` returns −1, and GDScript arrays accept −1 as "last element", so finger bones would silently copy another bone's motion. This matters once the protagonist enters the battle through `ToonModel`. The viewer doesn't use it. Fix: give bones missing from the source their rest rotation. Check the Requests table for claims before editing; `character_rig.gd` is shared code.
- Clips without finger tracks leave fingers wherever the previous clip put them. Harmless today, since nothing animates fingers. Once a gesture clip exists, fill the missing bone tracks with rest when building the library (`ToonModel._library`). `_neutral` already keys every bone at rest.

### 8. Records, by AGENTS.md
Update the asset `.json` notes, and add a dated finding to `character-models.md` or the new exploration
file. Commit the tool, the asset and the captures separately so each can be undone alone. Push. Restart
the viewer.

## Verification

- **Weights:** every hand vertex's weights sum to 1; no finger vertex is weighted to a neighbouring finger; palm and wrist vertices sit within about 0.1 mm of where they were in the rest pose.
- **Stress test in Blender:** bend each finger bone 90° and look close up for collapsed knuckles, tearing, or the thumb base caving in. Also check the cuff and wrist haven't moved.
- **Same-framing comparisons**, before and after: the hand close-up mid-run (side and front, as rendered 2026-10-14), rest-pose palm and back of hand, full body three-quarter, and the overhead game angle. Rebuild the render helper (below); the session's scratch scripts are gone.
- **Godot:** `godot --headless --path game --import`, `tools/check.sh`, then the viewer (`godot --path game/preview/model_viewer`): play walk and run, Stop, and check the hands stay relaxed throughout.
- Report honestly what was rendered, what was run, and what was looked at in the viewer.

## Lessons from building him (each cost time once)

- **The skeleton is stored at 0.01 scale.** Blender's exporter misplaces objects hung on its bones, which is why the pack is skinned to `Spine` inside the mesh.
- **Meshy meshes are split along texture seams.** Weld before any topology work, and never write a welded head back before its voxel rebuild.
- **Shrinking a Meshy mesh scrambles its texture.** Always re-bake the colour (`prep_operator.py`'s `bake()`).
- **Voxel rebuilds at 3 mm lose 3 mm details**, like the glasses frames. The head uses 1.5 mm.
- **Rules by coordinates break; rules by connected piece and colour hold**, verified with a render after every step. To find which mesh a stray pixel belongs to, ray-cast through it (`scene.ray_cast` from the camera). A scrap can be another mesh's shadow: render each part alone.
- **Blender 5.2 here:** the Eevee engine id is `'BLENDER_EEVEE'`. The BlenderMCP add-on prints harmless noise in `-b` mode.
- **Render recipe:** Eevee, orthographic camera, plain grey world, 1024², azimuths 0/35/90/180 and an overhead at 50°. Cycles plus a key, fill and warm rim light, exposure −1, AgX Punchy, for lit beauty shots. Worth saving as a small `tools/render_review.py`. Your call; ask Bryson if unsure.

## Resources

- Blender Python API: `bpy.types.EditBone` (head, tail, roll, parent), `bpy.types.VertexGroup.add`, `bpy.ops.pose.armature_apply`, `bpy.types.DataTransferModifier` (already used in `prep_operator.py`): https://docs.blender.org/api/current/
- Blender manual, armature deform parenting and Automatic Weights: https://docs.blender.org/manual/en/latest/animation/armatures/skinning/parenting.html
- glTF 2.0 skins (joints and weights, 4 per set): https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#skins
- Godot 4 `Skeleton3D` and `AnimationPlayer`: https://docs.godotengine.org/en/stable/classes/class_skeleton3d.html
- Meshy rigging, animation and text-to-motion: https://docs.meshy.ai/en/api/rigging, https://docs.meshy.ai/en/api/animation, https://docs.meshy.ai/en/api/text-to-motion
- Hand anatomy for posing: look up "relaxed hand posture finger cascade", and look at your own hand hanging at your side.

## Fallbacks, if it doesn't come out well (Bryson decides)

- **Fingers too fused to separate:** curl the hand as one group (all four fingers on shared bones), or have Astra draw relaxed hands and model them in Meshy, attached at the wrist. That needs a brief, a request and about 30 credits.
- **Knuckles crease badly:** add a helper bone or adjust the weight falloff before reaching for a new mesh.
- **A proper finger rig everywhere:** re-rig with Mixamo (free; Bryson uploads) or Reallusion AccuRIG (free desktop app). That changes the pipeline, so it's an architecture decision with Bryson.

## Findings

### 2026-10-15 — Built (Claude; Blender and Godot, no credits)

Bryson's answers (2026-10-15): the relaxed half-curl of the reference's front view; a tool, so the
writer and the developer get fingers the same way; knuckle loops; delete the two stale textures.

- `tools/add_fingers.py` sweeps each hand from the fingertips toward the wrist and takes each digit
  where it meets the rest. It adds four Mixamo-named bones per digit and three rings at each middle
  and end joint. Finger weights come out of the old Hand weight only. The curl is applied, then made
  the rest pose. It refuses a rig that already has fingers, and rebuilds the asset byte for byte.
- `tools/render_review.py` renders the recipe below at fixed framings: posed from a clip, or framed
  on a bone. Full-body shots are framed by height and hips, so a change at the hands doesn't
  reframe the whole picture.
- `CharacterRig.retarget` gives bones the source rig lacks their rest pose. Measured on his clip
  library in Godot: the old code put finger keys in the five bought clips up to 180° off rest; now
  they are within 0.4°, which is float noise.

| Check | Result |
|---|---|
| Digits found | 5 per hand |
| Vertices without finger weights | moved at most 0.0008 mm |
| The 24 existing joints | rest and inverse binds unchanged (float noise, under 0.01 mm) |
| Weight sums | 1, within 1e-7 |
| Finger skin weighted to another digit | none; only the thumb–index web follows both |
| Faces | 58,186 → 59,602 |
| Full-body renders, 7 framings | changed pixels only at the two hands |
| Godot | import and `tools/check.sh` pass. Through `ToonModel`, Neutral stands with relaxed hands. The Model Library's runtime loader sees the curl as rest; Run has no finger tracks; Still returns to the curl |

Changes from the starting points above:
- His T-pose fingers fan wide from the middle finger: index 20–26°, ring 26–29°, pinky 50–57°,
  thumb 42–49°. Closing 60% of that folded the palm's big triangles, so 60% of the spread stays
  and the thumb turns in 12°, not 20°.
- Palm weights are smoothed three times across palm skin only. Long palm triangles reach far up
  the fingers; smoothing that drew on finger skin gave palm vertices fingertip weights.
- The curl angles stay as planned; they match `01-main.png`'s front view.

Limits:
- A tight fist (each joint 40° past rest) creases into sharp facets at the knuckles: the Meshy hand
  is low-poly. Relaxed and flat poses are clean. This matters once grip or fist gestures exist; the
  fallbacks below apply then.
- The pinky curls most (97° in all) and tucks under the palm from some angles.
- His GLB has no AnimationPlayer, so the battle's `ToonModel` can't take him as he is; the check
  added one. Wiring him into the battle remains Bryson's call.

Captures, before and after in the same framings, from Blender and in Godot:
[operator-finger-rig-2026-10-15](../art/previews/operator-finger-rig-2026-10-15/).

## After the hands: Meshy text-to-motion (not continuing)

Bryson, 2026-10-15: no more work on animations for now. They move past V2; he'll return to them as
a finishing step.

- `POST /openapi/v1/text-to-motion` takes a prompt (up to 400 characters) and a duration (2–10 s), in prime mode (10 credits, FBX) or swift (3 credits, BVH). Apply the result with `POST /openapi/v1/animations` using `rig_task_id` and `motion_task_id`; library clips cost 3 credits, and generated ones may too. Results expire after 3 days.
- It needs a Meshy rig task within its retention. `01a13d40…` expires around 2026-10-17 21:50 EDT. After that, re-rig `prepared.glb` (5 credits) by posting it to `/openapi/v1/rigging` with the model embedded as base64. The MCP rig tool only takes URLs.
- The Meshy key lives in the macOS Keychain (`security find-generic-password -a "$USER" -s meshy-api-key -w`). Bryson approved reading it for the 2026-10-14 rig call only, so **ask before each new paid call**, and never print or store the key.
- Meshy applies clips to its own finger-less rig. Download them armature-only (`extract_armature`) and check the bone names match; finger bones then sit at the relaxed rest.
- Bryson writes the motion prompts; that's design. Stealth ideas offered so far: crouched sneak, peeking around a corner, kneeling to type on a wall panel, a wary idle.

## Other open threads, not part of this task

- Keep the 4.2-million-face full-detail scene for portraits? Bryson hasn't answered. It's over 100 MB, so it would be gitignored.
- The pack's waist strap floats beside the jacket. The filter grilles are soft.
- The protagonist isn't in the battle yet, only the viewer. Wiring him in through `ToonModel` needs the `retarget` fix above, and Bryson's go-ahead.
- The writer and the developer need their own Meshy-input requests to Astra, modelled on Requests 25 and 27 (the briefs `art/briefs/operator-meshy-inputs.md` and `operator-protagonist-head.md`). Include a side view of everything and a separate head from the start.
