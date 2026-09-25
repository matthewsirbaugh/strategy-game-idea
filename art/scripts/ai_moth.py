import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *
import numpy as np

FORE=[(.025,-.03),(.058,-.095),(.145,-.148),(.216,-.133),(.225,-.105),(.208,-.108),(.181,-.031),(.119,.025),(.032,.039)]
HIND=[(.025,.018),(.117,.011),(.169,.046),(.157,.100),(.112,.134),(.073,.125),(.031,.080)]


def rounded(points):
    pts=[Vector(p) for p in points]
    out=[]
    for i,b in enumerate(pts):
        a,c,d=pts[i-1],pts[(i+1)%len(pts)],pts[(i+2)%len(pts)]
        for j in range(4):
            t=j/4
            out.append(tuple(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)))
    return out


def wing_texture():
    n=1024
    x,y=np.meshgrid(np.linspace(-.25,.25,n),np.linspace(-.18,.18,n))
    u=np.abs(x)*47+np.sin(y*30)*.18
    v=y*47+np.abs(x)*4
    gx=np.minimum(u%1,1-u%1)
    gy=np.minimum(v%1,1-v%1)
    cell=(gx<.028)|(gy<.026)
    base=np.array(linear('solar'))
    gold=np.array(linear('gold'))
    cream=np.array(linear('cream'))
    rgb=np.broadcast_to(base,(n,n,3)).copy()
    rgb*= (1+np.sin(np.floor(u)*3+np.floor(v)*2)[...,None]*.16)
    rgb[cell]=gold*.8
    root=np.exp(-(x*x+(y+.025)**2)/.0016)
    rgb=rgb*(1-root[...,None]*.65)+gold*root[...,None]*.65
    r=np.sqrt((np.abs(x)-.11)**2+(y-.079)**2)
    a=np.arctan2(y-.079,np.abs(x)-.11)
    rays=(r>.020)&(r<.033)&(np.cos(a*12)>.58)
    rgb[rays]=cream
    rgb[(r>.017)&(r<.022)]=cream
    rgb[r<.016]=np.array(linear('amber'))
    rgb[r<.006]=gold*.6
    dist=np.full((n,n),10.0)
    mask=np.zeros((n,n),dtype=bool)
    for shape in [rounded(FORE),rounded(HIND)]:
        for s in [-1,1]:
            poly=[(s*a,b) for a,b in shape]
            inside=np.zeros_like(mask)
            for i,(ax,ay) in enumerate(poly):
                bx,by=poly[(i+1)%len(poly)]
                inside^=((ay>y)!=(by>y))&(x<(bx-ax)*(y-ay)/(by-ay+1e-12)+ax)
                t=np.clip(((x-ax)*(bx-ax)+(y-ay)*(by-ay))/((bx-ax)**2+(by-ay)**2),0,1)
                dist=np.minimum(dist,np.sqrt((x-ax-t*(bx-ax))**2+(y-ay-t*(by-ay))**2))
            mask|=inside
    edge=(dist<.005)&mask
    rgb[edge]=rgb[edge]*.35+gold*.65
    alpha=np.clip(dist/.004,0,1)*mask*.95
    pixels=np.concatenate([rgb,alpha[...,None]],axis=-1).astype(np.float32)
    image=bpy.data.images.new('Moth photovoltaic wing atlas',width=n,height=n,alpha=True)
    image.pixels.foreach_set(pixels.ravel())
    out=ROOT/'art/textures/ai_moth_wings.png'
    out.parent.mkdir(exist_ok=True)
    image.filepath_raw=str(out)
    image.file_format='PNG'
    image.save()
    image.pack()
    m=mat('hologram_wing','solar',rough=.42)
    m.surface_render_method='DITHERED'
    nodes=m.node_tree.nodes
    bs=nodes.get('Principled BSDF')
    tex=nodes.new('ShaderNodeTexImage')
    tex.image=image
    m.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
    m.node_tree.links.new(tex.outputs['Alpha'],bs.inputs['Alpha'])
    m.node_tree.links.new(tex.outputs['Color'],bs.inputs['Emission Color'])
    bs.inputs['Emission Strength'].default_value=.35
    return m


