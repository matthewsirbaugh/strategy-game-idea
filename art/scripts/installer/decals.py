"""Painted and sewn details: generated images laid onto the garments as conforming patches."""
import math
import numpy as np
import bmesh
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree
from .shading import Graph, ROOT, srgb

OUT = ROOT / 'art/textures'


def _save(name, rgba):
    h, w = rgba.shape[:2]
    img = bpy.data.images.get(name) or bpy.data.images.new(name, w, h, alpha=True)
    img.scale(w, h)
    img.pixels[:] = rgba[::-1].astype(np.float32).ravel()
    OUT.mkdir(parents=True, exist_ok=True)
    img.filepath_raw = str(OUT / f'{name}.png')
    img.file_format = 'PNG'
    img.save()
    return img


def leaf_emblem(size=512):
    """A cream sprig of seven leaves on a curved stem, like the concept's vest emblem."""
    yy, xx = np.mgrid[0:size, 0:size] / size
    alpha = np.zeros((size, size))

    def stem(t):
        return .5 + .08 * math.sin(t * 2.2 - .6), .94 - .86 * t

    for t in np.linspace(0, 1, 400):
        sx, sy = stem(t)
        alpha = np.maximum(alpha, np.clip(1 - np.hypot(xx - sx, yy - sy) / (.012 * (1.2 - .6 * t)), 0, 1))
    leaves = [(.2, -1, .19), (.3, 1, .2), (.42, -1, .19), (.53, 1, .18), (.64, -1, .16), (.75, 1, .14), (.98, 0, .13)]
    for t, side, length in leaves:
        bx, by = stem(t)
        if side:
            a = math.radians(50)
            dx, dy = side * math.sin(a), -math.cos(a)
        else:
            dx, dy = .12, -1.0
        n = math.hypot(dx, dy)
        dx, dy = dx / n, dy / n
        cx, cy = bx + dx * length * .5, by + dy * length * .5
        u = (xx - cx) * dx + (yy - cy) * dy
        v = -(xx - cx) * dy + (yy - cy) * dx
        half = length / 2
        # lanceolate leaf: pointed at both ends, widest a little below the middle
        s_ = np.clip((u / half + 1) / 2, 0, 1)
        width = .036 * length / .2 * np.sin(np.pi * s_ ** .85) ** 1.1
        inside = np.clip((width - np.abs(v)) / .003, 0, 1) * (np.abs(u) < half)
        vein = np.clip(1 - np.abs(v) / .0022, 0, 1) * (np.abs(u) < half * .8) * .4
        alpha = np.maximum(alpha, inside * (1 - vein))
    rough = np.random.default_rng(3).random((size, size))
    alpha = np.clip(alpha * (0.88 + .12 * rough), 0, 1)
    rgba = np.zeros((size, size, 4))
    rgba[..., 0], rgba[..., 1], rgba[..., 2] = .80, .76, .66
    rgba[..., 3] = alpha
    return _save('installer_leaf_emblem', rgba)


def stitched_patch(name, base, stitch, size=256, darn=False):
    """Square fabric patch with a running stitch round the edge (and darning lines if darn)."""
    yy, xx = np.mgrid[0:size, 0:size] / size
    rng = np.random.default_rng(len(name))
    noise = rng.random((size, size))
    col = np.ones((size, size, 4))
    for i in range(3):
        col[..., i] = base[i] * (.85 + .3 * noise)
    edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
    along = np.where(np.minimum(xx, 1 - xx) < np.minimum(yy, 1 - yy), yy, xx)
    dash = (np.sin(along * 2 * math.pi * 14) > .1)
    ring = (np.abs(edge - .07) < .012) & dash
    marks = ring.copy()
    if darn:
        rows = (np.abs(((yy * 6) % 1) - .5) < .06) & (xx > .1) & (xx < .9)
        marks |= rows
    for i in range(3):
        col[..., i] = np.where(marks, stitch[i], col[..., i])
    col[..., 3] = np.clip(edge / .012, 0, 1)
    return _save(name, col)


def decal_material(name, image, rough=.8, normal_strength=.0):
    g = Graph(name)
    tex = g.image(image.filepath_raw, 'sRGB')
    g.set(**{'Base Color': tex.outputs['Color'], 'Alpha': tex.outputs['Alpha'], 'Roughness': rough})
    g.mat.surface_render_method = 'DITHERED'
    return g.mat


def patch_on(surface, name, center, up, width, height, collection, mat, lift=.0015, res=12):
    """A grid patch projected onto surface around center, oriented by up, with 0..1 UVs."""
    from .garments import base_tree
    tree = base_tree(surface)
    loc, n, _, _ = tree.find_nearest(Vector(center))
    up = Vector(up)
    side = up.cross(n).normalized()
    up = n.cross(side).normalized()
    bm = bmesh.new()
    uv = bm.loops.layers.uv.new('UVMap')
    grid = []
    for j in range(res + 1):
        row = []
        for i in range(res + 1):
            p = loc + side * (i / res - .5) * width + up * (j / res - .5) * height
            hit, hn, _, _ = tree.find_nearest(p)
            row.append((bm.verts.new(hit + hn * lift), (i / res, j / res)))
        grid.append(row)
    for j in range(res):
        for i in range(res):
            quad = (grid[j][i], grid[j][i + 1], grid[j + 1][i + 1], grid[j + 1][i])
            f = bm.faces.new([q[0] for q in quad])
            for loop, q in zip(f.loops, quad):
                loop[uv].uv = q[1]
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        if f.normal.dot(n) < 0:
            f.normal_flip()
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    collection.objects.link(obj)
    me.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = True
    return obj
