"""Garments grown from the body surface, then draped with Blender's cloth solver."""
import math
import bmesh
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree


def extract(body, name, keep_face, collection):
    """Copy the body faces for which keep_face(center, normal) is true into a new object."""
    bm = bmesh.new()
    bm.from_mesh(body.data)
    doomed = [f for f in bm.faces if not keep_face(f.calc_center_median(), f.normal)]
    bmesh.ops.delete(bm, geom=doomed, context='FACES')
    loose = [v for v in bm.verts if not v.link_faces]
    bmesh.ops.delete(bm, geom=loose, context='VERTS')
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    collection.objects.link(obj)
    for vg in body.vertex_groups:
        obj.vertex_groups.new(name=vg.name)
    return obj


def largest_part(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.verts.ensure_lookup_table()
    seen, parts = set(), []
    for v in bm.verts:
        if v.index in seen:
            continue
        stack, part = [v], []
        while stack:
            x = stack.pop()
            if x.index in seen:
                continue
            seen.add(x.index)
            part.append(x)
            stack.extend(e.other_vert(x) for e in x.link_edges)
        parts.append(part)
    parts.sort(key=len, reverse=True)
    for part in parts[1:]:
        bmesh.ops.delete(bm, geom=part, context='VERTS')
    bm.to_mesh(obj.data)
    bm.free()


def subdivide(obj, levels=1, smooth=True):
    mod = obj.modifiers.new('subdiv', 'SUBSURF')
    mod.levels = levels
    mod.subdivision_type = 'CATMULL_CLARK' if smooth else 'SIMPLE'
    mod.boundary_smooth = 'PRESERVE_CORNERS'
    apply_modifiers(obj)


def apply_modifiers(obj):
    ctx = bpy.context
    for o in ctx.selected_objects:
        o.select_set(False)
    ctx.view_layer.objects.active = obj
    obj.select_set(True)
    for mod in list(obj.modifiers):
        if mod.type != 'ARMATURE':
            bpy.ops.object.modifier_apply(modifier=mod.name)


def offset(obj, amount):
    """Push every vertex out along its normal by amount(co) metres."""
    me = obj.data
    # Normals are recomputed after any write, so read them all before moving anything.
    normals = [v.normal.copy() for v in me.vertices]
    for v, n in zip(me.vertices, normals):
        v.co += n * amount(v.co)
    me.update()


def relax(obj, iterations, factor, weight=None):
    """Laplacian smoothing, optionally weighted per vertex by weight(co) in 0..1."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    for _ in range(iterations):
        moves = []
        for v in bm.verts:
            if v.is_boundary or not v.link_edges:
                continue
            w = factor * (weight(v.co) if weight else 1.0)
            if w <= 0:
                continue
            avg = sum((e.other_vert(v).co for e in v.link_edges), Vector()) / len(v.link_edges)
            moves.append((v, v.co.lerp(avg, w)))
        for v, co in moves:
            v.co = co
    bm.to_mesh(obj.data)
    bm.free()


def group(obj, name, weight):
    """Create or refill a vertex group from weight(co) in 0..1."""
    vg = obj.vertex_groups.get(name) or obj.vertex_groups.new(name=name)
    for v in obj.data.vertices:
        w = weight(v.co)
        if w > 0:
            vg.add([v.index], min(1.0, w), 'REPLACE')
        else:
            vg.remove([v.index])
    return vg


def smoothstep(e0, e1, x):
    t = max(0.0, min(1.0, (x - e0) / (e1 - e0)))
    return t * t * (3 - 2 * t)


def collider(body, collection, thickness=.004):
    mod = body.modifiers.get('Collision') or body.modifiers.new('Collision', 'COLLISION')
    body.collision.thickness_outer = thickness
    body.collision.thickness_inner = .01
    body.collision.cloth_friction = 8
    body.collision.damping = .5
    return mod


def drape(obj, frames, pin=None, shrink=None, shrink_min=0.0, shrink_max=0.0, mass=.2, tension=15, bending=.5,
          compression=None, shear=None, self_collide=False, quality=8, pressure=0.0, before=None):
    """Run the cloth solver on obj for frames and bake the last frame into the mesh.
    before(frame) may animate pinned targets (shape keys) between frames."""
    scene = bpy.context.scene
    mod = obj.modifiers.new('cloth', 'CLOTH')
    s = mod.settings
    s.quality = quality
    s.mass = mass
    s.tension_stiffness = tension
    s.compression_stiffness = compression if compression is not None else tension
    s.shear_stiffness = shear if shear is not None else tension * .5
    s.bending_stiffness = bending
    s.air_damping = 1.0
    s.shrink_min = shrink_min
    if shrink:
        s.vertex_group_shrink = shrink
        s.shrink_max = shrink_max
    if pin:
        s.vertex_group_mass = pin
        s.pin_stiffness = 1.0
    if pressure:
        s.use_pressure = True
        s.uniform_pressure_force = pressure
    c = mod.collision_settings
    c.distance_min = .003
    c.collision_quality = 4
    c.use_self_collision = self_collide
    c.self_distance_min = .003
    mod.point_cache.frame_start = 1
    mod.point_cache.frame_end = frames
    scene.frame_start, scene.frame_end = 1, frames
    for f in range(1, frames + 1):
        if before:
            before(f)
        scene.frame_set(f)
    dg = bpy.context.evaluated_depsgraph_get()
    ev = obj.evaluated_get(dg)
    coords = [v.co.copy() for v in ev.data.vertices]
    obj.modifiers.remove(mod)
    if obj.data.shape_keys:
        obj.shape_key_clear()
    for v, co in zip(obj.data.vertices, coords):
        v.co = co
    obj.data.update()
    scene.frame_set(1)


def solidify(obj, thickness, rim=True):
    mod = obj.modifiers.new('solidify', 'SOLIDIFY')
    mod.thickness = thickness
    mod.offset = 1.0
    # even thickness spikes at the odd degenerate vertex left by draping
    mod.use_even_offset = False
    mod.use_rim = rim
    mod.use_quality_normals = True
    return mod


def push_outside(obj, target, distance, max_move=.025):
    """Move vertices of obj that are inside (or closer than distance to) target's base surface outward.
    Uses the unmodified mesh so solidify shells can't flip the test, and skips implausible moves."""
    bm = bmesh.new()
    bm.from_mesh(target.data)
    bm.transform(target.matrix_world)
    tree = BVHTree.FromBMesh(bm)
    bm.free()
    me = obj.data
    for v in me.vertices:
        loc, normal, _, dist = tree.find_nearest(v.co)
        if loc is None:
            continue
        d = (v.co - loc).dot(normal)
        if d < distance and distance - d < max_move:
            v.co = loc + normal * distance
    me.update()


def smooth_boundary(obj, iterations=10, factor=.5, where=lambda co: True):
    """Straighten jagged cut edges by relaxing boundary vertices along their boundary neighbours."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    nbrs = {}
    for e in bm.edges:
        if e.is_boundary:
            a, b = e.verts
            nbrs.setdefault(a, []).append(b)
            nbrs.setdefault(b, []).append(a)
    for _ in range(iterations):
        moves = []
        for v, ns in nbrs.items():
            if len(ns) == 2 and where(v.co):
                moves.append((v, v.co.lerp((ns[0].co + ns[1].co) / 2, factor)))
        for v, co in moves:
            v.co = co
    # let the rows just inside the edge follow so the border doesn't pucker
    inner = {e.other_vert(v) for v in nbrs for e in v.link_edges} - set(nbrs)
    for _ in range(3):
        moves = []
        for v in inner:
            avg = sum((e.other_vert(v).co for e in v.link_edges), Vector()) / len(v.link_edges)
            moves.append((v, v.co.lerp(avg, .5)))
        for v, co in moves:
            v.co = co
    bm.to_mesh(obj.data)
    bm.free()


def base_tree(obj):
    """BVH of the unmodified mesh in world space: solidify shells would put nearest hits on the inside."""
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.transform(obj.matrix_world)
    tree = BVHTree.FromBMesh(bm)
    bm.free()
    return tree


def dress(obj, mat, thickness):
    """Assign the garment material, smooth shading and inward thickness."""
    obj.data.materials.append(mat)
    for p in obj.data.polygons:
        p.use_smooth = True
    mod = solidify(obj, thickness)
    mod.offset = -1
    return obj
