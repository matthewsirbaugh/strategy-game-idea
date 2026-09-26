"""Installer-only baking and review; independent of the unfinished shared material pass."""
import json
import math
import struct
import sys
from pathlib import Path
import bpy
import numpy as np
from mathutils import Vector, Quaternion
from common import ROOT, box, mat, pivot, bounds, cylinder, sphere


def cloth_material(name, color, rough, grain=.065, variation=.10):
    material=mat(name,color,rough=rough)
    nt=material.node_tree
    bs=nt.nodes.get('Principled BSDF')
    coord=nt.nodes.new('ShaderNodeNewGeometry')
    noise=nt.nodes.new('ShaderNodeTexNoise')
    noise.inputs['Scale'].default_value=18
    noise.inputs['Detail'].default_value=2
    nt.links.new(coord.outputs['Position'],noise.inputs['Vector'])
    ramp=nt.nodes.new('ShaderNodeValToRGB')
    base=tuple(bs.inputs['Base Color'].default_value)
    for element,factor in zip(ramp.color_ramp.elements,[1-variation,1+variation]):
        element.color=(*(min(1,c*factor) for c in base[:3]),1)
    nt.links.new(noise.outputs['Fac'],ramp.inputs[0])
    ao=nt.nodes.new('ShaderNodeAmbientOcclusion')
    ao.inputs['Distance'].default_value=.035
    ao.samples=16
    soften=nt.nodes.new('ShaderNodeMath');soften.operation='MULTIPLY_ADD'
    soften.inputs[1].default_value=.22;soften.inputs[2].default_value=.78
    nt.links.new(ao.outputs['AO'],soften.inputs[0])
    shading=nt.nodes.new('ShaderNodeMixRGB');shading.blend_type='MULTIPLY';shading.inputs[0].default_value=1
    nt.links.new(ramp.outputs['Color'],shading.inputs[1]);nt.links.new(soften.outputs[0],shading.inputs[2])
    nt.links.new(shading.outputs[0],bs.inputs['Base Color'])
    if grain:
        weave=nt.nodes.new('ShaderNodeTexNoise')
        weave.inputs['Scale'].default_value=1100
        weave.inputs['Detail'].default_value=1
        nt.links.new(coord.outputs['Position'],weave.inputs['Vector'])
        bump=nt.nodes.new('ShaderNodeBump')
        bump.inputs['Strength'].default_value=grain
        bump.inputs['Distance'].default_value=.0004
        nt.links.new(weave.outputs['Fac'],bump.inputs['Height'])
        nt.links.new(bump.outputs[0],bs.inputs['Normal'])
    return material


def camera(target,distance,pitch,yaw,size=(1024,1024),fov=30):
    data=bpy.data.cameras.new('Review camera')
    data.sensor_fit='VERTICAL'
    data.angle_y=math.radians(fov)
    obj=bpy.data.objects.new('Review camera',data)
    bpy.context.collection.objects.link(obj)
    p,y=map(math.radians,(pitch,yaw))
    obj.location=Vector(target)+distance*Vector((math.sin(y)*math.cos(p),-math.cos(y)*math.cos(p),math.sin(p)))
    obj.rotation_euler=(Vector(target)-obj.location).to_track_quat('-Z','Y').to_euler()
    scene=bpy.context.scene
    scene.camera=obj
    scene.render.resolution_x,scene.render.resolution_y=size
    return obj


def render(path):
    scene=bpy.context.scene
    scene.render.filepath=str(path)
    scene.render.image_settings.file_format='JPEG'
    scene.render.image_settings.quality=94
    bpy.ops.render.render(write_still=True)


def game_review(name,out):
    reference=mat('reference','#A6B2B5',rough=.9)
    parts=[cylinder('1.7 m scale reference',(1.05,0,.85),.14,1.42,reference,20,bevel=0),
        sphere('Reference head',(1.05,0,1.56),(.14,.14,.14),reference,16,8),
        sphere('Reference feet',(1.05,0,.14),(.14,.14,.14),reference,16,8)]
    pixels=[]
    for distance,size in [(34,200),(12,600)]:
        fov=math.degrees(2*math.atan(math.tan(math.radians(15))*size/900))
        camera((.40,0,.82),distance,50,45,(size,size),fov)
        path=Path('/tmp')/f'{name}_tactics_{size}.jpg'
        render(path)
        image=bpy.data.images.load(str(path))
        values=np.empty(size*size*4,dtype=np.float32)
        image.pixels.foreach_get(values)
        values=values.reshape(size,size,4)
        pixels.append(values.repeat(3,axis=0).repeat(3,axis=1) if size==200 else values)
        bpy.data.images.remove(image)
    image=bpy.data.images.new('Tactics comparison',width=1200,height=600,alpha=False)
    image.pixels.foreach_set(np.concatenate(pixels,axis=1).ravel())
    image.file_format='JPEG'
    image.save(filepath=str(out/f'{name}_game.jpg'),quality=94)
    bpy.data.images.remove(image)
    for obj in parts:
        obj.hide_render=True


