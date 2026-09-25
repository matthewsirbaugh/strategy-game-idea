import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('kit_floor_commons')
box('Mortar slab',(0,0,-.11),(1,1,.18),'soil',.004,1)
colors = ['terra','brick','cream','timber','terra','brick']
for row in range(4):
    for col in range(3):
        left = -.5+col/3
        box('Reclaimed paver',(left+1/6,-.375+row*.25,-.034),(1/3-.012,.238,.068),colors[(row*3+col)%6],.009,1)
for i in range(7):
    x = [-1/6,1/6][i%2]
    y = random.uniform(-.44,.44)
    leaf('Joint moss',(x,y,.001),(x+random.uniform(-.02,.02),y+.048,.003),.022,'moss')
finish('kit_floor_commons','kit','No textures. Twelve salvaged pavers with sparse moss; whole-tile footprint.',front_pitch=48)
