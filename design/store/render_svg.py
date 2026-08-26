"""Render the Tunathic store SVGs to PNG with headless Edge/Chromium.

The SVGs under `design/store/` are the masters. This script is the only step
between them and an upload-ready PNG, so an export is always reproducible from
source rather than from someone's editor session.

Usage:
    python design/store/render_svg.py <input.svg> <output.png> <width> <height>
    python design/store/render_svg.py --all            # every store asset

Google Play wants the listing icon as a 512x512 32-bit PNG and the feature
graphic as 1024x500 with no alpha, so the icon keeps its alpha channel and the
feature graphic is flattened onto opaque ivory.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
STORE = ROOT / "design" / "store"

BROWSER_CANDIDATES = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "chromium",
    "google-chrome",
]

# name -> (svg, png, width, height, flatten)
ASSETS = {
    "icon-a": ("icon/tunathic_icon_a_instrument_face.svg", "out/icon_a_512.png", 512, 512, False),
    "icon-b": ("icon/tunathic_icon_b_pedal_face.svg", "out/icon_b_512.png", 512, 512, False),
    "icon-c": ("icon/tunathic_icon_c_fork_well.svg", "out/icon_c_512.png", 512, 512, False),
    "feature-a-en": ("feature_graphic/tunathic_feature_a_faceplate.svg", "out/feature_a_1024x500.png", 1024, 500, True),
    "feature-a-tr": ("feature_graphic/tunathic_feature_a_faceplate_tr.svg", "out/feature_a_tr_1024x500.png", 1024, 500, True),
}

# Feature graphic B is not listed: it composites a real screenshot, so it is
# built by compose_feature_graphic_b.py rather than rendered from SVG.

IVORY = (255, 253, 248)


def find_browser() -> str:
    for candidate in BROWSER_CANDIDATES:
        if Path(candidate).is_file():
            return candidate
        found = shutil.which(candidate)
        if found:
            return found
    raise SystemExit(
        "No Chromium-based browser found. Install Edge or Chrome, or add one to PATH."
    )


def render(svg: Path, png: Path, width: int, height: int, flatten: bool) -> None:
    png.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as profile:
        subprocess.run(
            [
                find_browser(),
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--force-device-scale-factor=1",
                f"--user-data-dir={profile}",
                f"--window-size={width},{height}",
                "--default-background-color=00000000",
                f"--screenshot={png}",
                svg.resolve().as_uri(),
            ],
            check=True,
            capture_output=True,
        )
    from PIL import Image

    with Image.open(png) as opened:
        image = opened.convert("RGBA")
    if flatten:
        # The feature graphic must ship with no alpha channel at all.
        canvas = Image.new("RGB", image.size, IVORY)
        canvas.paste(image, mask=image.split()[3])
        canvas.save(png)
    else:
        # Play asks for the listing icon as a 32-bit PNG. Headless Chromium
        # drops the channel when nothing on the page is transparent, so put it
        # back rather than uploading a 24-bit file.
        image.save(png)
    def shown(path: Path) -> str:
        resolved = path.resolve()
        try:
            return str(resolved.relative_to(ROOT))
        except ValueError:
            return str(resolved)

    print(f"  {shown(svg)} -> {shown(png)}  ({width}x{height})")


def main() -> None:
    args = sys.argv[1:]
    if args[:1] == ["--all"]:
        for name, (svg, png, width, height, flatten) in ASSETS.items():
            source = STORE / svg
            if not source.is_file():
                print(f"  skipped {name}: {svg} not present yet")
                continue
            render(source, STORE / png, width, height, flatten)
        return
    if len(args) != 4:
        raise SystemExit(__doc__)
    render(Path(args[0]), Path(args[1]), int(args[2]), int(args[3]), False)


if __name__ == "__main__":
    main()
