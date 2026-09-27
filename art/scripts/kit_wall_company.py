import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('kit_wall_company')
box('Graphite plinth',(0,0,.13),(1,1,.26),'graphite',.014,1)
box('Composite panel',(0,0,1.28),(.988,.988,2.04),'white',.024,2)
box('Top shadow seam',(0,0,2.31),(1,1,.035),'graphite',.009,1)
box('Clean top cap',(0,0,2.366),(1,1,.068),'white',.014,1)
box('Upper light seam',(0,-.494,2.316),(.87,.013,.015),mat('emissive_architecture','cyan',emission=1.6),.004,1)
for x in [-.44,.44]:
    box('Panel reveal',(x,-.495,1.2),(.009,.003,1.8),'concrete',0)
finish('kit_wall_company','kit','Solid capped 1 m wall block; fixed cyan seam is architectural.',front_pitch=25)
