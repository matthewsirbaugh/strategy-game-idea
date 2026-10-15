# Renders a model at fixed review framings, so before-and-after shots of a change line up.
# Run: blender -b --python tools/render_review.py -- <model.glb> <out_dir> [--options below]
# Writes <out_dir>/<prefix><view>.png. Eevee, orthographic, plain grey world, as the earlier
# captures were made. Views look at the model, which faces -Y in Blender (+Z in glTF).
import argparse
import math
import sys

import bpy
from mathutils import Euler, Vector

VIEWS = {  # azimuth from the front toward his left, elevation
    "front": (0, 0), "three-quarter": (35, 0), "side": (90, 0), "back": (180, 0),
    "overhead": (35, 50), "top": (0, 90), "bottom": (0, -90),
}

args = argparse.ArgumentParser()
args.add_argument("model")
args.add_argument("out_dir")
args.add_argument("--views", nargs="+", default=["front", "three-quarter", "side", "back", "overhead"],
                  choices=list(VIEWS))
args.add_argument("--clip", help="a clip GLB for the same skeleton: pose the model from it")
args.add_argument("--frame", type=float, default=0, help="the clip's frame")
args.add_argument("--focus", help="a bone to frame instead of the whole model")
args.add_argument("--reach", type=float, default=0.08,
                  help="metres: the frame's centre lies this far past the focus bone's joint, away from its parent")
args.add_argument("--size", type=float, help="metres across the frame; default fits the whole model")
args.add_argument("--prefix", default="")
args.add_argument("--resolution", type=int, default=1024)
opts = args.parse_args(sys.argv[sys.argv.index("--") + 1:])


def bring(path):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    added = [o for o in bpy.data.objects if o not in before]
    # The importer adds an Icosphere as the bones' display shape; it isn't part of the model.
    for o in [o for o in added if o.name.startswith("Icosphere")]:
        bpy.data.objects.remove(o)
    return [o for o in bpy.data.objects if o not in before]


bpy.ops.wm.read_factory_settings(use_empty=True)
parts = bring(opts.model)
armature = next((o for o in parts if o.type == "ARMATURE"), None)
if opts.clip:
    before = set(bpy.data.actions)
    clip_parts = bring(opts.clip)
    action = [a for a in bpy.data.actions if a not in before][0]
    for o in clip_parts:
        bpy.data.objects.remove(o)
    armature.animation_data_create()
    armature.animation_data.action = action
    if armature.animation_data.action_slot is None:
        armature.animation_data.action_slot = action.slots[0]
    bpy.context.scene.frame_set(int(opts.frame), subframe=opts.frame % 1)
bpy.context.view_layer.update()

if opts.focus:
    bone = armature.pose.bones[opts.focus]
    joint = armature.matrix_world @ bone.head
    away = (joint - armature.matrix_world @ bone.parent.head).normalized()
    centre = joint + away * opts.reach
    size = opts.size or 0.3
else:
    graph = bpy.context.evaluated_depsgraph_get()
    points = []
    for o in parts:
        if o.type == "MESH":
            evaluated = o.evaluated_get(graph)
            points += [evaluated.matrix_world @ v.co for v in evaluated.to_mesh().vertices]
    low = Vector([min(p[i] for p in points) for i in range(3)])
    high = Vector([max(p[i] for p in points) for i in range(3)])
    centre = (low + high) / 2
    size = opts.size or max(high - low) * 1.1
    if armature:
        # Framed by height and hips, so a change at the hands doesn't reframe the whole picture.
        hips = armature.matrix_world @ armature.pose.bones["Hips"].head
        centre = Vector((hips.x, hips.y, centre.z))
        size = opts.size or (high.z - low.z) * 1.2

scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = scene.render.resolution_y = opts.resolution
scene.world = bpy.data.worlds.new("grey")
scene.world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.5, 0.5, 0.5, 1)
scene.view_settings.view_transform = "Standard"
camera = bpy.data.objects.new("camera", bpy.data.cameras.new("camera"))
scene.collection.objects.link(camera)
scene.camera = camera
camera.data.type = "ORTHO"
camera.data.ortho_scale = size
camera.data.clip_end = 100
for view in opts.views:
    azimuth, elevation = (math.radians(a) for a in VIEWS[view])
    # Camera rotation: tilt from looking along -Z to looking level (90°) or down (90° - elevation),
    # then turn to the azimuth; the front view looks along +Y.
    camera.rotation_euler = Euler((math.pi / 2 - elevation, 0, azimuth))
    camera.location = centre - camera.rotation_euler.to_matrix() @ Vector((0, 0, -10))
    scene.render.filepath = f"{opts.out_dir}/{opts.prefix}{view}.png"
    bpy.ops.render.render(write_still=True)
