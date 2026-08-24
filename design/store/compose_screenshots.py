"""Compose Google Play screenshots from raw Tunathic captures.

The raw capture is never retouched. It is cropped below the status bar, scaled
down proportionally and placed on an ivory workbench canvas with one caption
above it. No value, label, reading or state inside the app UI is edited.

Two things force the canvas. Play rejects a screenshot whose long side is more
than twice its short side, and a modern phone renders 1080x2400 (2.22:1). And
the app's daylight theme is ivory, so the capture needs a charcoal device body
to sit in or the screen stops reading as a screen.

Usage:
    python design/store/compose_screenshots.py <raw-dir> <out-dir> <en-US|tr-TR> <device>

    device: phone | tablet-7 | tablet-10
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))

from tunathic_brand import (  # noqa: E402
    BURNT_ORANGE,
    DEEP_CHARCOAL,
    device_frame,
    font,
    workbench,
)

# Canvas width per device class; height is always width * 16 / 9.
CANVAS_WIDTH = {"phone": 1350, "tablet-7": 1200, "tablet-10": 1600}

# Status bar height in raw capture pixels, per device class.
STATUS_BAR_PX = {"phone": 108, "tablet-7": 72, "tablet-10": 72}

# eyebrow / headline, per screenshot, per locale.
COPY: dict[str, dict[str, tuple[str, str]]] = {
    "en-US": {
        "01_toolkit": ("GUITAR TOOLKIT", "Every practice tool in one place"),
        "02_tuner": ("TUNER", "Tune faster. Play cleaner."),
        "03_tuner_chromatic": ("CHROMATIC", "Any note, any instrument"),
        "04_tuner_manual": ("AUTO / MANUAL", "Let it find the string, or pick it yourself"),
        "05_metronome": ("METRONOME", "Keep time with a native low-latency click"),
        "06_tuning_settings": ("TUNINGS & PITCH", "Drop D, DADGAD, open tunings, A4 430–450 Hz"),
        "07_chord_library": ("CHORDS", "Practical voicings with real fingerings"),
        "08_music_theory": ("THEORY", "Learn the theory behind what you play"),
    },
    "tr-TR": {
        "01_toolkit": ("GİTAR ARAÇ SETİ", "Tüm pratik araçların tek yerde"),
        "02_tuner": ("AKORT", "Hızlı akort. Temiz çalım."),
        "03_tuner_chromatic": ("KROMATİK", "Her nota, her enstrüman"),
        "04_tuner_manual": ("OTOMATİK / ELLE", "Teli kendi bulsun ya da sen seç"),
        "05_metronome": ("METRONOM", "Yerel, düşük gecikmeli metronomla tempoyu koru"),
        "06_tuning_settings": ("AKORT & REFERANS", "Drop D, DADGAD, açık akortlar, A4 430–450 Hz"),
        "07_chord_library": ("AKORLAR", "Gerçek basışlarıyla kullanışlı akorlar"),
        "08_music_theory": ("TEORİ", "Çaldığın şeyin teorisini öğren"),
    },
}


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt, max_width: int) -> list[str]:
    words, lines, line = text.split(), [], ""
    for word in words:
        candidate = f"{line} {word}".strip()
        if draw.textlength(candidate, font=fnt) <= max_width or not line:
            line = candidate
        else:
            lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def spaced(draw: ImageDraw.ImageDraw, xy, text: str, fnt, fill, tracking: float) -> float:
    x, y = xy
    for character in text:
        draw.text((x, y), character, font=fnt, fill=fill)
        x += draw.textlength(character, font=fnt) + tracking
    return x


def compose(raw: Path, out: Path, locale: str, device: str) -> None:
    key = raw.stem
    eyebrow, headline = COPY[locale][key]

    width = CANVAS_WIDTH[device]
    height = round(width * 16 / 9)
    canvas = workbench((width, height)).convert("RGB")
    draw = ImageDraw.Draw(canvas)

    margin = round(width * 0.085)
    eyebrow_font = font("bold", round(width * 0.021))
    headline_font = font("black", round(width * 0.052))

    # Caption block.
    y = round(height * 0.045)
    spaced(draw, (margin, y), eyebrow, eyebrow_font, BURNT_ORANGE, width * 0.0035)
    y += round(eyebrow_font.size * 2.0)
    for line in wrap(draw, headline, headline_font, width - margin * 2):
        draw.text((margin, y), line, font=headline_font, fill=DEEP_CHARCOAL)
        y += round(headline_font.size * 1.16)

    # Device. Whatever height is left, minus a bottom margin.
    top = y + round(height * 0.030)
    available = height - top - round(height * 0.030)

    shot = Image.open(raw).convert("RGB")
    usable = shot.height - STATUS_BAR_PX[device]
    bezel = max(8, round(width * 0.010))
    scale = min((available - bezel * 2) / usable, (width - margin * 2 - bezel * 2) / shot.width)
    body_width = round(shot.width * scale) + bezel * 2

    device_frame(
        canvas,
        shot,
        ((width - body_width) // 2, top),
        body_width,
        bezel=bezel,
        radius=round(width * 0.030),
        crop_top=STATUS_BAR_PX[device],
    )

    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out)
    print(f"  {out.name}  {width}x{height}")


def main() -> None:
    if len(sys.argv) != 5:
        raise SystemExit(__doc__)
    raw_dir, out_dir, locale, device = (
        Path(sys.argv[1]),
        Path(sys.argv[2]),
        sys.argv[3],
        sys.argv[4],
    )
    for raw in sorted(raw_dir.glob("*.png")):
        if raw.stem not in COPY[locale]:
            print(f"  skipped {raw.name}: no caption defined")
            continue
        compose(raw, out_dir / raw.name, locale, device)


if __name__ == "__main__":
    main()
