"""Belt kit and hip gear, fitted to the draped trousers."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree


def tree_of(obj):
    from .garments import base_tree
    return base_tree(obj)


def loop_on(tree, z, count, center=(0, 0), lift=.0, tilt=0.0, reach=.4):
    """Horizontal loop hugging a surface at height z (front edge tilted by tilt metres)."""
    pts = []
    for i in range(count):
        a = 2 * math.pi * i / count
        d = Vector((math.sin(a), -math.cos(a), 0))
        zz = z + tilt * max(0.0, -d.y)
        origin = Vector((center[0], center[1], zz))
        hit = tree.ray_cast(origin + d * reach, -d)
        loc, n = hit[0], hit[1]
        if loc is None:
            loc, n = origin + d * .15, d
        n = Vector((n.x, n.y, 0)).normalized() if Vector((n.x, n.y)).length > .1 else d
        pts.append((loc + n * lift, n))
    return pts


def strap_ring(name, pts, width, thick, collection, mat, rows=3):
    """A closed band through pts [(point, outward normal)], width along Z."""
    bm = bmesh.new()
    n = len(pts)
    grid = []
    for p, nrm in pts:
        col = []
        for j in range(rows):
            u = j / (rows - 1) - .5
            base = p + Vector((0, 0, u * width))
            col.append((bm.verts.new(base + nrm * thick), bm.verts.new(base)))
        grid.append(col)
    for i in range(n):
        a, b = grid[i], grid[(i + 1) % n]
        for j in range(rows - 1):
            bm.faces.new((a[j][0], b[j][0], b[j + 1][0], a[j + 1][0]))
            bm.faces.new((a[j + 1][1], b[j + 1][1], b[j][1], a[j][1]))
        bm.faces.new((a[0][1], b[0][1], b[0][0], a[0][0]))
        bm.faces.new((a[-1][0], b[-1][0], b[-1][1], a[-1][1]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return finish(name, bm, collection, mat)


def finish(name, bm, collection, mat, smooth=True, bevel=0.0):
    if bevel:
        bmesh.ops.bevel(bm, geom=[e for e in bm.edges if e.calc_face_angle(0) > .6], offset=bevel,
                        segments=2, affect='EDGES', clamp_overlap=True)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    collection.objects.link(obj)
    if mat:
        me.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = smooth
    if smooth:
        mod = obj.modifiers.new('ws', 'WEIGHTED_NORMAL')
        mod.keep_sharp = True
    return obj


def rbox(bm, center, size, frame, bevel=.004, segments=3):
    """Rounded box with local axes frame=(x, y, z) unit vectors."""
    x, y, z = frame
    m = Matrix(((x.x, y.x, z.x, center.x), (x.y, y.y, z.y, center.y), (x.z, y.z, z.z, center.z), (0, 0, 0, 1)))
    geom = bmesh.ops.create_cube(bm, size=1.0, matrix=m @ Matrix.Diagonal((*size, 1)))
    if bevel:
        edges = list({e for v in geom['verts'] for e in v.link_edges})
        bmesh.ops.bevel(bm, geom=edges, offset=bevel, segments=segments, affect='EDGES', clamp_overlap=True)
    return geom


def surface_frame(tree, point_guess, toward):
    """Nearest surface point and a frame (tangent x, up y, normal z) for gear sitting on the body."""
    loc, n, _, _ = tree.find_nearest(point_guess)
    n = n.normalized()
    up = Vector((0, 0, 1))
    x = up.cross(n).normalized()
    y = n.cross(x).normalized()
    return loc, (x, y, n)


def belt(trousers, collection, mats, z=.936):
    tree = tree_of(trousers)
    pts = loop_on(tree, z, 120, lift=.001)
    web = strap_ring('belt', pts, .044, .0045, collection, mats['webbing'], rows=4)
    low = loop_on(tree, z - .034, 120, lift=.001)
    tool = strap_ring('tool_belt', low, .024, .005, collection, mats['leather_belt'], rows=3)
    piping = loop_on(tree, z - .034 - .0125, 120, lift=.003)
    trim = strap_ring('tool_belt_piping', piping, .004, .003, collection, mats['orange'], rows=2)
    # cobra-style buckle, front and slightly to her left
    front = min(pts, key=lambda pn: (pn[0] - Vector((.03, -1, z))).length)
    p, n = front
    x = Vector((0, 0, 1)).cross(n).normalized()
    y = Vector((0, 0, 1))
    bm = bmesh.new()
    c = p + n * .008
    rbox(bm, c, (.052, .046, .01), (x, y, n), .004)
    rbox(bm, c + n * .006 + x * .0, (.026, .03, .008), (x, y, n), .003)
    for s in (-1, 1):
        rbox(bm, c + x * s * .03, (.01, .05, .006), (x, y, n), .002)
    buckle = finish('belt_buckle', bm, collection, mats['steel'])
    return [web, tool, trim, buckle]


def belt_loops(trousers, collection, mat, z=.936, count=7):
    tree = tree_of(trousers)
    bm = bmesh.new()
    for i in range(count):
        a = -2.3 + 4.6 * i / (count - 1)
        d = Vector((math.sin(a), -math.cos(a), 0))
        hit = tree.ray_cast(Vector((0, 0, z)) + d * .4, -d)
        if hit[0] is None:
            continue
        n = Vector((hit[1].x, hit[1].y, 0)).normalized()
        x = Vector((0, 0, 1)).cross(n).normalized()
        rbox(bm, hit[0] + n * .0055, (.012, .056, .003), (x, Vector((0, 0, 1)), n), .0012, 2)
    return finish('belt_loops', bm, collection, mat)


def hip_pouch(trousers, collection, mats):
    """Leather phone-size pouch with orange piping, hanging at her right hip."""
    tree = tree_of(trousers)
    loc, (x, y, n) = surface_frame(tree, Vector((-.14, -.075, .855)), None)
    c = loc + n * .026
    bm = bmesh.new()
    rbox(bm, c, (.09, .125, .045), (x, y, n), .008, 3)
    body = finish('hip_pouch', bm, collection, mats['leather'])
    bm = bmesh.new()
    rbox(bm, c + n * .024 + y * .038, (.094, .06, .007), (x, y, n), .005, 3)
    flap = finish('hip_pouch_flap', bm, collection, mats['leather'])
    bm = bmesh.new()
    for s in (-1, 1):
        rbox(bm, c + x * s * .046, (.004, .128, .047), (x, y, n), .0018, 2)
    trim = finish('hip_pouch_piping', bm, collection, mats['orange'])
    bm = bmesh.new()
    rbox(bm, c + n * .03 + y * .02, (.018, .05, .004), (x, y, n), .0015, 2)
    rbox(bm, c + n * .034 + y * .008, (.02, .012, .006), (x, y, n), .002, 2)
    strap = finish('hip_pouch_strap', bm, collection, mats['leather_dark'])
    bm = bmesh.new()
    rbox(bm, c + n * .036 + y * .008, (.012, .008, .004), (x, y, n), .0012, 2)
    bm2 = finish('hip_pouch_buckle', bm, collection, mats['brass'])
    # belt loop the pouch hangs from
    bm = bmesh.new()
    rbox(bm, c - n * .018 + y * .085, (.03, .06, .004), (x, y, n), .0015, 2)
    hanger = finish('hip_pouch_hanger', bm, collection, mats['leather_dark'])
    return [body, flap, trim, strap, bm2, hanger]


def carabiner(bm, top, down, side, size=.055, wire=.0035):
    """D-shaped climbing carabiner hanging from top."""
    pts = []
    for i in range(24):
        a = 2 * math.pi * i / 24
        px = .28 * size * math.cos(a) * (1.0 if math.cos(a) > 0 else .8)
        py = -.5 * size * (1 - math.sin(a)) * .9
        pts.append(top + side * px + down * (-py))
    rings = []
    for i, p in enumerate(pts):
        t = (pts[(i + 1) % 24] - pts[i - 1]).normalized()
        nrm = side.cross(down).normalized()
        b = t.cross(nrm).normalized()
        ring = [bm.verts.new(p + (nrm * math.cos(2 * math.pi * k / 6) + b * math.sin(2 * math.pi * k / 6)) * wire)
                for k in range(6)]
        rings.append(ring)
    for i in range(24):
        a, b = rings[i], rings[(i + 1) % 24]
        for k in range(6):
            bm.faces.new((a[k], a[(k + 1) % 6], b[(k + 1) % 6], b[k]))


def carabiners(trousers, collection, mats):
    tree = tree_of(trousers)
    out = []
    for k, (x0, mat, size) in enumerate(((-.075, 'steel', .058), (-.095, 'steel', .052), (-.112, 'orange_metal', .05))):
        loc, (x, y, n) = surface_frame(tree, Vector((x0, -.12, .915)), None)
        top = loc + n * .012
        bm = bmesh.new()
        down = (-y * .95 + n * .15).normalized()
        carabiner(bm, top, down, (x * math.cos(.4 * k) + n * math.sin(.4 * k)).normalized(), size)
        out.append(finish(f'carabiner_{k}', bm, collection, mats[mat]))
    return out


def thigh_rig(trousers, collection, mats):
    """Webbing strap round the right thigh carrying a tool holster on the outer thigh."""
    tree = tree_of(trousers)
    pts = loop_on(tree, .735, 64, center=(-.13, -.035), lift=.001, tilt=-.035, reach=.11)
    strap = strap_ring('thigh_strap', pts, .03, .003, collection, mats['webbing_grey'], rows=3)
    loc, (x, y, n) = surface_frame(tree, Vector((-.205, -.02, .70)), None)
    c = loc + n * .016
    bm = bmesh.new()
    rbox(bm, c, (.05, .15, .026), (x, y, n), .006, 3)
    holster = finish('thigh_holster', bm, collection, mats['leather_dark'])
    bm = bmesh.new()
    for s in (-1, 1):
        rbox(bm, c + y * .105 + x * s * .009, (.009, .07, .009), (x, y, n), .003, 2)
    rbox(bm, c + y * .078, (.03, .014, .014), (x, y, n), .003, 2)
    tool = finish('thigh_tool', bm, collection, mats['orange'])
    bm = bmesh.new()
    rbox(bm, c + y * .145, (.024, .02, .012), (x, y, n), .004, 2)
    head = finish('thigh_tool_head', bm, collection, mats['steel'])
    # strap from the belt down to the holster
    bm = bmesh.new()
    top, (tx, ty, tn) = surface_frame(tree, Vector((-.15, -.06, .905)), None)
    mid = (top + c) / 2
    d = (c - top)
    frame_y = d.normalized()
    frame_z = ((tn + n) / 2).normalized()
    frame_x = frame_y.cross(frame_z).normalized()
    frame_z = frame_x.cross(frame_y).normalized()
    rbox(bm, mid + frame_z * .006, (.028, d.length, .003), (frame_x, frame_y, frame_z), .001, 1)
    drop = finish('thigh_drop_strap', bm, collection, mats['webbing_grey'])
    return [strap, holster, tool, head, drop]


def tool_sheath(trousers, collection, mats):
    """Leather tool sheath on her left hip with a pry-bar handle."""
    tree = tree_of(trousers)
    loc, (x, y, n) = surface_frame(tree, Vector((.175, -.03, .80)), None)
    c = loc + n * .016
    bm = bmesh.new()
    rbox(bm, c, (.045, .13, .02), (x, y, n), .006, 3)
    sheath = finish('tool_sheath', bm, collection, mats['leather_tan'])
    bm = bmesh.new()
    rbox(bm, c + y * .1 + n * .004, (.018, .09, .014), (x, y, n), .005, 2)
    grip = finish('tool_grip', bm, collection, mats['rubber_grip'])
    bm = bmesh.new()
    rbox(bm, c + y * .06 + n * .006, (.05, .014, .024), (x, y, n), .003, 2)
    band = finish('tool_sheath_strap', bm, collection, mats['orange'])
    return [sheath, grip, band]
