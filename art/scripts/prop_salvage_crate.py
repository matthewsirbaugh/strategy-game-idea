import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

def build():
    box('Crate floor',(0,0,.05),(.83,.74,.10),'timber',.013,1)
    for x in [-.385,.385]:
        for y in [-.335,.335]:
            box('Steel corner',(x,y,.295),(.055,.055,.59),'webbing',.009,1)
    for z in [.18,.34,.5]:
        for y in [-.347,.347]:
            box('Side board',(0,y,z),(.80,.045,.14),'timber',.009,1)
        for x in [-.395,.395]:
            box('End board',(x,0,z),(.045,.70,.14),'timber',.009,1)
    box('Salvaged battery',(-.13,0,.40),(.24,.40,.28),'white',.032,2)
    box('Battery terminal',(-.13,-.16,.54),(.10,.08,.028),'graphite',.008,1)
    for x in [.1,.2,.3]:
        cylinder('Spare conduit',(x,.13,.39),.028,.36,'steel',12,rot=(math.pi/2,0,0))
    tube('Coiled cable',[(.13,-.12,.33),(.26,-.2,.45),(.29,.1,.5),(.11,.2,.44),(.08,-.1,.4)],.023,'terra',4,1)
    box('Cream repair label',(0,-.374,.34),(.22,.005,.096),'cream',.005,1)
    for x in [-.05,0,.05]:
        box('Inventory mark',(x,-.378,.34),(.012,.002,.05),'webbing',0)

if __name__ == '__main__':
    start('prop_salvage_crate')
    build()
    finish('prop_salvage_crate','props','No textures. Open crate of salvaged battery, conduit and cloth-wrapped cable.',front_pitch=31)
