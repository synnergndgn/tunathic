import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/interval.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';

abstract final class GuitarChordShapes {
  static final List<GuitarChordShape> all = List.unmodifiable([
    ..._openAndCompactShapes,
    ..._movableShapes(),
    ..._expandedMovableShapes(),
  ]);

  static List<GuitarChordShape> forChord(
    PitchClass root,
    ChordQuality quality,
  ) {
    final shapes = [
      for (final shape in all)
        if (shape.root == root && shape.quality == quality) shape,
    ];
    shapes.sort(_compareShapes);
    return shapes;
  }

  static int _compareShapes(GuitarChordShape left, GuitarChordShape right) {
    final openComparison = (left.category == GuitarShapeCategory.open ? 0 : 1)
        .compareTo(right.category == GuitarShapeCategory.open ? 0 : 1);
    if (openComparison != 0) return openComparison;
    final difficultyComparison = left.difficulty.index.compareTo(
      right.difficulty.index,
    );
    if (difficultyComparison != 0) return difficultyComparison;
    final categoryComparison = _categoryRank(
      left.category,
    ).compareTo(_categoryRank(right.category));
    if (categoryComparison != 0) return categoryComparison;
    return left.startingFret.compareTo(right.startingFret);
  }

  static int _categoryRank(GuitarShapeCategory category) => switch (category) {
    GuitarShapeCategory.open => 0,
    GuitarShapeCategory.movableEShape => 1,
    GuitarShapeCategory.movableAShape => 2,
    GuitarShapeCategory.compact => 3,
  };
}

