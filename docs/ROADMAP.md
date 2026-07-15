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

A production tuner interface, presets, calibration, and release claims remain later decisions.

## Phase 3: Chord library, scale library and circle of fifths

Offline reference tools for chords, scales, and harmonic relationships.

## Phase 4: Interval trainer, ear training and progress tracking

Guided listening exercises with meaningful local progress.

## Phase 5: Chord finder, capo calculator and fretboard explorer

Interactive tools for identifying and transforming playable material.

## Phase 6: Daily challenges, XP, streaks and statistics

Opt-in motivation and practice insights without punitive engagement mechanics.

## Phase 7: Privacy, store assets, advertising integration and publishing

Production privacy review, listing assets, respectful monetization integration, release hardening, and Android publishing.
