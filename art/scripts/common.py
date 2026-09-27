"""Shared metre-scale geometry, palette, stylized bake, export and review renders. Run with Blender."""
from pathlib import Path
import json
import math
import random
import struct
import tempfile
import bmesh
import bpy
import numpy as np
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
PALETTE = {
    'cream': '#EFE6D2', 'ochre': '#D9A441', 'terra': '#C8643C',
    'brick': '#A4553A', 'timber': '#9A6B43', 'sage': '#7FA37A',
    'moss': '#4F7A4A', 'teal': '#3E8C84', 'webbing': '#2F5F5C',
    'white': '#F2F1EC', 'concrete': '#D9D6CE', 'graphite': '#2B2E33',
    'glass': '#1A2230', 'solar': '#2A3570', 'gold': '#D9B24A',
    'cyan': '#27D3F5', 'magenta': '#E83FB8', 'green': '#58F08A',
    'offline': '#4A4F57', 'warm': '#FFC27A', 'steel': '#9DA5A6',
    'soil': '#3D3930', 'leaf_light': '#A9BF7D', 'amber': '#E8A94A',
}
# Materials the game recolors or shades itself keep their flat values and are never baked.
SPECIAL = ('status_ring', 'status_heart', 'emissive_', 'hologram_', 'glass', 'ad_screen')
# How each kind of surface ages in the bake. var/part: broad and per-part value jitter; ao: crevice
# darkening; edge: worn highlight on convex edges; grime: dirt near the floor and in crevices.
LOOKS = {
    'clean':    dict(var=.035, part=.03, ao=.45, edge=.10, grime=.06, speck=0,   grain=0,   strata=0,   rough_var=.10, bump=.02),
    'concrete': dict(var=.07,  part=.04, ao=.55, edge=.16, grime=.22, speck=.35, grain=0,   strata=0,   rough_var=.15, bump=.20),
    'metal':    dict(var=.05,  part=.05, ao=.50, edge=.30, grime=.12, speck=0,   grain=.12, strata=0,   rough_var=.18, bump=.04),
    'wood':     dict(var=.08,  part=.16, ao=.60, edge=.22, grime=.28, speck=0,   grain=.55, strata=0,   rough_var=.12, bump=.30),
    'ceramic':  dict(var=.11,  part=.22, ao=.62, edge=.26, grime=.30, speck=.45, grain=0,   strata=0,   rough_var=.12, bump=.32),
    'earth':    dict(var=.10,  part=.04, ao=.60, edge=.16, grime=.22, speck=.30, grain=0,   strata=.45, rough_var=.08, bump=.35),
    'foliage':  dict(var=.14,  part=.28, ao=.70, edge=.05, grime=0,   speck=0,   grain=0,   strata=0,   rough_var=.10, bump=.05),
    'fabric':   dict(var=.06,  part=.05, ao=.60, edge=.16, grime=.20, speck=0,   grain=.18, strata=0,   rough_var=.06, bump=.12),
    'soil':     dict(var=.22,  part=0,   ao=.70, edge=0,   grime=0,   speck=.45, grain=0,   strata=0,   rough_var=.05, bump=.45),
    'rubber':   dict(var=.05,  part=.03, ao=.55, edge=.12, grime=.20, speck=.08, grain=0,   strata=0,   rough_var=.08, bump=.10),
}
NAME_LOOKS = [
    (('canvas', 'webbing', 'fabric', 'trouser', 'cloth', 'strap', 'tape', 'rope', 'hoodie', 'bandana'), 'fabric'),
    (('timber', 'plank', 'wood', 'crate', 'trellis'), 'wood'),
    (('concrete', 'terrazzo', 'aggregate', 'plaster', 'asphalt', 'pebble', 'gravel'), 'concrete'),
    (('earth', 'rammed'), 'earth'),
    (('soil', 'mulch', 'dirt'), 'soil'),
    (('sage', 'moss', 'leaf', 'grass', 'herb', 'vine', 'foliage'), 'foliage'),
    (('rubber', 'tire', 'tyre', 'sole', 'offline'), 'rubber'),
    (('graphite', 'steel', 'metal', 'frame', 'alu', 'gold', 'brass', 'teal', 'chrome'), 'metal'),
    (('brick', 'terra', 'ochre', 'cream', 'clay', 'paver', 'amber'), 'ceramic'),
]
ASSET = None


def linear(hex_color):
    h = PALETTE.get(hex_color, hex_color).lstrip('#')
    rgb = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4 for c in rgb)


def guess_look(name):
    lower = name.lower()
    for words, look in NAME_LOOKS:
        if any(w in lower for w in words):
            return look
    return 'clean'


def special(m):
    return m is not None and m.name.startswith(SPECIAL)


