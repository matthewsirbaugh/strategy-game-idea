import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *
from mathutils import Matrix
from mathutils.kdtree import KDTree
from char_installer_review import finish_installer, cloth_material
import bmesh
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
skin=cloth_material('skin','#996B53',.51,grain=0,variation=.045)
canvas=cloth_material('ochre_canvas','#A37638',.83)
canvas_dark=cloth_material('canvas_reinforcement','#76522F',.85)
canvas_light=cloth_material('canvas_edge','#B49360',.8)
shirt=cloth_material('sage_shirt','#51685C',.88)
bandana=cloth_material('terracotta_bandana','#A64732',.82)
thread=mat('stitching','#B69A6A',rough=.85)
trousers=cloth_material('work_trousers','#303C43',.86)
leather=cloth_material('tan_leather','#796145',.66,grain=.025)
hair=mat('hair','#171B21',rough=.57)


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
    if name=='Reinforced work trousers':
        for v in boundary:
            if v.co.z<.20:
                v.co.z=.133
            elif v.co.z>.94:
                v.co.z=1.006
        for v in bm.verts:
            q=v.co
            axis=.103+max(0,.86-q.z)*.089
            fullness=.012+.008*math.exp(-((q.z-.68)/.20)**2)
            angle=math.atan2(q.y+.025,abs(q.x)-axis)
            fold=.004*math.sin(q.z*83+angle*2)*math.exp(-((q.z-.23)/.12)**2)
            q.x+=math.copysign((fullness+fold)*math.cos(angle),q.x) if math.cos(angle)>0 else -math.copysign(abs((fullness+fold)*math.cos(angle)),q.x)
            q.y+=(fullness+fold)*math.sin(angle)
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


tree=KDTree(len(base.data.vertices))
for v in base.data.vertices:
    tree.insert(v.co,v.index)
tree.balance()


def fitted(obj):
    if obj.type=='CURVE':
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.convert(target='MESH')
    groups={g.index:obj.vertex_groups.new(name=g.name) for g in base.vertex_groups if g.name in rig.data.bones}
    for v in obj.data.vertices:
        weights={}
        for co,index,dist in tree.find_n(obj.matrix_world@v.co,4):
            for w in base.data.vertices[index].groups:
                if w.group in groups:
                    weights[w.group]=weights.get(w.group,0)+w.weight/max(dist,.003)**2
        total=sum(weights.values())
        for i,w in weights.items():
            groups[i].add([v.index],w/total,'REPLACE')
    arm=obj.modifiers.new('Installer skin','ARMATURE')
    arm.object=rig
    parent_keep(obj,rig)
    return obj


def garment(name, rows, material, cyclic=True, sub=1, thickness=.003):
    n=len(rows[0])
    faces=[(r*n+i,r*n+(i+1)%n,(r+1)*n+(i+1)%n,(r+1)*n+i)
        for r in range(len(rows)-1) for i in range(n if cyclic else n-1)]
    obj=mesh(name,[v for row in rows for v in row],faces,material,True)
    if sub:
        mod=obj.modifiers.new('Tailored surface','SUBSURF')
        mod.levels=sub
    if thickness:
        mod=obj.modifiers.new('Cloth thickness','SOLIDIFY')
        mod.thickness=thickness
    return obj


visible_skin=surface('Visible skin',lambda p: 1.350<p.z<1.637 or (abs(p.x)>.305 and p.z<1.22),skin,ratio=.56)
surface('Sage undershirt',lambda p: .96<p.z<1.385 and abs(p.x)<.18,shirt,.014,.55)
surface('Reinforced work trousers',lambda p: .115<p.z<1.012 and abs(p.x)<.24,trousers,.018,.57)
surface('Fingerless gloves',lambda p: abs(p.x)>.420 and .988<p.z<1.05,leather,.005,.8)
nt=skin.node_tree
bs=nt.nodes.get('Principled BSDF')
original_color=bs.inputs['Base Color'].links[0].from_socket
pos=nt.nodes.new('ShaderNodeNewGeometry')
subtract=nt.nodes.new('ShaderNodeVectorMath');subtract.operation='SUBTRACT'
subtract.inputs[1].default_value=(0,-.158,1.503)
nt.links.new(pos.outputs['Position'],subtract.inputs[0])
scale=nt.nodes.new('ShaderNodeVectorMath');scale.operation='MULTIPLY'
scale.inputs[1].default_value=(1/.028,1/.020,1/.010)
nt.links.new(subtract.outputs[0],scale.inputs[0])
length=nt.nodes.new('ShaderNodeVectorMath');length.operation='LENGTH'
nt.links.new(scale.outputs[0],length.inputs[0])
falloff=nt.nodes.new('ShaderNodeMapRange');falloff.interpolation_type='SMOOTHSTEP'
falloff.inputs['From Min'].default_value=.3;falloff.inputs['From Max'].default_value=1.15
falloff.inputs['To Min'].default_value=.65;falloff.inputs['To Max'].default_value=0
nt.links.new(length.outputs['Value'],falloff.inputs['Value'])
mix=nt.nodes.new('ShaderNodeMixRGB')
nt.links.new(falloff.outputs[0],mix.inputs[0]);nt.links.new(original_color,mix.inputs[1])
mix.inputs[2].default_value=(*linear('#774938'),1)
nt.links.new(mix.outputs[0],bs.inputs['Base Color'])


