import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('kit_floor_company_light')
box('Concrete slab',(0,0,-.1),(1,1,.2),mat('polished_concrete','concrete',rough=.34),.008,1)
box('Recess',(0,-.43,-.002),(.88,.042,.006),'graphite',.005,1)
box('Inset guide light',(0,-.43,.001),(.78,.018,.004),mat('emissive_guide','cyan',emission=1.8),.004,1)
finish('kit_floor_company_light','kit','Fixed cyan architectural guide; not an ownership indicator.',front_pitch=48)
