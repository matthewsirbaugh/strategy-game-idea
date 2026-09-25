import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *
from mathutils import Matrix
import bmesh
import prop_backpack_rig
import prop_rivet_driver

start('char_installer')
with bpy.data.libraries.load(str(ROOT/'art/vendor/installer_base.blend'),link=False) as (src,dst):
    dst.objects=['Installer_CC0_base','Installer_skeleton']
for obj in dst.objects:
    bpy.context.collection.objects.link(obj)
base=bpy.data.objects['Installer_CC0_base']
rig=bpy.data.objects['Installer_skeleton']
anchors=json.loads(base['anchors'])


def head_shape(co):
    p=Vector(co)
    if p.z>1.43:
        p=Vector((p.x*1.07,p.y*1.07,1.43+(p.z-1.43)*1.07))
    p.z+=.011
    return p


for v in base.data.vertices:
    v.co=head_shape(v.co)
base.data.update()
anchors={n:head_shape(v) for n,v in anchors.items()}
skin=mat('skin','#9B654A',rough=.62)
canvas=mat('ochre_canvas','ochre',rough=.88)
trousers=mat('work_trousers','#343940',rough=.85)
leather=mat('tan_leather','#AD865A',rough=.68)
hair=mat('hair','#1D2024',rough=.68)


def bind(obj, bone):
    if obj.type=='CURVE':
        bpy.ops.object.select_all(action='DESELECT');obj.select_set(True)
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.convert(target='MESH')
    if obj.type=='MESH':
        group=obj.vertex_groups.new(name=bone)
        group.add(list(range(len(obj.data.vertices))),1,'REPLACE')
        mod=obj.modifiers.new('Installer skin','ARMATURE');mod.object=rig
    parent_keep(obj,rig)
    return obj


def surface(name, predicate, material, offset=0, ratio=1):
    data=base.data
    polys=[p for p in data.polygons if predicate(p.center)]
    used=sorted({i for p in polys for i in p.vertices})
    remap={old:new for new,old in enumerate(used)}
    verts=[data.vertices[i].co+data.vertices[i].normal*offset for i in used]
    obj=mesh(name,verts,[tuple(remap[i] for i in p.vertices) for p in polys],material,True)
    if data.uv_layers.active:
        uv=obj.data.uv_layers.new(name='MakeHuman_UV')
        for old,new in zip(polys,obj.data.polygons):
            for a,b in zip(old.loop_indices,new.loop_indices):
                uv.data[b].uv=data.uv_layers.active.data[a].uv
    mapping={g.index:obj.vertex_groups.new(name=g.name) for g in base.vertex_groups if g.name in rig.data.bones}
    for new,old in enumerate(used):
        for w in data.vertices[old].groups:
            if w.group in mapping:
                mapping[w.group].add([new],w.weight,'REPLACE')
    bm=bmesh.new();bm.from_mesh(obj.data)
    boundary=[v for v in bm.verts if v.is_boundary]
    for _ in range(3):
        bmesh.ops.smooth_vert(bm,verts=boundary,factor=.65,use_axis_x=True,use_axis_y=True,use_axis_z=True)
    if name=='Open canvas jacket':
        for v in bm.verts:
            if abs(v.co.x)<.21 and 1.005<v.co.z<1.31 and v.co.y<-.035:
                v.co.y=min(v.co.y,-.153-(v.co.z-1.005)*.04)
        for v in boundary:
            p=v.co
            if p.z<1.01:
                p.z=.979
            elif abs(p.x)<.095 and p.y<-.075 and p.z<1.36:
                p.x=math.copysign(.073,p.x)
            elif abs(p.x)>.255 and p.z<1.23:
                s=1 if p.x>0 else -1
                shoulder=Vector((s*.160,-.023,1.323))
                axis=Vector((s*.163,-.004,-.177)).normalized()
                p-=axis*((p-shoulder).dot(axis)-.215)
    if name in {'Terracotta bandana','Hairline'}:
        for v in boundary:
            if v.co.y<-.025:
                v.co.z=1.618 if name=='Terracotta bandana' else 1.606
    if name=='Approach shoe uppers':
        for _ in range(8):
            bmesh.ops.smooth_vert(bm,verts=list(bm.verts),factor=.55,use_axis_x=True,use_axis_y=True,use_axis_z=True)
        for v in bm.verts:
            v.co.z=max(.026,v.co.z)
    bm.to_mesh(obj.data);bm.free()
    if ratio<1:
        d=obj.modifiers.new('Prototype mesh reduction','DECIMATE');d.ratio=ratio
    arm=obj.modifiers.new('Installer skin','ARMATURE');arm.object=rig
    parent_keep(obj,rig)
    return obj