def scalp_point(a,z,offset):
    direction=Vector((math.sin(a),-math.cos(a),0))
    center=Vector((0,-.020,z))
    hit,co,normal,index=base.ray_cast(center+direction*.4,-direction)
    if not hit:
        co=Vector((.009*math.sin(a),-.020-.009*math.cos(a),z))
    return co+direction*offset


for name,material,extra in [('Pulled back hair',hair,.007),('Tied cloth bandana',bandana,.016)]:
    rows=[]
    for t in [0,.025,.08,.23,.47,.7,.88,.97,1]:
        row=[]
        for i in range(32):
            a=i*math.tau/32
            front=(1+math.cos(a))*.5
            lower=(1.580+.057*front**3 if material==hair else 1.592+.032*front)+.004*math.sin(a*2+.3)
            z=lower+(1.679-lower)*t
            wrinkle=(.0035*math.sin(a*7+t*13)+.002*math.sin(a*5-t*9))*math.sin(t*math.pi)
            point=scalp_point(a,z,(extra+wrinkle)*(1-.9*t**5))
            point.z+=(.007 if material==hair else .011)*t*t
            row.append(point)
        rows.append(row)
    rows.append([(math.sin(j*math.tau/32)*.0003,-.020+math.cos(j*math.tau/32)*.0003,1.689 if material==hair else 1.694) for j in range(32)])
    cap=garment(name,rows,material,True,1,0)
    bind(cap,'head')
    if material==bandana:
        bind(tube('Bandana folded hem',rows[1]+rows[1][:1],.0018,cloth_material('bandana_hem','#793B2D',.85),2,1),'head')
bind(sphere('Bandana knot',(0,.127,1.604),(.021,.015,.015),bandana,20,12),'head')

jacket_rows=[]
for z,rx,ry,opening in [(1.016,.174,.137,.42),(1.022,.180,.140,.42),(1.06,.184,.144,.41),
    (1.15,.184,.175,.36),(1.25,.194,.195,.30),(1.323,.207,.151,.29),
    (1.354,.172,.125,.34),(1.399,.077,.085,.48),(1.407,.074,.082,.50)]:
    row=[]
    for i in range(41):
        a=opening+(math.tau-2*opening)*i/40
        fold=.004*math.sin(a*7+z*13)*math.sin((z-1.016)*math.pi/.4)**2
        row.append(((rx+fold)*math.sin(a),-.015-(ry+fold)*math.cos(a),z+.005*math.sin(a*3)))
    jacket_rows.append(row)
jacket_obj=fitted(garment('Tailored open canvas jacket',jacket_rows,canvas,False))

def jacket_y(x,z):
    bpy.context.view_layer.update()
    evaluated=jacket_obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    hit,co,normal,index=evaluated.ray_cast(Vector((x,-1,z)),Vector((0,1,0)))
    return co.y if hit else -.12

for edge in [0,-1]:
    fitted(tube('Jacket front binding',[row[edge] for row in jacket_rows],.004,canvas_light,2,1))
    fitted(tube('Jacket zipper tape',[(p[0]+math.copysign(.007,p[0]),p[1]-.001,p[2]) for p in [r[edge] for r in jacket_rows]],.002,canvas_dark,2,1))
fitted(tube('Weighted jacket hem',jacket_rows[1],.004,canvas_dark,2,1))
for edge in [0,-1]:
    points=[Vector(r[edge]) for r in jacket_rows]
    for a,b in zip(points[1:-1],points[2:]):
        for t in [.18,.46,.74]:
            x=a.lerp(b,t);y=a.lerp(b,t+.09)
            x.y-=.003;y.y-=.003
            fitted(rod('Jacket topstitch',x,y,.0007,thread,5))


