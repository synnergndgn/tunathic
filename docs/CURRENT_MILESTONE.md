# Current Milestone: Phase 3C — Interactive Fretboard

Phase 3C adds a reusable, interactive standard-tuning guitar fretboard powered
by Tunathic's existing project-owned chord, scale, interval, pitch-class, and
spelling identities. The validated Guitar Tuner, BPM Tap, native Oboe
Metronome, Chord Library, and Scale Library remain behaviorally unchanged
except for safe navigation into the new reference tool.

## Authorized scope

- A pure Dart structural standard-tuning model covering open strings through
  fret 24, octave-aware notes, MIDI progression, chord/scale membership, root
  state, and structural interval/degree relationships.
- A project-owned Material 3 fretboard visualization with six strings, nut,
  fret numbers, common markers, root distinction, note/degree labels, and
  lightweight selected-position details.
- Chord and Scale modes, the shared pitch-class selector, existing localized
  definition names, 12/15/18/24-fret ranges, responsive horizontal scrolling,
  and offline deterministic updates.
- Dashboard access plus safe prefilled navigation from Chord Library and Scale
  Library.
- English and Turkish localization, accessibility summaries, deterministic
  unit/widget coverage, documentation, an Android debug build, and physical UI
  validation when a device is available.

CAGED overlays, interval-practice workflows, ear training, custom tuning UI,
left-handed orientation, chord-shape projection, audio, persistence, favorites,
accounts, networking, analytics, advertising, and backend work are outside this
milestone.

## Domain model

`lib/core/music_theory/fretboard.dart` is pure Dart. `GuitarTuning` owns a
structural list of six `GuitarStringTuning` values, ordered low to high.
Standard tuning is E2, A2, D3, G3, B3, E4 with MIDI notes 40, 45, 50, 55, 59,
and 64. Each fret is derived from the open MIDI note plus its fret offset; pitch
class and scientific-pitch octave are computed from that result. No visible
fret note table exists.

`FretboardProjection.chord` delegates construction to `ChordConstructor` and
maps every structural `TheoryInterval` to its chord-tone symbol. Compound and
altered identities remain explicit: examples include `b3`, `b5`, `b7`, `9`,
`11`, and `13`.

`FretboardProjection.scale` delegates construction to `ScaleConstructor` and
retains every `ScaleDegree.symbol`. Enharmonically equal relationships such as
`#4` and `b5` therefore stay distinct. `GuitarFretboard.project` synchronously
derives immutable positions with string, fret, octave, MIDI, pitch identity,
membership, root state, spelling, and relationship symbol.

## Interface

The dashboard exposes `/tools/interactive-fretboard`. Direct opening defaults
to C Major chord mode and 15 visible frets. Query parameters are parsed through
the project-owned `FretboardRouteState`; unknown mode, root, quality, or scale
values fall back safely.

The screen supports:

- switching between Chord and Scale without navigation;
- the shared 12-pitch-class selector with practical dual enharmonic labels;
- all currently supported chord qualities and scale definitions through their
  existing localized naming helpers;
- Note and Degrees / intervals display modes;
- 12, 15, 18, and 24 visible frets, always including the open strings;
- inline details after tapping a highlighted position; and
- immediate offline updates with no persistence, audio, or network work.

The project-owned `CustomPainter` renders six weighted strings, the nut, frets,
fret numbers, single markers at 3/5/7/9/15/17/19/21, and double markers at
12/24. It uses the common player-facing orientation: high E at the top and low E
at the bottom. Non-member notes are hidden. Roots use a square marker, strong
fill, double outline, and bold label while other members use circular markers,
so root identification does not depend on color.

Fret cells retain a readable fixed width. Narrow screens scroll the complete
neck horizontally; the fret numbers and neck share the same canvas and remain
synchronized. Wider screens lay the mode, label, and range controls in parallel
and keep content inside the existing 1200-pixel page bound.

## Library integration

Chord Library retains its curated fingering diagrams and adds **View on
Fretboard**, passing the current root and chord quality. The destination
projects pitch membership across the neck and does not imply one fingering.

Scale Library adds the equivalent action, passing the current root and
project-owned `ScaleDefinition`. Neither integration duplicates chord, scale,
shape, or search data.

## Accessibility and localization

All new text is sourced from English and Turkish ARB files; notation symbols
remain unchanged. The visual neck exposes one combined semantic summary such
as “A Minor Pentatonic fretboard, frets zero through 12. Root notes A
highlighted,” rather than hundreds of passive nodes. Tapping the canvas is a
real interaction and updates a live inline detail region with note and octave,
relationship, localized string name, and fret.

Controls use Material touch targets and wrapping/scrolling layouts. Tests cover
2× text, light/dark themes, and 360, 412, 600, 900, and 1280 logical pixels.

## Tests

Pure tests cover:

- all six open strings, tuning labels, MIDI values, semitone and octave
  progression, fret 12/24 equivalence, and range validation;
- C Major, A Minor, G7, F#m7, Bb Major, and diminished chord projection;
- C Major, A Natural Minor, A Minor Pentatonic, E Blues, D Dorian, and F
  Lydian scale projection;
- member/non-member behavior, root marking, structural labels, and F#, Gb, Bb,
  Eb, and C# contextual spelling; and
- direct, chord-prefilled, scale-prefilled, and malformed route state.

Widget tests cover dashboard opening, both modes, root and definition changes,
note/degree labels, 12/24 frets, horizontal scrolling, note details, both
library handoffs, EN/TR, light/dark themes, large text, requested widths, and
the combined semantics summary. The full existing suite remains the regression
gate for every validated feature.

## Validation status

- Baseline `flutter analyze`: passed with no issues.
- Baseline full `flutter test`: passed, 322 tests.
- Focused Phase 3C suite: passed, 37 tests.
- Final `dart format .`: 128 files checked with zero changes; the separate
  `--set-exit-if-changed` verification also reported zero changes.
- Final `flutter gen-l10n`: passed for English and Turkish.
- Final `flutter analyze`: passed with no issues.
- Final full `flutter test`: passed, 359 tests.
- Android debug APK built at
  `build/app/outputs/flutter-apk/app-debug.apk`. The first attempt encountered
  the repository's known read-only flags in Gradle's generated
  `mergeDebugAssets` directory; clearing those flags in that exact generated
  path allowed the unchanged retry to pass.
- Physical Android validation was not performed because `flutter devices`
  detected only Windows and Edge, with no attached Android device or emulator.
  The standalone `adb` executable was not available on PATH.

## Known limitations

- Standard EADGBE tuning only; the model accepts structural tunings but no
  custom-tuning UI is implemented.
- Right-handed/player-facing orientation only.
- Chord projection shows pitch membership, not shapes, inversions, omissions,
  duplicated-tone priorities, or playable voicings.
- Scale projection shows all member pitches, not boxes or position patterns.
- Non-members are intentionally hidden and no visibility toggle is included.
- No CAGED, interval-practice, ear-training, playback, persistence, favorites,
  custom scale/chord creation, or advanced voicing tools are implemented.

## Future reuse

The structural tuning and projected position types can support future CAGED
overlays, interval practice, ear-training references, and advanced voicing
tools without moving theory calculations into widgets. Those systems should
add their own feature state and datasets only when separately authorized.