def mat(name, color=None, metal=0, rough=.55, emission=0, alpha=1, look=None):
    if name in bpy.data.materials:
        return bpy.data.materials[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    c = (*linear(color or name), alpha)
    bs = m.node_tree.nodes.get('Principled BSDF')
    bs.inputs['Base Color'].default_value = c
    bs.inputs['Metallic'].default_value = metal
    bs.inputs['Roughness'].default_value = rough
    bs.inputs['Alpha'].default_value = alpha
    if emission:
        bs.inputs['Emission Color'].default_value = c
        bs.inputs['Emission Strength'].default_value = emission
    m.diffuse_color = c
    m.use_backface_culling = False
    m['look'] = look or (guess_look(name) if guess_look(name) != 'clean' or not isinstance(color, str)
        else guess_look(color))
    if alpha < 1:
        m.surface_render_method = 'DITHERED'
    return m


def material(value):
    return mat(value) if isinstance(value, str) else value


def use_gpu():
    try:
        prefs = bpy.context.preferences.addons['cycles'].preferences
        prefs.compute_device_type = 'METAL'
        prefs.get_devices()
        for d in prefs.devices:
            d.use = d.type != 'CPU'
        bpy.context.scene.cycles.device = 'GPU'
    except Exception as error:
        print('GPU unavailable, rendering on CPU:', error)


def start(name):
    global ASSET
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for col in list(bpy.data.collections):
        bpy.data.collections.remove(col)
    ASSET = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(ASSET)
    bpy.context.view_layer.active_layer_collection = bpy.context.view_layer.layer_collection.children[ASSET.name]
    for m in list(bpy.data.materials):
        bpy.data.materials.remove(m)
    bpy.context.scene.unit_settings.system = 'METRIC'
    bpy.context.scene.unit_settings.scale_length = 1
    random.seed(17)
    bpy.context.scene.render.fps = 24
    bpy.context.scene.render.engine = 'CYCLES'
    use_gpu()
    return ASSET


def apply(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    return obj


def assign(obj, name, m, smooth=False):
    obj.name = name
    if m:
        obj.data.materials.append(material(m))
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


def box(name, loc, size, m, bevel=.015, segments=2, rot=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.dimensions = size
    if rot:
        o.rotation_euler = rot
    apply(o)
    assign(o, name, m)
    if bevel:
        b = o.modifiers.new('Soft manufactured edges', 'BEVEL')
        b.width = min(bevel, min(size)*.45)
        b.segments = segments
        b = o.modifiers.new('Corner normals', 'WEIGHTED_NORMAL')
        b.keep_sharp = True
    return o


def sphere(name, loc, size, m, segments=20, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1, location=loc)
    o = bpy.context.object
    o.scale = size
    apply(o)
    return assign(o, name, m, True)


def cylinder(name, loc, radius, depth, m, vertices=24, rot=None, bevel=.006):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    o = bpy.context.object
    if rot:
        o.rotation_euler = rot
    apply(o)
    assign(o, name, m)
    for p in o.data.polygons:
        p.use_smooth = len(p.vertices) == 4
    if bevel:
        b = o.modifiers.new('Edge rounds', 'BEVEL')
        b.width = min(bevel, depth*.2)
        b.segments = 2
        o.modifiers.new('Corner normals', 'WEIGHTED_NORMAL')
    return o


def rod(name, a, b, radius, m, vertices=10):
    d = Vector(b)-Vector(a)
    o = cylinder(name, (Vector(a)+Vector(b))/2, radius, d.length, m, vertices, bevel=0)
    o.rotation_euler = d.to_track_quat('Z', 'Y').to_euler()
    apply(o)
    return o


def ring(name, loc, radius, tube, m, rot=None, major=32, minor=6):
    bpy.ops.mesh.primitive_torus_add(major_segments=major, minor_segments=minor,
        location=loc, major_radius=radius, minor_radius=tube)
    o = bpy.context.object
    if rot:
        o.rotation_euler = rot
    apply(o)
    return assign(o, name, m, True)


def mesh(name, verts, faces, m, smooth=False):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces)
    data.update()
    o = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(o)
    return assign(o, name, m, smooth)


def tube(name, points, radius, m, resolution=2, bevel_resolution=2):
    cu = bpy.data.curves.new(name, 'CURVE')
    cu.dimensions = '3D'
    cu.resolution_u = resolution
    cu.bevel_depth = radius
    cu.bevel_resolution = bevel_resolution
    cu.use_fill_caps = True
    s = cu.splines.new('BEZIER')
    s.bezier_points.add(len(points)-1)
    for p, co in zip(s.bezier_points, points):
        p.co = co
        p.handle_left_type = p.handle_right_type = 'AUTO'
    o = bpy.data.objects.new(name, cu)
    bpy.context.collection.objects.link(o)
    cu.materials.append(material(m))
    return o


def leaf(name, base, tip, width, m='sage'):
    a, b = Vector(base), Vector(tip)
    d = b-a
    side = d.cross(Vector((0,0,1)))
    if side.length < .001:
        side = Vector((1,0,0))
    side.normalize()
    mid = a+d*.5
    ridge = mid + Vector((0,0,width*.22))
    return mesh(name, [a,mid+side*width/2,b,mid-side*width/2,ridge],
        [(0,1,4),(1,2,4),(2,3,4),(3,0,4)],m)


def status(color='cyan'):
    return mat('status_ring', color, rough=.28, emission=2.5)


def warm():
    return mat('emissive_warm', 'warm', rough=.32, emission=2)


def parent_keep(obj, parent):
    world = obj.matrix_world.copy()
    obj.parent = parent
    obj.matrix_world = world


def pivot(name, loc, objects):
    bpy.context.view_layer.update()
    o = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(o)
    o.location = loc
    bpy.context.view_layer.update()
    for child in objects:
        parent_keep(child, o)
    return o


def action(obj, name, keys, path='location'):
    obj.animation_data_create()
    obj.animation_data.action = None
    for frame, value in keys:
        setattr(obj, path, value)
        obj.keyframe_insert(data_path=path, frame=frame)
    a = obj.animation_data.action
    a.name = name
    track = obj.animation_data.nla_tracks.new()
    track.name = name
    track.strips.new(name, int(a.frame_range[0]), a)
    obj.animation_data.action = None
    track.mute = True
    return a


def to_mesh(obj):
    """Converts curves and applies every modifier except skinning, keeping the object and its animation."""
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    if obj.type == 'CURVE':
        bpy.ops.object.convert(target='MESH')
    for mod in list(obj.modifiers):
        if mod.type != 'ARMATURE':
            bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj


def tag_parts(objects, seed):
    """Per-part attributes the bake reads: a random value for color jitter, and a grain stretch
    along each part's longest axis, so planks and brushed metal streak the right way."""
    rng = random.Random(seed)
    for o in objects:
        if o.type != 'MESH' or not o.data.vertices:
            continue
        dims = list(o.dimensions)
        longest = dims.index(max(dims))
        grain = [1.0 if i == longest else 14.0 for i in range(3)]
        n = len(o.data.vertices)
        value = rng.random()
        a = o.data.attributes.get('part_rand') or o.data.attributes.new('part_rand', 'FLOAT', 'POINT')
        a.data.foreach_set('value', [value]*n)
        g = o.data.attributes.get('grain') or o.data.attributes.new('grain', 'FLOAT_VECTOR', 'POINT')
        g.data.foreach_set('vector', grain*n)


# --- Stylized bake: procedural wear evaluated by Cycles and baked to three images per asset. ---

def _set(nt, socket, value):
    if isinstance(value, bpy.types.NodeSocket):
        nt.links.new(value, socket)
    else:
        socket.default_value = value


def _math(nt, op, a, b=None, clamp=False):
    n = nt.nodes.new('ShaderNodeMath')
    n.operation = op
    n.use_clamp = clamp
    _set(nt, n.inputs[0], a)
    if b is not None:
        _set(nt, n.inputs[1], b)
    return n.outputs[0]


def _remap(nt, value, lo, hi):
    n = nt.nodes.new('ShaderNodeMapRange')
    n.clamp = True
    _set(nt, n.inputs['Value'], value)
    n.inputs['From Min'].default_value = lo
    n.inputs['From Max'].default_value = hi
    return n.outputs['Result']


def _mix(nt, a, b, factor, blend='MIX'):
    n = nt.nodes.new('ShaderNodeMix')
    n.data_type = 'RGBA'
    n.blend_type = blend
    n.clamp_result = True
    sockets = {s.identifier: s for s in n.inputs}
    _set(nt, sockets['Factor_Float'], factor)
    _set(nt, sockets['A_Color'], a)
    _set(nt, sockets['B_Color'], b)
    return next(s for s in n.outputs if s.identifier == 'Result_Color')


def _scale(nt, color, factor):
    n = nt.nodes.new('ShaderNodeVectorMath')
    n.operation = 'SCALE'
    _set(nt, n.inputs[0], color)
    _set(nt, n.inputs['Scale'], factor)
    return n.outputs[0]


def _noise(nt, vector, scale, detail=2.0, rough=.5, distortion=0.0):
    n = nt.nodes.new('ShaderNodeTexNoise')
    _set(nt, n.inputs['Vector'], vector)
    n.inputs['Scale'].default_value = scale
    n.inputs['Detail'].default_value = detail
    n.inputs['Roughness'].default_value = rough
    n.inputs['Distortion'].default_value = distortion
    return n.outputs['Fac']


def _attribute(nt, name, output):
    n = nt.nodes.new('ShaderNodeAttribute')
    n.attribute_type = 'GEOMETRY'
    n.attribute_name = name
    return n.outputs[output]


def _stylize(m):
    """Adds the wear network to a material; returns its color, roughness, metallic and normal sockets."""
    look = LOOKS[m.get('look', 'clean')]
    nt = m.node_tree
    bs = nt.nodes.get('Principled BSDF')
    base = bs.inputs['Base Color']
    if base.is_linked:
        color = base.links[0].from_socket
    else:
        rgb = nt.nodes.new('ShaderNodeRGB')
        rgb.outputs[0].default_value = base.default_value
        color = rgb.outputs[0]
    rough0 = bs.inputs['Roughness'].default_value
    metal0 = bs.inputs['Metallic'].default_value
    geo = nt.nodes.new('ShaderNodeNewGeometry')
    pos, normal = geo.outputs['Position'], geo.outputs['Normal']
    rand = _attribute(nt, 'part_rand', 'Fac')
    stretch = _attribute(nt, 'grain', 'Vector')
    broad = _noise(nt, pos, 2.2, 3, .55)
    fine = _noise(nt, pos, 36, 2, .5)
    jitter = _math(nt, 'ADD', _math(nt, 'MULTIPLY', _math(nt, 'SUBTRACT', broad, .5), 2*look['var']),
        _math(nt, 'MULTIPLY', _math(nt, 'SUBTRACT', rand, .5), 2*look['part']))
    color = _scale(nt, color, _math(nt, 'ADD', jitter, 1.0))
    height = fine
    if look['grain']:
        vec = nt.nodes.new('ShaderNodeVectorMath')
        vec.operation = 'MULTIPLY'
        _set(nt, vec.inputs[0], pos)
        _set(nt, vec.inputs[1], stretch)
        offset = nt.nodes.new('ShaderNodeVectorMath')
        offset.operation = 'ADD'
        _set(nt, offset.inputs[0], vec.outputs[0])
        _set(nt, offset.inputs[1], _scale(nt, (1, 1, 1), _math(nt, 'MULTIPLY', rand, 40)))
        grain = _noise(nt, offset.outputs[0], 3.2, 8, .62, .35)
        color = _scale(nt, color, _math(nt, 'ADD', 1.0, _math(nt, 'MULTIPLY', _math(nt, 'SUBTRACT', grain, .5), 2*look['grain'])))
        height = grain
    if look['speck']:
        vor = nt.nodes.new('ShaderNodeTexVoronoi')
        _set(nt, vor.inputs['Vector'], pos)
        vor.inputs['Scale'].default_value = 55
        dots = _remap(nt, vor.outputs['Distance'], .13, .05)
        shade = _math(nt, 'ADD', .65, _math(nt, 'MULTIPLY', _math(nt, 'GREATER_THAN',
            _noise(nt, vor.outputs['Position'], 90, 0), .5), .7))
        color = _mix(nt, color, _scale(nt, color, shade), _math(nt, 'MULTIPLY', dots, look['speck']))
        height = _math(nt, 'ADD', height, _math(nt, 'MULTIPLY', dots, -.5))
    if look['strata']:
        wave = nt.nodes.new('ShaderNodeTexWave')
        wave.wave_type = 'BANDS'
        wave.bands_direction = 'Z'
        _set(nt, wave.inputs['Vector'], pos)
        wave.inputs['Scale'].default_value = 1.1
        wave.inputs['Distortion'].default_value = 1.6
        wave.inputs['Detail'].default_value = 2
        wave.inputs['Detail Scale'].default_value = .8
        ramp = nt.nodes.new('ShaderNodeValToRGB')
        ramp.color_ramp.interpolation = 'EASE'
        elements = ramp.color_ramp.elements
        elements[0].color, elements[1].color = (*linear('#A86A43'), 1), (*linear('#B98553'), 1)
        for at, name in [(.35, '#C99A63'), (.6, '#B07A4C'), (.8, '#D2AA75')]:
            elements.new(at).color = (*linear(name), 1)
        nt.links.new(wave.outputs['Fac'], ramp.inputs['Fac'])
        color = _mix(nt, color, ramp.outputs['Color'], look['strata'])
        height = _math(nt, 'ADD', height, _math(nt, 'MULTIPLY', wave.outputs['Fac'], .6))
    ao = nt.nodes.new('ShaderNodeAmbientOcclusion')
    ao.samples = 16
    ao.inputs['Distance'].default_value = .3
    occlusion = ao.outputs['AO']
    color = _scale(nt, color, _math(nt, 'SUBTRACT', 1.0, _math(nt, 'MULTIPLY', _math(nt, 'SUBTRACT', 1.0, occlusion), look['ao'])))
    bevel = nt.nodes.new('ShaderNodeBevel')
    bevel.samples = 8
    bevel.inputs['Radius'].default_value = .012
    dot = nt.nodes.new('ShaderNodeVectorMath')
    dot.operation = 'DOT_PRODUCT'
    nt.links.new(bevel.outputs['Normal'], dot.inputs[0])
    nt.links.new(normal, dot.inputs[1])
    edge = _remap(nt, dot.outputs['Value'], .997, .93)
    convex = _math(nt, 'MULTIPLY', edge, _remap(nt, occlusion, .72, .95))
    worn = _mix(nt, color, (1, 1, 1, 1), .28)
    color = _mix(nt, color, worn, _math(nt, 'MULTIPLY', convex, look['edge']*3.2, clamp=True))
    sep = nt.nodes.new('ShaderNodeSeparateXYZ')
    nt.links.new(pos, sep.inputs[0])
    low = _remap(nt, sep.outputs['Z'], .5, 0.0)
    dirt = _math(nt, 'ADD', _math(nt, 'MULTIPLY', low, _noise(nt, pos, 5, 4, .6)),
        _math(nt, 'MULTIPLY', _math(nt, 'SUBTRACT', 1.0, occlusion), .8), clamp=True)
    grime = _scale(nt, _mix(nt, color, (*linear('#5B4A36'), 1), .45, 'MULTIPLY'), .8)
    color = _mix(nt, color, grime, _math(nt, 'MULTIPLY', dirt, look['grime']*1.6, clamp=True))
    rough = _math(nt, 'ADD', rough0, _math(nt, 'MULTIPLY', _math(nt, 'SUBTRACT', fine, .5), 2*look['rough_var']))
    rough = _math(nt, 'ADD', rough, _math(nt, 'MULTIPLY', dirt, .15*look['grime']/.3 if look['grime'] else 0))
    rough = _math(nt, 'SUBTRACT', rough, _math(nt, 'MULTIPLY', convex, .12), clamp=True)
    bump = nt.nodes.new('ShaderNodeBump')
    bump.inputs['Strength'].default_value = look['bump']
    bump.inputs['Distance'].default_value = .004
    _set(nt, bump.inputs['Height'], height)
    nt.links.new(bevel.outputs['Normal'], bump.inputs['Normal'])
    return {'color': color, 'rough': rough, 'metal': metal0, 'normal': bump.outputs['Normal']}


def _image(name, size, data=False):
    if name in bpy.data.images:
        bpy.data.images.remove(bpy.data.images[name])
    img = bpy.data.images.new(name, size, size, alpha=False, float_buffer=False)
    img.colorspace_settings.name = 'Non-Color' if data else 'sRGB'
    return img


def _pixels(img):
    a = np.empty(len(img.pixels), dtype=np.float32)
    img.pixels.foreach_get(a)
    return a.reshape(img.size[1], img.size[0], 4)


def _pack_jpeg(img, quality=90):
    path = Path(tempfile.gettempdir())/f'{img.name}.jpg'
    img.filepath_raw = str(path)
    img.file_format = 'JPEG'
    img.save(filepath=str(path), quality=quality)
    img.pack()
    return img


def _with_ground(objects):
    """A temporary floor gives standing assets contact shadow in the bake."""
    lo, _ = bounds(objects)
    if lo[2] < -.01:
        return None
    bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, lo[2]-.001))
    plane = bpy.context.object
    plane.data.materials.append(mat('bake_ground', '#808080'))
    return plane