lining=[[(x*.965,y*.965,z-.002) for x,y,z in row] for row in jacket_rows[-3:]]
fitted(garment('Raised collar lining',lining,canvas_dark,False,1,.001))
fitted(tube('Soft collar rim',jacket_rows[-1],.0018,canvas_dark,2,1))
for side in [-1,1]:
    shoulder=Vector((side*.163,-.023,1.334))
    axis=Vector((side*.163,-.004,-.177)).normalized()
    across=Vector((0,1,0))
    up=axis.cross(across).normalized()
    rows=[]
    for t,r in [(-.063,.006),(-.043,.040),(-.022,.065),(0,.073),(.048,.078),(.105,.073),(.158,.067),(.195,.064),(.201,.064)]:
        rows.append([shoulder+axis*t+across*(math.cos(a)*r)+up*(math.sin(a)*r*(1.05+.025*math.sin(a*3+t*22)))
            for a in [j*math.tau/24 for j in range(24)]])
    fitted(garment('Loose rolled sleeve',rows,canvas))
    for t,r in [(.194,.069),(.183,.070)]:
        cuff=ring('Folded canvas cuff',shoulder+axis*t,r,.009,canvas_light,major=24,minor=6)
        cuff.rotation_euler=axis.to_track_quat('Z','Y').to_euler()
        apply(cuff)
        fitted(cuff)
    fitted(tube('Shoulder seam',rows[3]+rows[3][:1],.0018,canvas_dark,2,1))

bind(sphere('Low bun',(0,.111,1.565),(.052,.043,.048),hair,24,16),'head')
for s in [-1,1]:
    bind(mesh('Bandana tail',[(s*.010,.105,1.608),(s*.041,.144,1.585),(s*.030,.168,1.502),(s*.006,.138,1.527)],[(0,1,2,3)],bandana),'head')
    x=s*.173
    foot='foot_l' if s>0 else 'foot_r'
    fitted(loop_belt('Trouser cuff',(x,-.027,.152),.054,.061,.036,trousers))
    outline=[(-.046,.047),(-.064,.013),(-.067,-.119),(-.062,-.194),(-.038,-.227),
        (.026,-.235),(.061,-.215),(.066,-.150),(.055,-.040),(.052,.032)]
    for z,scale,height,m in [(.014,1.03,.024,'graphite'),(.035,1,.017,leather)]:
        rows=[[(x+u*scale,v*scale,k) for u,v in outline] for k in [z-height/2,z+height/2]]
        obj=garment('Shaped climbing shoe sole',rows,m,True,0,0)
        bm=bmesh.new();bm.from_mesh(obj.data)
        bmesh.ops.holes_fill(bm,edges=[e for e in bm.edges if e.is_boundary],sides=0)
        bm.to_mesh(obj.data);bm.free()
        bevel=obj.modifiers.new('Rounded sole edge','BEVEL');bevel.width=.005;bevel.segments=2
        bind(obj,foot)
    rows=[]
    for z,rx,ry,cy in [(.043,.061,.133,-.089),(.058,.062,.133,-.089),(.092,.059,.120,-.070),
        (.122,.051,.089,-.037),(.155,.047,.063,-.020),(.167,.045,.059,-.020)]:
        rows.append([(x+rx*math.sin(a),cy-ry*math.cos(a),z) for a in [j*math.tau/24 for j in range(24)]])
    bind(garment('Approach shoe upper',rows,mat('shoe_suede','#58605B',rough=.86)),foot)
    bind(tube('Rubber toe rand',[(x-.056,-.153,.064),(x-.047,-.203,.064),(x,-.228,.065),(x+.05,-.209,.064),(x+.061,-.160,.064)],.008,'graphite',3,2),foot)
    for y,z in [(-.148,.114),(-.118,.133),(-.087,.150)]:
        for a,b in [(-1,1),(1,-1)]:
            bind(tube('Crossed orange laces',[(x+a*.030,y+.008,z),(x,y-.006,z+.008),(x+b*.030,y-.015,z+.010)],.0027,bandana,2,1),foot)
    bind(box('Heel pull tab',(x,.043,.151),(.019,.011,.049),bandana,.004,2),foot)
    for y in [-.185,-.141,-.087,.012]:
        bind(box('Sole traction lug',(x,y,.006),(.104,.016,.010),'graphite',.004,1),foot)
    knee='calf_l' if s>0 else 'calf_r'
    bind(box('Knee reinforcement',(s*.137,-.125,.487),(.105,.031,.183),canvas_dark,.023,3),knee)
    bind(box('Articulated knee pad',(s*.137,-.147,.492),(.083,.021,.131),leather,.020,3),knee)
    for z in [.467,.493,.519]:
        bind(box('Knee pad channel',(s*.137,-.159,z),(.064,.003,.004),canvas_dark,.001,1),knee)
    bind(box('Thigh cargo pocket',(s*.181,-.060,.712),(.080,.069,.135),trousers,.014,3),'thigh_l' if s>0 else 'thigh_r')
    bind(box('Cargo pocket flap',(s*.181,-.100,.762),(.079,.014,.031),canvas_dark,.006,2),'thigh_l' if s>0 else 'thigh_r')
    bind(loop_belt('Harness leg loop',(s*.103,-.025,.808),.093,.095,.025,'webbing'),'thigh_l' if s>0 else 'thigh_r')