def bake_character(obj,name):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active=obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(65),island_margin=.006,area_weight=.8)
    bpy.ops.object.mode_set(mode='OBJECT')
    scene=bpy.context.scene
    scene.render.engine='CYCLES'
    scene.cycles.samples=8
    slots=list(obj.data.materials)
    originals={}
    targets={}
    for material in slots:
        if material in originals:
            continue
        nt=material.node_tree
        output=nt.nodes.get('Material Output')
        originals[material]=output.inputs['Surface'].links[0].from_socket
        target=nt.nodes.new('ShaderNodeTexImage')
        nt.nodes.active=target
        target.select=True
        targets[material]=target
    images={}
    for channel in ['albedo','normal','orm']:
        image=bpy.data.images.new(name+'_'+channel,width=2048,height=2048,alpha=False)
        if channel!='albedo':
            image.colorspace_settings.name='Non-Color'
        for material in originals:
            nt=material.node_tree
            targets[material].image=image
            nt.nodes.active=targets[material]
            output=nt.nodes.get('Material Output')
            bs=nt.nodes.get('Principled BSDF')
            if channel=='normal':
                nt.links.new(originals[material],output.inputs['Surface'])
                continue
            em=nt.nodes.new('ShaderNodeEmission')
            if channel=='albedo':
                socket=bs.inputs['Base Color']
                if socket.is_linked:
                    nt.links.new(socket.links[0].from_socket,em.inputs['Color'])
                else:
                    em.inputs['Color'].default_value=socket.default_value
            else:
                em.inputs['Color'].default_value=(1,bs.inputs['Roughness'].default_value,bs.inputs['Metallic'].default_value,1)
            nt.links.new(em.outputs[0],output.inputs['Surface'])
        bpy.ops.object.bake(type='NORMAL' if channel=='normal' else 'EMIT',margin=8,use_clear=True)
        image.pack()
        images[channel]=image
    for material in originals:
        nt=material.node_tree
        nt.links.new(originals[material],nt.nodes.get('Material Output').inputs['Surface'])
        nt.nodes.remove(targets[material])
    baked=mat(name+'_surface','#FFFFFF')
    nt=baked.node_tree
    bs=nt.nodes.get('Principled BSDF')
    for channel,img in images.items():
        node=nt.nodes.new('ShaderNodeTexImage')
        node.image=img
        if channel=='albedo':
            nt.links.new(node.outputs['Color'],bs.inputs['Base Color'])
        elif channel=='normal':
            normal=nt.nodes.new('ShaderNodeNormalMap')
            nt.links.new(node.outputs['Color'],normal.inputs['Color'])
            nt.links.new(normal.outputs[0],bs.inputs['Normal'])
        else:
            separate=nt.nodes.new('ShaderNodeSeparateColor')
            nt.links.new(node.outputs['Color'],separate.inputs[0])
            nt.links.new(separate.outputs['Green'],bs.inputs['Roughness'])
            nt.links.new(separate.outputs['Blue'],bs.inputs['Metallic'])
    keep=[baked]+[m for m in dict.fromkeys(slots) if m.name.startswith(('glass','status_','emissive_'))]
    indices=[keep.index(slots[p.material_index]) if slots[p.material_index] in keep else 0 for p in obj.data.polygons]
    obj.data.materials.clear()
    for material in keep:
        obj.data.materials.append(material)
    for p,index in zip(obj.data.polygons,indices):
        p.material_index=index


