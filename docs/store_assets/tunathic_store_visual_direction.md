# Tunathic Store Visual Direction

Written against the 0.7.4 (14) UI, inspected on a `Medium_Phone` emulator in
**Light** theme on 2026-08-24. Every colour, radius and surface rule below is
read out of `lib/app/theme/`, not invented for marketing.

---

## 1. Where the current assets stand

| Asset | State | Verdict |
| --- | --- | --- |
| Launcher icon (`mipmap-*`, adaptive) | Already ivory + `#C85818` tuning fork | On the new palette. Keep for now, see §7. |
| **Play listing icon** `release_assets/.../tunathic_play_icon_512.png` | `#18232D` charcoal-blue plate, `#72D7F3` cyan fork | **Dead. Wrong product.** Replace. |
| **Feature graphic** `tunathic_feature_graphic_1024x500.png` | Near-black, cyan fork, cyan fret grid | **Dead.** Replace. |
| **All 42 screenshots** (en-US + tr-TR, 3 device classes) | Captured 2026-07-27 from `0.2.0+1`, dark theme, Material-blue buttons, pill CTA, flat linear cents bar | **Dead.** None of that UI exists any more. Re-shoot everything. |

The store currently sells a dark, cyan, Material-3 app. The app is a warm ivory
skeuomorphic instrument. That gap is the whole problem.

---

## 2. Brand feeling

> A modern instrument that behaves like a physical one. Ivory enamel faceplates,
> a warm-orange indicator, machined edges and real hardware — precise, quiet,
> made for a musician's hands, never toy-like and never busy.

Three words to design against: **machined, warm, unhurried.**

What the app already says visually, and the store must repeat:

- Surfaces are **objects**, not cards. Bevel, contact shadow, ambient shadow,
  and a lit top-left edge on every raised panel (`StudioElevation`).
- **Corners are tight.** 2–6 px on a 411 dp screen (`AppRadii`). Nothing in the
  system is a pill any more. Rounded marketing cards will read as a different
  product.
- **Orange is the indicator, not the decoration.** It marks what is selected,
  live, or engraved. Everything else is ivory, cream and warm grey.
- **Green means one thing: in tune.** Never use it as a generic accent.
- Numbers are monospace, prose is system sans (`AppTypography`).

---

## 3. Colour system

Copied verbatim from `lib/app/theme/app_colors.dart`. Marketing may not
introduce a colour that is not on this list.

| Role | Hex | Where it comes from | Store use |
| --- | --- | --- | --- |
| Warm orange | `#C85818` | `AppColors.warmOrange` | Needle, active control, primary accent |
| Amber | `#E1842F` | `AppColors.amber` | Highlight side of an orange gradient, glow |
| Burnt orange | `#A84312` | `AppColors.burntOrange` | Engraved labels, eyebrows, small caps |
| Deep charcoal | `#302822` | `AppColors.deepCharcoal` | Headlines, scale arc, device body |
| Warm ivory | `#FFFDF8` | `stageTopLight` / `panelRaisedLight` | Faceplate, canvas top |
| Cream | `#F1E8DC` | `stageBottomLight` | Canvas bottom |
| Panel | `#F8F1E7` | `rackPanelLight` | Module faces |
| Display well | `#E9DECF` | `displayLight` | Recessed readouts |
| Edge | `#D9C9B8` | `rackEdgeLight` | Hairline borders |
| Edge strong | `#B99F88` | `rackEdgeStrongLight` | Module borders, dial rim highlight |
| In-tune green | `#35734C` | `signalInTuneLight` | In-tune band, status lamp. Nothing else. |
| Muted ink | `#6B5748` | `onSurfaceVariant` | Supporting copy |

**Light theme is the store theme.** The app ships a warm-brown dark theme too
(and it is good), but every competitor tuner on Play is dark. Ivory + orange is
the only thing that makes Tunathic's thumbnail different at a glance, and it is
what the product direction asked for. Keep every store asset in light. Mention
dark mode in the description, not in the artwork.

---

## 4. Typography

The app bundles no font — it resolves the platform stack. Store assets should
do the same thing so nothing looks bolted on.

| Role | Face | Treatment |
| --- | --- | --- |
| Wordmark, screenshot headlines | Segoe UI Black / Inter Black / Roboto Black | Tight tracking (−2 at 92 px), charcoal `#302822` |
| Engraved eyebrows, module labels | Segoe UI Bold / Inter Bold | ALL CAPS, tracking +4 to +5, burnt orange `#A84312` |
| Supporting copy | Segoe UI Semibold | Muted ink `#6B5748` |
| Any number, note, or Hz value | Consolas / SF Mono / Roboto Mono | Never set a readout in the sans |