bind(loop_belt('Harness waist belt',(0,-.025,.987),.204,.149,.038,'webbing'),'pelvis')
bind(box('Waist buckle',(0,-.181,.987),(.048,.015,.038),'gold',.007,2),'pelvis')
for s in [-1,1]:
    bind(tube('Harness riser',[(s*.09,-.123,.81),(s*.095,-.14,.90),(s*.075,-.15,.986)],.01,'webbing',3,1),'pelvis')
    bind(box('Canvas belt pouch',(s*.185,-.120,.941),(.072,.063,.10),canvas_dark,.012,3),'pelvis')
    bind(box('Pouch folded flap',(s*.185,-.155,.977),(.073,.011,.029),canvas,.005,2),'pelvis')
    bind(tube('Brass carabiner',[(s*.193,-.159,.99),(s*.211,-.163,.957),(s*.193,-.163,.926),(s*.175,-.163,.95),(s*.193,-.159,.99)],.0035,'gold',3,1),'pelvis')
for i in range(5):
    pts=[]
    for j in range(33):
        a=j*math.tau/32
        pts.append((-.225+.090*math.cos(a),-.015-i*.009,.933+.093*math.sin(a)))
    bind(tube('Orange climbing rope',pts,.004,'terra',1,1),'pelvis')
bind(box('Rope keeper',(-.225,-.043,1.018),(.027,.068,.028),'webbing',.005,1),'pelvis')
bind(rod('Stubby pry bar',(.20,.02,.88),(.20,.02,1.065),.009,'steel',8),'pelvis')
bind(ring('Cable ties roll',(.20,-.02,.97),.025,.007,'graphite',rot=(math.pi/2,0,0),major=20,minor=4),'pelvis')

for side in [-1,1]:
    fitted(box('Chest pocket',(side*.119,jacket_y(side*.119,1.223)-.006,1.223),(.064,.010,.082),canvas_dark,.010,3))
    fitted(box('Chest pocket flap',(side*.119,jacket_y(side*.119,1.261)-.012,1.261),(.066,.008,.021),canvas_light,.004,2))
    for z in [1.205,1.232]:
        fitted(cylinder('Jacket fastening',(side*.080,-.201,z),.003,.003,'gold',10,rot=(math.pi/2,0,0),bevel=0))
py=jacket_y(.120,1.224)-.017
bind(box('Cream chest patch',(.120,py,1.224),(.043,.004,.050),'cream',.007,2),'spine_03')
bind(cylinder('Chest sun',(.120,py-.005,1.224),.010,.003,bandana,16,rot=(math.pi/2,0,0),bevel=0),'spine_03')
sy=-.099
bind(cylinder('Sunflower patch',(.231,sy,1.322),.025,.005,'webbing',20,rot=(math.pi/2,0,0),bevel=.002),'upperarm_l')
for i in range(8):
    a=i*math.tau/8
    bind(mesh('Sunflower petal',[(.228+.010*math.cos(a-.4),sy-.004,1.322+.010*math.sin(a-.4)),
        (.228+.024*math.cos(a),sy-.004,1.322+.024*math.sin(a)),
        (.228+.010*math.cos(a+.4),sy-.004,1.322+.010*math.sin(a+.4))],[(0,1,2)],'gold'),'upperarm_l')
bind(cylinder('Sunflower center',(.228,sy-.007,1.322),.008,.002,'brick',16,rot=(math.pi/2,0,0),bevel=0),'upperarm_l')
bind(box('Sage elbow patch',(-.303,-.073,1.202),(.066,.012,.056),'sage',.012,2),'upperarm_r')

