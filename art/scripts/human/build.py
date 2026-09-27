"""Stage runner for human characters. A character is a spec module (see char_installer.py) with:

    NAME, BASE, LOOK, PALETTE, STAGES, BONES, RIGID, ON_BONES, COVER, TUCK, EXPORT, CONCEPT

Its garment and gear stages build on the reference mannequin (the Installer's body), because every
builder is tuned to it. If BASE is a different body, the 'retarget' stage moves the finished outfit
onto it. Each stage is cached in art/source/cache/<NAME>/NN_stage.blend.

    blender --background --factory-startup --python art/scripts/<spec>.py -- [--from STAGE] [--to STAGE]
"""
import argparse
import sys
from pathlib import Path
import bmesh
import bpy
from . import body, fit, rig as R, export as X, materials as M, studio, previews
from .shading import ROOT, VENDOR, srgb

REFERENCE = VENDOR / 'installer_base.blend'


class Context:
    def __init__(self, spec):
        self.spec = spec

    @property
    def col(self):
        return bpy.data.collections['character']

    @property
    def body(self):
        return bpy.data.objects['body']

    @property
    def rig(self):
        return bpy.data.objects['skeleton']

    def obj(self, name):
        return bpy.data.objects[name]

    def mat(self, name):
        return bpy.data.materials[name]

    @property
    def mats(self):
        return {m.name: m for m in bpy.data.materials}

    def objects(self, *prefixes):
        return [o for o in self.col.objects if o.name.startswith(prefixes)]


def retargeting(spec):
    return (ROOT / spec.BASE).resolve() != REFERENCE.resolve()


def ensure_materials(spec):
    library = dict(M.DEFAULTS)
    library.update(spec.PALETTE)
    for name, make in library.items():
        if name not in bpy.data.materials:
            make()


def look_of(spec):
    look = dict(body.LOOK)
    look.update(spec.LOOK)
    return look


def stage_base(ctx):
    spec = ctx.spec
    bpy.ops.wm.read_factory_settings(use_empty=True)
    char = bpy.data.collections.new('character')
    bpy.context.scene.collection.children.link(char)
    prev = bpy.data.collections.new('PREVIEW_ONLY')
    bpy.context.scene.collection.children.link(prev)
    parts = body.load_base(char, REFERENCE)
    body.dress_body(parts, body.LOOK if retargeting(spec) else look_of(spec))
    ensure_materials(spec)
    studio.setup(prev)


def stage_retarget(ctx):
    """Load the character's own body, move the outfit from the mannequin onto it, drop the mannequin.
    Needs only the scene after the last outfit stage, so a cached outfit can go onto many bodies."""
    target = bpy.data.collections.new('TARGET')
    bpy.context.scene.collection.children.link(target)
    parts = body.load_base(target, ROOT / ctx.spec.BASE, prefix='target_')
    body.dress_body(parts, look_of(ctx.spec))
    reference = {name: bpy.data.objects[name] for name in body.PARTS}
    outfit = [o for o in ctx.col.objects if o.type in {'MESH', 'CURVE'} and o.name not in body.PARTS]
    fit.retarget(outfit, reference['body'], parts['body'], ctx.spec.RIGID, ctx.spec.ON_BONES,
                 reference['skeleton'], parts['skeleton'])
    for o in reference.values():
        bpy.data.objects.remove(o, do_unlink=True)
    for name, o in parts.items():
        target.objects.unlink(o)
        ctx.col.objects.link(o)
        o.name = name
    bpy.data.collections.remove(target)


def bone_for(spec, name):
    for prefixes, bone in spec.BONES:
        if name.startswith(prefixes):
            return bone
    return None


