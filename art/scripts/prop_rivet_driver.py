import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

def build():
    box('Faded safety-orange body',(0,-.006,.14),(.10,.18,.083),'terra',.018,3)
    box('Grip',(0,.044,.077),(.045,.057,.112),'graphite',.01,2,rot=(math.radians(-12),0,0))
    box('Battery',(0,.055,.021),(.072,.08,.042),'graphite',.012,2)
    box('Battery latch',(0,.1,.027),(.04,.008,.01),'gold',.003,1)
    cylinder('Rivet barrel',(0,-.13,.15),.024,.10,'graphite',20,rot=(math.pi/2,0,0),bevel=.003)
    for y in [-.108,-.126,-.144]:
        ring('Black tape',(0,y,.15),.024,.002,'offline',rot=(math.pi/2,0,0),major=20,minor=4)
    cylinder('Nozzle',(0,-.177,.15),.016,.012,'steel',16,rot=(math.pi/2,0,0),bevel=.002)
    cylinder('Nozzle recess',(0,-.184,.15),.008,.003,'glass',12,rot=(math.pi/2,0,0),bevel=0)
    tube('Trigger guard',[(0,.012,.127),(0,-.02,.10),(0,.008,.065),(0,.03,.074)],.006,'graphite',2,1)
    box('Repair stripe',(0,-.003,.184),(.05,.052,.004),'cream',.004,1)

if __name__ == '__main__':
    start('prop_rivet_driver')
    build()
    finish('prop_rivet_driver','props','28 cm solar-install rivet tool with tape-wrapped nozzle and removable battery; muzzle faces −Y.',front_pitch=20)
