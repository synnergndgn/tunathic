# Architecture

Tunathic uses a pragmatic feature-first Flutter structure. Phase 1C polishes the application shell around BPM Tap and the foreground Metronome while keeping responsibilities explicit and avoiding data or repository layers that have no current use.

## Folder responsibilities

- `lib/app/` owns application composition: bootstrap, router, persisted application settings, and Material themes.
- `lib/core/` owns app-wide technical boundaries for logging, preferences, package information, and haptic output.
- `lib/features/` groups user-facing areas. Dashboard, Settings, About, and Privacy compose the application shell. BPM Tap separates pure estimation logic from presentation state. Metronome separates configuration and beat sequencing, scheduling and orchestration, audio output, persistence, and presentation. Unfinished tools share one placeholder presentation.
- `lib/shared/` contains reusable interface elements that are not specific to one feature. Foundation contains the friendly error view.
- `lib/l10n/` contains source ARB files and generated Flutter localization classes.

No UI component imports `shared_preferences` or contains audio timing logic. Platform-facing playback is isolated behind `MetronomeAudioOutput`. Both tools are fully offline, and BPM Tap does not persist sessions or timestamps.

## State management

Riverpod provides scoped dependency injection and reactive application settings. `ProviderScope` is the application root. `AppSettingsController` owns theme, locale, and haptic-preference changes; widgets observe its immutable state and never read or write storage directly. The initially persisted settings are loaded before `runApp`, preventing a visible theme, language, or interaction-preference change after the first frame.

`AppHaptics` gates meaningful direct feedback against the current setting and delegates to an injectable `HapticFeedbackOutput`. Production uses Flutter’s built-in system haptic API; tests use a recording fake. BPM taps, Metronome start/stop, result application, resets, navigation, and important selections may request subtle feedback. Timers, passive state, sliders, and Metronome beats do not.

`BpmTapController` owns the in-memory tap session, monotonic elapsed-time reads, manual reset, and inactivity timer. The BPM Tap widget only observes immutable state and forwards tap or reset actions. Its elapsed-time provider can be replaced in tests, keeping controller behavior deterministic without a platform clock dependency.

`MetronomeController` owns immutable runtime state and coordinates the scheduler, audio boundary, and preferences. Widgets forward user actions and render state. Playback stops when the app loses foreground focus and does not resume automatically. Leaving the screen synchronously invalidates pending start work, stops the scheduler, and releases audio without mutating Riverpod during widget teardown; a later screen entry normalizes the retained runtime state before rendering.

## Navigation

GoRouter provides one central route table:

- `/` displays the responsive dashboard.
- `/settings` displays appearance, interaction, and application preferences and links.
- `/about` displays localized product, publisher, tool, version, privacy, and license information.
- `/privacy` displays the current local/offline privacy summary.
- `/tools/bpm-tap` displays the functional BPM Tap screen.
- `/tools/metronome` displays the functional Metronome screen.
- `/tools/:toolId` resolves every other known tool to its Coming Soon placeholder.

Unknown paths and tool identifiers display a friendly localized not-found screen. Tool IDs are stable, nonlocalized route segments; tool names are localized at presentation time.

The Metronome opens BPM Tap with an explicit result contract. BPM Tap returns only a valid whole-number estimate when the user chooses Apply; the metronome validates the 20–300 BPM range and then updates and persists its tempo. Ordinary dashboard use of BPM Tap has no Apply action.

The dashboard groups stable tool definitions into Practice, Theory and Reference, and Training. Metronome and BPM Tap are the only available tools and receive stronger surface treatment; all planned tools remain visible and explicitly labeled Coming Soon. Navigation uses pushes for drill-in screens so Android back naturally returns to the previous context. Unknown routes continue to use the localized not-found screen.

## Application information and licenses

`ApplicationInfoLoader` isolates `package_info_plus` from widgets. Bootstrap reads the installed package version once and overrides `initialApplicationInfoProvider`; Settings, About, and the license page consume the application-owned immutable value. Tests inject arbitrary versions without a platform channel. The product version is `0.2.0+1`, representing a pre-1.0 application with Foundation plus two working tools.

Open-source notices use Flutter’s standard `showLicensePage`, which reads Flutter’s license registry and presents package licenses with the app name, actual version, and legalese. No custom license database or duplicate route is maintained.

