import 'package:tunathic/core/music_theory/pitch_class.dart';

enum ScaleDegree {
  tonic('1', 0, 0),
  flatSecond('b2', 1, 1),
  second('2', 2, 1),
  flatThird('b3', 3, 2),
  third('3', 4, 2),
  fourth('4', 5, 3),
  sharpFourth('#4', 6, 3),
  flatFifth('b5', 6, 4),
  fifth('5', 7, 4),
  flatSixth('b6', 8, 5),
  sixth('6', 9, 5),
  flatSeventh('b7', 10, 6),
  seventh('7', 11, 6);

  const ScaleDegree(this.symbol, this.semitones, this.diatonicSteps);

  final String symbol;
  final int semitones;
  final int diatonicSteps;
}

enum ScaleCategory { majorMinor, modes, pentatonicBlues, other }

enum ScaleDefinition {
  major(
    id: 'major',
    category: ScaleCategory.majorMinor,
    aliases: ['ionian'],
    modeDegree: 1,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.third,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.sixth,
      ScaleDegree.seventh,
    ],
  ),
  naturalMinor(
    id: 'natural-minor',
    category: ScaleCategory.majorMinor,
    aliases: ['aeolian'],
    modeDegree: 6,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.flatSixth,
      ScaleDegree.flatSeventh,
    ],
  ),
  harmonicMinor(
    id: 'harmonic-minor',
    category: ScaleCategory.majorMinor,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.flatSixth,
      ScaleDegree.seventh,
    ],
  ),
  melodicMinor(
    id: 'melodic-minor',
    category: ScaleCategory.majorMinor,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.sixth,
      ScaleDegree.seventh,
    ],
  ),
  dorian(
    id: 'dorian',
    category: ScaleCategory.modes,
    modeDegree: 2,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.sixth,
      ScaleDegree.flatSeventh,
    ],
  ),
  phrygian(
    id: 'phrygian',
    category: ScaleCategory.modes,
    modeDegree: 3,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.flatSecond,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.flatSixth,
      ScaleDegree.flatSeventh,
    ],
  ),
  lydian(
    id: 'lydian',
    category: ScaleCategory.modes,
    modeDegree: 4,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.third,
      ScaleDegree.sharpFourth,
      ScaleDegree.fifth,
      ScaleDegree.sixth,
      ScaleDegree.seventh,
    ],
  ),
  mixolydian(
    id: 'mixolydian',
    category: ScaleCategory.modes,
    modeDegree: 5,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.third,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.sixth,
      ScaleDegree.flatSeventh,
    ],
  ),
  locrian(
    id: 'locrian',
    category: ScaleCategory.modes,
    modeDegree: 7,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.flatSecond,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.flatFifth,
      ScaleDegree.flatSixth,
      ScaleDegree.flatSeventh,
    ],
  ),
  majorPentatonic(
    id: 'major-pentatonic',
    category: ScaleCategory.pentatonicBlues,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.second,
      ScaleDegree.third,
      ScaleDegree.fifth,
      ScaleDegree.sixth,
    ],
  ),
  minorPentatonic(
    id: 'minor-pentatonic',
    category: ScaleCategory.pentatonicBlues,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.fifth,
      ScaleDegree.flatSeventh,
    ],
  ),
  blues(
    id: 'blues',
    category: ScaleCategory.pentatonicBlues,
    degrees: [
      ScaleDegree.tonic,
      ScaleDegree.flatThird,
      ScaleDegree.fourth,
      ScaleDegree.flatFifth,
      ScaleDegree.fifth,
      ScaleDegree.flatSeventh,
    ],
  );

  const ScaleDefinition({
    required this.id,
    required this.category,
    required this.degrees,
    this.aliases = const [],
    this.modeDegree,
  });

  final String id;
  final ScaleCategory category;
  final List<ScaleDegree> degrees;
  final List<String> aliases;
  final int? modeDegree;

  String get formula => degrees.map((degree) => degree.symbol).join(' ');

  static ScaleDefinition? fromIdOrAlias(String id) {
    for (final scale in values) {
      if (scale.id == id || scale.aliases.contains(id)) return scale;
    }
    return null;
  }
}

final class ConstructedScale {
  const ConstructedScale({
    required this.root,
    required this.definition,
    required this.tones,
  });

  final SpelledPitchClass root;
  final ScaleDefinition definition;
  final List<SpelledPitchClass> tones;

  Set<PitchClass> get pitchClasses =>
      tones.map((tone) => tone.pitchClass).toSet();
}

abstract final class ScaleConstructor {
  static ConstructedScale construct({
    required SpelledPitchClass root,
    required ScaleDefinition definition,
    SpellingPreference preference = SpellingPreference.contextual,
  }) {
    final tones = [
      for (final degree in definition.degrees)
        NoteSpelling.spellInterval(
          root: root,
          semitones: degree.semitones,
          diatonicSteps: degree.diatonicSteps,
          preference: preference,
        ),
    ];
    return ConstructedScale(root: root, definition: definition, tones: tones);
  }
}

abstract final class ScaleRelationships {
  static const _majorModeOffsets = [0, 2, 4, 5, 7, 9, 11];

  static SpelledPitchClass relativeMinor(SpelledPitchClass majorRoot) =>
      NoteSpelling.spellInterval(
        root: majorRoot,
        semitones: 9,
        diatonicSteps: 5,
      );

  static SpelledPitchClass relativeMajor(SpelledPitchClass minorRoot) =>
      NoteSpelling.spellInterval(
        root: minorRoot,
        semitones: 3,
        diatonicSteps: 2,
      );

  static SpelledPitchClass? parentMajor({
    required SpelledPitchClass modeRoot,
    required ScaleDefinition definition,
  }) {
    final degree = definition.modeDegree;
    if (degree == null) return null;
    return NoteSpelling.spellInterval(
      root: modeRoot,
      semitones: -_majorModeOffsets[degree - 1],
      diatonicSteps: -(degree - 1),
    );
  }
}
