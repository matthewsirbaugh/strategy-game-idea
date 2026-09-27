"""Game export: decimate, unwrap into shared atlases, bake the procedural materials, write the GLB."""
import numpy as np
import bpy
from mathutils import Vector
from .shading import Graph, ROOT

GAME_TEX = ROOT / 'game/art/characters'


def select_only(objs, active=None):
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = active or objs[0]


def prepare(obj, ratio):
    """Drop thickness (the game draws cloth double-sided), decimate, and apply everything but the rig."""
    for m in list(obj.modifiers):
        if m.type == 'SOLIDIFY':
            obj.modifiers.remove(m)
    if ratio < 1.0 and len(obj.data.polygons) > 200:
        d = obj.modifiers.new('decimate', 'DECIMATE')
        d.ratio = ratio
        d.use_collapse_triangulate = True
    select_only([obj])
    for m in list(obj.modifiers):
        if m.type not in {'ARMATURE'}:
            with bpy.context.temp_override(object=obj, active_object=obj):
                bpy.ops.object.modifier_move_to_index(modifier=m.name, index=0)
                bpy.ops.object.modifier_apply(modifier=m.name)


def unwrap_atlas(objs, margin=.003):
    for o in objs:
        uvs = o.data.uv_layers
        atlas = uvs.get('atlas') or uvs.new(name='atlas')
        uvs.active = atlas
    select_only(objs)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=margin, area_weight=1.0, correct_aspect=True)
    bpy.ops.uv.select_all(action='SELECT')
    bpy.ops.uv.average_islands_scale()
    bpy.ops.uv.pack_islands(margin=margin, rotate=True)
    bpy.ops.object.mode_set(mode='OBJECT')


def bake_group(objs, name, size, samples=16):
    """Bake base colour, normal, roughness and metallic of every material on objs into one atlas."""
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = samples
    scene.render.bake.margin = 8
    scene.render.bake.use_selected_to_active = False
    images = {}
    for key, cs in (('color', 'sRGB'), ('normal', 'Non-Color'), ('rough', 'Non-Color'), ('metal', 'Non-Color')):
        img = bpy.data.images.new(f'{name}_{key}', size, size, alpha=False, float_buffer=False)
        img.colorspace_settings.name = cs
        images[key] = img
    mats = {m for o in objs for m in o.data.materials if m}
    nodes = {}
    for m in mats:
        tex = m.node_tree.nodes.new('ShaderNodeTexImage')
        m.node_tree.nodes.active = tex
        nodes[m] = tex
    select_only(objs)

    def bake(kind, img, **kw):
        for tex in nodes.values():
            tex.image = img
        bpy.ops.object.bake(type=kind, **kw)
    bake('DIFFUSE', images['color'], pass_filter={'COLOR'})
    bake('NORMAL', images['normal'], normal_space='TANGENT')
    bake('ROUGHNESS', images['rough'])
    # metallic via emission: route each material's metallic input to its output for one bake
    saved = {}
    for m in mats:
        nt = m.node_tree
        bsdf = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
        out = next((n for n in nt.nodes if n.type == 'OUTPUT_MATERIAL' and n.is_active_output), None)
        if not bsdf or not out:
            continue
        emit = nt.nodes.new('ShaderNodeEmission')
        mi = bsdf.inputs['Metallic']
        if mi.is_linked:
            nt.links.new(mi.links[0].from_socket, emit.inputs['Color'])
        else:
            v = mi.default_value
            emit.inputs['Color'].default_value = (v, v, v, 1)
        old = out.inputs['Surface'].links[0].from_socket if out.inputs['Surface'].is_linked else None
        nt.links.new(emit.outputs['Emission'], out.inputs['Surface'])
        saved[m] = (emit, old, out)
    bake('EMIT', images['metal'])
    for m, (emit, old, out) in saved.items():
        if old:
            m.node_tree.links.new(old, out.inputs['Surface'])
        m.node_tree.nodes.remove(emit)
    for m, tex in nodes.items():
        m.node_tree.nodes.remove(tex)
    # pack roughness (G) and metallic (B) the way glTF expects
    r = np.array(images['rough'].pixels[:]).reshape(size, size, 4)
    mt = np.array(images['metal'].pixels[:]).reshape(size, size, 4)
    orm = np.ones_like(r)
    orm[..., 1] = r[..., 0]
    orm[..., 2] = mt[..., 0]
    packed = bpy.data.images.new(f'{name}_orm', size, size, alpha=False)
    packed.colorspace_settings.name = 'Non-Color'
    packed.pixels[:] = orm.ravel()
    for key in ('color', 'normal'):
        save_png(images[key], f'{name}_{key}')
    save_png(packed, f'{name}_orm')
    return images['color'], images['normal'], packed


