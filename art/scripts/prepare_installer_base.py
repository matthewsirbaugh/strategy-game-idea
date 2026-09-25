"""Optional source regeneration: MPFB_SOURCE must point to the pinned MPFB checkout.
The normal character build uses the committed CC0 base and needs no installed add-on.
"""
import os
import sys
import json
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
source = Path(os.environ.get('MPFB_SOURCE', '/private/tmp/strategy-art-mpfb2'))
sys.path.insert(0,str(source/'src'))
bpy.utils.extension_path_user = lambda *args, **kwargs: '/private/tmp/strategy-mpfb-user'
import mpfb
bpy.context.preferences.addons.new().module='mpfb'
mpfb.register()
from mpfb.services.humanservice import HumanService
from mpfb.services.targetservice import TargetService

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
macro=TargetService.get_default_macro_info_dict()
macro.update(gender=0.0,age=.52,muscle=.64,weight=.38,proportions=.55,cupsize=.28,firmness=.6)
macro['race']={'african':.55,'asian':.10,'caucasian':.35}
body=HumanService.create_human(scale=.1,feet_on_ground=True,macro_detail_dict=macro)
body.name='Installer_CC0_base'
rig=HumanService.add_builtin_rig(body,'game_engine')
rig.name='Installer_skeleton'
bpy.context.view_layer.objects.active=body
body.select_set(True)
bpy.ops.object.shape_key_remove(all=True,apply_mix=True)
anchors={}
for name in ['joint-l-eye','joint-r-eye','joint-mouth','joint-head','joint-neck']:
    g=body.vertex_groups[name]
    vertices=[v.co for v in body.data.vertices if any(w.group==g.index for w in v.groups)]
    anchors[name]=sum(vertices,Vector())/len(vertices)
for mod in list(body.modifiers):
    if mod.type != 'ARMATURE':
        bpy.ops.object.modifier_apply(modifier=mod.name)
height=max((body.matrix_world@v.co).z for v in body.data.vertices)
factor=1.653/height
for o in [body,rig]:
    # MPFB objects are unscaled at this point; scale their data together to keep bind space.
    for v in o.data.vertices if o.type=='MESH' else []:
        v.co*=factor
if rig.type=='ARMATURE':
    bpy.context.view_layer.objects.active=rig
    bpy.ops.object.mode_set(mode='EDIT')
    for bone in rig.data.edit_bones:
        bone.head*=factor
        bone.tail*=factor
    bpy.ops.object.mode_set(mode='OBJECT')
body['provenance']='MakeHuman Community MPFB2 7fcc8df56f26776923e0a825f4551c3c3779befe; CC0 assets'
body['macro_parameters']=str(macro)
body['anchors']=json.dumps({name:list(co*factor) for name,co in anchors.items()})
(ROOT/'art/vendor').mkdir(exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/vendor/installer_base.blend'))
print('BASE_COMPLETE',len(body.data.vertices),height,factor)
