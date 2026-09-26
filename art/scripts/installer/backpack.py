"""The backpack rig: pack, solar panel, bottle, padded shoulder straps and the camera bot."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from .gear import finish, rbox

UP = Vector((0, 0, 1))
X = Vector((1, 0, 0))
BACK = Vector((0, 1, 0))


def frame_at(center):
    return (X, UP, BACK)


def pack_body(collection, mats, front_y):
    """Main bag: a padded rounded box with seams, olive side panels and a cream lower pocket."""
    out = []
    w, h, d = .34, .46, .19
    c = Vector((0, front_y + d / 2, 1.2))
    bm = bmesh.new()
    geom = bmesh.ops.create_cube(bm, size=1.0, matrix=Matrix.Translation(c) @ Matrix.Diagonal((w, d, h, 1)))
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=6, use_grid_fill=True)
    for v in bm.verts:
        lx, ly, lz = (v.co - c).x / (w / 2), (v.co - c).y / (d / 2), (v.co - c).z / (h / 2)
        # taper toward the top, bulge the back face, round the corners
        v.co.x *= 1 - .12 * max(0, lz)
        v.co.y += .018 * (1 - lx * lx) * (1 - lz * lz) * max(0, ly)
        v.co.z += .01 * (1 - lx * lx) * max(0, lz)
    bmesh.ops.bevel(bm, geom=[e for e in bm.edges if e.calc_face_angle(0) > .5], offset=.03, segments=5,
                    affect='EDGES', clamp_overlap=True)
    # padded nylon: soft lumps rather than flat panels
    from mathutils import noise
    bm.normal_update()
    for v in bm.verts:
        v.co += v.normal * (.004 * noise.noise(v.co * 18) + .003)
    body = finish('pack_body', bm, collection, mats['pack_nylon'])
    out.append(body)
    # side panels
    bm = bmesh.new()
    for s in (1, -1):
        rbox(bm, c + Vector((s * (w / 2 - .004), .005, -.02)), (.012, d * .82, h * .8), (X, BACK, UP), .006, 3)
    out.append(finish('pack_sides', bm, collection, mats['pack_olive']))
    # cream lower front pocket (the back face of the pack, away from her)
    bm = bmesh.new()
    pc = Vector((0, front_y + d + .022, 1.065))
    rbox(bm, pc, (.2, .045, .12), (X, BACK, UP), .018, 4)
    out.append(finish('pack_pocket', bm, collection, mats['pack_cream']))
    # top lid
    bm = bmesh.new()
    rbox(bm, Vector((0, front_y + d / 2 + .01, 1.405)), (.25, d * .95, .04), (X, BACK, UP), .018, 4)
    out.append(finish('pack_lid', bm, collection, mats['pack_olive']))
    # vertical compression straps with ladder buckles
    bm = bmesh.new()
    kb = bmesh.new()
    for s in (1, -1):
        x = s * .075
        rbox(bm, Vector((x, front_y + d + .03, 1.16)), (.028, .006, .40), (X, BACK, UP), .002, 2)
        for z in (1.28, 1.07):
            rbox(kb, Vector((x, front_y + d + .036, z)), (.036, .008, .02), (X, BACK, UP), .003, 2)
    for s in (1, -1):
        for z in (1.12, 1.26):
            rbox(bm, Vector((s * (w / 2 + .006), front_y + d / 2, z)), (.006, d * .9, .024), (X, BACK, UP), .002, 2)
    # horizontal compression straps across the back face and a top grab handle
    for z in (1.02, 1.36):
        rbox(bm, Vector((0, front_y + d + .026, z)), (w * .9, .006, .022), (X, BACK, UP), .002, 2)
    rbox(bm, Vector((0, front_y + d * .4, 1.44)), (.1, .012, .025), (X, BACK, UP), .006, 3)
    out.append(finish('pack_straps', bm, collection, mats['webbing_khaki']))
    out.append(finish('pack_buckles', kb, collection, mats['steel']))
    # orange trims on the strap ends
    bm = bmesh.new()
    for s in (1, -1):
        rbox(bm, Vector((s * .075, front_y + d + .034, .955)), (.03, .008, .03), (X, BACK, UP), .004, 2)
    out.append(finish('pack_trims', bm, collection, mats['orange']))
    return out, c, (w, h, d)


def solar_panel(collection, mats, pack_c, dims):
    w, h, d = dims
    back_face = pack_c.y + d / 2 + .02
    c = Vector((-.01, back_face + .012, 1.255))
    tilt = Matrix.Rotation(math.radians(-8), 4, 'X')
    x, y, z = X, UP, BACK
    out = []
    bm = bmesh.new()
    m = Matrix.Translation(c) @ tilt
    frame_geom = bmesh.ops.create_cube(bm, size=1.0, matrix=m @ Matrix.Diagonal((.27, .015, .30, 1)))
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=.008, segments=3, affect='EDGES', clamp_overlap=True)
    out.append(finish('solar_frame', bm, collection, mats['orange']))
    # cell face with UVs 0..1 so the material can draw the cell grid
    bm = bmesh.new()
    uv = bm.loops.layers.uv.new('UVMap')
    hw, hh = .117, .13
    corners = [(-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)]
    vs = [bm.verts.new(m @ Vector((px, .0082, pz))) for px, pz in corners]
    f = bm.faces.new(vs)
    for loop, (px, pz) in zip(f.loops, corners):
        loop[uv].uv = ((px + hw) / (2 * hw), (pz + hh) / (2 * hh))
    bmesh.ops.recalc_face_normals(bm, faces=[f])
    if f.normal.y < 0:
        bmesh.ops.reverse_faces(bm, faces=[f])
    out.append(finish('solar_cells', bm, collection, mats['solar_cells'], smooth=False))
    # corner brackets and bolts
    bm = bmesh.new()
    for sx in (-1, 1):
        for sz in (-1, 1):
            rbox(bm, m @ Vector((sx * .128, .01, sz * .141)), (.03, .006, .03), (X, BACK, UP), .002, 1)
    out.append(finish('solar_brackets', bm, collection, mats['steel']))
    return out


def bottle(collection, mats, pack_c, dims):
    w, h, d = dims
    out = []
    c = Vector((w / 2 + .03, pack_c.y + .01, 1.12))
    bm = bmesh.new()
    rbox(bm, c, (.07, .075, .16), (X, BACK, UP), .028, 5)
    out.append(finish('bottle_pocket', bm, collection, mats['pack_cream']))
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=24, radius1=.032, radius2=.032, depth=.07,
                          matrix=Matrix.Translation(c + Vector((0, 0, .11))))
    bmesh.ops.create_cone(bm, cap_ends=True, segments=24, radius1=.026, radius2=.022, depth=.028,
                          matrix=Matrix.Translation(c + Vector((0, 0, .158))))
    out.append(finish('bottle', bm, collection, mats['steel'], bevel=.002))
    bm = bmesh.new()
    rbox(bm, c + Vector((0, 0, -.1)), (.065, .06, .05), (X, BACK, UP), .02, 3)
    out.append(finish('bottle_pouch', bm, collection, mats['pack_tan']))
    return out


def camera_bot(collection, mats, pack_c, dims):
    """The AI's physical body: a camera head on a two-joint arm, clamped to the pack top."""
    w, h, d = dims
    out = []
    k = 1.4
    base = Vector((-.1, pack_c.y - .01, 1.425))
    j1 = base + Vector((0, 0, .04)) * k
    j2 = j1 + Vector((-.012, -.02, .045)) * k
    head_c = j2 + Vector((0, -.012, .045)) * k
    bm = bmesh.new()
    for a, b, r in ((base, j1, .011 * k), (j1, j2, .009 * k)):
        dvec = b - a
        m = Matrix.Translation((a + b) / 2) @ dvec.to_track_quat('Z', 'Y').to_matrix().to_4x4()
        bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=r, radius2=r * .85, depth=dvec.length, matrix=m)
    for p, r in ((base, .02 * k), (j1, .015 * k), (j2, .013 * k)):
        bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=10, radius=r, matrix=Matrix.Translation(p))
    rbox(bm, base + Vector((0, 0, -.012)), (.06, .06, .024), (X, BACK, UP), .006, 2)
    out.append(finish('bot_arm', bm, collection, mats['bot_joint']))
    bm = bmesh.new()
    look = Vector((0, -1, .05)).normalized()
    fx = UP.cross(look).normalized() * -1
    fy = look.cross(fx).normalized() * -1
    rbox(bm, head_c, (.075 * k, .06 * k, .055 * k), (fx, look, fy), .014 * k, 4)
    out.append(finish('bot_head', bm, collection, mats['bot_shell']))
    bm = bmesh.new()
    m = Matrix.Translation(head_c + look * .03 * k) @ look.to_track_quat('Z', 'Y').to_matrix().to_4x4()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=32, radius1=.024 * k, radius2=.022 * k, depth=.014 * k, matrix=m)
    out.append(finish('bot_bezel', bm, collection, mats['bot_joint'], bevel=.0015))
    bm = bmesh.new()
    m = Matrix.Translation(head_c + look * .0375 * k) @ look.to_track_quat('Z', 'Y').to_matrix().to_4x4()
    bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=12, radius=.015 * k,
                              matrix=m @ Matrix.Diagonal((1, 1, .45, 1)))
    out.append(finish('bot_lens', bm, collection, mats['status_heart']))
    bm = bmesh.new()
    for s in (1, -1):
        rbox(bm, head_c + fx * s * .04 * k, (.008 * k, .03 * k, .03 * k), (fx, look, fy), .003, 2)
    out.append(finish('bot_ears', bm, collection, mats['bot_joint']))
    return out


