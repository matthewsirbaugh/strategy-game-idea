"""Layering fixes between garments, and removal of body skin that clothing fully covers."""
import bmesh
import bpy
from mathutils import Vector
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
