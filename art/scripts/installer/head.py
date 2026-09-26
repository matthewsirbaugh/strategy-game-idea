"""Head wear and hair: the twisted rust headband and the curly updo."""
import math
import random
import bmesh
import bpy
from mathutils import Vector, Matrix, noise
from mathutils.bvhtree import BVHTree
from . import garments as G

ss = G.smoothstep


def head_tree(body):
    bm = bmesh.new()
    bm.from_mesh(body.data)
    doomed = [f for f in bm.faces if f.calc_center_median().z < 1.40]
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    tree = BVHTree.FromBMesh(bm)
    return tree, bm


def surface_loop(tree, center, plane_n, count, lift):
    """Points where rays from center, swept in the plane with normal plane_n, leave the head."""
    ref = Vector((0, -1, 0))
    ref = (ref - plane_n * ref.dot(plane_n)).normalized()
    side = plane_n.cross(ref)
    pts, normals = [], []
    for i in range(count):
        a = 2 * math.pi * i / count
        d = ref * math.cos(a) + side * math.sin(a)
        hit = tree.ray_cast(center + d * .3, -d)
        loc, n = hit[0], hit[1]
        if loc is None:
            loc, n = center + d * .09, d
        pts.append(loc + n * lift)
        normals.append(n)
    return pts, normals


BAND_FRONT, BAND_BACK = Vector((0, -.10, 1.603)), Vector((0, .09, 1.51))
BAND_WIDTH = .052


def band_plane():
    n = (BAND_FRONT - BAND_BACK).cross(Vector((1, 0, 0))).normalized()
    if n.z < 0:
        n = -n
    return (BAND_FRONT + BAND_BACK) / 2, n


def under_band(p, margin=.006):
    c, n = band_plane()
    return abs((p - c).dot(n)) < BAND_WIDTH / 2 + margin


