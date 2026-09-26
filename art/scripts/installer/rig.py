"""Skinning every part to the MakeHuman game skeleton, and the preview pose."""
import math
import bpy
from mathutils import Matrix, Vector


def transfer_weights(source, target):
    ctx = bpy.context
    for o in ctx.selected_objects:
        o.select_set(False)
    source.select_set(True)
    target.select_set(True)
    ctx.view_layer.objects.active = source
    bpy.ops.object.data_transfer(use_reverse_transfer=False, data_type='VGROUP_WEIGHTS', vert_mapping='POLYINTERP_NEAREST',
                                 layers_select_src='ALL', layers_select_dst='NAME', mix_mode='REPLACE')
    source.select_set(False)
    target.select_set(False)


def clean_groups(obj, bones, limit=4):
    for vg in list(obj.vertex_groups):
        if vg.name not in bones:
            obj.vertex_groups.remove(vg)
    groups = list(obj.vertex_groups)
    for v in obj.data.vertices:
        # copy out first: removing a group invalidates the vertex's element references
        gs = sorted(((g.group, g.weight) for g in v.groups), key=lambda gw: gw[1], reverse=True)
        keep = [(gi, w) for gi, w in gs[:limit] if w > .01]
        for gi, w in gs:
            if (gi, w) not in keep:
                groups[gi].remove([v.index])
        total = sum(w for _, w in keep)
        if total > 0:
            for gi, w in keep:
                groups[gi].add([v.index], w / total, 'REPLACE')


def bind_rigid(obj, bone):
    vg = obj.vertex_groups.get(bone) or obj.vertex_groups.new(name=bone)
    vg.add(list(range(len(obj.data.vertices))), 1.0, 'REPLACE')


def attach(obj, rig):
    mw = obj.matrix_world.copy()
    obj.parent = rig
    obj.matrix_world = mw
    arm = next((m for m in obj.modifiers if m.type == 'ARMATURE'), None) or obj.modifiers.new('rig', 'ARMATURE')
    arm.object = rig
    if obj.modifiers[0] != arm:
        # deform first, then add thickness
        with bpy.context.temp_override(object=obj, active_object=obj):
            bpy.ops.object.modifier_move_to_index(modifier=arm.name, index=0)


def rotate_world(rig, bone, axis, degrees):
    pb = rig.pose.bones[bone]
    head = pb.head.copy()
    r = Matrix.Translation(head) @ Matrix.Rotation(math.radians(degrees), 4, Vector(axis)) @ Matrix.Translation(-head)
    pb.matrix = r @ pb.matrix
    bpy.context.view_layer.update()


def relaxed_pose(rig):
    """Arms hanging close to the body, a slightly wider stance: the concept sheet's standing pose."""
    for pb in rig.pose.bones:
        pb.rotation_mode = 'QUATERNION'
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.location = (0, 0, 0)
    bpy.context.view_layer.update()
    rotate_world(rig, 'upperarm_l', (0, 1, 0), 34)
    rotate_world(rig, 'upperarm_r', (0, 1, 0), -34)
    rotate_world(rig, 'upperarm_l', (1, 0, 0), -6)
    rotate_world(rig, 'upperarm_r', (1, 0, 0), -6)
    rotate_world(rig, 'lowerarm_l', (0, 1, 0), 8)
    rotate_world(rig, 'lowerarm_r', (0, 1, 0), -8)
    rotate_world(rig, 'thigh_l', (0, 1, 0), -3.5)
    rotate_world(rig, 'thigh_r', (0, 1, 0), 3.5)
    rotate_world(rig, 'foot_l', (0, 1, 0), 3.5)
    rotate_world(rig, 'foot_r', (0, 1, 0), -3.5)
    rotate_world(rig, 'head', (0, 0, 1), -6)
