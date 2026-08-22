# Tunathic Brand Identity

The Tunathic mark is a **slender monoline tuning fork** — two prongs joined by a
semicircular head, with a single stem. It ties the whole toolkit to its core
tool (the guitar tuner) while staying premium, precise, and minimal. The mark
is a single-weight line (26 units on the 512 grid) with round caps.

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
| `tunathic-mark.svg`                   | Mark only, transparent (light or dark bg)      |
| `tunathic-icon-dark.svg`              | 512 rounded-square app icon, dark              |
| `tunathic-icon-light.svg`             | 512 rounded-square app icon, light             |
| `tunathic-wordmark.svg`               | Horizontal mark + “Tunathic” lockup            |
| `android/ic_launcher_background.svg`  | Adaptive icon background layer                 |
| `android/ic_launcher_foreground.svg`  | Adaptive icon foreground (mark in safe zone)   |

## Usage

- Keep clear space of at least one prong-width around the mark.
- Never restretch or recolor the mark outside the palette. Surface depth may
  use the restrained enamel bevel and shadow rules from the application UI.
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
