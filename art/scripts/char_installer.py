"""Builds the Installer from the CC0 base: garments, gear, hair, materials, rig, previews and export.

    blender --background --factory-startup --python art/scripts/char_installer.py -- [--from STAGE] [--to STAGE]

Each stage saves art/source/cache/<n>_<stage>.blend, so a later stage can be rebuilt without
re-running the cloth simulations before it.
"""
import argparse
import sys
from pathlib import Path
import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
from installer import (body, trousers, shirt, vest, shoes, gear, head, accessories, backpack, gloves, details,  # noqa: E402
                       fit, rig as R, export as X,
                       materials as M, studio)

ROOT = Path(__file__).resolve().parents[2]
CACHE = ROOT / 'art/source/cache'


def char():
    return bpy.data.collections['char_installer']


def obj(name):
    return bpy.data.objects[name]


def mat(name):
    return bpy.data.materials[name]


LIBRARY = {
    'shirt': M.shirt, 'vest': M.vest, 'trousers': M.trousers, 'headband': M.headband, 'hair': M.hair,
    'hair_cap': M.hair_cap, 'glass': M.glass,
    'leather': lambda: M.leather('leather'),
    'leather_dark': lambda: M.leather('leather_dark', '#3E2616', '#1A0F08', '#6E4A32'),
    'leather_tan': lambda: M.leather('leather_tan', '#8A5530', '#3A200F', '#C08050', 'brown_leather', 9.0),
    'leather_belt': lambda: M.leather('leather_belt', '#5A3620', '#24140B', '#8C5E3E', 'brown_leather', 12.0),
    'webbing': lambda: M.webbing('webbing', '#2B2C2E', '#141415', '#505256'),
    'webbing_grey': lambda: M.webbing('webbing_grey', '#4A4A48', '#232322', '#77756F'),
    'webbing_khaki': lambda: M.webbing('webbing_khaki', '#8A7A5A', '#4A3F2C', '#B5A47E'),
    'lace': lambda: M.webbing('lace', '#2A2724', '#141210', '#4A433C', 80.0),
    'steel': lambda: M.metal('steel', '#8E9296', .34),
    'brass': lambda: M.metal('brass', '#9C7A3E', .38, '#D8B878'),
    'frame': lambda: M.metal('frame', '#5E6368', .3),
    'device': lambda: M.metal('device', '#8C9196', .4),
    'silver': lambda: M.metal('silver', '#C9CBCF', .22),
    'orange_metal': lambda: M.metal('orange_metal', '#B8612E', .4, '#E09060'),
    'orange': lambda: M.plastic('orange', '#BD5E2B', .6, '#5A2A14', '#E08A50'),
    'lens_dark': lambda: M.plastic('lens_dark', '#0E1216', .08),
    'rubber_grip': lambda: M.plastic('rubber_grip', '#1E1E1F', .75),
    'button': lambda: M.plastic('button', '#D8D0C0', .35, '#8A8070', '#FFFFFF', .3, .2),
    'rubber': M.rubber, 'suede': M.suede, 'mesh_fabric': M.mesh_fabric,
    'sock': lambda: M.fabric('sock', '#2A2A2C', '#141415', '#4A4A4C', 'cotton_jersey', 20.0),
    'pack_nylon': M.pack_materials,
    'glove_fabric': lambda: M.neoprene('glove_fabric'),
    'suede_pad': lambda: M.suede('suede_pad', '#9A7A42', '#4E3C1E', '#C9A86A'),
    'midsole': lambda: M.plastic('midsole', '#3C3A37', .8, '#1A1918', '#5C5853', .4, .2),
}


def ensure_materials():
    for name, make in LIBRARY.items():
        if name not in bpy.data.materials:
            make()


def stage_base():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    c = bpy.data.collections.new('char_installer')
    bpy.context.scene.collection.children.link(c)
    prev = bpy.data.collections.new('PREVIEW_ONLY')
    bpy.context.scene.collection.children.link(prev)
    parts = body.load_base(c)
    body.dress_body(parts)
    ensure_materials()
    studio.setup(prev)