final List<GuitarChordShape> _openAndCompactShapes = [
  _shape(
    'c-major-open',
    PitchClass.c,
    ChordQuality.major,
    [-1, 3, 2, 0, 1, 0],
    fingers: [null, 3, 2, null, 1, null],
  ),
  _shape(
    'a-major-open',
    PitchClass.a,
    ChordQuality.major,
    [-1, 0, 2, 2, 2, 0],
    fingers: [null, null, 1, 2, 3, null],
  ),
  _shape(
    'g-major-open',
    PitchClass.g,
    ChordQuality.major,
    [3, 2, 0, 0, 0, 3],
    fingers: [2, 1, null, null, null, 3],
  ),
  _shape(
    'e-major-open',
    PitchClass.e,
    ChordQuality.major,
    [0, 2, 2, 1, 0, 0],
    fingers: [null, 2, 3, 1, null, null],
  ),
  _shape(
    'd-major-open',
    PitchClass.d,
    ChordQuality.major,
    [-1, -1, 0, 2, 3, 2],
    fingers: [null, null, null, 1, 3, 2],
  ),
  _shape(
    'a-minor-open',
    PitchClass.a,
    ChordQuality.minor,
    [-1, 0, 2, 2, 1, 0],
    fingers: [null, null, 2, 3, 1, null],
  ),
  _shape(
    'e-minor-open',
    PitchClass.e,
    ChordQuality.minor,
    [0, 2, 2, 0, 0, 0],
    fingers: [null, 2, 3, null, null, null],
  ),
  _shape(
    'd-minor-open',
    PitchClass.d,
    ChordQuality.minor,
    [-1, -1, 0, 2, 3, 1],
    fingers: [null, null, null, 2, 3, 1],
  ),
  _shape(
    'c7-open',
    PitchClass.c,
    ChordQuality.dominantSeventh,
    [-1, 3, 2, 3, 1, 0],
    fingers: [null, 3, 2, 4, 1, null],
    omittedIntervals: const [TheoryInterval.perfectFifth],
  ),
  _shape(
    'a7-open',
    PitchClass.a,
    ChordQuality.dominantSeventh,
    [-1, 0, 2, 0, 2, 0],
    fingers: [null, null, 1, null, 2, null],
  ),
  _shape(
    'b7-open',
    PitchClass.b,
    ChordQuality.dominantSeventh,
    [-1, 2, 1, 2, 0, 2],
    fingers: [null, 2, 1, 3, null, 4],
  ),
  _shape(
    'd7-open',
    PitchClass.d,
    ChordQuality.dominantSeventh,
    [-1, -1, 0, 2, 1, 2],
    fingers: [null, null, null, 2, 1, 3],
  ),
  _shape(
    'e7-open',
    PitchClass.e,
    ChordQuality.dominantSeventh,
    [0, 2, 0, 1, 0, 0],
    fingers: [null, 2, null, 1, null, null],
  ),
  _shape(
    'g7-open',
    PitchClass.g,
    ChordQuality.dominantSeventh,
    [3, 2, 0, 0, 0, 1],
    fingers: [3, 2, null, null, null, 1],
  ),
  _shape(
    'cmaj7-open',
    PitchClass.c,
    ChordQuality.majorSeventh,
    [-1, 3, 2, 0, 0, 0],
    fingers: [null, 3, 2, null, null, null],
  ),
  _shape(
    'amaj7-open',
    PitchClass.a,
    ChordQuality.majorSeventh,
    [-1, 0, 2, 1, 2, 0],
    fingers: [null, null, 2, 1, 3, null],
  ),
  _shape(
    'dmaj7-open',
    PitchClass.d,
    ChordQuality.majorSeventh,
    [-1, -1, 0, 2, 2, 2],
    fingers: [null, null, null, 1, 2, 3],
  ),
  _shape(
    'emaj7-open',
    PitchClass.e,
    ChordQuality.majorSeventh,
    [0, 2, 1, 1, 0, 0],
    fingers: [null, 3, 1, 2, null, null],
  ),
  _shape(
    'gmaj7-open',
    PitchClass.g,
    ChordQuality.majorSeventh,
    [3, 2, 0, 0, 0, 2],
    fingers: [3, 2, null, null, null, 1],
  ),
  _shape(
    'am7-open',
    PitchClass.a,
    ChordQuality.minorSeventh,
    [-1, 0, 2, 0, 1, 0],
    fingers: [null, null, 2, null, 1, null],
  ),
  _shape(
    'em7-open',
    PitchClass.e,
    ChordQuality.minorSeventh,
    [0, 2, 0, 0, 0, 0],
    fingers: [null, 1, null, null, null, null],
  ),
  _shape(
    'dm7-open',
    PitchClass.d,
    ChordQuality.minorSeventh,
    [-1, -1, 0, 2, 1, 1],
    fingers: [null, null, null, 2, 1, 1],
  ),
  _shape(
    'asus2-open',
    PitchClass.a,
    ChordQuality.suspendedSecond,
    [-1, 0, 2, 2, 0, 0],
    fingers: [null, null, 1, 2, null, null],
  ),
  _shape(
    'asus4-open',
    PitchClass.a,
    ChordQuality.suspendedFourth,
    [-1, 0, 2, 2, 3, 0],
    fingers: [null, null, 1, 2, 3, null],
  ),
  _shape(
    'dsus2-open',
    PitchClass.d,
    ChordQuality.suspendedSecond,
    [-1, -1, 0, 2, 3, 0],
    fingers: [null, null, null, 1, 3, null],
  ),
  _shape(
    'dsus4-open',
    PitchClass.d,
    ChordQuality.suspendedFourth,
    [-1, -1, 0, 2, 3, 3],
    fingers: [null, null, null, 1, 3, 4],
  ),
  _shape(
    'esus4-open',
    PitchClass.e,
    ChordQuality.suspendedFourth,
    [0, 2, 2, 2, 0, 0],
    fingers: [null, 1, 2, 3, null, null],
  ),
  _shape(
    'cadd9-open',
    PitchClass.c,
    ChordQuality.addNinth,
    [-1, 3, 2, 0, 3, 0],
    fingers: [null, 3, 2, null, 4, null],
  ),
  _shape(
    'gadd9-open',
    PitchClass.g,
    ChordQuality.addNinth,
    [3, 2, 0, 2, 0, 3],
    fingers: [2, 1, null, 3, null, 4],
  ),
  _shape(
    'eadd9-open',
    PitchClass.e,
    ChordQuality.addNinth,
    [0, 2, 4, 1, 0, 0],
    fingers: [null, 2, 4, 1, null, null],
  ),
  _shape(
    'c6-open',
    PitchClass.c,
    ChordQuality.sixth,
    [-1, 3, 2, 2, 1, 0],
    fingers: [null, 4, 2, 3, 1, null],
    omittedIntervals: const [TheoryInterval.perfectFifth],
  ),
  _shape(
    'a6-open',
    PitchClass.a,
    ChordQuality.sixth,
    [-1, 0, 2, 2, 2, 2],
    fingers: [null, null, 1, 1, 1, 1],
  ),
  _shape(
    'am6-open',
    PitchClass.a,
    ChordQuality.minorSixth,
    [-1, 0, 2, 2, 1, 2],
    fingers: [null, null, 2, 3, 1, 4],
  ),
  _shape(
    'dm6-open',
    PitchClass.d,
    ChordQuality.minorSixth,
    [-1, -1, 0, 2, 0, 1],
    fingers: [null, null, null, 2, null, 1],
  ),
  _shape(
    'c9-compact',
    PitchClass.c,
    ChordQuality.dominantNinth,
    [-1, 3, 2, 3, 3, 3],
    fingers: [null, 2, 1, 3, 3, 3],
    category: GuitarShapeCategory.compact,
  ),
  _shape(
    'a9-compact',
    PitchClass.a,
    ChordQuality.dominantNinth,
    [-1, 0, 2, 4, 2, 3],
    fingers: [null, null, 1, 4, 2, 3],
    category: GuitarShapeCategory.compact,
  ),
  _shape(
    'em9-open',
    PitchClass.e,
    ChordQuality.minorNinth,
    [0, 2, 0, 0, 0, 2],
    fingers: [null, 1, null, null, null, 2],
  ),
  _shape(
    'd11-compact',
    PitchClass.d,
    ChordQuality.eleventh,
    [-1, 5, 4, 5, 3, 3],
    fingers: [null, 3, 2, 4, 1, 1],
    startingFret: 3,
    category: GuitarShapeCategory.compact,
    barres: const [GuitarBarre(fret: 3, fromString: 4, toStringIndex: 5)],
    omittedIntervals: const [
      TheoryInterval.perfectFifth,
      TheoryInterval.majorNinth,
    ],
  ),
  _shape(
    'e13-open',
    PitchClass.e,
    ChordQuality.thirteenth,
    [0, 2, 0, 1, 2, 0],
    fingers: [null, 2, null, 1, 3, null],
    omittedIntervals: const [TheoryInterval.majorNinth],
  ),
  _shape(
    'c-aug-compact',
    PitchClass.c,
    ChordQuality.augmented,
    [-1, 3, 2, 1, 1, -1],
    fingers: [null, 4, 3, 1, 2, null],
    category: GuitarShapeCategory.compact,
  ),
  _shape(
    'c-dim-compact',
    PitchClass.c,
    ChordQuality.diminished,
    [-1, 3, 4, 5, 4, -1],
    fingers: [null, 1, 2, 4, 3, null],
    startingFret: 3,
    category: GuitarShapeCategory.compact,
  ),
  _shape(
    'bm7b5-compact',
    PitchClass.b,
    ChordQuality.halfDiminishedSeventh,
    [-1, 2, 3, 2, 3, -1],
    fingers: [null, 1, 3, 2, 4, null],
    category: GuitarShapeCategory.compact,
  ),
];

