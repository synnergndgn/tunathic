# Tunathic – Guitar Toolkit

**Tune. Train. Create.**

Tunathic is a commercial, Android-first Flutter music toolkit published by GUNDEV. The repository is currently at **Phase 1C — Application Polish**: it combines two fully offline practice tools with a coherent, localized, accessible application shell.

## Current contents

- Material 3 light, dark, and system themes
- Responsive dashboard for ten planned guitar tools
- English source localization and Turkish support
- Persisted theme and language preferences
- Centralized GoRouter navigation
- Riverpod state and dependency management
- Abstracted preferences and logging
- Friendly application and route error presentation
- Functional BPM Tap with a robust rolling tempo estimate
- Functional foreground metronome with 20–300 BPM, four time signatures, first-beat accent, volume, and visual beat feedback
- Persisted metronome settings and explicit BPM transfer from BPM Tap
- Grouped responsive dashboard and polished Settings hierarchy
- Localized About and Privacy screens with standard open-source license access
- Actual package-version display and persisted global haptic preference
- Centralized elevation and motion tokens alongside the existing design system
- Minimal GitHub Actions formatting, analysis, and test verification
- Unit and widget tests

All tools except BPM Tap and Metronome display **Coming Soon**. Phase 1C does not request microphone access, perform pitch detection or recording, play audio in the background, persist tap sessions, serve advertisements, collect analytics, require accounts, or connect to a Tunathic backend. It does not claim Play Store readiness.

## Requirements

- Flutter stable with its bundled Dart stable SDK
- Android SDK and accepted Android SDK licenses
- An Android emulator or physical Android device for runtime verification

## Get started

```sh
flutter pub get
flutter run
```

Run the project checks before proposing changes:

```sh
dart format .
flutter analyze
flutter test
```

## Project identity

- Product: Tunathic – Guitar Toolkit
- Publisher: GUNDEV
- Android application ID: `dev.gundev.tunathic`
- Initial languages: English and Turkish

The Android application ID is a permanent product identifier and must not be changed without explicit approval.

## Documentation

- [Product vision](docs/PRODUCT.md)
- [Current milestone](docs/CURRENT_MILESTONE.md)
- [Roadmap](docs/ROADMAP.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Design direction](design/README.md)
- [Repository rules](AGENTS.md)
