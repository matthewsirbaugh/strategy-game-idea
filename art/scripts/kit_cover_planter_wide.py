import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from common import *
from kit_cover_planter import build

start('kit_cover_planter_wide')
build(2)
finish('kit_cover_planter_wide','kit','2×1 tile version shares the narrow planter construction.',front_pitch=29)
