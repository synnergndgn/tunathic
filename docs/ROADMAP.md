# Roadmap

The roadmap communicates product sequence, not a promise of dates. Only the current milestone is authorized for implementation.

## Phase 0: Foundation

Application shell, architecture, design system, preferences, localization, navigation, accessibility basics, placeholders, tests, and documentation.

## Phase 1: Metronome and BPM tap

The first functional timing-sensitive practice tools, followed by application-shell polish.

## Phase 2: Guitar tuner

- **Phase 2A — Tuner Audio Prototype:** physically validated permission, lifecycle, and continuous local PCM input without tuner results.
- **Phase 2B — Offline Pitch Detection Engine:** deterministic pure Dart YIN analysis and note conversion using synthetic offline signals; no live integration.
- **Phase 2C — Real-Time Pitch Pipeline:** bounded overlapping microphone-frame analysis, newest-frame backpressure, transient smoothing and note hysteresis, lifecycle coordination, and a development diagnostic. Physical Android/profile validation remains required.
- **Phase 2D — Final Guitar Tuner UI:** production-facing automatic/manual tuning, common presets, target-string hysteresis, cents feedback, persisted tuner preferences, accessibility, and stable in-tune haptics. Final physical real-guitar validation and polish determine release completion.
- **Phase 2E — Production Metronome Engine:** P0 replacement of Dart-timed click playback with an Android native Oboe audio clock, denominator-aware beat rendering, live updates, deterministic lifecycle, and mandatory physical reliability validation before Phase 3.

Calibration and custom tuning creation remain later decisions.

## Phase 3: Offline theory and reference tools

- **Phase 3A — Music Theory Core + Chord Library:** reusable pure Dart pitch
  classes, enharmonic spelling, intervals, chord formulas and construction,
  validated structured guitar shapes, and the offline Chord Library.
- **Phase 3B — Scale Library:** structural scale degrees, formulas, aliases,
  spelling, relative/modal relationships, and an offline localized reference
  view built on the Phase 3A pitch identities and notation strategy.
- **Phase 3C — Interactive Fretboard:** a reusable standard-tuning projection
  model and responsive offline guitar neck for chord tones and scale degrees,
  with prefilled links from both existing libraries.
- **Recommended Phase 3D — Circle of Fifths:** an offline harmonic-relationship
  reference built from existing pitch spelling and relative-key helpers, with
  no audio or training behavior.
- **Later Phase 3 scope:** broader harmonic-reference work only after the
  Interactive Fretboard and Circle of Fifths are validated.

## Phase 4: Interval trainer, ear training and progress tracking

Guided listening exercises with meaningful local progress.

## Phase 5: Chord finder, capo calculator and advanced fretboard tools

Interactive tools for identifying and transforming playable material,
including separately authorized CAGED and voicing overlays.

## Phase 6: Daily challenges, XP, streaks and statistics

Opt-in motivation and practice insights without punitive engagement mechanics.

## Phase 7: Privacy, store assets, advertising integration and publishing

Production privacy review, listing assets, respectful monetization integration, release hardening, and Android publishing.
