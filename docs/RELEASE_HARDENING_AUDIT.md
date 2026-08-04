# Phase 5A Release Hardening Audit

Audit date: 2026-07-26

Branch: `release/closed-test`

Baseline commit: `d050626` (`feat: expand chord voicing coverage`)
Remote: `origin` at `https://github.com/synnergndgn/tunathic.git`

## Release identity

| Field | Audited value | Assessment |
| --- | --- | --- |
| Android application ID | `dev.gundev.tunathic` | Brand-consistent and suitable; do not change after first Play creation/upload |
| Android namespace | `dev.gundev.tunathic` | Consistent |
| Display name | `Tunathic` | Consistent |
| Flutter package | `tunathic` | Consistent |
| Version name | `0.3.0` | Repertoire release for internal testing |
| Version code | `3` | Code 2 was already uploaded and tested; every later upload must increase again |
| Minimum SDK | 24 | Flutter 3.44 stable default; compatible with current dependencies |
| Target SDK | 36 | Meets the 31 August 2026 new-app requirement |
| Compile SDK | 36 | Matches installed stable Android platform |

Current official Play guidance says new mobile apps and updates submitted from
31 August 2026 must target Android 16/API 36 or higher:
https://support.google.com/googleplay/android-developer/answer/11926878

## Feature-freeze classification

| Classification | Features |
| --- | --- |
| Ready | Guitar Tuner, Metronome, BPM Tap, Chord Library, Scale Library, Interactive Fretboard, Circle of Fifths, Settings, About, Privacy, Licenses |
| Coming Soon | Interval Trainer, Ear Training, Chord Finder, Capo Calculator |
| Debug-only | Tuner Diagnostics route, guarded by `kDebugMode` |
| Internal/development-only | `tool/` coverage, click-generation, and pitch-diagnostic commands |

Coming Soon dashboard cards are visible and localized but disabled. Unknown
direct tool routes may still render the localized placeholder, while release
navigation does not expose them as controls.

## Permission inventory

