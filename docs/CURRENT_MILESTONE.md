# Current Milestone: Phase 3E — Chord Voicing Expansion & Coverage Completion

Phase 3E completes the major feature-development work planned before release
hardening and Google Play Closed Testing. It expands the existing offline Chord
Library without adding a new product tool. The validated Guitar Tuner, native
Oboe Metronome, BPM Tap, Scale Library, Interactive Fretboard, Circle of Fifths,
Settings, About, Privacy, navigation, and audio coordination remain
behaviorally unchanged.

## Authorized scope

- Deterministic development-time coverage auditing for every one of the 12
  pitch-class roots and every quality in the existing `ChordQuality` registry.
- Project-owned, structured guitar voicings that substantially complete
  practical fingering coverage.
- Explicit intentional-omission metadata, rooted-first policy, stronger musical
  and playability validation, duplicate detection, useful ordering, localized
  descriptors, accessibility details, regression tests, and documentation.
- No new chord taxonomy, audio, microphone, network, backend, analytics,
  advertising, fuzzy search, arbitrary runtime voicing generation, or new major
  product feature.

Interval Trainer, Ear Training, Chord Finder, Capo Calculator, practice
statistics, daily challenges, and other unfinished training tools remain future
work and display Coming Soon where already represented in the application.

## Final coverage

The source of truth remains the 22-value `ChordQuality` enum. Combined with all
12 pitch-class roots, it defines 264 supported root/quality combinations.

- Previous dataset: 162 validated shapes.
- Previous coverage: 80 of 264 combinations (30.30%).
- Final dataset: 402 validated shapes.
- Final coverage: 264 of 264 combinations (100.00%).
- Missing combinations: none.

`tool/chord_shape_coverage.dart` runs the deterministic audit and reports total
valid shapes, supported/covered/missing combinations, coverage percentage,
shape totals by quality, shape totals by family, and any missing combinations.
`GuitarShapeCoverageAudit` exposes the same information to automated tests,
including family availability, lowest diagram position, and whether alternatives
exist.

### Shapes by quality

| Quality | Shapes |
| --- | ---: |
| Major | 29 |
| Minor | 27 |
| Diminished | 13 |
| Augmented | 13 |
| Sus2 | 26 |
| Sus4 | 27 |
| Major 7 | 29 |
| Dominant 7 | 30 |
| Minor 7 | 27 |
| Minor major 7 | 12 |
| Diminished 7 | 12 |
| Half-diminished / m7b5 | 13 |
| 6 | 14 |
| Minor 6 | 14 |
| Add9 | 27 |
| Minor add9 | 12 |
| 9 | 14 |
| Major 9 | 12 |
| Minor 9 | 13 |
| 11 | 13 |
| Minor 11 | 12 |
| 13 | 13 |

### Shapes by family

| Family | Shapes |
| --- | ---: |
| Open position | 36 |
| Movable E family | 228 |
| Movable A family | 132 |
| Curated compact | 6 |

Open and compact shapes remain individually curated. Existing common E- and
A-family barres and the new extension templates are generated as structured
transpositions. Open strings are never blindly transposed. Every generated
shape retains project-owned source metadata, is marked as generated, and passes
the same validator as curated data. The final provenance split is 42 curated
shapes and 360 generated shapes.

## Voicing policy

Shapes prioritize correct pitch content, practical fretting, recognizable chord
identity, and useful positions. Major, Minor, Dominant 7, Major 7, Minor 7,
Sus2, Sus4, and Add9 have at least two alternatives for every root. Curated
open shapes sort first, followed by common E-family and A-family movable
voicings, then compact alternatives. Difficulty remains descriptive rather than
gamified.

The first public library remains rooted-first. Every shipped Phase 3E shape
contains its root; no rootless shape is needed to achieve coverage. The model
and validator retain explicit rootless support, and tests prove that a rootless
shape must declare the omitted root and contain every other required tone.

Intentional omissions are structural rather than implied. A normal four-or-more
tone chord may omit its perfect fifth. Eleventh and thirteenth voicings may also
omit the ninth where declared. The root may be omitted only by an explicitly
rootless shape. Thirds, sevenths, altered fifths, elevenths, and thirteenths
remain defining tones and cannot be silently discarded. The UI and diagram
semantics communicate declared omissions.

