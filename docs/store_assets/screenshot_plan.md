# Tunathic Play Screenshot Plan

Eight screenshots, tuner-first, in the order a listing visitor scrolls them.
Captured from a real build, composed by `design/store/compose_screenshots.py`,
never retouched inside the app UI.

---

## 1. The set

| # | File stem | Screen | State to prepare | What it proves |
| --- | --- | --- | --- | --- |
| 01 | `01_toolkit` | Dashboard | Top of the list. Green "Tune. Train. Create." lamp badge, Guitar Tuner hero, quick dock, first theory rows | Scope: this is a toolkit, not a one-trick tuner |
| 02 | `02_tuner` | Guitar Tuner | Automatic, Standard tuning, permission already granted, dial visible | The core tool and its analog movement |
| 03 | `03_tuner_chromatic` | Guitar Tuner | Tuning system = Chromatic (target chip hidden) | Works beyond guitar |
| 04 | `04_tuner_manual` | Guitar Tuner | Manual, string `6 · E2` selected, full string strip visible | You can lock one string |
| 05 | `05_metronome` | Metronome | **Running**, 120 BPM, 4/4, accent on, **beat 1 lit** | A real metronome, not a slider |
| 06 | `06_tuning_settings` | Tuning settings | Standard selected; Chromatic, Drop D, Half/Full step, DADGAD, Open G, Open D all visible; A4 = 440 Hz | Alternate tunings + reference pitch |
| 07 | `07_chord_library` | Chord Library | A familiar chord with its diagram and at least one alternative shape | Practical reference content |
| 08 | `08_music_theory` | Music Theory hub | Category list, no search focus | Learning depth |

Play accepts 2–8 per device type, so eight is the ceiling. If you cut, cut from
the bottom: 08, then 07, then 03.

All eight screens use `TunathicScaffold` as of 0.7.4 (14), so the backdrop, the
app-bar face and the content width are identical across the set.

---

## 2. Canvas and composition

- **Canvas** 1350 × 2400 (9:16). A raw 1080×2400 capture is 2.22:1 and Play
  rejects anything past 2:1, so the canvas is not optional.
- **Background** ivory workbench: `#FFFDF8 → #F1E8DC` vertical, 6 px horizontal
  grain at 4 %, soft vignette. Identical on every shot.
- **Caption block**, top left, margin 8.5 % of width:
  - eyebrow — ALL CAPS, Segoe UI Bold, ~28 px, tracking +4.7, `#A84312`
  - headline — Segoe UI Black, ~70 px, charcoal `#302822`, max 2 lines
- **Device** — charcoal `#302822` body, 13 px bezel, 40 px radius, centred,
  scaled to whatever height is left. The status bar is cropped off the capture
  before placing (`crop_top`), so no clock, battery or Wi-Fi glyph appears.
- **Nothing else.** No arrows, no callout bubbles, no badges, no gradients
  behind the phone, no drop-shadowed marketing chrome.

---

## 3. Caption copy

Short, factual, no superlatives, no CTA, no guarantee. Both locales below are
already wired into `compose_screenshots.py` — edit them there, not by hand.

### English (en-US)

| # | Eyebrow | Headline |
| --- | --- | --- |
| 01 | `GUITAR TOOLKIT` | Every practice tool in one place |
| 02 | `TUNER` | Tune faster. Play cleaner. |
| 03 | `CHROMATIC` | Any note, any instrument |
| 04 | `AUTO / MANUAL` | Let it find the string, or pick it yourself |
| 05 | `METRONOME` | Keep time with a native low-latency click |
| 06 | `TUNINGS & PITCH` | Drop D, DADGAD, open tunings, A4 430–450 Hz |
| 07 | `CHORDS` | Practical voicings with real fingerings |
| 08 | `THEORY` | Learn the theory behind what you play |

Alternates, if you want a warmer register: 02 `Chromatic tuning, built for
guitarists` · 05 `Metronome and tuner in one focused tool` · 06 `Your tuning,
your reference pitch`.

### Turkish (tr-TR)

| # | Eyebrow | Headline |
| --- | --- | --- |
| 01 | `GİTAR ARAÇ SETİ` | Tüm pratik araçların tek yerde |
| 02 | `AKORT` | Hızlı akort. Temiz çalım. |
| 03 | `KROMATİK` | Her nota, her enstrüman |
| 04 | `OTOMATİK / ELLE` | Teli kendi bulsun ya da sen seç |
| 05 | `METRONOM` | Yerel, düşük gecikmeli metronomla tempoyu koru |
| 06 | `AKORT & REFERANS` | Drop D, DADGAD, açık akortlar, A4 430–450 Hz |
| 07 | `AKORLAR` | Gerçek basışlarıyla kullanışlı akorlar |
| 08 | `TEORİ` | Çaldığın şeyin teorisini öğren |

Alternates: 02 `Gitaristler için sade ve güçlü tuner` · 05 `Akort ve metronom tek
bir araçta` · 06 `Kendi akortun, kendi referans frekansın`.

**Musical notation stays identical in both locales.** Only the interface language
and the caption change — `E2 A2 D3 G3 B3 E4`, `120 BPM`, `4/4`, `A4 = 440 Hz` are
the same characters in a Turkish capture.

**Claims that are safe** because the build supports them: offline, no account, no
ads, no analytics, native low-latency metronome, 430–450 Hz reference in 1 Hz
steps, seven tuning presets plus chromatic, microphone released when you leave
the tuner. **Claims to avoid:** any cent-level accuracy figure, "studio", "pro",
"instant", "zero latency", "best", or a shape count that is not re-verified
against `guitar_shape_coverage_test.dart` on the shipping commit.

---

