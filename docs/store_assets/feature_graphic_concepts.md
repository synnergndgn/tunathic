# Tunathic Feature Graphic Concepts

Required size: **1024 × 500**, JPEG or 24-bit PNG, **no alpha**. Play crops the
graphic on some surfaces, so nothing that must be read may sit within 60 px of
any edge, and the left third must survive being cropped away on a wide banner.

Both concepts are built and rendered. Both exist in English and Turkish.

**Recommended: Concept A — Faceplate.**

---

## Concept A — Faceplate ✅ FINAL

Source: `design/store/feature_graphic/tunathic_feature_a_faceplate.svg`
(and `..._tr.svg`)
Render: `design/store/out/feature_a_1024x500.png`

**Headline idea.** None — the wordmark *is* the headline. The graphic's job in
the listing header is identity, not a sales sentence; the short description
directly under it already carries the pitch.

**Sub copy.**
- eyebrow: `GUITAR TOOLKIT` / `GİTAR ARAÇ SETİ`
- tagline: `Tune. Train. Create.` / `Akort Et. Çalış. Üret.`
- tool line: `Tuner · Metronome · Chords · Scales · Theory` /
  `Akort · Metronom · Akor · Gam · Teori`

**Layout.** The whole canvas is one ivory instrument panel with a machined edge
and a warm-steel screw in each corner.

- **Left block, x 72–560.** Green status lamp + engraved eyebrow at y≈146;
  `Tunathic` wordmark, 92 px black, charcoal, baseline y=262; tagline in warm
  orange y=312; a milled groove; the tool line in muted ink y=382.
- **Right block, x 612–962.** A recessed tuner module: engraved
  `STANDARD TUNING` label, the six standard-tuning string chips
  (`E2 A2 D3 G3 B3 E4`) in monospace, and the analog movement below them with the
  needle on zero and the green in-tune band above it.

**Device mockup.** None, deliberately. The module *is* the device. This is what
keeps the graphic sharp at any scale and free of a screenshot dependency, so it
does not go stale the next time a screen changes.

**Background.** Ivory `#FFFDF8 → #EADCC8` diagonal, 6 px horizontal brushed
grain at 4 % — the same grain `_SkeuoTexturePainter` paints in the app.

**How the UI is used.** Not as a capture; as reconstructed geometry. The dial
arc angles (198°→342°, ±13 % in-tune band) and the string chip set are taken
from `pitch_meter.dart` and `TuningPresets.standard`, so what is drawn is what
the app draws.

**Crop safety.** Wordmark and module both sit inside the central 880×420. If Play
crops to a wider banner, you lose empty plate and screws, not content.

---

## Concept B — Real Device

Script: `design/store/compose_feature_graphic_b.py`
Render: `design/store/out/feature_b_1024x500.png`

**Headline idea.** Same wordmark-led block as A, moved left and tightened.

**Layout.** Same ivory workbench, plus a soft amber bloom behind the device.
Left half carries the brand block; the right half carries a **charcoal phone
body** at x=632, y=44, 336 px wide, running off the bottom edge of the canvas so
it reads as a phone lying on the bench rather than a boxed thumbnail.

**Device mockup.** Yes — and the screen is a real, unedited capture with the
status bar cropped off. Nothing inside the app UI is retouched.

**Which capture.** `04_tuner_manual` (Manual mode, low E selected, dial visible)
is the best of the honest states: it shows the faceplate, the string picker and
the analog movement in one frame. If you ever capture a live in-tune reading on
hardware (see `screenshot_plan.md` §5), use that instead — it is a much stronger
image.

**Why the phone is charcoal.** The app's daylight theme is ivory. An ivory phone
body on an ivory bench gives the screen nothing to sit against and the UI stops
reading as a screen at all. Charcoal `#302822` is already in the palette.

**Trade-off.** B shows the actual product, which A does not; but B goes stale
every time the tuner screen changes, and the UI at 314 px wide is decorative
rather than readable.

---

## Recommendation

Ship **A** as the feature graphic. Identity, permanence, no capture dependency,
and it is the sharper image at the size Play actually renders it.

Keep **B** for places that want a product shot rather than a brand plate: a
website header, a Play "promo" slot, an X/Instagram post, a press kit. Rebuild
it whenever the tuner screen changes:

```bash
python design/store/compose_feature_graphic_b.py <capture>/04_tuner_manual.png design/store/out/feature_b_1024x500.png en
```

### Turkish

`tunathic_feature_a_faceplate_tr.svg` is a straight text swap of A — four text
nodes, no geometry change. If you edit the English master, re-apply the same
edit there; the three localisable nodes are marked `LOCALISE` in the source.