def stage_rig(ctx):
    spec = ctx.spec
    for inner, outer, margin, zmax in spec.TUCK:
        fit.keep_inside(ctx.obj(inner), ctx.obj(outer), margin, zmax)
    source = ctx.body.copy()
    source.data = ctx.body.data.copy()
    source.name = 'weights_source'
    ctx.col.objects.link(source)
    bones = {b.name for b in ctx.rig.data.bones}
    parts = [o for o in ctx.col.objects if o.type in {'MESH', 'CURVE'} and o.parent is None
             and o.name not in {'body', 'weights_source'} and not o.name.endswith('collider')]
    for o in parts:
        if o.type == 'CURVE':
            with bpy.context.temp_override(selected_editable_objects=[o], active_object=o, object=o):
                bpy.ops.object.convert(target='MESH')
        bone = bone_for(spec, o.name)
        if bone:
            R.bind_rigid(o, bone)
        else:
            R.transfer_weights(source, o)
            R.clean_groups(o, bones)
        R.attach(o, ctx.rig)
    bpy.data.objects.remove(source, do_unlink=True)
    covered = ctx.objects(*spec.COVER)
    print('hidden skin faces', fit.hide_covered_skin(ctx.body, covered, reach=.035))
    R.relaxed_pose(ctx.rig)


def stage_previews(ctx):
    concept = ctx.spec.CONCEPT
    previews.render_all(ctx.spec.NAME, ROOT / concept if concept else None)


def stage_export(ctx):
    spec, ex = ctx.spec, ctx.spec.EXPORT
    for pb in ctx.rig.pose.bones:
        pb.matrix_basis.identity()
    bpy.context.view_layer.update()
    for o in list(bpy.data.objects):
        if o.name == 'Backdrop' or o.name.endswith('collider'):
            bpy.data.objects.remove(o, do_unlink=True)
    parts = [o for o in ctx.col.objects if o.type == 'MESH']
    before = X.tri_count(parts)
    eyes = ctx.obj('eyes')
    bm = bmesh.new()
    bm.from_mesh(eyes.data)
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if f.material_index == 1], context='FACES')
    bm.to_mesh(eyes.data)
    bm.free()

    def ratio(o):
        for prefix, r in ex['ratios']:
            if o.name.startswith(prefix):
                return r
        return .5 if sum(len(p.vertices) - 2 for p in o.data.polygons) > 1500 else 1.0
    for o in parts:
        X.prepare(o, ratio(o))
    special = set(ex['special']) | {'body', 'eyes', 'eyebrows', 'eyelashes'}
    decals = [o for o in parts if o.name in ex['decals']]
    if decals:
        X.assign(decals, X.decal_atlas(decals, f'{spec.NAME}_decals'), keep_uv='UVMap')
    cloth = [o for o in parts if o.name.startswith(ex['cloth']) and not o.name.startswith(ex['gear_in_cloth'])
             and o.name not in special and o not in decals]
    gear = [o for o in parts if o not in cloth and o.name not in special and o not in decals]
    size = ex.get('size', 2048)
    for group, objs in (('cloth', cloth), ('gear', gear)):
        X.unwrap_atlas(objs)
        col, nor, orm = X.bake_group(objs, f'{spec.NAME}_{group}', size, samples=24)
        X.assign(objs, X.baked_material(f'{spec.NAME}_{group}', col, nor, orm))
    b = ctx.body
    b.data.uv_layers['UVMap'].active = True
    skin_img = bpy.data.images.new(f'{spec.NAME}_skin_color', size, size, alpha=False)
    m = b.data.materials[0]
    tex = m.node_tree.nodes.new('ShaderNodeTexImage')
    tex.image = skin_img
    m.node_tree.nodes.active = tex
    X.select_only([b])
    bpy.context.scene.cycles.samples = 8
    bpy.ops.object.bake(type='DIFFUSE', pass_filter={'COLOR'})
    X.save_png(skin_img, f'{spec.NAME}_skin_color')
    skin = X.Graph(f'{spec.NAME}_skin')
    t = skin.image(skin_img.filepath_raw, 'sRGB')
    skin.set(**{'Base Color': t.outputs['Color'], 'Roughness': .5})
    X.assign([b], skin.mat, keep_uv='UVMap')
    look = look_of(spec)
    mh = VENDOR / 'makehuman'
    X.assign([eyes], X.textured_material(f'{spec.NAME}_eyes', mh / look['eyes']), keep_uv='UVMap')
    X.assign([ctx.obj('eyebrows')], X.textured_material(f'{spec.NAME}_brows', mh / look['brows'], True,
                                                       srgb(look['brow_color'])), keep_uv='UVMap')
    X.assign([ctx.obj('eyelashes')], X.textured_material(f'{spec.NAME}_lashes', mh / look['lashes'], True,
                                                        srgb(look['lash_color'])), keep_uv='UVMap')
    for name, color in ex.get('flat', {}).items():
        X.assign([ctx.obj(name)], X.flat_material(f'{spec.NAME}_{name}', srgb(color), .5), keep_uv='UVMap')
    X.assign(ctx.objects(*ex['glass']), X.flat_material('glass', (.92, .96, 1, 1), .05, 0, .18), keep_uv='UVMap')
    for name, color in ex.get('heart', {}).items():
        X.assign([ctx.obj(name)], X.flat_material('status_heart', srgb(color), .2, 0, 1, srgb(color), 6.0),
                 keep_uv='UVMap')
    for o in parts:
        for vg in list(o.vertex_groups):
            if vg.name not in ctx.rig.data.bones:
                o.vertex_groups.remove(vg)
        for ca in list(o.data.color_attributes):
            o.data.color_attributes.remove(ca)
    mesh = X.join(parts, f'{spec.NAME}_mesh')
    print('TRIS', before, '->', X.tri_count([mesh]), 'materials', [m.name for m in mesh.data.materials])
    out = ROOT / f'game/art/characters/{spec.NAME}.glb'
    X.select_only([ctx.rig, mesh], ctx.rig)
    bpy.ops.export_scene.gltf(filepath=str(out), export_format='GLB', use_selection=True, export_apply=True,
                              export_yup=True, export_skins=True, export_animations=False, export_extras=False,
                              export_cameras=False, export_lights=False, export_image_format='AUTO')
    print('EXPORTED', out)


