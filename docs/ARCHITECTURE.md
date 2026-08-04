# Architecture

Tunathic uses a pragmatic feature-first Flutter structure. Phase 3E completes
the existing Chord Library's practical guitar-voicing coverage through
project-owned generated and curated data, deterministic auditing, and stronger
validation while preserving the physically validated Guitar Tuner, BPM Tap,
native Oboe Metronome, Scale Library, Interactive Fretboard, and Circle of
Fifths behavior.

## Folder responsibilities

- `lib/app/` owns application composition: bootstrap, router, persisted application settings, and Material themes.
- `lib/core/` owns app-wide technical boundaries for logging, preferences,
  package information, haptic output, and pure reusable music-theory identity
  and construction.
- `lib/features/` groups user-facing areas. Dashboard, Settings, About, and
  Privacy compose the application shell. Chord Library owns guitar-specific
  shapes, validation, offline data, diagram rendering, and browsing
  presentation while importing the theory core. Scale Library owns exact
  localized search vocabulary and scale-reference presentation while formulas,
  construction, and relationships remain in the theory core. Interactive
  Fretboard owns route state, controls, selection details, responsive scrolling,
  and project-owned neck painting while all pitch derivation remains in the
  theory core. Circle of Fifths owns responsive interaction, detail
  presentation, accessibility, and project-owned circular painting while key
  and harmony relationships remain in the theory core. BPM Tap separates pure
  estimation logic from presentation state. Metronome separates configuration
  and beat sequencing, scheduling and orchestration, audio output, persistence,
  and presentation. Tuner Audio separates its input boundary and package
  adapter, immutable PCM/frame domain types, pure statistics, capture
  orchestration, and diagnostic UI. Tuner Pitch contains only
  Flutter-independent configuration, results, musical-note conversion, the
  detector boundary, and DSP. Tuner Realtime owns bounded window assembly,
  backpressure, stabilization, hysteresis, stale timing, and transient
  diagnostics. Tuner owns immutable tuning definitions, target selection,
  tuner preferences, product orchestration, and production presentation. Other
  unfinished tools share one placeholder presentation.
- `lib/shared/` contains reusable interface elements that are not specific to one feature. Foundation contains the friendly error view.
- `lib/l10n/` contains source ARB files and generated Flutter localization classes.

No UI component imports `shared_preferences`, calls the microphone package, calls the wakelock package, invokes native audio channels, or contains audio conversion or DSP. Platform-facing playback is isolated behind `MetronomeEngine`; microphone input is isolated behind `TunerAudioInput`; offline pitch analysis is isolated behind `PitchDetector`. Current tools operate offline, and neither BPM Tap sessions nor microphone samples are persisted.

## Music-theory domain

`lib/core/music_theory/` has no Flutter, Riverpod, localization, storage, audio,
or platform import. `PitchClass` is the modulo-12 identity; `SpelledPitchClass`
is a diatonic letter plus natural, sharp, or flat accidental. C# and Db
therefore share pitch identity without losing their different display
spellings.

`NoteSpelling` advances the expected diatonic letter for an interval and selects
a single accidental that reaches the target pitch class. This separates pitch
arithmetic from naming and produces spellings such as F-A-C, Bb-D-F, and
F#-A-C#-E. Phase 3A falls back to a readable enharmonic spelling when double
accidentals would otherwise be required.

`TheoryInterval` stores stable identity, semitones, diatonic steps, and a short
label. Separate augmented-fourth and diminished-fifth values share six
semitones but retain structural meaning. Compound ninth, eleventh, and
thirteenth values support the current chord vocabulary.

`ChordQuality` stores a stable nonlocalized ID, notation symbol, category, and
ordered interval formula. `ChordConstructor` derives all tones from that
formula. `ChordSymbolParser` is an exact local parser for supported roots and
suffixes; it does not introduce a second chord representation.

`ScaleDegree` stores structural identity, notation symbol, semitone distance,
and diatonic steps. This keeps `#4` distinct from `b5` even though both reduce
to pitch class six. `ScaleDefinition` stores stable nonlocalized IDs, categories,
ordered degree formulas, aliases, and optional major-mode degree metadata.
Major/Ionian and Natural Minor/Aeolian share one formula each through aliases
rather than duplicated scale data.

`ScaleConstructor` delegates each structural degree to `NoteSpelling`, so
scale construction reuses the same pitch arithmetic and diatonic spelling as
chords. `ScaleRelationships` derives relative major/minor roots and modal parent
major roots without root-specific tables. Current coverage is Major, Natural
Minor, Harmonic Minor, ascending Melodic Minor, all seven major modes, Major
and Minor Pentatonic, and Blues.

`MusicalKey` combines a spelled tonic with major or natural-minor tonality and
a spelling preference. `KeySignature` stores a signed fifths count from -7
through +7 and derives accidental type, count, stable identity, and ordered
altered notes. A compact canonical major-key lookup owns the standard
signature boundary; natural-minor signatures resolve through the existing
relative-major helper. F# and Gb therefore retain distinct signatures without
creating distinct modulo-12 pitch identities.

`CircleOfFifths` owns twelve structural positions in clockwise-fifth order,
including practical alternate spellings at F#/Gb and Db/C#. Each position
aligns one major key with its relative natural minor. Circle and key helpers
derive fifth, fourth, relative, parallel, clockwise-neighbor, and
counter-clockwise-neighbor relationships deterministically.

