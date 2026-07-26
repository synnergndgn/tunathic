# Current Milestone: Phase 3D — Circle of Fifths

Phase 3D adds an offline harmonic-reference tool built on Tunathic's
project-owned pitch, interval, chord, scale, and spelling identities. The
validated Guitar Tuner, BPM Tap, native Oboe Metronome, Chord Library, Scale
Library, and Interactive Fretboard remain behaviorally unchanged except for
safe prefilled navigation from the new tool.

## Authorized scope

- Pure Dart major-key and natural-minor-key identities, key signatures,
  Circle-of-Fifths positions and relationships, parallel/relative keys,
  scale-derived diatonic triads and seventh chords, and structural Roman
  numerals.
- A project-owned interactive outer-major/inner-minor circle with twelve
  positions, conventional orientation, selected/relative/neighbor cues, and a
  concise key detail panel.
- Prefilled navigation to Scale Library, Chord Library, and Interactive
  Fretboard without changing their direct-opening defaults.
- English and Turkish localization, accessible semantics and large-text
  fallback, responsive layouts, deterministic tests, documentation, and an
  Android debug build.

Progression recommendations, songwriting workflows, interval or ear-training
exercises, audio, playback, staff notation, persistence, favorites, accounts,
networking, analytics, advertising, and backend work are outside this
milestone.

## Key and signature domain

`lib/core/music_theory/key.dart` is pure Dart. `MusicalKey` owns a
`SpelledPitchClass` tonic, `KeyTonality` (major or natural minor), and spelling
preference. It exposes its scale definition, canonical key signature, relative
key, and representable parallel key without storing a localized display name.

`KeySignature` stores a signed circle-of-fifths count from -7 flats through +7
sharps and derives accidental type, count, structural identity, and ordered
altered notes. The standard sharp order is F-C-G-D-A-E-B; the flat order is
B-E-A-D-G-C-F. Natural-minor signatures are resolved through the existing
Phase 3B relative-major helper, so relatives share one signature rule rather
than a duplicated minor table. Keys outside the supported single-accidental
-7…+7 range report no parallel relationship.

The compact canonical major-signature lookup is intentionally keyed by spelled
tonic. Pitch identity remains modulo 12: F# and Gb are the same
`PitchClass`, while their `SpelledPitchClass` values retain the musically
meaningful six-sharp and six-flat signatures.

## Circle ordering and relationships

`CircleOfFifths.positions` owns twelve structural positions, beginning with C
at index zero and moving clockwise through G, D, A, E, B, F#/Gb, Db/C#, Ab,
Eb, Bb, and F. Clockwise movement transposes pitch identity by seven semitones;
counter-clockwise movement transposes by five. Both directions wrap
deterministically.

Each position aligns a major key with its natural-minor relative. F#/Gb and
Db/C# positions also retain alternate major and relative-minor spellings.
`KeyRelationships` derives perfect fifth, perfect fourth, relative, and
parallel relationships from existing spelling/scale primitives.
`CircleOfFifths` supplies deterministic clockwise-fifth and
counter-clockwise-fourth neighbors for both tonalities.

## Diatonic harmony and Roman numerals

`lib/core/music_theory/harmony.dart` constructs the selected major or natural
minor scale through `ScaleConstructor`. For each scale degree it stacks every
other scale tone to form a triad or seventh chord, classifies the resulting
structural semitone pattern, and delegates final chord construction and symbol
spelling to `ChordConstructor`. No per-key chord-name table exists.

The resulting major triads follow I/ii/iii/IV/V/vi/vii° and natural-minor
triads follow i/ii°/III/iv/v/VI/VII because those qualities emerge from the
actual scales. Seventh qualities likewise emerge from four stacked thirds,
including major seventh, dominant seventh, minor seventh, diminished seventh,
minor-major seventh, and half-diminished seventh when structurally present.

`RomanNumeral` retains degree, chord quality, and seventh state. Case,
diminished or half-diminished marker, and seventh suffix are generated
properties, making the model suitable for a later separately authorized
progression tool without reducing identity to display text.

## Interface and interaction

The dashboard exposes `/tools/circle-of-fifths`. Direct opening starts on C
Major. A `CustomPainter` draws the two rings, twelve sectors, selected sector,
neighbor sectors, boundaries, and center field. Flutter controls positioned
over that decoration provide the actual interaction and semantics.

