import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/core/music_theory/scale.dart';

enum KeyTonality { major, naturalMinor }

enum KeySignatureAccidental { none, sharp, flat }

final class KeySignature {
  const KeySignature({required this.fifths, required this.alteredNotes})
    : assert(fifths >= -7 && fifths <= 7);

  final int fifths;
  final List<SpelledPitchClass> alteredNotes;

  int get accidentalCount => fifths.abs();

  KeySignatureAccidental get accidental => switch (fifths) {
    > 0 => KeySignatureAccidental.sharp,
    < 0 => KeySignatureAccidental.flat,
    _ => KeySignatureAccidental.none,
  };

  String get identity => switch (accidental) {
    KeySignatureAccidental.none => 'natural',
    KeySignatureAccidental.sharp => 'sharps-$accidentalCount',
    KeySignatureAccidental.flat => 'flats-$accidentalCount',
  };
}

final class MusicalKey {
  const MusicalKey({
    required this.tonic,
    required this.tonality,
    this.preferredSpelling = SpellingPreference.contextual,
  });

  final SpelledPitchClass tonic;
  final KeyTonality tonality;
  final SpellingPreference preferredSpelling;

  ScaleDefinition get scaleDefinition => switch (tonality) {
    KeyTonality.major => ScaleDefinition.major,
    KeyTonality.naturalMinor => ScaleDefinition.naturalMinor,
  };

  KeySignature get keySignature => KeySignatures.forKey(this);

  MusicalKey get relativeKey => KeyRelationships.relative(this);

  MusicalKey? get parallelKey => KeyRelationships.parallel(this);

  @override
  bool operator ==(Object other) =>
      other is MusicalKey &&
      tonic == other.tonic &&
      tonality == other.tonality &&
      preferredSpelling == other.preferredSpelling;

  @override
  int get hashCode => Object.hash(tonic, tonality, preferredSpelling);
}

abstract final class KeySignatures {
  static const _sharpOrder = [
    SpelledPitchClass(letter: NoteLetter.f, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.c, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.g, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.d, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.a, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.e, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.b, accidental: Accidental.sharp),
  ];

  static const _flatOrder = [
    SpelledPitchClass(letter: NoteLetter.b, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.e, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.a, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.d, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.g, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.c, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.f, accidental: Accidental.flat),
  ];

  static const Map<String, int> _majorFifths = {
    'Cb': -7,
    'Gb': -6,
    'Db': -5,
    'Ab': -4,
    'Eb': -3,
    'Bb': -2,
    'F': -1,
    'C': 0,
    'G': 1,
    'D': 2,
    'A': 3,
    'E': 4,
    'B': 5,
    'F#': 6,
    'C#': 7,
  };

  static bool supports(MusicalKey key) {
    final majorTonic = _majorTonicFor(key);
    return _majorFifths.containsKey(majorTonic.symbol);
  }

  static KeySignature forKey(MusicalKey key) {
    final majorTonic = _majorTonicFor(key);
    final fifths = _majorFifths[majorTonic.symbol];
    if (fifths == null) {
      throw ArgumentError.value(
        key.tonic.symbol,
        'key',
        'The key requires a signature outside the supported -7 to +7 range.',
      );
    }
    final order = fifths >= 0 ? _sharpOrder : _flatOrder;
    return KeySignature(
      fifths: fifths,
      alteredNotes: List.unmodifiable(order.take(fifths.abs())),
    );
  }

  static SpelledPitchClass _majorTonicFor(MusicalKey key) =>
      key.tonality == KeyTonality.major
      ? key.tonic
      : ScaleRelationships.relativeMajor(key.tonic);
}

final class CirclePosition {
  const CirclePosition({
    required this.index,
    required this.major,
    required this.relativeMinor,
    this.alternateMajor,
    this.alternateRelativeMinor,
  });

  final int index;
  final MusicalKey major;
  final MusicalKey relativeMinor;
  final MusicalKey? alternateMajor;
  final MusicalKey? alternateRelativeMinor;

  Iterable<MusicalKey> get majorKeys sync* {
    yield major;
    if (alternateMajor case final alternate?) yield alternate;
  }

  Iterable<MusicalKey> get minorKeys sync* {
    yield relativeMinor;
    if (alternateRelativeMinor case final alternate?) yield alternate;
  }
}

