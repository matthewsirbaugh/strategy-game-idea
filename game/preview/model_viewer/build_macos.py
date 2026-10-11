#!/usr/bin/env python3
"""Build a local Mac application with the installed official Godot runtime."""
import argparse
import os
from pathlib import Path
import plistlib
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path)
args = parser.parse_args()
source = Path(__file__).resolve().parent
output = args.output or source / 'build' / 'Model Library.app'
engine = shutil.which('godot')
if not engine:
    raise SystemExit('Godot 4 is required to build the viewer.')
contents = output / 'Contents'
macos = contents / 'MacOS'
resources = contents / 'Resources'
macos.mkdir(parents=True, exist_ok=True)
resources.mkdir(parents=True, exist_ok=True)
(source / 'build').mkdir(exist_ok=True)
(source / 'build' / '.gdignore').touch()
subprocess.run([engine, '--headless', '--path', str(source), '--editor', '--import', '--quit'], check=True)
subprocess.run([engine, '--headless', '--path', str(source), '--export-pack', 'Viewer pack', str(resources / 'ModelLibrary.pck')], check=True)
subprocess.run([engine, '--headless', '--path', str(source), '-s', str(source / 'render_icon.gd')], check=True)
legacy_project = resources / 'project'
if legacy_project.exists():
    shutil.rmtree(legacy_project)
iconset = source / 'build' / 'ModelLibrary.iconset'
iconset.mkdir(exist_ok=True)
for size in [16, 32, 128, 256, 512]:
    for retina in [False, True]:
        pixels = size * (2 if retina else 1)
        name = f'icon_{size}x{size}' + ('@2x' if retina else '') + '.png'
        subprocess.run(['sips', '-z', str(pixels), str(pixels), str(source / 'build' / 'icon.png'), '--out', str(iconset / name)], check=True, stdout=subprocess.DEVNULL)
subprocess.run(['iconutil', '-c', 'icns', str(iconset), '-o', str(resources / 'ModelLibrary.icns')], check=True)
shutil.copy2(Path(engine).resolve(), macos / 'Runtime')
os.chmod(macos / 'Runtime', 0o755)
license_path = source / 'Godot-LICENSE.txt'
if license_path.exists():
    shutil.copy2(license_path, resources / 'Godot-LICENSE.txt')
launcher = macos / 'ModelLibrary'
launcher.write_text('#!/bin/sh\nVIEWER_BUNDLE="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"\nexec "$VIEWER_BUNDLE/MacOS/Runtime" --main-pack "$VIEWER_BUNDLE/Resources/ModelLibrary.pck" "$@"\n')
os.chmod(launcher, 0o755)
(resources / 'library_path.txt').write_text(str(source.parents[1] / 'assets') + '\n')
info = {
    'CFBundleName': 'Model Library', 'CFBundleDisplayName': 'Model Library',
    'CFBundleIdentifier': 'com.bryson.modellibrary', 'CFBundleExecutable': 'ModelLibrary',
    'CFBundlePackageType': 'APPL', 'CFBundleShortVersionString': '1.0', 'CFBundleVersion': '1',
    'NSHighResolutionCapable': True, 'LSMinimumSystemVersion': '12.0',
    'CFBundleIconFile': 'ModelLibrary.icns',
    'NSHumanReadableCopyright': 'Local project tool by Astra for Bryson.',
}
with (contents / 'Info.plist').open('wb') as stream:
    plistlib.dump(info, stream)
subprocess.run(['codesign', '--force', '--deep', '--sign', '-', str(output)], check=True)
print(output)
