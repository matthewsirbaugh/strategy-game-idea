# Adds finger bones to a Meshy-rigged character and makes a relaxed curl the rest pose. Meshy's
# auto-rig gives each hand one bone, so without this the fingers stay frozen in the T-pose spread.
# Run: blender -b --python tools/add_fingers.py -- <rigged.glb> <out.glb> [--curl 1.0]
# Takes prep_operator.py --rig's output, or a game asset without fingers yet. Expects a T-pose with
# palms down and thumbs forward. Bones take Mixamo's names (LeftHandIndex1-4 ...), so clips with
# fingers can drive them; turning a finger bone positively about its local X curls it toward the palm.
import argparse
import math
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Quaternion, Vector
from mathutils.kdtree import KDTree

DIGITS = ["Thumb", "Index", "Middle", "Ring", "Pinky"]  # from the thumb's side across the hand
# Degrees of flexion at each digit's three joints, base to tip: the cascade of a hand hanging relaxed.
CURL = {"Thumb": (10, 15, 15), "Index": (15, 30, 15), "Middle": (20, 35, 18), "Ring": (25, 40, 20),
        "Pinky": (30, 45, 22)}
THUMB_IN = 12  # degrees the thumb turns toward the index at its base
SPREAD_KEEP = 0.6  # how much of each finger's T-pose spread from the middle finger stays
FINGER_JOINTS = (0.45, 0.75)  # middle and end joints, as fractions of a finger from its knuckle
KNUCKLE_DEPTH = 0.25  # a knuckle sits this fraction of the finger's visible length behind the web
THUMB_BASE = 0.8  # the thumb's root, behind its web, as a fraction of the thumb's visible length
THUMB_JOINT = 0.55  # the thumb's end joint, as a fraction of the way from its web to its tip
BLEND = 0.15  # each joint's weights blend over this fraction of the shorter segment beside it
WELD = 0.0003  # metres: Meshy exports split vertices along texture seams

args = argparse.ArgumentParser()
args.add_argument("rigged")
args.add_argument("out")
args.add_argument("--curl", type=float, default=1.0, help="scales every rest-pose angle")
opts = args.parse_args(sys.argv[sys.argv.index("--") + 1:])


def smooth(x):
    x = min(max(x, 0.0), 1.0)
    return x * x * (3 - 2 * x)


def across(v, axis):
    return (v - axis * v.dot(axis)).normalized()


def select(objs, active):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = active


def weld(points):
    tree = KDTree(len(points))
    for i, p in enumerate(points):
        tree.insert(p, i)
    tree.balance()
    root = list(range(len(points)))

    def find(i):
        while root[i] != i:
            root[i] = root[root[i]]
            i = root[i]
        return i
    for i, p in enumerate(points):
        for _, j, _ in tree.find_range(p, WELD):
            root[find(j)] = find(i)
    return [find(i) for i in range(len(points))]


# Sweeps the hand from the fingertips toward the wrist. Each tip starts a piece; a digit is a piece
# just before it first meets another lasting piece. Pieces shorter than `least` are bumps, and merge
# quietly. Returns [(nodes, height where it met the rest)].
def find_digits(height, links, least):
    owner = {}
    pieces = {}  # root node -> [tip height, nodes, holds more than one digit]
    found = []

    def find(n):
        while owner[n] != n:
            owner[n] = owner[owner[n]]
            n = owner[n]
        return n
    for n in sorted(height, key=lambda n: -height[n]):
        h = height[n]
        roots = {find(m) for m in links[n] if m in owner}
        owner[n] = n
        if not roots:
            pieces[n] = [h, [n], False]
            continue
        lasting = [r for r in roots if pieces[r][2] or pieces[r][0] - h >= least]
        if len(lasting) > 1:
            found += [(list(pieces[r][1]), h) for r in lasting if not pieces[r][2]]
        keep = max(roots, key=lambda r: pieces[r][0])
        mixed = len(lasting) > 1 or any(pieces[r][2] for r in roots)
        for r in roots - {keep}:
            pieces[keep][1] += pieces.pop(r)[1]
            owner[r] = keep
        pieces[keep][1].append(n)
        pieces[keep][2] = mixed
        owner[n] = keep
    return found


bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=opts.rigged)
for o in [o for o in bpy.data.objects if o.name.startswith("Icosphere")]:  # the importer's bone shape
    bpy.data.objects.remove(o)
armature = [o for o in bpy.data.objects if o.type == "ARMATURE"][0]
body = [o for o in bpy.data.objects if o.type == "MESH" and o.parent == armature][0]
if any(b.name.endswith("Index1") for b in armature.data.bones):
    sys.exit("add_fingers: this rig already has finger bones")
to_world = body.matrix_world.copy()
to_local = to_world.inverted()
to_bones = armature.matrix_world.inverted()
groups = {g.name: g.index for g in body.vertex_groups}
bm = bmesh.new()
bm.from_mesh(body.data)
deform = bm.verts.layers.deform.active
hands = {}

for side in ("Left", "Right"):
    bones = armature.data.bones
    wrist = armature.matrix_world @ bones[side + "Hand"].head_local
    out = (wrist - armature.matrix_world @ bones[side + "ForeArm"].head_local).normalized()
    palm = across(Vector((0, 0, -1)), out)
    thumb_side = out.cross(palm)
    if thumb_side.y > 0:
        thumb_side = -thumb_side
    hand = groups[side + "Hand"]
    verts = [v for v in bm.verts if v[deform] and max(v[deform].items(), key=lambda g: g[1])[0] == hand]
    points = [to_world @ v.co for v in verts]
    centred = np.array(points) - np.mean(points, 0)
    if abs(Vector(np.linalg.svd(centred)[2][2]).dot(palm)) < 0.8:
        sys.exit(f"add_fingers: the {side.lower()} palm doesn't face down")
    node = weld(points)
    index = {v: i for i, v in enumerate(verts)}
    links = {n: set() for n in node}
    for e in bm.edges:
        a, b = (index.get(v) for v in e.verts)
        if a is not None and b is not None and node[a] != node[b]:
            links[node[a]].add(node[b])
            links[node[b]].add(node[a])
    height = {n: (points[n] - wrist).dot(out) for n in links}
    found = find_digits(height, links, 0.08 * max(height.values()))
    if len(found) != 5:
        sys.exit(f"add_fingers: found {len(found)} digits on the {side.lower()} hand, not 5")

    digits = []
    for nodes, level in found:
        members = np.array([points[n] for n in nodes])
        centre = Vector(members.mean(0))
        along = Vector(np.linalg.svd(members - members.mean(0))[2][0])
        if along.dot(out) < 0:
            along = -along
        tip = max((Vector(p) - centre).dot(along) for p in members)
        web = (level - (centre - wrist).dot(out)) / along.dot(out)
        lateral = [((Vector(p) - centre) - along * (Vector(p) - centre).dot(along)).length for p in members]
        digits.append({"along": along, "tip": centre + along * tip, "web": centre + along * web,
                       "radius": float(np.percentile(lateral, 90)), "nodes": set(nodes)})
    digits.sort(key=lambda d: -d["tip"].dot(thumb_side))
    for name, d in zip(DIGITS, digits):
        d["name"] = name
        visible = (d["tip"] - d["web"]).length
        if name == "Thumb":
            root = d["web"] - d["along"] * visible * THUMB_BASE
            d["joints"] = [root, d["web"], d["web"] + d["along"] * visible * THUMB_JOINT, d["tip"]]
        else:
            length = visible * (1 + KNUCKLE_DEPTH)
            root = d["tip"] - d["along"] * length
            d["joints"] = [root] + [root + d["along"] * length * f for f in FINGER_JOINTS] + [d["tip"]]
        d["stops"] = [(j - root).dot(d["along"]) for j in d["joints"]]
        segments = [b - a for a, b in zip(d["stops"], d["stops"][1:])]
        d["blend"] = [BLEND * min(segments[0], segments[1]), BLEND * min(segments[1], segments[2])]
        spread = math.degrees(across(d["along"], palm).angle(across(digits[2]["along"], palm)))
        print(f"add_fingers: {side}{name} {d['stops'][-1] * 100:.1f} cm, web {visible * 100:.1f} cm from the tip, "
              f"{spread:.0f}° from the middle finger")

    # Knuckle loops: rings at each bending joint and either side of it, cut only through this digit.
    labels = {}
    for k, d in enumerate(digits):
        for v, i in index.items():
            if node[i] in d["nodes"]:
                labels[v] = k
        for stop, blend in zip(d["stops"][1:3], d["blend"]):
            for cut in (stop - blend, stop, stop + blend):
                faces = list({f for v, owner in labels.items() if owner == k for f in v.link_faces
                              if all(labels.get(u) == k for u in f.verts)})
                edges = list({e for f in faces for e in f.edges})
                corners = list({u for f in faces for u in f.verts})
                point = to_local @ (d["joints"][0] + d["along"] * cut)
                normal = (to_local.to_3x3() @ d["along"]).normalized()
                made = bmesh.ops.bisect_plane(bm, geom=faces + edges + corners, plane_co=point, plane_no=normal, dist=1e-6)
                for v in made["geom_cut"]:
                    if isinstance(v, bmesh.types.BMVert):
                        labels[v] = k
    # A cut through a face's edge leaves its neighbour with a corner in a straight line.
    bmesh.ops.triangulate(bm, faces=list({f for v in labels for f in v.link_faces if len(f.verts) > 3}),
                          quad_method="BEAUTY", ngon_method="BEAUTY")
    hands[side] = {"palm": palm, "thumb_side": thumb_side, "digits": digits, "hand": hand, "labels": labels,
                   "verts": verts + [v for v in labels if v not in index]}

