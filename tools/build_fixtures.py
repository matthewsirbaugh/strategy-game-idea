# Builds the pole-mounted fixtures and the barrier gate from Meshy heads plus parts made here,
# since AI 3D tools turn long thin poles and arms into lumpy ones.
# Run: blender -b --python tools/build_fixtures.py   (from the project root)
import bpy
from mathutils import Vector

ASSETS = "game/assets/"

# Mount points measured on the prepared heads (metres, Blender axes, Z up).
FIXTURES = {
    # id: (head asset, pole height, pole radius, head offset from the pole's axis at its foot)
    "pole_light": ("props/pole_light_head", 5.0, 0.06, Vector((0.25, 0.0, 5.0))),
    "camera_pole": ("devices/camera_head", 3.35, 0.06, Vector((-0.359, 0.0, 3.0))),
    "night_vision_camera_pole": ("devices/night_vision_camera", 3.35, 0.06, Vector((-0.359, 0.0, 3.0))),
    "scanner_pole": ("devices/scanner_head", 3.2, 0.05, Vector((0.0, -0.134, 2.8))),
}


def material(name, color, metallic=0.6, roughness=0.35):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return m


def box(size, location, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    o = bpy.context.object
    o.scale = size
    bpy.ops.object.transform_apply(scale=True)
    o.data.materials.append(mat)
    return o


def pole(height, radius, mat):
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=radius, depth=height, location=(0, 0, height / 2))
    p = bpy.context.object
    p.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return [p, box((0.3, 0.3, 0.02), (0, 0, 0.01), mat), box((radius * 2.2, radius * 2.2, 0.03), (0, 0, height + 0.015), mat)]


def head(asset, offset, path=None):
    bpy.ops.import_scene.gltf(filepath=path or ASSETS + asset + "/" + asset.split("/")[1] + ".glb")
    parts = [o for o in bpy.context.selected_objects if o.type == "MESH"]
    for o in bpy.context.selected_objects:
        if o.parent is None:
            o.location += offset
    return parts


def export(category, name, objects):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    path = ASSETS + category + "/" + name + "/" + name + ".glb"
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True)
    o = bpy.context.object
    tris = sum(len(p.vertices) - 2 for p in o.data.polygons)
    print("BUILT %s: %d triangles, %.2f m tall" % (path, tris, max((o.matrix_world @ Vector(c)).z for c in o.bound_box)))


import os
for name, (asset, height, radius, offset) in FIXTURES.items():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    black = material("anodized_black", (0.02, 0.02, 0.022))
    category = "props" if name == "pole_light" else "devices"
    os.makedirs(ASSETS + category + "/" + name, exist_ok=True)
    export(category, name, head(asset, offset) + pole(height, radius, black))

# The barrier: the housing, and a 4 m arm swung out from its hub on the +X face, along +Y.
bpy.ops.wm.read_factory_settings(use_empty=True)
white = material("arm_white", (0.85, 0.85, 0.84), 0.0, 0.4)
red = material("arm_red", (0.6, 0.02, 0.02), 0.0, 0.4)
objects = head("props/barrier_housing", Vector((0, 0, 0)))
objects.append(box((0.05, 4.0, 0.09), (0.19, 2.02, 0.86), white))
for i in range(4):
    objects.append(box((0.052, 0.3, 0.092), (0.19, 0.6 + i * 1.0, 0.86), red))
os.makedirs(ASSETS + "props/barrier_gate", exist_ok=True)
export("props", "barrier_gate", objects)

# The OpenBrain emblem on both flanks of the fleet vehicles, from the reference logo, white made clear.
# The vehicles' prepared models (prep_prop.py output) live in their sources folders.
import numpy as np
logo = bpy.data.images.load(os.path.abspath("art/reference/openbrain-logo-white.png"))
px = np.empty(logo.size[0] * logo.size[1] * 4, dtype=np.float32)
logo.pixels.foreach_get(px)
px = px.reshape(-1, 4)
px[:, 3] = 1.0 - px[:, :3].mean(axis=1)
px[:, :3] = 0.02
EMBLEM = px.ravel().copy()
LOGO_SIZE = logo.size[:]

for name, size, height in (("fleet_car", 0.22, 0.72), ("service_van", 0.55, 1.35)):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    image = bpy.data.images.new("openbrain_emblem", *LOGO_SIZE, alpha=True)
    image.pixels.foreach_set(EMBLEM)
    image.pack()
    m = bpy.data.materials.new("emblem")
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    tex = m.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = image
    m.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    m.node_tree.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    bsdf.inputs["Roughness"].default_value = 0.4
    # Read from the prepared model kept in sources, so rebuilding never stacks emblems.
    objects = head(None, Vector((0, 0, 0)), "art/sources/devices/%s/prepared.glb" % name)
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for side in (-1, 1):
        hit, at, normal, *_ = bpy.context.scene.ray_cast(depsgraph, Vector((0, side * 5, height)), Vector((0, -side, 0)))
        if not hit:
            print("NO SURFACE for", name, side)
            continue
        bpy.ops.mesh.primitive_plane_add(size=size, location=at + normal * 0.004)
        plane = bpy.context.object
        plane.rotation_euler = normal.to_track_quat("Z", "Y").to_euler()
        plane.data.materials.append(m)
        objects.append(plane)
    export("devices", name, objects)
