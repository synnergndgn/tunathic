# Tunathic Brand Identity

**The app icon is the analog tuner movement** — the semicircular dial the app's
own tuner paints: a charcoal scale arc, a green in-tune band on zero, a
warm-orange needle and a brass pivot. It is not a metaphor for the product; it
is the product's most recognisable component. Adopted for the Play listing icon
in 0.7.4 and for the launcher in 0.7.5.

The masters are `design/store/icon/tunathic_icon_a_instrument_face.svg` (store,
full-bleed square) and `android/ic_launcher_foreground.svg` (launcher,
recomposed for the adaptive safe zone). The two share geometry; only the framing
differs, and `docs/store_assets/icon_concepts.md` explains why they cannot be
one file.

## The tuning fork, retired from the icon

The earlier mark was a **slender monoline tuning fork** — two prongs joined by a
semicircular head, with a single stem, a single-weight line (26 units on the 512
grid) with round caps. It no longer appears on any app icon. Its files are kept
because the wordmark lockup still uses it:

> **Open:** `tunathic-wordmark.svg` still pairs the fork with the name. It has
> not been redrawn around the dial. Until it is, do not place the wordmark next
> to an app icon — they show two different marks.

## Colors

| Token          | Hex       | Use                                     |
| -------------- | --------- | --------------------------------------- |
| Warm orange    | `#C85818` | Primary mark and controls                |
| Amber          | `#E1842F` | Mark on dark workshop backgrounds        |
| Warm ivory     | `#FFFDF8` | Light icon and application surface       |
| Workshop brown | `#4A3C32` | Optional dark icon surface               |
| Warm charcoal  | `#302822` | Wordmark and primary text                |

These match `lib/app/theme/app_colors.dart`.

## Files

| File                                  | Purpose                                        |
| ------------------------------------- | ---------------------------------------------- |
| `android/ic_launcher_foreground.svg`  | **Current.** Adaptive foreground, the dial in the safe zone |
| `android/ic_launcher_monochrome.svg`  | **Current.** Themed-icon silhouette            |
| `android/ic_launcher_background.svg`  | **Current.** Adaptive background layer         |
| `android/ic_launcher_legacy.svg`      | **Current.** Composed square for the API 24-25 mipmap PNGs |
| `tunathic-mark.svg`                   | Legacy fork, transparent                       |
| `tunathic-icon-dark.svg`              | Legacy fork app icon, dark                     |
| `tunathic-icon-light.svg`             | Legacy fork app icon, light                    |
| `tunathic-wordmark.svg`               | Legacy fork lockup, not yet redrawn            |

## Usage

- Keep clear space of at least one prong-width around the mark.
- Never restretch or recolor the mark outside the palette. Surface depth may
  use the restrained enamel bevel and shadow rules from the application UI.
- Do not thin the dial's scale arc. With no frame around it, that arc is the
  only thing holding the icon's shape on a light background.
- Nothing may be drawn near an icon's edge: Play and every launcher apply their
  own mask. See `docs/store_assets/icon_concepts.md`.
- The wordmark uses a Segoe UI / system sans fallback. Swap in the product
  display type here once one is chosen, then convert the text to outlines.

## Producing Android launcher assets

The SVGs are the source of truth, but the shipping vector drawables are
hand-written rather than converted: the paths are simple enough — arcs, lines
and two circles — that VectorDrawable takes the same path syntax directly.

- `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- `android/app/src/main/res/drawable/ic_launcher_monochrome.xml`

Both carry the same group transform (pivot 256,256, scale 0.62, translateY
-15.81) and it has to stay identical in both, or the themed icon drifts away
from the colour one. Change either and change the matching SVG too.

The API 24-25 raster fallbacks are rendered from `android/ic_launcher_legacy.svg`:

```bash
python design/store/render_svg.py design/brand/android/ic_launcher_legacy.svg out.png 1024 1024
```

then downsampled to 48/72/96/144/192 into the `mipmap-*` folders. Those devices
apply no mask, so that file carries its own full-bleed plate.
