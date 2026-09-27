import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('prop_server_rack')
box('Server cabinet',(0,0,1),(.72,.64,2),'graphite',.035,2)
box('Door recess',(0,-.325,1.03),(.60,.018,1.78),'glass',.02,2)
for i in range(9):
    z=.27+i*.185
    box('Server sled',(0,-.35,z),(.51,.044,.135),'offline',.009,1)
    box('Sled handle',(.16,-.378,z),(.13,.014,.022),'steel',.004,1)
    box('Warm activity LED',(-.19,-.378,z),(.019,.012,.012),warm(),.003,1)
    for x in [-.12,-.07,-.02]:
        box('Cooling vent',(x,-.376,z),(.02,.007,.052),'graphite',0)
for x in [-.31,.31]:
    box('Vertical rail',(x,-.348,1.02),(.025,.02,1.85),'steel',.004,1)
finish('prop_server_rack','props','Warm activity LEDs only; deliberately no ownership ring because this rack is not interactive.',front_pitch=20)
