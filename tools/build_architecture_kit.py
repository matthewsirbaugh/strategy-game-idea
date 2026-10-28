# Builds the architecture kit's pieces to the 1.5 m grid and exports each as an asset.
# Run: blender -b --python tools/build_architecture_kit.py   (from the project root)
# Blender axes: a piece's outside faces -Y (glTF +Z), bays run along X, Z is up.
import json
import math
import os

import bpy

ASSETS = "game/assets/architecture/"
CELL = 1.5
STOREY = 4.5
WALL = 0.3          # wall thickness, centred on the tile edge
BAND = 0.5          # the floor-edge band at the top of every storey
STAIR_RISE = 2.25   # one flight climbs half a storey
BRIEF = "art/briefs/architecture-slice-look.md"


def material(name, color, metallic=0.0, roughness=0.5, alpha=1.0, emission=None):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if alpha < 1:
        bsdf.inputs["Alpha"].default_value = alpha
        m.blend_method = "BLEND"
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1)
        bsdf.inputs["Emission Strength"].default_value = 4.0
    return m


MAT = {}


def make_materials():
    MAT["white"] = material("white_panel", (0.82, 0.83, 0.82), roughness=0.45)
    MAT["seam"] = material("panel_seam", (0.12, 0.12, 0.13), roughness=0.6)
    MAT["frame"] = material("black_frame", (0.025, 0.025, 0.03), metallic=0.6, roughness=0.35)
    MAT["glass"] = material("glass", (0.08, 0.1, 0.12), roughness=0.04, alpha=0.3)
    MAT["steel"] = material("dark_steel", (0.16, 0.17, 0.18), metallic=0.8, roughness=0.45)
    MAT["stone"] = material("stone", (0.56, 0.55, 0.52), roughness=0.6)
    MAT["light"] = material("warm_light", (1.0, 0.85, 0.65), emission=(1.0, 0.8, 0.58))
    MAT["red"] = material("accent_red", (0.55, 0.03, 0.03), roughness=0.4)
    MAT["tread"] = material("tread", (0.36, 0.36, 0.35), metallic=0.5, roughness=0.6)
    MAT["emblem"] = material("emblem", (0.03, 0.03, 0.03), roughness=0.35)
    MAT["beacon"] = material("beacon_red", (1.0, 0.1, 0.08), emission=(1.0, 0.06, 0.04))


def clear():
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o)


