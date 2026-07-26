# Current Milestone: Phase 3A — Music Theory Core + Chord Library

Phase 3A establishes Tunathic's reusable, offline music-theory domain layer and
ships Chord Library as the first reference tool built on it. The production
Guitar Tuner, BPM Tap, and native Oboe Metronome remain behaviorally unchanged.

## Authorized scope

- Pure Dart pitch-class identity, spelling, interval, chord-formula, chord
  construction, and exact chord-symbol parsing.
- Structured guitar chord shapes, standard-tuning pitch derivation, and
  deterministic dataset validation.
- A localized, accessible, responsive Chord Library with root, quality, search,
  chord-tone, primary-shape, and alternate-shape browsing.
- English and Turkish strings, deterministic unit/widget coverage, architecture
  documentation, Android debug build, and available physical UI validation.

Scale Library, Interactive Fretboard, Interval Trainer, Ear Training, favorites,
accounts, networking, analytics, advertising, and backend work are outside this
milestone.

## Music-theory core

`lib/core/music_theory/` is a Flutter-independent library with no UI, state,
storage, audio, platform, or localization dependency.

### Pitch-class identity and spelling

`PitchClass` structurally represents the 12 chromatic identities as semitone
offsets from C. Safe positive modulo arithmetic handles transposition in either
direction. Enharmonic names are not separate pitches: C# and Db are distinct
`SpelledPitchClass` values whose `pitchClass` is the same identity.

`SpelledPitchClass` combines a diatonic `NoteLetter` with natural, sharp, or flat
`Accidental`. `NoteSpelling` keeps chromatic identity arithmetic separate from
display spelling. Chord construction advances the expected diatonic letter and
then chooses a natural, sharp, or flat accidental. This produces Bb in F-based
contexts, Bb-D-F for Bb major, and F#-A-C#-E for F#m7. If a result would require
a double accidental, the Phase 3A strategy deliberately falls back to a
readable enharmonic single-accidental spelling.

The root browser uses a pragmatic mixed chromatic spelling:
C, C#, D, Eb, E, F, F#, G, Ab, A, Bb, B. Exact search may preserve another
supported spelling such as Db.

### Intervals

`TheoryInterval` provides stable identity, semitone distance, diatonic steps,
short label, and simple semitone reduction. It covers unison through octave,
separate augmented-fourth and diminished-fifth identities, augmented fifth,
diminished seventh, and the compound ninth, eleventh, and thirteenth intervals
needed by current chord formulas. The model is designed for later Interval
Trainer reuse without carrying localized names or exercise state.

### Chord formulas and construction

`ChordQuality` stores a stable identifier, standard symbol, category, and an
ordered interval formula. User-facing names live in Flutter localization.
Coverage is intentionally focused:

- Triads: major, minor, diminished, augmented, sus2, sus4.
- Sevenths: major 7, dominant 7, minor 7, minor-major 7, diminished 7,
  half-diminished/m7b5.
- Common extensions: 6, minor 6, add9, minor add9, 9, major 9, minor 9, 11,
  minor 11, and 13.

`ChordConstructor` derives every displayed chord tone from the selected root and
formula. It contains no root-specific tone tables. `ChordSymbolParser` accepts
only the exact roots, accidentals, and quality suffixes represented by the
domain model; it is not fuzzy search.

Tuner live-pitch models remain separate because they include MIDI octave,
frequency, cents, confidence, and transient capture state. Phase 3A does not
change the physically validated tuner conversion or presentation behavior.

## Guitar chord shapes

`GuitarChordShape` stores six string fingerings in low-E through high-E order.
Each string is structurally muted, open, or fretted and may carry a finger
number. Shapes also identify root, chord quality, diagram starting fret,
category, difficulty, optional rootless status, project source, and zero or more
barres with fret, finger, and string range.

The project-owned offline dataset contains 162 shapes:

- curated open major, minor, dominant 7, major 7, minor 7, sus2/sus4, add9, 6,
  minor 6, and selected extended shapes;
- compact diminished, augmented, half-diminished, 9, 11, and 13 examples;
- validated movable E- and A-family major, minor, dominant 7, major 7, and
  minor 7 shapes for all 12 pitch classes.

The set favors dependable everyday vocabulary over exhaustive voicing coverage.
An unavailable voicing never gets fabricated: theory tones remain visible with
a localized empty state.

### Dataset validation