def bake_stylized(objects, name, size=1024):
    """Bakes every non-special material on these meshes into one atlas: albedo with occlusion,
    worn edges and grime; a normal map with rounded edges and grain; roughness and metal."""
    targets = [o for o in objects if o.type == 'MESH'
        and any(s.material and not special(s.material) for s in o.material_slots)]
    if not targets:
        return None
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    use_gpu()
    scene.cycles.samples = 64
    for o in targets:
        to_mesh(o)
        if not o.data.uv_layers:
            o.data.uv_layers.new(name='UVMap')
    bpy.ops.object.select_all(action='DESELECT')
    for o in targets:
        o.select_set(True)
    bpy.context.view_layer.objects.active = targets[0]
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.context.tool_settings.mesh_select_mode = (False, False, True)
    for o in targets:
        bm = bmesh.from_edit_mesh(o.data)
        for f in bm.faces:
            f.select = not special(o.material_slots[f.material_index].material if o.material_slots else None)
        bm.select_flush_mode()
        bmesh.update_edit_mesh(o.data)
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=.004, scale_to_bounds=False)
    bpy.ops.uv.pack_islands(margin=.004, shape_method='CONVEX')
    bpy.ops.object.mode_set(mode='OBJECT')
    ground = _with_ground(targets)
    mats = []
    for o in targets:
        for s in o.material_slots:
            if s.material and not special(s.material) and s.material not in mats:
                mats.append(s.material)
    outputs = {m: _stylize(m) for m in mats}
    dummy = _image(name+'_unused', 8)
    helpers = {}
    for m in {s.material for o in targets for s in o.material_slots if s.material}:
        nt = m.node_tree
        node = nt.nodes.new('ShaderNodeTexImage')
        emit = nt.nodes.new('ShaderNodeEmission')
        diffuse = nt.nodes.new('ShaderNodeBsdfDiffuse')
        out = next(n for n in nt.nodes if n.type == 'OUTPUT_MATERIAL' and n.is_active_output)
        helpers[m] = (node, emit, diffuse, out, out.inputs['Surface'].links[0].from_socket if out.inputs['Surface'].is_linked else None)
        nt.nodes.active = node
        node.image = dummy
    images = {}
    for key, data in [('color', False), ('rough', True), ('metal', True), ('normal', True)]:
        images[key] = _image(f'{name}_{key}', size, data)
        for m, (node, emit, diffuse, out, _) in helpers.items():
            nt = m.node_tree
            node.image = images[key] if m in outputs else dummy
            nt.nodes.active = node
            if m not in outputs:
                continue
            if key == 'normal':
                _set(nt, diffuse.inputs['Normal'], outputs[m]['normal'])
                nt.links.new(diffuse.outputs[0], out.inputs['Surface'])
            else:
                value = outputs[m][key]
                _set(nt, emit.inputs['Color'], value if isinstance(value, bpy.types.NodeSocket) else (value,)*3+(1,))
                nt.links.new(emit.outputs[0], out.inputs['Surface'])
        bpy.ops.object.select_all(action='DESELECT')
        for o in targets:
            o.select_set(True)
        bpy.context.view_layer.objects.active = targets[0]
        if key == 'normal':
            bpy.ops.object.bake(type='NORMAL', normal_space='TANGENT', margin=8, use_clear=True)
        else:
            bpy.ops.object.bake(type='EMIT', margin=8, use_clear=True)
    for m, (node, emit, diffuse, out, original) in helpers.items():
        nt = m.node_tree
        if original:
            nt.links.new(original, out.inputs['Surface'])
        for n in (node, emit, diffuse):
            nt.nodes.remove(n)
    if ground:
        bpy.data.objects.remove(ground, do_unlink=True)
    rough, metal = _pixels(images['rough']), _pixels(images['metal'])
    orm = _image(f'{name}_orm', size, True)
    packed = np.ones_like(rough)
    packed[..., 1], packed[..., 2] = rough[..., 0], metal[..., 0]
    orm.pixels.foreach_set(packed.ravel())
    for key in ('rough', 'metal'):
        bpy.data.images.remove(images.pop(key))
    bpy.data.images.remove(dummy)
    for img in (images['color'], orm, images['normal']):
        _pack_jpeg(img, 92 if img is images['normal'] else 90)
    baked = bpy.data.materials.new(name+'_baked')
    baked.use_nodes = True
    nt = baked.node_tree
    bs = nt.nodes['Principled BSDF']
    t = nt.nodes.new('ShaderNodeTexImage')
    t.image = images['color']
    nt.links.new(t.outputs['Color'], bs.inputs['Base Color'])
    t = nt.nodes.new('ShaderNodeTexImage')
    t.image = orm
    sep = nt.nodes.new('ShaderNodeSeparateColor')
    nt.links.new(t.outputs['Color'], sep.inputs[0])
    nt.links.new(sep.outputs['Green'], bs.inputs['Roughness'])
    nt.links.new(sep.outputs['Blue'], bs.inputs['Metallic'])
    t = nt.nodes.new('ShaderNodeTexImage')
    t.image = images['normal']
    nm = nt.nodes.new('ShaderNodeNormalMap')
    nt.links.new(t.outputs['Color'], nm.inputs['Color'])
    nt.links.new(nm.outputs['Normal'], bs.inputs['Normal'])
    baked['look'] = 'baked'
    for o in targets:
        slots = [s.material for s in o.material_slots]
        keep = [baked] + [m for m in dict.fromkeys(slots) if special(m)]
        remap = [keep.index(m) if special(m) else 0 for m in slots]
        indices = [remap[p.material_index] for p in o.data.polygons]
        o.data.materials.clear()
        for m in keep:
            o.data.materials.append(m)
        o.data.polygons.foreach_set('material_index', indices)
    for m in mats:
        if m.users == 0:
            bpy.data.materials.remove(m)
    return baked


