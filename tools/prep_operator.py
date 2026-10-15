# Readies a Meshy Operator for rigging: grafts a separately modeled head onto the body at the
# collar, rebuilds body, head and pack light, and bakes their colour from the detailed originals.
# Run: blender -b --python tools/prep_operator.py -- <body.glb> <head.glb> <pack.glb> <out_dir>
#      [--options below]
# Writes <out_dir>/prepared.glb (body and head, one mesh) and <out_dir>/prepared-pack.glb, seated
# on his back in the same frame. Defaults are the protagonist's (2026-10-14). Lengths before
# --height are in the Meshy body's own units (it arrives about 1.9 tall, centred on the origin);
# measure a new character's head and collar heights first.
import argparse
import colorsys
import math
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix
from mathutils.bvhtree import BVHTree

args = argparse.ArgumentParser()
args.add_argument("body")
args.add_argument("head")
args.add_argument("pack")
args.add_argument("out_dir")
args.add_argument("--cut-z", type=float, default=0.715, help="body: everything above goes")
args.add_argument("--neck-z", type=float, default=0.62, help="body: bottom of the neck zone")
args.add_argument("--neck-half-width", type=float, default=0.16)
args.add_argument("--lapel-y", type=float, default=-0.04, help="body: lapels lie in front of this")
args.add_argument("--head-scale", type=float, default=0.196, help="body filter width / head filter width")
args.add_argument("--head-anchor", type=float, nargs=3, default=(-0.028, 0.0, -0.36),
                  help="a point on the head model (the filters' centre)")
args.add_argument("--body-anchor", type=float, nargs=3, default=(0.0, 0.0075, 0.69),
                  help="where that point goes on the body")
args.add_argument("--height", type=float, default=1.75)
args.add_argument("--pack-height", type=float, default=0.63, help="camera top to case bottom")
args.add_argument("--pack-bottom", type=float, default=1.0, help="metres above the ground")
args.add_argument("--body-faces", type=int, default=25000)
args.add_argument("--head-faces", type=int, default=20000)
args.add_argument("--pack-faces", type=int, default=12000)
args.add_argument("--texture", type=int, default=4096)
args.add_argument("--pack-texture", type=int, default=2048)
opts = args.parse_args(sys.argv[sys.argv.index("--") + 1:])


def load(path, name):
    bpy.ops.import_scene.gltf(filepath=path)
    mesh = [o for o in bpy.context.selected_objects if o.type == "MESH"][0]
    mesh.name = name
    mesh.data.transform(mesh.matrix_world)
    mesh.parent = None
    mesh.matrix_world = Matrix()
    return mesh


def apply(obj, modifier):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=modifier.name)


def select(objs, active):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = active


bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
body = load(opts.body, "body")
head = load(opts.head, "head")

# Meshy hands back millions of faces; a first cut keeps the rest of the run quick.
cut = head.modifiers.new("d", "DECIMATE")
cut.ratio = min(1, 400000 / len(head.data.polygons))
apply(head, cut)
head.data.transform(Matrix.Translation(opts.body_anchor) @ Matrix.Scale(opts.head_scale, 4)
                    @ Matrix.Translation([-c for c in opts.head_anchor]))

# Remove the body's old head. Above the cut it all goes; in the neck zone only the jacket stays,
# told apart by colour: the jacket is blue-teal, the old mask grey, the old skin orange.
img = [n.image for n in body.active_material.node_tree.nodes if n.type == "TEX_IMAGE"][0]
w, h = img.size
pixels = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)
bm = bmesh.new()
bm.from_mesh(body.data)
uv = bm.loops.layers.uv.active
bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z > opts.cut_z and abs(v.co.x) < 0.3],
                 context="VERTS")


def colour(face):
    u = sum(l[uv].uv.x for l in face.loops) / len(face.loops)
    v = sum(l[uv].uv.y for l in face.loops) / len(face.loops)
    return pixels[int(v * h) % h, int(u * w) % w][:3]


def in_zone(face):
    c = face.calc_center_median()
    return c.z > opts.neck_z and abs(c.x) < opts.neck_half_width


def jacket(rgb):
    return rgb[2] > rgb[0] * 1.15


def keep(face):
    rgb = colour(face)
    grey = max(rgb) - min(rgb) < 0.05 and colorsys.rgb_to_hsv(*rgb)[2] < 0.38
    return jacket(rgb) or (face.calc_center_median().y < opts.lapel_y and not grey)


bmesh.ops.delete(bm, geom=[f for f in bm.faces if in_zone(f) and not keep(f)], context="FACES")

# Pieces cut loose inside the zone that aren't mostly jacket are leftovers of the old mask.
seen, junk = set(), []
for start in bm.faces:
    if start.index in seen or not in_zone(start):
        continue
    stack, piece, escapes = [start], [], False
    seen.add(start.index)
    while stack:
        f = stack.pop()
        piece.append(f)
        for e in f.edges:
            for g in e.link_faces:
                if g.index in seen:
                    continue
                if not in_zone(g):
                    escapes = True
                    continue
                seen.add(g.index)
                stack.append(g)
    if not escapes and sum(jacket(colour(f)) for f in piece) < 0.6 * len(piece):
        junk += piece
