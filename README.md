# Tunathic – Guitar Toolkit

**Tune. Train. Create.**

Tunathic is a commercial, Android-first Flutter music toolkit published by GUNDEV. The repository is currently at **Phase 3B — Scale Library**. The physically validated Guitar Tuner, BPM Tap, and native Oboe Metronome remain intact while the reusable theory core now powers two offline reference tools.

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
- Native Oboe-timed foreground metronome with 20–300 BPM, four time signatures, first-beat accent, live volume/tempo/signature updates, and visual-only beat callbacks
- Explicit microphone-permission flow and continuous mono PCM16 input boundary
- Local transient signal-level and stream diagnostics with lifecycle-safe cleanup
- Pure Dart YIN pitch detection from 40–1,200 Hz with typed confidence/no-pitch results
- Bounded 4,096/2,048-sample real-time analysis with newest-frame backpressure, pitch stabilization, and stale clearing
- A4 = 440 Hz MIDI, sharp note-name, octave, and signed-cents conversion tested offline
- Automatic and manual Guitar Tuner modes with seven common tunings, target-string hysteresis, a cents indicator, persisted tuner preferences, and one-shot in-tune haptics
- Pure Dart pitch-class, enharmonic spelling, interval, chord-formula, chord-construction, and exact chord-symbol parsing
- Offline Chord Library with all 12 roots, 22 useful qualities, formula-derived tones, and honest no-shape states
- 162 project-owned structured guitar shapes with automated pitch, root, fret, finger, diagram-window, and barre validation
- Responsive theme-aware chord diagrams drawn from data, with complete English/Turkish fingering and screen-reader descriptions
- Pure Dart structural scale degrees, formulas, aliases, construction, relative keys, and modal parent-major relationships
- Offline Scale Library with 12-root browsing, 12 unique scale definitions, exact English/Turkish search, formula-derived notes, and accessible degree formulas
- Persisted metronome settings and explicit BPM transfer from BPM Tap
- Grouped responsive dashboard and polished Settings hierarchy
- Localized About and Privacy screens with standard open-source license access
- Actual package-version display and persisted global haptic preference
- Centralized elevation and motion tokens alongside the existing design system
- Minimal GitHub Actions formatting, analysis, and test verification
- Unit and widget tests

Guitar Tuner, Metronome, BPM Tap, Chord Library, and Scale Library are available from the dashboard. Debug builds retain the Phase 2C engineering diagnostic behind a separate debug-only route. Both reference libraries are fully offline and add no audio, microphone, account, analytics, network, advertising, or backend behavior.

The Metronome's audio callback owns click timing; Flutter never schedules audible beats. Displayed BPM is quarter-note BPM, so 6/8 emits six eighth-note pulses. See the [engine decision](docs/METRONOME_ENGINE_DECISION.md) for the rejected package spike, Oboe rationale, lifecycle, diagnostics, and current physical-validation status.

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
- [Metronome engine decision](docs/METRONOME_ENGINE_DECISION.md)
- [Design direction](design/README.md)
- [Repository rules](AGENTS.md)