# --- Review renders ---

def _camera(target, distance, pitch, yaw, name, size, angle=30):
    data = bpy.data.cameras.new(name)
    data.sensor_fit = 'VERTICAL'
    data.angle_y = math.radians(angle)
    cam = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(cam)
    p,y = math.radians(pitch),math.radians(yaw)
    offset = Vector((math.sin(y)*math.cos(p),-math.cos(y)*math.cos(p),math.sin(p)))
    cam.location = Vector(target)+offset*distance
    cam.rotation_euler = (Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler()
    bpy.context.scene.camera = cam
    bpy.context.scene.render.resolution_x, bpy.context.scene.render.resolution_y = size
    return cam


def _light(name, loc, power, size, color, target=(0,0,.8)):
    data = bpy.data.lights.new(name,'AREA')
    data.energy, data.shape, data.size = power,'DISK',size
    data.color = color
    o = bpy.data.objects.new(name,data)
    bpy.context.collection.objects.link(o)
    o.location = loc
    o.rotation_euler = (Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()


def bounds(objects):
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    points = [o.matrix_world @ Vector(v) for obj in objects if obj.type in {'MESH','CURVE'}
        for o in [obj.evaluated_get(dg)] for v in o.bound_box]
    return [min(p[i] for p in points) for i in range(3)], [max(p[i] for p in points) for i in range(3)]


def studio(lo, hi, dark_floor='#353B41'):
    """Review lighting: warm key, cool fill, warm rim, and a dark floor so emissives read."""
    scene = bpy.context.scene
    studio = bpy.data.collections.new('PREVIEW_ONLY')
    scene.collection.children.link(studio)
    bpy.context.view_layer.active_layer_collection = bpy.context.view_layer.layer_collection.children[studio.name]
    floor_z = min(0,lo[2])-.008
    box('Studio floor',(0,0,floor_z-.05),(200,200,.1),mat('studio',dark_floor,rough=.8,look='concrete'),0)
    if not scene.world:
        scene.world = bpy.data.worlds.new('World')
    scene.world.use_nodes = True
    bg = scene.world.node_tree.nodes['Background']
    bg.inputs[0].default_value = (.34,.42,.55,1)
    bg.inputs[1].default_value = .32
    center = ((lo[0]+hi[0])/2,(lo[1]+hi[1])/2,(lo[2]+hi[2])/2)
    reach = max(1.0, max(hi[i]-lo[i] for i in range(3)))
    _light('Warm key',(center[0]-3*reach,center[1]-4*reach,center[2]+6*reach),900*reach*reach,4*reach,(1,.86,.7),center)
    _light('Sky fill',(center[0]+4*reach,center[1]-2*reach,center[2]+4*reach),380*reach*reach,5*reach,(.62,.78,1),center)
    _light('Warm rim',(center[0]+2*reach,center[1]+4.5*reach,center[2]+5*reach),1100*reach*reach,3*reach,(1,.84,.62),center)
    scene.cycles.samples = 48
    scene.cycles.use_denoising = True
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.view_settings.view_transform = 'AgX'
    scene.view_settings.look = 'AgX - Medium High Contrast'
    return studio


def _render(path):
    bpy.context.scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)
    img = bpy.data.images.load(str(path))
    a = _pixels(img).copy()
    bpy.data.images.remove(img)
    Path(path).unlink()
    return a


def _save_jpeg(pixels, path, quality=88):
    h, w = pixels.shape[:2]
    img = bpy.data.images.new(Path(path).stem, w, h, alpha=False)
    img.pixels.foreach_set(np.ascontiguousarray(pixels, dtype=np.float32).ravel())
    img.filepath_raw = str(path)
    img.file_format = 'JPEG'
    img.save(filepath=str(path), quality=quality)
    bpy.data.images.remove(img)


def review_renders(name, lo, hi, front_yaw=35, front_pitch=18, front_target=None, front_distance=None):
    """Writes <name>_front.jpg (close three-quarter) and <name>_game.jpg: the tactics camera at its
    default 34 m zoom, shown at true pixel size then enlarged 3x, beside its closest 12 m zoom."""
    tmp = Path(tempfile.gettempdir())
    target = front_target or ((lo[0]+hi[0])/2,(lo[1]+hi[1])/2,(lo[2]+hi[2])/2)
    extent = max(hi[i]-lo[i] for i in range(3))
    distance = front_distance or max(.3,extent*3.25)
    _camera(target,distance,front_pitch,front_yaw,'Close review',(1024,1024))
    _save_jpeg(_render(tmp/f'{name}_front.png'), ROOT/f'art/previews/{name}_front.jpg')
    ref_x = max(.65,hi[0]+.55)
    ref = mat('reference','#A6B2B5',rough=.85)
    cylinder('1.7 m reference stem',(ref_x,0,.85),.16,1.38,ref,24,bevel=0)
    sphere('Reference top',(ref_x,0,1.54),(.16,.16,.16),ref)
    sphere('Reference bottom',(ref_x,0,.16),(.16,.16,.16),ref)
    center = ((lo[0]+ref_x+.16)/2, 0, .8)
    view = lambda px: math.degrees(2*math.atan(math.tan(math.radians(15))*px/900))
    _camera(center,34,50,45,'Tactics default zoom',(200,200),view(200))
    near = _render(tmp/f'{name}_game_far.png')
    near = near.repeat(3, axis=0).repeat(3, axis=1)
    _camera(center,12,50,45,'Tactics closest zoom',(600,600),view(600))
    close = _render(tmp/f'{name}_game_near.png')
    gap = np.zeros((600, 8, 4), dtype=np.float32)
    gap[..., 3] = 1
    _save_jpeg(np.concatenate([near, gap, close], axis=1), ROOT/f'art/previews/{name}_game.jpg')


def finish(name, category, choice, front_yaw=35, front_pitch=18, front_target=None, front_distance=None, bake=1024):
    objects = list(ASSET.objects)
    for o in objects:
        if o.type in {'MESH','CURVE'}:
            apply(o)
            to_mesh(o)
    bpy.context.view_layer.update()
    tag_parts([o for o in ASSET.objects if o.type == 'MESH'], name)
    # Merge static parts for tile instancing; preserve articulated pieces and armatures.
    static = [o for o in ASSET.objects if o.type == 'MESH' and o.parent_type != 'BONE'
        and not o.animation_data and not any(m.type == 'ARMATURE' for m in o.modifiers)]
    groups = {}
    for o in static:
        groups.setdefault(o.parent, []).append(o)
    for parent, siblings in groups.items():
        bpy.ops.object.select_all(action='DESELECT')
        for o in siblings:
            o.select_set(True)
        bpy.context.view_layer.objects.active = siblings[0]
        bpy.ops.object.join()
        bpy.context.object.name = (parent.name if parent else name)+'_mesh'
    textures = 'Flat materials, no textures.'
    if bake:
        if bake_stylized(list(ASSET.objects), name, bake):
            textures = f'Baked {bake} px albedo, normal and roughness/metal atlas.'
    objects = list(ASSET.objects)
    root = pivot(name, (0,0,0), [o for o in objects if o.parent is None])
    root['front'] = 'Blender -Y; glTF +Z'
    root['units'] = 'metres'
    lo, hi = bounds(objects)
    for folder in ('art/source','art/previews',f'game/art/{category}'):
        (ROOT/folder).mkdir(parents=True, exist_ok=True)
    path = ROOT/f'game/art/{category}/{name}.glb'
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects+[root]:
        o.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',use_selection=True,
        export_apply=True,export_yup=True,export_extras=True,export_animations=True,
        export_animation_mode='NLA_TRACKS',export_force_sampling=True,
        export_optimize_animation_keep_anim_object=True,export_image_format='AUTO',
        export_tangents=bool(bake),export_cameras=False,export_lights=False)
    raw = path.read_bytes()
    json_size = struct.unpack_from('<I',raw,12)[0]
    doc = json.loads(raw[20:20+json_size])
    tris = sum(doc['accessors'][p['indices']]['count']//3 for m in doc.get('meshes',[]) for p in m['primitives'])
    animations = ', '.join(a['name'] for a in doc.get('animations',[])) or 'static'
    studio(lo, hi)
    review_renders(name, lo, hi, front_yaw, front_pitch, front_target, front_distance)
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/f'art/source/{name}.blend'))
    notes = ROOT/'art/NOTES.md'
    lines = notes.read_text().splitlines()
    lines = [l for l in lines if not l.startswith(f'| `{name}` |')]
    dims = ' × '.join(f'{hi[i]-lo[i]:.3f}' for i in range(3))
    lines.append(f'| `{name}` | {tris:,} | {dims} | {animations} | {textures} {choice} |')
    notes.write_text('\n'.join(lines)+'\n')
    print('ASSET_COMPLETE '+json.dumps({'name':name,'triangles':tris,'bounds':[lo,hi],'animations':animations,
        'glb_kb':round(path.stat().st_size/1024)}))