The conventional orientation places C Major at 12 o'clock, G clockwise, and F
counter-clockwise. Rounded-square outer positions represent major keys and
circular inner positions represent relative minors. Selection adds a strong
outline and check marker; the relative key uses a distinct outline/link marker;
the fifth and fourth neighbors use directional markers. These states therefore
do not depend only on color.

Tapping either ring selects that key and immediately updates the center and
detail panel. F#/Gb and Db/C# use concise dual labels. An enharmonic action
switches the selected spelling while retaining one pitch-class position, so
the corresponding signature and scale spelling remain meaningful.

The detail panel shows the localized key name, optional enharmonic equivalent,
key-signature count and altered notes, relative and parallel keys, fifth and
fourth neighbors, scale notes, seven triads, and seven seventh chords. Relative
and neighboring key controls also select their destination. Each chord entry
shows Roman numeral and standard symbol and opens Chord Library when tapped.

**View Scale** opens Scale Library with the selected tonic and Major or Natural
Minor. **View on Fretboard** opens Interactive Fretboard in Scale mode with the
same state. Project-owned route-state parsers preserve the existing direct C
Major defaults and safely reject malformed query values.

## Accessibility, localization, and responsiveness

The visual circle exposes a combined summary naming selected, relative, fifth,
and fourth keys. Every interactive position has its own localized tap semantics.
Decorative painter lines are excluded. Key-signature semantics read count and
altered notes naturally; chord semantics include both Roman numeral and chord
symbol plus their navigation action.

All descriptive copy is generated from English and Turkish ARB sources.
Standard note, accidental, chord, and Roman-numeral notation is unchanged.

At 360, 412, and 600 logical pixels, the circle and details form a vertically
scrolling column. At 900 and 1280 pixels, they use a bounded two-column layout.
The normal circle is capped at 520 pixels so it does not stretch across wide
screens. At large text scaling where radial labels would become unreadable,
the same clockwise order becomes a vertically scrollable, fully labeled
major/minor control list instead of shrinking notation.

## Tests

Pure tests cover all twelve positions, both directions and wraparound,
relative/parallel/neighbor relationships, enharmonic identity, the standard
sharp/flat orders, required major and minor signatures, F#/Gb and C# boundary
signatures, required major and natural-minor triads, C/F major and A minor
seventh chords, half-diminished behavior, and Roman-numeral structure.

Route tests cover direct, malformed, scale-prefilled, and chord-prefilled
states. Widget tests cover dashboard opening, C Major defaults, major/minor and
relationship selection, signature/harmony updates, enharmonic switching, all
three deep links, English/Turkish, light/dark themes, 360/412/600/900/1280
widths, 2× text, combined circle semantics, key controls, signatures, and
chords. The full existing suite remains the regression gate.

## Validation status

- Baseline `flutter analyze`: passed with no issues.
- Baseline full `flutter test`: passed, 359 tests.
- Focused Phase 3D suite: passed, 54 tests.
- Final `dart format .`: 139 files checked with zero changes; the separate
  `--set-exit-if-changed` verification also reported zero changes.
- Final `flutter gen-l10n`: passed for English and Turkish.
- Final `flutter analyze`: passed with no issues.
- Final full `flutter test`: passed, 413 tests.
- Android debug APK built at
  `build/app/outputs/flutter-apk/app-debug.apk`. The first attempts encountered
  the repository's known read-only attributes in Gradle's generated
  `mergeDebugAssets` tree; clearing those attributes in that exact generated
  path allowed the unchanged retry to pass.
- Physical Android validation was not performed because `flutter devices`
  detected only Windows and Edge, with no attached Android device or emulator.

## Known limitations

- Major and natural-minor keys only; harmonic/melodic minor key behavior and
  modal key signatures are not modeled.
- Signatures are bounded to standard -7…+7 single-accidental keys. The existing
  spelling engine does not render double sharps or double flats.
- The circle uses practical enharmonic labels at two boundary positions rather
  than displaying every theoretical spelling.
- Diatonic harmony describes root-position pitch content, not voicings,
  inversions, substitutions, functional analysis, or recommended progressions.
- No staff notation, audio, interval exercise, ear training, persistence,
  favorites, history, custom keys, or progression authoring is included.

## Future reuse

The structural key, signature, circle, diatonic-chord, and Roman-numeral types
can support future progression, songwriting/reference, interval-training,
ear-training, and key-aware fretboard features. Those tools must add their own
feature state and behavior only when separately authorized; Phase 3D does not
mark them implemented.
