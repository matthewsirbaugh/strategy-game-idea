"""Review renders: hero three-quarter, back, face, tactics camera sheet and a side-by-side with the concept."""
import math
import numpy as np
import bpy
from mathutils import Vector
from . import studio
from .shading import Graph, ROOT, srgb

OUT = ROOT / 'art/previews'
CONCEPT = ROOT / 'art/concepts/installer-2026-09-26/direction-c-turnaround.png'


def to_array(path):
    img = bpy.data.images.load(str(path), check_existing=False)
    w, h = img.size
    a = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)[::-1]
    bpy.data.images.remove(img)
    return a


def save_jpg(arr, name):
    h, w = arr.shape[:2]
    img = bpy.data.images.new(name, w, h, alpha=False)
    img.pixels[:] = np.ascontiguousarray(arr[::-1]).ravel()
    img.filepath_raw = str(OUT / f'{name}.jpg')
    img.file_format = 'JPEG'
    bpy.context.scene.render.image_settings.quality = 90
    img.save()
    bpy.data.images.remove(img)


def render_to(name, tmp):
    path = tmp / f'{name}.png'
    studio.render(path)
    return to_array(path)


def fit_height(a, h):
    """Nearest-neighbour resize to height h (keeps pixels crisp for the tactics crop)."""
    sh, sw = a.shape[:2]
    w = max(1, round(sw * h / sh))
    ys = (np.arange(h) * sh / h).astype(int)
    xs = (np.arange(w) * sw / w).astype(int)
    return a[ys][:, xs]


def smooth_height(a, h):
    sh, sw = a.shape[:2]
    w = max(1, round(sw * h / sh))
    ys = np.linspace(0, sh - 1, h)
    xs = np.linspace(0, sw - 1, w)
    y0, x0 = np.floor(ys).astype(int), np.floor(xs).astype(int)
    y1, x1 = np.minimum(y0 + 1, sh - 1), np.minimum(x0 + 1, sw - 1)
    fy, fx = (ys - y0)[:, None, None], (xs - x0)[None, :, None]
    top = a[y0][:, x0] * (1 - fx) + a[y0][:, x1] * fx
    bot = a[y1][:, x0] * (1 - fx) + a[y1][:, x1] * fx
    return top * (1 - fy) + bot * fy


def reference_capsule(collection, x):
    g = Graph('reference_capsule')
    g.set(**{'Base Color': srgb('#A6B2B5'), 'Roughness': .85})
    bpy.ops.mesh.primitive_cylinder_add(radius=.16, depth=1.38, location=(x, 0, .85))
    parts = [bpy.context.object]
    for z in (1.54, .16):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=.16, location=(x, 0, z))
        parts.append(bpy.context.object)
    for p in parts:
        for c in list(p.users_collection):
            c.objects.unlink(p)
        collection.objects.link(p)
        p.data.materials.append(g.mat)
    return parts


def render_all(samples=128):
    import tempfile
    from pathlib import Path
    tmp = Path(tempfile.mkdtemp())
    OUT.mkdir(parents=True, exist_ok=True)
    scene = bpy.context.scene
    prev = bpy.data.collections['PREVIEW_ONLY']
    scene.cycles.samples = samples
    for o in bpy.data.objects:
        if o.name.endswith('collider'):
            o.hide_render = True
    studio.camera('review_cam', (0, 0, .87), 4.9, -25, 4, lens=50, res=(1024, 1536), collection=prev)
    front = render_to('front', tmp)
    save_jpg(front, 'char_installer_front')
    studio.camera('review_cam', (0, 0, .87), 4.9, 155, 4, lens=50, res=(1024, 1536), collection=prev)
    back = render_to('back', tmp)
    save_jpg(back, 'char_installer_back')
    studio.camera('review_cam', (-.01, -.05, 1.53), .95, -22, 3, lens=85, res=(1024, 1152), collection=prev)
    save_jpg(render_to('detail', tmp), 'char_installer_detail')
    # tactics camera: default zoom at 34 m and the closest zoom at 12 m, next to a 1.7 m reference
    cap = reference_capsule(prev, .75)
    backdrop = bpy.data.objects.get('Backdrop')
    if backdrop:
        backdrop.hide_render = True
    g = Graph('tactics_floor')
    g.set(**{'Base Color': srgb('#6B6F68'), 'Roughness': .9})
    bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, -.002))
    floor = bpy.context.object
    for c in list(floor.users_collection):
        c.objects.unlink(floor)
    prev.objects.link(floor)
    floor.data.materials.append(g.mat)
    shots = []
    for dist in (34.0, 12.0):
        cam = studio.camera('tactics_cam', (.3, 0, .8), dist, 45, 50, lens=50, res=(1600, 900), collection=prev)
        cam.data.sensor_fit = 'VERTICAL'
        cam.data.angle_y = math.radians(30)
        shots.append(render_to(f'tactics_{int(dist)}', tmp))
    far, near = shots
    cy, cx = 450, 800
    far_crop = far[cy - 75:cy + 75, cx - 100:cx + 100]
    near_crop = near[cy - 225:cy + 225, cx - 300:cx + 300]
    left = fit_height(far_crop, 450)
    right = smooth_height(near_crop, 450)
    save_jpg(np.concatenate([left, right], axis=1), 'char_installer_game')
    for o in cap + [floor]:
        bpy.data.objects.remove(o, do_unlink=True)
    if backdrop:
        backdrop.hide_render = False
    # side by side with the concept sheet
    if CONCEPT.exists():
        concept = to_array(CONCEPT)
        h = 1100
        row = [smooth_height(concept, h), smooth_height(front, h), smooth_height(back, h)]
        save_jpg(np.concatenate(row, axis=1), 'char_installer_compare')
