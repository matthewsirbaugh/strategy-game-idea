import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

start('net_door')
for x in [-.45,.45]:
    box('Graphite jamb',(x,0,1.2),(.10,.26,2.4),'graphite',.025,2)
box('Door lintel',(0,0,2.47),(1,.28,.14),'graphite',.025,2)
box('Lintel facing',(0,-.147,2.47),(.83,.026,.092),'white',.01,2)
box('Threshold',(0,0,.012),(.8,.28,.024),'steel',.008,1)
panel=[]
panel.append(box('Sliding white panel',(0,.04,1.21),(.79,.10,2.37),'white',.018,2))
panel.append(box('Horizontal slot window',(0,-.016,1.70),(.62,.013,.19),'glass',.035,3))
panel.append(box('Window inner glint',(0,-.024,1.73),(.51,.004,.016),'steel',.003,1))
panel.append(box('Lower kick plate',(0,-.02,.17),(.72,.016,.25),'graphite',.012,2))
panel.append(box('Recessed pull',(-.28,-.022,1.20),(.035,.013,.21),'graphite',.008,2))
slider = pivot('door_slide',(0,0,0),panel)
action(slider,'closed',[(1,(0,0,0)),(2,(0,0,0))])
action(slider,'open',[(1,(0,0,0)),(13,(.82,0,0))])
slider.location=(0,0,0)
box('Lock terminal',(.435,-.225,1.18),(.13,.15,.25),'white',.026,3)
ring('Lock top ownership',(.435,-.225,1.313),.042,.008,status(),major=24)
box('Lock face',(.435,-.305,1.19),(.081,.014,.095),'glass',.015,2)
finish('net_door','network','No textures. Clear opening 2.4 m; lintel reaches 2.54 m. open slides 0.82 m into the adjacent wall; recolor status_ring in game.',front_pitch=18)