def stage_trousers():
    t = trousers.shell(obj('Installer_CC0_base'), char())
    trousers.drape(t, obj('Installer_CC0_base'), char())
    t.data.materials.append(mat('trousers'))
    for p in t.data.polygons:
        p.use_smooth = True
    G_solid(t, .0022)


def G_solid(o, thickness):
    from installer import garments
    m = garments.solidify(o, thickness)
    m.offset = -1
    m.use_even_offset = False


def stage_shirt():
    s, frames = shirt.shell(obj('Installer_CC0_base'), obj('Installer_skeleton'), char())
    shirt.drape(s, frames, obj('Installer_CC0_base'), char())
    s.data.materials.append(mat('shirt'))
    for p in s.data.polygons:
        p.use_smooth = True
    shirt.roll_cuffs(s, frames, char(), mat('shirt'))
    shirt.collar_and_placket(s, char(), mat('shirt'), mat('button'))
    G_solid(s, .0018)


def stage_vest():
    v = vest.shell(obj('Installer_CC0_base'), char())
    v.data.materials.append(mat('vest'))
    for p in v.data.polygons:
        p.use_smooth = True
    col = vest.collar(v, char())
    col.data.materials.append(mat('vest'))
    for p in col.data.polygons:
        p.use_smooth = True
    vest.settle(v, obj('shirt'), obj('Installer_CC0_base'))
    for o in (v, col):
        m = __import__('installer.garments', fromlist=['x']).solidify(o, .0035)
        m.offset = -1


def stage_shoes():
    mats = {k: mat(k) for k in ('rubber', 'suede', 'lace', 'brass', 'orange', 'sock', 'midsole')}
    mats['shoe_mesh'] = mat('mesh_fabric')
    shoes.build(obj('Installer_CC0_base'), char(), mats)


def stage_gear():
    t = obj('trousers')
    mats = {m.name: m for m in bpy.data.materials}
    gear.belt(t, char(), mats)
    gear.belt_loops(t, char(), mat('trousers'))
    gear.hip_pouch(t, char(), mats)
    gear.carabiners(t, char(), mats)
    gear.thigh_rig(t, char(), mats)
    gear.tool_sheath(t, char(), mats)


def stage_head():
    b = obj('Installer_CC0_base')
    head.headband(b, char(), mat('headband'))
    cap = head.scalp_cap(b, char(), mat('hair_cap'))
    head.hair(b, cap, char(), mat('hair'))
    accessories.glasses(b, char(), mat('glass'), mat('frame'), mat('device'), mat('lens_dark'))
    accessories.earrings(b, char(), mat('silver'))


def stage_backpack():
    backpack.build(obj('vest'), char(), {m.name: m for m in bpy.data.materials})


def stage_gloves():
    gloves.build(obj('Installer_CC0_base'), obj('Installer_skeleton'), char(), {m.name: m for m in bpy.data.materials})


def stage_details():
    base = obj('Installer_CC0_base')
    base.data.materials[0] = body.skin_material()
    mats = {m.name: m for m in bpy.data.materials}
    details.vest_details(obj('vest'), char(), mats)
    details.trouser_details(obj('trousers'), char(), mats)
    details.shirt_details(obj('shirt'), char())


HEAD = ('headband', 'hair', 'glasses_', 'earring_')
SPINE = ('pack_', 'solar_', 'bottle', 'bot_')
PELVIS = ('hip_pouch', 'carabiner_', 'tool_sheath', 'tool_grip')
THIGH_R = ('thigh_holster', 'thigh_tool', 'thigh_drop_strap')


def binding(name):
    for prefixes, bone in ((HEAD, 'head'), (SPINE, 'spine_03'), (PELVIS, 'pelvis'), (THIGH_R, 'thigh_r')):
        if name.startswith(prefixes):
            return bone
    return None