Headline discipline: **two lines maximum, ≤ 42 characters per line**, sentence
case. No exclamation marks, no all-caps headlines.

---

## 5. Icon direction

- One object, seen head on, filling the frame. No scene, no gradient sky, no
  guitar body, no floating musical notes.
- The object must be **the app's own analog movement** — the semicircular dial
  from `pitch_meter.dart`, not a generic gauge and not a stock tuning fork.
- Full-bleed square, **square corners**, no drop shadow: Play applies its own
  30 % corner mask and shadow. Rounding it yourself gives a double-rounded icon.
- No text, no wordmark, no letters other than a note name (concept B only).
- Must survive 48 px. That means one dark silhouette element carrying the shape
  (the charcoal scale arc), one saturated element carrying the brand (the orange
  needle), and one small green mark carrying the meaning.

See `icon_concepts.md`.

---

## 6. Screenshot direction

- **The screenshot is the product.** Real captures from a real build, unedited.
- Ivory workbench canvas, 9:16, one caption above one device.
- The device body is **charcoal** — the app is ivory, and an ivory device on an
  ivory bench leaves the screen with nothing to sit against.
- Caption = orange engraved eyebrow + charcoal headline. Nothing else on the
  canvas: no badges, no arrows, no annotation callouts, no ratings.
- Same theme, same status bar, same device across the whole set.

See `screenshot_plan.md`.

---

## 7. Feature graphic direction

Two valid answers, both built and both in the repo:

- **Faceplate (vector).** The whole 1024×500 is one ivory instrument panel with
  corner screws; the brand block is engraved on the left, the tuner module is
  recessed into the right. Scales to any surface, never blurry, no capture
  dependency.
- **Real device (composite).** Same bench, but the right side is an actual
  capture in a charcoal phone body running off the bottom edge.

See `feature_graphic_concepts.md`.

---

## 8. Do not use

- ❌ Cyan, electric blue, teal, neon. That was the old identity; `AppColors`
  still keeps `electricBlue` and `softCyan` as **aliases to orange and copper** —
  they are compatibility shims, not colours.
- ❌ Dark or near-black backgrounds in any store asset.
- ❌ Pills, 16–24 px rounded marketing cards, Material 3 tonal surfaces.
- ❌ Green anywhere except an in-tune indication.
- ❌ Photographs of guitars, hands, stages, studios, or wood-grain stock texture.
  The app's texture is enamel and brushed metal, not timber.
- ❌ Stock "musical note" glyphs, staves, treble clefs, sound-wave swooshes.
- ❌ Long shadows, glassmorphism, 3-D isometric phone stacks, gradient meshes.
- ❌ Bevelled 2008-style chrome. The app's skeuomorphism is 1–2 px bevels and
  short gradients, not heavy plastic.
- ❌ Any claim the build cannot support: "studio accuracy", "zero latency",
  "±0.1 cent", "#1", "best", "professional grade", star ratings, install counts,
  prices, or a call to action. Play's own graphic-asset rules forbid several of
  these outright.
- ❌ Coming-soon tools (Ear Training, Chord Finder, Capo Calculator) as a
  screenshot subject or a caption claim.

---

## 9. UI defects found while walking the app for this brief

Three were product bugs and are **fixed in 0.7.4 (14)**; two are standing
constraints on how the set is framed.

**Fixed:**

1. ~~Dashboard dock labels break mid-word~~ — "Metrono / me" and "Repertoir / e"
   at 411 dp. `ControlDockItem` now uses compact button padding, and `_DockLabel`
   measures the longest word and shrinks the label just enough for it to fit on
   one line rather than letting Flutter break the word.
2. ~~Metronome volume label truncates to `65% vo…`~~ — the 56 pt column now
   carries a monospace `volumePercentShort` readout; the full "65% volume"
   phrase reaches a screen reader through `semanticsLabel`.
3. ~~Music Theory hub has no studio backdrop~~ — it used a plain `Scaffold` +
   `AppBar`. So did ten other screens. All eleven now use `TunathicScaffold`, so
   the whole app carries one backdrop, one app-bar face and one content width.

**Still true, and they shape the set:**

4. **Tuner idle state is empty.** With no signal the display shows `—`,
   `Frequency unavailable` and a parked needle. See `screenshot_plan.md` §5 —
   this is the single biggest constraint on the set.
5. **Chromatic mode is visually near-identical to Automatic** (it only hides the
   target chip, and the Auto/Manual toggle still reads "Automatic"). A caption
   claiming a separate "chromatic screen" would be misleading; frame it as a
   mode.
