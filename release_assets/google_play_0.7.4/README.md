# Tunathic — Google Play asset set, 0.7.4 (14)

Produced **2026-08-24**. Replaces `release_assets/google_play/`, which was
exported on 2026-07-27 from `0.2.0+1` and shows a UI that no longer exists
(dark theme, cyan tuning fork, Material-blue buttons, flat cents bar).

| | |
| --- | --- |
| App version | `0.7.4+14`, confirmed in-app under Settings → Version |
| Build under test | `flutter build apk --profile` → `build/app/outputs/flutter-apk/app-profile.apk` |
| Theme | **Light**, pinned in Settings → Appearance → Theme mode |
| Locales | `en-US` and `tr-TR`, selected in-app under Settings → Language |
| Devices | `Medium_Phone` 1080×2400 @420 dpi · `Tunathic_Tablet7` 1200×1920 @320 dpi · `Tunathic_Tablet10` 1600×2560 @320 dpi (rotated to portrait). All Android 15 / API 35, portrait. |

**Still current for 0.7.5 (15).** That release changed the launcher icon, the
themed-icon layer and the predictive-back flag — Android resources and the
manifest. No Dart changed, so every in-app screen is byte-identical and the
captures did not need re-shooting. The launcher icon does not appear in any
screenshot, and the listing icon and feature graphic were already the dial.

Profile rather than release, for the same reason as the previous set: the
release build type requires local upload-key credentials, and profile is an AOT
build with no debug banner, no debug overlays, and no `kDebugMode` diagnostics
route.

---

## Contents

```
icon/
  tunathic_play_icon_512.png        <- upload this (concept A, Instrument Face)
  alt_b_pedal_face_512.png          alternate concept, not for upload
  alt_c_fork_well_512.png           alternate concept, not for upload
  _icon_size_review.png             all three at 256/128/72/48 on light and dark
  _play_mask_preview.png            all three under Play's corner mask + shadow
feature_graphic/
  tunathic_feature_graphic_1024x500.png      <- upload this (en-US)
  tunathic_feature_graphic_tr_1024x500.png   <- upload this (tr-TR)
  alt_b_device_1024x500.png                  real-device variant, for web/press
  alt_b_device_tr_1024x500.png
screenshots/en-US/phone/       01 … 08, 1350×2400
screenshots/en-US/tablet-7/    01 … 08, 1200×2133
screenshots/en-US/tablet-10/   01 … 08, 1600×2844
screenshots/tr-TR/phone/       01 … 08, 1350×2400
screenshots/tr-TR/tablet-7/    01 … 08, 1200×2133
screenshots/tr-TR/tablet-10/   01 … 08, 1600×2844
```

48 screenshots: eight screens × two locales × three device classes.

Everything here is regenerated from source:

- icon and feature graphic → `design/store/render_svg.py --all`, from the SVG
  masters in `design/store/icon/` and `design/store/feature_graphic/`
- feature graphic B → `design/store/compose_feature_graphic_b.py`
- screenshots → `design/store/capture_device.sh`, then
  `design/store/compose_screenshots.py`
- format gate → `python design/store/validate_assets.py release_assets/google_play_0.7.4`
  (55 files, 0 problems on export)
- icon edge check → `python design/store/play_icon_preview.py <icon>.png`. Play
  masks the corners itself, so the icons carry no frame, border or corners of
  their own; an early revision did and showed a broken double edge in Console.

Raw captures live in `build/store_capture/<device>-<locale>/` and are
gitignored. Tap targets per device class are in `design/store/profiles/`.
The rationale and the copy are in `docs/store_assets/`.

---

## Screenshot states

| # | Screen | State |
| --- | --- | --- |
| 01 | Dashboard | Top of the list, tuner hero, quick dock, theory rows |
| 02 | Guitar Tuner | Automatic, Standard tuning, mic granted |
| 03 | Guitar Tuner | Chromatic — the target chip is hidden |
| 04 | Guitar Tuner | Manual, string `6 · E2` selected |
| 05 | Metronome | Running, 120 BPM, 4/4, accent on, beat 1 lit |
| 06 | Tuning settings | Standard selected, all seven presets + Chromatic, A4 = 440 Hz |
| 07 | Chord Library | C major, tones C·E·G, three shapes, open position |
| 08 | Music Theory | Category list, All levels |

No pixel inside the app UI was edited. The status bar is cropped off before
placement; the capture itself is untouched.

---

## What could not be captured honestly

**A live tuner reading.** The Android emulator's virtual microphone receives
silence, so screenshots 02, 03 and 04 show the tuner's ready state — the note
readout is `—` and the frequency line reads `Frequency unavailable`. The needle
is parked, not measuring.

Fabricating a reading was out of the question, and no caption in this set makes
an accuracy claim. To improve it, re-capture 02 on a physical phone with a real
string sounding — the procedure is in `docs/store_assets/screenshot_plan.md` §5.
Everything else in the set is unaffected.

**Metronome beat 1** *was* captured honestly: the capture script grabs a burst
while the metronome runs and `pick_beat_one.py` keeps the frame that landed on
the accented first beat.

---

## Large-screen notes

Both tablet sets are native captures, not framed phone images.

- **7-inch** lays the dashboard out in two columns and the theory categories in
  one; everything fits without scrolling.
- **10-inch** uses three dashboard columns, and the Chord Library opens its
  two-pane layout with the fingering list beside the diagram — the single best
  argument in the set for a large screen.
- Several 10-inch pages (dashboard, tuner, tuning settings) finish well above
  the bottom of the viewport and read bottom-empty. Nothing is stretched or
  clipped; it is what the app actually does at 800×1280 dp.

---

## Privacy

Every capture uses synthetic, music-only state. No account, e-mail, username,
file path, device identifier, notification, or microphone-usage history appears
in any asset.
