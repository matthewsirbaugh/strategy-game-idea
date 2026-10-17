# Readies a Meshy Operator for rigging: grafts a separately modeled head onto the body at the
# collar, rebuilds body, head and pack light, and bakes their colour from the detailed originals.
# Run: blender -b --python tools/prep_operator.py -- <body.glb> <head.glb> <pack.glb> <out_dir>
#      [--options below]
# Writes <out_dir>/prepared.glb (body and head, one mesh) and <out_dir>/prepared-pack.glb, seated
# on his back in the same frame. With --rig, also <out_dir>/rigged.glb: that rig's weights copied
# onto this mesh, the pack skinned to Spine, ready for game/assets/units/. Defaults are the protagonist's (2026-10-14). Lengths before
# --height are in the Meshy body's own units (it arrives about 1.9 tall, centred on the origin);
# measure a new character's head and collar heights first.
import argparse
import colorsys
import math
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector
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
args.add_argument("--collar-z", type=float, default=1.40, help="metres: the collar's cut edge is above this")
args.add_argument("--hairline-z", type=float, default=1.63, help="metres: scalp above this is painted hair")
args.add_argument("--rig", help="Meshy's rigged GLB of an earlier run: moves its rig onto this run's mesh")
args.add_argument("--pack-height", type=float, default=0.63, help="camera top to case bottom")
args.add_argument("--pack-bottom", type=float, default=1.0, help="metres above the ground")
args.add_argument("--body-faces", type=int, default=25000)
args.add_argument("--head-faces", type=int, default=20000)
args.add_argument("--pack-faces", type=int, default=12000)
args.add_argument("--head-voxel", type=float, default=0.0015,
                  help="metres; at 3 mm the glasses frames survive only by luck")
args.add_argument("--neck-keep", choices=["jacket", "clothes"], default="jacket",
                help="neck zone: keep only the blue-teal jacket, or everything but skin and --old-mask")
args.add_argument("--old-mask", type=float, nargs=3, help="clothes mode: the body's old mask colour, dropped")
args.add_argument("--no-scalp", action="store_true", help="leave the head's skin alone: scalp meant to show")
args.add_argument("--no-specks", action="store_true", help="skip repainting orange specks as jacket")
args.add_argument("--glasses-box", type=float, nargs=6,
                help="head model units, x0 x1 y0 y1 z0 z1: brass and black faces inside skip the voxel rebuild")
args.add_argument("--glasses-faces", type=int, default=8000)
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
glasses = None
if opts.glasses_box:
    # Long curls need coarse voxels to survive, which wire frames don't: a copy goes round the
    # rebuild. Cutting them out instead would leave holes, and the voxels hollow an open head.
    x0, x1, y0, y1, z0, z1 = opts.glasses_box
    tex = [n.image for n in head.active_material.node_tree.nodes if n.type == "TEX_IMAGE"][0]
    gw, gh = tex.size
    gpx = np.empty(gw * gh * 4, dtype=np.float32)
    tex.pixels.foreach_get(gpx)
    gpx = gpx.reshape(gh, gw, 4)
    me = head.data
    n = len(me.polygons)
    cen = np.empty(n * 3, dtype=np.float32)
    me.polygons.foreach_get("center", cen)
    cen = cen.reshape(n, 3)
    uvs = np.empty(len(me.loops) * 2, dtype=np.float32)
    me.uv_layers.active.data.foreach_get("uv", uvs)
    starts = np.empty(n, dtype=np.int32)
    me.polygons.foreach_get("loop_start", starts)
    u = uvs.reshape(-1, 2)[starts]
    rgb = gpx[(u[:, 1] * gh).astype(int) % gh, (u[:, 0] * gw).astype(int) % gw, :3]
    r, g, b = rgb.T
    hi = rgb.max(1)
    brass = (r > g) & (g > b) & ((hi - rgb.min(1)) / np.maximum(hi, 1e-6) > 0.3) & (hi > 0.5) & (g > 0.7 * r)
    inside = ((cen[:, 0] > x0) & (cen[:, 0] < x1) & (cen[:, 1] > y0) & (cen[:, 1] < y1)
              & (cen[:, 2] > z0) & (cen[:, 2] < z1))
    pick = inside & (brass | (hi < 0.08))
    me.vertices.foreach_set("select", np.zeros(len(me.vertices), dtype=bool))
    me.edges.foreach_set("select", np.zeros(len(me.edges), dtype=bool))
    me.polygons.foreach_set("select", pick)
    bpy.context.tool_settings.mesh_select_mode = (False, False, True)
    select([head], head)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.duplicate()
    bpy.ops.mesh.separate(type="SELECTED")
    bpy.ops.object.mode_set(mode="OBJECT")
    glasses = [o for o in bpy.context.selected_objects if o != head][0]
    print(f"prep_operator: glasses {len(glasses.data.polygons)} faces, head {len(head.data.polygons)}")