def strap_path(tree, route, lift):
    pts = []
    for p in route:
        loc, n, _, _ = tree.find_nearest(Vector(p))
        pts.append((loc + n * lift, n))
    fine = []
    for i in range(len(pts) - 1):
        p0 = pts[max(i - 1, 0)][0]
        p1, n1 = pts[i]
        p2, n2 = pts[i + 1]
        p3 = pts[min(i + 2, len(pts) - 1)][0]
        for k in range(8):
            t = k / 8
            q = .5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t ** 3)
            fine.append((q, n1.lerp(n2, t).normalized()))
    fine.append(pts[-1])
    return fine


def ribbon(name, path, width, thick, collection, mat):
    bm = bmesh.new()
    rows = []
    for i, (p, n) in enumerate(path):
        t = (path[min(i + 1, len(path) - 1)][0] - path[max(i - 1, 0)][0]).normalized()
        side = t.cross(n).normalized()
        pad = thick * (.6 + .4 * math.sin(math.pi * min(1, i / max(1, len(path) - 1)) ))
        row = []
        for j in range(5):
            u = j / 4 - .5
            bulge = 1 - (2 * u) ** 4
            row.append((bm.verts.new(p + side * u * width + n * pad * bulge), bm.verts.new(p + side * u * width)))
        rows.append(row)
    for a, b in zip(rows, rows[1:]):
        for j in range(4):
            bm.faces.new((a[j][0], a[j + 1][0], b[j + 1][0], b[j][0]))
            bm.faces.new((b[j][1], b[j + 1][1], a[j + 1][1], a[j][1]))
        bm.faces.new((a[0][1], a[0][0], b[0][0], b[0][1]))
        bm.faces.new((b[-1][1], b[-1][0], a[-1][0], a[-1][1]))
    for end in (rows[0], rows[-1]):
        ring = [v for v, _ in end] + [w for _, w in reversed(end)]
        bm.faces.new(ring)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return finish(name, bm, collection, mat)


