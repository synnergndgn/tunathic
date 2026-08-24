"""Feature graphic concept B: the real tuner, in a real phone, on the workbench.

Concept A is drawn entirely in SVG and shows the brand as an object. B is the
counterpart that shows the product: the actual UI, captured from a build, in a
device body that runs off the bottom edge so the graphic reads as a photograph
of a phone lying on the bench rather than as a boxed thumbnail.

The capture is never retouched. It is cropped below the status bar, scaled down
and placed; nothing inside the app UI is edited, recoloured or composited.

Usage:
    python design/store/compose_feature_graphic_b.py <capture.png> <out.png> [en|tr]
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tunathic_brand import (  # noqa: E402
    BURNT_ORANGE,
    DEEP_CHARCOAL,
    MUTED_INK,
    WARM_ORANGE,
    device_frame,
    engraved_rule,
    font,
    glow,
    lamp,
    workbench,
)

SIZE = (1024, 500)

COPY = {
    "en": {
        "eyebrow": "GUITAR TOOLKIT",
        "tagline": "Tune. Train. Create.",
        "tools": "Tuner · Metronome · Chords · Scales · Theory",
    },
    "tr": {
        "eyebrow": "GİTAR ARAÇ SETİ",
        "tagline": "Akort Et. Çalış. Üret.",
        "tools": "Akort · Metronom · Akor · Gam · Teori",
    },
}

# The Medium_Phone emulator draws its status bar in the top 108 px at 420 dpi.
STATUS_BAR_PX = 108


def spaced(draw: ImageDraw.ImageDraw, xy, text, fnt, fill, tracking: float) -> None:
    """Draw letter-spaced text. Pillow has no tracking, so step glyph by glyph."""
    x, y = xy
    for character in text:
        draw.text((x, y), character, font=fnt, fill=fill)
        x += draw.textlength(character, font=fnt) + tracking


def main() -> None:
    if len(sys.argv) not in (3, 4):
        raise SystemExit(__doc__)
    capture = Path(sys.argv[1])
    out = Path(sys.argv[2])
    locale = sys.argv[3] if len(sys.argv) == 4 else "en"
    copy = COPY[locale]

    canvas = workbench(SIZE)
    glow(canvas, (790, 300), 300, alpha=40)
    canvas = canvas.convert("RGB")
    draw = ImageDraw.Draw(canvas)

    # Left: the engraved brand block.
    lamp(draw, (84, 140))
    spaced(draw, (108, 129), copy["eyebrow"], font("bold", 18), BURNT_ORANGE, 4.5)

    draw.text((72, 172), "Tunathic", font=font("black", 92), fill=DEEP_CHARCOAL)
    draw.text((76, 282), copy["tagline"], font=font("bold", 27), fill=WARM_ORANGE)

    engraved_rule(draw, 78, 340, 290)
    draw.text((76, 362), copy["tools"], font=font("semibold", 21), fill=MUTED_INK)

    # Right: the phone, running off the bottom edge.
    shot = Image.open(capture).convert("RGB")
    device_frame(canvas, shot, (632, 44), 336, crop_top=STATUS_BAR_PX)

    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out)
    print(f"  {out}  {canvas.size[0]}x{canvas.size[1]}  ({locale})")


if __name__ == "__main__":
    main()
