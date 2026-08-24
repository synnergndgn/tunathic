# Generation and Editing Prompts

The Tunathic assets in `design/store/` are **vector and code**, not generated
images — that is deliberate, because a store icon has to hit exact hex values,
exact geometry and a 512 px grid, and a diffusion model will not. Use the
prompts below only when you want an exploration, a mood frame, or a variant to
argue about; do not upload a generated image to Play.

Every prompt below already carries the palette and the negative list. Keep them
verbatim; the negatives are doing most of the work.

---

## 1. Shared style block

Paste this at the head of any image prompt.

> Warm ivory enamel instrument faceplate, colour palette strictly limited to
> ivory #FFFDF8, cream #F1E8DC, panel #F8F1E7, warm orange #C85818, amber
> #E1842F, burnt orange #A84312, deep charcoal #302822, in-tune green #35734C,
> warm steel #B99F88. Restrained skeuomorphism: 1–2 px bevels, short gradients,
> soft contact shadow plus a wider ambient shadow, light source top-left, fine
> horizontal brushed grain at very low opacity. Very tight corner radii (2–6 px
> at UI scale). Flat head-on orthographic view, centred, no perspective.
> Precise, machined, quiet, premium. Clean vector-like rendering, crisp edges.

**Negative prompt, always:**

> cyan, teal, electric blue, neon, glow, dark background, black background,
> Material Design, rounded pill buttons, large rounded cards, glassmorphism,
> long shadows, 3D isometric, gradient mesh, chrome plastic bevel, wood grain,
> photograph, guitar body, hands, stage, studio, sheet music, staff lines,
> treble clef, floating musical notes, sound wave swoosh, text, letters,
> watermark, logo, ui mockup frame, drop shadow on the outer edge, rounded
> canvas corners

---

## 2. Icon — Concept A (Instrument Face)

> [shared style block] App icon, 1:1, 512×512, full-bleed square with square
> corners. A single analog VU-style tuner movement seen head on: a semicircular
> dial recess sunk into an ivory enamel faceplate; a thick charcoal #302822 scale
> arc spanning roughly 200° to 340°; four long charcoal major ticks and four
> short warm-grey minor ticks; a short saturated green #35734C band centred at
> the top of the arc marking zero; one bold warm-orange #C85818 needle pointing
> straight up at that green band; a brushed brass pivot cap at the base of the
> needle with a small orange centre. A hairline machined frame inset from the
> edge. Nothing else in frame.

Aspect / size hints: `--ar 1:1`, request 1024 px and downsample.

## 3. Icon — Concept B (Pedal Face)

> [shared style block] App icon, 1:1, 512×512, full-bleed square, square corners.
> The front panel of a guitar pedal tuner seen head on: ivory enamel body with a
> warm-steel slotted screw in each corner; a horizontal row of five small round
> indicator lamps near the top, the centre one lit green #35734C and the rest
> unlit warm grey; below them a deeply recessed dark charcoal display window with
> rounded corners and a soft glass sheen, showing one large warm-orange #E1842F
> monospace capital letter E. Symmetrical composition.

## 4. Icon — Concept C (Fork in the Well)

> [shared style block] App icon, 1:1, 512×512, full-bleed square, square corners.
> A slender monoline tuning fork — two straight prongs joined by a semicircular
> head, one short stem, uniform stroke weight, round caps — in warm orange
> #C85818, centred inside a machined circular recess cut into an ivory enamel
> faceplate. A short green #35734C segment on the recess rim at twelve o'clock.
> Nothing else in frame.

## 5. Feature graphic — Concept A (Faceplate)

> [shared style block] Wide banner, 1024×500, no transparency. The entire canvas
> is one ivory enamel instrument faceplate with a machined edge and a warm-steel
> slotted screw in each corner, fine horizontal brushed grain. Left third: empty
> plate with a small lit green indicator lamp, reserved for engraved type. Right
> third: a recessed rectangular instrument module containing a row of six small
> ivory chips and, below them, a semicircular analog tuner dial with a charcoal
> scale, a green band at zero and a warm-orange needle. Balanced, uncluttered,
> generous negative space in the left half.