`DiatonicHarmonyConstructor` constructs the selected key's scale, stacks thirds
from each degree, classifies the resulting triad or seventh pattern, and
delegates chord spelling to `ChordConstructor`. `RomanNumeral` retains scale
degree, quality, and seventh state while deriving case, diminished or
half-diminished marker, and suffix. These types contain no localized display
strings or progression recommendations.

`GuitarTuning` represents strings structurally, ordered low to high. The current
`standard` value stores E2/A2/D3/G3/B3/E4 and open MIDI values. A
`GuitarStringTuning` derives every fret by adding its offset to the open MIDI
note, then derives octave and pitch class; custom tunings can later supply
different structural data without changing that algorithm.

`FretboardProjection` delegates chord tones to `ChordConstructor` and scale
tones to `ScaleConstructor`. Its relation map keeps the constructed spelling,
root state, and structural interval or scale-degree symbol for each member
pitch class. `GuitarFretboard.project` combines that map with a tuning and
validated fret range to produce immutable `FretPosition` values. It is
synchronous, deterministic, and Flutter-independent.

The tuner retains its MIDI/octave/frequency/cents live-pitch types because those
models solve a different, physically validated capture problem. Future safe
consolidation requires explicit tuner regression evidence rather than moving
transient tuner state into music theory.

## Guitar chord shapes

`GuitarChordShape` stores six low-E-to-high-E string states, optional finger
numbers, diagram start, category, difficulty, rootless status, declared
interval omissions, curated/generated provenance, project source, and barre
ranges. Muted, open, and fretted strings are structural states, not magic
display text or images.

The 402-shape project-owned dataset combines 36 curated open shapes, six curated
compact shapes, 228 movable E-family shapes, and 132 movable A-family shapes.
Common E/A barres and extension voicings are generated from reviewed structured
templates; curated open strings are never blindly transposed. Generated and
curated shapes pass identical validation. Provenance is explicit: 42 shapes are
curated and 360 are generated.

`GuitarShapeCoverageAudit` deterministically evaluates all 12 pitch classes
against all 22 `ChordQuality` values. It reports shape count, families, lowest
position, and alternative availability for each of the 264 combinations plus
aggregate percentage and quality/family totals. The development tool at
`tool/chord_shape_coverage.dart` prints the same report. Final validated
coverage is 264/264 (100.00%); the previous 162-shape dataset covered 80/264
(30.30%).

`GuitarShapeValidator` derives every sounding pitch from standard tuning,
rejects formula-foreign tones, and requires all non-omitted formula tones.
Four-or-more-note formulas may explicitly omit a perfect fifth; eleventh and
thirteenth formulas may also declare the ninth omitted. The root may be omitted
only on an explicitly rootless shape. Thirds, sevenths, altered fifths, and
highest extensions remain defining tones. Declared omissions must belong to
the formula, be policy-allowed, be unique, and actually be absent.

Structural validation also covers string count, fret/state consistency, fret
bounds, finger range and same-fret reuse, a four-fret maximum span, diagram
window, barre fret/range/finger/coverage, duplicate IDs, and effectively
duplicate root/quality fingerings. The first public dataset remains entirely
rooted, although a deterministic test retains explicit rootless support.

The diagram is a project-owned `CustomPainter`. Theme colors support contrast,
while muted/open glyphs, geometry, finger numbers, starting-fret text, visible
fingering instructions, and one combined semantic image keep meaning
independent of color.

## State management

Riverpod provides scoped dependency injection and reactive application settings. `ProviderScope` is the application root. `AppSettingsController` owns theme, locale, and haptic-preference changes; widgets observe its immutable state and never read or write storage directly. The initially persisted settings are loaded before `runApp`, preventing a visible theme, language, or interaction-preference change after the first frame.

`AppHaptics` gates meaningful direct feedback against the current setting and delegates to an injectable `HapticFeedbackOutput`. Production uses Flutter’s built-in system haptic API; tests use a recording fake. BPM taps, Metronome start/stop, result application, resets, navigation, and important selections may request subtle feedback. Timers, passive state, sliders, and Metronome beats do not.

`BpmTapController` owns the in-memory tap session, monotonic elapsed-time reads, manual reset, and inactivity timer. The BPM Tap widget only observes immutable state and forwards tap or reset actions. Its elapsed-time provider can be replaced in tests, keeping controller behavior deterministic without a platform clock dependency.

`MetronomeController` owns immutable runtime state and coordinates `MetronomeEngine`, diagnostics, Tuner exclusion, and preferences. Widgets forward user actions and render state. Native run IDs reject callbacks after Stop or restart. Playback stops when the app loses foreground focus and does not resume automatically. Leaving the screen invalidates pending start work and releases the native stream; a later screen entry normalizes retained presentation state before rendering.

`TunerAudioController` owns the capture state machine and creates its audio input through an injectable factory. It requests permission only in response to Start, releases Metronome audio before capture, rejects duplicate operations, subscribes to frames and configuration changes, and owns all cleanup. It feeds normalized frame-owned samples into `RealtimePitchPipeline`; the UI observes only immutable scalar snapshots and never receives PCM bytes. Controller operation versions and pipeline generations invalidate delayed permission, detector, stop, and restart work. Backgrounding stops capture and analysis, and foregrounding never restarts them automatically.

