import 'package:tunathic/core/music_theory/interval.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';

enum ChordCategory { triad, seventh, extended }

enum ChordQuality {
  major(
    id: 'major',
    symbol: '',
    category: ChordCategory.triad,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
    ],
  ),
  minor(
    id: 'minor',
    symbol: 'm',
    category: ChordCategory.triad,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
    ],
  ),
  diminished(
    id: 'diminished',
    symbol: 'dim',
    category: ChordCategory.triad,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.diminishedFifth,
    ],
  ),
  augmented(
    id: 'augmented',
    symbol: 'aug',
    category: ChordCategory.triad,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.augmentedFifth,
    ],
  ),
  suspendedSecond(
    id: 'suspended-second',
    symbol: 'sus2',
    category: ChordCategory.triad,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorSecond,
      TheoryInterval.perfectFifth,
    ],
  ),
  suspendedFourth(
    id: 'suspended-fourth',
    symbol: 'sus4',
    category: ChordCategory.triad,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.perfectFourth,
      TheoryInterval.perfectFifth,
    ],
  ),
  majorSeventh(
    id: 'major-seventh',
    symbol: 'maj7',
    category: ChordCategory.seventh,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorSeventh,
    ],
  ),
  dominantSeventh(
    id: 'dominant-seventh',
    symbol: '7',
    category: ChordCategory.seventh,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
    ],
  ),
  minorSeventh(
    id: 'minor-seventh',
    symbol: 'm7',
    category: ChordCategory.seventh,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
    ],
  ),
  minorMajorSeventh(
    id: 'minor-major-seventh',
    symbol: 'm(maj7)',
    category: ChordCategory.seventh,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorSeventh,
    ],
  ),
  diminishedSeventh(
    id: 'diminished-seventh',
    symbol: 'dim7',
    category: ChordCategory.seventh,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.diminishedFifth,
      TheoryInterval.diminishedSeventh,
    ],
  ),
  halfDiminishedSeventh(
    id: 'half-diminished-seventh',
    symbol: 'm7b5',
    category: ChordCategory.seventh,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.diminishedFifth,
      TheoryInterval.minorSeventh,
    ],
  ),
  sixth(
    id: 'sixth',
    symbol: '6',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorSixth,
    ],
  ),
  minorSixth(
    id: 'minor-sixth',
    symbol: 'm6',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorSixth,
    ],
  ),
  addNinth(
    id: 'add-ninth',
    symbol: 'add9',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorNinth,
    ],
  ),
  minorAddNinth(
    id: 'minor-add-ninth',
    symbol: 'madd9',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorNinth,
    ],
  ),
  dominantNinth(
    id: 'dominant-ninth',
    symbol: '9',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
      TheoryInterval.majorNinth,
    ],
  ),
  majorNinth(
    id: 'major-ninth',
    symbol: 'maj9',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.majorSeventh,
      TheoryInterval.majorNinth,
    ],
  ),
  minorNinth(
    id: 'minor-ninth',
    symbol: 'm9',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
      TheoryInterval.majorNinth,
    ],
  ),
  eleventh(
    id: 'eleventh',
    symbol: '11',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
      TheoryInterval.majorNinth,
      TheoryInterval.perfectEleventh,
    ],
  ),
  minorEleventh(
    id: 'minor-eleventh',
    symbol: 'm11',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.minorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
      TheoryInterval.majorNinth,
      TheoryInterval.perfectEleventh,
    ],
  ),
  thirteenth(
    id: 'thirteenth',
    symbol: '13',
    category: ChordCategory.extended,
    formula: [
      TheoryInterval.perfectUnison,
      TheoryInterval.majorThird,
      TheoryInterval.perfectFifth,
      TheoryInterval.minorSeventh,
      TheoryInterval.majorNinth,
      TheoryInterval.majorThirteenth,
    ],
  );

  const ChordQuality({
    required this.id,
    required this.symbol,
    required this.category,
    required this.formula,
  });

  final String id;
  final String symbol;
  final ChordCategory category;
  final List<TheoryInterval> formula;

  static ChordQuality? fromId(String id) {
    for (final quality in values) {
      if (quality.id == id) return quality;
    }
    return null;
  }
}

final class ConstructedChord {
  const ConstructedChord({
    required this.root,
    required this.quality,
    required this.tones,
  });

  final SpelledPitchClass root;
  final ChordQuality quality;
  final List<SpelledPitchClass> tones;

  String get symbol => '${root.symbol}${quality.symbol}';

  Set<PitchClass> get pitchClasses =>
      tones.map((tone) => tone.pitchClass).toSet();
}

abstract final class ChordConstructor {
  static ConstructedChord construct({
    required SpelledPitchClass root,
    required ChordQuality quality,
    SpellingPreference preference = SpellingPreference.contextual,
  }) {
    final tones = [
      for (final interval in quality.formula)
        NoteSpelling.spellInterval(
          root: root,
          semitones: interval.semitones,
          diatonicSteps: interval.diatonicSteps,
          preference: preference,
        ),
    ];
    return ConstructedChord(root: root, quality: quality, tones: tones);
  }
}
