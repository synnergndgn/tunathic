"""Show a listing icon the way Play will actually draw it.

Play does not display the uploaded 512 square as-is: it masks the corners with
its own rounded square and adds its own drop shadow. Anything the icon draws
near its own edge — a frame, a border, corners of its own — collides with that
mask and reads as a broken double edge.

This renders each icon through the same treatment so the collision is visible
before upload rather than in Play Console. Google describes the radius as
dynamic rather than fixed, so two radii are drawn: the ~22 % Play Console
currently shows, and the 30 % the icon-design spec mentions.

Usage: python design/store/play_icon_preview.py <icon.png> [more.png ...]
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

CARD = (250, 250, 252)
RADII = (0.22, 0.30)
TILE = 256
PAD = 28


def masked(icon: Image.Image, size: int, radius_fraction: float) -> Image.Image:
    """The icon under Play's corner mask, with Play's shadow under it."""
    icon = icon.convert("RGBA").resize((size, size), Image.LANCZOS)
    radius = round(size * radius_fraction)

    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)

    tile = Image.new("RGBA", (size + PAD * 2, size + PAD * 2), (0, 0, 0, 0))

    shadow = Image.new("RGBA", tile.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [PAD, PAD + 6, PAD + size, PAD + size + 6], radius=radius, fill=(30, 26, 22, 70)
    )
    tile.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(size * 0.035)))

    face = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    face.paste(icon, (0, 0), mask)
    tile.alpha_composite(face, (PAD, PAD))
    return tile


def main() -> None:
    paths = [Path(p) for p in sys.argv[1:]]
    if not paths:
        raise SystemExit(__doc__)

    cell = TILE + PAD * 2
    sheet = Image.new("RGB", (cell * len(RADII) * 2, cell * len(paths)), CARD)
    for row, path in enumerate(paths):
        with Image.open(path) as opened:
            icon = opened.copy()
        column = 0
        for fraction in RADII:
            for size in (TILE, 96):
                tile = masked(icon, size, fraction)
                x = column * cell + (cell - tile.width) // 2
                y = row * cell + (cell - tile.height) // 2
                sheet.paste(tile, (x, y), tile)
                column += 1

    out = paths[0].parent / "_play_mask_preview.png"
    sheet.save(out)
    print(f"  {out}  (rows: {', '.join(p.stem for p in paths)}; 22% and 30% masks)")


if __name__ == "__main__":
    main()
