"""Cropped teal canvas work vest: open front, deep armholes, tall stand collar."""
import math
import bmesh
import bpy
from mathutils import Vector
from . import garments as G

ss = G.smoothstep
HEM = .99


def keep(c, n):
    if c.z < HEM - .02 or c.z > 1.47:
        return False
    if abs(c.x) > .2:
        return False
    return True


def shell(body, collection):
    obj = G.extract(body, 'vest', keep, collection)
    G.largest_part(obj)
    G.subdivide(obj, 2)
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=(0, 0, HEM),
                           plane_no=(0, 0, -1), clear_outer=True)
    doomed = []
    for f in bm.faces:
        c = f.calc_center_median()
        ax = abs(c.x)
        # armhole: an ellipse around the shoulder joint, open down to the side seam
        arm = ((ax - .175) / .058) ** 2 + ((c.z - 1.255) / .135) ** 2 < 1.0 or ax > .165
        # neckline: higher at the back, scooped at the front to sit around the stand collar
        neck = c.z > 1.405 + c.y * .7 - (ax < .075) * 0.0 or (c.z > 1.385 and ax < .085 and c.y < 0)
        # front opening, slightly off-centre so the left panel overlaps the placket line
        front = c.y < -.03 and -.028 < c.x < .03
        if arm or neck or front:
            doomed.append(f)
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    bm.to_mesh(obj.data)
    bm.free()
    G.largest_part(obj)

    G.smooth_boundary(obj, 25, .5)

    def ease(co):
        return .021 + .004 * ss(1.15, 1.02, co.z) - .004 * ss(1.30, 1.40, co.z)
    G.offset(obj, ease)
    # stiff canvas drapes over the bust and the small of the back instead of following them
    G.relax(obj, 70, .5, lambda co: ss(.17, .12, abs(co.x)) * ss(1.02, 1.10, co.z) * ss(1.36, 1.28, co.z)
            * ss(-.02, -.06, co.y))
    G.relax(obj, 30, .5, lambda co: ss(.10, .0, abs(co.x)) * ss(1.0, 1.08, co.z) * ss(1.30, 1.2, co.z) * ss(.02, .06, co.y))
    G.relax(obj, 8, .35)
    G.smooth_boundary(obj, 10, .5)
    return obj


def settle(vest, shirt, body):
    """Keep the draped canvas clear of the shirt and the body underneath."""
    G.push_outside(vest, shirt, .007)
    G.push_outside(vest, body, .016)
    G.relax(vest, 4, .3)
    G.push_outside(vest, shirt, .006)


def collar(vest, collection, height=.062, flare=.012):
    """Stand collar grown from the vest's neckline loop."""
    bm = bmesh.new()
    bm.from_mesh(vest.data)
    edges = [tuple(v.index for v in e.verts) for e in bm.edges
             if e.is_boundary and all(v.co.z > 1.33 and abs(v.co.x) < .105 for v in e.verts)]
    coords = {v.index: v.co.copy() for v in bm.verts}
    bm.free()
    ring = sorted({i for e in edges for i in e})
    center = sum((coords[i] for i in ring), Vector()) / len(ring)
    center.z = 1.40
    me = bpy.data.meshes.new('vest_collar')
    bmc = bmesh.new()
    lookup = {}
    for i in ring:
        base = coords[i]
        out = base - center
        out.z = 0
        out = out.normalized() if out.length else Vector((0, 1, 0))
        top = base + Vector((0, 0, height)) + out * flare
        lookup[i] = (bmc.verts.new(base), bmc.verts.new(top))
    for i, j in edges:
        a, b = lookup[i], lookup[j]
        bmc.faces.new((a[0], b[0], b[1], a[1]))
    bmesh.ops.recalc_face_normals(bmc, faces=bmc.faces[:])
    bmesh.ops.subdivide_edges(bmc, edges=[e for e in bmc.edges if abs(e.verts[0].co.z - e.verts[1].co.z) > .03],
                              cuts=5, use_grid_fill=True)
    bmc.to_mesh(me)
    bmc.free()
    obj = bpy.data.objects.new('vest_collar', me)
    collection.objects.link(obj)
    # a soft outward roll near the top edge
    for v in me.vertices:
        t = ss(1.37, 1.47, v.co.z)
        out = v.co - center
        out.z = 0
        if out.length:
            v.co += out.normalized() * .008 * t * t
    return obj
