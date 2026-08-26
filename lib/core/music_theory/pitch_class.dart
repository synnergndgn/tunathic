enum Accidental {
  flat('b', -1),
  natural('', 0),
  sharp('#', 1);

  const Accidental(this.symbol, this.semitoneOffset);

  final String symbol;
  final int semitoneOffset;
}

enum NoteLetter {
  c('C', 0),
  d('D', 2),
  e('E', 4),
  f('F', 5),
  g('G', 7),
  a('A', 9),
  b('B', 11);

  const NoteLetter(this.symbol, this.naturalSemitone);

  final String symbol;
  final int naturalSemitone;

  NoteLetter transposeBySteps(int steps) =>
      values[_positiveModulo(index + steps, values.length)];
}

enum PitchClass {
  c(0),
  cSharpDFlat(1),
  d(2),
  dSharpEFlat(3),
  e(4),
  f(5),
  fSharpGFlat(6),
  g(7),
  gSharpAFlat(8),
  a(9),
  aSharpBFlat(10),
  b(11);

  const PitchClass(this.semitonesFromC);

  final int semitonesFromC;

  PitchClass transpose(int semitones) =>
      fromSemitones(semitonesFromC + semitones);

  static PitchClass fromSemitones(int semitones) =>
      values[_positiveModulo(semitones, values.length)];
}

enum SpellingPreference { contextual, sharps, flats }

final class SpelledPitchClass {
  const SpelledPitchClass({required this.letter, required this.accidental});

  final NoteLetter letter;
  final Accidental accidental;

  PitchClass get pitchClass => PitchClass.fromSemitones(
    letter.naturalSemitone + accidental.semitoneOffset,
  );

  String get symbol => '${letter.symbol}${accidental.symbol}';

  static SpelledPitchClass? tryParse(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 2) return null;

    NoteLetter? letter;
    final letterText = normalized[0].toUpperCase();
    for (final candidate in NoteLetter.values) {
      if (candidate.symbol == letterText) {
        letter = candidate;
        break;
      }
    }
    if (letter == null) return null;

    final accidental = switch (normalized.length == 1
        ? ''
        : normalized.substring(1)) {
      '' => Accidental.natural,
      '#' || '♯' => Accidental.sharp,
      'b' || '♭' => Accidental.flat,
      _ => null,
    };
    if (accidental == null) return null;
    return SpelledPitchClass(letter: letter, accidental: accidental);
  }

  @override
  bool operator ==(Object other) =>
      other is SpelledPitchClass &&
      letter == other.letter &&
      accidental == other.accidental;

  @override
  int get hashCode => Object.hash(letter, accidental);

  @override
  String toString() => symbol;
}

abstract final class NoteSpelling {
  static const _sharpSpellings = [
    SpelledPitchClass(letter: NoteLetter.c, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.c, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.d, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.d, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.e, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.f, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.f, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.g, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.g, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.a, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.a, accidental: Accidental.sharp),
    SpelledPitchClass(letter: NoteLetter.b, accidental: Accidental.natural),
  ];

  static const _flatSpellings = [
    SpelledPitchClass(letter: NoteLetter.c, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.d, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.d, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.e, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.e, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.f, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.g, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.g, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.a, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.a, accidental: Accidental.natural),
    SpelledPitchClass(letter: NoteLetter.b, accidental: Accidental.flat),
    SpelledPitchClass(letter: NoteLetter.b, accidental: Accidental.natural),
  ];

  /// A pragmatic single-spelling chromatic selector for browsing controls.
  ///
  /// Diatonic construction uses [spellInterval] instead, so an F-major scale
  /// can contain Bb even when the root was selected from this mixed list.
  static SpelledPitchClass forPitchClass(
    PitchClass pitchClass, {
    SpellingPreference preference = SpellingPreference.contextual,
  }) {
    final effectivePreference = preference == SpellingPreference.contextual
        ? _contextualPreference(pitchClass)
        : preference;
    return switch (effectivePreference) {
      SpellingPreference.flats => _flatSpellings[pitchClass.semitonesFromC],
      SpellingPreference.sharps || SpellingPreference.contextual =>
        _sharpSpellings[pitchClass.semitonesFromC],
    };
  }

  /// Spells a transposed pitch on the expected diatonic letter.
  ///
  /// Common single-accidental spellings are preferred. When an interval would
  /// require a double accidental, the method falls back to a chromatic spelling
  /// selected by [preference].
  static SpelledPitchClass spellInterval({
    required SpelledPitchClass root,
    required int semitones,
    required int diatonicSteps,
    SpellingPreference preference = SpellingPreference.contextual,
  }) {
    final target = root.pitchClass.transpose(semitones);
    final letter = root.letter.transposeBySteps(diatonicSteps);
    final difference = _signedPitchDifference(
      target.semitonesFromC,
      letter.naturalSemitone,
    );
    final accidental = switch (difference) {
      -1 => Accidental.flat,
      0 => Accidental.natural,
      1 => Accidental.sharp,
      _ => null,
    };
    if (accidental != null) {
      return SpelledPitchClass(letter: letter, accidental: accidental);
    }

    final fallbackPreference = preference == SpellingPreference.contextual
        ? (root.accidental == Accidental.flat
              ? SpellingPreference.flats
              : SpellingPreference.sharps)
        : preference;
    return forPitchClass(target, preference: fallbackPreference);
  }

  static SpellingPreference _contextualPreference(PitchClass pitchClass) =>
      switch (pitchClass) {
        PitchClass.dSharpEFlat ||
        PitchClass.gSharpAFlat ||
        PitchClass.aSharpBFlat => SpellingPreference.flats,
        _ => SpellingPreference.sharps,
      };
}

int _positiveModulo(int value, int modulus) =>
    ((value % modulus) + modulus) % modulus;

int _signedPitchDifference(int target, int natural) {
  final forward = _positiveModulo(target - natural, 12);
  return forward > 6 ? forward - 12 : forward;
}
