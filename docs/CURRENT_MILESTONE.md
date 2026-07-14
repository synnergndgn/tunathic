# Current Milestone: Phase 1B — Core Metronome

Phase 1B delivers a reliable, accessible, offline foreground metronome for Android. BPM Tap remains available, while every other unfinished tool stays labeled “Coming Soon”. This milestone does not complete all of Phase 1.

## In scope

- Start and stop controls for foreground playback
- Tempo selection from 20–300 BPM with buttons, numeric entry, and a precise slider
- 2/4, 3/4, 4/4, and 6/8 time signatures
- A distinct optional accent on the first beat
- Visual measure and current-beat indicators
- User-controlled click volume
- Reset to 120 BPM, 4/4, 65 percent volume, and accent enabled
- BPM Tap navigation and explicit result transfer
- Persisted BPM, time signature, accent preference, and volume
- Lifecycle-safe stopping, audio failure handling, accessibility, and English/Turkish localization
- Pure beat-sequence tests, deterministic controller tests, and widget interaction tests

## Timing strategy

Two short bundled WAV samples are preloaded into reusable `audioplayers` low-latency `AudioPool` instances before the scheduler starts. Each pool prewarms three players and can grow to four, providing conservative headroom for the 100-millisecond minimum interval produced by 6/8 at 300 BPM without loading an asset or constructing a player on each beat.

An anchored one-shot scheduler uses monotonic elapsed time to calculate each next deadline instead of relying on a repeating animation timer. It arms the next timer before invoking controller, visual-state, or asynchronous audio work. A mildly late callback retains the original following deadline. Deadlines already reached during a longer stall are skipped rather than emitted as a catch-up burst. Tempo or denominator changes cancel the previous timer and re-anchor one scheduler safely.

Debug builds log each intended deadline, callback time, lateness, skipped-deadline count, beat, BPM, and pending/completed/failed audio request state through `AppLogger`. Release builds do not log each beat.

This is the best maintainable foreground approach available through the selected package; `AudioPool` does not expose trustworthy future sample scheduling. Timing therefore crosses the Dart/platform boundary on each beat and is not sample-accurate.

## 6/8 interpretation

For Phase 1B, displayed BPM uses a quarter-note reference. Click duration is `quarter-note duration × 4 ÷ denominator`. Therefore 4/4, 3/4, and 2/4 produce quarter-note clicks, while 6/8 produces six eighth-note clicks per measure at twice the click rate. At 120 BPM, 4/4 clicks every 500 milliseconds and 6/8 clicks every 250 milliseconds. Beat one remains accented when accent is enabled. Dotted-quarter pulse interpretation is deferred.

## Out of scope

- Guitar tuner, microphone input, pitch detection, recording, or DSP
- Subdivisions, triplets, swing, custom rhythms, or custom accent patterns
- Custom time signatures, polyrhythms, count-in, or practice routines
- Tempo automation or MIDI
- Background playback, lock-screen controls, notifications, or services
- Advertisements, analytics, accounts, purchases, backend, or synchronization

## Completion criteria

- Audible and visual beats start and stop without duplicate schedulers.
- Tempo, time signature, accent, and volume changes take effect safely.
- The metronome stops when the app loses foreground focus and stays stopped on return.
- Audio failures stop playback, show a friendly localized error, and allow retry.
- BPM Tap values within 20–300 BPM can be applied without persisting tap sessions.
- Formatting, analysis, tests, and an Android debug APK build pass.

## Known limitations

- Audible timing depends on Dart scheduling, platform-channel transit, Android audio buffering, and device hardware latency.
- The implementation does not guarantee sample-accurate playback or identical latency across Android devices.
- Heavy foreground load can delay a beat; missed deadlines are skipped to avoid catch-up bursts.
- A physical Android test of the original Phase 1B build observed rare audible stuttering or delayed beats. The hotfix adds timing and audio-request instrumentation, but the observation must not be considered resolved until repeat physical-device testing supports that conclusion. No physical Android target was connected during automated hotfix validation, so the required repeat device run remains outstanding.
- Playback intentionally stops on any non-resumed lifecycle state and never resumes automatically.
- Only first-beat accents and the four listed time signatures are supported.
