# Current Milestone: Phase 2E — Production Metronome Engine

Phase 2E is a P0 Android reliability gate. It replaces the Metronome's Dart-timed `AudioPool` playback with an audio-engine-owned clock before any new toolkit feature begins.

## Authorized scope

- Replace audible Dart scheduling with a native low-latency engine.
- Preserve 20–300 BPM, 2/4, 3/4, 4/4, and 6/8.
- Keep quarter-note BPM semantics and denominator-aware 6/8 eighth-note pulses.
- Support first-beat accent, volume, live BPM changes, and live signature changes.
- Separate audio timing, beat state, visual callbacks, and UI animation.
- Preserve foreground-only lifecycle and Metronome/Tuner mutual exclusion.
- Add fake-engine automated coverage and debug diagnostics.
- Perform Android debug/profile/release build and physical-device validation.
- Update architecture, roadmap, README, and decision documentation.

No chord, scale, training, account, backend, advertising, publishing, or unrelated tuner functionality is authorized.

## Production architecture

`MetronomeEngine` is the application boundary. The Android implementation uses Oboe 1.10.0 through a small Kotlin method/event channel and a C++ audio callback. Oboe selects AAudio where supported and OpenSL ES on older supported Android versions.

The native callback writes the regular or accented project click directly at calculated output sample frames. Fractional frame accumulation prevents interval-rounding drift. Flutter beat events are visual hints and diagnostics; they never trigger sound.

The rejected `metronome` 2.0.12 package spike and detailed rationale are recorded in [Metronome Engine Decision](METRONOME_ENGINE_DECISION.md).

## Musical semantics

- BPM range: 20–300.
- Displayed BPM is always quarter-note BPM.
- 2/4, 3/4, and 4/4 use quarter-note pulses.
- 6/8 uses six eighth-note pulses, not six quarter notes and not two dotted-quarter pulses.
- Beat 1 uses the accent click when enabled.
- A BPM update preserves remaining pulse phase.
- A signature update preserves pulse phase and makes the next pulse beat 1.

## Runtime and lifecycle

Start preloads and initializes the native stream once when practical. Stop invalidates the native run, rejects queued callbacks, resets visual state, and remains restartable. Route exit and app background stop playback; returning to foreground never auto-starts.

Starting tuner capture releases Metronome output. Starting the Metronome releases active tuner capture. The shared coordinator stores only release callbacks; it does not own audio engines or samples.

Tunathic uses shared media/sonification output and deliberately does not request global Android audio focus. This allows normal system mixing and avoids disruptive focus acquisition for every click.

## Validation gate

Automated validation must pass without requiring a plugin:

- domain and persistence tests;
- initialize/start/stop/restart and rapid-operation tests;
- BPM/signature/volume/accent live-update tests;
- failure/recovery and stale-callback tests;
- lifecycle, route, and tuner-transition tests;
- English/Turkish, narrow, large-text, error, control, and beat widget tests.

Release completion additionally requires physical Android validation at 40, 60, 90, 120, 160, 200, and 300 BPM; 3/4, 4/4, and 6/8; rapid live changes; at least 20 Start/Stop cycles; navigation/background/tuner transitions; and a continuous 10-minute run. Phone speaker is required; wired and Bluetooth output are tested when available.

## Current validation status

- Baseline `flutter analyze`: passed.
- Baseline full `flutter test`: passed.
- Updated focused Metronome/Tuner regression suite: passed.
- Updated full `flutter test`: passed, 263 tests including first-start and route re-entry hotfix regressions.
- Updated `flutter analyze`: passed with no issues.
- Android debug, profile, and release APKs with Oboe/JNI: built successfully.
- Release APK content check: native library present for arm64-v8a, armeabi-v7a, and x86_64; bundled Oboe license present.
- Physical Android validation passed on device `23021RAAEG` (Android 15/API 35). Oboe selected AAudio at 48 kHz, mono, 192 frames per burst, a 384-frame buffer, shared low-latency mode, and output device ID 3.
- Five force-stopped fresh-process first starts each remained active for at least two minutes. Every run opened stream generation 1/run 1, reached its first native audio callback, and produced no unexpected Stop, disconnect, or error callback.
- Ten post-fix fresh-route entries passed consecutively. Stream generations 1 through 10 each started and reached a first audio callback; no stale callback, native error, or error widget occurred.
- Physical BPM coverage passed at 40, 60, 90, 120, 160, 200, and 300 BPM. Live 120/200/300 and 60/90/160 update sequences preserved the active stream without an unexpected Stop or error.
- Physical signature coverage passed for 3/4, 4/4, and 6/8. Accent and volume changes were also applied live without recreating or stopping the stream.
- Metronome-to-Tuner and active-Tuner-to-Metronome ownership transitions passed. The replacement Metronome stream reached its first audio callback with no native error.
- The continuous endurance run passed for 10 minutes 24 seconds and stopped explicitly after 174,110 native audio callbacks. It produced no disconnect or error callback.
- The tester's physical listening assessment remained that sustained timing quality was very good. No instrumented acoustic-onset measurement was performed, so callback timing is not represented as acoustic timing.

### First-start hotfix gate

Physical testing confirmed that overall Oboe timing is very good, but exposed one remaining route-lifecycle race: the first Start could be stopped by an older asynchronous route release that completed after a replacement stream began.

The hotfix serializes release before initialization, uses generation-scoped coordinator ownership, rejects stale native stream callbacks, and adds explicit native lifecycle diagnostics. Automated first-start, delayed-cleanup, coordinator, stale-error, restart, and failure tests are required alongside the existing suite.

The physical cold-start, fresh-route, BPM/signature, Tuner-transition, and 10-minute endurance matrix is complete.
