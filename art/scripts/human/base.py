"""MPFB body generation: the CC0 MakeHuman body, game skeleton, eyes, brows and lashes, from a
character's BODY spec. Run through art/scripts/make_base.py; needs the sources from fetch_sources.py."""
import json
import shutil
import sys
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[3]
SOURCES = ROOT / 'art/vendor/_sources'
VENDOR_MH = ROOT / 'art/vendor/makehuman'
PARTS = ('body', 'skeleton', 'eyes', 'eyebrows', 'eyelashes')


def _register_mpfb():
    sys.path.insert(0, str(SOURCES / 'mpfb2/src'))
    bpy.utils.extension_path_user = lambda *args, **kwargs: '/private/tmp/strategy-mpfb-user'
    import mpfb
    bpy.context.preferences.addons.new().module = 'mpfb'
    mpfb.register()


def vendor_textures(spec):
    """Copy the skin, eye, brow and lash images the spec uses into art/vendor/makehuman/."""
    VENDOR_MH.mkdir(parents=True, exist_ok=True)
    system = SOURCES / 'makehuman_system_assets_cc0'
    copies = {
        f"eye_{spec['eyes']}.png": system / f"eyes/materials/{spec['eyes']}_eye.png",
        f"{spec['brows']}.png": system / f"eyebrows/{spec['brows']}/{spec['brows']}.png",
        f"{spec['lashes']}.png": system / f"eyelashes/{spec['lashes']}/{spec['lashes']}.png",
        spec['skin'][1]: SOURCES / spec['skin'][0],
    }
    for name, src in copies.items():
        shutil.copyfile(src, VENDOR_MH / name)


def generate(spec, out):
    """spec: macros (MPFB macro dict incl. race), face (target path -> weight), eyes, brows, lashes,
    skin (source path under _sources, vendored file name), height (metres, barefoot)."""
    _register_mpfb()
    from mpfb.services.humanservice import HumanService
    from mpfb.services.targetservice import TargetService

    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    macro = TargetService.get_default_macro_info_dict()
    macro.update({k: v for k, v in spec['macros'].items() if k != 'race'})
    macro['race'] = dict(spec['macros']['race'])
    body = HumanService.create_human(scale=.1, feet_on_ground=True, macro_detail_dict=macro)
    targets = SOURCES / 'mpfb2/src/mpfb/data/targets'
    for name, weight in spec['face'].items():
        TargetService.load_target(body, str(targets / f'{name}.target.gz'), weight=weight)
    rig = HumanService.add_builtin_rig(body, 'game_engine')
    system = SOURCES / 'makehuman_system_assets_cc0'
    proxies = {}
    # Proxies must be fitted while MakeHuman's helper geometry still exists: their fitting data
    # points at helper vertices. The helper mask is applied afterwards.
    for kind, path in (('eyes', 'eyes/high-poly/high-poly.mhclo'),
                       ('eyebrows', f"eyebrows/{spec['brows']}/{spec['brows']}.mhclo"),
                       ('eyelashes', f"eyelashes/{spec['lashes']}/{spec['lashes']}.mhclo")):
        proxies[kind] = HumanService.add_mhclo_asset(str(system / path), body, asset_type=kind.capitalize(),
                                                     subdiv_levels=0)
    bpy.context.view_layer.objects.active = body
    body.select_set(True)
    TargetService.bake_targets(body)
    anchors = {}
    for name in ['joint-l-eye', 'joint-r-eye', 'joint-mouth', 'joint-head', 'joint-neck']:
        g = body.vertex_groups[name]
        vertices = [v.co for v in body.data.vertices if any(w.group == g.index for w in v.groups)]
        anchors[name] = sum(vertices, Vector()) / len(vertices)
    for obj in [body] + list(proxies.values()):
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            if mod.type != 'ARMATURE':
                bpy.ops.object.modifier_apply(modifier=mod.name)
    height = max((body.matrix_world @ v.co).z for v in body.data.vertices)
    factor = spec['height'] / height
    # Objects are unscaled here; scale their data together so the bind space stays consistent.
    for obj in [body] + list(proxies.values()):
        for v in obj.data.vertices:
            v.co *= factor
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    for bone in rig.data.edit_bones:
        bone.head *= factor
        bone.tail *= factor
    bpy.ops.object.mode_set(mode='OBJECT')
    for name, obj in (('body', body), ('skeleton', rig), *proxies.items()):
        obj.name = name
        obj.data.name = name
    body['provenance'] = 'MakeHuman Community MPFB2 7fcc8df56f26776923e0a825f4551c3c3779befe; CC0 assets'
    body['body_spec'] = json.dumps(spec)
    body['anchors'] = json.dumps({name: list(co * factor) for name, co in anchors.items()})
    for m in list(bpy.data.materials):
        if m.users == 0:
            bpy.data.materials.remove(m)
    vendor_textures(spec)
    bpy.ops.wm.save_as_mainfile(filepath=str(out))
    print('BASE_COMPLETE', out, len(body.data.vertices), height, factor)