def headband(body, collection, mat, width=BAND_WIDTH, thick=.0065, hair=.010):
    tree, bm_head = head_tree(body)
    center_p, plane_n = band_plane()
    n_seg = 128
    pts, normals = surface_loop(tree, center_p, plane_n, n_seg, hair + thick * .5)
    bm = bmesh.new()
    rows = 11
    ring = []
    for i, (p, n) in enumerate(zip(pts, normals)):
        t = (pts[(i + 1) % n_seg] - pts[i - 1]).normalized()
        w = n.cross(t).normalized()
        if w.dot(plane_n) < 0:
            w = -w
        s = i / n_seg
        col = []
        for j in range(rows):
            u = j / (rows - 1) - .5
            bulge = math.cos(u * math.pi) ** .6 if abs(u) < .5 else 0.0
            # soft diagonal pleats, crowding toward the knot at the front right
            crowd = 1 + 1.5 * math.exp(-((s - .93 + .5) % 1 - .5) ** 2 / .004)
            phase = s * 7 * crowd + u * .9
            pleat = .0026 * (abs(math.sin(math.pi * phase)) ** .5 - .5)
            lump = .0012 * noise.noise(Vector((s * 25, u * 3, 1.7)))
            out = n * (thick * .5 * bulge + (pleat + lump) * bulge)
            col.append((p + w * u * width + out, p + w * u * width - n * thick * .4 * bulge))
        ring.append(col)
    outer = [[bm.verts.new(c[j][0]) for j in range(rows)] for c in ring]
    inner = [[bm.verts.new(c[j][1]) for j in range(rows)] for c in ring]
    for i in range(n_seg):
        a, b = outer[i], outer[(i + 1) % n_seg]
        c, d = inner[i], inner[(i + 1) % n_seg]
        for j in range(rows - 1):
            bm.faces.new((a[j], b[j], b[j + 1], a[j + 1]))
            bm.faces.new((c[j + 1], d[j + 1], d[j], c[j]))
        bm.faces.new((a[0], c[0], d[0], b[0]))
        bm.faces.new((b[-1], d[-1], c[-1], a[-1]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new('headband')
    bm.to_mesh(me)
    bm.free()
    band = bpy.data.objects.new('headband', me)
    collection.objects.link(band)
    me.materials.append(mat)
    for poly in me.polygons:
        poly.use_smooth = True
    knot = headband_knot(pts, normals, plane_n, collection, mat, width, thick)
    bm_head.free()
    return band, knot


def headband_knot(pts, normals, plane_n, collection, mat, width, thick):
    """Two flattened fabric strands twisted round each other, front and to her right."""
    count = len(pts)
    i0 = int(count * .93)
    span = 5
    path = [pts[(i0 + k) % count] + normals[(i0 + k) % count] * (thick + .004) for k in range(-span, span + 1)]
    frames = parallel_frames(path)
    bm = bmesh.new()
    steps, sides = 40, 14
    for strand in (0, 1):
        rings = []
        for i in range(steps + 1):
            s = i / steps
            k = s * (len(path) - 1)
            j = min(int(k), len(path) - 2)
            f = k - j
            c = path[j].lerp(path[j + 1], f)
            t, n, b = frames[j]
            nrm = normals[(i0 - span + j) % count]
            side = nrm.cross(t).normalized()
            a = math.pi * strand + 2 * math.pi * 1.1 * s
            swell = math.sin(math.pi * s) ** .7
            cen = c + (side * math.cos(a) * .010 + nrm * math.sin(a) * .006) * swell
            ring = []
            for q in range(sides):
                th = 2 * math.pi * q / sides
                # flattened cross-section that rotates with the twist
                ex, ey = .012 * (.55 + .45 * swell), .0055 * (.6 + .4 * swell)
                lx, ly = ex * math.cos(th), ey * math.sin(th)
                ca, sa = math.cos(a + .6), math.sin(a + .6)
                off = side * (lx * ca - ly * sa) + nrm * (lx * sa + ly * ca)
                ring.append(bm.verts.new(cen + off))
            rings.append(ring)
        for i in range(steps):
            for q in range(sides):
                q2 = (q + 1) % sides
                bm.faces.new((rings[i][q], rings[i][q2], rings[i + 1][q2], rings[i + 1][q]))
        bm.faces.new(rings[0])
        bm.faces.new(list(reversed(rings[-1])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for v in bm.verts:
        v.co += v.normal * .0009 * noise.noise(v.co * 400)
    me = bpy.data.meshes.new('headband_knot')
    bm.to_mesh(me)
    bm.free()
    knot = bpy.data.objects.new('headband_knot', me)
    collection.objects.link(knot)
    me.materials.append(mat)
    for poly in me.polygons:
        poly.use_smooth = True
    return knot


def parallel_frames(points):
    tangents = []
    for i in range(len(points)):
        a = points[max(i - 1, 0)]
        b = points[min(i + 1, len(points) - 1)]
        tangents.append((b - a).normalized())
    t0 = tangents[0]
    n = t0.orthogonal().normalized()
    frames = []
    for t in tangents:
        n = (n - t * n.dot(t)).normalized()
        frames.append((t, n, t.cross(n)))
    return frames


def ringlet(bm, uv_layer, spine, length, helix_r, pitch, tube_r, phase, sides=6, per_turn=10,
            color=None, color_layer=None, taper_root=.35):
    """Sweep a tapered tube along a helix wound around spine(s), s in 0..1."""
    turns = length / pitch
    steps = max(8, int(turns * per_turn))
    axis = [spine(i / steps) for i in range(steps + 1)]
    frames = parallel_frames(axis)
    centers = []
    for i, (p, (t, n, b)) in enumerate(zip(axis, frames)):
        s = i / steps
        r = helix_r * (ss(0, .12, s) * .8 + .2) * (1 - .25 * s)
        a = phase + 2 * math.pi * turns * s
        centers.append(p + (n * math.cos(a) + b * math.sin(a)) * r)
    tframes = parallel_frames(centers)
    rings = []
    for i, (c, (t, n, b)) in enumerate(zip(centers, tframes)):
        s = i / steps
        rad = tube_r * (1 - .75 * ss(.75, 1.0, s)) * (1 - taper_root * (1 - ss(0, .08, s)))
        ring = []
        for k in range(sides):
            a = 2 * math.pi * k / sides
            ring.append(bm.verts.new(c + (n * math.cos(a) + b * math.sin(a)) * rad))
        rings.append(ring)
    faces = []
    for i in range(steps):
        for k in range(sides):
            k2 = (k + 1) % sides
            f = bm.faces.new((rings[i][k], rings[i][k2], rings[i + 1][k2], rings[i + 1][k]))
            faces.append(f)
            for loop, (u, v) in zip(f.loops, ((k / sides, i / steps), ((k + 1) / sides, i / steps),
                                              ((k + 1) / sides, (i + 1) / steps), (k / sides, (i + 1) / steps))):
                loop[uv_layer].uv = (u, v * turns)
                if color_layer is not None:
                    loop[color_layer] = color
    tip = bm.faces.new(list(reversed(rings[-1])))
    faces.append(tip)
    return faces


def curve_spine(p0, d0, length, gravity=0.0, curl_to=None, wobble=.0, seed=0):
    """A gently bending path from p0 along d0; gravity bends it down, curl_to bends toward a point."""
    rng = random.Random(seed)
    k = Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-1, 1))) * wobble

    def f(s):
        d = d0 * (length * s)
        d += Vector((0, 0, -gravity)) * (length * s) ** 2
        if curl_to is not None:
            d += (curl_to - p0) * .25 * s * s
        d += k * math.sin(math.pi * s) * length
        return p0 + d
    return f


def hairline(ax):
    """Height of the front hairline at distance ax from the midline: down to the sideburns."""
    if ax < .038:
        return 1.62
    if ax < .058:
        return 1.62 - (ax - .038) / .02 * .035
    return 1.585 - min(1.0, (ax - .058) / .014) * .045


def scalp_cap(body, collection, mat, lift=.006):
    def keep(c, n):
        ax = abs(c.x)
        if c.z < 1.465:
            return False
        if c.y < -.02 and c.z < hairline(ax):
            return False
        ear = ax > .064 and 1.48 < c.z < 1.572 and -.036 < c.y < .03
        return not ear
    cap = G.extract(body, 'hair_cap', keep, collection)
    G.largest_part(cap)
    G.subdivide(cap, 1)
    bm = bmesh.new()
    bm.from_mesh(cap.data)
    edge = {v.index for v in bm.verts if v.is_boundary}
    ring2 = {e.other_vert(bm.verts[i]).index for i in edge for e in bm.verts[i].link_edges} if False else set()
    bm.verts.ensure_lookup_table()
    for i in list(edge):
        for e in bm.verts[i].link_edges:
            ring2.add(e.other_vert(bm.verts[i]).index)
    bm.free()
    normals = [v.normal.copy() for v in cap.data.vertices]
    for v, n in zip(cap.data.vertices, normals):
        f = 0.0 if v.index in edge else (.45 if v.index in ring2 else 1.0)
        v.co += n * (lift + .003 * ss(1.60, 1.66, v.co.z)) * f
    G.relax(cap, 3, .3)
    cap.data.materials.append(mat)
    for p in cap.data.polygons:
        p.use_smooth = True
    return cap


def sample_surface(obj, count, rng, accept):
    """Area-weighted random points on obj's faces for which accept(point) is true."""
    me = obj.data
    me.calc_loop_triangles()
    tris = [(t, t.area) for t in me.loop_triangles]
    total = sum(a for _, a in tris)
    out = []
    tries = 0
    while len(out) < count and tries < count * 40:
        tries += 1
        r = rng.random() * total
        for t, a in tris:
            r -= a
            if r <= 0:
                break
        a, b, c = (me.vertices[i].co for i in t.vertices)
        u, v = rng.random(), rng.random()
        if u + v > 1:
            u, v = 1 - u, 1 - v
        p = a + (b - a) * u + (c - a) * v
        if accept(p):
            out.append((p, t.normal.copy()))
    return out


def hair(body, cap, collection, mat, seed=7, detail=1.0):
    rng = random.Random(seed)
    bm = bmesh.new()
    uv = bm.loops.layers.uv.new('UVMap')
    col = bm.loops.layers.color.new('hair_tint')
    bun_c = Vector((0, .05, 1.665))

    def tint():
        v = rng.uniform(.8, 1.3)
        return (v, v * rng.uniform(.92, 1.0), v * rng.uniform(.82, .98), 1.0)

    def coil(spine, L, r, p, t, taper_root=.35):
        ringlet(bm, uv, spine, L, r, p, t, rng.uniform(0, 6.28), sides=6, per_turn=9,
                color=tint(), color_layer=col, taper_root=taper_root)

    # bun: fat ringlets radiating from a core high on the back of the head
    n_bun = int(230 * detail)
    golden = math.pi * (3 - math.sqrt(5))
    for i in range(n_bun):
        y = 1 - 2 * (i + .5) / n_bun
        r = math.sqrt(max(0, 1 - y * y))
        th = golden * i
        d = Vector((math.cos(th) * r, math.sin(th) * r, y))
        if d.z < -.45 or (d.y < -.35 and d.z < .35):
            continue
        d = (d + Vector((0, .15, .1))).normalized()
        root = bun_c + Vector((d.x * .041, d.y * .039, d.z * .036))
        L = rng.uniform(.045, .07)
        spine = curve_spine(root, d, L, gravity=rng.uniform(.1, .45), wobble=.3, seed=i)
        coil(spine, L, rng.uniform(.0055, .0075), rng.uniform(.009, .012), rng.uniform(.0036, .0046))
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=1.0,
                               matrix=Matrix.Translation(bun_c) @ Matrix.Diagonal((.048, .046, .042, 1)))
    # loose tendrils at the temples, in front of the ears, and at the nape
    tendrils = [((.058, -.058, 1.588), (.25, -.35, -1), .105), ((.066, -.04, 1.572), (.35, -.1, -1), .09),
                ((-.058, -.058, 1.59), (-.25, -.35, -1), .115), ((-.066, -.042, 1.574), (-.35, -.05, -1), .085),
                ((.035, .075, 1.485), (.25, .35, -1), .07), ((-.03, .078, 1.49), (-.2, .35, -1), .08),
                ((.005, .082, 1.495), (0, .4, -1), .055)]
    for k, (p, d, L) in enumerate(tendrils):
        spine = curve_spine(Vector(p), Vector(d).normalized(), L, gravity=.35, wobble=.15, seed=100 + k)
        coil(spine, L, rng.uniform(.0075, .0095), rng.uniform(.014, .018), rng.uniform(.0034, .0042), .55)
    # curls lying on the scalp, swept toward the bun; the band hides the front ones
    def on_scalp(p):
        return p.z > 1.505 and not under_band(p)
    for k, (root, n) in enumerate(sample_surface(cap, int(70 * detail), rng, on_scalp)):
        to_bun = bun_c - root
        dirn = (to_bun - n * to_bun.dot(n)).normalized()
        L = rng.uniform(.03, .045)
        base = root + n * .004
        spine = curve_spine(base, (dirn + n * .15).normalized(), L, wobble=.15, seed=300 + k)
        coil(spine, L, rng.uniform(.004, .0055), rng.uniform(.008, .011), rng.uniform(.003, .0038))
    me = bpy.data.meshes.new('hair')
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new('hair', me)
    collection.objects.link(obj)
    me.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = True
    return obj
