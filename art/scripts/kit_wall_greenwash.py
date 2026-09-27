import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('kit_wall_greenwash')
box('White composite backing',(0,.04,1.2),(1,.92,2.4),'white',.024,1)
for x in [-.35,0,.35]:
    box('Timber vertical',(x,-.447,1.19),(.035,.052,2.24),'timber',.006,1)
for z in [.34,.84,1.34,1.84,2.28]:
    box('Trellis crosspiece',(0,-.464,z),(.89,.034,.032),'timber',.005,1)
for i in range(3):
    x = -.3+i*.3
    tube('Living vine',[(x,-.48,.05),(x+.08,-.48,.7),(x-.06,-.48,1.4),(x+.03,-.48,2.3)],.009,'moss',2,0)
    for j in range(12):
        z = .2+j*.174
        side = (-1)**j
        leaf('Vine leaf',(x,-.48,z),(x+side*.13,-.498,z+.15),.1,['sage','moss','leaf_light'][j%3])
finish('kit_wall_greenwash','kit','Company composite behind a shallow timber trellis; leaves stay inside the tile.',front_pitch=23)
