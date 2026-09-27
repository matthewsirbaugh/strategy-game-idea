"""Layering fixes between garments, and removal of body skin that clothing fully covers."""
import bmesh
import bpy
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree


def evaluated_tree(objs):
    dg = bpy.context.evaluated_depsgraph_get()
    bm = bmesh.new()
    for o in objs:
        ev = o.evaluated_get(dg)
        me = ev.to_mesh()
        tmp = bmesh.new()
        tmp.from_mesh(me)
        tmp.transform(o.matrix_world)
        m = bpy.data.meshes.new('_tmp')
        tmp.to_mesh(m)
        tmp.free()
        bm.from_mesh(m)
        bpy.data.meshes.remove(m)
        ev.to_mesh_clear()
    tree = BVHTree.FromBMesh(bm)
    bm.free()
    return tree


def keep_inside(obj, container, margin, zmax):
    """Pull vertices of obj below zmax to at least margin inside container's surface."""
    tree = evaluated_tree([container])
    moved = 0
    for v in obj.data.vertices:
        if v.co.z > zmax:
            continue
        loc, n, _, _ = tree.find_nearest(v.co)
        if loc is None:
            continue
        if (v.co - loc).dot(n) > -margin:
            v.co = loc - n * margin
            moved += 1
    obj.data.update()
    return moved


def keep_outside(obj, others, margin):
    tree = evaluated_tree(others)
    moved = 0
    for v in obj.data.vertices:
        loc, n, _, _ = tree.find_nearest(v.co)
        if loc is None:
            continue
        if (v.co - loc).dot(n) < margin:
            v.co = loc + n * margin
            moved += 1
    obj.data.update()
    return moved


def hide_covered_skin(body, garments, reach=.06, keep=lambda co: False):
    """Delete body faces whose vertices all have clothing just outside them along the normal."""
    tree = evaluated_tree(garments)
    me = body.data
    covered = []
    for v in me.vertices:
        if keep(v.co):
            covered.append(False)
            continue
        hit = tree.ray_cast(v.co + v.normal * .0005, v.normal, reach)
        covered.append(hit[0] is not None)
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.verts.ensure_lookup_table()
    doomed = [f for f in bm.faces if all(covered[v.index] for v in f.verts)]
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    loose = [v for v in bm.verts if not v.link_faces]
    bmesh.ops.delete(bm, geom=loose, context='VERTS')
    bm.to_mesh(me)
    bm.free()
    return len(doomed)


class Surface:
    """A body mesh as triangles with smooth normals, for binding points to it by vertex index.
    Every MPFB body has the same vertex order, so a binding made on one body applies to another."""

    def __init__(self, body):
        me = body.data
        me.calc_loop_triangles()
        mw = body.matrix_world
        self.co = [mw @ v.co for v in me.vertices]
        self.nor = [(mw.to_3x3() @ v.normal).normalized() for v in me.vertices]
        self.tris = [tuple(t.vertices) for t in me.loop_triangles]
        self.tree = BVHTree.FromPolygons(self.co, self.tris)

    def frame(self, tri, w):
        a, b, c = (self.co[i] for i in tri)
        origin = a * w[0] + b * w[1] + c * w[2]
        n = sum((self.nor[i] * wi for i, wi in zip(tri, w)), Vector()).normalized()
        t = (b - a)
        t = (t - n * t.dot(n)).normalized()
        return origin, t, n.cross(t), n, ((b - a).cross(c - a)).length

    def bind(self, p):
        loc, _, index, _ = self.tree.find_nearest(p)
        tri = self.tris[index]
        a, b, c = (self.co[i] for i in tri)
        w = barycentric(loc, a, b, c)
        origin, t, bt, n, area = self.frame(tri, w)
        d = p - origin
        return tri, w, (d.dot(t), d.dot(bt), d.dot(n)), area

    def place(self, binding):
        tri, w, (dt, db, dn), area = binding
        origin, t, bt, n, new_area = self.frame(tri, w)
        s = max(.6, min(1.6, (new_area / area) ** .5)) if area > 0 else 1.0
        return origin + (t * dt + bt * db + n * dn) * s


def barycentric(p, a, b, c):
    v0, v1, v2 = b - a, c - a, p - a
    d00, d01, d11 = v0.dot(v0), v0.dot(v1), v1.dot(v1)
    d20, d21 = v2.dot(v0), v2.dot(v1)
    den = d00 * d11 - d01 * d01
    if abs(den) < 1e-14:
        return (1.0, 0.0, 0.0)
    v = (d11 * d20 - d01 * d21) / den
    w = (d00 * d21 - d01 * d20) / den
    return (1.0 - v - w, v, w)


def bone_matrix(rig, bone):
    b = rig.data.bones[bone]
    return rig.matrix_world @ b.matrix_local, b.length


def retarget(objs, source_body, target_body, rigid=(), on_bones=(), source_rig=None, target_rig=None):
    """Move garments and gear built on the reference mannequin onto another MPFB body.
    Cloth follows the new surface point by point. Each rigid group (a tuple of name prefixes) moves
    as one piece, keeping its shape, with the body at the group's centre. Each on_bones entry
    ((prefixes), bone) moves with that bone's rest transform, scaled by the bone's length (footwear)."""
    src, dst = Surface(source_body), Surface(target_body)
    for o in objs:
        if o.type == 'CURVE':
            with bpy.context.temp_override(selected_editable_objects=[o], active_object=o, object=o):
                bpy.ops.object.convert(target='MESH')
    objs = [o for o in objs if o.type == 'MESH']
    done = set()

    def move(o, fn):
        mw = o.matrix_world
        inv = mw.inverted()
        for v in o.data.vertices:
            v.co = inv @ fn(mw @ v.co)
        o.data.update()
        done.add(o)

    for prefixes, bone in on_bones:
        (m0, l0), (m1, l1) = bone_matrix(source_rig, bone), bone_matrix(target_rig, bone)
        xf = m1 @ Matrix.Scale(l1 / l0, 4) @ m0.inverted()
        for o in objs:
            if o not in done and o.name.startswith(prefixes):
                move(o, lambda p: xf @ p)
    for prefixes in rigid:
        group = [o for o in objs if o not in done and o.name.startswith(prefixes)]
        if not group:
            continue
        pts = [o.matrix_world @ v.co for o in group for v in o.data.vertices]
        center = sum(pts, Vector()) / len(pts)
        b = src.bind(center)
        new_center = dst.place(b)
        s = max(.6, min(1.6, (dst.frame(b[0], b[1])[4] / b[3]) ** .5)) if b[3] > 0 else 1.0
        for o in group:
            move(o, lambda p: new_center + (p - center) * s)
    for o in objs:
        if o not in done:
            move(o, lambda p: dst.place(src.bind(p)))