`GuitarShapeValidator` derives every sounding pitch from standard guitar tuning
and its fret, reduces it to pitch class, and checks it against the selected
formula. It also verifies:

- exactly six strings;
- fret range 0–24 plus the explicit muted sentinel;
- string-kind/fret consistency;
- optional finger range 1–4;
- a valid five-fret diagram window and starting fret;
- barre fret, finger, range, and covered-string consistency;
- no pitch outside the chord formula;
- root presence unless a voicing explicitly declares itself rootless.

All checked-in shapes must pass the aggregate dataset test. Chord extensions may
omit optional chord members in a practical guitar voicing, but may not add a
foreign pitch.

## Chord Library interface

The dashboard exposes `/tools/chord-library` as an available offline tool. One
scrollable screen supports:

- exact local chord-symbol search;
- all 12 pitch classes through minimum-size root chips;
- all 22 chord qualities through a categorized selector;
- standard chord symbol and formula-derived chord tones;
- selected and alternate verified guitar shapes;
- concise localized per-string and barre fingering;
- a clear no-shape state for valid formulas without curated voicings.

The project-owned `CustomPainter` diagram draws six strings, five fret cells,
nut or starting-fret position, muted/open glyphs, finger dots/numbers, and
barres. It uses active theme colors but preserves meaning through glyphs,
geometry, numbers, and text. A single image semantic describes all six strings
and any barre as a useful reading sequence rather than exposing meaningless
controls.

Phone layouts stack diagram and fingering; wider layouts place diagram and
details side-by-side inside the shared 1200-pixel content bound. Root and shape
choices wrap, content scrolls, and widget coverage exercises 360, 412, 600, 900,
and 1280 logical-pixel widths plus 2× text.

## Validation gate

Before completion:

- run `dart format .` and verify formatting;
- run `flutter gen-l10n`;
- run `flutter analyze`;
- run the full `flutter test` suite;
- build an Android debug APK;
- inspect an attached Android device and perform physical Chord Library UI
  checks when available.

## Current validation status

- Baseline `flutter analyze`: passed with no issues.
- Baseline full `flutter test`: passed, 263 tests.
- Final `dart format .`: 113 files checked, no changes required.
- Formatting verification with `--set-exit-if-changed`: passed.
- `flutter gen-l10n`: passed for English and Turkish sources.
- Final `flutter analyze`: passed with no issues.
- Final full `flutter test`: passed, 298 tests.
- All 162 checked-in guitar shapes passed aggregate musical and structural
  validation.
- Android debug APK, including the existing native Oboe component, built
  successfully at `build/app/outputs/flutter-apk/app-debug.apk`.
- Physical Android validation passed on device `23021RAAEG` (Android 15/API
  35): dashboard opening and back navigation; Bb root selection; Bbm7 quality
  selection; formula-derived Bb-Db-F-Ab tones; diagram and complete semantic
  fingering; movable E/A alternative browsing; scrolling; dark theme; and 1.5×
  system text. The original system font scale and app theme preference were
  restored after the checks.
- An immediate hierarchy probe during the first post-install bootstrap briefly
  observed the application's friendly error surface. No Flutter exception was
  present in the process log; a clean restart and three subsequent five-second
  fresh-start checks all reached the dashboard without the error.

## Reuse plan

- Scale Library can reuse pitch identity, spelling, intervals, and diatonic tone
  construction while adding scale formulas.
- Interactive Fretboard can reuse pitch classes, standard-tuning pitch
  derivation, and structured string/fret concepts without importing Chord
  Library presentation.
- Interval Trainer can reuse `TheoryInterval` identity and metadata while
  keeping localized exercise copy and audio orchestration in its own feature.
- Ear Training can reuse interval and chord formula identities while keeping
  generated audio, answer state, progress, and persistence out of the core.

## Known limitations

- Double sharps/flats and a complete academic notation engine are intentionally
  out of scope.
- Chord search is exact syntax only and has no fuzzy matching or aliases beyond
  the explicitly supported suffix table.
- The shape collection is curated rather than exhaustive. Inversions, slash
  chords, altered dominants, custom tunings, left-handed diagrams, and arbitrary
  voicing generation are not implemented.
- Favorites are deferred until structured reference-tool persistence has a
  concrete cross-feature requirement.
- Extended guitar voicings may omit optional chord members, as real six-string
  arrangements commonly do; validation rejects foreign notes and missing roots
  rather than requiring every formula member.