## 4. Capture plan

### 4.1 Devices

| | Phone | 7-inch tablet | 10-inch tablet |
| --- | --- | --- | --- |
| AVD | `Medium_Phone` | `Tunathic_Tablet7` | `Tunathic_Tablet10` |
| Resolution | 1080 × 2400 | 1200 × 1920 | 1600 × 2560 |
| Density | 420 dpi | 320 dpi | 320 dpi |
| Logical | 411 × 914 dp | 600 × 960 dp | 800 × 1280 dp |
| Orientation | portrait (native) | portrait (native) | portrait via `adb shell settings put system user_rotation 1` |
| Canvas | 1350 × 2400 | 1200 × 2133 | 1600 × 2844 |

All three AVDs already exist on this machine. **Emulator for everything except
the live tuner reading** (§5) — it is reproducible, the status bar can be forced
clean, and tablet layouts are genuinely native rather than a stretched phone.

### 4.2 Build

Use a **profile** build, not debug and not release:

```bash
flutter build apk --profile
```

Profile is AOT, has no debug banner and no `kDebugMode` routes, so
`/debug/tuner-diagnostics` is absent — and it does not need the upload keystore
that `preReleaseBuild` demands. If a Windows Gradle build fails with "Unable to
delete directory" or an l10n permission error, clear the ReadOnly attribute
first:

```bash
powershell -Command "Get-ChildItem lib,build -Recurse -Force -Directory | ForEach-Object { $_.Attributes = $_.Attributes -band -bnot [System.IO.FileAttributes]::ReadOnly }"
```

### 4.3 Device state before capturing

`design/store/capture_phone.sh` does all of this, but if you shoot by hand:

- Animations off (`window_animation_scale`, `transition_animation_scale`,
  `animator_duration_scale` = 0).
- `adb shell svc power stayon true` — otherwise the emulator sleeps and
  `screencap` returns a black frame.
- Microphone **granted ahead of time**
  (`adb shell pm grant dev.gundev.tunathic android.permission.RECORD_AUDIO`), so
  the system permission dialog never lands in a capture.
- Theme = **Light**, in Settings → Appearance → Theme mode. Fixed, not System.
- Language set in-app (Settings → Language), not by changing the device locale,
  so the status bar clock format stays identical between the two sets.
- SystemUI demo mode for a fixed status bar: clock **09:30**, battery **100 %
  unplugged**, Wi-Fi full, mobile hidden, notifications hidden, every optional
  status icon hidden.
- No keyboard on screen, no emulator chrome, no developer overlays.

### 4.4 Status bar and navigation bar

The composer crops the status bar off entirely (`STATUS_BAR_PX`), so the clock
and battery never reach the store. Set demo mode anyway — it keeps the raw
captures clean and consistent, and it is what you fall back on if you ever
decide to keep the bar.

The gesture pill at the bottom **is** kept: cropping it would leave the UI
floating in a body with no bottom edge. It is identical in every capture.

Consistent clock / battery / signal across a set is only required if the bar is
visible. It is not — but the emulator must still be in demo mode so that no
notification icon appears in the strip before it is cropped.

### 4.5 Run it

```bash
design/store/capture_phone.sh emulator-5554 build/store_capture/phone-en-US
python design/store/compose_screenshots.py build/store_capture/phone-en-US release_assets/google_play/screenshots/en-US/phone en-US phone
```

Then switch the in-app language to Turkish and repeat into `phone-tr-TR` /
`tr-TR`. Tap coordinates in the script are raw 1080×2400 pixels read off this
build — **re-read them after any layout change**, they are not resolution
independent.

---

## 5. The one thing the emulator cannot do honestly

**A live tuner reading.** The Android emulator's virtual microphone receives
silence, so opening the tuner gives `—`, `Frequency unavailable` and a parked
grey needle. The 2026-07 asset set hit the same wall and shipped the idle state.

That is honest, but it is a weak hero image for a tuner app — the single most
important screenshot in the set shows a tuner measuring nothing.

**Fix it by capturing screenshot 02 on hardware.** This is the recommendation:

1. Install the same profile APK on a physical Android phone (`adb install -r`).
2. Apply the same state: Light theme, language, animations off. Physical devices
   cannot use SystemUI demo mode as reliably — it does not matter, the bar is
   cropped.
3. Put the phone on a stand, play the open A string, and let the reading settle.
4. `adb exec-out screencap -p > 02_tuner.png` while the note is held.
5. Aim for a **slightly-off, not perfect** reading — a needle a few cents flat
   with the orange colour is more credible and more useful than a pinned green
   zero, and it makes no accuracy claim.

Do **not** fabricate a reading by editing a capture, and do not add a debug hook
that injects a synthetic pitch into the production tuner screen for the purpose
of a screenshot. If hardware capture is not possible before this release, ship
the idle state and keep the caption free of any accuracy language.

Screenshots 01 and 03–08 need no audio and are fine on the emulator.

**Metronome (05) is not affected.** It runs on the emulator; the accented first
beat is lit 500 ms in every 2 s at 120 BPM. The capture script grabs a burst and
`pick_beat_one.py` keeps the frame that actually landed on beat 1 — so the
shipped image is a real frame, not a retouched one.

---

## 6. Tablets

Play recommends at least four large-screen screenshots. Use the same eight
stems, or a subset of 01 / 02 / 05 / 06 / 07. Known behaviour on these AVDs, from
the previous asset run and still true:

- 10-inch: several pages finish well above the bottom of the viewport and read
  bottom-empty. Nothing is stretched or clipped.
- 7-inch: longer pages need a small scroll so a card is not cut at the screen
  edge.

Prefer native tablet captures over framed phone images. Portrait for all sets.
