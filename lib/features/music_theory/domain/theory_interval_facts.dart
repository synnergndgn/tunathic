import 'package:tunathic/core/music_theory/music_theory.dart';

enum TheoryIntervalQuality { perfect, major, minor, augmented, diminished }

/// Naming facts derived from the shared interval model.
///
/// Quality is read from the interval rather than stored beside it, so a
/// lesson, a diagram, and a screen reader always agree.
extension TheoryIntervalFacts on TheoryInterval {
  TheoryIntervalQuality get quality => switch (this) {
    TheoryInterval.perfectUnison ||
    TheoryInterval.perfectFourth ||
    TheoryInterval.perfectFifth ||
    TheoryInterval.octave ||
    TheoryInterval.perfectEleventh => TheoryIntervalQuality.perfect,
    TheoryInterval.majorSecond ||
    TheoryInterval.majorThird ||
    TheoryInterval.majorSixth ||
    TheoryInterval.majorSeventh ||
    TheoryInterval.majorNinth ||
    TheoryInterval.majorThirteenth => TheoryIntervalQuality.major,
    TheoryInterval.minorSecond ||
    TheoryInterval.minorThird ||
    TheoryInterval.minorSixth ||
    TheoryInterval.minorSeventh ||
    TheoryInterval.minorNinth => TheoryIntervalQuality.minor,
    TheoryInterval.augmentedFourth ||
    TheoryInterval.augmentedFifth => TheoryIntervalQuality.augmented,
    TheoryInterval.diminishedFifth ||
    TheoryInterval.diminishedSeventh => TheoryIntervalQuality.diminished,
  };

  /// The content identifier holding this interval's translated name.
  String get nameId => 'intervalName.$id';

  /// The content identifier holding this interval's translated quality.
  String get qualityId => 'intervalQuality.${quality.name}';
}
