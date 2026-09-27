import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

def build(planted=False):
    box('Stone foot',(0,0,.10),(1,1,.2),'brick',.018,1)
    for i in range(9):
        c = ['#B47E49','#C28C52','#CB9860','#C18A54','#BA804E','#CA9761','#D0A069','#C69558','#D1A263'][i]
        box('Compacted earth layer',(0,0,.2+(i+.5)*.227),(.984,.984,.227),mat('earth_'+str(i),c,rough=.92),.006,1)
    box('Reclaimed timber cap',(0,0,2.32),(1,1,.16),'timber',.018,1)
    for x in [-.3,.3]:
        box('End grain seam',(x,0,2.4002),(.009,.91,.001),'brick',0)
    if planted:
        for i in range(16):
            x,y = random.uniform(-.43,.43),random.uniform(-.43,.43)
            leaf('Cap moss',(x,y,2.4),(x+.03,y+.065,2.44),.045,['moss','sage'][i%2])
        for i in range(12):
            x,y = random.uniform(-.4,.4),random.uniform(-.4,.4)
            mesh('Grass blade',[(x-.008,y,2.4),(x+.008,y,2.4),(x+.025,y+.015,2.51)],[(0,1,2)],'sage')

if __name__ == '__main__':
    start('kit_wall_commons')
    build()
    finish('kit_wall_commons','kit','Nine quiet earth strata under a timber cap.',front_pitch=25)