Iterable<GuitarChordShape> _movableShapes() sync* {
  const ePatterns = {
    ChordQuality.major: [0, 2, 2, 1, 0, 0],
    ChordQuality.minor: [0, 2, 2, 0, 0, 0],
    ChordQuality.dominantSeventh: [0, 2, 0, 1, 0, 0],
    ChordQuality.majorSeventh: [0, 2, 1, 1, 0, 0],
    ChordQuality.minorSeventh: [0, 2, 0, 0, 0, 0],
  };
  const aPatterns = {
    ChordQuality.major: [-1, 0, 2, 2, 2, 0],
    ChordQuality.minor: [-1, 0, 2, 2, 1, 0],
    ChordQuality.dominantSeventh: [-1, 0, 2, 0, 2, 0],
    ChordQuality.majorSeventh: [-1, 0, 2, 1, 2, 0],
    ChordQuality.minorSeventh: [-1, 0, 2, 0, 1, 0],
  };

  for (final root in PitchClass.values) {
    final eRootFret = _fretAboveOpen(root, PitchClass.e);
    for (final entry in ePatterns.entries) {
      yield _movableShape(
        root: root,
        quality: entry.key,
        rootFret: eRootFret,
        pattern: entry.value,
        category: GuitarShapeCategory.movableEShape,
        barreFrom: 0,
      );
    }

    final aRootFret = _fretAboveOpen(root, PitchClass.a);
    for (final entry in aPatterns.entries) {
      yield _movableShape(
        root: root,
        quality: entry.key,
        rootFret: aRootFret,
        pattern: entry.value,
        category: GuitarShapeCategory.movableAShape,
        barreFrom: 1,
      );
    }
  }
}

