import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('net_camera')
box('Pole foot',(0,.13,.04),(.40,.4,.08),'graphite',.06,2)
cylinder('Pole',(0,.13,1.0),.046,1.92,mat('pole_metal','graphite',metal=.5),16)
rod('Cantilever',(0,.13,1.94),(0,-.11,2.02),.035,'steel',12)
cylinder('Gimbal',(0,-.11,2.02),.068,.18,'graphite',20,rot=(0,math.pi/2,0))
box('Capsule housing',(0,-.14,2.12),(.28,.42,.16),'white',.07,5)
box('Dark lens face',(0,-.355,2.105),(.218,.025,.125),'glass',.045,4)
cylinder('Camera lens',(0,-.376,2.105),.043,.018,mat('lens_optics','#213946',metal=.45,rough=.13),24,rot=(math.pi/2,0,0))
ring('Lens ownership ring',(0,-.39,2.105),.059,.007,status(),rot=(math.pi/2,0,0),major=24)
ring('Top ownership ring',(0,-.13,2.199),.065,.006,status(),major=24)
box('Clamp collar',(0,.13,1.77),(.135,.125,.055),'white',.018,2)
tube('Arm cable',[(.045,.13,1.84),(.08,.05,1.90),(.08,-.08,2.025)],.009,'graphite',3,1)
finish('net_camera','network','Pole variant first; lens halo is repeated on top for tactics readability.',front_pitch=20)
