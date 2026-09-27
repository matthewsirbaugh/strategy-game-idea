"""Fingerless work gloves with suede knuckle pads, velcro wrist straps, and a watch."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix
from . import garments as G
from .gear import finish, rbox

ss = G.smoothstep
CUT = ('_02_', '_03_')


def glove(body, rig, side, collection, mats):
    names = {vg.index: vg.name for vg in body.vertex_groups}
    m = rig.matrix_world
    wrist = m @ rig.data.bones[f'hand_{side}'].head_local
    elbow = m @ rig.data.bones[f'lowerarm_{side}'].head_local
    fore = (wrist - elbow).normalized()
    heavy = {}
    for v in body.data.vertices:
        if v.groups:
            g = max(v.groups, key=lambda gg: gg.weight)
            heavy[v.index] = names[g.group] + '_'
    me = body.data

    def keep(c, n):
        return (c - wrist).dot(fore) > -.045 and (c.x > 0) == (side == 'l') and c.z > .7
    obj = G.extract(body, f'glove_{side}', keep, collection)
    # drop the finger segments beyond the first knuckle
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    src = bmesh.new()
    src.from_mesh(me)
    from mathutils.kdtree import KDTree
    kd = KDTree(len(me.vertices))
    for v in me.vertices:
        kd.insert(v.co, v.index)
    kd.balance()
    doomed = []
    for f in bm.faces:
        c = f.calc_center_median()
        _, idx, _ = kd.find(c)
        bone = heavy.get(idx, '')
        if any(k in bone for k in CUT):
            doomed.append(f)
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    bm.to_mesh(obj.data)
    bm.free()
    src.free()
    G.largest_part(obj)
    G.subdivide(obj, 1)
    G.offset(obj, lambda co: .0013 + .001 * ss(.0, -.03, (co - wrist).dot(fore)))
    obj.data.materials.append(mats['glove_fabric'])
    obj.data.materials.append(mats['suede_pad'])
    # suede on the knuckles and the heel of the palm
    hand_dir = (m @ rig.data.bones[f'middle_01_{side}'].head_local - wrist).normalized()
    side_axis = Vector((1 if side == 'l' else -1, 0, 0))
    dorsal = hand_dir.cross(fore.cross(side_axis)).normalized()
    if dorsal.z < 0:
        dorsal = -dorsal
    for p in obj.data.polygons:
        p.use_smooth = True
    solid = G.solidify(obj, .0012)
    solid.offset = -1
    solid.use_even_offset = False
    # padded suede panels over the knuckles and the heel of the palm
    from .details import conform_box
    from mathutils.bvhtree import BVHTree
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    tree = BVHTree.FromBMesh(bm)
    bm.free()
    pads = []
    for tag, t, sign, size in (('knuckles', .07, 1, (.058, .03)), ('palm', .03, -1, (.045, .035))):
        probe = wrist + hand_dir * t + dorsal * sign * .04
        hit = tree.ray_cast(probe, -dorsal * sign)
        if hit[0] is None:
            continue
        pad, _ = conform_box(tree, f'glove_{tag}_{side}', hit[0], hand_dir, size[0], size[1], .003, collection,
                             mats['suede_pad'], .0012, 8)
        pads.append(pad)
    # velcro strap round the wrist
    bm = bmesh.new()
    ref = fore.orthogonal().normalized()
    other = fore.cross(ref)
    radius = .027
    ring_c = wrist - fore * .012
    n = 32
    outer = [bm.verts.new(ring_c + (ref * math.cos(2 * math.pi * i / n) + other * math.sin(2 * math.pi * i / n)) * (radius + .0025)
                          + fore * dz) for dz in (-.009, .009) for i in range(n)]
    inner = [bm.verts.new(ring_c + (ref * math.cos(2 * math.pi * i / n) + other * math.sin(2 * math.pi * i / n)) * radius
                          + fore * dz) for dz in (-.009, .009) for i in range(n)]
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((outer[i], outer[j], outer[n + j], outer[n + i]))
        bm.faces.new((inner[n + i], inner[n + j], inner[j], inner[i]))
        bm.faces.new((inner[i], inner[j], outer[j], outer[i]))
        bm.faces.new((outer[n + i], outer[n + j], inner[n + j], inner[n + i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    strap = finish(f'glove_strap_{side}', bm, collection, mats['glove_fabric'])
    return [obj, strap] + pads, (wrist, fore, ref, other)


def watch(frame, side, collection, mats):
    wrist, fore, ref, other = frame
    c = wrist - fore * .05
    radius = .0265
    bm = bmesh.new()
    n = 32
    rings = []
    for dz in (-.011, .011):
        for r in (radius + .003, radius):
            rings.append([bm.verts.new(c + (ref * math.cos(2 * math.pi * i / n) + other * math.sin(2 * math.pi * i / n)) * r
                                       + fore * dz) for i in range(n)])
    o0, i0, o1, i1 = rings
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((o0[i], o0[j], o1[j], o1[i]))
        bm.faces.new((i1[i], i1[j], i0[j], i0[i]))
        bm.faces.new((i0[i], i0[j], o0[j], o0[i]))
        bm.faces.new((o1[i], o1[j], i1[j], i1[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    band = finish(f'watch_band_{side}', bm, collection, mats['rubber_grip'])
    if side == 'r':
        return [band]
    up = other if other.z > 0 else -other
    bm = bmesh.new()
    rbox(bm, c + up * (radius + .006), (.032, .028, .01), (fore, up.cross(fore).normalized(), up), .004, 3)
    face = finish(f'watch_{side}', bm, collection, mats['bot_joint'])
    return [band, face]


def build(body, rig, collection, mats):
    out = []
    for side in 'lr':
        parts, frame = glove(body, rig, side, collection, mats)
        out += parts
        out += watch(frame, side, collection, mats)
    return out
