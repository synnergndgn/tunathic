# Tunathic Store Assets

The Play listing was built for the 0.2.0 UI: dark, cyan, Material 3. The app is
now warm ivory, orange and skeuomorphic. This directory is the plan for
replacing every store asset so the listing shows the product that ships.

Written against **0.7.4 (14)**, UI inspected on a `Medium_Phone` emulator in
Light theme on 2026-08-24.

## Read in this order

| Document | What it settles |
| --- | --- |
| [`tunathic_store_visual_direction.md`](tunathic_store_visual_direction.md) | Brand feeling, palette, type, what to never use, and the UI defects a capture will expose |
| [`icon_concepts.md`](icon_concepts.md) | Three built icon concepts, the recommendation, and what changing the icon means for the launcher |
| [`feature_graphic_concepts.md`](feature_graphic_concepts.md) | Two built feature graphics and when to use each |
| [`screenshot_plan.md`](screenshot_plan.md) | The eight-shot set, EN/TR copy, capture plan, and the one state the emulator cannot produce honestly |
| [`generation_prompts.md`](generation_prompts.md) | Image-generation prompts and Figma/Photoshop build instructions |
| [`play_upload_checklist.md`](play_upload_checklist.md) | Format, content, privacy and provenance gates before upload |

## Where the files live

```
design/store/
  icon/
    tunathic_icon_a_instrument_face.svg     <- recommended
    tunathic_icon_b_pedal_face.svg
    tunathic_icon_c_fork_well.svg
  feature_graphic/
    tunathic_feature_a_faceplate.svg        <- recommended
    tunathic_feature_a_faceplate_tr.svg
  screenshot_templates/                     (Figma exports, if any)
  tunathic_brand.py            palette + painting helpers, shared
  render_svg.py                SVG -> PNG via headless Edge/Chromium
  compose_feature_graphic_b.py feature graphic B (needs a real capture)
  compose_screenshots.py       raw capture -> 9:16 store canvas
  capture_device.sh            drives an emulator through the real UI
  profiles/*.env               per-device tap targets for that script
  pick_beat_one.py             keeps the metronome frame that hit beat 1
  validate_assets.py           re-checks exports against Play's format rules
  play_icon_preview.py         shows an icon under Play's corner mask + shadow
  out/                         generated PNGs; regenerate, never hand-edit
```

## Producing the set

```bash
# 1. Build. Profile: AOT, no debug banner, no kDebugMode routes, no keystore.
flutter build apk --profile

# 2. Capture, per locale. Sets device state, then walks the real UI.
design/store/capture_device.sh emulator-5554 build/store_capture/phone-en-US phone

# 3. Compose onto the ivory 9:16 canvas.
python design/store/compose_screenshots.py \
    build/store_capture/phone-en-US \
    release_assets/google_play/screenshots/en-US/phone en-US phone

# 4. Icon and feature graphic.
python design/store/render_svg.py --all
python design/store/compose_feature_graphic_b.py \
    build/store_capture/phone-en-US/04_tuner_manual.png \
    design/store/out/feature_b_1024x500.png en

# 5. Gate.
python design/store/validate_assets.py
```

Then repeat steps 2–3 with the app language set to Turkish, and again for the
`tablet7` and `tablet10` profiles (device class `tablet-7` / `tablet-10` in
step 3) if you are filling the large-screen listing slots.

## Naming

| Asset | Name |
| --- | --- |
| Listing icon | `tunathic_play_icon_512.png` |
| Feature graphic | `tunathic_feature_graphic_1024x500.png` (`_tr` for Turkish) |
| Screenshots | `NN_slug.png` — `01_toolkit`, `02_tuner`, `03_tuner_chromatic`, `04_tuner_manual`, `05_metronome`, `06_tuning_settings`, `07_chord_library`, `08_music_theory` |
| Raw captures | `build/store_capture/<device>-<locale>/NN_slug.png` |
| Upload sets | `release_assets/google_play/screenshots/<locale>/<phone\|tablet-7\|tablet-10>/` |

Filename order is upload order in Play Console, so the numbers matter.

## Ground rules

- The raw capture is never retouched. Cropping the status bar, scaling down and
  placing on a canvas is allowed; editing anything inside the app UI is not.
- Never scale a capture above 100 %.
- `out/` is generated. If a PNG needs to change, change the SVG or the script.
- `design/brand/` holds the brand masters and was not modified by this work.
  Concept C is the only one that reuses the existing mark; A and B are new.
