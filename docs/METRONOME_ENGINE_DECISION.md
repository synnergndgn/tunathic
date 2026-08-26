# Metronome Engine Decision

## Baseline risk record

Phase 2E began from the physically observed Android failures: jitter, delayed or missing clicks, spontaneous stopping, and partially silent clicks. The baseline repository was clean apart from the pre-existing untracked `.claude/` directory. `flutter analyze` and the full automated test suite passed, which demonstrated that the earlier tests did not exercise audible Android timing.

The replaced production path had these concrete risks:

- `AnchoredMetronomeScheduler` used a Dart `Timer` and `Stopwatch` for musical deadlines. Dart isolate stalls could delay callbacks, and deadlines reached during a longer stall were deliberately skipped.
- Each callback started an asynchronous `audioplayers` `AudioPool` request. Multiple requests could be pending, and platform-channel completion did not represent audible onset.
- Every click instance was manually stopped after 100 ms. This added another Dart timer and could truncate or race playback.
- A late error from any individual playback future stopped and disposed the complete session, even if newer clicks had already been requested.
- Beat numbering, UI state, and the request that triggered sound shared one Dart callback. A delayed visual callback therefore also delayed the audible request.
- The audio context requested full `gain` focus for a sequence of short clicks, which was more disruptive than needed.

The two project WAV files were not a root cause. They are original generated mono PCM16 assets at 44.1 kHz: the regular click is 40 ms with a -6.0 dBFS peak, and the accent is 55 ms with a -4.15 dBFS peak. Neither clips or contains excess leading silence. The native loader applies a final 3 ms fade so playback reaches zero without a cut-off edge.

## Option A spike: `metronome` 2.0.12

The latest compatible stable pub.dev version evaluated on 2026-07-26 was `metronome` 2.0.12. It is BSD-3-Clause licensed and advertises Android, iOS, macOS, web, and Windows support. Its API provides initialization, play/stop, integer BPM, integer bar length, volume, regular/accent assets, and a tick stream.

The package was rejected before production adoption:

- The 2.0.12 Android method handler does not complete `MethodChannel.Result` for initialization, play, pause, stop, setters, or destroy. Corresponding Dart futures can remain pending.
- The Dart adapter catches and prints platform exceptions instead of exposing them, so Tunathic could not provide a reliable error state or retry contract.
- Android BPM and time-signature updates pause and restart the `AudioTrack`, reset the bar, and create a replacement writer thread. This does not meet the phase-preserving, race-free live-update requirement.
- The public time-signature value is only beats per bar. Denominator-aware 6/8 would require hidden BPM translation rather than an explicit musical model.
- Accent disablement requires replacing the accent audio source, which also restarts active playback.

The package does render a prebuilt bar through native `AudioTrack`, so it improves timing ownership over the old Dart scheduler. Its lifecycle, update, and error behavior nevertheless fail essential acceptance criteria. The temporary dependency was removed.

## Chosen fallback: native Oboe engine

Tunathic now uses Oboe 1.10.0, the current stable Android low-latency library at the time of implementation. Oboe is Apache-2.0 licensed. Its license is bundled as an app asset and registered with Flutter's license page.

The engine requests a low-latency, shared output stream with the device's natural sample rate. Oboe selects AAudio on supported Android versions and OpenSL ES on older supported versions. The shared mode and media/sonification attributes allow normal system mixing. Tunathic deliberately does not acquire global audio focus, so it does not pause or duck other media and never acquires focus per click.

The Oboe data callback owns:

- the output sample clock;
- fractional frames-per-pulse accumulation;
- regular/accent sample rendering;
- bar position and first-beat accent;
- phase-preserving BPM changes;
- denominator-aware pulse duration;
- deterministic signature transitions.

No Dart timer, Flutter frame callback, method-channel call, or UI state change triggers an audible click.

## Musical behavior

The supported range remains 20–300 BPM. Displayed BPM is quarter-note BPM for every signature. Pulse duration is:

`60 seconds × 4 ÷ BPM ÷ denominator`

Therefore 2/4, 3/4, and 4/4 emit quarter-note pulses. 6/8 emits six eighth-note pulses; at 120 BPM they are 250 ms apart. Beat 1 is accented when accent is enabled. Dotted-quarter 6/8 is not the current product meaning.

A BPM update preserves the fraction remaining until the next pulse, then continues from the new interval. It does not stop or recreate the stream. A signature update preserves pulse phase but makes the next pulse beat 1 under the new signature. Configuration revisions suppress visual callbacks queued under the previous configuration.

Volume is applied atomically in the render callback. Accent changes affect the next rendered beat. Neither setting reinitializes the stream.

## Flutter boundary and diagnostics

