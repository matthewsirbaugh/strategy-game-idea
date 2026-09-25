import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

def build(width=1):
    for y in [-.41,.41]:
        for z in [.135,.335,.535]:
            box('Reclaimed plank',(0,y,z),(width-.10,.08,.18),'timber',.008,1)
    for x in [-width/2+.08,width/2-.08]:
        box('Folded steel end',(x,0,.34),(.06,.9,.62),mat('planter_steel','webbing',metal=.35),.01,1)
    box('Dark potting soil',(0,0,.60),(width-.18,.75,.06),'soil',0)
    for i in range(int(22*width)):
        x,y = random.uniform(-width/2+.15,width/2-.15),random.uniform(-.32,.32)
        h = random.uniform(.09,.20)
        for s in [-1,1]:
            leaf('Herb leaf',(x,y,.615),(x+s*.085,y+.03,.615+h),.075,['sage','moss','leaf_light'][i%3])
    for i in range(int(16*width)):
        x,y = random.uniform(-width/2+.15,width/2-.15),random.uniform(-.28,.28)
        h = random.uniform(.18,.28)
        mesh('Tall grass',[(x-.012,y,.62),(x+.012,y,.62),(x+.05,y+.045,.62+h)],[(0,1,2)],'sage')

if __name__ == '__main__':
    start('kit_cover_planter')
    build()
    finish('kit_cover_planter','kit','No textures. 1×1 tile; timber box is 0.65 m and foliage reaches 0.9 m.',front_pitch=29)
