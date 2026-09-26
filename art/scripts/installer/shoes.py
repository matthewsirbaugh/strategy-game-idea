"""Mid-cut hiking shoes: suede-and-mesh upper on a chunky rubber sole, with socks above."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix
from . import garments as G
from .gear import finish

ss = G.smoothstep
SOLE = .03


def foot_axis(side):
    s = 1 if side == 'l' else -1
    return Vector((s * .17, -.03, 0))


def collar_height(y):
    return .135 + .006 * ss(-.02, .05, y) - .032 * ss(-.03, -.10, y)


def upper(body, side, collection, mats):
    s = 1 if side == 'l' else -1
    obj = G.extract(body, f'shoe_{side}', lambda c, n: c.z < .17 and c.x * s > .05, collection)
    G.largest_part(obj)
    G.subdivide(obj, 2)
    me = obj.data
    # a last, not a foot: melt the toes into one rounded toe box
    G.relax(obj, 60, .5, lambda co: ss(-.11, -.16, co.y) + .3)
    G.offset(obj, lambda co: .009 + .006 * ss(-.09, -.19, co.y) + .004 * ss(.06, .11, co.z) * ss(-.02, -.1, co.y))
    G.relax(obj, 10, .4)
    for v in me.vertices:
        v.co.z = SOLE - .006 + v.co.z * 1.06
        v.co.y -= .006 * ss(-.12, -.2, v.co.y)
    bm = bmesh.new()
    bm.from_mesh(me)
    doomed = [f for f in bm.faces if f.calc_center_median().z > collar_height(f.calc_center_median().y)
              or (f.normal.z < -.5 and f.calc_center_median().z < SOLE + .015)]
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    bm.to_mesh(me)
    bm.free()
    G.largest_part(obj)
    G.smooth_boundary(obj, 15, .5, lambda co: co.z > .06)
    me.materials.append(mats['shoe_mesh'])
    me.materials.append(mats['suede'])
    me.materials.append(mats['rubber'])
    me.materials.append(mats['orange'])
    ax = foot_axis(side)
    for p in me.polygons:
        c = p.center
        cap = c.y < -.16 and c.z < SOLE + .026
        rand = c.z < SOLE + .01
        toe = c.y < -.095 and p.normal.z > .45
        heel = c.y > .035 and c.z < .105
        stay = .011 < abs(c.x - ax.x) < .03 and c.z > .07 and -.12 < c.y < .035
        stripe = abs(c.z - (SOLE + .03)) < .004 and -.09 < c.y < .03
        p.material_index = 2 if (rand or cap) else (1 if (toe or heel or stay) else (3 if stripe else 0))
        p.use_smooth = True
    solid = G.solidify(obj, .0025)
    solid.offset = -1
    solid.use_even_offset = False
    return obj


def collar_roll(shoe, side, collection, mat):
    """Padded collar round the ankle opening."""
    bm_src = bmesh.new()
    bm_src.from_mesh(shoe.data)
    loop = [v.co.copy() for v in bm_src.verts if v.is_boundary and v.co.z > .07]
    bm_src.free()
    c = sum(loop, Vector()) / len(loop)
    loop.sort(key=lambda p: math.atan2(p.x - c.x, p.y - c.y))
    bm = bmesh.new()
    rings = []
    for i, p in enumerate(loop):
        out = Vector((p.x - c.x, p.y - c.y, 0)).normalized()
        front = ss(-.03, -.09, p.y)
        r = .0075 * (1 - .7 * front)
        ring = []
        for k in range(8):
            a = 2 * math.pi * k / 8
            ring.append(bm.verts.new(p + out * (r * math.cos(a) + .002) + Vector((0, 0, r * math.sin(a)))))
        rings.append(ring)
    for i in range(len(rings)):
        a, b = rings[i], rings[(i + 1) % len(rings)]
        for k in range(8):
            bm.faces.new((a[k], a[(k + 1) % 8], b[(k + 1) % 8], b[k]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return finish(f'shoe_collar_{side}', bm, collection, mat)


def tongue(side, collection, mat):
    ax = foot_axis(side)
    bm = bmesh.new()
    pts = [(-.105, .062), (-.07, .08), (-.035, .102), (0.0, .128), (.012, .142)]
    rows = []
    for y, z in pts:
        row = [bm.verts.new((ax.x + u * .024, y + .0, z + .006 * (1 - u * u))) for u in (-1, -.5, 0, .5, 1)]
        rows.append(row)
    for a, b in zip(rows, rows[1:]):
        for k in range(4):
            bm.faces.new((a[k], a[k + 1], b[k + 1], b[k]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        if f.normal.z < 0:
            f.normal_flip()
    obj = finish(f'shoe_tongue_{side}', bm, collection, mat)
    G.solidify(obj, .006).offset = -1
    return obj


def sole(shoe, side, collection, mats):
    me = shoe.data
    pts = [v.co.copy() for v in me.vertices if v.co.z < SOLE + .02]
    cx = sum(p.x for p in pts) / len(pts)
    cy = sum(p.y for p in pts) / len(pts)
    radii = [0.0] * 64
    for p in pts:
        a = math.atan2(p.y - cy, p.x - cx) % (2 * math.pi)
        k = int(a / (2 * math.pi) * 64) % 64
        radii[k] = max(radii[k], math.hypot(p.x - cx, p.y - cy))
    for _ in range(4):
        radii = [max(radii[i], (radii[i - 1] + radii[(i + 1) % 64]) / 2) for i in range(64)]
    ring = [Vector((cx + math.cos(2 * math.pi * (i + .5) / 64) * (radii[i] + .006),
                    cy + math.sin(2 * math.pi * (i + .5) / 64) * (radii[i] + .006), 0)) for i in range(64)]
    bm = bmesh.new()
    layers = []
    for z, grow in ((0.0, -.003), (.006, .0), (.016, .001), (SOLE + .002, -.002)):
        layer = []
        for p in ring:
            d = Vector((p.x - cx, p.y - cy, 0)).normalized()
            q = p + d * grow
            spring = .014 * ss(-.13, -.22, q.y) + .004 * ss(.07, .11, q.y)
            layer.append(bm.verts.new((q.x, q.y, z + spring)))
        layers.append(layer)
    for a, b in zip(layers, layers[1:]):
        for i in range(64):
            bm.faces.new((a[i], a[(i + 1) % 64], b[(i + 1) % 64], b[i]))
    bm.faces.new(list(reversed(layers[0])))
    bm.faces.new(layers[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        f.material_index = 1 if f.calc_center_median().z > .014 else 0
    obj = finish(f'sole_{side}', bm, collection, mats['rubber'], bevel=.0015)
    obj.data.materials.append(mats['midsole'])
    return obj


def laces(shoe, side, collection, lace_mat, eyelet_mat):
    ax = foot_axis(side)
    top_pts = [v.co for v in shoe.data.vertices]

    def top_at(y, x):
        near = [p for p in top_pts if abs(p.y - y) < .01 and abs(p.x - x) < .01]
        return max((p.z for p in near), default=.09)
    bm_l, bm_e = bmesh.new(), bmesh.new()
    holes = []
    for i in range(6):
        y = -.108 + i * .024
        half = .017 + .003 * ss(-.11, -.02, y)
        row = []
        for sx in (-1, 1):
            x = ax.x + sx * half
            p = Vector((x, y, top_at(y, x) + .003))
            row.append(p)
            bmesh.ops.create_cone(bm_e, cap_ends=True, segments=10, radius1=.0034, radius2=.0034, depth=.002,
                                  matrix=Matrix.Translation(p))
        holes.append(row)
    for a, b in zip(holes, holes[1:]):
        for p, q in ((a[0], b[1]), (a[1], b[0])):
            mid = (p + q) / 2 + Vector((0, 0, .006))
            prev = None
            for k in range(7):
                t = k / 6
                c = p * (1 - t) ** 2 + mid * 2 * t * (1 - t) + q * t * t
                side_v = (q - p).normalized().cross(Vector((0, 0, 1)))
                ring = [bm_l.verts.new(c + Vector((0, 0, .0022 * math.sin(2 * math.pi * r / 5))) + side_v * .0022 * math.cos(2 * math.pi * r / 5))
                        for r in range(5)]
                if prev:
                    for r in range(5):
                        bm_l.faces.new((prev[r], prev[(r + 1) % 5], ring[(r + 1) % 5], ring[r]))
                prev = ring
    return finish(f'laces_{side}', bm_l, collection, lace_mat), finish(f'eyelets_{side}', bm_e, collection, eyelet_mat)


def heel_tab(side, collection, mat):
    ax = foot_axis(side)
    bm = bmesh.new()
    m = Matrix.Translation((ax.x, .07, collar_height(.07) + .01)) @ Matrix.Rotation(math.radians(-18), 4, 'X')
    bmesh.ops.create_cube(bm, size=1.0, matrix=m @ Matrix.Diagonal((.02, .007, .034, 1)))
    return finish(f'heel_tab_{side}', bm, collection, mat, bevel=.002)


def socks(body, collection, mat):
    obj = G.extract(body, 'socks', lambda c, n: .09 < c.z < .17, collection)
    G.subdivide(obj, 1)
    G.offset(obj, lambda co: .0025)
    obj.data.materials.append(mat)
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj


def build(body, collection, mats):
    out = []
    for side in 'lr':
        up = upper(body, side, collection, mats)
        out += [up, collar_roll(up, side, collection, mats['shoe_mesh']), tongue(side, collection, mats['shoe_mesh']),
                sole(up, side, collection, mats), *laces(up, side, collection, mats['lace'], mats['brass']),
                heel_tab(side, collection, mats['orange'])]
    out.append(socks(body, collection, mats['sock']))
    return out
