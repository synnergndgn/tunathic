import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';
import 'package:tunathic/features/chord_library/domain/guitar_shape_validator.dart';

final class GuitarShapeCoverageEntry {
  const GuitarShapeCoverageEntry({
    required this.root,
    required this.quality,
    required this.validShapeCount,
    required this.families,
    required this.lowestPracticalPosition,
  });

  final PitchClass root;
  final ChordQuality quality;
  final int validShapeCount;
  final Set<GuitarShapeCategory> families;
  final int? lowestPracticalPosition;

  bool get hasShape => validShapeCount > 0;
  bool get hasAlternatives => validShapeCount > 1;
}

final class GuitarShapeCoverageReport {
  const GuitarShapeCoverageReport({
    required this.entries,
    required this.shapesByQuality,
    required this.shapesByCategory,
    required this.validShapeCount,
  });

  final List<GuitarShapeCoverageEntry> entries;
  final Map<ChordQuality, int> shapesByQuality;
  final Map<GuitarShapeCategory, int> shapesByCategory;
  final int validShapeCount;

  int get totalCombinationCount => entries.length;

  int get coveredCombinationCount =>
      entries.where((entry) => entry.hasShape).length;

  int get missingCombinationCount =>
      totalCombinationCount - coveredCombinationCount;

  double get coveragePercentage => totalCombinationCount == 0
      ? 0
      : coveredCombinationCount * 100 / totalCombinationCount;

  List<GuitarShapeCoverageEntry> get missingCombinations =>
      List.unmodifiable(entries.where((entry) => !entry.hasShape));
}

abstract final class GuitarShapeCoverageAudit {
  static GuitarShapeCoverageReport calculate(
    Iterable<GuitarChordShape> shapes,
  ) {
    final validShapes = [
      for (final shape in shapes)
        if (GuitarShapeValidator.validate(shape).isValid) shape,
    ];
    final entries = <GuitarShapeCoverageEntry>[];
    for (final root in PitchClass.values) {
      for (final quality in ChordQuality.values) {
        final matching = [
          for (final shape in validShapes)
            if (shape.root == root && shape.quality == quality) shape,
        ];
        entries.add(
          GuitarShapeCoverageEntry(
            root: root,
            quality: quality,
            validShapeCount: matching.length,
            families: {for (final shape in matching) shape.category},
            lowestPracticalPosition: matching.isEmpty
                ? null
                : matching
                      .map((shape) => shape.startingFret)
                      .reduce((left, right) => left < right ? left : right),
          ),
        );
      }
    }

    return GuitarShapeCoverageReport(
      entries: List.unmodifiable(entries),
      shapesByQuality: Map.unmodifiable({
        for (final quality in ChordQuality.values)
          quality: validShapes
              .where((shape) => shape.quality == quality)
              .length,
      }),
      shapesByCategory: Map.unmodifiable({
        for (final category in GuitarShapeCategory.values)
          category: validShapes
              .where((shape) => shape.category == category)
              .length,
      }),
      validShapeCount: validShapes.length,
    );
  }
}