for part in [head] + ([glasses] if glasses else []):
    part.data.transform(Matrix.Translation(opts.body_anchor) @ Matrix.Scale(opts.head_scale, 4)
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
    if opts.neck_keep == "clothes":
        mask = opts.old_mask is not None and np.abs(rgb - opts.old_mask).max() < 0.08
        return not skinlike(rgb[None])[0] and not mask
    return rgb[2] > rgb[0] * 1.15


def skinlike(rgb):
    """Skin, and the orange Meshy smears where it guessed: warm and saturated."""
    hi, lo = rgb.max(-1), rgb.min(-1)
    return ((rgb[..., 0] > rgb[..., 1]) & ((hi - lo) / np.maximum(hi, 1e-6) > 0.35) & (hi > 0.25)
            & (rgb[..., 0] - rgb[..., 2] > 0.12))


def keep(face):
    rgb = colour(face)
    if opts.neck_keep == "clothes":
        return jacket(rgb)
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
for o in [body, head] + ([glasses] if glasses else []):
    o.data.transform(to_world)


# The tidy-up, in metres from here on. Every step was needed on the protagonist (2026-10-14).
def pixels_of(obj):
    image = [n.image for n in obj.active_material.node_tree.nodes if n.type == "TEX_IMAGE"][0]
    flat = np.empty(image.size[0] * image.size[1] * 4, dtype=np.float32)
    image.pixels.foreach_get(flat)
    return image, flat.reshape(image.size[1], image.size[0], 4)


def centre_colour(face, uv, px):
    h, w = px.shape[:2]
    u = sum(l[uv].uv.x for l in face.loops) / len(face.loops)
    v = sum(l[uv].uv.y for l in face.loops) / len(face.loops)
    return px[int(v * h) % h, int(u * w) % w, :3]


def patches(bm, flagged):
    seen, found = set(), []
    for start in bm.faces:
        if start.index in seen or not flagged(start):
            continue
        stack, piece = [start], []
        seen.add(start.index)
        while stack:
            f = stack.pop()
            piece.append(f)
            for e in f.edges:
                for g in e.link_faces:
                    if g.index not in seen and flagged(g):
                        seen.add(g.index)
                        stack.append(g)
        found.append(piece)
    return found


def repaint(faces, uv, px, colour):
    """Recolours the skin-like texels under the given faces."""
    h, w = px.shape[:2]
    cells = []
    for f in faces:
        loops = list(f.loops)
        for i in range(1, len(loops) - 1):
            p = np.array([(l[uv].uv.x * w, l[uv].uv.y * h) for l in (loops[0], loops[i], loops[i + 1])])
            (x0, y0), (x1, y1) = np.floor(p.min(0)).astype(int), np.ceil(p.max(0)).astype(int)
            xs, ys = np.meshgrid(np.arange(x0, x1 + 1), np.arange(y0, y1 + 1))
            q = np.stack([xs.ravel() + 0.5, ys.ravel() + 0.5], 1) - p[0]
            e1, e2 = p[1] - p[0], p[2] - p[0]
            det = e1[0] * e2[1] - e1[1] * e2[0]
            if abs(det) < 1e-9:
                continue
            a = (q[:, 0] * e2[1] - q[:, 1] * e2[0]) / det
            b = (e1[0] * q[:, 1] - e1[1] * q[:, 0]) / det
            inside = (a >= -0.05) & (b >= -0.05) & (a + b <= 1.05)
            cells.append(np.stack([ys.ravel()[inside] % h, xs.ravel()[inside] % w], 1))
    if cells:
        cells = np.unique(np.concatenate(cells), axis=0)
        hit = skinlike(px[cells[:, 0], cells[:, 1], :3])
        px[cells[hit, 0], cells[hit, 1], :3] = colour


def centre(piece):
    return sum((f.calc_center_median() for f in piece), Vector()) / len(piece)


# Head: scalp showing between the curls becomes hair. The face, ears and filter rims are large
# patches; scalp shows in small ones above the hairline.
if not opts.no_scalp:
    image, px = pixels_of(head)
    bm = bmesh.new()
    bm.from_mesh(head.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0003)
    uv = bm.loops.layers.uv.active
    skin = {f.index for f in bm.faces if skinlike(centre_colour(f, uv, px))}
    dark = np.array([centre_colour(f, uv, px) for f in bm.faces if f.calc_center_median().z > opts.hairline_z])
    hair = np.median(dark[dark.max(1) < 0.15], 0)
    repaint([f for piece in patches(bm, lambda f: f.index in skin)
             if (len(piece) < 400 and centre(piece).z > opts.hairline_z)
             or (len(piece) < 60 and centre(piece).y > 0.03 and centre(piece).z > opts.collar_z + 0.08)
             for f in piece], uv, px, hair)
    image.pixels.foreach_set(px.ravel())
    image.pack()
    bm.free()  # texture only: the welded head would rebuild without its thin parts, the glasses

image, px = pixels_of(body)
bm = bmesh.new()
bm.from_mesh(body.data)
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0003)
uv = bm.loops.layers.uv.active

