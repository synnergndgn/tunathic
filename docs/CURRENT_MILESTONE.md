# Current Milestone: Phase 2C — Real-Time Pitch Pipeline

Phase 2C connects the physically validated Phase 2A normalized microphone stream to the synthetic/offline-validated Phase 2B YIN detector through a bounded foreground analysis pipeline. The routed screen is explicitly a development diagnostic, not the final Guitar Tuner. Guitar Tuner remains Coming Soon.

## In scope

- Arbitrary normalized mono PCM chunks assembled into overlapping detector frames
- One active detector operation and at most one newest pending frame
- Log-pitch smoothing, octave rejection, note hysteresis, no-pitch clearing, and stale timeout outside `YinPitchDetector`
- Riverpod-owned capture, analysis, lifecycle, error, and transient diagnostic state
- English and Turkish development diagnostics without a needle, string UI, presets, or tuning modes
- Local, in-memory processing with no raw sample, pitch-history, or diagnostic persistence

## Analysis configuration

Defaults are centralized in `RealtimePitchConfiguration`:

- Frame size: 4,096 samples
- Hop size: 1,024 samples
- Overlap: 75%
- History length: 5 accepted estimates
- Minimum confidence: 0.82
- Median outlier threshold: 45 cents
- Exponential smoothing factor: 0.35
- Note-boundary margin: 8 cents
- Note and octave switch confirmations: 2
- Sustained no-pitch clearing: 4 analyzed results
- Stale timeout: 350 ms
- UI publication interval: 75 ms, at most approximately 13.3 updates/s

At 48 kHz, a frame spans about 85.3 ms and a hop about 21.3 ms. At 44.1 kHz they span about 92.9 ms and 23.2 ms. The frame exceeds YIN's 3,600-sample requirement at 48 kHz and 3,308-sample requirement at 44.1 kHz while the hop provides responsive overlapping observations.

## Ring buffer and frame assembly

`SampleWindowAssembler` owns one fixed `Float32List` ring whose capacity equals the frame size. It accepts arbitrary chunk boundaries, writes each sample once, emits a chronological frame-owned 4,096-sample snapshot when full, then emits after every 1,024 new samples. It does not concatenate growing arrays or retain samples older than the current analysis window.

One large chunk may produce several windows. Buffer use never exceeds 4,096 samples. Diagnostics track received samples, emitted frames, discarded partial samples, resets, current buffered samples, and maximum occupancy. A sample-rate change counts and discards the partial old-rate buffer before reset; different rates are never mixed.

## Backpressure and session safety

`RealtimePitchPipeline` permits one active detector future. If frames arrive during analysis, it retains only one pending frame; each newer frame replaces the older pending frame and increments replacement/drop counters. Capture callbacks enqueue no unbounded work and prioritize current audio.

Every start and sample-rate change advances a generation. Stop, route disposal, lifecycle interruption, stream failure, analysis failure, and restart invalidate pending work. An already-running synchronous calculation cannot be cancelled, but its late result is ignored and cannot mutate a stopped or newer session.

## Detector execution placement

Detection currently uses one asynchronously scheduled main-isolate executor. It never uses `compute()` and does not spawn a per-frame isolate. The Phase 2B Windows JIT observation was approximately 11.35 ms median for a 4,096-sample frame, below the 21.3 ms 48 kHz hop, but that is not Android evidence.

No Android device was connected during this implementation; `flutter devices` reported only Windows and Edge. Therefore no Android duration, UI-jank, allocation, thermal, replacement-rate, or real-guitar claim is made. Main-isolate placement remains provisional until a physical profile-mode session measures representative hardware. A single long-lived worker isolate is authorized only if those measurements show persistent responsiveness or cadence pressure and must account for typed-data transfer costs.

## Stabilization and note hysteresis

`PitchStabilizer` converts frequency to continuous MIDI/log-pitch space. Estimates below 0.82 confidence follow the no-pitch path. For the locked note, a five-item rolling history is median-centered; values farther than 45 cents from the median are excluded, and the accepted target is followed with a 0.35 exponential factor.

The stabilizer never edits the raw detector result. An isolated octave or clearly different note is held as pending. Two consecutive estimates confirm a genuine switch. Near a semitone boundary, the current note remains locked until the other note is at least 8 cents beyond the midpoint and persists for two estimates. Smoothing history resets on a confirmed note change so clearly different notes are never averaged together.

A short no-pitch gap retains the previous stable value only as transient context while status becomes unstable. Four consecutive no-pitch/low-confidence results clear it. Independently, 350 ms without a reliable estimate clears the last pitch and exposes no signal. Stop, restart, sample-rate changes, and lifecycle cleanup reset smoothing, hysteresis, and stale deadlines.

## Controller, lifecycle, and errors

`TunerAudioController` still owns permission and Phase 2A capture. Before Start it releases Tunathic's Metronome audio. Once capture starts it configures the pipeline from the reported rate, or the requested rate when no report exists, and passes frame-owned normalized samples without assuming chunk size.

Capture and analysis stop on user Stop, route disposal, provider disposal, all non-foreground lifecycle states, unexpected stream end, stream error, invalid reported sample rate, or detector exception. Foreground return never restarts capture. Operation versions and pipeline generations prevent duplicate starts, duplicate analysis loops, and stale callbacks. Technical errors go only to the local logger; UI uses localized permission, capture, and analysis messages.

## Development diagnostic screen

The existing prototype route now shows capture/permission state, requested and reported rate, PCM chunk statistics, buffer occupancy, frames assembled/analyzed/replaced/dropped, average and maximum detector time, raw frequency/confidence/note/cents, stabilized note/frequency/cents, no-signal state, execution mode, and friendly errors. Publication is throttled independently of PCM arrival.

The screen remains scrollable for narrow and large-text layouts and contains no final tuner needle, in-tune visualization, string target, presets, calibration, waveform, spectrum, or fake precision claim.

## Privacy

Raw PCM remains transient and local. The ring retains at most the current window and frame-owned work in flight. Replaced frames, retired samples, pitch history, and diagnostics are discarded in memory. No raw bytes, sample values, pitch history, or continuous telemetry are logged, persisted, uploaded, or transmitted.

## Validation status and known limitations

- Deterministic tests cover arbitrary chunks, exact overlap, multiple emission, bounded memory, sample-rate reset, slow-detector backpressure, late results, restart isolation, stale clearing, smoothing, octave changes, deliberate note changes, note-boundary flicker, controller lifecycle/errors, localization, and diagnostic presentation.
- Physical Android and real-guitar validation was not performed because no Android device was connected.
- Actual Android detector cadence, time to first pitch, settle time, note-change delay, octave errors, flicker, stale behavior, CPU, GC, thermal behavior, and five-minute stability remain unmeasured.
- Main-isolate suitability is provisional, not a release conclusion.
- The diagnostic is monophonic and inherits the offline detector's harmonic, transient, inharmonicity, and noise limitations.
- The final production Guitar Tuner UI and product behavior remain out of scope.

## Remaining physical validation gate

On a connected Android device, run profile mode and record requested/reported rate, typical PCM chunk size, frame cadence, detector average/maximum duration, replacements/drops, responsiveness, first-pitch and settle time, note-change delay, octave errors, flicker, stale clearing, CPU/thermal behavior, microphone-indicator cleanup, and route/lifecycle cleanup. Exercise quiet/speech/noisy conditions, all open strings, fretted and repeated notes, soft/hard/muted plucks, rapid string changes, decay, five minutes of capture, repeated Start/Stop, backgrounding, route exit, and Metronome-to-tuner transition. Never save or upload raw audio.
