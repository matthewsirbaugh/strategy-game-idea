"""Rust work shirt: tucked in, bloused over the belt, sleeves bunched above a roll below the elbow."""
import math
import bmesh
import bpy
from mathutils import Vector
from . import garments as G

ss = G.smoothstep
HEM = .935          # tucked inside the trousers
ROLL = .055         # sleeve ends this far below the elbow, along the forearm
PULL = .035         # sleeves start this much longer and are pushed up to the roll by the sim


def arm_frame(rig, side):
    m = rig.matrix_world
    elbow = m @ rig.data.bones[f'lowerarm_{side}'].head_local
    wrist = m @ rig.data.bones[f'hand_{side}'].head_local
    shoulder = m @ rig.data.bones[f'upperarm_{side}'].head_local
    return shoulder, elbow, (wrist - elbow).normalized()


def dominant_bone(body):
    names = {vg.index: vg.name for vg in body.vertex_groups}
    best = []
    for v in body.data.vertices:
        top = max(v.groups, key=lambda g: g.weight if names[g.group][:4] in
                  ('uppe', 'lowe', 'hand', 'clav', 'spin', 'neck', 'pelv', 'thig', 'head') else -1, default=None)
        best.append(names[top.group] if top else '')
    return best


def shell(body, rig, collection):
    frames = {s: arm_frame(rig, s) for s in 'lr'}
    bones = dominant_bone(body)
    me = body.data

    def keep(center, normal):
        return True

    obj = G.extract(body, 'shirt', lambda c, n: .88 < c.z < 1.47 and not (abs(c.x) < .09 and c.z > 1.40), collection)
    # drop hands and anything past the sleeve cut (plus the pull allowance)
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    doomed = []
    for f in bm.faces:
        c = f.calc_center_median()
        side = 'l' if c.x > 0 else 'r'
        shoulder, elbow, fore = frames[side]
        if abs(c.x) > .13 and (c - elbow).dot(fore) > ROLL + PULL + .02:
            doomed.append(f)
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    bm.to_mesh(obj.data)
    bm.free()
    G.largest_part(obj)
    G.subdivide(obj, 1)

    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=(0, 0, HEM),
                           plane_no=(0, 0, -1), clear_outer=True)
    for side in 'lr':
        shoulder, elbow, fore = frames[side]
        cut = elbow + fore * (ROLL + PULL)
        geom = [f for f in bm.faces if (f.calc_center_median().x > 0) == (side == 'l')]
        verts = {v for f in geom for v in f.verts}
        edges = {e for f in geom for e in f.edges}
        bmesh.ops.bisect_plane(bm, geom=list(verts) + list(edges) + geom, plane_co=cut, plane_no=fore,
                               clear_outer=True)
    # neckline: lower at the front, with a shallow V where the top button is open
    neck = [f for f in bm.faces if f.calc_center_median().z > 1.30]
    doomed = []
    for f in neck:
        c = f.calc_center_median()
        limit = 1.402 + c.y * .45
        if c.y < -.02:
            limit = min(limit, 1.305 + abs(c.x) * 1.9)
        if c.z > limit:
            doomed.append(f)
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    bm.to_mesh(obj.data)
    bm.free()
    G.largest_part(obj)
    G.smooth_boundary(obj, 20, .5, lambda co: co.z > 1.25)

    def ease(co):
        side = 'l' if co.x > 0 else 'r'
        shoulder, elbow, fore = frames[side]
        arm = ss(.12, .17, abs(co.x)) * ss(1.36, 1.28, co.z) if co.z > 1.0 else 0.0
        along = (co - shoulder).length
        torso = .004 + .004 * ss(1.25, 1.05, co.z) + .012 * ss(.945, .985, co.z) * ss(1.06, 1.0, co.z)
        torso -= .003 * ss(.955, .93, co.z)
        sleeve = .009 + .012 * ss(.05, .22, along)
        return torso * (1 - arm) + sleeve * arm
    G.offset(obj, ease)
    # a shirt bridges the cleavage and the small of the back
    G.relax(obj, 25, .5, lambda co: ss(.08, .0, abs(co.x)) * ss(1.06, 1.14, co.z) * ss(1.32, 1.24, co.z))
    G.relax(obj, 3, .3)
    return obj, frames


