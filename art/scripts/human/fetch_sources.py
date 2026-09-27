"""Downloads what body generation needs into art/vendor/_sources/ (git-ignored): the pinned MPFB2
checkout and the two CC0 MakeHuman asset packs. Plain Python 3, no Blender:

    python3 art/scripts/human/fetch_sources.py
"""
import subprocess
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCES = ROOT / 'art/vendor/_sources'
MPFB_COMMIT = '7fcc8df56f26776923e0a825f4551c3c3779befe'
PACKS = {
    'makehuman_system_assets_cc0': 'https://files.makehumancommunity.org/asset_packs/makehuman_system_assets/makehuman_system_assets_cc0.zip',
    'skins01_cc0': 'https://files.makehumancommunity.org/asset_packs/skins01/skins01_cc0.zip',
}


def main():
    SOURCES.mkdir(parents=True, exist_ok=True)
    mpfb = SOURCES / 'mpfb2'
    if not mpfb.exists():
        subprocess.run(['git', 'clone', '-q', 'https://github.com/makehumancommunity/mpfb2.git', str(mpfb)], check=True)
    subprocess.run(['git', '-C', str(mpfb), 'checkout', '-q', MPFB_COMMIT], check=True)
    for name, url in PACKS.items():
        folder = SOURCES / name
        if folder.exists():
            continue
        archive = SOURCES / f'{name}.zip'
        urllib.request.urlretrieve(url, archive)
        with zipfile.ZipFile(archive) as z:
            z.extractall(folder)
        archive.unlink()
    print('sources ready in', SOURCES)


if __name__ == '__main__':
    main()