bmesh.ops.delete(bm, geom=junk, context="FACES")

# Anything still hugging the new head is old mask or skin showing through it.
head_bm = bmesh.new()
head_bm.from_mesh(head.data)
tree = BVHTree.FromBMesh(head_bm)
bmesh.ops.delete(bm, geom=[f for f in bm.faces if in_zone(f)
                           and tree.find_nearest(f.calc_center_median(), 0.012)[0] is not None],
                 context="FACES")
bm.to_mesh(body.data)

# Real-world size, feet on the ground, centred.
co = np.concatenate([np.array([v.co[:] for v in o.data.vertices]) for o in (body, head)])
low, high = co.min(0), co.max(0)
to_world = Matrix.Scale(opts.height / (high[2] - low[2]), 4) @ Matrix.Translation(
    (-(low[0] + high[0]) / 2, -(low[1] + high[1]) / 2, -low[2]))
for o in (body, head):
    o.data.transform(to_world)

# Seat the pack: turned to face back, its padded panel against the jacket at shoulder-blade
# height. The panel sits about 45% of the pack's depth in front of the case's back face.
co = np.array([v.co[:] for v in body.data.vertices])
band = co[(co[:, 2] > opts.height * 0.63) & (co[:, 2] < opts.height * 0.83) & (np.abs(co[:, 0]) < 0.15)]
back_y = band[:, 1].max()
pack = load(opts.pack, "pack")
pc = np.array([v.co[:] for v in pack.data.vertices])
pack.data.transform(Matrix.Rotation(math.pi, 4, "Z")
                    @ Matrix.Scale(opts.pack_height / (pc[:, 2].max() - pc[:, 2].min()), 4))
pc = np.array([v.co[:] for v in pack.data.vertices])
low, high = pc.min(0), pc.max(0)
panel_y = high[1] - 0.45 * (high[1] - low[1])
pack.data.transform(Matrix.Translation(
    (-(low[0] + high[0]) / 2, back_y - panel_y + 0.01, opts.pack_bottom - low[2])))


def bake(sources, name, size):
    """Light copy of each source, joined, fresh UVs, diffuse colour baked from the sources.
    Shrinking Meshy's own UVs breaks them into speckles, so the colour is always rebaked."""
    lights = []
    for src, faces, voxel in sources:
        light = src.copy()
        light.data = src.data.copy()
        scene.collection.objects.link(light)
        if voxel:
            # Rebuilding as voxels gives a closed surface that shrinks cleanly. The body is too
            # open for it; its seams are welded instead.
            remesh = light.modifiers.new("r", "REMESH")
            remesh.mode = "VOXEL"
            remesh.voxel_size = voxel
            apply(light, remesh)
        else:
            select([light], light)
            bpy.ops.object.mode_set(mode="EDIT")
            bpy.ops.mesh.select_all(action="SELECT")
            bpy.ops.mesh.remove_doubles(threshold=0.001)
            bpy.ops.object.mode_set(mode="OBJECT")
        for _ in range(4):
            if len(light.data.polygons) <= faces * 1.1:
                break
            shrink = light.modifiers.new("d", "DECIMATE")
            shrink.ratio = faces / len(light.data.polygons)
            apply(light, shrink)
        lights.append(light)
    select(lights, lights[0])
    bpy.ops.object.join()
    out = bpy.context.view_layer.objects.active
    out.name = name
    while out.data.uv_layers:
        out.data.uv_layers.remove(out.data.uv_layers[0])
    out.data.uv_layers.new(name="UVMap")
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.002)
    bpy.ops.uv.pack_islands(rotate=True, margin=0.002)
    bpy.ops.object.mode_set(mode="OBJECT")
    image = bpy.data.images.new(name + "_base_color", size, size)
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    nodes = material.node_tree
    tex = nodes.nodes.new("ShaderNodeTexImage")
    tex.image = image
    nodes.links.new(tex.outputs["Color"], nodes.nodes["Principled BSDF"].inputs["Base Color"])
    nodes.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.8
    out.data.materials.clear()
    out.data.materials.append(material)
    nodes.nodes.active = tex
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 4
    settings = scene.render.bake
    settings.use_selected_to_active = True
    settings.cage_extrusion = 0.01
    settings.max_ray_distance = 0.03
    settings.margin = 8
    settings.use_pass_direct = settings.use_pass_indirect = False
    settings.use_pass_color = True
    select([s for s, _, _ in sources] + [out], out)
    bpy.ops.object.bake(type="DIFFUSE")
    image.pack()
    print(f"prep_operator: {name} {len(out.data.polygons)} faces")
    return out


figure = bake([(body, opts.body_faces, 0), (head, opts.head_faces, 0.003)], "operator", opts.texture)
pack_light = bake([(pack, opts.pack_faces, 0.002)], "operator_pack", opts.pack_texture)
for obj, file in ((figure, "prepared.glb"), (pack_light, "prepared-pack.glb")):
    select([obj], obj)
    bpy.ops.export_scene.gltf(filepath=f"{opts.out_dir}/{file}", export_format="GLB",
                              use_selection=True)