def front_y(x,z):
    hit,co,normal,index=base.ray_cast(Vector((x,-1,z)),Vector((0,1,0)))
    return co.y if hit else -.09


def loop_belt(name,center,rx,ry,height,material):
    x,y,z=center
    verts=[]
    for radius,zoff in [(1,-height/2),(1,height/2),(.94,-height/2),(.94,height/2)]:
        verts.extend((x+rx*radius*math.cos(i*math.tau/32),y+ry*radius*math.sin(i*math.tau/32),z+zoff) for i in range(32))
    faces=[]
    for i in range(32):
        j=(i+1)%32
        faces.extend([(i,j,32+j,32+i),(64+i,96+i,96+j,64+j),(32+i,32+j,96+j,96+i),(i,64+i,64+j,j)])
    return mesh(name,verts,faces,material,True)


surface('Visible skin',lambda p: p.z>1.386 or (abs(p.x)>.305 and p.z<1.22),skin,ratio=.43)
surface('Sage undershirt',lambda p: .96<p.z<1.385 and abs(p.x)<.18,'sage',.010,.55)
surface('Open canvas jacket',lambda p: .965<p.z<1.394 and (abs(p.x)<.19 or p.z>1.165)
    and not(abs(p.x)<.064 and p.y<-.035),canvas,.028,.60)
surface('Reinforced work trousers',lambda p: .085<p.z<1.012 and abs(p.x)<.24,trousers,.014,.52)
surface('Fingerless gloves',lambda p: abs(p.x)>.420 and .988<p.z<1.05,leather,.003,.8)
surface('Approach shoe uppers',lambda p: p.z<.138,'offline',.012,.65)
surface('Hairline',lambda p: p.z>1.60 or (p.y>.014 and p.z>1.50),hair,.005,.50)
surface('Terracotta bandana',lambda p: p.z>1.621 or (p.y>-.07 and p.z>1.595),'terra',.011,.50)
bind(sphere('Low bun',(0,.111,1.565),(.047,.047,.043),hair,20,12),'head')
for s in [-1,1]:
    bind(mesh('Bandana tail',[(s*.012,.095,1.589),(s*.042,.137,1.568),(s*.035,.153,1.49),(s*.009,.13,1.515)],[(0,1,2,3)],'terra'),'head')
    x=s*.173
    bind(box('Rubber shoe sole',(x,-.087,.02),(.127,.265,.04),'graphite',.018,3),'foot_l' if s>0 else 'foot_r')
    for y in [-.12,-.085,-.05]:
        bind(tube('Orange shoe lace',[(x-.028,y,.107),(x,y-.007,.119),(x+.028,y,.107)],.003,'terra',2,1),'foot_l' if s>0 else 'foot_r')
    bind(box('Tan knee pad',(s*.137,-.11,.489),(.093,.043,.14),leather,.024,3),'calf_l' if s>0 else 'calf_r')
    bind(loop_belt('Harness leg loop',(s*.103,-.025,.808),.093,.095,.025,'webbing'),'thigh_l' if s>0 else 'thigh_r')
bind(loop_belt('Harness waist belt',(0,-.025,.987),.182,.126,.038,'webbing'),'pelvis')
bind(box('Waist buckle',(0,-.153,.987),(.048,.015,.038),'gold',.007,2),'pelvis')
for s in [-1,1]:
    bind(tube('Harness riser',[(s*.09,-.123,.81),(s*.095,-.14,.90),(s*.075,-.15,.986)],.01,'webbing',3,1),'pelvis')
    bind(box('Canvas belt pouch',(s*.16,-.094,.94),(.072,.063,.10),canvas,.016,2),'pelvis')
    bind(tube('Brass carabiner',[(s*.165,-.14,.99),(s*.183,-.143,.957),(s*.165,-.143,.926),(s*.147,-.143,.95),(s*.165,-.14,.99)],.0035,'gold',3,1),'pelvis')
