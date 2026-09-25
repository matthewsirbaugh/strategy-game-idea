import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('prop_cargo_bike')
paint=mat('bike_enamel','teal',metal=.3,rough=.36)
for y,r in [(.62,.31),(-.77,.25)]:
    z=r+.035
    ring('Rubber tyre',(0,y,z),r,.03,'graphite',rot=(0,math.pi/2,0),major=32,minor=8)
    ring('Alloy rim',(0,y,z),r-.045,.013,'steel',rot=(0,math.pi/2,0),major=32,minor=4)
    rod('Axle',(-.09,y,z),(.09,y,z),.028,'steel',12)
    for i in range(12):
        a=i*math.tau/12
        rod('Spoke',(.01,y,z),(.01,y+math.sin(a)*(r-.045),z+math.cos(a)*(r-.045)),.003,'steel',5)
crank=(0,.22,.32)
seat=(0,.31,.79)
rear=(0,.62,.345)
head=(0,-.21,.79)
lowhead=(0,-.22,.33)
for a,b in [(crank,seat),(seat,rear),(rear,crank),(seat,head),(head,lowhead),(lowhead,crank)]:
    rod('Frame tube',a,b,.023,paint,12)
for x in [-.09,.09]:
    tube('Extended cargo frame',[(x,.1,.32),(x,-.36,.23),(x,-.70,.23),(x,-.77,.285)],.019,paint,3,1)
    tube('Front fork',[(x,-.46,.66),(x,-.65,.53),(x,-.77,.285)],.019,paint,2,1)
rod('Seat post',seat,(0,.31,.91),.017,'steel',12)
sphere('Leather saddle',(0,.33,.925),(.11,.15,.035),'webbing',16,8)
tube('Handlebar',[(0,-.22,.72),(0,-.23,1.03),(-.24,-.15,1.04)],.015,'steel',3,1)
tube('Right bar',[(0,-.23,1.03),(.24,-.15,1.04)],.015,'steel',2,1)
for x in [-.25,.25]:
    rod('Grip',(x,-.19,1.04),(x,-.08,1.04),.022,'graphite',12)
rod('Crank axle',(-.12,.22,.32),(.12,.22,.32),.025,'steel',12)
for x,y,z in [(-.13,.15,.42),(.13,.29,.22)]:
    box('Pedal',(x,y,z),(.09,.075,.022),'graphite',.005,1)
box('Cargo floor',(0,-.55,.51),(.64,.64,.045),'timber',.01,1)
for z in [.59,.72,.85]:
    for x in [-.30,.30]:
        box('Basket side',(x,-.55,z),(.035,.62,.105),'timber',.006,1)
    for y in [-.85,-.25]:
        box('Basket end',(0,y,z),(.60,.035,.105),'timber',.006,1)
box('Sage canvas parcel',(0,-.55,.71),(.39,.38,.32),'sage',.06,3)
box('Parcel strap',(0,-.55,.877),(.065,.38,.013),'webbing',.005,1)
rod('Kickstand',(.02,.31,.30),(.23,.32,.015),.012,'steel',10)
finish('prop_cargo_bike','props','No textures. Front-facing −Y; working cargo-bike proportions, boxed solar-install supplies, and a parked kickstand.',front_yaw=65,front_pitch=25)
