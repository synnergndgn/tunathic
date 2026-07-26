import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/key.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/core/music_theory/scale.dart';

final class RomanNumeral {
  const RomanNumeral({
    required this.degree,
    required this.quality,
    required this.isSeventh,
  }) : assert(degree >= 1 && degree <= 7);

  final int degree;
  final ChordQuality quality;
  final bool isSeventh;

  bool get isUppercase => switch (quality) {
    ChordQuality.major ||
    ChordQuality.augmented ||
    ChordQuality.majorSeventh ||
    ChordQuality.dominantSeventh => true,
    _ => false,
  };

  bool get isDiminished =>
      quality == ChordQuality.diminished ||
      quality == ChordQuality.diminishedSeventh;

  bool get isHalfDiminished => quality == ChordQuality.halfDiminishedSeventh;

  String get symbol {
    final base = _romanDegrees[degree - 1];
    final cased = isUppercase ? base : base.toLowerCase();
    final marker = isHalfDiminished
        ? 'ø'
        : isDiminished
        ? '°'
        : '';
    final suffix = !isSeventh
        ? ''
        : switch (quality) {
            ChordQuality.majorSeventh => 'maj7',
            ChordQuality.minorMajorSeventh => '(maj7)',
            _ => '7',
          };
    return '$cased$marker$suffix';
  }

  static const _romanDegrees = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
}

final class DiatonicChord {
  const DiatonicChord({
    required this.degree,
    required this.chord,
    required this.romanNumeral,
  });

  final int degree;
  final ConstructedChord chord;
  final RomanNumeral romanNumeral;
}

final class DiatonicHarmony {
  const DiatonicHarmony({
    required this.key,
    required this.scale,
    required this.triads,
    required this.seventhChords,
  });

  final MusicalKey key;
  final ConstructedScale scale;
  final List<DiatonicChord> triads;
  final List<DiatonicChord> seventhChords;
}

abstract final class DiatonicHarmonyConstructor {
  static DiatonicHarmony construct(MusicalKey key) {
    final scale = ScaleConstructor.construct(
      root: key.tonic,
      definition: key.scaleDefinition,
      preference: key.preferredSpelling,
    );
    return DiatonicHarmony(
      key: key,
      scale: scale,
      triads: List.unmodifiable(_buildChords(scale.tones, chordSize: 3)),
      seventhChords: List.unmodifiable(_buildChords(scale.tones, chordSize: 4)),
    );
  }

  static Iterable<DiatonicChord> _buildChords(
    List<SpelledPitchClass> tones, {
    required int chordSize,
  }) sync* {
    for (var degreeIndex = 0; degreeIndex < tones.length; degreeIndex++) {
      final chordTones = [
        for (var chordTone = 0; chordTone < chordSize; chordTone++)
          tones[(degreeIndex + chordTone * 2) % tones.length],
      ];
      final root = chordTones.first;
      final intervals = [
        for (final tone in chordTones.skip(1))
          (tone.pitchClass.semitonesFromC -
                  root.pitchClass.semitonesFromC +
                  12) %
              12,
      ];
      final quality = chordSize == 3
          ? _triadQuality(intervals)
          : _seventhQuality(intervals);
      final chord = ChordConstructor.construct(root: root, quality: quality);
      yield DiatonicChord(
        degree: degreeIndex + 1,
        chord: chord,
        romanNumeral: RomanNumeral(
          degree: degreeIndex + 1,
          quality: quality,
          isSeventh: chordSize == 4,
        ),
      );
    }
  }

  static ChordQuality _triadQuality(List<int> intervals) => switch (intervals) {
    [4, 7] => ChordQuality.major,
    [3, 7] => ChordQuality.minor,
    [3, 6] => ChordQuality.diminished,
    [4, 8] => ChordQuality.augmented,
    _ => throw StateError('Unsupported diatonic triad: $intervals'),
  };

  static ChordQuality _seventhQuality(List<int> intervals) =>
      switch (intervals) {
        [4, 7, 11] => ChordQuality.majorSeventh,
        [4, 7, 10] => ChordQuality.dominantSeventh,
        [3, 7, 10] => ChordQuality.minorSeventh,
        [3, 7, 11] => ChordQuality.minorMajorSeventh,
        [3, 6, 10] => ChordQuality.halfDiminishedSeventh,
        [3, 6, 9] => ChordQuality.diminishedSeventh,
        _ => throw StateError('Unsupported diatonic seventh chord: $intervals'),
      };
}
