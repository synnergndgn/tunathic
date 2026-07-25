# Tunathic – Guitar Toolkit

**Tune. Train. Create.**

Tunathic is a commercial, Android-first Flutter music toolkit published by GUNDEV. The repository is currently at **Phase 2D — Final Guitar Tuner UI**: BPM Tap, Metronome, and a production-facing monophonic Guitar Tuner are implemented, with final real-guitar validation and tuning polish still tracked explicitly.

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
- Explicit microphone-permission flow and continuous mono PCM16 input boundary
- Local transient signal-level and stream diagnostics with lifecycle-safe cleanup
- Pure Dart YIN pitch detection from 40–1,200 Hz with typed confidence/no-pitch results
- Bounded 4,096/2,048-sample real-time analysis with newest-frame backpressure, pitch stabilization, and stale clearing
- A4 = 440 Hz MIDI, sharp note-name, octave, and signed-cents conversion tested offline
- Automatic and manual Guitar Tuner modes with seven common tunings, target-string hysteresis, a cents indicator, persisted tuner preferences, and one-shot in-tune haptics
- Persisted metronome settings and explicit BPM transfer from BPM Tap
- Grouped responsive dashboard and polished Settings hierarchy
- Localized About and Privacy screens with standard open-source license access
- Actual package-version display and persisted global haptic preference
- Centralized elevation and motion tokens alongside the existing design system
- Minimal GitHub Actions formatting, analysis, and test verification
- Unit and widget tests

Guitar Tuner is available from the dashboard. Debug builds retain the Phase 2C engineering diagnostic behind a separate debug-only route. The current work adds no audio-file recording, background capture, sample or pitch-history persistence, upload, advertising, analytics, account, or backend behavior and does not claim Play Store readiness.

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