Iterable<GuitarChordShape> _expandedMovableShapes() sync* {
  const templates = [
    _MovableTemplate(
      quality: ChordQuality.diminished,
      family: 'e',
      pattern: [0, 1, 2, 0, -1, -1],
      fingers: [1, 2, 3, 1, null, null],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 3)],
    ),
    _MovableTemplate(
      quality: ChordQuality.augmented,
      family: 'a',
      pattern: [-1, 0, 3, 2, 2, 1],
      fingers: [null, 1, 4, 3, 3, 2],
      barres: [
        _RelativeBarre(offset: 2, fromString: 3, toStringIndex: 4, finger: 3),
      ],
    ),
    _MovableTemplate(
      quality: ChordQuality.suspendedSecond,
      family: 'e',
      pattern: [0, 2, 4, 4, 0, 0],
      fingers: [1, 3, 4, 4, 1, 1],
      barres: [
        _RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5),
        _RelativeBarre(offset: 4, fromString: 2, toStringIndex: 3, finger: 4),
      ],
      difficulty: GuitarShapeDifficulty.advanced,
    ),
    _MovableTemplate(
      quality: ChordQuality.suspendedSecond,
      family: 'a',
      pattern: [-1, 0, 2, 2, 0, 0],
      fingers: [null, 1, 3, 3, 1, 1],
      barres: [
        _RelativeBarre(offset: 0, fromString: 1, toStringIndex: 5),
        _RelativeBarre(offset: 2, fromString: 2, toStringIndex: 3, finger: 3),
      ],
    ),
    _MovableTemplate(
      quality: ChordQuality.suspendedFourth,
      family: 'e',
      pattern: [0, 2, 2, 2, 0, 0],
      fingers: [1, 3, 3, 3, 1, 1],
      barres: [
        _RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5),
        _RelativeBarre(offset: 2, fromString: 1, toStringIndex: 3, finger: 3),
      ],
    ),
    _MovableTemplate(
      quality: ChordQuality.suspendedFourth,
      family: 'a',
      pattern: [-1, 0, 2, 2, 3, 0],
      fingers: [null, 1, 2, 3, 4, 1],
      barres: [_RelativeBarre(offset: 0, fromString: 1, toStringIndex: 5)],
    ),
    _MovableTemplate(
      quality: ChordQuality.minorMajorSeventh,
      family: 'e',
      pattern: [0, 2, 1, 0, 0, 0],
      fingers: [1, 3, 2, 1, 1, 1],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
    ),
    _MovableTemplate(
      quality: ChordQuality.diminishedSeventh,
      family: 'e',
      pattern: [0, 1, 2, 0, 2, 0],
      fingers: [1, 2, 3, 1, 4, 1],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
    ),
    _MovableTemplate(
      quality: ChordQuality.halfDiminishedSeventh,
      family: 'e',
      pattern: [0, 1, 0, 0, -1, -1],
      fingers: [1, 2, 1, 1, null, null],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 3)],
    ),
    _MovableTemplate(
      quality: ChordQuality.sixth,
      family: 'a',
      pattern: [-1, 0, 2, 2, 2, 2],
      fingers: [null, 1, 3, 3, 3, 3],
      barres: [
        _RelativeBarre(offset: 2, fromString: 2, toStringIndex: 5, finger: 3),
      ],
    ),
    _MovableTemplate(
      quality: ChordQuality.minorSixth,
      family: 'a',
      pattern: [-1, 0, 2, -1, 1, 2],
      fingers: [null, 1, 3, null, 2, 4],
    ),
    _MovableTemplate(
      quality: ChordQuality.addNinth,
      family: 'e',
      pattern: [0, 2, 4, 1, 0, 0],
      fingers: [1, 3, 4, 2, 1, 1],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
      difficulty: GuitarShapeDifficulty.advanced,
    ),
    _MovableTemplate(
      quality: ChordQuality.addNinth,
      family: 'a',
      pattern: [-1, 0, 2, 4, 2, 0],
      fingers: [null, 1, 2, 4, 3, 1],
      barres: [_RelativeBarre(offset: 0, fromString: 1, toStringIndex: 5)],
      difficulty: GuitarShapeDifficulty.advanced,
    ),
    _MovableTemplate(
      quality: ChordQuality.minorAddNinth,
      family: 'e',
      pattern: [0, 2, 4, 0, 0, 0],
      fingers: [1, 3, 4, 1, 1, 1],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
      difficulty: GuitarShapeDifficulty.advanced,
    ),
    _MovableTemplate(
      quality: ChordQuality.dominantNinth,
      family: 'e',
      pattern: [0, 2, 0, 1, 0, 2],
      fingers: [1, 3, 1, 2, 1, 4],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
    ),
    _MovableTemplate(
      quality: ChordQuality.majorNinth,
      family: 'e',
      pattern: [0, 2, 1, 1, 0, 2],
      fingers: [1, 3, 2, 2, 1, 4],
      barres: [
        _RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5),
        _RelativeBarre(offset: 1, fromString: 2, toStringIndex: 3, finger: 2),
      ],
    ),
    _MovableTemplate(
      quality: ChordQuality.minorNinth,
      family: 'e',
      pattern: [0, 2, 0, 0, 0, 2],
      fingers: [1, 3, 1, 1, 1, 4],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
    ),
    _MovableTemplate(
      quality: ChordQuality.eleventh,
      family: 'e',
      pattern: [0, 0, 0, 1, -1, 2],
      fingers: [1, 1, 1, 2, null, 3],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 3)],
      omittedIntervals: [TheoryInterval.perfectFifth],
    ),
    _MovableTemplate(
      quality: ChordQuality.minorEleventh,
      family: 'e',
      pattern: [0, 0, 0, 0, 0, 2],
      fingers: [1, 1, 1, 1, 1, 3],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
    ),
    _MovableTemplate(
      quality: ChordQuality.thirteenth,
      family: 'e',
      pattern: [0, 4, 0, 1, 0, 2],
      fingers: [1, 4, 1, 2, 1, 3],
      barres: [_RelativeBarre(offset: 0, fromString: 0, toStringIndex: 5)],
      difficulty: GuitarShapeDifficulty.advanced,
    ),
  ];

  for (final root in PitchClass.values) {
    for (final template in templates) {
      final openPitch = template.family == 'e' ? PitchClass.e : PitchClass.a;
      final rootFret = _fretAboveOpen(root, openPitch);
      final category = template.family == 'e'
          ? GuitarShapeCategory.movableEShape
          : GuitarShapeCategory.movableAShape;
      yield _shape(
        '${root.name}-${template.quality.id}-${template.family}-extension-$rootFret',
        root,
        template.quality,
        [
          for (final offset in template.pattern)
            offset < 0 ? -1 : rootFret + offset,
        ],
        fingers: template.fingers,
        startingFret: rootFret,
        category: category,
        difficulty: template.difficulty,
        barres: [
          for (final barre in template.barres)
            GuitarBarre(
              fret: rootFret + barre.offset,
              fromString: barre.fromString,
              toStringIndex: barre.toStringIndex,
              finger: barre.finger,
            ),
        ],
        omittedIntervals: template.omittedIntervals,
        provenance: GuitarShapeProvenance.generated,
      );
    }
  }
}

