import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('net_access_point')
box('Foot plate',(0,0,.025),(.44,.36,.05),'graphite',.04,3)
box('Kiosk shell',(0,0,.558),(.35,.25,1.035),'white',.065,5)
box('Service face',(0,-.128,.62),(.255,.024,.66),'graphite',.035,3)
box('Port recess',(0,-.144,.72),(.13,.012,.09),'glass',.012,2)
box('Physical socket',(0,-.153,.72),(.065,.006,.022),'steel',.003,1)
ring('Port indicator',(0,-.151,.91),.065,.008,status(),rot=(math.pi/2,0,0),major=28)
ring('Top ownership ring',(0,0,1.08),.092,.009,status(),major=32)
cylinder('Luminous cap',(0,0,1.082),.07,.012,status(),32,bevel=.002)
for z in [.29,.32,.35]:
    box('Intake slot',(0,-.145,z),(.14,.008,.008),'offline',.002,1)
tube('Floor conduit',[(0,.1,.16),(0,.21,.07),(0,.34,.035),(.22,.34,.025)],.017,'graphite',3,1)
finish('net_access_point','network','Ownership ring, port halo and top cap share status_ring; unambiguous top beacon.',front_pitch=25)
