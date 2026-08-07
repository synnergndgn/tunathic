import 'package:tunathic/core/music_theory/music_theory.dart';

/// Reference roots used by the worked examples.
///
/// Lessons name a root rather than spelling one out, so an example always uses
/// a spelling the shared engine can build a correct scale or chord from.
abstract final class TheoryRoots {
  static const c = SpelledPitchClass(
    letter: NoteLetter.c,
    accidental: Accidental.natural,
  );
  static const d = SpelledPitchClass(
    letter: NoteLetter.d,
    accidental: Accidental.natural,
  );
  static const e = SpelledPitchClass(
    letter: NoteLetter.e,
    accidental: Accidental.natural,
  );
  static const f = SpelledPitchClass(
    letter: NoteLetter.f,
    accidental: Accidental.natural,
  );
  static const g = SpelledPitchClass(
    letter: NoteLetter.g,
    accidental: Accidental.natural,
  );
  static const a = SpelledPitchClass(
    letter: NoteLetter.a,
    accidental: Accidental.natural,
  );
  static const b = SpelledPitchClass(
    letter: NoteLetter.b,
    accidental: Accidental.natural,
  );
  static const bFlat = SpelledPitchClass(
    letter: NoteLetter.b,
    accidental: Accidental.flat,
  );
  static const eFlat = SpelledPitchClass(
    letter: NoteLetter.e,
    accidental: Accidental.flat,
  );
  static const aFlat = SpelledPitchClass(
    letter: NoteLetter.a,
    accidental: Accidental.flat,
  );
  static const dFlat = SpelledPitchClass(
    letter: NoteLetter.d,
    accidental: Accidental.flat,
  );
  static const fSharp = SpelledPitchClass(
    letter: NoteLetter.f,
    accidental: Accidental.sharp,
  );

  static const cMajorKey = MusicalKey(tonic: c, tonality: KeyTonality.major);
  static const gMajorKey = MusicalKey(tonic: g, tonality: KeyTonality.major);
  static const aMinorKey = MusicalKey(
    tonic: a,
    tonality: KeyTonality.naturalMinor,
  );
}
