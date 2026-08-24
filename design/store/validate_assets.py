"""Re-check exported Tunathic store assets against Play's format rules.

This only enforces the mechanical rules — size, mode, alpha, byte budget, and
the 2:1 aspect limit. The content rules (no dark captures, no truncated labels,
no unverifiable claims) are in docs/store_assets/play_upload_checklist.md and
still need a pair of eyes.

Usage:
    python design/store/validate_assets.py [asset-dir]

    asset-dir defaults to design/store/out.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ICON_MAX_BYTES = 1024 * 1024
SCREENSHOT_MAX_BYTES = 8 * 1024 * 1024


def has_alpha(image: Image.Image) -> bool:
    return image.mode in ("RGBA", "LA") or "transparency" in image.info


def check_icon(path: Path, fail: list[str]) -> None:
    with Image.open(path) as image:
        if image.size != (512, 512):
            fail.append(f"{path.name}: {image.size} != 512x512")
        if not has_alpha(image):
            fail.append(f"{path.name}: listing icon must be 32-bit PNG with alpha")
    if path.stat().st_size > ICON_MAX_BYTES:
        fail.append(f"{path.name}: {path.stat().st_size} bytes > 1,024 KB")


def check_feature(path: Path, fail: list[str]) -> None:
    with Image.open(path) as image:
        if image.size != (1024, 500):
            fail.append(f"{path.name}: {image.size} != 1024x500")
        if has_alpha(image):
            fail.append(f"{path.name}: feature graphic must have no alpha")


def check_screenshot(path: Path, fail: list[str]) -> None:
    with Image.open(path) as image:
        width, height = image.size
        if has_alpha(image):
            fail.append(f"{path.name}: screenshots must have no alpha")
        short, long = min(width, height), max(width, height)
        if short < 320 or long > 3840:
            fail.append(f"{path.name}: {width}x{height} outside 320-3,840 px")
        if long > short * 2:
            fail.append(f"{path.name}: {width}x{height} is past the 2:1 limit")
    if path.stat().st_size > SCREENSHOT_MAX_BYTES:
        fail.append(f"{path.name}: {path.stat().st_size} bytes > 8 MB")


def classify(path: Path) -> str | None:
    """Which Play rule set applies to this file.

    The folder wins over the filename, because an upload set names its files
    for Play Console (`tunathic_play_icon_512.png`) while the render directory
    names them for the concept they came from (`icon_a_512.png`).
    """
    for part in reversed(path.parts[:-1]):
        if part == "icon":
            return "icon"
        if part == "feature_graphic":
            return "feature"
        if part == "screenshots":
            return "screenshot"
    if path.name.startswith("icon_"):
        return "icon"
    if path.name.startswith("feature_"):
        return "feature"
    if re.match(r"^\d{2}_", path.name):
        return "screenshot"
    return None


def main() -> None:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "design" / "store" / "out"
    if not root.is_dir():
        raise SystemExit(f"{root} is not a directory")

    fail: list[str] = []
    checked = 0
    for path in sorted(root.rglob("*.png")):
        if path.name.startswith("_"):
            continue
        kind = classify(path)
        if kind is None:
            print(f"  SKIP  {path.name}: cannot tell what kind of asset this is")
            continue
        {"icon": check_icon, "feature": check_feature, "screenshot": check_screenshot}[
            kind
        ](path, fail)
        checked += 1

    for line in fail:
        print(f"  FAIL  {line}")
    print(f"{checked} file(s) checked, {len(fail)} problem(s).")
    sys.exit(1 if fail else 0)


if __name__ == "__main__":
    main()
