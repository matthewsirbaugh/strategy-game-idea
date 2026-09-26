"""Garment details from the concept: vest pockets, snaps and leaf emblem, trouser pockets and patches."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from . import decals
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


def vest_details(vest, collection, mats):
    t = tree(vest)
    out = []
    snaps = bmesh.new()
    for s, name in ((-1, 'r'), (1, 'l')):
        pocket, (loc, side, up, n) = conform_box(t, f'vest_pocket_{name}', (s * .085, -.14, 1.035), (0, 0, 1),
                                                   .115, .075, .006, collection, mats['vest'], .003)
        flap, (floc, fside, fup, fn) = conform_box(t, f'vest_flap_{name}', (s * .085, -.15, 1.07), (0, 0, 1),
                                                   .125, .042, .006, collection, mats['vest'], .011, round_bottom=.25)
        out += [pocket, flap]
        for k in (-1, 1):
            p = floc + fside * k * .035 - fup * .008
            hit, hn, _, _ = t.find_nearest(p)
            snap(snaps, hit + hn * .02, hn)
    # snaps up her left front edge and on the collar tab
    for z in (1.02, 1.09, 1.16, 1.23, 1.30):
        hit = t.ray_cast(Vector((.045, -.4, z)), Vector((0, 1, 0)))
        if hit[0] is not None:
            snap(snaps, hit[0] + hit[1] * .0045, hit[1], .005)
    out.append(finish('vest_snaps', snaps, collection, mats['brass']))
    emblem = decals.leaf_emblem()
    em = decals.decal_material('vest_emblem', emblem, .85)
    out.append(decals.patch_on(vest, 'vest_emblem', (-.075, -.16, 1.2), (0, 0, 1), .095, .12, collection, em, .0065, 28))
    return out


def trouser_details(trousers, collection, mats):
    t = tree(trousers)
    out = []
    # cargo pocket on the outer left thigh, back pockets on the seat
    pocket, _ = conform_box(t, 'cargo_pocket', (.19, -.01, .62), (0, 0, 1), .13, .15, .008, collection,
                            mats['trousers'], .003)
    flap, (floc, fside, fup, fn) = conform_box(t, 'cargo_flap', (.192, -.012, .71), (0, 0, 1), .14, .05, .006,
                                               collection, mats['trousers'], .012, round_bottom=.2)
    out += [pocket, flap]
    for s, name in ((1, 'l'), (-1, 'r')):
        bp, _ = conform_box(t, f'back_pocket_{name}', (s * .075, .14, .845), (0, 0, 1), .12, .13, .004, collection,
                            mats['trousers'], .002)
        out.append(bp)
    snaps = bmesh.new()
    hit, hn, _, _ = t.find_nearest(floc - fup * .012)
    snap(snaps, hit + hn * .02, hn)
    out.append(finish('cargo_snap', snaps, collection, mats['brass']))
    # waistband
    patch = decals.stitched_patch('installer_knee_patch', (.42, .38, .33), (.25, .33, .5))
    pm = decals.decal_material('knee_patch', patch, .9)
    out.append(decals.patch_on(trousers, 'knee_patch', (-.14, -.12, .53), (0, 0, 1), .085, .09, collection, pm, .0035))
    return out


def shirt_details(shirt_obj, collection):
    patch = decals.stitched_patch('installer_sleeve_patch', (.22, .23, .27), (.12, .14, .2), darn=True)
    pm = decals.decal_material('sleeve_patch', patch, .9)
    return [decals.patch_on(shirt_obj, 'sleeve_patch', (-.245, -.02, 1.24), (.55, 0, .83), .07, .06, collection, pm,
                            .003)]