def smooth_collider(body, collection):
    """Torso and arms with the chest and navel smoothed, as if over a sports top."""
    col = G.extract(body, 'torso_collider', lambda c, n: c.z > .8, collection)
    G.relax(col, 30, .5, lambda co: ss(.03, .07, abs(co.x)) * ss(.13, .09, abs(co.x)) * ss(1.12, 1.17, co.z)
            * ss(1.28, 1.23, co.z) * ss(-.05, -.09, co.y))
    G.relax(col, 20, .5, lambda co: ss(.05, .0, abs(co.x)) * ss(.95, 1.0, co.z) * ss(1.08, 1.03, co.z) * ss(-.03, -.08, co.y))
    G.offset(col, lambda co: .0015)
    col.hide_render = True
    return col


def drape(obj, frames, body, collection):
    collider = smooth_collider(body, collection)
    G.collider(collider, collection, thickness=.003)
    me = obj.data
    natural = [v.co.copy() for v in me.vertices]
    # Basis: sleeves extended by PULL; key 'target' pushes the cuffs back to the roll line.
    for v, n in zip(me.vertices, natural):
        side = 'l' if n.x > 0 else 'r'
        shoulder, elbow, fore = frames[side]
        t = (n - elbow).dot(fore)
        if abs(n.x) > .14 and t > -.10:
            w = ss(-.10, ROLL + PULL, t)
            v.co = n + fore * 0.0 * w
    obj.shape_key_add(name='Basis')
    key = obj.shape_key_add(name='target')
    for i, n in enumerate(natural):
        side = 'l' if n.x > 0 else 'r'
        shoulder, elbow, fore = frames[side]
        t = (n - elbow).dot(fore)
        co = n.copy()
        if abs(n.x) > .14 and t > ROLL - .02:
            # everything beyond the roll line slides back along the forearm
            co = n - fore * min(PULL, t - (ROLL - .02))
        key.data[i].co = co
    key.value = 0.0
    key.keyframe_insert('value', frame=1)
    key.value = 1.0
    key.keyframe_insert('value', frame=20)

    def pinned(co):
        side = 'l' if co.x > 0 else 'r'
        shoulder, elbow, fore = frames[side]
        if co.z < HEM + .012:
            return 1.0
        if abs(co.x) > .14 and (co - elbow).dot(fore) > ROLL + PULL - .012:
            return 1.0
        if co.z > 1.37 or (co.y < -.03 and co.z > 1.29 and abs(co.x) < .07):
            return 1.0
        return 0.0
    G.group(obj, 'pin', pinned)
    G.drape(obj, 36, pin='pin', mass=.25, tension=25, compression=40, bending=9.0, quality=8)
    bpy.data.objects.remove(collider, do_unlink=True)
    obj.vertex_groups.remove(obj.vertex_groups['pin'])
    G.subdivide(obj, 1)


def sleeve_ring(obj, frames, side):
    """Boundary vertices at the end of one sleeve, and the arm axis point they surround."""
    shoulder, elbow, fore = frames[side]
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    ring = []
    for v in bm.verts:
        if not v.is_boundary or (v.co.x > 0) != (side == 'l'):
            continue
        rel = v.co - elbow
        t = rel.dot(fore)
        if ROLL - .05 < t < ROLL + .05 and (rel - fore * t).length < .09:
            ring.append(v.co.copy())
    bm.free()
    center = sum(ring, Vector()) / len(ring)
    return ring, center


def roll_cuffs(obj, frames, collection, mat, width=.034, thick=.0105):
    """Rolled-up cuffs: a thick folded band hugging the forearm at each sleeve end."""
    from mathutils import noise
    out = []
    for side in 'lr':
        shoulder, elbow, fore = frames[side]
        ring, center = sleeve_ring(obj, frames, side)
        radius = sum((p - center - fore * (p - center).dot(fore)).length for p in ring) / len(ring)
        radius = max(radius, .036)
        ref = fore.orthogonal().normalized()
        side_v = fore.cross(ref)
        bm = bmesh.new()
        n_a, n_p = 48, 14
        rings = []
        for i in range(n_a):
            a = 2 * math.pi * i / n_a
            d = ref * math.cos(a) + side_v * math.sin(a)
            wave = .0025 * math.sin(a * 5 + 1.3) + .0015 * noise.noise(Vector((a * 3, 0, 0)))
            prof = []
            for j in range(n_p):
                t = 2 * math.pi * j / n_p
                ax = math.cos(t) * width / 2
                rad = math.sin(t) * thick / 2
                bulge = .6 + .4 * math.cos(t) ** 2
                p = center + fore * (ax - .002) + d * (radius + thick / 2 + rad * bulge + wave)
                prof.append(bm.verts.new(p))
            rings.append(prof)
        for i in range(n_a):
            a, b = rings[i], rings[(i + 1) % n_a]
            for j in range(n_p):
                bm.faces.new((a[j], a[(j + 1) % n_p], b[(j + 1) % n_p], b[j]))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        me = bpy.data.meshes.new(f'shirt_cuff_{side}')
        bm.to_mesh(me)
        bm.free()
        cuff = bpy.data.objects.new(f'shirt_cuff_{side}', me)
        collection.objects.link(cuff)
        me.materials.append(mat)
        for p in me.polygons:
            p.use_smooth = True
        out.append(cuff)
    return out


