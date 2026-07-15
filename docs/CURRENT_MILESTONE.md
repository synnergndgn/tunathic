# Current Milestone: Phase 2B — Offline Pitch Detection Engine

Phase 2B adds a deterministic, Flutter-independent pitch engine for normalized mono samples. Phase 2A microphone capture has been physically validated separately and remains unchanged. The new engine is not connected to that live stream, so Guitar Tuner remains Coming Soon and Tunathic still does not present a working tuner.

## In scope

- A project-owned pure Dart YIN pitch detector under `lib/features/tuner_pitch/`
- Immutable detector configuration and typed detected/no-pitch results
- A 40–1,200 Hz fundamental-frequency range for guitar and bass
- 44.1 kHz and 48 kHz normalized mono `Float32List` input
- A4 = 440 Hz 12-tone equal-temperament conversion to MIDI, sharp note name, octave, and signed cents
- Deterministic synthetic sine, harmonic, noise, DC-offset, envelope, combined-signal, and silence utilities for tests
- Pure tests for accuracy, range boundaries, confidence, harmonics, octave resistance, noise, numeric validation, and determinism
- An optional non-production diagnostic command for error and execution-time observations

## Algorithm and defaults

The primary algorithm is YIN with a direct time-domain difference function, cumulative mean normalized difference, absolute threshold selection, and parabolic period refinement. Defaults are:

- Minimum frequency: 40 Hz
- Maximum frequency: 1,200 Hz
- Minimum centered RMS: 0.002
- YIN threshold: 0.18
- Minimum confidence: 0.82
- Minimum low-frequency periods: 3
- Lower-range rejection guard: 10% beyond the configured maximum lag
- Harmonic candidate multiples inspected: up to 4
- Required score improvement before preferring a longer fundamental period: 0.01
- Equal-temperament reference: A4 = 440 Hz

The default minimum frame length is 3,600 samples at 48 kHz and 3,308 samples at 44.1 kHz. A 4,096-sample frame is the practical recommendation: it spans 85.3 ms at 48 kHz and contains enough periods for E1 and the 40 Hz lower boundary. No power-of-two frame length is required.

## Input and output contract

`PitchDetector.detect` accepts a frame-owned normalized mono `Float32List` and a positive sample rate. It returns a `PitchEstimate`; normal unusable input never throws. A detected result contains frequency, confidence, period, MIDI note, sharp note class, octave, and signed cents. A no-pitch result contains a typed reason without localized text.

No-pitch reasons cover empty frames, invalid sample rates, non-finite or out-of-range normalized samples, insufficient frames, centered near-silence, incompatible detection range, and low confidence. Frequencies outside 40–1,200 Hz are not returned as valid estimates.

## Preprocessing and confidence

The detector computes mean-centered RMS before analysis. A constant DC offset cancels mathematically in each difference term, so it requires no copied, filtered buffer. No window, gain normalization, high-pass filter, complex gate, or isolate is added. Silence is rejected below the configured RMS threshold.

Confidence is `1 - CMNDF(period)`, clamped to 0–1. A candidate must cross the 0.18 YIN threshold and retain at least 0.82 confidence. White noise and the tested very-low-SNR input return no pitch rather than a low-confidence frequency.

## Harmonics and octave resistance

YIN selects the first threshold-crossing local minimum only inside the configured supported lag range. Tunathic then inspects nearby integer period multiples through four and selects a longer supported period only when its normalized difference improves by at least 0.01. Guard-only periods can reject a clearer below-range fundamental but cannot become a valid candidate. A separate clarity comparison prevents an unsupported high-only tone from being reported as an in-range subharmonic while allowing a valid fundamental beneath stronger high harmonics. This general rule corrected the tested dominant-second, dominant-third, weak-fundamental, missing-fundamental-with-second-and-third, and bass-like spectra without note-specific fixes.

A single isolated harmonic contains no mathematical evidence of an absent lower fundamental. Real instruments can also be inharmonic or transient, so octave ambiguity is reduced but not eliminated.

## Measured deterministic results

