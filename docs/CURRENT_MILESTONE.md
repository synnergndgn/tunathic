# Current Milestone: Phase 2A — Tuner Audio Prototype

Phase 2A validates the microphone-input foundation needed by a future guitar tuner. Foundation, BPM Tap, Core Metronome, its physical-device hotfix, and Application Polish are complete. This milestone is deliberately a technical audio prototype, not a working tuner.

## In scope

- One application-owned audio-input boundary with a `record`-based Android implementation
- Explicit runtime microphone permission requested only after the user presses Start
- Continuous mono signed PCM16 little-endian capture, requesting 48,000 Hz
- Immediate conversion of PCM16 bytes into frame-owned normalized `Float32List` samples in `[-1.0, 1.0)`
- Scalar diagnostics for peak, RMS, dBFS, frames, samples, duration, malformed frames, observed frame sizes, and arrival rate
- A maximum 10 Hz presentation update rate while every received frame contributes to statistics
- Explicit start, stop, lifecycle, stream-error, route-exit, and disposal cleanup
- A localized English and Turkish prototype screen with requested/reported format and clear privacy language
- Unit, controller, lifecycle, cleanup, and widget coverage with injectable fake audio input
- Android manifest permission limited to `RECORD_AUDIO`

## Capture contract

The client requests one 48 kHz mono PCM16 little-endian stream. Android and the audio backend may adjust a request; the screen distinguishes the requested configuration from a backend-reported adjustment. If the backend does not report an adjustment, Tunathic labels the reported sample rate unavailable and does not claim the requested rate was measured.

Frame sizes and arrival intervals are observed rather than assumed. The current backend selects its Android stream buffer unless a later milestone demonstrates a measured reason to override it. Raw bytes and normalized samples are held only for the current frame; long-running diagnostics retain counters and scalar aggregates, not audio history.

## Lifecycle, routing, and coexistence

Capture starts only through a visible user action. Opening the screen does not request permission or activate the microphone. Capture stops when requested, when the app leaves the foreground, when the route is left, or when an unrecoverable stream error occurs. It never resumes automatically.

Starting microphone capture first releases Metronome audio. Bluetooth routing is not managed by the prototype, no audio route is forced, and Android remains responsible for the selected input. This is intentional until physical-device evidence justifies more routing policy.

## User interface contract

The dashboard continues to label Guitar Tuner **Coming Soon**. Opening it shows a clearly named **Tuner Audio Prototype** with permission state, capture state, requested/reported PCM format, input level, and diagnostic counters. It must not display a detected note, frequency, cents offset, confidence, tuning needle, smoothing, or calibration control.

## Privacy

Microphone data is processed locally and only while foreground capture is active. Raw PCM, normalized samples, and signal statistics are not saved, uploaded, logged, or sent to GUNDEV. Debug logs contain configuration, aggregate counters, lifecycle reasons, and failures only—never sample values. The app still has no account, advertising, analytics, backend, or cloud transfer.

## Out of scope

- Pitch or fundamental-frequency detection
- Note mapping, cents calculation, confidence, smoothing, or a tuner needle
- Calibration, alternate tunings, instrument profiles, or noise gating
- Recording files, playback, sharing, persistence, upload, or background capture
- Forced microphone routing or automatic Bluetooth SCO management
- Changes to BPM Tap or Metronome behavior beyond releasing playback before capture
- Store publishing, signing, advertising, analytics, accounts, backend, or cloud features

## Completion criteria

- Permission grant and denial, successful start, unsupported format, retry, duplicate start, rapid stop, lifecycle stop, stream failure, stop failure, malformed input, throttling, configuration updates, navigation cleanup, and disposal failure have automated coverage.
- PCM16 conversion and signal statistics have deterministic pure-Dart tests.
- The prototype remains localized, scrollable, text-scale tolerant, and explicit about its non-tuner status.
- Formatting verification, analysis, the complete test suite, and an Android debug APK build pass.
- Final reporting records connected-device availability and does not claim physical validation when no physical Android target is present.

## Known limitations

- This milestone proves audio capture plumbing only; it cannot tune a guitar.
- `record` exposes permission as granted or denied but does not distinguish Android's permanent-denial state. The UI therefore provides a neutral retry instruction rather than claiming that distinction.
- The backend can report an adjusted client configuration, but this is not a measurement of the hardware endpoint sample rate.
- Frame arrival timing is measured when Dart receives a buffer, not with native capture timestamps, so it includes platform and scheduling delay.
- Audio focus, route selection, Bluetooth input behavior, interruptions, and device-specific sample-rate adjustment require physical-device observation.
- No physical Android target was connected during final Phase 2A validation, so permission, live PCM activity, denial/retry, background/foreground behavior, route changes, contention, and five-minute stability remain physically unverified.
- The app is not Play Store ready; its privacy draft and store disclosures require release review.