def save_png(img, stem):
    path = ROOT / 'art/source/baked' / f'{stem}.png'
    path.parent.mkdir(parents=True, exist_ok=True)
    img.filepath_raw = str(path)
    img.file_format = 'PNG'
    img.save()


def baked_material(name, color, normal, orm, double_sided=True):
    """Image-only Principled material the glTF exporter maps 1:1 (single UV set after assign)."""
    g = Graph(name)
    c = g.image(color.filepath_raw, 'sRGB')
    n = g.image(normal.filepath_raw, 'Non-Color')
    o = g.image(orm.filepath_raw, 'Non-Color')
    sep = g.node('ShaderNodeSeparateColor', Color=o.outputs['Color'])
    nm = g.node('ShaderNodeNormalMap', Color=n.outputs['Color'])
    g.set(**{'Base Color': c.outputs['Color'], 'Roughness': sep.outputs['Green'], 'Metallic': sep.outputs['Blue'],
             'Normal': nm.outputs['Normal']})
    g.mat.use_backface_culling = not double_sided
    return g.mat


def flat_material(name, color, rough=.5, metal=0.0, alpha=1.0, emission=None, strength=0.0):
    g = Graph(name)
    g.set(**{'Base Color': color, 'Roughness': rough, 'Metallic': metal, 'Alpha': alpha})
    if emission:
        g.set(**{'Emission Color': emission, 'Emission Strength': strength})
    if alpha < 1.0:
        g.mat.surface_render_method = 'BLENDED'
    return g.mat


def textured_material(name, path, alpha=False, tint=None):
    g = Graph(name)
    t = g.image(path, 'sRGB')
    col = t.outputs['Color']
    if tint:
        col = g.mix(col, tint, 1.0, 'MULTIPLY')
    g.set(**{'Base Color': col, 'Roughness': .5})
    if alpha:
        g.set(**{'Alpha': t.outputs['Alpha']})
        g.mat.surface_render_method = 'BLENDED'
    return g.mat


def assign(objs, mat, keep_uv='atlas'):
    for o in objs:
        o.data.materials.clear()
        o.data.materials.append(mat)
        uvs = o.data.uv_layers
        for uv in list(uvs):
            if uv.name != keep_uv:
                uvs.remove(uv)
        if keep_uv in uvs:
            uvs[keep_uv].name = 'UVMap'
            uvs['UVMap'].active = True
            uvs['UVMap'].active_render = True


def join(objs, name):
    select_only(objs)
    bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = name
    return obj


def tri_count(objs):
    return sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in objs if o.type == 'MESH')


def decal_atlas(objs, name):
    """Put each decal's own image side by side in one strip and remap its UVs into its slot."""
    images = []
    for o in objs:
        img = next(n.image for n in o.data.materials[0].node_tree.nodes if n.type == 'TEX_IMAGE' and n.image)
        w, h = img.size
        a = np.array(img.pixels[:], dtype=np.float32).reshape(h, w, 4)
        size = 512
        ys = (np.arange(size) * h / size).astype(int)
        xs = (np.arange(size) * w / size).astype(int)
        images.append(a[ys][:, xs])
    strip = np.concatenate(images, axis=1)
    out = bpy.data.images.new(name, strip.shape[1], strip.shape[0], alpha=True)
    out.pixels[:] = strip.ravel()
    save_png(out, name)
    n = len(objs)
    for i, o in enumerate(objs):
        uv = o.data.uv_layers['UVMap'].data
        for loop in uv:
            loop.uv = ((loop.uv.x + i) / n, loop.uv.y)
    g = Graph(name)
    t = g.image(out.filepath_raw, 'sRGB')
    # alpha test keeps the decals out of transparency sorting in the game
    g.set(**{'Base Color': t.outputs['Color'], 'Roughness': .85,
             'Alpha': g.math('GREATER_THAN', t.outputs['Alpha'], .5)})
    g.mat.surface_render_method = 'DITHERED'
    return g.mat
