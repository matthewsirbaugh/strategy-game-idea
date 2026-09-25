import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('net_data_cache')
box('Monolith plinth',(0,0,.055),(.70,.54,.11),'graphite',.05,3)
box('Graphite core',(0,0,1.02),(.56,.42,1.86),mat('anodized_graphite','graphite',metal=.35,rough=.29),.05,4)
glass = mat('glass','#60767B',metal=.24,rough=.3)
for y in [-.23,.23]:
    box('Frosted glass face',(0,y,1.06),(.47,.024,1.67),glass,.025,3)
    for x in [-.20,.20]:
        box('Vertical ownership seam',(x,y*1.065,1.08),(.012,.013,1.5),status(),.005,2)
    for i in range(7):
        box('Storage lamella',(0,y*1.07,.49+i*.16),(.31,.013,.024),mat('inner_blades','#8BA3A3',metal=.35),.006,1)
    box('Quiet central aperture',(0,y*1.08,1.45),(.19,.014,.13),'glass',.022,2)
    ring('Data seal',(0,y*1.12,1.45),.043,.006,status(),rot=(math.pi/2,0,0),major=24)
box('Bone crown',(0,0,1.965),(.56,.43,.07),'white',.025,3)
ring('Crown ownership ring',(0,0,2.003),.145,.009,status(),major=40)
box('Crown dark field',(0,0,1.999),(.33,.33,.008),'glass',.03,3)
finish('net_data_cache','network','No textures. Frosted faces are opaque for reliable sorting. Recolor status_ring green when secured; pulse in game.',front_pitch=22)
