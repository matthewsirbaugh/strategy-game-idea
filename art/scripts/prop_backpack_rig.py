import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

def build():
    steel=mat('brushed_aluminum','steel',metal=.68,rough=.32)
    box('Salvaged drone core',(0,0,.225),(.285,.16,.39),'white',.046,4)
    box('Graphite bottom bumper',(0,0,.045),(.30,.18,.09),'graphite',.022,2)
    for x in [-.143,.143]:
        tube('Hand-bent frame',[(x,.09,.035),(x,.095,.38),(x,.08,.425),(x*.65,.07,.43)],.009,steel,3,1)
        tube('Padded shoulder strap',[(x*.7,.10,.385),(x*.7,.25,.39),(x*.7,.30,.25),(x*.7,.20,.08),(x*.7,.09,.08)],.019,'webbing',3,1)
    box('Chest strap',(0,.31,.24),(.23,.018,.024),'webbing',.004,1)
    box('Chest buckle',(0,.326,.24),(.037,.012,.03),'gold',.005,1)
    box('Cyan trim',(0,-.084,.345),(.213,.009,.012),mat('emissive_core','cyan',emission=.6),.004,2)
    box('Sanded-off corporate mark',(0,-.084,.235),(.10,.007,.063),mat('ghost_mark','#DEDDD6'),.018,3)
    # A small, deliberately hand-painted moth replaces the removed corporate mark.
    for s in [-1,1]:
        mesh('Painted moth',[(0,-.089,.24),(s*.03,-.089,.257),(s*.02,-.089,.229),(0,-.089,.232)],[(0,1,2,3)],'webbing')
    ring('Heart bezel',(0,-.091,.127),.025,.004,steel,rot=(math.pi/2,0,0),major=24)
    cylinder('Heart light',(0,-.094,.127),.02,.009,mat('status_heart','amber',emission=2),24,rot=(math.pi/2,0,0),bevel=.002)
    for z in [.12,.15,.18,.21,.24,.27]:
        box('Heat-sink fin',(-.163,.012,z),(.042,.145,.009),steel,.003,1)
    cylinder('Fan disc',(-.17,.005,.32),.037,.018,'graphite',20,rot=(0,math.pi/2,0),bevel=.003)
    for i in [-1,0,1]:
        rod('Fan grille',(-.182,-.021,.32+i*.014),(-.182,.031,.32+i*.014),.002,steel,6)
    for x in [-.078,.078]:
        rod('Panel hinge',(x,-.035,.417),(x,.065,.417),.012,steel,12)
    for s in [-1,1]:
        before=set(bpy.context.collection.objects)
        cx=s*.154
        box('Solar flap frame',(cx,-.015,.493),(.302,.224,.018),'graphite',.007,1)
        for col in range(3):
            for row in range(4):
                box('Photovoltaic cell',(cx-.10+col*.10,-.096+row*.055,.504),(.094,.049,.004),mat('solar_cells','solar',metal=.32,rough=.27),.006,1)
        for col in range(4):
            box('Gold bus bar',(cx-.148+col*.099,-.015,.507),(.0018,.204,.0015),'gold',0)
        flap=pivot('solar_flap', (cx,-.015,.493),list(set(bpy.context.collection.objects)-before))
        flap.rotation_euler.x=math.radians(-30)
    tube('Glasses cable',[(.11,.05,.35),(.18,.15,.42),(.13,.27,.43)],.008,'terra',3,1)
    tube('Wrist cable',[(-.14,.04,.18),(-.20,.18,.14),(-.17,.25,.24)],.008,'terra',3,1)
    rod('Flexible antenna',(.14,.045,.37),(.17,.06,.52),.004,'graphite',10)
    mesh('Faded ribbon',[(.163,.06,.47),(.215,.067,.44),(.212,.072,.418),(.169,.06,.451)],[(0,1,2,3)],'terra')
    for z in [.18,.225,.27,.315]:
        cylinder('Probe holder',(.105,.306,z),.012,.036,mat('glass','#9BC3C2',metal=.12,rough=.18),12,bevel=.003)
        cylinder('Probe in capsule',(.105,.312,z),.006,.020,'amber',10,bevel=.002)

if __name__ == '__main__':
    start('prop_backpack_rig')
    build()
    finish('prop_backpack_rig','props','No textures. 42 cm frame, ~55 cm with two 30×22 cm solar flaps spread side by side. Positive Y straps face wearer; status_heart is independent.',front_pitch=48)