# Small holes in the upper jacket get filled; the lapel edges at the front are open on purpose.
# A filled face takes one point of its rim's texture: its corners' own UVs can span the sheet.
rims, seen = [], set()
for start in (e for e in bm.edges if e.is_boundary):
    if start in seen:
        continue
    stack, rim = [start], []
    seen.add(start)
    while stack:
        e = stack.pop()
        rim.append(e)
        for v in e.verts:
            for nxt in v.link_edges:
                if nxt.is_boundary and nxt not in seen:
                    seen.add(nxt)
                    stack.append(nxt)
    rims.append(rim)
filled = set()
for rim in rims:
    middle = sum((e.verts[0].co for e in rim), Vector()) / len(rim)
    if sum(e.calc_length() for e in rim) < 0.25 and middle.z > opts.height * 0.69 and middle.y > -0.04:
        new = bmesh.ops.holes_fill(bm, edges=rim, sides=0)["faces"]
        for f in new:
            outside = [x for l in f.loops for x in l.vert.link_loops if x.face not in new]
            for l in f.loops:
                if outside:
                    l[uv].uv = outside[0][uv].uv.copy()
            filled.add(f)

# The collar's cut edge, straightened along itself so it reads as a hem, not a saw.
hem = [v for v in bm.verts if v.is_boundary and v.co.z > opts.collar_z and abs(v.co.x) < 0.2]
for _ in range(10):
    moved = {}
    for v in hem:
        ends = [e.other_vert(v) for e in v.link_edges if e.is_boundary]
        if len(ends) == 2:
            moved[v] = v.co * 0.5 + (ends[0].co + ends[1].co) * 0.25
    for v, co in moved.items():
        v.co = co

# Old collar inside or hugging the new neck shadows it in jagged shapes; so do loose scraps
# of the old head left above the collar.
head_bm.free()
head_bm = bmesh.new()
head_bm.from_mesh(head.data)
tree = BVHTree.FromBMesh(head_bm)


def against_neck(f):
    c = f.calc_center_median()
    if c.z < opts.collar_z + 0.04 or abs(c.x) > 0.17:
        return False
    loc, normal, _, dist = tree.find_nearest(c, 0.05)
    return loc is not None and ((c - loc).dot(normal) < 0 or dist < 0.008)


bmesh.ops.delete(bm, geom=[f for f in bm.faces if against_neck(f)], context="FACES")
scraps = [piece for piece in patches(bm, lambda f: True)
          if len(piece) < 3000 and min(f.calc_center_median().z for f in piece) > opts.collar_z + 0.04]
bmesh.ops.delete(bm, geom=[f for piece in scraps for f in piece], context="FACES")

