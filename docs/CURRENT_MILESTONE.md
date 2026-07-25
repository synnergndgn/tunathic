# Current Milestone: Phase 2D — Final Guitar Tuner UI

Phase 2D places a production-facing monophonic Guitar Tuner on the validated Phase 2A–2C microphone, YIN, buffering, stabilization, and lifecycle stack. The feature is implemented and covered by deterministic tests. Final real-guitar validation and tuning polish remain required before declaring the tuner release-complete.

## Product experience

The dashboard opens Guitar Tuner as an available tool. The production route shows:

- Selected tuning preset and automatic/manual mode
- Six target strings with the active target identified
- Large stabilized note and octave
- Animated approximately −50 to +50 cent indicator
- Signed, unclamped cents text and current frequency
- Flat, sharp, in-tune, and signal-state text that does not rely on color
- One clear Start/Stop action and friendly microphone/processing errors

The layout is scrollable, responsive on narrow portrait phones, usable with large text, and supports light/dark themes plus English/Turkish. Raw confidence, PCM counters, detector durations, and other engineering data are absent from the production screen.

In debug builds, the science action opens `/debug/tuner-diagnostics`, preserving the Phase 2C diagnostic. That route is not registered in release builds.

## Tuning domain

`TuningPreset`, `TuningStringTarget`, `TuningPresetId`, and `TunerMode` are immutable pure Dart models. Every target stores its six-to-one string position, MIDI note, octave, and display name. Frequency is derived from MIDI with A4 = 440 Hz; it is never independently hardcoded.

Included presets:

- Standard: E2 A2 D3 G3 B3 E4
- Drop D: D2 A2 D3 G3 B3 E4
- Half Step Down: D#2 G#2 C#3 F#3 A#3 D#4
- Full Step Down: D2 G2 C3 F3 A3 D4
- DADGAD: D2 A2 D3 G3 A3 D4
- Open G: D2 G2 D3 G3 B3 D4
- Open D: D2 A2 D3 F#3 A3 D4

Calibration remains fixed at A4 = 440 Hz. No calibration UI is included.

## Target selection

Automatic mode consumes only the Phase 2C stabilized pitch. It compares logarithmic/cents distance to every target:

- A target must be within 200 cents to be considered trustworthy.
- The current target is retained while it remains within 25 cents of the nearest candidate.
- A different target requires two consecutive supporting observations.
- Isolated octave/transient estimates therefore cannot immediately change strings.
- Four selector-level no-pitch observations clear an automatic target; the pipeline's 350 ms stale clearing also removes it.
- Capture restart and preset change reset pending evidence.

Manual mode bypasses automatic selection. The chosen string stays locked until the user changes it, including while waiting for a signal.

## Cents and in-tune state

Displayed target-relative cents are:

`1200 × log2(detectedFrequency / targetFrequency)`

The signed domain result is never clamped. Only the marker position is limited to the visual ±50-cent range.

Central thresholds are:

- In tune: absolute distance at most 5 cents
- Near: more than 5 and at most 15 cents
- Out: more than 15 cents

Negative is flat and positive is sharp. A pitch more than 200 cents from every automatic target may still show its detected note, but receives no target-relative cents or misleading in-tune state.

## Haptics

The controller requests one light impact after three consecutive stable, targeted, in-tune UI observations. It uses `AppHaptics`, so the global haptics preference remains authoritative. Feedback is disarmed until the signal leaves in-tune, and resets on target change, preset change, capture restart, or lifecycle cleanup. Unstable/no-signal states never vibrate.

## Persistence

Only these tuner preferences are stored:

- Preset ID
- Automatic/manual mode
- Manual string position

Unknown IDs and invalid string positions safely fall back to Standard, Automatic, and string 6. Samples, pitch history, last detected note, automatic target, cents, and diagnostics remain transient.

## Lifecycle and privacy

The production controller delegates capture to the existing `TunerAudioController`; it does not duplicate or weaken its guarantees. Stop, route exit, provider disposal, backgrounding, stream failure, and processing failure stop microphone capture and analysis. Returning to foreground does not restart. Generations still reject late results.