| Permission/capability | Variant | Classification | Reason |
| --- | --- | --- | --- |
| `android.permission.RECORD_AUDIO` | main/release | Required | Foreground Guitar Tuner PCM input and local pitch analysis |
| `android.permission.INTERNET` | debug/profile only | Development-only | Flutter debugging/hot reload/service protocol |
| `dev.gundev.tunathic.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | all variants | Expected framework-internal signature permission | AndroidX protects app-internal dynamic receivers on affected Android versions; other apps cannot obtain it |
| `PROCESS_TEXT` query | main/release | Required framework query, not a permission | Flutter text action discovery |

No location, contacts, camera, storage/media, Bluetooth scan/connect, phone/SMS,
notifications, advertising ID, background service, exact alarm, accessibility
service, device admin, or broad package visibility declaration exists in the
project manifest. Recheck the merged release manifest and final AAB after every
dependency change.

## Privacy and network behavior

- `record` streams PCM16 to application memory only after explicit Tuner Start.
- Raw bytes/samples are converted and released; no file, database, history,
  upload, or raw-audio logging exists.
- Pitch estimates and stabilizer state are bounded and transient.
- Scalar theme, locale, haptic, metronome, and tuner preferences are stored
  locally through the application-owned preferences boundary.
- BPM Tap session state is memory-only.
- No app HTTP call or Internet permission in release, analytics, crash
  reporting, advertising, account, backend, cloud sync, location, or
  device-identifier behavior was found. `package_info_plus` has a transitive
  `http` package for non-Android implementations; Android release code does not
  use it and Dart tree shaking excludes unreachable implementation code.
- Chord, scale, fretboard, circle, and click content ships in the app.

## Dependency audit

| Dependency | Release purpose | Network / Data Safety / permission effect | License note |
| --- | --- | --- | --- |
| Flutter SDK / Material | UI/runtime | No application network behavior; debug tooling adds Internet in debug/profile | Flutter/engine license obligations handled by standard notices |
| `flutter_riverpod` | State management and dependency injection | No permissions or collection | Include transitive license in Flutter license page |
| `go_router` | Declarative navigation | No permissions or collection | Include license |
| `flutter_localizations`, `intl` | EN/TR localization | No permissions or collection | Include licenses |
| `shared_preferences` | Local scalar preferences | Local storage only; not developer collection | Include plugin/transitive licenses |
| `record` | Foreground PCM16 tuner input | Contributes microphone implementation/permission behavior; no app file recording | Include plugin/native licenses |
| `package_info_plus` | Installed version/build display | Reads package metadata; no developer collection | Include plugin/transitive licenses |
| `wakelock_plus` | Keeps the display on while a Repertoire sheet is open | Sets the standard keep-screen-on window flag; contributes no permission and no collection | Include plugin/transitive licenses |
| Oboe 1.10.0 | Native low-latency Metronome output | No network or data collection; native audio output only | Apache-2.0 text bundled in `assets/licenses/oboe.txt` and registered in-app |

No dependency was removed or upgraded speculatively. Transitive packages must
be re-audited from the final dependency lock and AAB SDK inventory.

## Native Metronome integrity

- Kotlin registers one `tunathic/metronome` method/event-channel boundary from
  `MainActivity`.
- `NativeMetronomeEngine` owns JNI lifecycle and loads the project library.
- CMake builds the project metronome engine with C++17 and links Android log,
  Oboe, and required native libraries.
- Oboe callback timing, initialization, and stop architecture are unchanged.
- Oboe license is bundled.
- Flutter release packaging is expected to emit arm32, arm64, and x86_64 native
  libraries; verify actual APK/AAB archive contents.
- No project ProGuard/R8 rules affect JNI registration; native methods use
  explicit JNI exports. Verify release build output and smoke-test initialization.

## Secret and logging audit

Tracked filename and pattern scans found no keystore, private key, `.env`,
`key.properties`, signing password, API credential, or token. `.claude/` is an
untracked user-owned directory and was not read or changed.

`AppLogger` emits only in debug mode. Native metronome debug logging is compiled
out when `NDEBUG` is set. No remote sink exists, and the audio path does not log
raw PCM or samples. Release-facing framework errors use a localized friendly
error view. Physical release testing must still check logcat for plugin/native
noise and UI for technical exceptions.

## Baseline automated results

- Flutter 3.44.0 stable; Dart 3.12.0.
- Android SDK 36.1 and Java 21 installed; Android licenses accepted.
- `flutter doctor -v`: Android/Windows toolchains pass; Chrome executable is
  unavailable; Windows and Edge are the only detected devices.
- Baseline `flutter analyze`: passed, no issues.
- Baseline `flutter test`: passed, 431 tests.

## Build and artifact results

- Debug APK: built after clearing stale read-only attributes only in Gradle's
  generated `mergeDebugAssets` directory. Size: 186,661,799 bytes. SHA-256:
  `FC25369570521B86B647023A40C0317CE2193282C508EDDA18C1A2AAACA66CFB`.
- Profile APK: built. Size: 97,906,554 bytes. SHA-256:
  `8F1D3C370799B4F6A4179DF47B52D2CB74EC7D1C8EFC98E49C6C1A45F107DB0A`.
  Rebuilds on this Windows workspace required the same narrow read-only
  attribute cleanup in generated profile asset/native-library directories.
- Release APK attempt: stopped at the intentional `preReleaseBuild` gate
  because `android/key.properties` is absent.
- Release AAB attempt: stopped at the same intentional signing gate.
- The generated merged release manifest confirms application ID/version,
  min/target SDK, `RECORD_AUDIO`, the AndroidX signature permission, and no
  `INTERNET`.
- Profile archive inspection confirms `libtunathic_metronome.so`, `liboboe.so`,
  `libapp.so`, and required runtimes for `armeabi-v7a`, `arm64-v8a`, and
  `x86_64`, plus the bundled Oboe license.
- Final `flutter gen-l10n`: passed.
- Final formatting and no-change formatting verification: passed, 142 files.
- Final `flutter analyze`: passed, no issues.
- Final `flutter test`: passed, 432 tests.
- `git diff --check`: passed.
- No Android target was connected (`adb devices` was empty), so physical,
  release-mode, process-death, accessibility-device, and offline smoke tests
  were not performed and are not claimed as passed.

Final build, manifest, artifact, and test results are recorded in the task
report and should be copied into release records after credentials and physical
hardware are available.

## Remaining external/manual blockers

- Explicit final approval of package ID before Play app creation.
- Privacy effective date, public contact, and appropriate legal review.
- Final target-audience and Play App Content decisions.
- Final 512×512 listing icon, feature graphic, and screenshots.
- Authorized upload-key creation, backups, and Play App Signing decision.
- Signed release APK/AAB, signer verification, and artifact hash.
- Physical profile/release, process-death, offline, accessibility, and logcat
  validation on Android hardware.
- Play Console account-specific requirements and all current form wording.
