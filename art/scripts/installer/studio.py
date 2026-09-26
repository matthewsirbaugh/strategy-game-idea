"""Preview lighting, backdrop and cameras for the Installer review renders."""
import math
import bpy
from mathutils import Vector
from .shading import Graph, VENDOR, srgb


def use_gpu():
    prefs = bpy.context.preferences.addons['cycles'].preferences
    for backend in ('METAL', 'OPTIX', 'CUDA'):
        try:
            prefs.compute_device_type = backend
            break
        except TypeError:
            continue
    prefs.get_devices()
    for d in prefs.devices:
        d.use = True
    bpy.context.scene.cycles.device = 'GPU'


def setup(collection, samples=96, backdrop='#CFC3B4'):
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    use_gpu()
    scene.cycles.samples = samples
    scene.cycles.use_denoising = True
    scene.cycles.denoiser = 'OPENIMAGEDENOISE'
    scene.cycles.max_bounces = 8
    scene.cycles.transparent_max_bounces = 24
    scene.view_settings.view_transform = 'AgX'
    scene.view_settings.look = 'AgX - Medium High Contrast'
    scene.render.image_settings.file_format = 'PNG'
    world = scene.world or bpy.data.worlds.new('World')
    scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    nt.nodes.clear()
    env = nt.nodes.new('ShaderNodeTexEnvironment')
    env.image = bpy.data.images.load(str(VENDOR / 'hdri/studio_small_09_2k.hdr'), check_existing=True)
    mapping = nt.nodes.new('ShaderNodeMapping')
    mapping.inputs['Rotation'].default_value = (0, 0, math.radians(160))
    coord = nt.nodes.new('ShaderNodeTexCoord')
    bg = nt.nodes.new('ShaderNodeBackground')
    bg.inputs['Strength'].default_value = .55
    out = nt.nodes.new('ShaderNodeOutputWorld')
    nt.links.new(coord.outputs['Generated'], mapping.inputs['Vector'])
    nt.links.new(mapping.outputs['Vector'], env.inputs['Vector'])
    nt.links.new(env.outputs['Color'], bg.inputs['Color'])
    nt.links.new(bg.outputs['Background'], out.inputs['Surface'])

    def light(name, loc, energy, size, color):
        data = bpy.data.lights.new(name, 'AREA')
        data.energy, data.shape, data.size, data.color = energy, 'DISK', size, color
        o = bpy.data.objects.new(name, data)
        collection.objects.link(o)
        o.location = loc
        o.rotation_euler = (Vector((0, 0, 1.1)) - Vector(loc)).to_track_quat('-Z', 'Y').to_euler()
        return o

    light('Key', (-2.2, -2.8, 3.2), 260, 2.2, (1.0, .9, .8))
    light('Rim', (1.8, 2.4, 2.8), 260, 1.6, (.85, .9, 1.0))
    light('Fill', (2.6, -2.0, 1.2), 90, 3.0, (1.0, .95, .9))

    # Curved cyclorama so the backdrop reads like the concept sheet's paper background.
    bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 1.5, 0))
    cyc = bpy.context.object
    cyc.name = 'Backdrop'
    for c in list(cyc.users_collection):
        c.objects.unlink(cyc)
    collection.objects.link(cyc)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.subdivide(number_cuts=40)
    bpy.ops.object.mode_set(mode='OBJECT')
    for v in cyc.data.vertices:
        y = v.co.y
        if y > 1.0:
            t = (y - 1.0)
            v.co.z = t * t * .25 if t < 3 else (t - 1.5) * 1.5
    g = Graph('backdrop')
    g.set(**{'Base Color': srgb(backdrop), 'Roughness': .9})
    cyc.data.materials.append(g.mat)
    for p in cyc.data.polygons:
        p.use_smooth = True
    return cyc


def camera(name, target, distance, yaw, pitch, lens=85, res=(1024, 1536), collection=None):
    data = bpy.data.cameras.get(name) or bpy.data.cameras.new(name)
    data.lens = lens
    data.sensor_fit = 'VERTICAL'
    data.sensor_height = 24
    cam = bpy.data.objects.get(name) or bpy.data.objects.new(name, data)
    if collection and cam.name not in collection.objects:
        collection.objects.link(cam)
    y, p = math.radians(yaw), math.radians(pitch)
    offset = Vector((math.sin(y) * math.cos(p), -math.cos(y) * math.cos(p), math.sin(p)))
    cam.location = Vector(target) + offset * distance
    cam.rotation_euler = (Vector(target) - cam.location).to_track_quat('-Z', 'Y').to_euler()
    scene = bpy.context.scene
    scene.camera = cam
    scene.render.resolution_x, scene.render.resolution_y = res
    return cam


def render(path, samples=None):
    scene = bpy.context.scene
    if samples:
        scene.cycles.samples = samples
    scene.render.filepath = str(path)
    bpy.ops.render.render(write_still=True)