`GuitarTunerController` listens to immutable `TunerAudioState` and owns only product behavior: persisted preset/mode/manual-string settings, automatic target selection, target-relative cents, accuracy bands, signal messaging, and stable in-tune haptics. It delegates Start, Stop, lifecycle, and route release to `TunerAudioController`. Widgets never read preferences, select targets, calculate cents, or trigger haptics from animation frames.

The production controller keeps an existing stabilized pitch visible while the realtime pipeline reports a short `unstableSignal` gap with retained stabilizer history. In Automatic mode it also refuses to present a candidate more than 200 cents from the active tuning's selected string; this product-level guard prevents a release-tail A1/55 Hz estimate from being shown while A2 is the valid target. The last accepted display pitch may bridge up to eight new detector results, but retained or rejected data is not counted as fresh evidence for haptic feedback. Sustained invalid input or the realtime 350 ms stale deadline still clears the visible pitch. Manual mode remains deliberately ungated so a selected string can show a large tuning error.

## Navigation

GoRouter provides one central route table:

- `/` displays the responsive dashboard.
- `/settings` displays appearance, interaction, and application preferences and links.
- `/about` displays localized product, publisher, tool, version, privacy, and license information.
- `/privacy` displays the current local/offline privacy summary.
- `/tools/bpm-tap` displays the functional BPM Tap screen.
- `/tools/metronome` displays the functional Metronome screen.
- `/tools/guitar-tuner` displays the production Guitar Tuner.
- `/tools/chord-library` displays the offline Chord Library.
- `/tools/scale-library` displays the offline Scale Library.
- `/tools/interactive-fretboard` displays the offline Interactive Fretboard;
  project-owned query state safely preconfigures chord or scale mode, root, and
  definition while malformed or absent parameters use sensible defaults.
- `/tools/circle-of-fifths` displays the offline interactive major/minor
  circle, key signatures, relationships, scale notes, and diatonic harmony.
  Its actions use project-owned query state to preconfigure Scale Library,
  Chord Library, and Scale-mode Interactive Fretboard; direct and malformed
  library routes retain their existing C Major defaults.
- `/tools/interval-trainer` displays offline visual interval identification and
  target-note construction.
- `/tools/repertoire` lists the songs stored on this device,
  `/tools/repertoire/new` and `/tools/repertoire/:songId/edit` open the editor,
  and `/tools/repertoire/:songId` opens the performance view. A song identifier
  that no longer exists resolves to the localized not-found message rather than
  an empty sheet.
- `/debug/tuner-diagnostics` displays Phase 2C engineering diagnostics only in debug builds.
- `/tools/:toolId` resolves every other unfinished known tool to its Coming Soon placeholder.

Unknown paths and tool identifiers display a friendly localized not-found screen. Tool IDs are stable, nonlocalized route segments; tool names are localized at presentation time.

The Metronome opens BPM Tap with an explicit result contract. BPM Tap returns only a valid whole-number estimate when the user chooses Apply; the metronome validates the 20–300 BPM range and then updates and persists its tempo. Ordinary dashboard use of BPM Tap has no Apply action.

The dashboard groups stable tool definitions into Practice, Theory and Reference,
and Training. Metronome, BPM Tap, Guitar Tuner, Repertoire, Chord Library, Scale Library,
Interactive Fretboard, Circle of Fifths, and Interval Trainer are production-facing tools and receive stronger
surface treatment. Navigation uses
pushes for drill-in screens so Android back naturally returns to the previous
context. Unknown routes continue to use the localized not-found screen.

## Repertoire

The Repertoire is the only feature that stores user-authored content. Its
domain layer is pure Dart: `ChordProParser` turns bracket text into a
renderable sheet of lyric fragments with attached chords, `ChordSheetImporter`
converts a pasted chords-above-lyrics chart into that same bracket form once,
at save time, and `SongSheet` transposes a whole chart while keeping one
accidental style. Attaching chords to syllables rather than columns is what
makes transposition safe: a chord printed as `Bb` and transposed to `B` can no
longer drag the alignment of the line with it.

Chord symbols in charts are far more varied than the modeled chord qualities,
so `ChordSymbolParser.tryParseWritten` keeps the suffix verbatim and interprets
only the root and optional slash bass. Its suffix alphabet is deliberately
narrow so ordinary words that begin with a note letter are not mistaken for
chords when a pasted chart is scanned for chord lines.

Chords can also be placed without typing brackets. The parser records where
every chord, lyric fragment, and line sits in the stored text, so the
performance view can turn each word, the end of each line, and each empty line
into a target, and `SongChordEditor` can insert, append, replace, or remove a
bracket as a plain string edit at that position. Line ends and empty lines are
what make intros and instrumental breaks expressible; appending separates
adjacent chords so a chord-only line stays readable as text. Tapping a word and
typing a bracket by hand therefore produce identical content. Because the view
may be transposed while editing, a chord chosen from the picker is converted
back to the song's written key before it is stored; transposition itself never
rewrites the text, so recorded positions stay valid.

`RepertoireRepository` owns the only storage access, encoding the song list as
JSON through `PreferencesStore`; unreadable storage is logged and reported as an
empty repertoire rather than failing. `RepertoireController` owns the list and
every mutation, including per-song transposition and scroll speed. The
performance view drives auto-scroll from a `Ticker` through the pure
`AutoScrollSpeed` rate model, stops at the end of the sheet, and yields as soon
as the performer drags. The feature adds no audio, microphone, network,
account, analytics, or backend dependency.

