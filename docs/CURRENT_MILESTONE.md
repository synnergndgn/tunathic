# Current Milestone: Phase 3B — Scale Library

Phase 3B extends Tunathic's reusable pure Dart music-theory core with structural
scale formulas and ships Scale Library as the second offline reference tool.
The validated Guitar Tuner, BPM Tap, native Oboe Metronome, and Phase 3A Chord
Library remain behaviorally unchanged.

## Authorized scope

- Pure Dart scale degrees, formulas, construction, aliases, relative-key
  relationships, and modal parent-major relationships.
- A localized, accessible, responsive Scale Library with 12-root browsing,
  categorized scale selection, exact local search, notes, degree formulas,
  aliases, and relevant relationships.
- A focused reusable pitch-class selector shared by Chord Library and Scale
  Library without moving feature state or music logic into widgets.
- English and Turkish localization, deterministic unit/widget coverage,
  documentation, an Android debug build, and physical UI validation when a
  device is available.

Interactive Fretboard, scale-position diagrams, audio playback, Interval
Trainer, Ear Training, Circle of Fifths, favorites, accounts, networking,
analytics, advertising, and backend work are outside this milestone.

## Scale domain

`lib/core/music_theory/scale.dart` remains Flutter-, state-, storage-, audio-,
platform-, and localization-independent.

### Structural degrees

`ScaleDegree` stores a stable structural identity, display symbol, semitone
distance, and diatonic letter distance. Enharmonically equal degrees are not
collapsed: `#4` and `b5` both span six semitones but retain different diatonic
steps. Scale spelling therefore follows the formula rather than being inferred
from semitone distance alone.

### Formula coverage

`ScaleDefinition` stores a stable ID, category, ordered structural degrees,
aliases, and optional major-mode degree. Current unique formulas cover:

- Major, with Ionian as an alias.
- Natural Minor, with Aeolian as an alias.
- Harmonic Minor.
- Ascending Melodic Minor.
- Dorian, Phrygian, Lydian, Mixolydian, and Locrian.
- Major Pentatonic, Minor Pentatonic, and Blues.

Ionian does not duplicate Major data, and Aeolian does not duplicate Natural
Minor data. Their stable alias metadata resolves to the same definitions.
Additional exotic and synthetic scales are intentionally deferred until they
have a product use.

### Construction and spelling

`ScaleConstructor` walks each definition's ordered degrees and delegates every
tone to Phase 3A `NoteSpelling`. Pitch-class arithmetic remains modulo 12 while
the degree supplies the intended diatonic letter. This produces examples such
as:

- C Major: C D E F G A B
- F Major: F G A Bb C D E
- Bb Major: Bb C D Eb F G A
- B Major: B C# D# E F# G# A#
- F# Natural Minor: F# G# A B C# D E
- E Blues: E G A Bb B D

The pragmatic Phase 3A notation boundary still supports naturals, single
sharps, and single flats. A result that would require a double accidental falls
back to a readable single-accidental enharmonic spelling.

### Relationships

`ScaleRelationships` derives relative keys and modal parents from pitch and
diatonic offsets:

- a major root yields its relative natural-minor root;
- a natural-minor root yields its relative-major root;
- a mode with explicit `modeDegree` yields its parent-major root.

For example, A Natural Minor relates to C Major, while D Dorian is degree 2 of
C Major. These are computed relationships, not localized prose or root-specific
tables.

## Scale Library interface

The dashboard exposes `/tools/scale-library` as an available offline tool. One
scrollable screen supports:

- all 12 pitch classes through wrapping minimum-size root chips;
- practical dual enharmonic labels such as `Db / C#`, `F# / Gb`, and
  `Bb / A#`;
- 12 unique scale definitions ordered into Major/Minor, Modes, and
  Pentatonic/Blues categories;
- formula-derived note names and visible structural degree tokens;
- localized category names and Ionian/Aeolian alias metadata;
- relative major/minor or parent-major/mode-degree relationships when relevant;
- exact local English or Turkish searches such as `C major`, `F# minor`,
  `D Dorian`, `C majör`, and `D doryen`;
- explicit rejection of fuzzy, incomplete, and unsupported searches.