# Weights: each hand vertex's Hand weight is shared with the finger bones. A finger's own skin
# follows only that finger; palm skin near the knuckles follows up to two, smoothed across the palm
# so its big triangles stretch instead of folding. Long palm triangles reach far up the fingers, so
# the smoothing never draws from finger skin.
for side, h in hands.items():
    groups = {}
    for d in h["digits"]:
        for i in (1, 2, 3):
            name = f"{side}Hand{d['name']}{i}"
            groups[d["name"], i] = body.vertex_groups.new(name=name).index
    shares = {}  # vertex -> {group: fraction of its Hand weight}
    for v in h["verts"]:
        p = to_world @ v.co
        reaches = []
        for k, d in enumerate(h["digits"]):
            s = (p - d["joints"][0]).dot(d["along"])
            if d["name"] == "Thumb":
                reach = smooth((s - 0.15 * d["stops"][1]) / (0.55 * d["stops"][1]))
            else:
                knuckle = 0.3 * d["stops"][1]
                reach = smooth((s + knuckle) / (2 * knuckle))
            if h["labels"].get(v) != k:
                if h["labels"].get(v) is not None:
                    continue
                spot = d["joints"][0] + d["along"] * min(max(s, 0), d["stops"][-1])
                reach *= 1 - smooth(((p - spot).length - d["radius"]) / d["radius"])
            if reach > 0.001:
                reaches.append((reach, k, s))
        reaches = sorted(reaches, reverse=True)[:2]
        moved = reaches[0][0] if reaches else 0.0
        share = {h["hand"]: 1 - moved}
        for reach, k, s in reaches:
            d = h["digits"][k]
            middle = smooth((s - d["stops"][1] + d["blend"][0]) / (2 * d["blend"][0]))
            end = smooth((s - d["stops"][2] + d["blend"][1]) / (2 * d["blend"][1]))
            part = moved * reach / sum(r for r, _, _ in reaches)
            for i, w in ((1, 1 - middle), (2, middle * (1 - end)), (3, middle * end)):
                share[groups[d["name"], i]] = part * w
        shares[v] = share
    palm = [v for v in h["verts"] if v not in h["labels"] and shares[v][h["hand"]] < 1]
    node = weld([to_world @ v.co for v in palm])
    copies = {}
    for v, n in zip(palm, node):
        copies.setdefault(n, []).append(v)
    for _ in range(3):
        smoothed = {}
        for group in copies.values():
            near = {u for v in group for e in v.link_edges for u in [e.other_vert(v)]
                    if u in shares and u not in h["labels"]} - set(group)
            if not near:
                continue
            mix = dict(shares[group[0]])
            for u in near:
                for g, f in shares[u].items():
                    mix[g] = mix.get(g, 0.0) + f / len(near)
            smoothed.update({v: {g: f / 2 for g, f in mix.items()} for v in group})
        shares.update(smoothed)
    for v, share in shares.items():
        whole = v[deform].get(h["hand"], 0.0)
        if whole == 0:
            continue
        del v[deform][h["hand"]]
        for g, f in share.items():
            if whole * f > 0.001:
                v[deform][g] = whole * f
        for g, _ in sorted(v[deform].items(), key=lambda g: -g[1])[4:]:
            del v[deform][g]
        total = sum(v[deform].values())
        for g in list(v[deform].keys()):
            v[deform][g] /= total
