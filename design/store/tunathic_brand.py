"""Shared painting helpers for the Tunathic store assets.

Everything marketing draws by hand lives here so a caption, a feature graphic
and a screenshot canvas cannot drift apart. The palette is copied from
`lib/app/theme/app_colors.dart`; if that file changes, change this one.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# Palette, straight out of AppColors (light "daylight workbench" theme).
WARM_ORANGE = (200, 88, 24)  # #C85818
AMBER = (225, 132, 47)  # #E1842F
BURNT_ORANGE = (168, 67, 18)  # #A84312
DEEP_CHARCOAL = (48, 40, 34)  # #302822
IN_TUNE_GREEN = (53, 115, 76)  # #35734C
OFF_WHITE = (255, 253, 248)  # #FFFDF8
STAGE_TOP = (255, 253, 248)  # #FFFDF8
STAGE_BOTTOM = (241, 232, 220)  # #F1E8DC
PANEL_EDGE = (217, 201, 184)  # #D9C9B8
PANEL_EDGE_STRONG = (185, 159, 136)  # #B99F88
MUTED_INK = (107, 87, 72)

FONTS = {
    "regular": r"C:\Windows\Fonts\segoeui.ttf",
    "semibold": r"C:\Windows\Fonts\seguisb.ttf",
    "bold": r"C:\Windows\Fonts\segoeuib.ttf",
    "black": r"C:\Windows\Fonts\seguibl.ttf",
    "mono": r"C:\Windows\Fonts\consola.ttf",
    "mono-bold": r"C:\Windows\Fonts\consolab.ttf",
}


def font(weight: str, size: int) -> ImageFont.FreeTypeFont:
    path = FONTS[weight]
    if not Path(path).is_file():
        raise SystemExit(f"Missing font {path}. Edit FONTS in tunathic_brand.py.")
    return ImageFont.truetype(path, size)


def workbench(size: tuple[int, int]) -> Image.Image:
    """The warm ivory stage every screen in the app stands on.

    A top-to-bottom ivory gradient, the fine horizontal grain the studio
    surfaces are painted with, and a soft vignette so a large flat area does
    not read as one dead fill.
    """
    width, height = size
    base = Image.new("RGB", size, STAGE_TOP)
    draw = ImageDraw.Draw(base)
    for y in range(height):
        t = y / max(height - 1, 1)
        draw.line(
            [(0, y), (width, y)],
            fill=tuple(
                round(a + (b - a) * t) for a, b in zip(STAGE_TOP, STAGE_BOTTOM)
            ),
        )

    grain = Image.new("RGBA", size, (0, 0, 0, 0))
    grain_draw = ImageDraw.Draw(grain)
    for y in range(0, height, 6):
        grain_draw.line([(0, y), (width, y)], fill=(107, 74, 50, 9))
    base = Image.alpha_composite(base.convert("RGBA"), grain).convert("RGB")

    vignette = Image.new("L", size, 0)
    ImageDraw.Draw(vignette).ellipse(
        [-width * 0.25, -height * 0.55, width * 1.25, height * 1.55], fill=255
    )
    vignette = vignette.filter(ImageFilter.GaussianBlur(width * 0.10))
    shade = Image.new("RGB", size, (150, 122, 96))
    return Image.composite(base, Image.blend(base, shade, 0.16), vignette)


def rounded_shadow(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    radius: int,
    *,
    blur: int = 22,
    offset: tuple[int, int] = (6, 10),
    alpha: int = 74,
) -> None:
    """The contact + ambient shadow a raised panel casts, lit from the top left."""
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    left, top, right, bottom = box
    ImageDraw.Draw(layer).rounded_rectangle(
        [left + offset[0], top + offset[1], right + offset[0], bottom + offset[1]],
        radius=radius,
        fill=(90, 58, 36, alpha),
    )
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(layer) if canvas.mode == "RGBA" else canvas.paste(
        Image.alpha_composite(canvas.convert("RGBA"), layer).convert("RGB"), (0, 0)
    )


def device_frame(
    canvas: Image.Image,
    screenshot: Image.Image,
    top_left: tuple[int, int],
    body_width: int,
    *,
    bezel: int = 11,
    radius: int = 34,
    crop_top: int = 0,
    body_color: tuple[int, int, int] = DEEP_CHARCOAL,
) -> tuple[int, int]:
    """Place a real capture inside an ivory phone body.

    `crop_top` drops that many source pixels off the top of the capture, which
    is how the emulator status bar is removed without touching the app pixels
    below it. Returns the body's (width, height) as drawn; the caller is free
    to run it off the bottom of the canvas.

    The body defaults to charcoal because the app's daylight theme is ivory:
    an ivory body on an ivory bench leaves the screen with nothing to sit
    against, and the UI stops reading as a screen at all.
    """
    shot = screenshot.crop((0, crop_top, screenshot.width, screenshot.height))
    screen_width = body_width - bezel * 2
    scale = screen_width / shot.width
    screen_height = round(shot.height * scale)
    shot = shot.resize((screen_width, screen_height), Image.LANCZOS)

    body_height = screen_height + bezel * 2
    x, y = top_left

    rounded_shadow(
        canvas,
        (x, y, x + body_width, y + body_height),
        radius,
        blur=26,
        offset=(8, 14),
        alpha=86,
    )

    body = Image.new("RGBA", (body_width, body_height), (0, 0, 0, 0))
    body_draw = ImageDraw.Draw(body)
    body_draw.rounded_rectangle(
        [0, 0, body_width - 1, body_height - 1], radius=radius, fill=body_color + (255,)
    )
    body_draw.rounded_rectangle(
        [1, 1, body_width - 2, body_height - 2],
        radius=radius - 1,
        outline=(255, 255, 255, 44),
        width=2,
    )

    screen = Image.new("RGBA", (screen_width, screen_height), (0, 0, 0, 0))
    mask = Image.new("L", (screen_width, screen_height), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, screen_width - 1, screen_height - 1], radius=radius - bezel, fill=255
    )
    screen.paste(shot.convert("RGBA"), (0, 0))
    body.paste(screen, (bezel, bezel), mask)
    body_draw.rounded_rectangle(
        [bezel, bezel, body_width - bezel - 1, body_height - bezel - 1],
        radius=radius - bezel,
        outline=(0, 0, 0, 110),
        width=2,
    )

    canvas.paste(body, (x, y), body)
    return body_width, body_height


def glow(canvas: Image.Image, centre: tuple[int, int], radius: int, alpha: int = 46) -> None:
    """A soft warm bloom, used to lift a device off the workbench."""
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse(
        [centre[0] - radius, centre[1] - radius, centre[0] + radius, centre[1] + radius],
        fill=AMBER + (alpha,),
    )
    layer = layer.filter(ImageFilter.GaussianBlur(radius * 0.45))
    canvas.paste(Image.alpha_composite(canvas.convert("RGBA"), layer), (0, 0))


def lamp(draw: ImageDraw.ImageDraw, centre: tuple[int, int], radius: int = 8) -> None:
    """The app's little green status LED."""
    x, y = centre
    draw.ellipse([x - radius - 4, y - radius - 4, x + radius + 4, y + radius + 4],
                 fill=(224, 236, 227))
    draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=IN_TUNE_GREEN)
    draw.ellipse([x - radius + 2, y - radius + 2, x - radius + 6, y - radius + 6],
                 fill=(185, 228, 199))


def engraved_rule(draw: ImageDraw.ImageDraw, x0: int, y: int, x1: int) -> None:
    """A milled groove: one dark line with a lit lip under it."""
    draw.line([(x0, y), (x1, y)], fill=PANEL_EDGE, width=2)
    draw.line([(x0, y + 2), (x1, y + 2)], fill=(255, 255, 255), width=2)