# Orange specks on the shoulders and the old neck inside the collar become jacket. The piping
# is orange too, but it runs along the pale lining; specks sit in the dark jacket.
bm.faces.ensure_lookup_table()
skin = {f.index for f in bm.faces if f not in filled and skinlike(centre_colour(f, uv, px))}
cloth = np.array([centre_colour(f, uv, px) for f in bm.faces
                  if opts.height * 0.63 < f.calc_center_median().z < opts.height * 0.77
                  and f.calc_center_median().y > 0.05])
fill = None if opts.no_specks else np.median(cloth[cloth[:, 2] > cloth[:, 0] * 1.1], 0)


def on_lining(piece):
    ids = {f.index for f in piece}
    rim = [g for f in piece for e in f.edges for g in e.link_faces if g.index not in ids]
    pale = 0
    for g in rim:
        rgb = centre_colour(g, uv, px)
        pale += rgb.max() > 0.33 and (rgb.max() - rgb.min()) / max(rgb.max(), 1e-6) < 0.3
    return pale > 0.1 * max(len(rim), 1)


stray = []
for piece in [] if opts.no_specks else patches(bm, lambda f: f.index in skin):
    c = centre(piece)
    inside_collar = c.z > opts.collar_z and abs(c.x) < 0.2 and c.y > -0.02
    speck = len(piece) < 150 and c.z > opts.height * 0.69 and abs(c.x) < 0.35 and not on_lining(piece)
    if inside_collar or speck:
        stray += piece
repaint(stray, uv, px, fill)
image.pixels.foreach_set(px.ravel())
image.pack()
bm.to_mesh(body.data)

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


figure = bake([(body, opts.body_faces, 0), (head, opts.head_faces, opts.head_voxel)]
              + ([(glasses, opts.glasses_faces, 0)] if glasses else []), "operator", opts.texture)
pack_light = bake([(pack, opts.pack_faces, 0.002)], "operator_pack", opts.pack_texture)
for obj, file in ((figure, "prepared.glb"), (pack_light, "prepared-pack.glb")):
    select([obj], obj)
    bpy.ops.export_scene.gltf(filepath=f"{opts.out_dir}/{file}", export_format="GLB",
                              use_selection=True)

if opts.rig:
    # Meshy's armature is stored at 0.01 scale, and Blender's exporter misplaces bone children of
    # it, so the pack is skinned to Spine inside the same mesh instead.
    bpy.ops.wm.read_factory_settings(use_empty=True)

    def bring(path):
        before = set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=path)
        return [o for o in bpy.data.objects if o not in before]

    parts = bring(opts.rig)
    armature = [o for o in parts if o.type == "ARMATURE"][0]
    rigged = [o for o in parts if o.type == "MESH" and o.parent == armature][0]
    figure = [o for o in bring(f"{opts.out_dir}/prepared.glb") if o.type == "MESH"][0]
    bpy.context.view_layer.update()
    figure.data.transform(rigged.matrix_world.inverted() @ figure.matrix_world)
    figure.parent = armature
    figure.matrix_parent_inverse = rigged.matrix_parent_inverse.copy()
    figure.matrix_basis = rigged.matrix_basis.copy()
    for group in rigged.vertex_groups:
        figure.vertex_groups.new(name=group.name)
    weights = figure.modifiers.new("weights", "DATA_TRANSFER")
    weights.object = rigged
    weights.use_vert_data = True
    weights.data_types_verts = {"VGROUP_WEIGHTS"}
    weights.vert_mapping = "POLYINTERP_NEAREST"
    weights.layers_vgroup_select_src = "ALL"
    weights.layers_vgroup_select_dst = "NAME"
    apply(figure, weights)
    figure.modifiers.new("Armature", "ARMATURE").object = armature
    pack = [o for o in bring(f"{opts.out_dir}/prepared-pack.glb") if o.type == "MESH"][0]
    pack.vertex_groups.new(name="Spine").add(range(len(pack.data.vertices)), 1.0, "REPLACE")
    select([pack, figure], figure)
    bpy.ops.object.join()
    for o in [o for o in bpy.data.objects if o not in (armature, figure)]:
        bpy.data.objects.remove(o)
    select([armature, figure], figure)
    bpy.ops.export_scene.gltf(filepath=f"{opts.out_dir}/rigged.glb", export_format="GLB",
                              use_selection=True, export_animations=False)