## Interval Trainer

The Interval Trainer keeps visual-theory practice self-contained. Its pure
domain layer constructs intervals from diatonic letter movement and semitone
distance, preserves augmented-fourth and diminished-fifth identities, rejects
spellings that need double accidentals, and uses seeded random generation with
a shuffled interval bag for deterministic tests. The presentation controller
owns only a transient session with one-answer protection, accuracy, and streak
state; it has no storage, audio, microphone, network, analytics, or account
dependency.

## Application information and licenses

`ApplicationInfoLoader` isolates `package_info_plus` from widgets. Bootstrap reads the installed package version once and overrides `initialApplicationInfoProvider`; Settings, About, and the license page consume the application-owned immutable value. Tests inject arbitrary versions without a platform channel. The product version is `0.3.0+5`, representing a pre-1.0 application with Foundation plus the shipped tool set.

Open-source notices use Flutter’s standard `showLicensePage`, which reads Flutter’s license registry and presents package licenses with the app name, actual version, and legalese. No custom license database or duplicate route is maintained.

## Metronome timing and beat model

`MetronomeTimeSignature` models 2/4, 3/4, 4/4, and 6/8 with explicit numerator and denominator. Displayed BPM uses a quarter-note reference, and pulse duration is `quarter-note duration × 4 ÷ denominator`. In 6/8 this produces six eighth-note clicks per measure: at 120 BPM each click is 250 milliseconds apart. Dotted-quarter interpretation is out of scope.

`MetronomeEngine` separates initialize/start/stop/dispose, live configuration, running state, beat events, engine information, and native stop diagnostics from the controller. `NativeMetronomeEngine` is the only production implementation. It loads the two bundled WAV assets once and delegates to a Kotlin channel plus C++ Oboe engine.

The Oboe low-latency data callback owns the output sample clock, fractional frames-per-pulse accumulation, beat progression, accent selection, gain, and click rendering. It uses the device's natural output rate, resamples the project assets during initialization, applies a 3 ms terminal fade, and writes no file/network/Flutter work in the callback. Oboe uses AAudio on supported devices and OpenSL ES on older supported Android releases. Shared output with media/sonification attributes preserves normal system mixing; Tunathic does not request global audio focus.

BPM updates preserve the fraction remaining to the next pulse. Signature updates preserve pulse phase and make the next pulse beat 1. Neither update restarts the stream. Configuration revisions discard queued visual callbacks from a previous configuration, and run IDs discard callbacks after Stop or restart.

Native beat events contain rendered output-frame position and a monotonic callback timestamp. They update current beat and animation only; they never trigger sound. Debug builds log engine implementation/API, sample rate and buffer properties, requested changes, first Flutter callback latency, callback interval/deviation, detectable callback gaps, native x-runs, and engine errors. Callback cadence is explicitly not claimed as acoustic timing.

## Tuner audio capture boundary

