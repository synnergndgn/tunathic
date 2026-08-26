# Tunathic App Icon Concepts

Three concepts, all built as SVG masters under `design/store/icon/` and all
rendered to 512×512 by `design/store/render_svg.py --all`. Small-size reads were
judged off `design/store/out/_contact_sheet_icons.png`, which renders each one at
256 / 128 / 72 / 48 px on both a white and a `#202124` store background.

**Decided: Concept A — Instrument Face.** Chosen 2026-08-24 and shipped as
`release_assets/google_play_0.7.4/icon/tunathic_play_icon_512.png`. B and C stay
in the repo as the alternates the decision was made against.

## The edge rule, learned the hard way

Play masks the uploaded 512 square with **its own rounded square** (~22 % radius
in Console today, 30 % in the icon-design spec) and adds **its own drop shadow**.

All three concepts originally carried a thin inset "machined frame" a few pixels
in from the edge, at a much tighter radius. Under Play's mask that became two
mismatched rounded rectangles — a visible frame inside a frame, and it looked
broken in the listing. The frames are gone; the plate runs full bleed and Play's
mask supplies the only edge.

So: **nothing may be drawn near the icon's edge.** No frame, no border, no
corners of its own, no shadow. Anything within roughly 40 px of the 512 edge is
either cut by the mask or fights it. Check before uploading:

```bash
python design/store/play_icon_preview.py design/store/out/icon_a_512.png
```

That renders the icon under both mask radii, with Play's shadow, at 256 and
96 px, so a collision shows up locally instead of in Console.

---

## Concept A — Instrument Face ✅ SHIPPING

`design/store/icon/tunathic_icon_a_instrument_face.svg`

**Description.** The app's own analog movement, lifted straight out of
`lib/features/tuner/presentation/widgets/pitch_meter.dart` and rendered as a
physical instrument faceplate: a half-disc dial recess sunk into ivory enamel, a
charcoal scale arc, engraved major and minor ticks, a green in-tune band sitting
on zero, a warm-orange needle parked on the mark, and a brass pivot cap.

**Composition.** Full-bleed 512 square, no frame and no corners of its own.
Pivot at (256, 376), rim radius 226 — the dial is centred on the canvas's
optical centre, not its geometric one, so it sits correctly once Play's corner
mask is applied. The scale arc's outermost point is 41 px in from the edge,
clear of the mask at both radii.

**Colour.** Ivory plate `#FFFDF8 → #EBDDCA`; scale and ticks `#302822`; minor
ticks `#9A8168`; in-tune band `#35734C`; needle `#E1842F → #C85818 → #8E3A0D`;
pivot brass `#FFFFFF → #D6C0A8 → #4A3B31` with a `#C85818` core.

**Why it fits Tunathic.** It is not a metaphor for the product, it *is* the
product's most recognisable component — a user who has used the tuner once will
recognise the icon, and a user who has not immediately reads "measuring
instrument for musicians". It carries the ivory-and-orange identity without a
single generic music cliché, and the skeuomorphism is the app's own restrained
kind (short gradients, 1–2 px bevels) rather than plastic chrome.

**48 px readability.** Good. The charcoal arc gives the icon a hard silhouette
that survives downscaling; the orange needle is the only saturated mass, so it
reads as a pointer even when the ticks blur; the green band survives as a notch.
Weakest of the three on a white store background, because the plate is nearly
white — with no frame to fall back on, the charcoal arc is the only thing
holding the shape, so it may not be lightened or thinned.

**Variant worth testing.** Needle at about −20 % of range instead of dead centre
reads more dynamic ("approaching the mark") at the cost of symmetry. Symmetry
usually wins for an icon; run both past a second pair of eyes before shipping.

---

## Concept B — Pedal Face

`design/store/icon/tunathic_icon_b_pedal_face.svg`

**Description.** A pedal-tuner front panel seen head on: ivory enamel body, four
hardware screws, a row of five indicator lamps with only the centre one lit
green, and a sunken dark display window carrying the note `E` in warm orange —
the same monospace, oversized note readout the app puts at the top of the tuner.

**Composition.** Screws at (76, 76) and the three mirrored corners — 110 px from
the mask's corner arc centre against a 154 px radius, so they survive the mask
at 30 % with room to spare. Lamp row at y=152; display window 360×184 at y=204;
note centred. Strictly symmetric.

**Colour.** Ivory plate; window `#3B322C → #221C19`; note `#E1842F`; lamp
`#35734C`; screws warm steel.

**Why it fits Tunathic.** The strongest "musician's equipment" signal of the
three — a stompbox is unmistakable to a guitarist. It also borrows the app's real
hardware detail (screws come from `_SkeuoEdgePainter`, the lamp from
`SkeuoStatusBadge`).

**48 px readability.** Best of the three by a clear margin. The dark window is a
high-contrast anchor on any store background and the orange `E` stays legible.

**Cost.** It puts a letter in the icon, and it introduces a dark mass into a
white-and-orange identity. It is also less specific: several competitor tuners
already use a dark note window.

---

## Concept C — Fork in the Well

`design/store/icon/tunathic_icon_c_fork_well.svg`

**Description.** The existing Tunathic tuning-fork mark, geometry unchanged from
`design/brand/tunathic-mark.svg`, seated in a machined circular recess on an
ivory faceplate, with a green in-tune segment on the rim at twelve o'clock.

**Composition.** Recess radius 178 centred on the canvas; mark scaled 0.82 about
centre; stroke 34 so it holds up small.

**Why it fits Tunathic.** Continuity. The launcher icon already ships this mark
in ivory and `#C85818`, so the store icon and the home-screen icon would match
exactly, and the brand documentation in `design/brand/README.md` stays true.
Lowest-risk option if you do not want to touch brand identity right now.

**48 px readability.** Fine — the fork is a clean silhouette. But it is the most
generic of the three: a monoline tuning fork is the default choice for this
category, and the recess and green segment both disappear below ~72 px, which
leaves you with exactly the icon you already have.

---

## Decision

**A ships.** It is the only one of the three that could not belong to another
app, it is the most faithful to the UI a user is about to open, and it keeps the
palette pure ivory-and-orange.

**B** stays as the fallback if a small-size test ever shows A losing
tap-through on a light Play surface — its contrast advantage is real.

**C** was the "do nothing" option: safe, already half shipped in the launcher,
but it does not close the gap between the store and the new app.

### Done in 0.7.5: the launcher shows the dial too

0.7.4 shipped the dial to the store while the launcher still carried the fork,
so the listing and the home screen showed two different marks. 0.7.5 closes it.
What that took:

1. The dial was recomposed rather than reused. The store framing fills a square,
   and a circular launcher mask would clip the scale arc's ends.
2. The foreground scales to 0.62 with a -15.81 translate. The fork it replaced
   sat at 0.92, which put its half diagonal at about 168 px against a 170 px
   safe radius — it fitted, but only just, and read oversized on a device.
3. `monochrome` got its own drawable. Tinted to one colour, the green in-tune
   band merges into the charcoal arc and the brass pivot into the orange core,
   so the themed layer keeps only arc, ticks, needle and pivot.
4. Every `mipmap-*` density was regenerated from `ic_launcher_legacy.svg`, the
   API 24-25 fallback that no launcher masks.
5. `design/brand/README.md` now documents the dial as the app icon and marks the
   fork files legacy.