def box(x0, x1, y0, y1, z0, z1, mat, bevel=0.01):
    bpy.ops.mesh.primitive_cube_add(size=1, location=((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))
    o = bpy.context.object
    o.scale = (x1 - x0, y1 - y0, z1 - z0)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(MAT[mat])
    if bevel and min(x1 - x0, y1 - y0, z1 - z0) > bevel * 3:
        mod = o.modifiers.new("bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    return o


def beam(a, b, size, mat):
    # A square bar from point a to point b, for sloped stringers, rails and bracing.
    ax, ay, az = a
    bx, by, bz = b
    length = math.dist(a, b)
    bpy.ops.mesh.primitive_cube_add(size=1, location=((ax + bx) / 2, (ay + by) / 2, (az + bz) / 2))
    o = bpy.context.object
    o.scale = (size, size, length)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    direction = (bx - ax, by - ay, bz - az)
    o.rotation_mode = "QUATERNION"
    from mathutils import Vector
    o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(Vector(direction).normalized())
    o.data.materials.append(MAT[mat])
    return o


# Wall bays: 1.5 wide, one storey tall, centred on the tile edge.
H = CELL / 2
T = WALL / 2


def band():
    # Proud of the face so each storey's floor edge reads from above.
    box(-H, H, -T - 0.04, T, STOREY - BAND, STOREY, "white")


def half_mullions(z0, z1, depth=0.12):
    for x in (-H, H - 0.06):
        box(x, x + 0.06, -T - 0.02, -T + depth, z0, z1, "frame", bevel=0)


def wall_panel():
    box(-H, H, -T, T, 0, STOREY - BAND, "white")
    band()
    # Seams wide enough to read from the battle camera, about a pixel at the default zoom.
    for z in (1.33, 2.67):
        box(-H, H, -T - 0.004, -T + 0.01, z - 0.015, z + 0.015, "seam", bevel=0)
    for x in (-H, H - 0.015):
        box(x, x + 0.015, -T - 0.004, -T + 0.01, 0, STOREY - BAND, "seam", bevel=0)


def glazing(z0, z1, transom=None):
    half_mullions(z0, z1)
    box(-H, H, -T - 0.02, T, z0, z0 + 0.1, "frame", bevel=0)
    box(-H, H, -T - 0.02, -T + 0.12, z1 - 0.08, z1, "frame", bevel=0)
    if transom:
        box(-H, H, -T - 0.02, -T + 0.12, transom - 0.04, transom + 0.04, "frame", bevel=0)
    box(-H + 0.06, H - 0.06, -0.01, 0.01, z0 + 0.1, z1 - 0.08, "glass", bevel=0)


def wall_glass():
    glazing(0, STOREY - BAND, transom=3.2)
    band()


def wall_door():
    glazing(0, STOREY - BAND, transom=2.7)
    for x in (-0.5, 0.46):
        box(x, x + 0.04, -T - 0.03, -T + 0.12, 0, 2.7, "frame", bevel=0)
    box(0.55, 0.65, -T - 0.06, -T - 0.02, 1.2, 1.4, "frame", bevel=0)  # access reader
    band()


def wall_ribbon():
    # White panel with a long horizontal window: the upper floor's glazed band.
    box(-H, H, -T, T, 0, 1.0, "white")
    box(-H, H, -T, T, 2.6, STOREY - BAND, "white")
    glazing(1.0, 2.6)
    band()


def wall_header():
    # Only the floor-edge band, over an opening such as the skybridge's.
    band()


def accent_band():
    # OpenBrain's red line under the first floor's band. Long enough to meet its neighbour round a
    # corner post.
    reach = H + T + 0.05
    box(-reach, reach, -T - 0.05, -T, STOREY - BAND - 0.1, STOREY - BAND - 0.02, "red", bevel=0)


def emblem():
    # OpenBrain's emblem, 1.8 m across, on a panel bay's upper half; Godot cuts the logo out of it.
    bpy.ops.mesh.primitive_plane_add(size=1.8, location=(0, -T - 0.006, 2.9), rotation=(math.pi / 2, 0, 0))
    bpy.context.object.data.materials.append(MAT["emblem"])


def beacon():
    # An aviation light on the roof's corner, on top of the parapet's cap.
    box(-0.03, 0.03, -0.03, 0.03, 0, 0.18, "frame", bevel=0)
    box(-0.06, 0.06, -0.06, 0.06, 0.18, 0.3, "beacon", bevel=0)


def corner_post():
    box(-T, T, -T, T, 0, STOREY - BAND, "white")
    box(-T - 0.04, T + 0.04, -T - 0.04, T + 0.04, STOREY - BAND, STOREY, "white")


def floor_slab():
    box(-H, H, -H, H, 0, 0.3, "stone", bevel=0.015)


def parapet():
    box(-H, H, -T, T, 0, 0.5, "white")
    box(-H, H, -0.01, 0.01, 0.5, 1.05, "glass", bevel=0)
    box(-H, H, -0.03, 0.03, 1.05, 1.1, "frame", bevel=0)
    for x in (-H, H - 0.03):
        box(x, x + 0.03, -0.03, 0.03, 0.5, 1.05, "frame", bevel=0)


def stair_flight():
    # Climbs toward +Y (away from the outside face): ten steps over two tiles.
    steps, run = 10, 2 * CELL
    rise, going = STAIR_RISE / steps, run / steps
    y0 = -run / 2
    for i in range(steps):
        z = (i + 1) * rise
        box(-H + 0.08, H - 0.08, y0 + i * going, y0 + (i + 1) * going, z - 0.04, z, "tread", bevel=0)
    for x in (-H + 0.04, H - 0.04):
        beam((x, y0, 0.0), (x, y0 + run, STAIR_RISE), 0.08, "steel")
        beam((x, y0, 1.0), (x, y0 + run, STAIR_RISE + 1.0), 0.04, "frame")
        for i in range(0, steps + 1, 2):
            beam((x, y0 + i * going, i * rise), (x, y0 + i * going, i * rise + 1.0), 0.025, "frame")


def stair_landing():
    box(-H, H, -H, H, 0, 0.1, "tread", bevel=0)


def stair_rail():
    # A landing's guard rail along one edge, on its outside face.
    for x in (-H + 0.02, H - 0.02):
        beam((x, -H + 0.02, 0.1), (x, -H + 0.02, 1.1), 0.03, "frame")
    beam((-H, -H + 0.02, 1.1), (H, -H + 0.02, 1.1), 0.04, "frame")
    beam((-H, -H + 0.02, 0.6), (H, -H + 0.02, 0.6), 0.02, "frame")


def steel_post():
    box(-0.06, 0.06, -0.06, 0.06, 0, STAIR_RISE, "steel", bevel=0)


def skybridge_span():
    # One 1.5 m length of an enclosed bridge, 3 m wide, running along Y.
    w = CELL
    box(-w, w, -H, H, 0, 0.3, "white")
    box(-w, w, -H, H, STOREY - 0.3, STOREY, "white")
    box(-w + 0.2, w - 0.2, -H, H, 0.3, 0.32, "stone", bevel=0)
    for x in (-0.7, 0.7):
        box(x - 0.06, x + 0.06, -H, H, STOREY - 0.34, STOREY - 0.3, "light", bevel=0)
    for x in (-w + 0.03, w - 0.03):
        box(x - 0.01, x + 0.01, -H, H, 0.3, STOREY - 0.3, "glass", bevel=0)
        for y in (-H, H - 0.1):
            box(x - 0.07, x + 0.07, y, y + 0.1, 0.3, STOREY - 0.3, "frame", bevel=0)
        box(x - 0.05, x + 0.05, -H, H, STOREY / 2 - 0.03, STOREY / 2 + 0.03, "frame", bevel=0)
        beam((x, -H, 0.35), (x, H, STOREY - 0.35), 0.07, "steel")
        beam((x, H, 0.35), (x, -H, STOREY - 0.35), 0.07, "steel")


PIECES = {
    # id: (builder, name, description)
    "wall_panel": (wall_panel, "Wall: white panel bay", "A 1.5 m bay of matte white composite panels, one storey tall"),
    "wall_glass": (wall_glass, "Wall: glass bay", "A 1.5 m black-framed glass curtain-wall bay, one storey tall"),
    "wall_door": (wall_door, "Wall: glass door bay", "A glass bay with a door and an access reader"),
    "wall_ribbon": (wall_ribbon, "Wall: ribbon window bay", "A white panel bay with a long horizontal window"),
    "wall_header": (wall_header, "Wall: header over an opening", "Only the floor-edge band, spanning an opening"),
    "accent_band": (accent_band, "Red accent band", "OpenBrain's red line under the first floor's band, one bay long"),
    "emblem": (emblem, "OpenBrain emblem", "OpenBrain's emblem, 1.8 m across, for a white panel bay"),
    "beacon": (beacon, "Roof beacon", "A red aviation light on a short post, for the roof's corners"),
    "corner_post": (corner_post, "Corner post", "Fills the corner where two wall bays meet"),
    "floor_slab": (floor_slab, "Floor slab", "A 1.5 m square floor or roof slab, 0.3 m thick"),
    "parapet": (parapet, "Parapet with glass railing", "A roof edge 1.1 m tall: white upstand, glass railing, black cap"),
    "stair_flight": (stair_flight, "Stair flight", "A steel flight climbing half a storey over two tiles"),
    "stair_landing": (stair_landing, "Stair landing", "A 1.5 m square steel landing"),
    "stair_rail": (stair_rail, "Stair rail", "A landing's 1.1 m guard rail along one edge"),
    "steel_post": (steel_post, "Steel post", "A post holding a landing up, half a storey tall"),
    "skybridge_span": (skybridge_span, "Skybridge span", "A 1.5 m length of an enclosed glass skybridge, 3 m wide"),
}


def export(piece_id):
    builder, name, description = PIECES[piece_id]
    clear()
    builder()
    for o in bpy.data.objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = bpy.data.objects[0]
    bpy.ops.object.convert(target="MESH")
    bpy.ops.object.join()
    bpy.context.object.name = piece_id
    folder = ASSETS + piece_id + "/"
    os.makedirs(folder, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=folder + piece_id + ".glb", export_format="GLB", export_apply=True)
    height = max((bpy.context.object.matrix_world @ v.co).z for v in bpy.context.object.data.vertices)
    record = {
        "spec": 1, "id": piece_id, "name": name, "category": "architecture", "status": "proof",
        "model": piece_id + ".glb", "height_m": round(height, 3), "fit_to_height": False, "device": None,
        "description": description + ", for the architecture slice.",
        "brief": BRIEF,
        "sources": "art/sources/architecture/slice/",
        "made_with": {"tool": "blender", "settings": "tools/build_architecture_kit.py", "date": "2026-10-28"},
        "animations": [], "notes": "Look pass against the Request 31 picks; surfaces finish in Godot's kit shaders.",
    }
    with open(folder + piece_id + ".json", "w") as f:
        json.dump(record, f, indent=2)
        f.write("\n")


make_materials()
for piece in PIECES:
    export(piece)
print("built", len(PIECES), "pieces")