Raw PCM remains local and transient. Phase 2D adds no recording, upload, analytics, ads, account, backend, or background microphone behavior.

## Accessibility

One semantic value describes each logical result: detected note plus octave, signed cents direction, target string, frequency, selected mode, and signal state. Direction arrows and text supplement color. Controls meet Material touch-target behavior, keyboard behavior follows standard Flutter controls, reduced-motion preference disables the cents-marker transition, and narrow/large-text layouts switch the mode control to a vertical arrangement.

## Validation status

- Pure tests cover presets, derived frequencies, signed cents, thresholds, target distance, hysteresis, confirmation, octave/transient rejection, no-pitch clearing, reset, tuning changes, and invalid preferences.
- Controller tests cover automatic/manual operation, preset/string persistence, lifecycle target reset, stale-session rejection, and one-shot stable in-tune haptics.
- Widget tests cover production states, flat/sharp/in-tune presentation, modes, selectors, English/Turkish, light/dark themes, narrow large text, semantics, and absence of diagnostic overload.
- Physical Android testing on a 23021RAAEG confirmed permission, capture, Standard automatic/manual controls, and correct stabilized E2, A2, and D3 observations. It also exposed excessive short no-pitch clearing with the original 1,024-sample hop: 3,840-sample input chunks produced immediate pending-frame replacement while the main-isolate detector averaged about 32 ms. The production configuration now uses a 2,048-sample hop and retains up to eight consecutive no-pitch analyses, approximately matching the existing 350 ms stale policy.
- The same session attributed high-confidence `A2 → 55 Hz/A1` and transient `D3 → ~73 Hz/~49 Hz` errors to the generic longer-period correction. Subharmonic promotion now requires a separate 0.11 clarity improvement instead of the boundary-specific 0.01 margin and at least 0.12 relative spectral support at the proposed lower fundamental. The complete existing pitch matrix still passes, with noisy guitar-spectrum and isolated spectral-evidence regressions covering the octave-fold path. Physical retesting showed that a real A2 release can still contain enough lower-frequency energy to pass the DSP guard.
- The production controller therefore adds a tuning-relative Automatic-mode guard: a candidate more than 200 cents from the selected string is not displayed. It retains the last accepted pitch for up to eight new detector results, does not count retained/rejected data as fresh haptic evidence, and then hides the pitch while keeping the useful target context. This also fixes the earlier behavior that hid a correct stabilized pitch on a single unstable raw frame. A rebuilt-device repeat is required before these product changes are considered validated.
- Physical diagnostics identified a persistent 54–55 Hz acoustic background tone at a 20–30 cm test position (silence RMS approximately 0.025–0.030). Moving the phone to 5–10 cm from the guitar and away from the noise source reduced silence RMS to approximately 0.005–0.006; four sampled D3 attacks then measured 146.39–146.50 Hz at 0.982–0.994 confidence without 73 Hz or 49 Hz octave errors. Weak decay frames were retained briefly and then cleared instead of displaying an unsupported estimate.
- Returning from the debug diagnostic exposed a shared-controller lifecycle bug: disposing the diagnostic route permanently marked the still-observed audio controller as disposed, leaving the production Start button unable to restart capture. Route release now stops capture without disposing the reusable controller; actual input disposal occurs only when the provider itself is disposed. A regression test covers route release followed by restart.

## Known limitations and remaining work

- The tuner is monophonic and inherits the validated YIN/stabilizer limitations.
- A4 is fixed at 440 Hz.
- Automatic target selection is guitar-preset-specific; arbitrary custom tunings are not supported.
- Android real-guitar evaluation still needs user confirmation for all six strings on the rebuilt APK, plus target accuracy, flicker, needle feel, haptics, stale clearing, route cleanup, and repeated session stability. The YIN acceptance/confidence thresholds were not relaxed because close-position D3 attacks produced high-confidence correct estimates while the earlier interruption was attributable to a measured acoustic background tone.
- Store publishing, legal review, calibration UI, custom tunings, subscriptions, ads, analytics, accounts, and cloud behavior remain out of scope.