eye_z=0
for side,s in [('l',1),('r',-1)]:
    e=anchors['joint-'+side+'-eye']+Vector((0,-.009,0))
    eye_z=e.z
    bind(sphere('Eye white',e,(.011,.010,.008),mat('eye_white','#BFA98B',rough=.4),16,8),'head')
    bind(sphere('Amber iris',e+Vector((0,-.010,.0005)),(.0048,.002,.0049),mat('iris','#54462F',rough=.35),16,10),'head')
    bind(sphere('Pupil',e+Vector((0,-.012,.0005)),(.0022,.001,.0027),hair,12,8),'head')
    bind(sphere('Eye highlight',e+Vector((-.0016,-.013,.003)),(.0008,.0004,.0008),'cream',8,6),'head')
    ey=min(e.y-.019,front_y(e.x,e.z)-.010)
    outline=[(e.x-.019,ey,e.z+.008),(e.x-.017,ey,e.z-.008),(e.x+.016,ey,e.z-.009),
        (e.x+.020,ey,e.z+.007),(e.x+.010,ey,e.z+.011),(e.x-.019,ey,e.z+.008)]
    bind(tube('Graphite AR frame',outline,.0018,'graphite',2,1),'head')
    bind(mesh('AR lens',outline[:-1],[(0,1,2,3,4)],mat('glass','#BCD1C8',rough=.3,alpha=.035)),'head')
    bind(tube('Glasses temple',[(e.x+s*.019,ey,e.z+.007),(s*.070,-.032,e.z+.008),(s*.073,.037,e.z-.002)],.002,'graphite',2,1),'head')
    brow=[(e.x-s*.018,front_y(e.x-s*.018,e.z+.019)-.003,e.z+.016),
        (e.x,front_y(e.x,e.z+.021)-.003,e.z+.021),
        (e.x+s*.018,front_y(e.x+s*.018,e.z+.019)-.003,e.z+.019)]
    bind(tube('Strong brow',brow,.0021,hair,3,1),'head')
    if side=='l':
        bind(tube('Gold lens repair',[(e.x+.006,ey-.002,e.z+.01),(e.x+.002,ey-.002,e.z+.002),(e.x+.009,ey-.002,e.z-.009)],.0008,'gold',1,1),'head')
        bind(tube('Healed brow scar',[(e.x+.006,front_y(e.x+.006,e.z+.018)-.007,e.z+.017),
            (e.x+.009,front_y(e.x+.009,e.z+.025)-.005,e.z+.027)],.0012,mat('scar','#C59E7D'),1,1),'head')
    for i in range(8):
        x=e.x+random.uniform(-.014,.014)
        z=e.z-random.uniform(.019,.036)
        y=front_y(x,z)-.0007
        bind(sphere('Sun freckle',(x,y,z),(.0007,.00045,.0006),mat('freckles','#704733'),6,4),'head')
e=anchors['joint-l-eye']+Vector((0,-.009,0))
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