final class _MovableTemplate {
  const _MovableTemplate({
    required this.quality,
    required this.family,
    required this.pattern,
    required this.fingers,
    this.barres = const [],
    this.omittedIntervals = const [],
    this.difficulty = GuitarShapeDifficulty.intermediate,
  });

  final ChordQuality quality;
  final String family;
  final List<int> pattern;
  final List<int?> fingers;
  final List<_RelativeBarre> barres;
  final List<TheoryInterval> omittedIntervals;
  final GuitarShapeDifficulty difficulty;
}

final class _RelativeBarre {
  const _RelativeBarre({
    required this.offset,
    required this.fromString,
    required this.toStringIndex,
    this.finger = 1,
  });

  final int offset;
  final int fromString;
  final int toStringIndex;
  final int finger;
}

int _fretAboveOpen(PitchClass root, PitchClass openPitch) {
  final fret = (root.semitonesFromC - openPitch.semitonesFromC + 12) % 12;
  return fret == 0 ? 12 : fret;
}

GuitarChordShape _movableShape({
  required PitchClass root,
  required ChordQuality quality,
  required int rootFret,
  required List<int> pattern,
  required GuitarShapeCategory category,
  required int barreFrom,
}) {
  final frets = [
    for (final offset in pattern) offset < 0 ? -1 : rootFret + offset,
  ];
  final family = category == GuitarShapeCategory.movableEShape ? 'e' : 'a';
  return _shape(
    '${root.name}-${quality.id}-$family-shape-$rootFret',
    root,
    quality,
    frets,
    startingFret: rootFret,
    category: category,
    barres: [
      GuitarBarre(fret: rootFret, fromString: barreFrom, toStringIndex: 5),
    ],
    provenance: GuitarShapeProvenance.generated,
  );
}