for i in range(5):
    pts=[]
    for j in range(33):
        a=j*math.tau/32
        pts.append((-.225+.090*math.cos(a),-.015-i*.009,.933+.093*math.sin(a)))
    bind(tube('Orange climbing rope',pts,.004,'terra',1,1),'pelvis')
bind(box('Rope keeper',(-.225,-.043,1.018),(.027,.068,.028),'webbing',.005,1),'pelvis')
bind(rod('Stubby pry bar',(.20,.02,.88),(.20,.02,1.065),.009,'steel',8),'pelvis')
bind(ring('Cable ties roll',(.20,-.02,.97),.025,.007,'graphite',rot=(math.pi/2,0,0),major=20,minor=4),'pelvis')

# Garment details sit on the inherited anatomy instead of an invented torso primitive.
for s in [-1,1]:
    bind(tube('Raised collar',[(s*.03,-.086,1.376),(s*.081,-.04,1.416),(s*.088,.016,1.396)],.016,canvas,3,1),'spine_03')
    cuff=ring('Rolled canvas cuff',(s*.306,-.027,1.164),.053,.013,canvas,major=24,minor=6)
    cuff.rotation_euler=Vector((s*.163,-.004,-.177)).to_track_quat('Z','Y').to_euler()
    apply(cuff);bind(cuff,'upperarm_l' if s>0 else 'upperarm_r')
    bind(tube('Jacket hem',[(s*.072,-.139,.977),(s*.156,-.08,.977),(s*.164,.035,.977),(s*.06,.095,.977)],.005,leather,3,1),'pelvis')
py=front_y(.087,1.252)-.035
bind(box('Cream chest patch',(.087,py,1.252),(.064,.006,.074),'cream',.007,2),'spine_03')
bind(cylinder('Chest sun',(.087,py-.005,1.252),.015,.004,'terra',16,rot=(math.pi/2,0,0),bevel=0),'spine_03')
sy=front_y(.228,1.317)-.037
bind(cylinder('Sunflower patch',(.228,sy,1.317),.025,.005,'webbing',20,rot=(math.pi/2,0,0),bevel=.002),'upperarm_l')
for i in range(8):
    a=i*math.tau/8
    bind(mesh('Sunflower petal',[(.228+.010*math.cos(a-.4),sy-.004,1.317+.010*math.sin(a-.4)),
        (.228+.024*math.cos(a),sy-.004,1.317+.024*math.sin(a)),
        (.228+.010*math.cos(a+.4),sy-.004,1.317+.010*math.sin(a+.4))],[(0,1,2)],'gold'),'upperarm_l')
bind(cylinder('Sunflower center',(.228,sy-.007,1.317),.008,.002,'brick',16,rot=(math.pi/2,0,0),bevel=0),'upperarm_l')
bind(box('Sage elbow patch',(-.303,.023,1.181),(.075,.022,.061),'sage',.012,2),'upperarm_r')

