# Closed Test Verification — 0.7.4 (14)

Run on 2026-08-25 against commit `HEAD` of `feature/interval-trainer`, on the
`Medium_Phone` AVD (1080×2400, 420 dpi, Android 15 / API 35) with the profile
APK, plus static checks against the signed release bundle.

This records what was actually checked. `closed_test_release_checklist.md`
stays the generic template; this is the filled-in result for this release.

---

## Verified

### Quality gates

| Check | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed .` | 251 files, 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | **644 passed**, 0 failed |
| `git diff --check` | clean |
| `flutter build apk --profile` | succeeds |
| `flutter build appbundle --release` | succeeds, signed |

### Layout and accessibility

`test/large_text_layout_test.dart` is new and covers what the checklist calls
"narrow phone, large text". Every dashboard destination plus the dashboard,
repertoire, settings and tuning settings are pumped at **320×700 logical pixels
with a 2× text scaler, in both English and Turkish** — 20 tests. A `RenderFlex`
overflow throws in a widget test, so reaching each screen with no exception is
the assertion, and each destination must still expose its scroll view so a
screen cannot "pass" by clipping its content.

The test was sanity-checked by raising the scaler to 8×, which fails 7 screens —
confirming the scaler reaches the tree rather than the tests passing vacuously.
2× is the bar because that is Android's accessibility maximum.

### Runtime behaviour on device

| Check | Result |
| --- | --- |
| Microphone acquired on entering the tuner | `appops` reports `RECORD_AUDIO ... (running)` |
| Microphone released on leaving the tuner | op stops running, duration recorded |
| No microphone held after cold launch | not running on the dashboard |
| No live tuner/metronome restored after force-stop | app opens on the dashboard, mic idle |
| Theme persists across force-stop | Dark survived |
| Reference pitch persists across force-stop | A4 = 442 Hz survived |
| Offline (airplane mode) | dashboard, tuner, metronome start/stop, chord library and music theory all work; no network-dependent surface |
| Dark theme | walked in airplane mode; studio surfaces consistent on every screen |
| Coming-soon tools | absent from the dashboard; listed on About under "Planned tools", localized |

### Release hygiene

| Check | Result |
| --- | --- |
| Debug tuner diagnostics | route is inside `if (kDebugMode)` in `app_router.dart`; absent from profile and release |
| Native metronome logging | `METRONOME_LOG` is `#ifndef NDEBUG`; the release `libtunathic_metronome.so` contains none of the log tag or event strings |
| Kotlin logging | every `Log.d` is behind `BuildConfig.DEBUG`, false in release |
| Tracked secrets | only `android/key.properties.example` with placeholders; the real file and `*.jks` are gitignored |

### Release bundle

| | |
| --- | --- |
| Path | `build/app/outputs/bundle/release/app-release.aab` |
| Size | 57,863,698 bytes |
| SHA-256 | `042f764cdd7f1f227b8e00d2eb345f998c6b1c894483dbaf002159a4fc4650ea` |
| Signer | `CN=Ali, C=TR`, 4096-bit RSA, SHA256withRSA — `jarsigner -verify`: **jar verified** |
| Native ABIs | `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| Native libs | `libapp.so`, `libflutter.so`, `liboboe.so`, `libtunathic_metronome.so`, `libc++_shared.so`, `libdatastore_shared_counter.so` |
| Runtime permissions | **`RECORD_AUDIO` only** |
| Version code | `14`. Confirmed by the owner on 2026-08-25 as **not yet uploaded**, so it is free to use. The last consumed code is `13` (0.7.3). |

`android.permission.DUMP` appears once in the merged manifest. It is not a
`uses-permission`: it is the permission *required of callers* of AndroidX's
`ProfileInstallReceiver`, which Flutter includes by default. That is the
restrictive configuration, not a request for a privileged permission.

The Oboe licence is bundled at `assets/licenses/oboe.txt` and surfaced through
Settings → Open-source licenses.

---

## Deferred to 0.7.5, deliberately

Neither blocks Closed Test.

1. **Launcher icon still shows the tuning fork.** The store icon is now the
   analog dial, so the listing and the home screen disagree. Steps are in
   `docs/store_assets/icon_concepts.md`; it needs its own release because it
   swaps the icon on existing users' home screens.
2. **Predictive back is not enabled.** Logcat warns
   `OnBackInvokedCallback is not enabled for the application`. Setting
   `android:enableOnBackInvokedCallback="true"` opts into the Android 13+ back
   animation, but it changes back behaviour across every route and wants its own
   test pass rather than a change on release day.

---

## Not verifiable here — owner action before upload

These are account- and policy-level and cannot be checked from the repo. The
version code question is closed: see the bundle table above.

- Data Safety form reverified against this exact AAB.
- App Content answers reverified in the current Play Console.
- IARC questionnaire completed.
- Target audience and any Families implications approved.
- Privacy policy hosted over public HTTPS with a live contact, matching in-app text.
- Play App Signing key strategy approved; the upload key backed up off this machine.
- Closed Testing tester list, feedback channel, and the 12-testers/14-days
  requirement.
- Physical-device cold launch smoke. Everything above is emulator-verified; a
  real device has not been exercised this pass, and it is also the only way to
  capture a live tuner reading (see `docs/store_assets/screenshot_plan.md` §5).
