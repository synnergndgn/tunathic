import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';

void main() {
  group('standard tuning', () {
    test('represents all six open strings low to high', () {
      final strings = GuitarTuning.standard.strings;

      expect(strings.map((string) => string.label), [
        'E2',
        'A2',
        'D3',
        'G3',
        'B3',
        'E4',
      ]);
      expect(strings.map((string) => string.openMidiNote), [
        40,
        45,
        50,
        55,
        59,
        64,
      ]);
      expect(strings.map((string) => string.openPitch.pitchClass), [
        PitchClass.e,
        PitchClass.a,
        PitchClass.d,
        PitchClass.g,
        PitchClass.b,
        PitchClass.e,
      ]);
    });

    test('derives semitone, octave, and MIDI progression', () {
      final lowE = GuitarTuning.standard.strings.first;

      expect(lowE.noteAt(0).midiNote, 40);
      expect(lowE.noteAt(1).pitchClass, PitchClass.f);
      expect(lowE.noteAt(11).octave, 3);
      expect(lowE.noteAt(12).pitchClass, lowE.openPitch.pitchClass);
      expect(lowE.noteAt(12).octave, 3);
      expect(lowE.noteAt(12).midiNote, 52);
      expect(lowE.noteAt(24).pitchClass, lowE.openPitch.pitchClass);
      expect(lowE.noteAt(24).octave, 4);
      expect(lowE.noteAt(24).midiNote, 64);
    });

    test('validates the supported open-through-24 range', () {
      final string = GuitarTuning.standard.strings.first;
      expect(() => string.noteAt(-1), throwsRangeError);
      expect(() => string.noteAt(25), throwsRangeError);
      expect(
        () => const GuitarFretboard().project(
          projection: FretboardProjection.chord(
            root: _pitch('C'),
            quality: ChordQuality.major,
          ),
          maximumFret: 25,
        ),
        throwsRangeError,
      );
    });
  });

  group('chord projection', () {
    final examples = <String, (ChordQuality, Set<String>)>{
      'C': (ChordQuality.major, {'C', 'E', 'G'}),
      'A': (ChordQuality.minor, {'A', 'C', 'E'}),
      'G': (ChordQuality.dominantSeventh, {'G', 'B', 'D', 'F'}),
      'F#': (ChordQuality.minorSeventh, {'F#', 'A', 'C#', 'E'}),
      'Bb': (ChordQuality.major, {'Bb', 'D', 'F'}),
      'C diminished': (ChordQuality.diminished, {'C', 'Eb', 'Gb'}),
    };

    for (final entry in examples.entries) {
      test('${entry.key} highlights exactly its chord-tone identities', () {
        final rootText = entry.key == 'C diminished' ? 'C' : entry.key;
        final projection = FretboardProjection.chord(
          root: _pitch(rootText),
          quality: entry.value.$1,
        );

        expect(
          projection.relations.values
              .map((relation) => relation.pitch.symbol)
              .toSet(),
          entry.value.$2,
        );
        expect(
          projection.relations[projection.root.pitchClass]!.isRoot,
          isTrue,
        );
      });
    }

    test('membership and root marking repeat across the neck', () {
      final positions = const GuitarFretboard().project(
        projection: FretboardProjection.chord(
          root: _pitch('C'),
          quality: ChordQuality.major,
        ),
        maximumFret: 12,
      );

      expect(_at(positions, string: 1, fret: 3).isRoot, isTrue);
      expect(_at(positions, string: 0, fret: 8).isRoot, isTrue);
      expect(_at(positions, string: 0, fret: 0).isMember, isTrue);
      expect(_at(positions, string: 0, fret: 1).isMember, isFalse);
      expect(_at(positions, string: 0, fret: 0).relationshipSymbol, '3');
    });
  });

  group('scale projection', () {
    final examples = <String, (ScaleDefinition, List<String>)>{
      'C': (ScaleDefinition.major, ['C', 'D', 'E', 'F', 'G', 'A', 'B']),
      'A': (ScaleDefinition.naturalMinor, ['A', 'B', 'C', 'D', 'E', 'F', 'G']),
      'A pentatonic': (
        ScaleDefinition.minorPentatonic,
        ['A', 'C', 'D', 'E', 'G'],
      ),
      'E': (ScaleDefinition.blues, ['E', 'G', 'A', 'Bb', 'B', 'D']),
      'D': (ScaleDefinition.dorian, ['D', 'E', 'F', 'G', 'A', 'B', 'C']),
      'F': (ScaleDefinition.lydian, ['F', 'G', 'A', 'B', 'C', 'D', 'E']),
    };

    for (final entry in examples.entries) {
      test('${entry.key} preserves formula spelling and degrees', () {
        final rootText = entry.key == 'A pentatonic' ? 'A' : entry.key;
        final projection = FretboardProjection.scale(
          root: _pitch(rootText),
          definition: entry.value.$1,
        );

        expect(
          projection.relations.values.map((relation) => relation.pitch.symbol),
          entry.value.$2,
        );
        expect(
          projection.relations.values.map((relation) => relation.symbol),
          entry.value.$1.degrees.map((degree) => degree.symbol),
        );
        expect(
          projection.relations[_pitch(rootText).pitchClass]!.isRoot,
          isTrue,
        );
      });
    }

    test('degree mapping is structural and excludes non-members', () {
      final positions = const GuitarFretboard().project(
        projection: FretboardProjection.scale(
          root: _pitch('A'),
          definition: ScaleDefinition.minorPentatonic,
        ),
        maximumFret: 12,
      );

      expect(_at(positions, string: 0, fret: 5).isRoot, isTrue);
      expect(_at(positions, string: 0, fret: 8).relationshipSymbol, 'b3');
      expect(_at(positions, string: 0, fret: 6).isMember, isFalse);
    });
  });

  test('enharmonic roots retain practical contextual spelling', () {
    for (final root in ['F#', 'Gb', 'Bb', 'Eb', 'C#']) {
      final projection = FretboardProjection.scale(
        root: _pitch(root),
        definition: ScaleDefinition.major,
      );
      expect(
        projection.relations[projection.root.pitchClass]!.pitch.symbol,
        root,
      );
    }
  });

  test('chord interval labels retain compound and altered identities', () {
    expect(chordDegreeSymbol(TheoryInterval.minorThird), 'b3');
    expect(chordDegreeSymbol(TheoryInterval.diminishedFifth), 'b5');
    expect(chordDegreeSymbol(TheoryInterval.majorNinth), '9');
    expect(chordDegreeSymbol(TheoryInterval.perfectEleventh), '11');
    expect(chordDegreeSymbol(TheoryInterval.majorThirteenth), '13');
  });
}

SpelledPitchClass _pitch(String symbol) => SpelledPitchClass.tryParse(symbol)!;

FretPosition _at(
  List<FretPosition> positions, {
  required int string,
  required int fret,
}) => positions.singleWhere(
  (position) => position.stringIndex == string && position.fret == fret,
);