def stages(spec):
    out = [('base', stage_base)] + list(spec.STAGES)
    if retargeting(spec):
        out.append(('retarget', stage_retarget))
    return out + [('rig', stage_rig), ('previews', stage_previews), ('export', stage_export)]


def run(spec):
    argv = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    all_stages = stages(spec)
    names = [n for n, _ in all_stages]
    ap = argparse.ArgumentParser()
    ap.add_argument('--from', dest='start', default=names[0], choices=names)
    ap.add_argument('--to', dest='end', default=names[-1], choices=names)
    args = ap.parse_args(argv)
    cache = ROOT / 'art/source/cache' / spec.NAME
    cache.mkdir(parents=True, exist_ok=True)
    ctx = Context(spec)
    i0, i1 = names.index(args.start), names.index(args.end)
    if i0 > 0:
        bpy.ops.wm.open_mainfile(filepath=str(cache / f'{i0 - 1:02d}_{names[i0 - 1]}.blend'))
    for i in range(i0, i1 + 1):
        name, fn = all_stages[i]
        print(f'STAGE {name}', flush=True)
        if i > 0:
            ensure_materials(spec)
        fn(ctx)
        bpy.ops.wm.save_as_mainfile(filepath=str(cache / f'{i:02d}_{name}.blend'))
        print(f'STAGE_DONE {name}', flush=True)
    if names[i1] in ('previews', 'export', 'rig'):
        # the rigged, posed scene is the asset's source file
        src = cache / f'{names.index("previews"):02d}_previews.blend'
        if src.exists():
            import shutil
            shutil.copyfile(src, ROOT / f'art/source/{spec.NAME}.blend')
