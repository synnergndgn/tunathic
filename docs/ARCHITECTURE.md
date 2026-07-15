# Architecture

Tunathic uses a pragmatic feature-first Flutter structure. Phase 2C connects the physically validated Phase 2A capture boundary to the Phase 2B pure Dart detector through a bounded, transient real-time pipeline while keeping capture, buffering, detection, stabilization, lifecycle, and presentation responsibilities separate.

## Folder responsibilities

- `lib/app/` owns application composition: bootstrap, router, persisted application settings, and Material themes.
- `lib/core/` owns app-wide technical boundaries for logging, preferences, package information, and haptic output.
- `lib/features/` groups user-facing areas. Dashboard, Settings, About, and Privacy compose the application shell. BPM Tap separates pure estimation logic from presentation state. Metronome separates configuration and beat sequencing, scheduling and orchestration, audio output, persistence, and presentation. Tuner Audio separates its input boundary and package adapter, immutable PCM/frame domain types, pure statistics, capture orchestration, and diagnostic UI. Tuner Pitch contains only Flutter-independent configuration, results, musical-note conversion, the detector boundary, and DSP. Tuner Realtime owns bounded window assembly, backpressure, stabilization, hysteresis, stale timing, and transient diagnostics. Other unfinished tools share one placeholder presentation.
- `lib/shared/` contains reusable interface elements that are not specific to one feature. Foundation contains the friendly error view.
- `lib/l10n/` contains source ARB files and generated Flutter localization classes.

No UI component imports `shared_preferences`, calls the microphone package, or contains audio conversion or DSP. Platform-facing playback is isolated behind `MetronomeAudioOutput`; microphone input is isolated behind `TunerAudioInput`; offline pitch analysis is isolated behind `PitchDetector`. Current tools operate offline, and neither BPM Tap sessions nor microphone samples are persisted.

## State management

Riverpod provides scoped dependency injection and reactive application settings. `ProviderScope` is the application root. `AppSettingsController` owns theme, locale, and haptic-preference changes; widgets observe its immutable state and never read or write storage directly. The initially persisted settings are loaded before `runApp`, preventing a visible theme, language, or interaction-preference change after the first frame.

`AppHaptics` gates meaningful direct feedback against the current setting and delegates to an injectable `HapticFeedbackOutput`. Production uses Flutter’s built-in system haptic API; tests use a recording fake. BPM taps, Metronome start/stop, result application, resets, navigation, and important selections may request subtle feedback. Timers, passive state, sliders, and Metronome beats do not.

`BpmTapController` owns the in-memory tap session, monotonic elapsed-time reads, manual reset, and inactivity timer. The BPM Tap widget only observes immutable state and forwards tap or reset actions. Its elapsed-time provider can be replaced in tests, keeping controller behavior deterministic without a platform clock dependency.

`MetronomeController` owns immutable runtime state and coordinates the scheduler, audio boundary, and preferences. Widgets forward user actions and render state. Playback stops when the app loses foreground focus and does not resume automatically. Leaving the screen synchronously invalidates pending start work, stops the scheduler, and releases audio without mutating Riverpod during widget teardown; a later screen entry normalizes the retained runtime state before rendering.

`TunerAudioController` owns the capture state machine and creates its audio input through an injectable factory. It requests permission only in response to Start, releases Metronome audio before capture, rejects duplicate operations, subscribes to frames and configuration changes, and owns all cleanup. It feeds normalized frame-owned samples into `RealtimePitchPipeline`; the UI observes only immutable scalar snapshots and never receives PCM bytes. Controller operation versions and pipeline generations invalidate delayed permission, detector, stop, and restart work. Backgrounding stops capture and analysis, and foregrounding never restarts them automatically.

## Navigation

GoRouter provides one central route table:

- `/` displays the responsive dashboard.
- `/settings` displays appearance, interaction, and application preferences and links.
- `/about` displays localized product, publisher, tool, version, privacy, and license information.
- `/privacy` displays the current local/offline privacy summary.
- `/tools/bpm-tap` displays the functional BPM Tap screen.
- `/tools/metronome` displays the functional Metronome screen.
- `/tools/guitar-tuner` displays the Real-Time Pitch Diagnostic while the dashboard entry remains Coming Soon.
- `/tools/:toolId` resolves every other unfinished known tool to its Coming Soon placeholder.