Exact search preserves the entered root spelling. Selector roots use a pragmatic
default spelling, while the chip label exposes the common alternative. Musical
note symbols and degree symbols remain standard notation rather than being
translated.

The summary uses wrapping tokens rather than a fixed text row, so notes and
formulas remain readable at large text. At wider widths, browsing controls and
detail groups use parallel columns inside the shared 1200-pixel content bound;
phone layouts stack them. One combined semantic summary announces the scale
name, ordered notes, and spoken localized degree formula.

## Shared reference UI

`lib/shared/widgets/pitch_class_selector.dart` owns only the repeated labeled,
wrapping `ChoiceChip` presentation. Each feature provides its own choices,
labels, selected spelling, and state transition. Chord Library keeps its
existing mixed spellings and keys; Scale Library supplies dual enharmonic
labels. Chord construction, guitar shapes, search, and diagram behavior remain
feature-owned.

## Tests

Pure tests cover structural degree identity, all required formulas, aliases,
construction from every definition and all 12 pitch identities, sharp and flat
keys, relative keys, modal parent roots, pentatonic and blues formulas, and the
requested C/F/Bb/B Major, F# Minor, A Minor Pentatonic, E Blues, D Dorian,
E Phrygian, F Lydian, G Mixolydian, and B Locrian examples.

Parser tests cover English and Turkish supported vocabulary, accidentals,
Ionian/Aeolian aliases, and rejection of fuzzy, incomplete, or unsupported
syntax.

Widget tests cover dashboard opening, root and scale selection, note/formula
updates, modal and relative relationships, exact search and rejection,
English/Turkish, light/dark themes, combined semantics, 2× text, and 360, 412,
600, 900, and 1280 logical-pixel widths. The full pre-existing suite remains
the regression gate for Tuner, Metronome, BPM Tap, Settings, About, Privacy,
localization, preferences, and Chord Library.

## Validation gate

Before completion:

- run `dart format .` and formatting verification;
- run `flutter gen-l10n`;
- run `flutter analyze`;
- run the full `flutter test` suite;
- build an Android debug APK;
- inspect an attached Android device and perform Scale Library UI checks when
  available.

Final automated and physical validation results are recorded in the completion
report and this document before the milestone commit.

## Current validation status

- Baseline `flutter analyze`: passed with no issues.
- Baseline full `flutter test`: passed, 298 tests.
- Final `dart format .`: 121 files formatted; the immediate verification pass
  reported zero changes.
- `flutter gen-l10n`: passed for English and Turkish sources.
- Final `flutter analyze`: passed with no issues.
- Final full `flutter test`: passed, 322 tests.
- Focused Chord Library and dashboard regressions passed after extracting the
  shared selector.
- Android debug APK, including the existing native Oboe component, built
  successfully at `build/app/outputs/flutter-apk/app-debug.apk`.
- The first APK attempt encountered read-only flags in Gradle's generated
  `mergeDebugAssets` directory. Clearing those flags in that exact generated
  path allowed an unchanged rebuild to pass.
- Physical Android validation was not performed because neither Flutter nor ADB
  detected an attached Android device or emulator. No microphone validation is
  required for this milestone.

## Reuse plan

- Interactive Fretboard can consume `ConstructedScale.pitchClasses`,
  structural degrees, and standard-tuning pitch derivation while keeping
  fretboard interaction and layout in its own feature.
- Interval Trainer can consume `TheoryInterval` and the semitone/diatonic
  metadata represented by scale degrees without importing Scale Library UI.
- Ear Training can consume pitch classes, intervals, chord formulas, and scale
  definitions while keeping audio generation, answer state, and progress
  outside the core.
- Circle of Fifths can consume relative-key helpers and pitch spelling while
  owning its own harmonic navigation model.

## Known limitations

- Melodic Minor currently represents the ascending form only.
- Double sharps/flats and a complete academic notation engine remain out of
  scope.
- The library intentionally excludes whole-tone, diminished, bebop, altered,
  regional, and other synthetic scale catalogs.
- Search is exact and offline; it does not accept localized solfège root names,
  fuzzy descriptions, or unsupported scales.
- No fretboard positions, fingering patterns, playback, favorites, or custom
  scale creation are included.