The 4,096-sample, 48 kHz clean-sine diagnostic produced the following representative results on the development machine. Error cents compare estimated frequency with the synthetic expected frequency, not with the nearest note.

| Expected Hz | Estimated Hz | Error % | Error cents | Confidence |
| ---: | ---: | ---: | ---: | ---: |
| 40.00 | 40.000000 | 0.000000 | 0.0000 | 1.000000 |
| 41.20 | 41.200000 | 0.000000 | -0.0000 | 1.000000 |
| 55.00 | 54.999993 | 0.000013 | -0.0002 | 0.999998 |
| 61.74 | 61.739995 | 0.000008 | -0.0001 | 0.999993 |
| 82.41 | 82.410000 | 0.000000 | -0.0000 | 0.999988 |
| 110.00 | 109.999986 | 0.000013 | -0.0002 | 0.999986 |
| 146.83 | 146.829952 | 0.000033 | -0.0006 | 0.999998 |
| 196.00 | 195.999888 | 0.000057 | -0.0010 | 0.999997 |
| 246.94 | 246.939971 | 0.000012 | -0.0002 | 0.999926 |
| 329.63 | 329.629848 | 0.000046 | -0.0008 | 0.999864 |
| 440.00 | 440.000053 | 0.000012 | 0.0002 | 0.999986 |
| 659.25 | 659.247713 | 0.000347 | -0.0060 | 0.999865 |
| 880.00 | 879.998312 | 0.000192 | -0.0033 | 0.998615 |
| 1,000.00 | 999.997120 | 0.000288 | -0.0050 | 1.000000 |
| 1,200.00 | 1199.997845 | 0.000180 | -0.0031 | 1.000000 |

These synthetic results exceed the milestone's 0.5% target but are not evidence of equivalent recorded-instrument or live-device accuracy.

The optional JIT diagnostic warms the detector and performs 30 non-asserted runs. One representative Windows development-machine run measured an 11.35 ms median and 12.00 ms average for 4,096 samples, and a 26.23 ms median and 25.84 ms average for 8,192 samples. Wall-clock timing varies with machine load and is deliberately excluded from pass/fail tests.

## Out of scope

- Connecting pitch detection to Phase 2A microphone frames
- Live buffering, overlapping analysis windows, scheduling, isolates, or backpressure
- Real-time controller state, smoothing, hysteresis, debounce, or result history
- User-facing frequency, note, cents, confidence, strings, or tuner needle UI
- Tuning presets, alternate tunings, calibration controls, or string selection
- Recording, playback monitoring, visualization, analytics, advertising, backend, or cloud work

## Completion criteria

- The DSP and note domain import no Flutter, platform, audio, timer, widget, or networking API.
- Required clean frequencies, exact range limits, semitone boundaries, sharp/flat cents, harmonics, noise, DC, envelope, phase, sample rates, frame sizes, invalid numbers, and no-pitch behavior have deterministic coverage.
- Existing Phase 2A and application behavior remains unchanged and all regression tests pass.
- Formatting verification, analysis, complete tests, and an Android debug APK build pass.

## Known limitations

- Only a single monophonic fundamental is estimated; chords and multiple simultaneous sources are unsupported.
- Confidence is YIN periodicity clarity, not a calibrated probability that a note is correct.
- The direct implementation is `O(N × L)` time and `O(L)` temporary memory. At 48 kHz the configured 40 Hz limit is a 1,200-sample lag; a 10% rejection guard searches to 1,320 samples to distinguish just-below-range pitches.
- Lower-bound interpolation uses a relative `1e-6` numerical tolerance only for an exact maximum-lag candidate; 39.9999 Hz and lower regression values remain rejected rather than clamped into range.
- Each call allocates raw and normalized `Float64List` lag buffers plus its immutable result. Reuse may be considered only after Phase 2C profiling establishes a need.
- Synthetic periodic signals are cleaner than plucked strings with attack transients, decay, inharmonicity, body resonances, environmental noise, and microphone processing.
- Real-time latency, frame overlap, Android CPU cost, isolate placement, smoothing, and display stability are intentionally unmeasured until Phase 2C.