def stage_rig():
    base = obj('Installer_CC0_base')
    skel = obj('Installer_skeleton')
    fit.keep_inside(obj('shirt'), obj('trousers'), .003, .958)
    source = base.copy()
    source.data = base.data.copy()
    source.name = 'weights_source'
    char().objects.link(source)
    bones = {b.name for b in skel.data.bones}
    parts = [o for o in char().objects if o.type in {'MESH', 'CURVE'} and o.parent is None
             and o.name not in {'Installer_CC0_base', 'weights_source'} and not o.name.endswith('collider')]
    for o in parts:
        if o.type == 'CURVE':
            with bpy.context.temp_override(selected_editable_objects=[o], active_object=o, object=o):
                bpy.ops.object.convert(target='MESH')
        bone = binding(o.name)
        if bone:
            R.bind_rigid(o, bone)
        else:
            R.transfer_weights(source, o)
            R.clean_groups(o, bones)
        R.attach(o, skel)
    covered = [obj(n) for n in ('trousers', 'shirt', 'vest', 'socks', 'hair_cap', 'shoe_l', 'shoe_r')]
    covered += [o for o in char().objects if o.name.startswith(('glove_l', 'glove_r'))]
    removed = fit.hide_covered_skin(base, covered, reach=.035)
    print('hidden skin faces', removed)
    bpy.data.objects.remove(source, do_unlink=True)
    R.relaxed_pose(skel)


SPECIAL = {'Installer_CC0_base', 'Installer_eyes', 'Installer_eyebrows', 'Installer_eyelashes', 'hair',
           'glasses_lenses', 'glasses_pads', 'bot_lens'}
CLOTH = ('shirt', 'trousers', 'vest', 'socks', 'headband', 'hair_cap', 'knee_patch', 'sleeve_patch', 'cargo_',
         'back_pocket', 'belt_loops')
GEAR_IN_CLOTH_NAMES = ('shirt_buttons', 'vest_snaps', 'cargo_snap')
RATIOS = (('shirt', .08), ('trousers', .12), ('vest_collar', .3), ('vest', .12), ('socks', .3), ('hair_cap', .3),
          ('hair', .08), ('headband_knot', .3), ('headband', .25), ('shoe_collar', .4), ('shoe_tongue', .5),
          ('shoe_', .05), ('glove_l', .12), ('glove_r', .12), ('Installer_CC0_base', .45), ('Installer_eyes', .5),
          ('belt', .5), ('tool_belt', .5), ('sole_', .6), ('bot_arm', .5), ('shoulder_strap', .6))


def ratio_for(o):
    for prefix, r in RATIOS:
        if o.name.startswith(prefix):
            return r
    tris = sum(len(p.vertices) - 2 for p in o.data.polygons)
    return .5 if tris > 1500 else 1.0


