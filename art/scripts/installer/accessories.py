"""Hard-surface accessories on the head: safety glasses with a temple camera module, earrings."""
import math
import bmesh
import bpy
from mathutils import Vector, Matrix


def head_landmarks(body):
    vs = [v.co for v in body.data.vertices]
    head = [c for c in vs if c.z > 1.40]
    nose = min((c for c in head if abs(c.x) < .01 and 1.48 < c.z < 1.53), key=lambda c: c.y)
    bridge = min((c for c in head if abs(c.x) < .006 and 1.535 < c.z < 1.55), key=lambda c: c.y)
    ear_l = max((c for c in head if 1.50 < c.z < 1.55 and -.03 < c.y < .02), key=lambda c: c.x)
    return {'nose': nose, 'bridge': bridge, 'ear_l': ear_l, 'ear_r': Vector((-ear_l.x, ear_l.y, ear_l.z))}


def rounded_rect(w, h, r, seg=4):
    pts = []
    for cx, cy, a0 in ((w / 2 - r, h / 2 - r, 0), (-w / 2 + r, h / 2 - r, 90),
                       (-w / 2 + r, -h / 2 + r, 180), (w / 2 - r, -h / 2 + r, 270)):
        for i in range(seg + 1):
            a = math.radians(a0 + 90 * i / seg)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def mesh_obj(name, bm, collection, mat=None, smooth=True):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    collection.objects.link(obj)
    if mat:
        me.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = smooth
    return obj


def bend(co, center_y, radius):
    """Wrap x around a vertical cylinder so flat parts curve with the face."""
    a = co.x / radius
    return Vector((radius * math.sin(a), center_y - radius * math.cos(a) + (co.y - center_y + radius), co.z))


def glasses(body, collection, lens_mat, frame_mat, device_mat, lens_dark_mat):
    lm = head_landmarks(body)
    eye_z = lm['bridge'].z - .004
    front_y = lm['bridge'].y - .016
    radius = .115
    objs = []
    # lenses
    bm = bmesh.new()
    for side in (1, -1):
        outline = rounded_rect(.054, .033, .008, 5)
        cx = side * .033
        top = [bm.verts.new((cx + x, front_y, eye_z + y)) for x, y in outline]
        face = bm.faces.new(top)
    ext = bmesh.ops.extrude_face_region(bm, geom=bm.faces[:])
    for v in [e for e in ext['geom'] if isinstance(e, bmesh.types.BMVert)]:
        v.co.y += .0014
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for v in bm.verts:
        v.co = bend(v.co, front_y + radius, radius)
    objs.append(mesh_obj('glasses_lenses', bm, collection, lens_mat))
    # top rims and bridge as one swept bar
    bar = bpy.data.curves.new('glasses_bar', 'CURVE')
    bar.dimensions = '3D'
    bar.bevel_depth = .0021
    bar.bevel_resolution = 2
    for side in (1, -1):
        sp = bar.splines.new('POLY')
        pts = [(side * (.033 + x), front_y - .0012, eye_z + .0162 - (abs(x) > .02) * .004 * (abs(x) - .02) / .006)
               for x in [i / 10 * .054 - .027 for i in range(11)]]
        sp.points.add(len(pts) - 1)
        for p, co in zip(sp.points, pts):
            p.co = (*bend(Vector(co), front_y + radius, radius), 1)
    sp = bar.splines.new('BEZIER')
    sp.bezier_points.add(1)
    for bp, co in zip(sp.bezier_points, ((.008, front_y - .0012, eye_z + .0155), (-.008, front_y - .0012, eye_z + .0155))):
        bp.co = bend(Vector(co), front_y + radius, radius)
        bp.handle_left_type = bp.handle_right_type = 'AUTO'
    sp.bezier_points[0].co.z += .0
    barobj = bpy.data.objects.new('glasses_bar', bar)
    collection.objects.link(barobj)
    bar.materials.append(frame_mat)
    objs.append(barobj)
    # nose pads
    bm = bmesh.new()
    for side in (1, -1):
        m = Matrix.Translation(Vector((side * .0085, lm['bridge'].y - .004, eye_z - .012)))
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=.0035, matrix=m @ Matrix.Diagonal((.55, 1, 1.2, 1)))
    objs.append(mesh_obj('glasses_pads', bm, collection, lens_mat))
    # temples: from the outer lens corner back over the ear, dipping behind it
    for side, tag in ((1, 'l'), (-1, 'r')):
        ear = lm['ear_' + tag]
        start = bend(Vector((side * .0605, front_y + .001, eye_z + .012)), front_y + radius, radius)
        c = bpy.data.curves.new(f'temple_{tag}', 'CURVE')
        c.dimensions = '3D'
        c.bevel_depth = .0022
        c.bevel_resolution = 2
        sp = c.splines.new('BEZIER')
        pts = [start, Vector((ear.x + side * .004, start.y + .06, eye_z + .010)),
               Vector((ear.x + side * .002, ear.y + .012, ear.z + .006)), Vector((ear.x - side * .004, ear.y + .026, ear.z - .018))]
        sp.bezier_points.add(len(pts) - 1)
        for bp, co in zip(sp.bezier_points, pts):
            bp.co = co
            bp.handle_left_type = bp.handle_right_type = 'AUTO'
        o = bpy.data.objects.new(f'glasses_temple_{tag}', c)
        collection.objects.link(o)
        c.materials.append(frame_mat)
        objs.append(o)
    # camera module on her right temple (-X side), just behind the hinge
    ear = lm['ear_r']
    hinge = bend(Vector((-.0605, front_y + .001, eye_z + .012)), front_y + radius, radius)
    bm = bmesh.new()
    box = Matrix.Translation(hinge + Vector((-.006, .018, -.001))) @ Matrix.Diagonal((.0085, .030, .012, 1))
    bmesh.ops.create_cube(bm, size=1.0, matrix=box)
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=.0018, segments=3, affect='EDGES')
    objs.append(mesh_obj('glasses_device', bm, collection, device_mat))
    bm = bmesh.new()
    lens_at = hinge + Vector((-.0108, .008, -.001))
    m = Matrix.Translation(lens_at) @ Matrix.Rotation(math.radians(90), 4, 'Y')
    bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=.0034, radius2=.0028, depth=.002, matrix=m)
    objs.append(mesh_obj('glasses_device_lens', bm, collection, lens_dark_mat))
    return objs


def earrings(body, collection, metal):
    lm = head_landmarks(body)
    objs = []
    for tag in ('l', 'r'):
        ear = lm['ear_' + tag]
        side = 1 if tag == 'l' else -1
        lobe = Vector((ear.x - side * .004, ear.y - .006, ear.z - .026))
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=.0022, matrix=Matrix.Translation(lobe))
        bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=.0006, radius2=.0006, depth=.014,
                              matrix=Matrix.Translation(lobe + Vector((0, 0, -.009))))
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=.0016,
                                  matrix=Matrix.Translation(lobe + Vector((0, 0, -.017))))
        objs.append(mesh_obj(f'earring_{tag}', bm, collection, metal))
    return objs
