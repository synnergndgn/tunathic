import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';

void main() {
  group('ChordQuality', () {
    test('provides the authorized focused formula set', () {
      expect(ChordQuality.values, hasLength(22));
      expect(
        ChordQuality.values.map((quality) => quality.id).toSet(),
        hasLength(22),
      );
      for (final quality in ChordQuality.values) {
        expect(quality.formula.first, TheoryInterval.perfectUnison);
        expect(quality.symbol, isNotNull);
      }
    });

    test('triad and seventh formulas contain expected intervals', () {
      expect(_semitones(ChordQuality.major), orderedEquals([0, 4, 7]));
      expect(_semitones(ChordQuality.minor), orderedEquals([0, 3, 7]));
      expect(_semitones(ChordQuality.diminished), orderedEquals([0, 3, 6]));
      expect(_semitones(ChordQuality.augmented), orderedEquals([0, 4, 8]));
      expect(
        _semitones(ChordQuality.suspendedSecond),
        orderedEquals([0, 2, 7]),
      );
      expect(
        _semitones(ChordQuality.suspendedFourth),
        orderedEquals([0, 5, 7]),
      );
      expect(
        _semitones(ChordQuality.majorSeventh),
        orderedEquals([0, 4, 7, 11]),
      );
      expect(
        _semitones(ChordQuality.dominantSeventh),
        orderedEquals([0, 4, 7, 10]),
      );
      expect(
        _semitones(ChordQuality.minorSeventh),
        orderedEquals([0, 3, 7, 10]),
      );
      expect(
        _semitones(ChordQuality.minorMajorSeventh),
        orderedEquals([0, 3, 7, 11]),
      );
      expect(
        _semitones(ChordQuality.diminishedSeventh),
        orderedEquals([0, 3, 6, 9]),
      );
      expect(
        _semitones(ChordQuality.halfDiminishedSeventh),
        orderedEquals([0, 3, 6, 10]),
      );
    });

    test('extensions expose their characteristic compound intervals', () {
      expect(_semitones(ChordQuality.sixth), contains(9));
      expect(_semitones(ChordQuality.minorSixth), contains(9));
      expect(_semitones(ChordQuality.addNinth), contains(14));
      expect(_semitones(ChordQuality.minorAddNinth), contains(14));
      expect(_semitones(ChordQuality.dominantNinth), containsAll([10, 14]));
      expect(_semitones(ChordQuality.majorNinth), containsAll([11, 14]));
      expect(_semitones(ChordQuality.minorNinth), containsAll([3, 10, 14]));
      expect(_semitones(ChordQuality.eleventh), contains(17));
      expect(_semitones(ChordQuality.minorEleventh), containsAll([3, 17]));
      expect(_semitones(ChordQuality.thirteenth), contains(21));
    });
  });

  group('ChordConstructor', () {
    test('constructs common examples from interval formulas', () {
      expect(_chord('C', ChordQuality.major), ['C', 'E', 'G']);
      expect(_chord('D', ChordQuality.minor), ['D', 'F', 'A']);
      expect(_chord('G', ChordQuality.dominantSeventh), ['G', 'B', 'D', 'F']);
      expect(_chord('Bb', ChordQuality.major), ['Bb', 'D', 'F']);
      expect(_chord('F#', ChordQuality.minorSeventh), ['F#', 'A', 'C#', 'E']);
    });

    test('spells altered and suspended chord degrees structurally', () {
      expect(_chord('C', ChordQuality.diminished), ['C', 'Eb', 'Gb']);
      expect(_chord('C', ChordQuality.augmented), ['C', 'E', 'G#']);
      expect(_chord('D', ChordQuality.suspendedSecond), ['D', 'E', 'A']);
      expect(_chord('D', ChordQuality.suspendedFourth), ['D', 'G', 'A']);
    });

    test(
      'uses pragmatic fallbacks where double accidentals would be needed',
      () {
        expect(_chord('B', ChordQuality.major), ['B', 'D#', 'F#']);
        expect(_chord('B', ChordQuality.augmented), ['B', 'D#', 'G']);
        expect(_chord('E', ChordQuality.augmented), ['E', 'G#', 'B#']);
        expect(_chord('B', ChordQuality.suspendedSecond), ['B', 'C#', 'F#']);
        expect(_chord('E', ChordQuality.suspendedFourth), ['E', 'A', 'B']);
      },
    );

    test('keeps flat and sharp key spellings musically sensible', () {
      expect(_chord('F', ChordQuality.suspendedFourth), ['F', 'Bb', 'C']);
      expect(_chord('Eb', ChordQuality.majorSeventh), ['Eb', 'G', 'Bb', 'D']);
      expect(_chord('Ab', ChordQuality.minor), ['Ab', 'Cb', 'Eb']);
      expect(_chord('F#', ChordQuality.majorSeventh), ['F#', 'A#', 'C#', 'E#']);
    });

    test('constructs extended tones rather than hardcoded voicings', () {
      expect(_chord('C', ChordQuality.addNinth), ['C', 'E', 'G', 'D']);
      expect(_chord('C', ChordQuality.majorNinth), ['C', 'E', 'G', 'B', 'D']);
      expect(_chord('D', ChordQuality.minorEleventh), [
        'D',
        'F',
        'A',
        'C',
        'E',
        'G',
      ]);
      expect(_chord('G', ChordQuality.thirteenth), [
        'G',
        'B',
        'D',
        'F',
        'A',
        'E',
      ]);
    });
  });

  group('ChordSymbolParser', () {
    test('parses only supported exact chord syntax', () {
      expect(ChordSymbolParser.tryParse('C')?.quality, ChordQuality.major);
      expect(ChordSymbolParser.tryParse('Cm')?.quality, ChordQuality.minor);
      expect(
        ChordSymbolParser.tryParse('Cmaj7')?.quality,
        ChordQuality.majorSeventh,
      );
      expect(ChordSymbolParser.tryParse('F#m')?.root.symbol, 'F#');
      expect(
        ChordSymbolParser.tryParse('Bb7')?.quality,
        ChordQuality.dominantSeventh,
      );
      expect(
        ChordSymbolParser.tryParse('Dsus4')?.quality,
        ChordQuality.suspendedFourth,
      );
      expect(ChordSymbolParser.tryParse('C major'), isNull);
      expect(ChordSymbolParser.tryParse('C7alt'), isNull);
      expect(ChordSymbolParser.tryParse('H'), isNull);
    });
  });
}

List<int> _semitones(ChordQuality quality) =>
    quality.formula.map((interval) => interval.semitones).toList();

List<String> _chord(String root, ChordQuality quality) =>
    ChordConstructor.construct(
      root: SpelledPitchClass.tryParse(root)!,
      quality: quality,
    ).tones.map((tone) => tone.symbol).toList();
