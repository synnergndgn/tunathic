# Tunathic – Guitar Toolkit

**Tune. Train. Create.**

Tunathic is a commercial, Android-first Flutter music toolkit published by GUNDEV. The repository is currently under feature freeze at **Phase 5A — Closed Test Release Hardening**. The validated Guitar Tuner, BPM Tap, native Oboe Metronome, Chord Library, Scale Library, Interactive Fretboard, Circle of Fifths, and Interval Trainer are being prepared for Google Play Internal and Closed Testing.

## Current contents

- Material 3 light, dark, and system themes
- Responsive dashboard for eleven planned guitar tools
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
- Offline Chord Library with all 12 roots, 22 useful qualities,
  formula-derived tones, exact search, and complete 264/264 practical
  root/quality coverage
- 402 project-owned structured guitar shapes across open, movable E, movable A,
  and compact families, with curated and generated provenance
- Deterministic development-time coverage statistics plus automated pitch,
  required-tone, root/rootless, declared-omission, fret-span, finger,
  diagram-window, barre, and duplicate validation
- Responsive theme-aware chord diagrams drawn from data, with useful ordering,
  difficulty/position metadata, and complete English/Turkish fingering,
  omission, barre, and screen-reader descriptions
- Pure Dart structural scale degrees, formulas, aliases, construction, relative keys, and modal parent-major relationships
- Offline Scale Library with 12-root browsing, 12 unique scale definitions, exact English/Turkish search, formula-derived notes, and accessible degree formulas
- Pure Dart standard-tuning fret derivation from open strings through fret 24, with octave/MIDI identity and reusable chord/scale projection
- Interactive Fretboard with Chord/Scale modes, note or structural degree labels, root distinction, 12/15/18/24-fret ranges, synchronized horizontal scrolling, position markers, and inline note details
- Prefilled **View on Fretboard** navigation from both Chord Library and Scale Library
- Pure Dart major/natural-minor keys, standard key signatures, relative and
  parallel relationships, structural Circle-of-Fifths ordering, scale-derived
  diatonic triads and seventh chords, and reusable Roman numerals
- Interactive Circle of Fifths with outer major and inner relative-minor rings,
  practical enharmonic switching, selected/relative/fifth/fourth cues,
  signature and chord details, and an accessible large-text ordered fallback
- Prefilled **View Scale**, **View on Fretboard**, and diatonic-chord navigation
  from Circle of Fifths
- Offline Interval Trainer with identify-interval and target-note modes,
  spelling-aware tritone identities, deterministic questions, and transient
  accuracy/streak feedback
- Persisted metronome settings and explicit BPM transfer from BPM Tap
- Grouped responsive dashboard and polished Settings hierarchy
- Localized About and Privacy screens with standard open-source license access
- Actual package-version display and persisted global haptic preference
- Centralized elevation and motion tokens alongside the existing design system
- Reproducible Flutter 3.44.0 GitHub Actions formatting, analysis, test, and debug-build verification
- Unit and widget tests

Guitar Tuner, Metronome, BPM Tap, Chord Library, Scale Library, Interactive Fretboard, Circle of Fifths, and Interval Trainer are available from the dashboard. Debug builds retain the Phase 2C engineering diagnostic behind a separate debug-only route. All reference and Interval Trainer tools are fully offline and add no audio, microphone, account, analytics, network, advertising, or backend behavior.

Ear Training, Chord Finder, and Capo Calculator remain localized,
non-interactive Coming Soon items.

The Metronome's audio callback owns click timing; Flutter never schedules audible beats. Displayed BPM is quarter-note BPM, so 6/8 emits six eighth-note pulses. See the [engine decision](docs/METRONOME_ENGINE_DECISION.md) for the rejected package spike, Oboe rationale, lifecycle, diagnostics, and current physical-validation status.

## Requirements

- Flutter 3.44.0 stable with its bundled Dart 3.12.0 SDK
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

Print Chord Library development coverage statistics with:

```sh
dart run tool/chord_shape_coverage.dart
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
- [Release hardening audit](docs/RELEASE_HARDENING_AUDIT.md)
- [Closed test release checklist](docs/closed_test_release_checklist.md)
- [Android release signing](docs/android_release_signing.md)
- [Privacy policy draft](docs/PRIVACY_POLICY_DRAFT.md)
- [Data Safety draft](docs/data_safety_draft.md)
- [Store listing draft](docs/store_listing.md)
- [Design direction](design/README.md)
- [Repository rules](AGENTS.md)
