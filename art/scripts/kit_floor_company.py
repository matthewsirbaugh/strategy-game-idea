import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('kit_floor_company')
box('Concrete slab',(0,0,-.105),(1,1,.19),'concrete',.008,1)
box('Polished terrazzo',(0,0,-.014),(.982,.982,.028),mat('polished_concrete','concrete',rough=.34),.005,1)
for i in range(32):
    x,y = random.uniform(-.46,.46),random.uniform(-.46,.46)
    r = random.uniform(.003,.009)
    mesh('Terrazzo inlay',[(x-r,y,.00015),(x+r,y,.00015),(x,y+r*1.2,.00015)],[(0,1,2)],
        mat('aggregate_'+str(i%3),['#C3BEB0','#BBBAB5','#EEEADD'][i%3]))
finish('kit_floor_company','kit','No textures. Restrained geometric terrazzo; slab spans −0.2 to 0 m.',front_pitch=48)