Unknown paths and tool identifiers display a friendly localized not-found screen. Tool IDs are stable, nonlocalized route segments; tool names are localized at presentation time.

The Metronome opens BPM Tap with an explicit result contract. BPM Tap returns only a valid whole-number estimate when the user chooses Apply; the metronome validates the 20–300 BPM range and then updates and persists its tempo. Ordinary dashboard use of BPM Tap has no Apply action.

The dashboard groups stable tool definitions into Practice, Theory and Reference, and Training. Metronome and BPM Tap remain the only production-available tools and receive stronger surface treatment. Guitar Tuner stays explicitly labeled Coming Soon despite its evaluable technical prototype. Navigation uses pushes for drill-in screens so Android back naturally returns to the previous context. Unknown routes continue to use the localized not-found screen.

## Application information and licenses

`ApplicationInfoLoader` isolates `package_info_plus` from widgets. Bootstrap reads the installed package version once and overrides `initialApplicationInfoProvider`; Settings, About, and the license page consume the application-owned immutable value. Tests inject arbitrary versions without a platform channel. The product version is `0.2.0+1`, representing a pre-1.0 application with Foundation plus two working tools.

Open-source notices use Flutter’s standard `showLicensePage`, which reads Flutter’s license registry and presents package licenses with the app name, actual version, and legalese. No custom license database or duplicate route is maintained.

## Metronome timing and beat model

`BeatSequence` is pure Dart. It advances and wraps a one-based beat number for 2/4, 3/4, 4/4, and 6/8, marking only beat one as accented when the preference is enabled. Displayed BPM uses a quarter-note reference, and click duration is `quarter-note duration × 4 ÷ denominator`. In 6/8 this produces six eighth-note clicks per measure: at 120 BPM each click is 250 milliseconds apart. Dotted-quarter interpretation is out of scope.

`AnchoredMetronomeScheduler` uses a monotonic clock and one-shot timers. Its clock and timer factory are replaceable in deterministic tests. Each deadline is calculated from the original anchor instead of chaining the previous timer completion, limiting cumulative drift. The next timer is armed before controller state or audio work begins. A callback delayed by less than one interval retains the original next deadline; deadlines already reached during a longer stall are skipped rather than played in a catch-up burst. BPM or denominator changes cancel the previous timer and re-anchor the single scheduler.

The scheduler callback carries its intended deadline, actual callback time, lateness, and skipped count to `MetronomeController`. In debug builds, the controller records those values with beat number, BPM, and audio-request pending/completed/failed state through `AppLogger`. Per-beat logging is compiled out of release builds. Audio playback futures are deliberately not awaited by the scheduler, so platform-channel completion cannot postpone arming the next deadline. Visual state and the audio request use the same beat number, although visual rendering may follow the request by a few milliseconds.

This foreground design is maintainable and testable but not sample-accurate: Dart scheduling, platform-channel transit, Android audio buffering, and device hardware all contribute latency. A native scheduled-audio engine would be required for stronger real-time guarantees.

## Tuner audio capture prototype

