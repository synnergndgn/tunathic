# Architecture

Tunathic uses a pragmatic feature-first Flutter structure. Phase 1A adds the first functional tool while keeping responsibilities explicit and avoiding data or repository layers that have no current use.

## Folder responsibilities

- `lib/app/` owns application composition: bootstrap, router, persisted application settings, and Material themes.
- `lib/core/` owns app-wide technical boundaries. Foundation contains only logging and preferences abstractions.
- `lib/features/` groups user-facing areas. The dashboard and settings have presentation code, tool metadata is centralized, BPM Tap separates pure domain logic from presentation state, and unfinished tools share one placeholder presentation.
- `lib/shared/` contains reusable interface elements that are not specific to one feature. Foundation contains the friendly error view.
- `lib/l10n/` contains source ARB files and generated Flutter localization classes.

No UI component imports `shared_preferences`, and no audio or platform-specific feature code exists. BPM Tap is fully offline and does not persist sessions or timestamps.

## State management

Riverpod provides scoped dependency injection and reactive application settings. `ProviderScope` is the application root. `AppSettingsController` owns theme and locale changes; widgets observe its immutable state and never read or write storage directly. The initially persisted settings are loaded before `runApp`, preventing a visible theme or language change after the first frame.

`BpmTapController` owns the in-memory tap session, monotonic elapsed-time reads, manual reset, and inactivity timer. The BPM Tap widget only observes immutable state and forwards tap or reset actions. Its elapsed-time provider can be replaced in tests, keeping controller behavior deterministic without a platform clock dependency.

## Navigation

GoRouter provides one central route table:

- `/` displays the responsive dashboard.
- `/settings` displays theme and language preferences.
- `/tools/bpm-tap` displays the functional BPM Tap screen.
- `/tools/:toolId` resolves every other known tool to its Coming Soon placeholder.

Unknown paths and tool identifiers display a friendly localized not-found screen. Tool IDs are stable, nonlocalized route segments; tool names are localized at presentation time.

## BPM estimation

`BpmTapEngine` is pure Dart and receives monotonic elapsed durations rather than reading wall-clock time. It derives intervals only from accepted taps and rejects intervals outside 200–2,000 milliseconds, corresponding to 300–30 BPM. A three-second gap starts a new session automatically.

An estimate requires at least two valid intervals (three accepted taps). The engine retains the latest eight valid intervals. For three or more intervals, it computes their median, discards samples more than 20 percent from that median, and averages the retained samples before converting the result to a whole-number BPM. With only two intervals it averages both; if aggressive filtering would retain fewer than two samples, it falls back to the median. This provides resistance to isolated accidental spikes while remaining responsive to a deliberate tempo change as new samples replace the rolling window.

Known algorithm limitations are intentional: the tool estimates only whole-number BPM, abrupt half-time or double-time changes need several taps to replace the previous window, and it cannot infer musical meter or distinguish equivalent tempo interpretations.

## Localization

Flutter's generated localization infrastructure uses English `app_en.arb` as the source and Turkish `app_tr.arb` as the second supported language. The selected language can follow the device or be fixed to English or Turkish. Unsupported device languages fall back to English.

## Preferences abstraction

`PreferencesStore` is the small asynchronous key-value boundary used by application settings. Its production implementation uses `SharedPreferencesAsync`, while tests use an in-memory implementation. Shared Preferences is sufficient for two non-sensitive scalar settings and is smaller and easier to maintain than introducing a database. The asynchronous API avoids stale cache behavior across isolates and engine instances.

The stored values are theme mode and optional locale code. Unknown or missing values safely fall back to system settings. Preferences are not suitable for secrets or future structured practice data.

## Theme system

The application uses Material 3 with light, dark, and system modes. Centralized theme files define the deep-charcoal, electric-blue, soft-cyan, and off-white palette plus spacing, typography, and restrained radius tokens. Feature widgets consume the active `ThemeData` and shared tokens instead of duplicating design values.

## Error handling and logging

`AppLogger` isolates diagnostic output from features. Bootstrap records uncaught Flutter framework and platform errors without adding analytics or an external reporting service. A localized, user-friendly error widget replaces raw framework error presentation in release-facing UI.

## Dependency rationale

- `flutter_riverpod` supplies scoped state management and dependency injection without global mutable state.
- `go_router` supplies centralized declarative navigation, path parsing, and route-level error handling.
- `flutter_localizations` and the SDK-compatible `intl` version generate and support English and Turkish localization.
- `shared_preferences` persist the two Foundation settings behind an application-owned abstraction.

No microphone, audio, DSP, database, analytics, advertising, account, backend, or purchase package is included.

## Testing approach

Unit tests cover preference parsing, safe defaults, settings persistence, BPM estimates at common tempos, rolling-window behavior, invalid intervals, outlier resistance, inactivity, and reset behavior. Controller tests use a deterministic elapsed-time reader. Widget tests verify dashboard availability, placeholder navigation, Turkish content, repeated BPM tapping, reset, and inactivity behavior. Fakes implement the same application-owned boundaries used by production code.

## Known limitations

- BPM Tap is functional; every other listed music tool remains a nonfunctional Coming Soon placeholder.
- There is no microphone permission, recording, pitch detection, DSP, metronome timing engine, or content database.
- Preferences store only theme and locale; future structured data needs a separate decision when its requirements exist.
- Logging is local developer output only. No remote reporting or analytics exists.
- Foundation targets Android; other generated platform projects are intentionally absent.
