"""Pick the metronome frame that landed on the accented first beat.

The capture script grabs a short burst while the metronome runs. Exactly one
frame in every bar has lamp 1 lit, and which one it is depends on shutter luck.
This picks that frame and drops the rest, so the shipped screenshot is a real
frame of a running metronome rather than a retouched one.

Usage:
    python design/store/pick_beat_one.py <capture-dir> <final-stem> \
        --lamps <x1,x2,x3,x4> --y <y>

The lamp coordinates are raw device pixels and live in
design/store/profiles/<profile>.env alongside the rest of the tap targets.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def lit_lamp(image: Image.Image, lamps: list[int], y: int) -> int | None:
    """Which lamp is lit, if any. The active lamp's digit turns warm orange."""
    best, best_index = 0.0, None
    for index, x in enumerate(lamps, start=1):
        r, _, b = image.getpixel((x, y))[:3]
        warmth = (r - b) / 255
        if warmth > best:
            best, best_index = warmth, index
    return best_index if best > 0.12 else None


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("stem")
    parser.add_argument("--lamps", required=True, help="comma-separated x centres")
    parser.add_argument("--y", required=True, type=int)
    args = parser.parse_args()

    lamps = [int(value) for value in args.lamps.split(",")]
    frames = sorted(args.directory.glob(".metronome_*.png"))
    if not frames:
        raise SystemExit("No burst frames found. Did the capture script run?")

    chosen = None
    for frame in frames:
        with Image.open(frame) as image:
            if lit_lamp(image.convert("RGB"), lamps, args.y) == 1:
                chosen = frame
                break
    if chosen is None:
        raise SystemExit(
            "No frame landed on beat 1. Re-run the burst; do not edit a frame "
            "to move the lamp."
        )

    chosen.replace(args.directory / f"{args.stem}.png")
    for frame in frames:
        frame.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
