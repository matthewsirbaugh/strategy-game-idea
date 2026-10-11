# Readies a Meshy model for the game: one mesh, real-world height, origin at the centre of its
# base, an optional triangle budget, exported as GLB with its textures.
# Run: blender -b --python tools/prep_prop.py -- <in.glb> <out.glb> --height 1.0 [--max-tris 8000]
import argparse
import sys

import bpy
from mathutils import Matrix, Vector

args = argparse.ArgumentParser()
args.add_argument("source")
args.add_argument("target")
args.add_argument("--height", type=float, required=True, help="metres, base to top")
args.add_argument("--max-tris", type=int, default=0)
opts = args.parse_args(sys.argv[sys.argv.index("--") + 1:])

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=opts.source)
meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
bpy.ops.object.select_all(action="DESELECT")
for mesh in meshes:
    mesh.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
if len(meshes) > 1:
    bpy.ops.object.join()
prop = bpy.context.view_layer.objects.active
# Imported glTF hierarchies carry their own transforms; flatten them into the mesh first.
bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM")
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

corners = [prop.matrix_world @ Vector(c) for c in prop.bound_box]
low = Vector((min(c.x for c in corners), min(c.y for c in corners), min(c.z for c in corners)))
high = Vector((max(c.x for c in corners), max(c.y for c in corners), max(c.z for c in corners)))
scale = opts.height / (high.z - low.z)
base = Vector(((low.x + high.x) / 2, (low.y + high.y) / 2, low.z))
prop.data.transform(Matrix.Translation(-base))
prop.data.transform(Matrix.Scale(scale, 4))
prop.location = (0, 0, 0)


def triangles() -> int:
    return sum(len(p.vertices) - 2 for p in prop.data.polygons)


before = triangles()
if opts.max_tris and before > opts.max_tris:
    decimate = prop.modifiers.new("budget", "DECIMATE")
    decimate.ratio = opts.max_tris / before
    bpy.ops.object.modifier_apply(modifier=decimate.name)

for other in [o for o in bpy.context.scene.objects if o != prop]:
    bpy.data.objects.remove(other, do_unlink=True)
bpy.ops.export_scene.gltf(filepath=opts.target, export_format="GLB", use_selection=False)

size = (high - low) * scale
print("PREP %s: %d -> %d triangles, %.2f x %.2f x %.2f m, %d materials" % (
    opts.target, before, triangles(), size.x, size.y, size.z, len(prop.data.materials)))