GuitarChordShape _shape(
  String id,
  PitchClass root,
  ChordQuality quality,
  List<int> frets, {
  List<int?>? fingers,
  int startingFret = 1,
  GuitarShapeCategory category = GuitarShapeCategory.open,
  GuitarShapeDifficulty? difficulty,
  List<GuitarBarre> barres = const [],
  List<TheoryInterval> omittedIntervals = const [],
  GuitarShapeProvenance provenance = GuitarShapeProvenance.curated,
}) {
  final strings = <GuitarStringFingering>[
    for (var index = 0; index < frets.length; index++)
      if (frets[index] < 0)
        const GuitarStringFingering.muted()
      else if (frets[index] == 0)
        const GuitarStringFingering.open()
      else
        GuitarStringFingering.fretted(
          frets[index],
          finger: fingers == null ? null : fingers[index],
        ),
  ];
  return GuitarChordShape(
    id: id,
    root: root,
    quality: quality,
    strings: strings,
    startingFret: startingFret,
    category: category,
    difficulty:
        difficulty ??
        (category == GuitarShapeCategory.open
            ? GuitarShapeDifficulty.beginner
            : GuitarShapeDifficulty.intermediate),
    barres: barres,
    omittedIntervals: omittedIntervals,
    provenance: provenance,
  );
}
