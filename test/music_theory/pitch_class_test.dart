import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';

void main() {
  group('PitchClass', () {
    test('represents all twelve chromatic identities', () {
      expect(PitchClass.values, hasLength(12));
      expect(
        PitchClass.values.map((pitch) => pitch.semitonesFromC),
        orderedEquals(List.generate(12, (index) => index)),
      );
    });

    test('transposes with safe positive modulo twelve', () {
      expect(PitchClass.b.transpose(1), PitchClass.c);
      expect(PitchClass.c.transpose(-1), PitchClass.b);
      expect(PitchClass.e.transpose(13), PitchClass.f);
      expect(PitchClass.f.transpose(-25), PitchClass.e);
      expect(PitchClass.fromSemitones(120), PitchClass.c);
      expect(PitchClass.fromSemitones(-13), PitchClass.b);
    });

    test('enharmonic spellings share pitch-class identity', () {
      final cSharp = SpelledPitchClass.tryParse('C#')!;
      final dFlat = SpelledPitchClass.tryParse('Db')!;
      expect(cSharp, isNot(dFlat));
      expect(cSharp.pitchClass, dFlat.pitchClass);
      expect(cSharp.pitchClass, PitchClass.cSharpDFlat);
    });

    test('sharp and flat chromatic spellings are selectable', () {
      expect(
        NoteSpelling.forPitchClass(
          PitchClass.cSharpDFlat,
          preference: SpellingPreference.sharps,
        ).symbol,
        'C#',
      );
      expect(
        NoteSpelling.forPitchClass(
          PitchClass.cSharpDFlat,
          preference: SpellingPreference.flats,
        ).symbol,
        'Db',
      );
      expect(NoteSpelling.forPitchClass(PitchClass.aSharpBFlat).symbol, 'Bb');
      expect(NoteSpelling.forPitchClass(PitchClass.fSharpGFlat).symbol, 'F#');
    });

    test('parser accepts ASCII and musical accidental glyphs', () {
      expect(SpelledPitchClass.tryParse('f♯')?.symbol, 'F#');
      expect(SpelledPitchClass.tryParse('B♭')?.symbol, 'Bb');
      expect(SpelledPitchClass.tryParse('H'), isNull);
      expect(SpelledPitchClass.tryParse('C##'), isNull);
    });
  });
}