abstract final class CircleOfFifths {
  static const positions = [
    CirclePosition(
      index: 0,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.c,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.a,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
      ),
    ),
    CirclePosition(
      index: 1,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.g,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.e,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
      ),
    ),
    CirclePosition(
      index: 2,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.d,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.b,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
      ),
    ),
    CirclePosition(
      index: 3,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.a,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.f,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.sharps,
      ),
    ),
    CirclePosition(
      index: 4,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.e,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.c,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.sharps,
      ),
    ),
    CirclePosition(
      index: 5,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.b,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.sharps,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.g,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.sharps,
      ),
    ),
    CirclePosition(
      index: 6,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.f,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.sharps,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.d,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.sharps,
      ),
      alternateMajor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.g,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.flats,
      ),
      alternateRelativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.e,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.flats,
      ),
    ),
    CirclePosition(
      index: 7,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.d,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.flats,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.b,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.flats,
      ),
      alternateMajor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.c,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.sharps,
      ),
      alternateRelativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.a,
          accidental: Accidental.sharp,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.sharps,
      ),
    ),
    CirclePosition(
      index: 8,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.a,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.flats,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.f,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.flats,
      ),
    ),
    CirclePosition(
      index: 9,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.e,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.flats,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.c,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.flats,
      ),
    ),
    CirclePosition(
      index: 10,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.b,
          accidental: Accidental.flat,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.flats,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.g,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.flats,
      ),
    ),
    CirclePosition(
      index: 11,
      major: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.f,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.major,
        preferredSpelling: SpellingPreference.flats,
      ),
      relativeMinor: MusicalKey(
        tonic: SpelledPitchClass(
          letter: NoteLetter.d,
          accidental: Accidental.natural,
        ),
        tonality: KeyTonality.naturalMinor,
        preferredSpelling: SpellingPreference.flats,
      ),
    ),
  ];

  static CirclePosition positionFor(MusicalKey key) {
    for (final position in positions) {
      final candidates = key.tonality == KeyTonality.major
          ? position.majorKeys
          : position.minorKeys;
      if (candidates.any(
        (candidate) => candidate.tonic.pitchClass == key.tonic.pitchClass,
      )) {
        return position;
      }
    }
    throw ArgumentError.value(key.tonic.symbol, 'key', 'Not on the circle');
  }

  static CirclePosition clockwiseFrom(CirclePosition position) =>
      positions[(position.index + 1) % positions.length];

  static CirclePosition counterClockwiseFrom(CirclePosition position) =>
      positions[(position.index - 1 + positions.length) % positions.length];

  static MusicalKey clockwiseNeighbor(MusicalKey key) {
    final position = clockwiseFrom(positionFor(key));
    return key.tonality == KeyTonality.major
        ? position.major
        : position.relativeMinor;
  }

  static MusicalKey counterClockwiseNeighbor(MusicalKey key) {
    final position = counterClockwiseFrom(positionFor(key));
    return key.tonality == KeyTonality.major
        ? position.major
        : position.relativeMinor;
  }
}

abstract final class KeyRelationships {
  static SpelledPitchClass perfectFifthAbove(SpelledPitchClass tonic) =>
      NoteSpelling.spellInterval(root: tonic, semitones: 7, diatonicSteps: 4);

  static SpelledPitchClass perfectFourthAbove(SpelledPitchClass tonic) =>
      NoteSpelling.spellInterval(root: tonic, semitones: 5, diatonicSteps: 3);

  static MusicalKey relative(MusicalKey key) => switch (key.tonality) {
    KeyTonality.major => MusicalKey(
      tonic: ScaleRelationships.relativeMinor(key.tonic),
      tonality: KeyTonality.naturalMinor,
      preferredSpelling: key.preferredSpelling,
    ),
    KeyTonality.naturalMinor => MusicalKey(
      tonic: ScaleRelationships.relativeMajor(key.tonic),
      tonality: KeyTonality.major,
      preferredSpelling: key.preferredSpelling,
    ),
  };

  static MusicalKey? parallel(MusicalKey key) {
    final parallel = MusicalKey(
      tonic: key.tonic,
      tonality: key.tonality == KeyTonality.major
          ? KeyTonality.naturalMinor
          : KeyTonality.major,
      preferredSpelling: key.preferredSpelling,
    );
    return KeySignatures.supports(parallel) ? parallel : null;
  }
}