## Validation strategy

`GuitarShapeValidator` now checks:

- exactly six low-E-to-high-E string entries;
- fret bounds and agreement between muted/open/fretted state and fret value;
- finger range and consistent same-fret reuse;
- starting fret, five-fret diagram window, and maximum four-fret span;
- sounding pitch-class derivation from standard tuning;
- formula membership for every sounding note;
- every required chord tone;
- root presence unless explicitly rootless;
- omission membership, policy, uniqueness, and absence from the sounding set;
- barre fret, finger, range, and compatibility with covered strings;
- duplicate IDs and effectively duplicate root/quality fingerings.

Malformed data fails deterministic tests. The validator deliberately avoids a
biomechanical hand simulator; uncommon but valid four-fret stretches use
advanced difficulty metadata.

## Chord Library interface

The workflow remains root → quality → shapes. Shape chips use localized Open,
Movable E shape, Movable A shape, or Compact voicing descriptors plus position
where useful. The detail view subtly includes difficulty, starting fret,
per-string instructions, barres, intentional omissions, and rootless status.
The existing project-owned diagram continues to render open and mute markers,
finger dots, barres, and high positions in light and dark themes.

Exact search remains deliberately non-fuzzy and now has regressions for
`Ebmaj9`, `C#m7b5`, `Bb13`, `F#mMaj7`, `Ab9`, and `Dm11`. Standard chord
notation is not localized. English and Turkish localize new advanced-difficulty,
omission, and rootless descriptions.

Per-string semantics continue to describe muted, open, and fretted strings with
finger numbers. Barre ranges, declared omissions, and rootless status are
included in nonvisual descriptions.

## Tests

Coverage tests exercise all 264 combinations, aggregate calculation, shape
totals by quality and family, position/family reporting, complete final
coverage, alternatives for common qualities, and representative everyday and
extended chords.

Validator tests cover rooted shapes, declared omissions, explicit rootless
voicings, foreign notes, missing defining tones, malformed barres, invalid
fingers, excessive spans, invalid string count, invalid omission metadata,
duplicate IDs, and effectively duplicate fingerings.

Widget and parser tests cover opening and browsing, multiple shapes, extended
exact searches, high-position and barre rendering, omission visibility and
semantics, English/Turkish, light/dark themes, 2× text, and phone/tablet widths.
The full existing suite remains the regression gate for every other feature.

## Validation status

- Baseline `flutter analyze`: passed with no issues.
- Baseline full `flutter test`: passed, 413 tests.
- Deterministic coverage audit: 402 valid shapes, 264/264 combinations,
  100.00%, no missing combinations.
- Focused Phase 3E chord tests: passed.
- Final `dart format .`: 142 files checked; the separate
  `--set-exit-if-changed` verification reported zero changes.
- Final `flutter gen-l10n`: passed for English and Turkish.
- Final `flutter analyze`: passed with no issues.
- Final full `flutter test`: passed, 431 tests.
- Android debug APK built at
  `build/app/outputs/flutter-apk/app-debug.apk`. The first attempt encountered
  the repository's known stale read-only attributes in Gradle's generated
  `mergeDebugAssets` tree; clearing attributes only in that exact generated
  path allowed the unchanged retry to pass.
- Physical Android validation was not performed because `flutter devices`
  detected only Windows and Edge, with no attached Android device or emulator.

## Known limitations

- Shapes target standard six-string tuning and a right-handed/player-facing
  diagram. No left-handed transform, custom tuning, inversions, slash chords,
  altered dominants, favorites, playback, or arbitrary voicing generator is
  included.
- Movable voicings prioritize dependable pitch content and bounded diagram
  spans; difficulty metadata is deterministic guidance, not a promise that
  every hand will find a shape equally comfortable.
- Exact search has no fuzzy matching.
- Music spelling supports naturals, single sharps, and single flats rather than
  a complete double-accidental notation engine.
- Physical Android interaction validation depends on an attached device or
  emulator; automated widget coverage does not replace real-device inspection.
