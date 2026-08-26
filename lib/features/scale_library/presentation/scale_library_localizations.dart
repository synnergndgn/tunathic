import 'package:tunathic/core/music_theory/scale.dart';
import 'package:tunathic/l10n/app_localizations.dart';

extension ScaleLibraryLocalizations on AppLocalizations {
  String scaleName(ScaleDefinition definition) => switch (definition) {
    ScaleDefinition.major => scaleMajor,
    ScaleDefinition.naturalMinor => scaleNaturalMinor,
    ScaleDefinition.harmonicMinor => scaleHarmonicMinor,
    ScaleDefinition.melodicMinor => scaleMelodicMinor,
    ScaleDefinition.dorian => scaleDorian,
    ScaleDefinition.phrygian => scalePhrygian,
    ScaleDefinition.lydian => scaleLydian,
    ScaleDefinition.mixolydian => scaleMixolydian,
    ScaleDefinition.locrian => scaleLocrian,
    ScaleDefinition.majorPentatonic => scaleMajorPentatonic,
    ScaleDefinition.minorPentatonic => scaleMinorPentatonic,
    ScaleDefinition.blues => scaleBlues,
  };

  String scaleCategoryName(ScaleCategory category) => switch (category) {
    ScaleCategory.majorMinor => scaleCategoryMajorMinor,
    ScaleCategory.modes => scaleCategoryModes,
    ScaleCategory.pentatonicBlues => scaleCategoryPentatonicBlues,
    ScaleCategory.other => scaleCategoryOther,
  };

  String scaleAliasName(String alias) => switch (alias) {
    'ionian' => scaleAliasIonian,
    'aeolian' => scaleAliasAeolian,
    _ => alias,
  };

  String scaleDegreeSpoken(ScaleDegree degree) => switch (degree) {
    ScaleDegree.tonic => degreeOneSpoken,
    ScaleDegree.flatSecond => degreeFlatTwoSpoken,
    ScaleDegree.second => degreeTwoSpoken,
    ScaleDegree.flatThird => degreeFlatThreeSpoken,
    ScaleDegree.third => degreeThreeSpoken,
    ScaleDegree.fourth => degreeFourSpoken,
    ScaleDegree.sharpFourth => degreeSharpFourSpoken,
    ScaleDegree.flatFifth => degreeFlatFiveSpoken,
    ScaleDegree.fifth => degreeFiveSpoken,
    ScaleDegree.flatSixth => degreeFlatSixSpoken,
    ScaleDegree.sixth => degreeSixSpoken,
    ScaleDegree.flatSeventh => degreeFlatSevenSpoken,
    ScaleDegree.seventh => degreeSevenSpoken,
  };
}
