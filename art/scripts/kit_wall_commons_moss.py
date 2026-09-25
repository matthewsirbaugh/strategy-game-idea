import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *
from kit_wall_commons import build

start('kit_wall_commons_moss')
build(True)
finish('kit_wall_commons_moss','kit','No textures. Wall structure is 2.4 m; sparse cap growth reaches 2.51 m.',front_pitch=25)
