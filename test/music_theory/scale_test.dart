import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';

void main() {
  const c = SpelledPitchClass(
    letter: NoteLetter.c,
    accidental: Accidental.natural,
  );
  const f = SpelledPitchClass(
    letter: NoteLetter.f,
    accidental: Accidental.natural,
  );
  const a = SpelledPitchClass(
    letter: NoteLetter.a,
    accidental: Accidental.natural,
  );
  const bFlat = SpelledPitchClass(
    letter: NoteLetter.b,
    accidental: Accidental.flat,
  );
  const fSharp = SpelledPitchClass(
    letter: NoteLetter.f,
    accidental: Accidental.sharp,
  );

  test('scale degrees retain structural identity and chromatic distance', () {
    expect(ScaleDegree.sharpFourth.semitones, 6);
    expect(ScaleDegree.sharpFourth.diatonicSteps, 3);
    expect(ScaleDegree.flatFifth.semitones, 6);
    expect(ScaleDegree.flatFifth.diatonicSteps, 4);
    expect(ScaleDegree.sharpFourth, isNot(ScaleDegree.flatFifth));
  });

  test('required formulas and aliases are stable', () {
    expect(ScaleDefinition.major.formula, '1 2 3 4 5 6 7');
    expect(ScaleDefinition.naturalMinor.formula, '1 2 b3 4 5 b6 b7');
    expect(ScaleDefinition.harmonicMinor.formula, '1 2 b3 4 5 b6 7');
    expect(ScaleDefinition.melodicMinor.formula, '1 2 b3 4 5 6 7');
    expect(ScaleDefinition.majorPentatonic.formula, '1 2 3 5 6');
    expect(ScaleDefinition.minorPentatonic.formula, '1 b3 4 5 b7');
    expect(ScaleDefinition.blues.formula, '1 b3 4 b5 5 b7');
    expect(ScaleDefinition.fromIdOrAlias('ionian'), ScaleDefinition.major);
    expect(
      ScaleDefinition.fromIdOrAlias('aeolian'),
      ScaleDefinition.naturalMinor,
    );
    expect(ScaleDefinition.fromIdOrAlias('unknown'), isNull);
  });

  test('constructs common major keys with sensible spelling', () {
    expect(_tones(c, ScaleDefinition.major), 'C D E F G A B');
    expect(_tones(f, ScaleDefinition.major), 'F G A Bb C D E');
    expect(_tones(bFlat, ScaleDefinition.major), 'Bb C D Eb F G A');
    const b = SpelledPitchClass(
      letter: NoteLetter.b,
      accidental: Accidental.natural,
    );
    expect(_tones(b, ScaleDefinition.major), 'B C# D# E F# G# A#');
  });

  test('constructs minor, pentatonic, blues, and all requested modes', () {
    expect(_tones(fSharp, ScaleDefinition.naturalMinor), 'F# G# A B C# D E');
    expect(_tones(a, ScaleDefinition.minorPentatonic), 'A C D E G');
    const e = SpelledPitchClass(
      letter: NoteLetter.e,
      accidental: Accidental.natural,
    );
    const d = SpelledPitchClass(
      letter: NoteLetter.d,
      accidental: Accidental.natural,
    );
    const g = SpelledPitchClass(
      letter: NoteLetter.g,
      accidental: Accidental.natural,
    );
    const b = SpelledPitchClass(
      letter: NoteLetter.b,
      accidental: Accidental.natural,
    );
    expect(_tones(e, ScaleDefinition.blues), 'E G A Bb B D');
    expect(_tones(d, ScaleDefinition.dorian), 'D E F G A B C');
    expect(_tones(e, ScaleDefinition.phrygian), 'E F G A B C D');
    expect(_tones(f, ScaleDefinition.lydian), 'F G A B C D E');
    expect(_tones(g, ScaleDefinition.mixolydian), 'G A B C D E F');
    expect(_tones(b, ScaleDefinition.locrian), 'B C D E F G A');
  });

  test('all definitions construct from all 12 pitch identities', () {
    for (final pitchClass in PitchClass.values) {
      final root = NoteSpelling.forPitchClass(pitchClass);
      for (final definition in ScaleDefinition.values) {
        final scale = ScaleConstructor.construct(
          root: root,
          definition: definition,
        );
        expect(scale.tones.length, definition.degrees.length);
        expect(scale.tones.first.pitchClass, pitchClass);
        expect(scale.pitchClasses.length, definition.degrees.length);
      }
    }
  });

  test('relative major and minor relationships preserve musical spelling', () {
    expect(ScaleRelationships.relativeMinor(c).symbol, 'A');
    expect(ScaleRelationships.relativeMajor(a).symbol, 'C');
    const eFlat = SpelledPitchClass(
      letter: NoteLetter.e,
      accidental: Accidental.flat,
    );
    expect(ScaleRelationships.relativeMinor(eFlat).symbol, 'C');
    const cMinor = SpelledPitchClass(
      letter: NoteLetter.c,
      accidental: Accidental.natural,
    );
    expect(ScaleRelationships.relativeMajor(cMinor).symbol, 'Eb');
  });

  test('modal parent major and degree are explicit metadata', () {
    const d = SpelledPitchClass(
      letter: NoteLetter.d,
      accidental: Accidental.natural,
    );
    const g = SpelledPitchClass(
      letter: NoteLetter.g,
      accidental: Accidental.natural,
    );
    expect(
      ScaleRelationships.parentMajor(
        modeRoot: d,
        definition: ScaleDefinition.dorian,
      )?.symbol,
      'C',
    );
    expect(ScaleDefinition.dorian.modeDegree, 2);
    expect(
      ScaleRelationships.parentMajor(
        modeRoot: g,
        definition: ScaleDefinition.mixolydian,
      )?.symbol,
      'C',
    );
    expect(
      ScaleRelationships.parentMajor(
        modeRoot: c,
        definition: ScaleDefinition.harmonicMinor,
      ),
      isNull,
    );
  });
}

String _tones(SpelledPitchClass root, ScaleDefinition definition) =>
    ScaleConstructor.construct(
      root: root,
      definition: definition,
    ).tones.map((tone) => tone.symbol).join(' ');