def compact_backpack():
    steel=mat('pack_metal','#7D898C',metal=.65,rough=.37)
    shell=mat('pack_shell','#D6D5C7',metal=.1,rough=.47)
    bind(box('Salvaged AI home',(0,.174,1.224),(.241,.140,.340),shell,.035,4),'spine_03')
    bind(box('Pack impact base',(0,.183,1.065),(.250,.158,.067),'graphite',.018,3),'spine_03')
    for side in [-1,1]:
        bind(rod('Pack side rail',(side*.126,.190,1.07),(side*.126,.190,1.394),.008,steel,12),'spine_03')
        strap=[(side*.102,.161,1.344),(side*.107,.084,1.403),(side*.112,-.073,1.394),
            (side*.143,-.178,1.311),(side*.142,-.213,1.205),(side*.162,-.166,1.090)]
        strap=[(x,jacket_y(x,z)-.013 if y<-.1 else y,z) for x,y,z in strap]
        rows=[[(x-.014,y,z),(x+.014,y,z)] for x,y,z in strap]
        fitted(garment('Flat padded backpack strap',rows,mat('strap_webbing','#274E4C',rough=.81),False,1,.008))
    bind(box('Pack chest strap',(0,-.205,1.276),(.265,.012,.019),'webbing',.003,2),'spine_03')
    bind(box('Chest quick release',(.019,-.216,1.276),(.035,.012,.025),'graphite',.004,2),'spine_03')
    bind(box('Release tab',(.019,-.224,1.276),(.014,.005,.012),'gold',.002,1),'spine_03')
    bind(ring('Home light bezel',(0,.252,1.206),.026,.004,steel,rot=(math.pi/2,0,0),major=24,minor=6),'spine_03')
    bind(cylinder('Home light',(0,.254,1.206),.020,.005,mat('status_heart','amber',emission=1.4),24,rot=(math.pi/2,0,0),bevel=.001),'spine_03')
    for z in [1.14,1.166,1.30,1.326]:
        bind(box('Pack recessed vent',(0,.247,z),(.167,.006,.010),'graphite',.003,2),'spine_03')
    for side in [-1,1]:
        points=[]
        for u,v in [(-.083,-.144),(.083,-.144),(.083,.144),(-.083,.144)]:
            points.append((side*.091+u,.231+v*.34,1.466+v*.94+side*u*.18))
        panel=mesh('Folded solar panel',points,[(0,1,2,3)],'graphite')
        solid=panel.modifiers.new('Panel backing','SOLIDIFY');solid.thickness=.004;solid.offset=0
        bind(panel,'spine_03')
        for i in range(2):
            for j in range(5):
                u0=-.078+i*.080;v0=-.137+j*.055
                cell=[(side*.091+u,.238+v*.34,1.467+v*.94+side*u*.18) for u,v in [(u0,v0),(u0+.074,v0),(u0+.074,v0+.050),(u0,v0+.050)]]
                bind(mesh('Photovoltaic cell',cell,[(0,1,2,3)],mat('solar_cells','#283966',metal=.4,rough=.31)),'spine_03')
        for u in [-.080,0,.080]:
            bind(rod('Solar bus bar',(side*.091+u,.239-.138*.34,1.468-.138*.94+side*u*.18),
                (side*.091+u,.239+.138*.34,1.468+.138*.94+side*u*.18),.0009,'gold',6),'spine_03')
        bind(rod('Panel folding stay',(side*.110,.186,1.305),(side*.150,.275,1.533),.005,steel,8),'spine_03')
    bind(tube('Repaired power cable',[(.113,.253,1.123),(.159,.210,1.173),(.153,.135,1.348),(.078,.057,1.517)],.005,bandana,3,1),'spine_03')
    bind(rod('Pack antenna',(-.126,.185,1.361),(-.140,.206,1.582),.0035,'graphite',10),'spine_03')


compact_backpack()
bind(box('Rivet driver holster',(-.203,.000,.746),(.064,.082,.160),'webbing',.016,2),'thigh_r')
attach_equipment(prop_rivet_driver.build,Matrix.Translation((-.207,.050,.79))@Matrix.Diagonal((.85,.85,.85,1))@Matrix.Rotation(math.pi/2,4,'X'),'thigh_r')
bpy.data.objects.remove(base,do_unlink=True)

# Apply cloth subdivision before joining so transferred weights interpolate with the surface.
skins=[o for o in bpy.context.collection.objects if o.type=='MESH']
for o in skins:
    bpy.ops.object.select_all(action='DESELECT');o.select_set(True)
    bpy.context.view_layer.objects.active=o
    tailored=any(mod.type=='SUBSURF' for mod in o.modifiers)
    for mod in list(o.modifiers):
        if mod.type!='ARMATURE':
            bpy.ops.object.modifier_apply(modifier=mod.name)
    if tailored:
        reduction=o.modifiers.new('Tailored surface reduction','DECIMATE')
        reduction.ratio=.65 if 'strap' in o.name.lower() else .40
        bpy.ops.object.modifier_move_up(modifier=reduction.name)
        bpy.ops.object.modifier_apply(modifier=reduction.name)
bpy.ops.object.select_all(action='DESELECT')
for o in skins:o.select_set(True)
bpy.context.view_layer.objects.active=skins[0]
bpy.ops.object.join()
bpy.context.object.name='Installer_skinned_mesh'
reduction=bpy.context.object.modifiers.new('Character game budget','DECIMATE')
reduction.ratio=.69
reduction.use_collapse_triangulate=True
bpy.ops.object.modifier_move_up(modifier=reduction.name)
bpy.ops.object.modifier_apply(modifier=reduction.name)
bpy.ops.object.vertex_group_limit_total(limit=4)
bpy.ops.object.vertex_group_normalize_all(lock_active=False)
rig['animation_status']='Weighted A-pose prototype. Human motion clips deliberately deferred by brief; weights require pose review before animation production.'
finish_installer(rig,'char_installer','characters')
