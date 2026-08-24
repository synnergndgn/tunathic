"""Pick the metronome frame that landed on the accented first beat.

The capture script grabs a short burst while the metronome runs. Exactly one
frame in every bar has lamp 1 lit, and which one it is depends on shutter luck.
This picks that frame and drops the rest, so the shipped screenshot is a real
frame of a running metronome rather than a retouched one.

Usage: python design/store/pick_beat_one.py <capture-dir> <final-stem>
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

# The four beat lamps on the phone profile, in raw capture pixels.
LAMP_Y = 720
LAMP_X = (334, 470, 607, 744)


def lit_lamp(image: Image.Image) -> int | None:
    """Which lamp is lit, if any. The active lamp's digit turns warm orange."""
    best, best_index = 0.0, None
    for index, x in enumerate(LAMP_X, start=1):
        r, g, b = image.getpixel((x, LAMP_Y))[:3]
        warmth = (r - b) / 255
        if warmth > best:
            best, best_index = warmth, index
    return best_index if best > 0.12 else None


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    directory, stem = Path(sys.argv[1]), sys.argv[2]
    frames = sorted(directory.glob(".metronome_*.png"))
    if not frames:
        raise SystemExit("No burst frames found. Did the capture script run?")

    chosen = None
    for frame in frames:
        with Image.open(frame) as image:
            if lit_lamp(image.convert("RGB")) == 1:
                chosen = frame
                break
    if chosen is None:
        raise SystemExit(
            "No frame landed on beat 1. Re-run the burst; do not edit a frame "
            "to move the lamp."
        )

    chosen.replace(directory / f"{stem}.png")
    for frame in frames:
        frame.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