def finish_installer(rig,name,category):
    draft='--draft' in sys.argv
    out=Path('/tmp/installer-review') if draft else ROOT/'art/previews'
    out.mkdir(parents=True,exist_ok=True)
    obj=bpy.data.objects['Installer_skinned_mesh']
    collection=obj.users_collection[0]
    asset=list(collection.objects)
    root=pivot(name,(0,0,0),[o for o in asset if o.parent is None])
    root['front']='Blender -Y; glTF +Z'
    root['units']='metres'
    lo,hi=bounds(asset)
    if not draft:
        bake_character(obj,name)
        bpy.ops.object.select_all(action='DESELECT')
        for o in asset+[root]:
            o.select_set(True)
        bpy.context.view_layer.objects.active=root
        path=ROOT/f'game/art/{category}/{name}.glb'
        bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',use_selection=True,export_apply=True,
            export_yup=True,export_extras=True,export_animations=False,export_tangents=True,
            export_cameras=False,export_lights=False)
        raw=path.read_bytes()
        doc=json.loads(raw[20:20+struct.unpack_from('<I',raw,12)[0]])
        print('INSTALLER_EXPORT',json.dumps({'triangles':sum(doc['accessors'][p['indices']]['count']//3 for m in doc['meshes'] for p in m['primitives']),
            'bounds':[lo,hi],'materials':len(doc['materials']),'images':len(doc.get('images',[])),'bytes':len(raw)}))
    scene=bpy.context.scene
    preview=bpy.data.collections.new('PREVIEW_ONLY')
    scene.collection.children.link(preview)
    bpy.context.view_layer.active_layer_collection=bpy.context.view_layer.layer_collection.children[preview.name]
    box('Studio floor',(0,0,-.058),(2000,2000,.1),mat('studio','#343D42',rough=.88),0)
    scene.world.use_nodes=True
    bg=scene.world.node_tree.nodes['Background']
    bg.inputs[0].default_value=(.38,.46,.55,1)
    bg.inputs[1].default_value=.35
    for name_,loc,power,size,color in [('Key',(-3,-4,6),720,4,(1,.88,.74)),('Fill',(3,-2,4),460,4,(.70,.82,1)),('Rim',(2,4,5),900,3,(1,.79,.56))]:
        data=bpy.data.lights.new(name_,'AREA');data.energy=power;data.shape='DISK';data.size=size;data.color=color
        light=bpy.data.objects.new(name_,data);preview.objects.link(light);light.location=loc
        light.rotation_euler=(Vector((0,0,.9))-light.location).to_track_quat('-Z','Y').to_euler()
    scene.render.engine='CYCLES'
    scene.cycles.samples=16 if draft else 64
    scene.cycles.use_denoising=True
    scene.render.resolution_percentage=100
    scene.view_settings.view_transform='AgX'
    scene.view_settings.look='AgX - Medium High Contrast'
    camera((0,0,.87),4.35,18,-24)
    render(out/f'{name}_front.jpg')
    camera((0,0,.87),4.35,18,151)
    render(out/f'{name}_back.jpg')
    camera((0,-.035,1.49),1.30,16,-18,(1024,1024),24)
    render(out/f'{name}_detail.jpg')
    game_review(name,out)
    if draft:
        bpy.ops.wm.save_as_mainfile(filepath='/tmp/installer-review/draft.blend')
    else:
        camera((0,0,.87),4.35,18,-24)
        bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/f'art/source/{name}.blend'))
    mesh=obj.evaluated_get(bpy.context.evaluated_depsgraph_get()).to_mesh()
    mesh.calc_loop_triangles()
    print('INSTALLER_GEOMETRY',len(mesh.loop_triangles),'triangles')
    for side,sign in [('l',1),('r',-1)]:
        bone=rig.pose.bones['upperarm_'+side]
        bone.rotation_mode='QUATERNION'
        axis=bone.bone.matrix_local.to_3x3().inverted()@Vector((0,1,0))
        bone.rotation_quaternion=Quaternion(axis,math.radians(sign*25))
        bone=rig.pose.bones['lowerarm_'+side]
        bone.rotation_mode='QUATERNION'
        axis=bone.bone.matrix_local.to_3x3().inverted()@Vector((1,0,0))
        bone.rotation_quaternion=Quaternion(axis,math.radians(-12))
    bpy.context.view_layer.update()
    camera((0,0,.87),4.35,18,-24)
    render(out/f'{name}_pose.jpg')
    for bone in rig.pose.bones:
        bone.matrix_basis.identity()
    print('INSTALLER_REVIEW_COMPLETE',out)