def stage_export():
    skel = obj('Installer_skeleton')
    for pb in skel.pose.bones:
        pb.matrix_basis.identity()
    bpy.context.view_layer.update()
    for o in list(bpy.data.objects):
        if o.name == 'Backdrop' or o.name.endswith('collider'):
            bpy.data.objects.remove(o, do_unlink=True)
    parts = [o for o in char().objects if o.type == 'MESH']
    before = X.tri_count(parts)
    eyes = obj('Installer_eyes')
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(eyes.data)
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if f.material_index == 1], context='FACES')
    bm.to_mesh(eyes.data)
    bm.free()
    for o in parts:
        X.prepare(o, ratio_for(o))
    decals = [obj(n) for n in ('vest_emblem', 'knee_patch', 'sleeve_patch')]
    X.assign(decals, X.decal_atlas(decals, 'char_installer_decals'), keep_uv='UVMap')
    cloth = [o for o in parts if o.name.startswith(CLOTH) and not o.name.startswith(GEAR_IN_CLOTH_NAMES)
             and o.name not in SPECIAL and o not in decals]
    gear_objs = [o for o in parts if o not in cloth and o.name not in SPECIAL and o not in decals]
    size = 2048
    for group, objs in (('cloth', cloth), ('gear', gear_objs)):
        X.unwrap_atlas(objs)
        col, nor, orm = X.bake_group(objs, f'char_installer_{group}', size, samples=24)
        X.assign(objs, X.baked_material(f'installer_{group}', col, nor, orm))
    body_obj = obj('Installer_CC0_base')
    body_obj.data.uv_layers['UVMap'].active = True
    skin_img = bpy.data.images.new('char_installer_skin_color', size, size, alpha=False)
    m = body_obj.data.materials[0]
    tex = m.node_tree.nodes.new('ShaderNodeTexImage')
    tex.image = skin_img
    m.node_tree.nodes.active = tex
    X.select_only([body_obj])
    bpy.context.scene.cycles.samples = 8
    bpy.ops.object.bake(type='DIFFUSE', pass_filter={'COLOR'})
    X.save_png(skin_img, 'char_installer_skin_color')
    skin = X.Graph('installer_skin')
    t = skin.image(skin_img.filepath_raw, 'sRGB')
    skin.set(**{'Base Color': t.outputs['Color'], 'Roughness': .5})
    X.assign([body_obj], skin.mat, keep_uv='UVMap')
    from installer.shading import srgb, VENDOR
    mh = VENDOR / 'makehuman'
    X.assign([eyes], X.textured_material('installer_eyes', mh / 'eye_brown.png'), keep_uv='UVMap')
    X.assign([obj('Installer_eyebrows')], X.textured_material('installer_brows', mh / 'eyebrow008.png', True,
                                                            srgb('#1A120E')), keep_uv='UVMap')
    X.assign([obj('Installer_eyelashes')], X.textured_material('installer_lashes', mh / 'eyelashes01.png', True,
                                                             srgb('#0E0B0A')), keep_uv='UVMap')
    X.assign([obj('hair')], X.flat_material('installer_hair', srgb('#2A1B12'), .5), keep_uv='UVMap')
    glass_objs = [obj('glasses_lenses'), obj('glasses_pads')]
    X.assign(glass_objs, X.flat_material('glass', (.92, .96, 1, 1), .05, 0, .18), keep_uv='UVMap')
    X.assign([obj('bot_lens')], X.flat_material('status_heart', srgb('#2EC6C2'), .2, 0, 1, srgb('#2EC6C2'), 6.0),
             keep_uv='UVMap')
    for o in parts:
        for vg in list(o.vertex_groups):
            if vg.name not in skel.data.bones:
                o.vertex_groups.remove(vg)
        for ca in list(o.data.color_attributes):
            o.data.color_attributes.remove(ca)
    mesh = X.join(parts, 'char_installer_mesh')
    after = X.tri_count([mesh])
    print('TRIS', before, '->', after, 'materials', [m.name for m in mesh.data.materials])
    root = ROOT / 'game/art/characters/char_installer.glb'
    X.select_only([skel, mesh], skel)
    bpy.ops.export_scene.gltf(filepath=str(root), export_format='GLB', use_selection=True, export_apply=True,
                              export_yup=True, export_skins=True, export_animations=False, export_extras=False,
                              export_cameras=False, export_lights=False, export_image_format='AUTO')
    print('EXPORTED', root)


def stage_previews():
    from installer import previews
    previews.render_all()


STAGES = [('base', stage_base), ('trousers', stage_trousers), ('shirt', stage_shirt), ('vest', stage_vest),
          ('shoes', stage_shoes), ('gear', stage_gear), ('head', stage_head), ('backpack', stage_backpack),
          ('gloves', stage_gloves), ('details', stage_details), ('rig', stage_rig),
          ('previews', stage_previews), ('export', stage_export)]


def main():
    argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    ap = argparse.ArgumentParser()
    names = [n for n, _ in STAGES]
    ap.add_argument('--from', dest='start', default=names[0], choices=names)
    ap.add_argument('--to', dest='end', default=names[-1], choices=names)
    args = ap.parse_args(argv)
    CACHE.mkdir(parents=True, exist_ok=True)
    i0, i1 = names.index(args.start), names.index(args.end)
    if i0 > 0:
        bpy.ops.wm.open_mainfile(filepath=str(CACHE / f'{i0 - 1:02d}_{names[i0 - 1]}.blend'))
    for i in range(i0, i1 + 1):
        name, fn = STAGES[i]
        print(f'STAGE {name}', flush=True)
        if i > 0:
            ensure_materials()
        fn()
        bpy.ops.wm.save_as_mainfile(filepath=str(CACHE / f'{i:02d}_{name}.blend'))
        print(f'STAGE_DONE {name}', flush=True)


main()
