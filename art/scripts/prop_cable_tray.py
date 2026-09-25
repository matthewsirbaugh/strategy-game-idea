import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('prop_cable_tray')
for x in [-.15,.15]:
    box('Tray side',(x,0,.064),(.025,1,.12),mat('galvanized','steel',metal=.65),.006,1)
for y in [-.45,-.225,0,.225,.45]:
    box('Rung',(0,y,.012),(.30,.025,.024),'steel',.005,1)
for i in range(5):
    x=-.105+i*.05
    tube('Cable run',[(x,-.49,.048),(x+.016,-.17,.055),(x-.008,.19,.05),(x,.49,.049)],.015,
        ['graphite','terra','graphite','webbing','graphite'][i],3,1)
for y in [-.27,.33]:
    box('Cloth repair tape',(0,y,.071),(.277,.068,.037),'terra',.012,2)
finish('prop_cable_tray','props','No textures. One-metre segment; local Z=0 is its mounting surface. Rotate the parent to hang overhead.',front_pitch=44)
