# Readies a Meshy model for the game: one mesh, real-world height, origin at the centre of its
# base, an optional triangle budget, exported as GLB with its textures.
# Run: blender -b --python tools/prep_prop.py -- <in.glb> <out.glb> --height 1.0 [--max-tris 8000]
#      [--glow 0.75] lights up texels brighter than that, and saturated reds, as emission.
#      --glow 2 lights only the reds, for white bodies.
#      [--max-texture 4096] shrinks larger textures to that size, for load time.
#      [--glow-box x0 y0 z0 x1 y1 z1] limits the brightness test to faces inside that box (metres,
#      after scaling, Blender axes), for a screen on a white body.
import argparse
import sys

import bpy
from mathutils import Matrix, Vector

args = argparse.ArgumentParser()
args.add_argument("source")
args.add_argument("target")
args.add_argument("--height", type=float, required=True, help="metres, base to top")
args.add_argument("--max-tris", type=int, default=0)
args.add_argument("--glow", type=float, default=0.0, help="luminance above which the base colour glows")
args.add_argument("--glow-strength", type=float, default=4.0)
args.add_argument("--glow-box", type=float, nargs=6, default=None)
args.add_argument("--max-texture", type=int, default=0)
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



def box_mask(width, height):
    import numpy as np
    x0, y0, z0, x1, y1, z1 = opts.glow_box
    mask = np.zeros((height, width), dtype=bool)
    uv = prop.data.uv_layers.active.data
    for poly in prop.data.polygons:
        c = poly.center
        if x0 <= c.x <= x1 and y0 <= c.y <= y1 and z0 <= c.z <= z1:
            pts = [(uv[i].uv.x * width, uv[i].uv.y * height) for i in poly.loop_indices]
            for k in range(1, len(pts) - 1):
                fill_triangle(mask, pts[0], pts[k], pts[k + 1])
    return mask.ravel()


def fill_triangle(mask, a, b, c):
    import numpy as np
    x0, x1 = int(min(a[0], b[0], c[0])), int(max(a[0], b[0], c[0])) + 1
    y0, y1 = int(min(a[1], b[1], c[1])), int(max(a[1], b[1], c[1])) + 1
    ys, xs = np.mgrid[y0:y1, x0:x1] + 0.5
    area = (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1])
    if area == 0:
        return
    w0 = ((b[0] - xs) * (c[1] - ys) - (c[0] - xs) * (b[1] - ys)) / area
    w1 = ((c[0] - xs) * (a[1] - ys) - (a[0] - xs) * (c[1] - ys)) / area
    inside = (w0 >= 0) & (w1 >= 0) & (w0 + w1 <= 1)
    h, w = mask.shape
    sub = mask[max(y0, 0):min(y1, h), max(x0, 0):min(x1, w)]
    sub |= inside[max(-y0, 0):max(-y0, 0) + sub.shape[0], max(-x0, 0):max(-x0, 0) + sub.shape[1]]


def add_glow(material) -> None:
    import numpy as np
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    links = bsdf.inputs["Base Color"].links if bsdf else []
    if not links or links[0].from_node.type != "TEX_IMAGE":
        print("PREP glow skipped: %s has no base colour texture" % material.name)
        return
    texture = links[0].from_node
    source = texture.image
    width, height = source.size
    rgba = np.empty(width * height * 4, dtype=np.float32)
    source.pixels.foreach_get(rgba)
    rgba = rgba.reshape(-1, 4)
    r, g, b = rgba[:, 0], rgba[:, 1], rgba[:, 2]
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    # Meshy paints lit parts into the base colour; the bright band and red status lights are the lamps.
    bright = luminance > opts.glow
    if opts.glow_box:
        bright &= box_mask(width, height)
    lit = bright | ((r > 0.35) & (r > 2.5 * g) & (r > 2.5 * b))
    if not lit.any():
        print("PREP glow: nothing lit in %s" % material.name)
        return
    glow = np.zeros_like(rgba)
    glow[lit, :3] = rgba[lit, :3]
    glow[:, 3] = 1.0
    image = bpy.data.images.new(material.name + "_glow", width, height)
    image.pixels.foreach_set(glow.ravel())
    image.pack()
    node = material.node_tree.nodes.new("ShaderNodeTexImage")
    node.image = image
    material.node_tree.links.new(node.outputs["Color"], bsdf.inputs["Emission Color"])
    bsdf.inputs["Emission Strength"].default_value = opts.glow_strength
    print("PREP glow: %.1f%% of %s lit" % (100.0 * lit.mean(), material.name))


if opts.max_texture:
    for image in bpy.data.images:
        if max(image.size) > opts.max_texture:
            image.scale(opts.max_texture, opts.max_texture)

if opts.glow:
    for material in prop.data.materials:
        add_glow(material)

for other in [o for o in bpy.context.scene.objects if o != prop]:
    bpy.data.objects.remove(other, do_unlink=True)
bpy.ops.export_scene.gltf(filepath=opts.target, export_format="GLB", use_selection=False)

size = (high - low) * scale
print("PREP %s: %d -> %d triangles, %.2f x %.2f x %.2f m, %d materials" % (
    opts.target, before, triangles(), size.x, size.y, size.z, len(prop.data.materials)))