`TunerAudioInput` is the application-owned platform boundary. It covers nonprompting permission inspection, explicit permission request, continuous capture start, stop, and disposal. `RecordTunerAudioInput` is the only production implementation. It uses [`record` 7.1.1](https://pub.dev/packages/record) because its official [`AudioRecorder`](https://pub.dev/documentation/record/latest/record/AudioRecorder-class.html) and [`RecordConfig`](https://pub.dev/documentation/record/latest/record/RecordConfig-class.html) APIs support PCM16 byte streams, Android's native `AudioRecord` implementation, encoder capability checks, and backend configuration-change callbacks without adding a general recording or DSP layer. `record` supports Android API 23 and newer; Tunathic's current Flutter 3.44 debug manifest resolves to API 24, so the package does not raise the app's current minimum. The evaluated native alternative was a custom Android platform-channel wrapper around [`AudioRecord`](https://developer.android.com/reference/android/media/AudioRecord); it would add lifecycle, threading, byte transport, and error-mapping code that the current prototype does not yet need.

The requested stream is 48,000 Hz, one channel, signed 16-bit PCM in little-endian byte order, matching Android's documented [`AudioFormat`](https://developer.android.com/reference/android/media/AudioFormat.html) representation. Automatic gain control, echo cancellation, and noise suppression are disabled because they can alter an instrument signal. Bluetooth management is disabled and the default Android audio source is retained, so the prototype does not request route-control permissions or force an input. Only `android.permission.RECORD_AUDIO` is declared. Following Android's [runtime-permission guidance](https://developer.android.com/training/permissions/requesting), the request occurs after Start; the package currently exposes granted/denied as a boolean and cannot reliably distinguish a permanent denial, which is why the UI does not claim that state.

The adapter converts every even-length byte frame immediately with little-endian signed 16-bit reads and divides by 32768. Each `AudioFrame` owns its `Float32List`, reported/client format, monotonic Dart arrival time, and sequence number. Odd-length frames become typed malformed-frame errors; the controller counts them and continues. No raw byte buffer or sample array is placed in state, history, storage, or logs.

`SignalStatisticsAccumulator` processes every frame but retains only scalar aggregates. It computes peak, RMS, dBFS, frame/sample counts, stream duration, minimum/maximum/average frame size, average arrival interval, and derived arrival rate. The controller publishes at most once per 100 milliseconds so widget rebuild frequency is bounded at 10 Hz. Arrival timing begins when Dart receives data and therefore includes native buffering, platform transport, and scheduler delay; it is diagnostic rather than a native capture timestamp.

PCM conversion and scalar accumulation currently run synchronously on Flutter's main Dart isolate when each package stream event is delivered. Phase 2A adds no isolate because this linear pass has not shown a measured need for one. The app does not enqueue frames: after conversion and accumulation, a frame becomes collectible, and UI throttling only skips state publication—not audio processing. Backpressure below the Dart stream remains controlled by the package and Android buffer; if profiling shows event-loop backlog or dropped native input, isolate/native processing becomes a measured follow-up.

The `record` Android backend selects its stream buffer because Phase 2A has no measured evidence for a fixed override. Frame size is observed at runtime. The client requests 48 kHz, and an adjustment callback is shown as the reported format if available; absent that callback the screen explicitly says the reported sample rate is unavailable. Neither value is presented as a measured hardware endpoint rate.

Capture cleanup is idempotent across explicit stop, application backgrounding, stream failure, navigation, provider disposal, and partial start failure. Starting capture first releases Metronome playback to avoid simultaneous Tunathic playback/input activity. Android may still arbitrate other apps, calls, audio focus, input routing, and Bluetooth behavior. A native `AudioRecord` implementation becomes justified if physical testing demonstrates a need for native timestamps, explicit buffer sizing, preferred-device routing, audio-session callbacks, lower-copy transport, or controls the package cannot expose.

## Offline pitch detection

Phase 2B introduces `lib/features/tuner_pitch/` without importing it from Tuner Audio, controllers, routes, or widgets. `PitchDetector` is the small future-facing API: provide one normalized mono `Float32List` plus sample rate and receive one immutable `PitchEstimate`. `YinPitchDetector` owns no history, timers, smoothing, state, or platform resources, so identical input and configuration produce identical output.

### Algorithm decision

The selected method is YIN, following de Cheveigné and Kawahara's primary paper, [“YIN, a fundamental frequency estimator for speech and music”](https://pubmed.ncbi.nlm.nih.gov/12002874/). YIN modifies autocorrelation-style period estimation with a squared difference function, cumulative mean normalization, an absolute threshold, and interpolation. Its periodicity score maps cleanly to Tunathic's required confidence/no-pitch contract, it is intended for musical as well as speech signals, and it avoids FFT-bin resolution and spectral-peak assumptions.

Alternatives were evaluated as follows:

- Plain autocorrelation is established but its peaks remain sensitive to amplitude, finite-window effects, and harmonic multiples without additional normalization and selection rules; Rabiner's primary [autocorrelation analysis](https://doi.org/10.1109/TASSP.1977.1162905) describes the importance of preprocessing and peak behavior.
- Normalized autocorrelation and the McLeod Pitch Method are strong musical alternatives. McLeod and Wyvill's [MPM paper](https://quod.lib.umich.edu/i/icmc/bbp2372.2005.107/1/--smarter-way-to-find-pitch?page=root;size=75;view=text) reports real-time monophonic musical use, normalized square difference, and a clarity measure. YIN was retained because its first-threshold-minimum rule and cumulative normalization provide the more direct conservative no-pitch behavior needed for this milestone; MPM remains a valid comparison candidate if recorded-instrument tests expose YIN-specific octave errors.
- A raw FFT peak is not a reliable fundamental when a guitar harmonic is stronger than its fundamental. It also requires windowing, bin interpolation, and harmonic candidate scoring to address spectral leakage and low-frequency resolution. An FFT implementation or dependency would broaden Phase 2B without evidence that time-domain analysis is insufficient.

The direct implementation has `O(N × L)` execution and `O(L)` temporary memory, where `N` is the comparison span and `L` is the maximum searched lag. At 48 kHz, the configured 40 Hz boundary has a 1,200-sample lag. A 10% lower-range guard extends only the search to 1,320 samples so a just-below-range periodic minimum is rejected instead of rounded onto 40 Hz. In-range lags retain a fixed comparison span; guard-only lags use their available overlap scaled to the same span. The detector allocates two `Float64List` lag arrays per call but does not copy or normalize the input samples. An FFT-accelerated difference calculation could reduce asymptotic cost later, but it is not justified by the current measurements.

### Difference, selection, and interpolation

For each lag `τ`, the detector calculates the fixed-span squared difference:

`d(τ) = Σ (x[j] - x[j + τ])²`

It then calculates the cumulative mean normalized difference:

`d′(τ) = d(τ) × τ / Σ d(k), k = 1…τ`

The first local minimum below 0.18 is searched only from `ceil(sampleRate / maximumFrequency)` through `ceil(sampleRate / minimumFrequency)`. Guard-only lags cannot become the initial supported candidate. A separate check may compare a sub-minimum-lag periodicity with the supported result: an unsupported high tone is rejected when the supported multiple does not improve clarity by the configured 0.01 harmonic threshold, while a real lower fundamental remains eligible. Confidence is `clamp(1 - d′(τ), 0, 1)` and must be at least 0.82.

Parabolic interpolation of the raw difference around the selected integer lag produces a fractional period; frequency is `sampleRate / period`. The lower guard supplies the right-hand interpolation sample at the maximum supported lag and may be inspected by harmonic correction only to reject a clearer below-range period. There is no broad frequency clamp: a lower-bound candidate is corrected to exactly 40 Hz only when interpolation drift is within a relative `1e-6` (one-part-per-million) tolerance. Larger lower-bound deviations and every result above 1,200 Hz remain unsupported.

Guitar spectra may make a shorter harmonic period cross the threshold first. Without hardcoding notes, the detector checks neighborhoods around two, three, and four times the initial period and prefers a longer candidate only when its normalized difference improves by at least 0.01. Tests cover dominant second and third harmonics, a weak fundamental, a synthetic missing fundamental supported by second and third harmonics, and a noisy bass-like spectrum. A waveform containing only one isolated harmonic cannot reveal an absent lower fundamental, so octave ambiguity remains possible.

### Frame sizing, preprocessing, and latency

The configured minimum frame contains three periods at the 40 Hz lower bound: 3,600 samples at 48 kHz or 3,308 at 44.1 kHz. The recommended 4,096-sample frame spans 85.3 ms at 48 kHz and 92.9 ms at 44.1 kHz. That acquisition span is the minimum practical low-note latency before future overlap, scheduling, and display smoothing. The detector also accepts larger or non-power-of-two frames.

All samples must be finite and within `[-1, 1]`. The detector calculates mean-centered RMS and rejects values below 0.002. DC offset needs no filtered copy because subtraction in `d(τ)` cancels any constant component. YIN does not require a Hann window for this time-domain comparison, and Phase 2B adds no gain normalization, automatic gain control, high-pass filter, or complex noise gate.

### Musical-note conversion

`MusicalNoteConverter` is independent of YIN. For reference frequency `A4`, defaulting to 440 Hz:

`continuousMidi = 69 + 12 × log₂(frequency / A4)`

The nearest integer gives MIDI note; note class uses the sharp-name sequence C through B; octave is `midi ~/ 12 - 1`; cents are `100 × (continuousMidi - nearestMidi)`. The reference is a function argument so a later milestone can introduce calibration without changing detector math or adding a setting now.

### Accuracy and performance observations

The checked-in diagnostic command, `dart run tool/pitch_detector_diagnostic.dart`, prints synthetic expected/estimated frequency, percent error, detector error in cents, note-relative cents, confidence, and non-asserted timings. The complete matrix is recorded in `docs/CURRENT_MILESTONE.md`. Across clean 4,096-sample 48 kHz sines from 40 through 1,200 Hz, the largest observed error was 0.000347%, approximately 0.006 cents. These are deterministic synthetic results, not recorded-guitar claims.

One warmed 30-run Windows JIT observation measured 4,096 samples at 11.35 ms median/12.00 ms average and 8,192 samples at 26.23 ms median/25.84 ms average. Timings vary with JIT state and machine load and are never test assertions. Phase 2C must profile representative Android hardware before choosing main-isolate, reusable-buffer, or isolate execution.

### No-pitch and real-time boundary

Typed no-pitch reasons cover empty frames, invalid sample rate, non-finite or non-normalized samples, insufficient length, centered near-silence, incompatible range, and low confidence. Deterministic white noise and an approximately -19 dB synthetic signal-to-noise case were rejected; an approximately +15 dB case was detected. No probability calibration is claimed: confidence is a bounded periodicity clarity measure.

## Real-time pitch pipeline

`RealtimePitchConfiguration` centralizes the 4,096-sample frame, 1,024-sample hop, 75% overlap, stabilizer thresholds, 350 ms stale timeout, and 75 ms maximum UI publication cadence. At 48 kHz the frame/hop durations are approximately 85.3/21.3 ms. Configuration validation prevents a nonpositive hop, a hop larger than the frame, or a frame shorter than the detector's sample-rate-dependent low-frequency requirement.

`SampleWindowAssembler` is a pure Dart fixed-capacity circular `Float32List`. It accepts arbitrary chunks and emits chronological frame-owned snapshots without growing concatenations. After the initial frame it overwrites only samples that have left the current window and emits after each hop. Sample-rate changes count and discard the partial old-rate window before reset, so samples from different rates never mix. Occupancy cannot exceed one analysis frame.

`RealtimePitchPipeline` starts at most one `PitchDetectionExecutor` future. While it is active, one pending slot retains the newest ready frame; later frames replace that slot and increment replacement/drop counters. A generation changes on session start, stop, restart, and sample-rate change. Late futures from older generations are ignored. Stopping clears the ring, pending slot, stabilizer, hysteresis, and stale deadline even though an already-executing main-isolate calculation cannot be cancelled.

The production executor schedules the existing synchronous YIN detector on the main isolate. It does not use per-frame `compute()` or an isolate. The Phase 2B Windows JIT observation of about 11.35 ms median for 4,096 samples is below the 48 kHz hop, but no Android device was connected for Phase 2C. Main-isolate placement is therefore provisional. Profile-mode Android duration, responsiveness, allocation/GC, and replacement counts must justify any later single long-lived worker isolate and its typed-data transfer cost.

`PitchStabilizer` operates in continuous MIDI/log-frequency space and never changes the raw detector result. It applies a five-estimate median-centered 45-cent outlier filter followed by 0.35 exponential smoothing. Confidence below 0.82 follows no-pitch behavior. A different note or octave requires two consecutive confirmations; the current note is retained near semitone boundaries until evidence persists at least 8 cents beyond the midpoint. Confirmed note changes reset history instead of averaging unrelated notes. Four consecutive no-pitch results or 350 ms without a reliable estimate clear the old pitch.

The diagnostic exposes requested/reported format, chunk statistics, ring occupancy, assembled/analyzed/replaced/dropped frames, detector average/maximum duration, raw and stabilized pitch, stale/no-signal state, execution mode, and friendly errors. UI publication is capped near 13.3 updates/s and is not driven by widget rebuilds or every PCM chunk. No raw bytes or samples are logged, persisted, or sent off-device.

## Audio playback and assets

`audioplayers` 6.8.1 is used because its maintained, multiplatform API includes `AudioPool` preloading and Android low-latency playback for short, repetitive effects. The discontinued `soundpool` package was rejected. Separate regular and accented pools are created once before the first beat, reused throughout the screen session, and released when the screen is disposed or audio fails. Each pool prewarms three players and can grow to four. This small amount of extra capacity provides headroom when 6/8 at 300 BPM requests a click every 100 milliseconds and a previous platform request is still being reclaimed. Android audio context is configured for sonification.

The click WAV files are original project assets generated deterministically by `tool/generate_metronome_clicks.dart`; they are short decaying synthesized tones and contain no third-party recording. The script records the exact generation parameters and can reproduce the checked-in assets.

## BPM estimation

`BpmTapEngine` is pure Dart and receives monotonic elapsed durations rather than reading wall-clock time. It derives intervals only from accepted taps and rejects intervals outside 200–2,000 milliseconds, corresponding to 300–30 BPM. A three-second gap starts a new session automatically.

An estimate requires at least two valid intervals (three accepted taps). The engine retains the latest eight valid intervals. For three or more intervals, it computes their median, discards samples more than 20 percent from that median, and averages the retained samples before converting the result to a whole-number BPM. With only two intervals it averages both; if aggressive filtering would retain fewer than two samples, it falls back to the median. This provides resistance to isolated accidental spikes while remaining responsive to a deliberate tempo change as new samples replace the rolling window.

Known algorithm limitations are intentional: the tool estimates only whole-number BPM, abrupt half-time or double-time changes need several taps to replace the previous window, and it cannot infer musical meter or distinguish equivalent tempo interpretations.

## Localization

Flutter's generated localization infrastructure uses English `app_en.arb` as the source and Turkish `app_tr.arb` as the second supported language. The selected language can follow the device or be fixed to English or Turkish. Unsupported device languages fall back to English.

## Preferences abstraction

`PreferencesStore` is the small asynchronous key-value boundary used by application settings. Its production implementation uses `SharedPreferencesAsync`, while tests use an in-memory implementation. Shared Preferences is sufficient for this small set of non-sensitive scalar settings and is smaller and easier to maintain than introducing a database. The asynchronous API avoids stale cache behavior across isolates and engine instances.

The stored values are theme mode, optional locale code, default-on haptic feedback, metronome BPM, time signature, accent enabled state, and volume. Unknown, missing, or out-of-range values safely fall back to supported defaults or clamp where appropriate. Preferences are not suitable for secrets or future structured practice data.

## Theme system

The application uses Material 3 with light, dark, and system modes. Centralized theme files define the deep-charcoal, electric-blue, soft-cyan, and off-white palette plus spacing, typography, restrained radii, two elevation levels, and limited motion durations. Feature widgets consume the active `ThemeData`, `ColorScheme`, and shared tokens instead of duplicating design constants. Only available dashboard tools use subtle raised elevation; Phase 1C adds no decorative animation, gradients, or glass effects.

Shared maximum widths produce readable phone, large-phone, and tablet columns. Core screens remain vertically scrollable, Wrap replaces rigid rows where selections can expand, and tests exercise narrow 360-pixel layouts with large text. Availability, selection, running state, and accented beats retain text or semantic meaning rather than relying on color alone.

## Error handling and logging

`AppLogger` isolates diagnostic output from features. Bootstrap records uncaught Flutter framework and platform errors without adding analytics or an external reporting service. A localized, user-friendly error widget replaces raw framework error presentation in release-facing UI.

## Dependency rationale

- `flutter_riverpod` supplies scoped state management and dependency injection without global mutable state.
- `go_router` supplies centralized declarative navigation, path parsing, and route-level error handling.
- `flutter_localizations` and the SDK-compatible `intl` version generate and support English and Turkish localization.
- `shared_preferences` persists scalar application and metronome settings behind an application-owned abstraction.
- `audioplayers` preloads and plays the two bundled metronome clicks through low-latency Android audio pools.
- `record` 7.1.1 supplies continuous PCM16 microphone streaming and the Android `AudioRecord` bridge behind `TunerAudioInput`; it is used for transient capture, never file recording.
- `package_info_plus` supplies the installed version and build number behind `ApplicationInfoLoader`; platform metadata cannot be read reliably from `pubspec.yaml` at runtime.

No pitch-analysis, FFT, DSP, scientific-computing, database, analytics, advertising, account, backend, or purchase package is included. Pitch detection and the real-time buffer/stabilizer use only Dart SDK math, async, and typed-data libraries.

## Testing approach

Unit tests cover preference parsing and persistence, BPM estimation, metronome beat progression, wrapping, accents, time signatures, tempo interval calculation, lifecycle stopping, failure recovery, reset, and duplicate-start prevention. Controller tests replace clocks, audio, and scheduling with deterministic fakes. Widget tests verify both functional dashboard tools, English and Turkish content, scaled compact layouts, metronome controls, and BPM Tap result transfer. Fakes implement the same application-owned boundaries used by production code.

Scheduler tests use fake monotonic time and fake one-shot timers; they do not wait on wall-clock time. They cover exact callbacks, mild and multi-interval lateness, original-deadline retention, skipped deadlines, no catch-up bursts, re-anchoring, and rapid stop/start. Controller tests additionally cover 4/4-to-6/8 reconfiguration, debug timing records, duplicate-start prevention, audio failure, and pending audio futures that do not block later beat callbacks.

Application-shell tests cover haptic persistence and enabled/disabled behavior, dashboard grouping and availability, injected package versions, About and Privacy navigation, standard license entry, theme and language regression, large text, narrow layout, BPM Tap and Metronome regressions, corrected 6/8 timing, and Metronome cleanup on back navigation. GitHub Actions repeats dependency resolution, formatting verification, analysis, and tests for pushes and pull requests to `main` without secrets or deployment steps.

Tuner Audio pure-Dart tests cover PCM16 little-endian normalization, signed boundaries, malformed input, peak, RMS, dBFS, silence, and aggregate frame timing. Controller tests inject a fake audio input and cover grant/denial, unsupported configuration, retry, duplicate and rapid operations, foreground lifecycle, stream and stop failures, malformed-frame recovery, 10 Hz publication throttling, backend format adjustment, route cleanup, and disposal failure. Widget tests cover the non-tuner warning, privacy language, denied permission, start/statistics/stop interaction, Turkish localization, and narrow large-text scrolling. They intentionally use deterministic synthetic frames and make no claim about Android hardware.

Tuner Pitch tests are pure and require no microphone, Flutter widget, real timer, audio file, Android target, or network. They cover configuration validation, empty/short/non-finite/out-of-contract input, silence thresholds, all required clean frequencies, exact 40/1,200 Hz limits, near-boundary rejection through 39.9999 Hz and from 1,201 Hz, supported fundamentals beneath stronger out-of-range harmonics and a high transient, unsupported high-only tones, 44.1/48 kHz, multiple frame lengths and phases, 12-TET semitone boundaries, reference-frequency injection, dominant harmonics, missing/weak fundamental, deterministic white noise, low/moderate SNR, DC offset, clipping-like amplitude, envelopes, bass spectra, and repeatability. Wall-clock performance is observed only by the optional tool and is never asserted in tests.

Tuner Realtime pure tests verify exact 4,096/1,024 overlap, arbitrary chunks, multiple frames from one chunk, partial reset, ordering without gaps/duplicates, and fixed memory. Controlled asynchronous detector fakes verify one active analysis, newest pending replacement, counters, stop/restart generation invalidation, sample-rate reset, stale clearing, and detector errors. Stabilizer tests cover steady variation, transient/octave rejection, repeated octave and deliberate note changes, short/sustained no-pitch, confidence, semitone flicker, bass, and high guitar notes. Controller and widget tests retain fake capture/time/detector dependencies and cover permission, Metronome release, lifecycle, route cleanup, raw/stable display, counters, errors, localization, narrow layout, and the absence of final tuner UI.

## Known limitations

- BPM Tap and the foreground Metronome are functional. Guitar Tuner remains Coming Soon and opens a Phase 2C development diagnostic, not a production tuner interface.
- Metronome playback is not sample-accurate, does not run in the background, and supports no subdivisions, swing, custom rhythms, or custom accent patterns.
- Rare audible stuttering was observed on a physical Android device in the original Phase 1B build. Debug instrumentation can now distinguish Dart scheduler lateness, skipped deadlines, and overlapping platform audio requests, but repeat physical-device validation is required before declaring the symptom resolved. No physical Android target was connected during automated validation of this hotfix.
- Haptic response varies with Android hardware and system settings.
- The privacy policy is a product draft and the application is not Play Store ready.
- Microphone capture is foreground-only, transient, local, and was physically validated separately in Phase 2A. There is no file recording or content database.
- The capture prototype does not force an input route or manage Bluetooth SCO; its physical validation does not turn Android-controlled routing into a guaranteed route policy.
- Pitch detection is monophonic. Buffering, backpressure, smoothing, hysteresis, and stale behavior have deterministic coverage, but plucked-string inharmonicity, real microphone processing, Android execution cost, UI responsiveness, octave/flicker behavior, and thermal stability still require physical profile-mode validation.
- Preferences store only scalar application and metronome settings; future structured data needs a separate decision when its requirements exist.
- Logging is local developer output only. No remote reporting or analytics exists.
- Foundation targets Android; other generated platform projects are intentionally absent.