Then set the type in Figma or Photoshop rather than in the model — see §7.

## 6. Feature graphic — Concept B (Real Device)

Do not generate this one. It must contain a real capture. Run:

```bash
python design/store/compose_feature_graphic_b.py <capture>/04_tuner_manual.png design/store/out/feature_b_1024x500.png en
```

If you want a background plate to composite by hand instead:

> [shared style block] Wide empty background, 1024×500. Ivory enamel workbench
> surface, subtle top-to-bottom gradient from #FFFDF8 to #F1E8DC, fine horizontal
> brushed grain, a very soft warm amber bloom in the right third, gentle vignette
> at the corners. Completely empty — no objects, no devices, no text.

---

## 7. Figma / Photoshop instructions

### Setting up the file

1. New Figma file, page **Store**. Frames: `icon-512` (512×512),
   `feature-1024x500`, `shot-1350x2400` (×8), plus `shot-1200x2133` and
   `shot-1600x2844` for tablets.
2. Import `design/store/icon/*.svg` and
   `design/store/feature_graphic/*.svg` directly — they are plain SVG, they land
   as editable vectors with the gradients intact.
3. Create colour styles from `tunathic_store_visual_direction.md` §3. Name them
   after the Dart tokens (`warmOrange`, `burntOrange`, `stageTopLight`,
   `signalInTuneLight`) so a designer and the codebase share vocabulary.
4. Text styles:
   - `store/headline` — Inter Black 70 / 116 %, tracking −2 %, `deepCharcoal`
   - `store/eyebrow` — Inter Bold 28, tracking +17 %, ALL CAPS, `burntOrange`
   - `store/wordmark` — Inter Black 92, tracking −2.7 %, `deepCharcoal`
   - `store/readout` — JetBrains Mono Bold, for any number or note name

   (Inter and JetBrains Mono are the closest free stand-ins for the Segoe UI /
   Consolas stack the scripts use on Windows. If you set type in Figma, re-render
   everything in Figma — do not mix the two toolchains inside one set.)

### Feature graphic, if you rebuild it by hand

1. 1024×500 frame, fill = linear gradient `#FFFDF8` → `#EADCC8` at 135°.
2. Grain: 1 px horizontal line, `#6B4A32` at 4 %, repeated every 6 px, grouped
   and clipped to the frame.
3. Edge: rounded rect inset 14, radius 10, stroke `#C9B39C` 2.5; a second inset
   18, radius 7, stroke white 90 % 1.5. That pair is the whole bevel trick.
4. Screws: 22 px circle, radial gradient white → `#C3AE99` → `#6B5748`, plus a
   `#4A3B31` 50 % slot line. One in each corner at 48/48.
5. Module: rounded rect 350×396 at (612, 52), radius 8, fill `#FFFDF9` →
   `#F6EEE2` → `#E8DAC6`, stroke `#B99F88` 2, inner stroke white 80 % 1.5, plus a
   `#5A3A24` 16 % offset rectangle behind it as the contact shadow.
6. Type on the left per §7 text styles. Keep the wordmark baseline at y=262.

### Screenshots, if you compose them by hand instead of by script

1. 1350×2400 frame, same ivory gradient and grain.
2. Caption block at x=115: eyebrow at y≈108, headline baseline starts y≈165,
   line height 116 %, wrap at 2 lines.
3. Device: rounded rect, radius 40, fill `#302822`, 13 px bezel; inner rounded
   rect radius 27 as a mask for the capture; inner stroke black 43 % 2 px; drop
   shadow `#5A3A24` 34 %, y +14, blur 26.
4. Place the raw capture, **crop the top 108 px** (the status bar), scale
   proportionally to fit. Never scale above 100 %.
5. Do not touch a single pixel inside the app UI.

The script does all of this and is the source of truth; hand-composing is for
one-off variants only.