## Metronome timing and beat model

`BeatSequence` is pure Dart. It advances and wraps a one-based beat number for 2/4, 3/4, 4/4, and 6/8, marking only beat one as accented when the preference is enabled. Displayed BPM uses a quarter-note reference, and click duration is `quarter-note duration × 4 ÷ denominator`. In 6/8 this produces six eighth-note clicks per measure: at 120 BPM each click is 250 milliseconds apart. Dotted-quarter interpretation is out of scope.

`AnchoredMetronomeScheduler` uses a monotonic clock and one-shot timers. Its clock and timer factory are replaceable in deterministic tests. Each deadline is calculated from the original anchor instead of chaining the previous timer completion, limiting cumulative drift. The next timer is armed before controller state or audio work begins. A callback delayed by less than one interval retains the original next deadline; deadlines already reached during a longer stall are skipped rather than played in a catch-up burst. BPM or denominator changes cancel the previous timer and re-anchor the single scheduler.

The scheduler callback carries its intended deadline, actual callback time, lateness, and skipped count to `MetronomeController`. In debug builds, the controller records those values with beat number, BPM, and audio-request pending/completed/failed state through `AppLogger`. Per-beat logging is compiled out of release builds. Audio playback futures are deliberately not awaited by the scheduler, so platform-channel completion cannot postpone arming the next deadline. Visual state and the audio request use the same beat number, although visual rendering may follow the request by a few milliseconds.

This foreground design is maintainable and testable but not sample-accurate: Dart scheduling, platform-channel transit, Android audio buffering, and device hardware all contribute latency. A native scheduled-audio engine would be required for stronger real-time guarantees.

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
- `package_info_plus` supplies the installed version and build number behind `ApplicationInfoLoader`; platform metadata cannot be read reliably from `pubspec.yaml` at runtime.

No microphone, recording, DSP, database, analytics, advertising, account, backend, or purchase package is included.

## Testing approach

Unit tests cover preference parsing and persistence, BPM estimation, metronome beat progression, wrapping, accents, time signatures, tempo interval calculation, lifecycle stopping, failure recovery, reset, and duplicate-start prevention. Controller tests replace clocks, audio, and scheduling with deterministic fakes. Widget tests verify both functional dashboard tools, English and Turkish content, scaled compact layouts, metronome controls, and BPM Tap result transfer. Fakes implement the same application-owned boundaries used by production code.

Scheduler tests use fake monotonic time and fake one-shot timers; they do not wait on wall-clock time. They cover exact callbacks, mild and multi-interval lateness, original-deadline retention, skipped deadlines, no catch-up bursts, re-anchoring, and rapid stop/start. Controller tests additionally cover 4/4-to-6/8 reconfiguration, debug timing records, duplicate-start prevention, audio failure, and pending audio futures that do not block later beat callbacks.

Application-shell tests cover haptic persistence and enabled/disabled behavior, dashboard grouping and availability, injected package versions, About and Privacy navigation, standard license entry, theme and language regression, large text, narrow layout, BPM Tap and Metronome regressions, corrected 6/8 timing, and Metronome cleanup on back navigation. GitHub Actions repeats dependency resolution, formatting verification, analysis, and tests for pushes and pull requests to `main` without secrets or deployment steps.

## Known limitations

- BPM Tap and the foreground Metronome are functional; every other listed music tool remains a nonfunctional Coming Soon placeholder.
- Metronome playback is not sample-accurate, does not run in the background, and supports no subdivisions, swing, custom rhythms, or custom accent patterns.
- Rare audible stuttering was observed on a physical Android device in the original Phase 1B build. Debug instrumentation can now distinguish Dart scheduler lateness, skipped deadlines, and overlapping platform audio requests, but repeat physical-device validation is required before declaring the symptom resolved. No physical Android target was connected during automated validation of this hotfix.
- Haptic response varies with Android hardware and system settings.
- The privacy policy is a product draft and the application is not Play Store ready.
- There is no microphone permission, recording, pitch detection, DSP, or content database.
- Preferences store only scalar application and metronome settings; future structured data needs a separate decision when its requirements exist.
- Logging is local developer output only. No remote reporting or analytics exists.
- Foundation targets Android; other generated platform projects are intentionally absent.