def collar_and_placket(obj, collection, mat, button_mat):
    """Shirt collar leaves at the open neck, the button placket and its buttons."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    neck = [v.co.copy() for v in bm.verts if v.is_boundary and v.co.z > 1.28]
    bm.free()
    out = []
    # collar points lying open over the vest collar at the front of the neck
    cbm = bmesh.new()
    for sgn in (1, -1):
        root = Vector((sgn * .038, -.07, 1.372))
        tip = Vector((sgn * .052, -.098, 1.318))
        back = Vector((sgn * .062, -.035, 1.392))
        mid_out = Vector((sgn * .066, -.075, 1.352))
        quad = [cbm.verts.new(p) for p in (root, back, mid_out, tip)]
        cbm.faces.new(quad if sgn > 0 else list(reversed(quad)))
    bmesh.ops.subdivide_edges(cbm, edges=cbm.edges[:], cuts=3, use_grid_fill=True)
    for v in cbm.verts:
        v.co.y -= .004 * math.sin(math.pi * min(1, max(0, (1.39 - v.co.z) / .07)))
    me = bpy.data.meshes.new('shirt_collar')
    cbm.to_mesh(me)
    cbm.free()
    collar = bpy.data.objects.new('shirt_collar', me)
    collection.objects.link(collar)
    me.materials.append(mat)
    G.solidify(collar, .0025)
    for p in me.polygons:
        p.use_smooth = True
    out.append(collar)
    # placket and buttons down the centre front
    tree = G.base_tree(obj)
    pbm = bmesh.new()
    bbm = bmesh.new()
    zs = [1.29 - i * .01 for i in range(34)]
    left, right = [], []
    for z in zs:
        hit = tree.ray_cast(Vector((0, -.4, z)), Vector((0, 1, 0)))
        if hit[0] is None:
            continue
        p, n = hit[0], hit[1]
        x = Vector((1, 0, 0))
        left.append(pbm.verts.new(p + n * .0018 - x * .016))
        right.append(pbm.verts.new(p + n * .0018 + x * .016))
    for i in range(len(left) - 1):
        pbm.faces.new((left[i], right[i], right[i + 1], left[i + 1]))
    bmesh.ops.recalc_face_normals(pbm, faces=pbm.faces[:])
    me = bpy.data.meshes.new('shirt_placket')
    pbm.to_mesh(me)
    pbm.free()
    placket = bpy.data.objects.new('shirt_placket', me)
    collection.objects.link(placket)
    me.materials.append(mat)
    G.solidify(placket, .0015)
    out.append(placket)
    for z in (1.265, 1.19, 1.115, 1.04, .965):
        hit = tree.ray_cast(Vector((0, -.4, z)), Vector((0, 1, 0)))
        if hit[0] is None:
            continue
        from mathutils import Matrix
        n = hit[1]
        m = Matrix.Translation(hit[0] + n * .004) @ n.to_track_quat('Z', 'Y').to_matrix().to_4x4()
        bmesh.ops.create_cone(bbm, cap_ends=True, segments=12, radius1=.0052, radius2=.0046, depth=.0022, matrix=m)
    me = bpy.data.meshes.new('shirt_buttons')
    bbm.to_mesh(me)
    bbm.free()
    buttons = bpy.data.objects.new('shirt_buttons', me)
    collection.objects.link(buttons)
    me.materials.append(button_mat)
    out.append(buttons)
    return out
