import 'interval_identity.dart';

enum NoteLetter { c, d, e, f, g, a, b }

enum NoteAccidental { flat, natural, sharp }

enum IntervalDirection {
  ascending(1),
  descending(-1);

  const IntervalDirection(this.sign);

  final int sign;
}

enum IntervalDirectionPreference {
  ascending,
  descending,
  mixed;

  List<IntervalDirection> get choices => switch (this) {
    IntervalDirectionPreference.ascending => const [
      IntervalDirection.ascending,
    ],
    IntervalDirectionPreference.descending => const [
      IntervalDirection.descending,
    ],
    IntervalDirectionPreference.mixed => IntervalDirection.values,
  };
}

/// A single-accidental spelling used by visual interval exercises.
///
/// The trainer intentionally excludes double accidentals. Construction returns
/// null whenever an interval would require one, instead of changing its
/// structural interval identity to an enharmonic simplification.
final class SpelledNote {
  const SpelledNote(this.letter, [this.accidental = NoteAccidental.natural]);

  final NoteLetter letter;
  final NoteAccidental accidental;

  String get display =>
      '${_letterNames[letter.index]}${switch (accidental) {
        NoteAccidental.flat => 'b',
        NoteAccidental.natural => '',
        NoteAccidental.sharp => '#',
      }}';

  int get pitchClass =>
      (_naturalPitchClasses[letter.index] +
              switch (accidental) {
                NoteAccidental.flat => -1,
                NoteAccidental.natural => 0,
                NoteAccidental.sharp => 1,
              })
          .modulo(12);

  static const naturalNotes = [
    SpelledNote(NoteLetter.c),
    SpelledNote(NoteLetter.d),
    SpelledNote(NoteLetter.e),
    SpelledNote(NoteLetter.f),
    SpelledNote(NoteLetter.g),
    SpelledNote(NoteLetter.a),
    SpelledNote(NoteLetter.b),
  ];

  static const singleAccidentalNotes = [
    ...naturalNotes,
    SpelledNote(NoteLetter.c, NoteAccidental.sharp),
    SpelledNote(NoteLetter.d, NoteAccidental.flat),
    SpelledNote(NoteLetter.d, NoteAccidental.sharp),
    SpelledNote(NoteLetter.e, NoteAccidental.flat),
    SpelledNote(NoteLetter.f, NoteAccidental.sharp),
    SpelledNote(NoteLetter.g, NoteAccidental.flat),
    SpelledNote(NoteLetter.g, NoteAccidental.sharp),
    SpelledNote(NoteLetter.a, NoteAccidental.flat),
    SpelledNote(NoteLetter.a, NoteAccidental.sharp),
    SpelledNote(NoteLetter.b, NoteAccidental.flat),
  ];

  static SpelledNote? constructInterval(
    SpelledNote root,
    IntervalIdentity interval,
    IntervalDirection direction,
  ) {
    final targetLetterIndex =
        (root.letter.index + direction.sign * (interval.diatonicNumber - 1))
            .modulo(NoteLetter.values.length);
    final targetPitchClass =
        (root.pitchClass + direction.sign * interval.semitones).modulo(12);
    final naturalPitchClass = _naturalPitchClasses[targetLetterIndex];
    final difference = (targetPitchClass - naturalPitchClass).modulo(12);
    final accidental = switch (difference) {
      0 => NoteAccidental.natural,
      1 => NoteAccidental.sharp,
      11 => NoteAccidental.flat,
      _ => null,
    };
    if (accidental == null) return null;
    return SpelledNote(NoteLetter.values[targetLetterIndex], accidental);
  }

  @override
  bool operator ==(Object other) =>
      other is SpelledNote &&
      other.letter == letter &&
      other.accidental == accidental;

  @override
  int get hashCode => Object.hash(letter, accidental);

  @override
  String toString() => display;
}

const _letterNames = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
const _naturalPitchClasses = [0, 2, 4, 5, 7, 9, 11];

extension on int {
  int modulo(int divisor) {
    final result = this % divisor;
    return result < 0 ? result + divisor : result;
  }
}
