"""Charcoal work trousers: relaxed legs that stack into elastic jogger cuffs."""
import math
import bmesh
import bpy
from mathutils import Vector
from . import garments as G

ss = G.smoothstep
WAIST, CUFF = .955, .12
TOP, DROP = .50, .14   # the lower legs start DROP longer and are pulled up to CUFF by the sim


def leg_axis(co):
    return Vector((math.copysign(.165 - .07 * ss(.12, .45, co.z), co.x), -.035, co.z))


def shell(body, collection):
    obj = G.extract(body, 'trousers', lambda c, n: .05 < c.z < 1.0 and abs(c.x) < .3, collection)
    G.largest_part(obj)
    G.subdivide(obj, 2)
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=(0, 0, WAIST),
                           plane_no=(0, 0, 1), clear_outer=True)
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=(0, 0, CUFF),
                           plane_no=(0, 0, -1), clear_outer=True)
    bm.to_mesh(obj.data)
    bm.free()

    def ease(co):
        z = co.z
        e = .005 + .006 * ss(.92, .84, z) + .009 * ss(.80, .62, z) + .012 * ss(.58, .45, z)
        return e - .012 * ss(.20, .13, z)
    G.offset(obj, ease)
    # Trousers bridge the crotch instead of following it.
    G.relax(obj, 40, .5, lambda co: ss(.10, .02, abs(co.x)) * ss(.62, .74, co.z) * ss(.90, .84, co.z))
    # bridge the seat cleft and the hollows behind the knees
    G.relax(obj, 60, .5, lambda co: ss(.06, .0, abs(co.x)) * ss(.70, .78, co.z) * ss(.96, .88, co.z) * ss(.0, .04, co.y))
    G.relax(obj, 25, .45, lambda co: ss(.0, .03, co.y) * ss(.36, .42, co.z) * ss(.56, .50, co.z))
    G.relax(obj, 3, .3)
    return obj


def drape(obj, body, collection):
    collider = G.extract(body, 'legs_collider', lambda c, n: c.z > .10, collection)
    collider.hide_render = True
    G.collider(collider, collection, thickness=.004)
    me = obj.data
    natural = [v.co.copy() for v in me.vertices]
    for v, n in zip(me.vertices, natural):
        if n.z < TOP:
            a = leg_axis(n)
            d = n - a
            d.z = 0
            co = a + d * (1 + .08 * ss(TOP, CUFF, n.z))
            # displacement grows smoothly toward the hem so the slack stacks at the ankle
            co.z = n.z - DROP * ss(TOP, CUFF, n.z) ** 2.4
            v.co = co
    obj.shape_key_add(name='Basis')
    key = obj.shape_key_add(name='target')
    for i, n in enumerate(natural):
        co = n.copy()
        w = ss(CUFF + .03, CUFF, co.z)
        if w > 0:
            a = leg_axis(co)
            d = co - a
            d.z = 0
            co = a + d * (1 - .12 * w)
        key.data[i].co = co
    key.value = 0.0
    key.keyframe_insert('value', frame=1)
    key.value = 1.0
    key.keyframe_insert('value', frame=24)
    G.group(obj, 'pin', lambda co: 1.0 if (co.z > WAIST - .012 or co.z < CUFF - DROP + .012) else 0.0)
    G.drape(obj, 60, pin='pin', mass=.45, tension=40, compression=70, bending=5.0, quality=10,
            self_collide=True)
    bpy.data.objects.remove(collider, do_unlink=True)
    obj.vertex_groups.remove(obj.vertex_groups['pin'])
