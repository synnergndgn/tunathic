import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';
import 'package:tunathic/l10n/app_localizations.dart';

extension ChordLibraryLocalizations on AppLocalizations {
  String chordQualityName(ChordQuality quality) => switch (quality) {
    ChordQuality.major => qualityMajor,
    ChordQuality.minor => qualityMinor,
    ChordQuality.diminished => qualityDiminished,
    ChordQuality.augmented => qualityAugmented,
    ChordQuality.suspendedSecond => qualitySus2,
    ChordQuality.suspendedFourth => qualitySus4,
    ChordQuality.majorSeventh => qualityMajor7,
    ChordQuality.dominantSeventh => qualityDominant7,
    ChordQuality.minorSeventh => qualityMinor7,
    ChordQuality.minorMajorSeventh => qualityMinorMajor7,
    ChordQuality.diminishedSeventh => qualityDiminished7,
    ChordQuality.halfDiminishedSeventh => qualityHalfDiminished7,
    ChordQuality.sixth => quality6,
    ChordQuality.minorSixth => qualityMinor6,
    ChordQuality.addNinth => qualityAdd9,
    ChordQuality.minorAddNinth => qualityMinorAdd9,
    ChordQuality.dominantNinth => quality9,
    ChordQuality.majorNinth => qualityMajor9,
    ChordQuality.minorNinth => qualityMinor9,
    ChordQuality.eleventh => quality11,
    ChordQuality.minorEleventh => qualityMinor11,
    ChordQuality.thirteenth => quality13,
  };

  String chordCategoryName(ChordCategory category) => switch (category) {
    ChordCategory.triad => triadCategory,
    ChordCategory.seventh => seventhChordCategory,
    ChordCategory.extended => extendedChordCategory,
  };

  String shapeCategoryName(GuitarShapeCategory category) => switch (category) {
    GuitarShapeCategory.open => openPositionShape,
    GuitarShapeCategory.movableEShape => movableEShape,
    GuitarShapeCategory.movableAShape => movableAShape,
    GuitarShapeCategory.compact => compactShape,
  };

  String shapeDifficultyName(GuitarShapeDifficulty difficulty) =>
      switch (difficulty) {
        GuitarShapeDifficulty.beginner => beginnerDifficulty,
        GuitarShapeDifficulty.intermediate => intermediateDifficulty,
      };

  List<String> get guitarStringNames => [
    lowEString,
    aString,
    dString,
    gString,
    bString,
    highEString,
  ];
}