bm.to_mesh(body.data)
bm.free()

select([armature], armature)
bpy.ops.object.mode_set(mode="EDIT")
for side, h in hands.items():
    for d in h["digits"]:
        flex = h["palm"]
        if d["name"] == "Thumb":
            flex = (h["palm"] - h["thumb_side"]).normalized()
        parent = armature.data.edit_bones[side + "Hand"]
        joints = d["joints"] + [d["tip"] + d["along"] * (d["stops"][3] - d["stops"][2]) * 0.5]
        for i in range(4):
            bone = armature.data.edit_bones.new(f"{side}Hand{d['name']}{i + 1}")
            bone.head = to_bones @ joints[i]
            bone.tail = to_bones @ joints[i + 1]
            bone.parent = parent
            bone.use_connect = i > 0
            bone.align_roll((to_bones.to_3x3() @ flex).normalized())
            parent = bone

# The curl as a pose, written into the mesh, then made the rest pose: only finger bones move.
bpy.ops.object.mode_set(mode="POSE")
for side, h in hands.items():
    middle = next(d for d in h["digits"] if d["name"] == "Middle")["along"]
    first = next(d for d in h["digits"] if d["name"] == "Index")["along"]
    for d in h["digits"]:
        for i, angle in enumerate(CURL[d["name"]]):
            bone = armature.pose.bones[f"{side}Hand{d['name']}{i + 1}"]
            bone.rotation_mode = "QUATERNION"
            turn = Quaternion((1, 0, 0), math.radians(angle * opts.curl))
            if i == 0 and d["name"] != "Middle":
                toward = first if d["name"] == "Thumb" else middle
                a, b = across(d["along"], h["palm"]), across(toward, h["palm"])
                closing = math.radians(THUMB_IN) if d["name"] == "Thumb" else a.angle(b) * (1 - SPREAD_KEEP)
                rest = bone.bone.matrix_local.to_quaternion()
                inward = Quaternion((to_bones.to_3x3() @ a.cross(b)).normalized(), closing * opts.curl)
                turn = rest.inverted() @ inward @ rest @ turn
            bone.rotation_quaternion = turn
bpy.ops.object.mode_set(mode="OBJECT")
before = [to_world @ v.co for v in body.data.vertices]
fingers = {g.index for g in body.vertex_groups if "Hand" in g.name and not g.name.endswith("Hand")}
select([body], body)
skin = next(m.name for m in body.modifiers if m.type == "ARMATURE")
bpy.ops.object.modifier_copy(modifier=skin)
bpy.ops.object.modifier_apply(modifier=skin)
body.modifiers[-1].name = skin
still = max((to_world @ v.co - before[v.index]).length for v in body.data.vertices
            if not any(g.group in fingers for g in v.groups))
select([armature], armature)
bpy.ops.object.mode_set(mode="POSE")
bpy.ops.pose.armature_apply(selected=False)
bpy.ops.object.mode_set(mode="OBJECT")
print(f"add_fingers: vertices without finger weights moved at most {still * 1000:.4f} mm; "
      f"{len(body.data.vertices)} vertices, {len(body.data.polygons)} faces")

select([armature, body], body)
bpy.ops.export_scene.gltf(filepath=opts.out, export_format="GLB", use_selection=True, export_animations=False)
