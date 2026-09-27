"""Generates a character's MPFB body from the BODY in its spec and saves it to the spec's BASE.

    python3 art/scripts/human/fetch_sources.py          # once per machine
    blender --background --factory-startup --python art/scripts/make_base.py -- char_installer
"""
import importlib
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from human import base  # noqa: E402

spec = importlib.import_module(sys.argv[sys.argv.index('--') + 1])
base.generate(spec.BODY, base.ROOT / spec.BASE)
