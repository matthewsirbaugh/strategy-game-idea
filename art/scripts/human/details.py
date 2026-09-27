"""Helpers for garment details: padded panels (pockets, flaps, pads) that follow a surface, and snaps."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from .gear import finish


def tree(obj):
    from .garments import base_tree
    return base_tree(obj)


def conform_box(surface_tree, name, center, up, width, height, thick, collection, mat, lift=.002, res=10,
                round_bottom=0.0):
    """A thin padded panel (pocket, flap) that follows the garment surface."""
    loc, n, _, _ = surface_tree.find_nearest(Vector(center))
    up = Vector(up)
    side = up.cross(n).normalized()
    up = n.cross(side).normalized()
    bm = bmesh.new()
    top, bot = [], []
    for j in range(res + 1):
        rt, rb = [], []
        for i in range(res + 1):
            u, v = i / res - .5, j / res - .5
            if round_bottom and v < 0:
                # round the lower corners into a flap shape
                u *= 1 - round_bottom * (1 - math.sqrt(max(0.0, 1 - (2 * v) ** 2)))
            p = loc + side * u * width + up * v * height
            hit, hn, _, _ = surface_tree.find_nearest(p)
            puff = thick * (1 - (2 * u) ** 6) * (1 - (2 * v) ** 6) * .5 + thick * .5
            rt.append(bm.verts.new(hit + hn * (lift + puff)))
            rb.append(bm.verts.new(hit + hn * lift))
        top.append(rt)
        bot.append(rb)
    for j in range(res):
        for i in range(res):
            bm.faces.new((top[j][i], top[j][i + 1], top[j + 1][i + 1], top[j + 1][i]))
            bm.faces.new((bot[j + 1][i], bot[j + 1][i + 1], bot[j][i + 1], bot[j][i]))
    for j in range(res):
        for a, b in ((top[j][0], top[j + 1][0]), (top[j + 1][-1], top[j][-1])):
            pass
    edges = []
    for i in range(res):
        edges.append((top[0][i], top[0][i + 1], bot[0][i + 1], bot[0][i]))
        edges.append((top[-1][i + 1], top[-1][i], bot[-1][i], bot[-1][i + 1]))
    for j in range(res):
        edges.append((top[j + 1][0], top[j][0], bot[j][0], bot[j + 1][0]))
        edges.append((top[j][-1], top[j + 1][-1], bot[j + 1][-1], bot[j][-1]))
    for q in edges:
        bm.faces.new(q)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return finish(name, bm, collection, mat), (loc, side, up, n)


def snap(bm, p, n, r=.0055):
    m = Matrix.Translation(p) @ n.to_track_quat('Z', 'Y').to_matrix().to_4x4()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=14, radius1=r, radius2=r * .75, depth=.0028, matrix=m)
