"""Shared metre-scale geometry, palette, export and review lighting. Run with Blender."""
from pathlib import Path
import json
import math
import random
import struct
import bpy
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
ASSET = None


def linear(hex_color):
    h = PALETTE.get(hex_color, hex_color).lstrip('#')
    rgb = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    return tuple(c / 12.92 if c <= .04045 else ((c + .055) / 1.055) ** 2.4 for c in rgb)


def mat(name, color=None, metal=0, rough=.55, emission=0, alpha=1):
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
    if alpha < 1:
        m.surface_render_method = 'DITHERED'
    return m


def material(value):
    return mat(value) if isinstance(value, str) else value


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
    obj.animation_data_clear()
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


def _camera(target, distance, pitch, yaw, name, size):
    data = bpy.data.cameras.new(name)
    data.sensor_fit = 'VERTICAL'
    data.angle_y = math.radians(30)
    cam = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(cam)
    p,y = math.radians(pitch),math.radians(yaw)
    offset = Vector((math.sin(y)*math.cos(p),-math.cos(y)*math.cos(p),math.sin(p)))
    cam.location = Vector(target)+offset*distance
    cam.rotation_euler = (Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler()
    bpy.context.scene.camera = cam
    bpy.context.scene.render.resolution_x, bpy.context.scene.render.resolution_y = size
    return cam


def _light(name, loc, power, size, color):
    data = bpy.data.lights.new(name,'AREA')
    data.energy, data.shape, data.size = power,'DISK',size
    data.color = color
    o = bpy.data.objects.new(name,data)
    bpy.context.collection.objects.link(o)
    o.location = loc
    o.rotation_euler = (Vector((0,0,.8))-o.location).to_track_quat('-Z','Y').to_euler()


def bounds(objects):
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    points = [o.matrix_world @ Vector(v) for obj in objects if obj.type in {'MESH','CURVE'}
        for o in [obj.evaluated_get(dg)] for v in o.bound_box]
    return [min(p[i] for p in points) for i in range(3)], [max(p[i] for p in points) for i in range(3)]


def finish(name, category, choice, front_yaw=35, front_pitch=18, front_target=None, front_distance=None):
    objects = list(ASSET.objects)
    for o in objects:
        if o.type in {'MESH','CURVE'}:
            apply(o)
    bpy.context.view_layer.update()
    # Merge static parts for tile instancing; preserve articulated pieces and armatures.
    static = [o for o in objects if o.type in {'MESH','CURVE'} and o.parent is None
        and not o.animation_data and not any(m.type == 'ARMATURE' for m in o.modifiers)]
    if static:
        bpy.ops.object.select_all(action='DESELECT')
        for o in static:
            o.select_set(True)
        bpy.context.view_layer.objects.active = static[0]
        bpy.ops.object.convert(target='MESH')
        bpy.ops.object.join()
        bpy.context.object.name = name+'_mesh'
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
        export_cameras=False,export_lights=False)
    raw = path.read_bytes()
    json_size = struct.unpack_from('<I',raw,12)[0]
    doc = json.loads(raw[20:20+json_size])
    tris = sum(doc['accessors'][p['indices']]['count']//3 for m in doc.get('meshes',[]) for p in m['primitives'])
    animations = ', '.join(a['name'] for a in doc.get('animations',[])) or 'static'
    scene = bpy.context.scene
    studio = bpy.data.collections.new('PREVIEW_ONLY')
    scene.collection.children.link(studio)
    bpy.context.view_layer.active_layer_collection = bpy.context.view_layer.layer_collection.children[studio.name]
    floor_z = min(0,lo[2])-.008
    box('Studio floor',(0,0,floor_z-.05),(200,200,.1),mat('studio','#454C51',rough=.82),0)
    scene.world.color = (.25,.25,.25)
    scene.world.use_nodes = True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.4,.47,.55,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value = .38
    _light('Warm key',(-3,-4,7),800,5,(1,.87,.73))
    _light('Sky fill',(4,-1,5),650,4,(.68,.82,1))
    _light('Soft rim',(1,4,6),1000,3,(1,.89,.68))
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 24
    scene.cycles.use_denoising = True
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.view_settings.view_transform = 'AgX'
    target = front_target or ((lo[0]+hi[0])/2,(lo[1]+hi[1])/2,(lo[2]+hi[2])/2)
    extent = max(hi[i]-lo[i] for i in range(3))
    distance = front_distance or max(.3,extent*3.25)
    _camera(target,distance,front_pitch,front_yaw,'Close review',(1024,1024))
    scene.render.filepath = str(ROOT/f'art/previews/{name}_front.png')
    bpy.ops.render.render(write_still=True)
    ref_x = max(.65,hi[0]+.55)
    ref = mat('reference','#A6B2B5',rough=.85)
    cylinder('1.7 m reference stem',(ref_x,0,.85),.16,1.38,ref,24,bevel=0)
    sphere('Reference top',(ref_x,0,1.54),(.16,.16,.16),ref)
    sphere('Reference bottom',(ref_x,0,.16),(.16,.16,.16),ref)
    _camera((0,0,.8),34,50,45,'Tactics review',(1600,900))
    scene.render.filepath = str(ROOT/f'art/previews/{name}_game.png')
    bpy.ops.render.render(write_still=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/f'art/source/{name}.blend'))
    notes = ROOT/'art/NOTES.md'
    if not notes.exists():
        notes.write_text('# Priority 1 art review\n\nPrototype interpretations of `astra-brief.md`; creative approval remains with Bryson. '
            'Models are exported for review, not installed into battle visuals.\n\n'
            'Rebuild one asset from the project root: `blender --background --python art/scripts/<asset>.py`. '
            'The asset collection exports; `PREVIEW_ONLY` contains the excluded studio and scale reference. '
            'Blender front is −Y; the standard glTF conversion makes that Godot +Z. '
            'All dimensions below are Blender X × Y × Z, in metres. Floor slabs end at Z=0.\n\n'
            '| Asset | Exported triangles | Dimensions | Animation clips | Choices and limits |\n'
            '|---|---:|---|---|---|\n')
    lines = notes.read_text().splitlines()
    lines = [l for l in lines if not l.startswith(f'| `{name}` |')]
    dims = ' × '.join(f'{hi[i]-lo[i]:.3f}' for i in range(3))
    lines.append(f'| `{name}` | {tris:,} | {dims} | {animations} | {choice} |')
    notes.write_text('\n'.join(lines)+'\n')
    print('ASSET_COMPLETE '+json.dumps({'name':name,'triangles':tris,'bounds':[lo,hi],'animations':animations}))
