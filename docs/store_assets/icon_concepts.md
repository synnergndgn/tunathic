# Tunathic App Icon Concepts

Three concepts, all built as SVG masters under `design/store/icon/` and all
rendered to 512×512 by `design/store/render_svg.py --all`. Small-size reads were
judged off `design/store/out/_contact_sheet_icons.png`, which renders each one at
256 / 128 / 72 / 48 px on both a white and a `#202124` store background.

**Recommended: Concept A — Instrument Face.**

---

## Concept A — Instrument Face ✅ FINAL

`design/store/icon/tunathic_icon_a_instrument_face.svg`

**Description.** The app's own analog movement, lifted straight out of
`lib/features/tuner/presentation/widgets/pitch_meter.dart` and rendered as a
physical instrument faceplate: a half-disc dial recess sunk into ivory enamel, a
charcoal scale arc, engraved major and minor ticks, a green in-tune band sitting
on zero, a warm-orange needle parked on the mark, and a brass pivot cap.

**Composition.** Full-bleed 512 square. Pivot at (256, 376), rim radius 226 —
the dial is centred on the canvas's optical centre, not its geometric one, so it
sits correctly once Play's corner mask is applied. A 2.5 px machined frame is
inset 22 px. Nothing sits within 22 px of the edge.

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
white — the charcoal arc and frame are what stop it dissolving, so neither may
be lightened.

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

**Composition.** Screws at the four corners inside the mask-safe zone; lamp row
at y=152; display window 360×184 at y=204; note centred. Strictly symmetric.

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

## Recommendation

Ship **A**. It is the only one of the three that could not belong to another
app, it is the most faithful to the UI a user is about to open, and it keeps the
palette pure ivory-and-orange.

Keep **B** as the fallback if a small-size A/B test shows A losing tap-through
on a light Play surface — B's contrast advantage is real.

Treat **C** as the "do nothing" option. It is safe and it is already half
shipped, but it does not solve the problem you asked about, which is that the
store does not look like the new app.

### If you ship A, also update the launcher

`android/app/src/main/res/drawable/ic_launcher_foreground.xml` currently scales
the fork to 0.92 of the 512 viewport. Measured against the adaptive-icon safe
zone (the central 72/108 dp circle, 341 px on this grid), the mark's half
diagonal is ≈168 px against a 170 px radius — it fits, but only just, and it
reads noticeably larger than a normal launcher icon on a device. If the store
icon becomes the dial, regenerate both layers from the same master and bring the
foreground down to roughly 0.62–0.68 scale.

Note that `monochrome` points at the same drawable. The dial has no single-path
silhouette, so a themed-icon variant needs its own simplified drawable — arc,
needle, pivot as solid shapes, no gradients.
