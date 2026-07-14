# Architecture

Tunathic uses a pragmatic feature-first Flutter structure. The Foundation milestone keeps responsibilities explicit without adding data, domain, or repository layers that have no current use.

## Folder responsibilities

- `lib/app/` owns application composition: bootstrap, router, persisted application settings, and Material themes.
- `lib/core/` owns app-wide technical boundaries. Foundation contains only logging and preferences abstractions.
- `lib/features/` groups user-facing areas. The dashboard and settings have presentation code, tool metadata is centralized, and unfinished tools share one placeholder presentation.
- `lib/shared/` contains reusable interface elements that are not specific to one feature. Foundation contains the friendly error view.
- `lib/l10n/` contains source ARB files and generated Flutter localization classes.

No UI component imports `shared_preferences`, and no audio or platform-specific feature code exists.

## State management

Riverpod provides scoped dependency injection and reactive application settings. `ProviderScope` is the application root. `AppSettingsController` owns theme and locale changes; widgets observe its immutable state and never read or write storage directly. The initially persisted settings are loaded before `runApp`, preventing a visible theme or language change after the first frame.

## Navigation

GoRouter provides one central route table:

- `/` displays the responsive dashboard.
- `/settings` displays theme and language preferences.
- `/tools/:toolId` resolves a known tool and displays its Coming Soon placeholder.

Unknown paths and tool identifiers display a friendly localized not-found screen. Tool IDs are stable, nonlocalized route segments; tool names are localized at presentation time.

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

Unit tests cover preference parsing, safe defaults, controller state changes, and persistence behavior. Widget tests verify that all ten dashboard tools are marked Coming Soon, navigation opens the correct placeholder, and Turkish content renders. Fakes implement the same application-owned boundaries used by production code.

## Known limitations

- Every listed music tool is intentionally a nonfunctional Coming Soon placeholder.
- There is no microphone permission, recording, pitch detection, DSP, metronome timing engine, or content database.
- Preferences store only theme and locale; future structured data needs a separate decision when its requirements exist.
- Logging is local developer output only. No remote reporting or analytics exists.
- Foundation targets Android; other generated platform projects are intentionally absent.