def shoulder_straps(vest, collection, mats, pack_front_y):
    from .garments import base_tree
    tree = base_tree(vest)
    out = []
    for s in (1, -1):
        route = [(s * .075, pack_front_y + .02, 1.40), (s * .085, .07, 1.445), (s * .095, .0, 1.45),
                 (s * .10, -.07, 1.40), (s * .105, -.11, 1.31), (s * .11, -.12, 1.22), (s * .12, -.11, 1.12)]
        path = strap_path(tree, route, .002)
        out.append(ribbon(f'shoulder_strap_{"l" if s > 0 else "r"}', path, .05, .012, collection, mats['pack_nylon']))
        low = [(s * .12, -.11, 1.12), (s * .15, -.07, 1.08), (s * .165, .02, 1.04), (s * .15, pack_front_y, 1.0)]
        path = strap_path(tree, low, .003)
        out.append(ribbon(f'side_strap_{"l" if s > 0 else "r"}', path, .026, .004, collection, mats['webbing_khaki']))
    # sternum strap and buckle
    route = [(.105, -.125, 1.25), (0, -.14, 1.25), (-.105, -.125, 1.25)]
    path = strap_path(tree, route, .02)
    out.append(ribbon('sternum_strap', path, .02, .003, collection, mats['webbing']))
    bm = bmesh.new()
    loc, n, _, _ = tree.find_nearest(Vector((0, -.14, 1.25)))
    rbox(bm, loc + n * .026, (.04, .024, .01), (X, UP, n), .004, 2)
    out.append(finish('sternum_buckle', bm, collection, mats['rubber_grip']))
    return out


def build(vest, collection, mats):
    front_y = .135
    parts, c, dims = pack_body(collection, mats, front_y)
    parts += solar_panel(collection, mats, c, dims)
    parts += bottle(collection, mats, c, dims)
    parts += camera_bot(collection, mats, c, dims)
    parts += shoulder_straps(vest, collection, mats, front_y)
    return parts
