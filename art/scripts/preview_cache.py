"""Quick look at any cached stage while iterating (low samples, git-ignored output):

    blender -b --factory-startup -P art/scripts/preview_cache.py -- char_installer 09_details front,face [samples]

Views: front, back, torso, legs, face, feet. Renders go to art/source/cache/<name>/look/.
"""
import sys
from pathlib import Path
import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human import studio  # noqa: E402
from human.shading import ROOT  # noqa: E402

name, stage, views = sys.argv[sys.argv.index('--') + 1:][:3]
samples = int(sys.argv[-1]) if sys.argv[-1].isdigit() else 32
cache = ROOT / 'art/source/cache' / name
bpy.ops.wm.open_mainfile(filepath=str(cache / f'{stage}.blend'))
studio.use_gpu()
for o in bpy.data.objects:
    if o.name.endswith('collider'):
        o.hide_render = True
prev = bpy.data.collections['PREVIEW_ONLY']
VIEWS = {  # target, distance, yaw (-25 = her right-front), pitch, lens, resolution
    'front': ((0, 0, .87), 4.9, -25, 4, 50, (800, 1200)),
    'back': ((0, 0, .87), 4.9, 155, 4, 50, (800, 1200)),
    'torso': ((0, -.02, 1.18), 2.0, -25, 4, 50, (900, 900)),
    'legs': ((0, 0, .45), 2.6, 30, 8, 50, (800, 1000)),
    'face': ((-.01, -.05, 1.53), .95, -22, 3, 85, (900, 1000)),
    'feet': ((0, -.05, .07), 1.1, 35, 18, 50, (1000, 700)),
}
out = cache / 'look'
out.mkdir(exist_ok=True)
for view in views.split(','):
    target, dist, yaw, pitch, lens, res = VIEWS[view]
    studio.camera('look_cam', target, dist, yaw, pitch, lens=lens, res=res, collection=prev)
    studio.render(out / f'{stage}_{view}.png', samples=samples)
    print('RENDERED', out / f'{stage}_{view}.png', flush=True)