eye_z=0
for side,s in [('l',1),('r',-1)]:
    e=anchors['joint-'+side+'-eye']
    eye_z=e.z
    bind(sphere('Eye white',e,(.012,.011,.009),mat('eye_white','#D4C8B3',rough=.4),16,8),'head')
    bind(sphere('Amber iris',e+Vector((0,-.010,.0005)),(.0055,.002,.0057),mat('iris','#795328',rough=.35),16,10),'head')
    bind(sphere('Pupil',e+Vector((0,-.012,.0005)),(.0024,.001,.003),hair,12,8),'head')
    bind(sphere('Eye highlight',e+Vector((-.0016,-.013,.003)),(.0014,.0007,.0012),'cream',8,6),'head')
    ey=min(e.y-.019,front_y(e.x,e.z)-.010)
    outline=[(e.x-.019,ey,e.z+.008),(e.x-.017,ey,e.z-.008),(e.x+.016,ey,e.z-.009),
        (e.x+.020,ey,e.z+.007),(e.x+.010,ey,e.z+.011),(e.x-.019,ey,e.z+.008)]
    bind(tube('Graphite AR frame',outline,.0018,'graphite',2,1),'head')
    bind(mesh('AR lens',outline[:-1],[(0,1,2,3,4)],mat('glass','#82BDCA',rough=.16,alpha=.17)),'head')
    bind(tube('Glasses temple',[(e.x+s*.019,ey,e.z+.007),(s*.070,-.032,e.z+.008),(s*.073,.037,e.z-.002)],.002,'graphite',2,1),'head')
    brow=[(e.x-s*.018,front_y(e.x-s*.018,e.z+.019)-.003,e.z+.016),
        (e.x,front_y(e.x,e.z+.021)-.003,e.z+.021),
        (e.x+s*.018,front_y(e.x+s*.018,e.z+.019)-.003,e.z+.019)]
    bind(tube('Strong brow',brow,.0031,hair,3,1),'head')
    if side=='l':
        bind(tube('Gold lens repair',[(e.x+.006,ey-.002,e.z+.01),(e.x+.002,ey-.002,e.z+.002),(e.x+.009,ey-.002,e.z-.009)],.0008,'gold',1,1),'head')
        bind(tube('Healed brow scar',[(e.x+.006,front_y(e.x+.006,e.z+.018)-.007,e.z+.017),
            (e.x+.009,front_y(e.x+.009,e.z+.025)-.005,e.z+.027)],.0012,mat('scar','#C59E7D'),1,1),'head')
    for i in range(8):
        x=e.x+random.uniform(-.014,.014)
        z=e.z-random.uniform(.019,.036)
        y=front_y(x,z)-.0007
        bind(sphere('Sun freckle',(x,y,z),(.0007,.00045,.0006),mat('freckles','#704733'),6,4),'head')
e=anchors['joint-l-eye']
ey=min(e.y-.019,front_y(e.x,e.z)-.010)
bind(tube('Glasses bridge',[(-.014,ey,eye_z+.005),(0,ey-.006,eye_z+.009),(.014,ey,eye_z+.005)],.0018,'graphite',3,1),'head')


def attach_equipment(build,transform,bone):
    before=set(bpy.context.collection.objects)
    build()
    parts=list(set(bpy.context.collection.objects)-before)
    bpy.context.view_layer.update()
    worlds={o:transform@o.matrix_world for o in parts}
    for o in parts:
        if o.type in {'MESH','CURVE'}:
            o.parent=None;o.matrix_world=worlds[o]
            apply(o);bind(o,bone)
    for o in parts:
        if o.type=='EMPTY':
            bpy.data.objects.remove(o,do_unlink=True)


attach_equipment(prop_backpack_rig.build,Matrix.Translation((0,.167,1.102))@Matrix.Rotation(math.pi,4,'Z'),'spine_03')
bind(box('Rivet driver holster',(-.215,-.015,.747),(.074,.092,.18),'webbing',.016,2),'thigh_r')
attach_equipment(prop_rivet_driver.build,Matrix.Translation((-.217,.037,.79))@Matrix.Rotation(math.pi/2,4,'X'),'thigh_r')
bpy.data.objects.remove(base,do_unlink=True)

# A single skinned mesh keeps the many wearable parts practical in Godot.
skins=[o for o in bpy.context.collection.objects if o.type=='MESH']
for o in skins:
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True)
    bpy.context.view_layer.objects.active=o
    for mod in list(o.modifiers):
        if mod.type!='ARMATURE':
            bpy.ops.object.modifier_apply(modifier=mod.name)
bpy.ops.object.select_all(action='DESELECT')
for o in skins:o.select_set(True)
bpy.context.view_layer.objects.active=skins[0]
bpy.ops.object.join()
bpy.context.object.name='Installer_skinned_mesh'
bpy.ops.object.vertex_group_limit_total(limit=4)
bpy.ops.object.vertex_group_normalize_all(lock_active=False)
rig['animation_status']='Weighted A-pose prototype. Human motion clips deliberately deferred by brief; weights require pose review before animation production.'
finish('char_installer','characters','CC0 MakeHuman base and game skeleton; fitted procedural clothes and all gear, no image textures. Weighted A-pose only: human motion clips are deferred by the brief. Counts include the 5.9k backpack and 1.5k rivet driver. Bandana brings height to 1.69 m.',front_yaw=-27,front_pitch=18)