`MetronomeEngine` is the project-owned boundary. Widgets depend only on `MetronomeController`; tests replace the engine with `FakeMetronomeEngine`.

Native beat events include run ID, sequence, beat number, accent state, and rendered audio-frame position. Run IDs reject callbacks after Stop or restart. These events update visual state only. The callback timestamp is explicitly not an acoustic measurement.

Debug logs include engine/API/sample-rate/buffer details, requested BPM and signature changes, first Flutter callback latency, callback cadence/deviation, callback count, detectable callback gaps, native x-run count on Stop, and engine failures. Audible accuracy still requires physical or acoustic measurement.

## Lifecycle and coordination

Start initializes assets and the stream once per route audio lifetime. Stop halts the stream, invalidates the run, clears visual beat state, and remains immediately restartable. Leaving the route stops and disposes native resources. Backgrounding stops playback, and foregrounding never auto-starts.

`ToolAudioCoordinator` is a small callback registry, not a global audio engine. Starting tuner capture releases the metronome; starting the metronome releases active tuner capture. Each feature retains ownership of its platform resources.

## First-start lifecycle hotfix

Physical Android testing found one deterministic follow-up failure: the first Start after entering a fresh Metronome route could play several clicks and then stop, while the second Start remained stable.

The root cause was route cleanup ownership, not the Oboe render clock. `MetronomeScreen.dispose()` intentionally launched `releaseAudio()` without blocking Flutter navigation, but the provider-scoped controller survives route disposal. A quick route re-entry could call `prepareForScreen()` and initialize/start a replacement stream while the older asynchronous release was between its Stop and Dispose operations. When that stale cleanup resumed, it disposed the replacement stream. The second Start occurred after the old cleanup had completed, so it was unaffected.

The hotfix serializes route release and initialization: Start awaits any in-flight release before acquiring coordinator ownership or opening a stream. Coordinator leases carry monotonically increasing generations, so delayed ownership results cannot replace the latest owner. Native callbacks now carry both run ID and stream generation; an error or beat from an older stream is rejected in C++, Kotlin, and Dart.

The fresh-route physical matrix also exposed a Flutter lifecycle assertion: `prepareForScreen()` could reset provider state synchronously from `MetronomeScreen.initState()` while GoRouter was building the replacement route. Riverpod rejected that mutation and displayed the app's friendly error widget. The screen now schedules route preparation in a microtask after the build phase. A widget regression leaves a running route, returns to the dashboard, re-enters, and starts again while asserting that no framework exception is produced.

The native lifecycle is explicit (`uninitialized`, `initialized`, `starting`, `running`, `stopping`, `stopped`, `recovering`, `failed`, and `disposed`). The active stream pointer remains strongly owned for its complete lifetime. A stale Oboe error callback is compared with the active stream identity before it can publish a failure.

Debug builds record engine and stream generations, native state transitions, Oboe state before and after Start, first audio callback, callback count, Stop/close requests, both error callback phases, selected API, sample rate, channels, burst/buffer details, sharing/performance modes, and device ID. Controller diagnostics record operation generation, coordinator owner/generation, all stop reasons, and callback filtering decisions. Audio samples are never logged.

No automatic Oboe recovery was added. The diagnosed failure is stale application cleanup, and silently reopening a stream would hide that programming error. A current-generation native disconnect remains a visible engine failure and retry path; bounded native recovery should be considered only if physical diagnostics demonstrate a real route/device disconnection.

## Validation status

Automated domain, preference, controller, widget, lifecycle, failure, and tuner-coordination tests use fakes and pass without loading native audio. The hotfix suite passes with 263 tests, and Dart analysis reports no issues. Android debug, profile, and release APKs containing the Oboe/JNI engine build successfully; the release APK was inspected and contains all three configured ABI libraries plus the bundled Oboe license.

Physical hotfix validation passed on `23021RAAEG` running Android 15/API 35:

- five force-stopped fresh-process first starts ran for at least two minutes each with stream generation 1/run 1 and no unexpected Stop, disconnect, or native error;
- ten consecutive post-fix route entries opened generations 1 through 10, each reached its first native audio callback, and produced no stale callback, native error, or error widget;
- 40, 60, 90, 120, 160, 200, and 300 BPM; 3/4, 4/4, and 6/8; accent; and volume changes were exercised without an unexpected stream restart or Stop;
- running-Metronome to Tuner and active-Tuner to Metronome ownership transitions completed cleanly;
- a 10-minute 24-second untouched endurance run stopped explicitly after 174,110 native audio callbacks with no error or disconnect.

The tester's physical assessment remained that sustained timing quality was very good and the former jitter/missing-click symptoms were not observed. No microphone-based acoustic-onset measurement was made, so native and Flutter callback diagnostics are not claimed as acoustic timing measurements.
