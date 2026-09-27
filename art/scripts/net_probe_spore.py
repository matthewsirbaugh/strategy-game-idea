import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *

def build():
    sphere('Amber seed',(0,0,.018),(.008,.008,.018),mat('spore_shell','amber',metal=.25,rough=.36),16,10)
    cylinder('Magnetic foot',(0,0,.004),.009,.008,'graphite',12,bevel=.001)
    rod('Seed neck',(0,0,.028),(0,0,.057),.0018,'gold',8)
    for i in range(12):
        a=i*math.tau/12
        tip=(.026*math.cos(a),.026*math.sin(a),.074)
        tube('Parachute filament',[(0,0,.051),(.015*math.cos(a),.015*math.sin(a),.069),tip],.0007,'cream',2,0)
        rod('Fine filament',tip,(tip[0]*1.12,tip[1]*1.12,.078),.00045,'cream',5)
    sphere('Glowing tip',(0,0,.077),(.0025,.0025,.0025),mat('emissive_spore','amber',emission=2),12,6)

if __name__ == '__main__':
    start('net_probe_spore')
    build()
    finish('net_probe_spore','network','Actual 8 cm sensor spore; nearly invisible at default zoom, so gameplay needs a marker.',front_pitch=20)
