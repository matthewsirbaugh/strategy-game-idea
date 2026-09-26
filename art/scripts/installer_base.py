"""Regenerates art/vendor/installer_base.blend: the CC0 MakeHuman body, game skeleton, eyes,
eyebrows and eyelashes. Only needed when the base itself changes; the character build reads the
committed .blend.

    MPFB_SOURCE=<mpfb2 checkout @ 7fcc8df> MH_ASSETS=<makehuman_system_assets_cc0> \
        blender --background --python art/scripts/installer_base.py
"""
import os
import sys
import json
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
MPFB = Path(os.environ['MPFB_SOURCE'])
ASSETS = Path(os.environ['MH_ASSETS'])
HEIGHT = 1.653

sys.path.insert(0, str(MPFB / 'src'))
bpy.utils.extension_path_user = lambda *args, **kwargs: '/private/tmp/strategy-mpfb-user'
import mpfb
bpy.context.preferences.addons.new().module = 'mpfb'
mpfb.register()
from mpfb.services.humanservice import HumanService
from mpfb.services.targetservice import TargetService

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

macro = TargetService.get_default_macro_info_dict()
macro.update(gender=0.0, age=.5, muscle=.62, weight=.36, proportions=.62, cupsize=.34, firmness=.6)
macro['race'] = {'african': .5, 'asian': .12, 'caucasian': .38}
body = HumanService.create_human(scale=.1, feet_on_ground=True, macro_detail_dict=macro)
body.name = 'Installer_CC0_base'

# Likeness to the direction C concept: oval face, high cheekbones, fuller lips, finer nose.
FACE = {
    'head/head-oval': .45,
    'cheek/l-cheek-bones-incr': .45, 'cheek/r-cheek-bones-incr': .45,
    'cheek/l-cheek-volume-decr': .2, 'cheek/r-cheek-volume-decr': .2,
    'mouth/mouth-lowerlip-volume-incr': .15, 'mouth/mouth-upperlip-volume-incr': .55,
    'mouth/mouth-upperlip-height-incr': .35, 'mouth/mouth-cupidsbow-incr': .35, 'mouth/mouth-angles-up': .12,
    'mouth/mouth-lowerlip-ext-up': .2,
    'nose/nose-point-width-decr': .3, 'nose/nose-nostrils-width-decr': .2, 'nose/nose-scale-horiz-decr': .12,
    'chin/chin-width-decr': .25, 'chin/chin-prominent-incr': .15,
    'eyebrows/eyebrows-angle-up': .2,
    'neck/neck-scale-horiz-decr': .15,
    # a relaxed, slightly amused resting expression
    'expression/units/african/mouth-corner-puller': .2, 'expression/units/caucasian/mouth-corner-puller': .12,
    'expression/units/african/eye-left-slit': .1, 'expression/units/african/eye-right-slit': .1,
}
targets = MPFB / 'src/mpfb/data/targets'
for name, weight in FACE.items():
    TargetService.load_target(body, str(targets / f'{name}.target.gz'), weight=weight)

rig = HumanService.add_builtin_rig(body, 'game_engine')
rig.name = 'Installer_skeleton'

proxies = []
for kind, path in (('Eyes', 'eyes/high-poly/high-poly.mhclo'),
                   ('Eyebrows', 'eyebrows/eyebrow008/eyebrow008.mhclo'),
                   ('Eyelashes', 'eyelashes/eyelashes01/eyelashes01.mhclo')):
    obj = HumanService.add_mhclo_asset(str(ASSETS / path), body, asset_type=kind, subdiv_levels=0)
    obj.name = f'Installer_{kind.lower()}'
    proxies.append(obj)

bpy.context.view_layer.objects.active = body
body.select_set(True)
TargetService.bake_targets(body)
anchors = {}
for name in ['joint-l-eye', 'joint-r-eye', 'joint-mouth', 'joint-head', 'joint-neck']:
    g = body.vertex_groups[name]
    vertices = [v.co for v in body.data.vertices if any(w.group == g.index for w in v.groups)]
    anchors[name] = sum(vertices, Vector()) / len(vertices)
for mod in list(body.modifiers):
    if mod.type != 'ARMATURE':
        bpy.ops.object.modifier_apply(modifier=mod.name)
for obj in proxies:
    bpy.context.view_layer.objects.active = obj
    for mod in list(obj.modifiers):
        if mod.type != 'ARMATURE':
            bpy.ops.object.modifier_apply(modifier=mod.name)

height = max((body.matrix_world @ v.co).z for v in body.data.vertices)
factor = HEIGHT / height
# Objects are unscaled here; scale their data together so the bind space stays consistent.
for obj in [body] + proxies:
    for v in obj.data.vertices:
        v.co *= factor
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode='EDIT')
for bone in rig.data.edit_bones:
    bone.head *= factor
    bone.tail *= factor
bpy.ops.object.mode_set(mode='OBJECT')

body['provenance'] = 'MakeHuman Community MPFB2 7fcc8df56f26776923e0a825f4551c3c3779befe; CC0 assets'
body['macro_parameters'] = json.dumps(macro)
body['face_targets'] = json.dumps(FACE)
body['anchors'] = json.dumps({name: list(co * factor) for name, co in anchors.items()})
for m in list(bpy.data.materials):
    if m.users == 0:
        bpy.data.materials.remove(m)
out = Path(os.environ.get('BASE_OUT', ROOT / 'art/vendor/installer_base.blend'))
bpy.ops.wm.save_as_mainfile(filepath=str(out))
print('BASE_COMPLETE', len(body.data.vertices), [o.name for o in proxies], height, factor)
