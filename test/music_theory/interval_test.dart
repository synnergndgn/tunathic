import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/interval.dart';

void main() {
  test('required simple intervals expose semitones and labels', () {
    const expected = {
      TheoryInterval.perfectUnison: 0,
      TheoryInterval.minorSecond: 1,
      TheoryInterval.majorSecond: 2,
      TheoryInterval.minorThird: 3,
      TheoryInterval.majorThird: 4,
      TheoryInterval.perfectFourth: 5,
      TheoryInterval.augmentedFourth: 6,
      TheoryInterval.diminishedFifth: 6,
      TheoryInterval.perfectFifth: 7,
      TheoryInterval.minorSixth: 8,
      TheoryInterval.majorSixth: 9,
      TheoryInterval.minorSeventh: 10,
      TheoryInterval.majorSeventh: 11,
      TheoryInterval.octave: 12,
    };

    for (final entry in expected.entries) {
      expect(entry.key.semitones, entry.value);
      expect(entry.key.id, isNotEmpty);
      expect(entry.key.shortLabel, isNotEmpty);
    }
    expect(
      TheoryInterval.augmentedFourth.simpleSemitones,
      TheoryInterval.diminishedFifth.simpleSemitones,
    );
  });
}
