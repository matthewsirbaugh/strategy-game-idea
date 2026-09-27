import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('kit_exit_hatch')
box('Threshold apron',(0,0,.035),(2,2,.07),'concrete',.012,1)
for i in range(6):
    height=(i+1)*.18
    box('Reclaimed stair',(0,-.70+i*.26,height/2+.07),(1.15,.27,height),'timber',.01,1)
for x in [-.75,.75]:
    box('Handrail post',(x,.79,1.1),(.075,.075,2.06),'timber',.01,1)
    tube('Hand-bent railing',[(x,-.80,.63),(x,-.65,.78),(x,.79,1.87),(x,.79,2.13)],.022,'webbing',2,0)
box('Open roof hatch lid',(0,.84,1.80),(1.28,.072,1.34),'teal',.025,1,rot=(math.radians(-12),0,0))
box('Arrow backing',(0,.777,1.95),(.57,.02,.55),'cream',.008,1)
mesh('Hand-painted up arrow',[(-.08,.76,1.77),(.08,.76,1.77),(.08,.76,1.99),(.20,.76,1.99),
    (0,.76,2.17),(-.2,.76,1.99),(-.08,.76,1.99)],[(0,1,2,3,4,5,6)],'terra')
tube('Warm light cable',[(-.8,.64,2.24),(0,.64,2.13),(.8,.64,2.24)],.008,'graphite',4,0)
for x,z in [(-.6,2.195),(0,2.115),(.6,2.195)]:
    sphere('Warm bulb',(x,.64,z),(.04,.04,.05),warm(),8,4)
finish('kit_exit_hatch','kit','2×2 extraction vignette: six roofward steps, open hatch and hand-painted arrow. Layout is a proposal for review.',front_pitch=27)