def build():
    start('ai_moth')
    groups={}
    bodymat=mat('hologram_body','cream',rough=.7,emission=.12)
    groups['body']=[sphere('Thorax',(0,-.02,.08),(.026,.034,.025),bodymat,20,12),
        sphere('Head',(0,-.061,.081),(.023,.023,.021),bodymat,20,12)]
    groups['abdomen']=[sphere('Amber abdomen',(0,.042,.073),(.024,.063,.023),mat('hologram_abdomen','amber',rough=.6,emission=.10),20,12)]
    for s in [-1,1]:
        groups['body'].append(sphere('Indigo compound eye',(s*.019,-.074,.086),(.013,.012,.014),mat('hologram_eye','#1C1F3A',rough=.23),16,10))
        groups['body'].append(sphere('Eye glint',(s*.022,-.083,.095),(.0035,.002,.003),mat('hologram_glint','cream',emission=.5),10,6))
    for i in range(24):
        a=i*math.tau/24
        base=(math.sin(a)*.022,-.037, .081+math.cos(a)*.021)
        tip=(math.sin(a)*.033,-.022,.081+math.cos(a)*.032)
        groups['body'].append(leaf('Fluffy ruff',base,tip,.009,bodymat))
    wingmat=wing_texture()
    for s,side in [(-1,'r'),(1,'l')]:
        for kind,shape in [('fore',FORE),('hind',HIND)]:
            outline=rounded(shape)
            points=[(s*x,y,.078 if kind=='fore' else .075) for x,y in outline]
            center=tuple(sum(p[j] for p in points)/len(points) for j in range(3))
            points=[center]+points
            faces=[(0,i+1,(i+1)%len(outline)+1) for i in range(len(outline))]
            if s<0:
                faces=[tuple(reversed(f)) for f in faces]
            o=mesh(kind+'wing_'+side,points,faces,wingmat)
            uv=o.data.uv_layers.new(name='wing_atlas')
            for loop in o.data.loops:
                co=o.data.vertices[loop.vertex_index].co
                uv.data[loop.index].uv=((co.x+.25)/.5,(co.y+.18)/.36)
            groups[kind+'_'+side]=[o]
        feather=[]
        p0=(s*.013,-.074,.097)
        p1=(s*.048,-.119,.117)
        feather.append(tube('Antenna stem',[p0,(s*.04,-.10,.12),p1],.0019,'gold',3,1))
        for i in range(8):
            t=(i+1)/9
            mid=Vector(p0).lerp(Vector(p1),t)
            w=math.sin(t*math.pi)*.014
            for direction in [-1,1]:
                feather.append(leaf('Feathered antenna',mid,mid+Vector((s*w*direction,-.013,.003)),.004,'gold'))
        groups['antenna_'+side]=feather
        for i in range(3):
            groups['body'].append(tube('Tucked leg',[(s*.019,-.025+i*.013,.067),(s*.032,-.02+i*.015,.05),(s*.025,-.009+i*.014,.044)],.0016,'gold',2,0))
    groups['probe']=[sphere('Deploying sensor spore',(0,.075,.052),(.006,.01,.006),mat('hologram_probe','amber',emission=.6),12,6)]
    data=bpy.data.armatures.new('Moth skeleton')
    rig=bpy.data.objects.new('MothRig',data)
    bpy.context.collection.objects.link(rig)
    bpy.context.view_layer.objects.active=rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    for name in groups:
        b=data.edit_bones.new(name)
        if name=='body':
            b.head=(0,0,.08);b.tail=(0,-.05,.08)
        elif name=='abdomen':
            b.head=(0,.012,.075);b.tail=(0,.084,.075)
        elif name=='probe':
            b.head=(0,.075,.052);b.tail=(0,.075,.03)
        else:
            s=1 if name.endswith('_l') else -1
            b.head=(s*.022,-.022,.078)
            b.tail=(s*.022,-.10,.078)
        if name!='body':
            b.parent=data.edit_bones['body']
    bpy.ops.object.mode_set(mode='OBJECT')
    for name,objects in groups.items():
        for o in objects:
            if o.type=='CURVE':
                bpy.ops.object.select_all(action='DESELECT')
                o.select_set(True)
                bpy.context.view_layer.objects.active=o
                bpy.ops.object.convert(target='MESH')
            g=o.vertex_groups.new(name=name)
            g.add(list(range(len(o.data.vertices))),1,'REPLACE')
            mod=o.modifiers.new('Moth skin','ARMATURE');mod.object=rig
            parent_keep(o,rig)
    return rig


def animate(rig):
    rig.animation_data_create()
    for name,length in [('hover_idle',40),('fly',24),('scan',48),('deploy_probe',36),('strain',24)]:
        rig.animation_data.action=None
        for f in range(1,length+1):
            t=(f-1)/(length-1)
            for b in rig.pose.bones:
                b.rotation_mode='XYZ';b.rotation_euler=(0,0,0);b.location=(0,0,0)
            beats=2 if name=='hover_idle' else 5
            flap=math.sin(t*math.tau*beats)
            flap=math.copysign(abs(flap)**.7,flap)
            if name=='scan':flap=.05*math.sin(t*math.tau)
            for side,s in [('l',1),('r',-1)]:
                rig.pose.bones['fore_'+side].rotation_euler.y=s*(.15+flap*.36)
                rig.pose.bones['hind_'+side].rotation_euler.y=s*(.10+flap*.28)
                rig.pose.bones['antenna_'+side].rotation_euler.z=s*math.sin(t*math.tau)*.09
            body=rig.pose.bones['body']
            body.location.z=.007*math.sin(t*math.tau)
            if name=='fly':body.rotation_euler.x=.18
            if name=='strain':
                body.location.x=.003*math.sin(t*math.tau*9)
                body.rotation_euler.z=.07*math.sin(t*math.tau*7)
            if name=='deploy_probe':
                rig.pose.bones['abdomen'].rotation_euler.x=.5*math.sin(t*math.pi)**2
                rig.pose.bones['probe'].location.y=.065*max(0,t-.45)
            for b in rig.pose.bones:
                b.keyframe_insert(data_path='rotation_euler',frame=f)
                b.keyframe_insert(data_path='location',frame=f)
        a=rig.animation_data.action;a.name=name
        track=rig.animation_data.nla_tracks.new();track.name=name
        track.strips.new(name,1,a);track.mute=True
        rig.animation_data.action=None
    for b in rig.pose.bones:
        b.rotation_euler=(0,0,0);b.location=(0,0,0)
    bpy.context.scene.frame_set(1)


if __name__=='__main__':
    rig=build()
    animate(rig)
    finish('ai_moth','characters','One 1024×1024 RGBA wing atlas. Eight-bone rig, five clips. scan opens the wings; the travelling cell-light sweep remains a game shader hook. Place root ~1.82 m high for a 1.9 m hover center.',front_pitch=58,front_yaw=15)