`TunerAudioInput` is the application-owned platform boundary. It covers nonprompting permission inspection, explicit permission request, continuous capture start, stop, and disposal. `RecordTunerAudioInput` is the only production implementation. It uses [`record` 7.1.1](https://pub.dev/packages/record) because its official [`AudioRecorder`](https://pub.dev/documentation/record/latest/record/AudioRecorder-class.html) and [`RecordConfig`](https://pub.dev/documentation/record/latest/record/RecordConfig-class.html) APIs support PCM16 byte streams, Android's native `AudioRecord` implementation, encoder capability checks, and backend configuration-change callbacks without adding a general recording or DSP layer. `record` supports Android API 23 and newer; Tunathic's current Flutter 3.44 debug manifest resolves to API 24, so the package does not raise the app's current minimum. The evaluated native alternative was a custom Android platform-channel wrapper around [`AudioRecord`](https://developer.android.com/reference/android/media/AudioRecord); it would add lifecycle, threading, byte transport, and error-mapping code without a demonstrated product need.

The requested stream is 48,000 Hz, one channel, signed 16-bit PCM in little-endian byte order, matching Android's documented [`AudioFormat`](https://developer.android.com/reference/android/media/AudioFormat.html) representation. Automatic gain control, echo cancellation, and noise suppression are disabled because they can alter an instrument signal. Bluetooth management is disabled and the default Android audio source is retained, so the capture layer does not request route-control permissions or force an input. Only `android.permission.RECORD_AUDIO` is declared. Following Android's [runtime-permission guidance](https://developer.android.com/training/permissions/requesting), the request occurs after Start; the package currently exposes granted/denied as a boolean and cannot reliably distinguish a permanent denial, which is why the UI does not claim that state.

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

Guitar spectra may make a shorter harmonic period cross the threshold first. Without hardcoding notes, the detector checks neighborhoods around two, three, and four times the initial period. Physical testing showed that the former shared 0.01 margin also promoted a real A2 to 55 Hz/A1 and briefly promoted D3 to approximately 73 Hz and 49 Hz because ordinary longer-period minima were only slightly clearer. Longer subharmonics now require a separate 0.11 normalized-difference improvement, while the unsupported-high-frequency comparison retains its 0.01 boundary-specific margin. A proposed longer period must also have at least 0.12 of the initial candidate's centered spectral magnitude. This evidence check rejects unsupported synthetic longer periods while retaining deterministic dominant-harmonic, missing-fundamental, and stronger unsupported-harmonic cases. Physical retesting showed that a real guitar release can still contain enough lower-frequency energy to pass this DSP check, so the production tuner's tuning-relative guard remains necessary. A waveform containing only one isolated harmonic still cannot reveal an absent lower fundamental, so octave ambiguity remains possible.

### Frame sizing, preprocessing, and latency

The configured minimum frame contains three periods at the 40 Hz lower bound: 3,600 samples at 48 kHz or 3,308 at 44.1 kHz. The recommended 4,096-sample frame spans 85.3 ms at 48 kHz and 92.9 ms at 44.1 kHz. That acquisition span is the minimum practical low-note latency before future overlap, scheduling, and display smoothing. The detector also accepts larger or non-power-of-two frames.

All samples must be finite and within `[-1, 1]`. The detector calculates mean-centered RMS and rejects values below 0.002. DC offset needs no filtered copy because subtraction in `d(τ)` cancels any constant component. YIN does not require a Hann window for this time-domain comparison, and Phase 2B adds no gain normalization, automatic gain control, high-pass filter, or complex noise gate.

### Musical-note conversion

`MusicalNoteConverter` is independent of YIN. For reference frequency `A4`, defaulting to 440 Hz:

`continuousMidi = 69 + 12 × log₂(frequency / A4)`

The nearest integer gives MIDI note; note class uses the sharp-name sequence C through B; octave is `midi ~/ 12 - 1`; cents are `100 × (continuousMidi - nearestMidi)`. The reference is a function argument so a later milestone can introduce calibration without changing detector math or adding a setting now.

### Accuracy and performance observations

The checked-in diagnostic command, `dart run tool/pitch_detector_diagnostic.dart`, prints synthetic expected/estimated frequency, percent error, detector error in cents, note-relative cents, confidence, and non-asserted timings. The complete matrix is recorded in `docs/CURRENT_MILESTONE.md`. Across clean 4,096-sample 48 kHz sines from 40 through 1,200 Hz, the largest observed error was 0.000347%, approximately 0.006 cents. These are deterministic synthetic results, not recorded-guitar claims.

One warmed 30-run Windows JIT observation measured 4,096 samples at 11.35 ms median/12.00 ms average and 8,192 samples at 26.23 ms median/25.84 ms average. Timings vary with JIT state and machine load and are never test assertions. Phase 2C physical validation was reported complete separately, but no measurement artifact is committed; main-isolate duration, responsiveness, allocations, and replacement counts remain monitored before any execution-model change.

### No-pitch and real-time boundary

Typed no-pitch reasons cover empty frames, invalid sample rate, non-finite or non-normalized samples, insufficient length, centered near-silence, incompatible range, and low confidence. Deterministic white noise and an approximately -19 dB synthetic signal-to-noise case were rejected; an approximately +15 dB case was detected. No probability calibration is claimed: confidence is a bounded periodicity clarity measure.

## Real-time pitch pipeline

`RealtimePitchConfiguration` centralizes the 4,096-sample frame, 2,048-sample hop, 50% overlap, stabilizer thresholds, 350 ms stale timeout, and 75 ms maximum UI publication cadence. At 48 kHz the frame/hop durations are approximately 85.3/42.7 ms. Physical Phase 2D testing on a 23021RAAEG measured about 32 ms average detector duration and showed that the former 1,024-sample hop emitted three or four frames per 3,840-sample Android chunk, forcing immediate pending-frame replacement before the main isolate could run. The 2,048-sample hop remains faster than the UI publication cadence while keeping a typical one-or-two-frame chunk within the single-active/single-pending budget. Eight consecutive no-pitch analyses now align short-gap retention with the existing approximately 350 ms stale limit at the intended cadence. Configuration validation prevents a nonpositive hop, a hop larger than the frame, or a frame shorter than the detector's sample-rate-dependent low-frequency requirement.

`SampleWindowAssembler` is a pure Dart fixed-capacity circular `Float32List`. It accepts arbitrary chunks and emits chronological frame-owned snapshots without growing concatenations. After the initial frame it overwrites only samples that have left the current window and emits after each hop. Sample-rate changes count and discard the partial old-rate window before reset, so samples from different rates never mix. Occupancy cannot exceed one analysis frame.

`RealtimePitchPipeline` starts at most one `PitchDetectionExecutor` future. While it is active, one pending slot retains the newest ready frame; later frames replace that slot and increment replacement/drop counters. A generation changes on session start, stop, restart, and sample-rate change. Late futures from older generations are ignored. Stopping clears the ring, pending slot, stabilizer, hysteresis, and stale deadline even though an already-executing main-isolate calculation cannot be cancelled.

The production executor schedules the existing synchronous YIN detector on the main isolate. It does not use per-frame `compute()` or an isolate. The Phase 2B Windows JIT observation of about 11.35 ms median for 4,096 samples is below the 48 kHz hop. Phase 2C physical validation was reported complete separately, but the repository contains no committed numeric measurement record. A later single long-lived worker isolate and its typed-data transfer cost would require new evidence from profile-mode Android duration, responsiveness, allocation/GC, and replacement counters.

`PitchStabilizer` operates in continuous MIDI/log-frequency space and never changes the raw detector result. It applies a five-estimate median-centered 45-cent outlier filter followed by 0.35 exponential smoothing. Confidence below 0.82 follows no-pitch behavior. A different note or octave requires two consecutive confirmations; the current note is retained near semitone boundaries until evidence persists at least 8 cents beyond the midpoint. Confirmed note changes reset history instead of averaging unrelated notes. Eight consecutive no-pitch results or 350 ms without a reliable estimate clear the old pitch.

The diagnostic exposes requested/reported format, chunk statistics, ring occupancy, assembled/analyzed/replaced/dropped frames, detector average/maximum duration, raw and stabilized pitch, stale/no-signal state, execution mode, and friendly errors. UI publication is capped near 13.3 updates/s and is not driven by widget rebuilds or every PCM chunk. No raw bytes or samples are logged, persisted, or sent off-device.

## Production Guitar Tuner

The Phase 2D product layer consumes only the stabilized Phase 2C estimate. Immutable tuning definitions provide Standard, Drop D, Half Step Down, Full Step Down, DADGAD, Open G, and Open D. Each string target stores a MIDI note and derives its frequency from 12-tone equal temperament with A4 fixed at 440 Hz.

Automatic selection compares every string in logarithmic cents space. A candidate must be within 200 cents, the current string receives a 25-cent hysteresis margin, a change requires two consecutive supporting observations, and four no-pitch observations clear the target. Manual mode bypasses this selector and keeps the chosen string locked. A preset or capture-session change resets pending automatic evidence.

Target-relative cents use `1200 × log2(detectedFrequency / targetFrequency)`. The model keeps the full signed value; only the indicator position is visually clamped to ±50 cents. Absolute error up to 5 cents is in tune, up to 15 cents is near, and larger errors are far. The controller requests one success haptic only after three consecutive targeted in-tune observations and rearms after the signal leaves that state or the session resets.

`TunerPreferences` persists only preset, automatic/manual mode, and the manual string position through `PreferencesStore`; unknown values fall back safely. The controller owns preference access and lifecycle delegation. The presentation is scrollable, supports compact controls under narrow or large-text constraints, supplies combined note/cents/frequency/target semantics, and honors reduced-motion accessibility. Raw detector confidence and engineering counters remain available only on the debug diagnostics route.

## Audio playback and assets

Oboe 1.10.0 provides the Android low-latency callback and device-version abstraction. It is integrated as an Android Prefab/CMake dependency, isolated below `MetronomeEngine`, and carries no Flutter-facing API. The Apache-2.0 license is bundled and registered with Flutter's license page.

The click WAV files are original project assets generated deterministically by `tool/generate_metronome_clicks.dart`; they are 40/55 ms decaying mono PCM16 tones, remain below full scale, and contain no third-party recording. The script records the exact generation parameters and can reproduce the checked-in assets. Native playback never schedules a manual stop.

## BPM estimation

`BpmTapEngine` is pure Dart and receives monotonic elapsed durations rather than reading wall-clock time. It derives intervals only from accepted taps and rejects intervals outside 200–2,000 milliseconds, corresponding to 300–30 BPM. A three-second gap starts a new session automatically.

An estimate requires at least two valid intervals (three accepted taps). The engine retains the latest eight valid intervals. For three or more intervals, it computes their median, discards samples more than 20 percent from that median, and averages the retained samples before converting the result to a whole-number BPM. With only two intervals it averages both; if aggressive filtering would retain fewer than two samples, it falls back to the median. This provides resistance to isolated accidental spikes while remaining responsive to a deliberate tempo change as new samples replace the rolling window.

Known algorithm limitations are intentional: the tool estimates only whole-number BPM, abrupt half-time or double-time changes need several taps to replace the previous window, and it cannot infer musical meter or distinguish equivalent tempo interpretations.

## Localization

Flutter's generated localization infrastructure uses English `app_en.arb` as the source and Turkish `app_tr.arb` as the second supported language. The selected language can follow the device or be fixed to English or Turkish. Unsupported device languages fall back to English.

Theory IDs, musical chord symbols, note symbols, and degree formulas are
deliberately nonlocalized. Chord quality names, categories, selector labels,
empty states, difficulty, per-string fingering, barre descriptions, intentional
omissions, rootless status, search feedback, and diagram semantics are
localized at the Chord Library presentation boundary.

Scale names, categories, alias names, relationships, search guidance, and
spoken degree semantics are localized at the Scale Library presentation
boundary. Exact search owns a small explicit English/Turkish vocabulary outside
the pure core; it does not turn localized display strings into theory identity.

Interactive Fretboard control, orientation, selection-detail, navigation, and
semantic-summary text is localized in the same ARB sources. Note, chord, and
degree notation remains standard and is never translated.

Circle of Fifths key descriptions, relationship labels, signature counts,
navigation actions, orientation guidance, and accessibility summaries are
localized at the presentation boundary. Note names, accidentals, chord
symbols, and Roman numerals remain standard notation.

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
- `shared_preferences` persists scalar application, metronome, and tuner settings behind application-owned abstractions.
- Oboe 1.10.0 supplies the Android low-latency output callback and AAudio/OpenSL ES compatibility layer behind `MetronomeEngine`.
- `record` 7.1.1 supplies continuous PCM16 microphone streaming and the Android `AudioRecord` bridge behind `TunerAudioInput`; it is used for transient capture, never file recording.
- `package_info_plus` supplies the installed version and build number behind `ApplicationInfoLoader`; platform metadata cannot be read reliably from `pubspec.yaml` at runtime.
- `wakelock_plus` 1.7.0 keeps the display on behind `ScreenWakeLock` while a Repertoire sheet is open. A performer reading chords does not touch the device, so the display timeout would otherwise blank the sheet mid-song. On Android the package sets the standard `FLAG_KEEP_SCREEN_ON` window flag, which needs no permission, contributes no manifest permission, and applies only while Tunathic is in the foreground. The evaluated alternative was a small platform channel around the same flag; it would duplicate the package's per-platform lifecycle handling with no product gain.

No pitch-analysis, FFT, DSP, scientific-computing, database, analytics, advertising, account, backend, or purchase package is included. Pitch detection and the real-time buffer/stabilizer use only Dart SDK math, async, and typed-data libraries.

Phases 3A through 3E add no dependency. Pitch arithmetic, formulas, search
parsing, relationships, shape validation, diagrams, fret derivation, and
reference presentation use Dart and Flutter primitives. The circle uses
`CustomPainter` and Material controls rather than chart, notation, or
third-party music-theory packages.

## Testing approach

Music-theory tests cover all 12 pitch classes, signed modulo transposition,
enharmonic identity and spelling, interval semitones and structural labels, all
22 formulas, common/altered/suspended/extended chord construction, sharp/flat
keys, boundary crossings, and exact supported search syntax.

Scale-theory tests cover structural degrees, all required scale formulas and
aliases, all 12 roots, requested sharp/flat examples, relative keys, modal
parents and degrees, pentatonic/blues construction, and exact English/Turkish
search acceptance and rejection. Scale Library widget tests cover dashboard
opening, root/definition changes, notes and formulas, relative/modal
relationships, localization, themes, combined semantics, 2× text, and 360,
412, 600, 900, and 1280 logical-pixel widths.

Fretboard pure tests cover standard tuning, all six open strings, MIDI/octave
transposition through fret 24, valid ranges, requested chord/scale projections,
root and non-member behavior, structural labels, and practical enharmonics.
Route tests cover direct, chord-prefilled, scale-prefilled, and malformed
states. Widget tests cover dashboard and both library paths, controls,
note/degree rendering, 12/24-fret scrolling, note details, localization,
themes, combined semantics, 2× text, and 360, 412, 600, 900, and 1280 logical
pixels.

Key/harmony pure tests cover all twelve circle positions, fifth/fourth
direction and wraparound, relative and representable parallel keys, practical
enharmonics, canonical signatures and accidental order, required major/minor
triads and seventh chords, half-diminished behavior, and structural Roman
numerals. Circle widget tests cover dashboard access, major/minor and
relationship selection, signature and harmony updates, enharmonic context, all
three library handoffs, localization, themes, combined and per-control
semantics, 2× text, and 360, 412, 600, 900, and 1280 logical-pixel widths.

Chord coverage tests audit all 264 root/quality combinations, exact quality and
family totals, complete coverage, lowest position, family availability,
alternatives for common qualities, and representative everyday and extended
chords. Chord-shape tests validate all 402 shapes plus rooted and rootless
voicings, intentional omissions, defining tones, malformed strings, frets,
fingers, spans, barres, and duplicate detection. Widget tests cover dashboard
opening, root/quality changes, formula-derived tones, diagram rendering,
multiple alternatives, representative extended exact searches, high positions,
barres, omission semantics, English/Turkish, light/dark themes, combined
semantics, 2× text, and 360, 412, 600, 900, and 1280 logical-pixel widths.

Unit tests cover preference parsing and persistence, BPM estimation, metronome denominator semantics, tempo interval calculation, lifecycle stopping, failure recovery, reset, and duplicate-start prevention. Controller tests replace `MetronomeEngine` with a deterministic fake, so unit/widget tests never load Oboe or require Android.

Metronome controller tests cover initialize-once, start/stop/restart, duplicate and rapid operations, 20 repeated Start/Stop cycles, stale callbacks after Stop/restart, BPM limits and rapid live changes, 2/4, 3/4, 4/4, and 6/8 callback order, deterministic signature transition, volume/accent persistence, initialization/start/runtime/update failures, recovery, backgrounding, route release, provider disposal, Tuner transition, and callback diagnostics. Widget tests cover start/stop, BPM, signature, current beat, accent, error/retry, English/Turkish, narrow/large-text layout, BPM Tap transfer, and navigation cleanup.

Application-shell tests cover haptic persistence and enabled/disabled behavior, dashboard grouping and availability, injected package versions, About and Privacy navigation, standard license entry, theme and language regression, large text, narrow layout, BPM Tap and Metronome regressions, corrected 6/8 timing, and Metronome cleanup on back navigation. GitHub Actions repeats dependency resolution, formatting verification, analysis, and tests for pushes and pull requests to `main` without secrets or deployment steps.

Tuner Audio pure-Dart tests cover PCM16 little-endian normalization, signed boundaries, malformed input, peak, RMS, dBFS, silence, and aggregate frame timing. Controller tests inject a fake audio input and cover grant/denial, unsupported configuration, retry, duplicate and rapid operations, foreground lifecycle, stream and stop failures, malformed-frame recovery, 10 Hz publication throttling, backend format adjustment, route cleanup, and disposal failure. Widget tests cover the non-tuner warning, privacy language, denied permission, start/statistics/stop interaction, Turkish localization, and narrow large-text scrolling. They intentionally use deterministic synthetic frames and make no claim about Android hardware.

Tuner Pitch tests are pure and require no microphone, Flutter widget, real timer, audio file, Android target, or network. They cover configuration validation, empty/short/non-finite/out-of-contract input, silence thresholds, all required clean frequencies, exact 40/1,200 Hz limits, near-boundary rejection through 39.9999 Hz and from 1,201 Hz, supported fundamentals beneath stronger out-of-range harmonics and a high transient, unsupported high-only tones, 44.1/48 kHz, multiple frame lengths and phases, 12-TET semitone boundaries, reference-frequency injection, dominant harmonics, missing/weak fundamental, deterministic white noise, low/moderate SNR, DC offset, clipping-like amplitude, envelopes, bass spectra, and repeatability. Wall-clock performance is observed only by the optional tool and is never asserted in tests.

Tuner Realtime pure tests verify exact overlap assembly, including the original 4,096/1,024 stress matrix, arbitrary chunks, multiple frames from one chunk, partial reset, ordering without gaps/duplicates, and fixed memory. Controlled asynchronous detector fakes verify one active analysis, newest pending replacement, counters, stop/restart generation invalidation, sample-rate reset, stale clearing, and detector errors. Stabilizer tests cover steady variation, transient/octave rejection, repeated octave and deliberate note changes, short/sustained no-pitch, confidence, semitone flicker, bass, and high guitar notes. Diagnostic controller and widget tests retain fake capture/time/detector dependencies and cover permission, Metronome release, lifecycle, route cleanup, raw/stable display, counters, errors, localization, and narrow layout.

Production Tuner tests cover all preset MIDI sequences and frequencies, target-relative cents, boundary thresholds, automatic hysteresis, confirmation, no-pitch clearing, octave/transient isolation, manual lock, preference fallback and persistence, lifecycle delegation, late-result cleanup, and one-shot haptics. Widget tests cover stopped, waiting, no-signal, flat, sharp, in-tune, automatic/manual, preset and string selection, English/Turkish, light/dark themes, narrow two-times text scaling, semantics, and the absence of diagnostics on the production surface.

## Known limitations

- Music spelling supports naturals, single sharps, and single flats. A complete
  double-accidental notation engine is intentionally out of scope.
- Chord Library has complete practical root/quality coverage for its current
  registry, but no inversions, slash chords, altered dominants, custom tunings,
  left-handed diagram transform, favorites, playback, or arbitrary runtime
  voicing generation.
- Exact chord search has no fuzzy matching. Favorites remain deferred until a
  structured cross-reference-tool persistence requirement exists.
- Scale Library uses ascending Melodic Minor and a deliberately focused scale
  catalog. It has no playback, custom formulas, or fuzzy search, and its
  single-accidental spelling fallback is not a complete academic notation
  engine.
- Interactive Fretboard currently supports standard tuning and one
  player-facing/right-handed orientation. It projects pitch membership rather
  than CAGED boxes, scale positions, chord shapes, inversions, or playable
  voicings. Custom tuning UI, left-handed mode, playback, CAGED, interval
  practice, and ear-training behavior are not implemented.
- Circle of Fifths covers major and natural-minor keys with standard -7…+7
  signatures. It does not implement staff notation, double-accidental keys,
  harmonic/melodic-minor key behavior, modes as keys, progressions,
  substitutions, playback, songwriting workflows, interval training, or ear
  training. Large text uses an ordered control list so notation is not
  compressed into an unreadable radial layout.

- BPM Tap, the foreground Metronome, and Guitar Tuner are functional. The tuner still requires broader real-guitar and device-matrix validation before it is release-complete.
- Metronome click placement is owned by the native output sample clock, but end-to-end acoustic latency varies by device and route. The feature does not run in the background and supports no subdivisions, swing, custom rhythms, dotted-quarter 6/8, or custom accent patterns.
- The original Dart-timed build exhibited audible stuttering on a physical Android device. The old scheduler/audio-pool path is removed, but the replacement cannot be declared physically reliable until profile/release listening, 20 Start/Stop cycles, a 10-minute endurance run, and the required BPM/signature matrix pass on hardware.
- Haptic response varies with Android hardware and system settings.
- The privacy policy is a product draft and the application is not Play Store ready.
- Microphone capture is foreground-only, transient, local, and was physically validated separately in Phase 2A. There is no file recording or content database.
- The capture layer does not force an input route or manage Bluetooth SCO; physical validation does not turn Android-controlled routing into a guaranteed route policy.
- Pitch detection is monophonic. Buffering, backpressure, smoothing, hysteresis, and stale behavior have deterministic coverage, but plucked-string inharmonicity, real microphone processing, Android execution cost, UI responsiveness, octave/flicker behavior, and thermal stability still require physical profile-mode validation.
- Preferences store only scalar application, metronome, and tuner settings; future structured data needs a separate decision when its requirements exist.
- Logging is local developer output only. No remote reporting or analytics exists.
- Foundation targets Android; other generated platform projects are intentionally absent.
