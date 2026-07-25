# Tunathic Brand Identity

The Tunathic mark is a **slender monoline tuning fork** — two prongs joined by a
semicircular head, with a single stem. It ties the whole toolkit to its core
tool (the guitar tuner) while staying premium, precise, and minimal. The mark
is a single-weight line (26 units on the 512 grid) with round caps.

## Colors

| Token          | Hex       | Use                                     |
| -------------- | --------- | --------------------------------------- |
| Electric blue  | `#287DFF` | Primary mark, mark on light backgrounds |
| Soft cyan      | `#72D7F3` | Mark on dark (charcoal) backgrounds      |
| Off-white      | `#F3F7FA` | Light icon surface, wordmark on dark    |
| Charcoal surf. | `#18232D` | Dark icon / adaptive background         |
| Deep charcoal  | `#111820` | Wordmark text on light                  |

These match `lib/app/theme/app_colors.dart`.

## Files

| File                                  | Purpose                                        |
| ------------------------------------- | ---------------------------------------------- |
| `tunathic-mark.svg`                   | Mark only, transparent (light or dark bg)      |
| `tunathic-icon-dark.svg`              | 512 rounded-square app icon, dark              |
| `tunathic-icon-light.svg`             | 512 rounded-square app icon, light             |
| `tunathic-wordmark.svg`               | Horizontal mark + “Tunathic” lockup            |
| `android/ic_launcher_background.svg`  | Adaptive icon background layer                 |
| `android/ic_launcher_foreground.svg`  | Adaptive icon foreground (mark in safe zone)   |

## Usage

- Keep clear space of at least one prong-width around the mark.
- Never restretch, recolor outside the palette, add a second colour to the
  mark, or apply gradients/shadows — the direction is flat and restrained.
- Keep the line weight proportional; do not thin it below the 26/512 ratio, or
  the prongs disappear at favicon sizes.
- The wordmark uses a Segoe UI / system sans fallback. Swap in the product
  display type here once one is chosen, then convert the text to outlines.

## Producing Android launcher assets

The SVGs are the source of truth. To generate the Flutter/Android launcher
assets, convert the two `android/*.svg` layers to Android vector drawables
(e.g. via `vd-tool`, an SVG→VectorDrawable converter, or a 432×432 PNG export)
and wire them through `flutter_launcher_icons` with
`adaptive_icon_background` / `adaptive_icon_foreground`. Content already sits
inside the adaptive-icon safe zone.
