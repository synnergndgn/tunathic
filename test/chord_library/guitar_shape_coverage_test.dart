import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/chord_library/data/guitar_chord_shapes.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';
import 'package:tunathic/features/chord_library/domain/guitar_shape_coverage.dart';

void main() {
  late GuitarShapeCoverageReport report;

  setUpAll(() {
    report = GuitarShapeCoverageAudit.calculate(GuitarChordShapes.all);
  });

  test('audits every supported root and chord quality deterministically', () {
    expect(report.totalCombinationCount, 12 * ChordQuality.values.length);
    expect(report.entries, hasLength(264));
    expect(
      report.entries.map((entry) => (entry.root, entry.quality)).toSet(),
      hasLength(264),
    );
  });

  test('final project-owned library has complete validated coverage', () {
    expect(report.validShapeCount, 402);
    expect(report.coveredCombinationCount, 264);
    expect(report.missingCombinationCount, 0);
    expect(report.missingCombinations, isEmpty);
    expect(report.coveragePercentage, 100);
  });

  test('reports shape totals by quality and family', () {
    expect(report.shapesByQuality, {
      ChordQuality.major: 29,
      ChordQuality.minor: 27,
      ChordQuality.diminished: 13,
      ChordQuality.augmented: 13,
      ChordQuality.suspendedSecond: 26,
      ChordQuality.suspendedFourth: 27,
      ChordQuality.majorSeventh: 29,
      ChordQuality.dominantSeventh: 30,
      ChordQuality.minorSeventh: 27,
      ChordQuality.minorMajorSeventh: 12,
      ChordQuality.diminishedSeventh: 12,
      ChordQuality.halfDiminishedSeventh: 13,
      ChordQuality.sixth: 14,
      ChordQuality.minorSixth: 14,
      ChordQuality.addNinth: 27,
      ChordQuality.minorAddNinth: 12,
      ChordQuality.dominantNinth: 14,
      ChordQuality.majorNinth: 12,
      ChordQuality.minorNinth: 13,
      ChordQuality.eleventh: 13,
      ChordQuality.minorEleventh: 12,
      ChordQuality.thirteenth: 13,
    });
    expect(report.shapesByCategory, {
      GuitarShapeCategory.open: 36,
      GuitarShapeCategory.movableEShape: 228,
      GuitarShapeCategory.movableAShape: 132,
      GuitarShapeCategory.compact: 6,
    });
  });

  test('keeps generated and curated provenance distinguishable', () {
    expect(
      GuitarChordShapes.all
          .where((shape) => shape.provenance == GuitarShapeProvenance.curated)
          .length,
      42,
    );
    expect(
      GuitarChordShapes.all
          .where((shape) => shape.provenance == GuitarShapeProvenance.generated)
          .length,
      360,
    );
  });

  test('every coverage entry reports families and a practical position', () {
    for (final entry in report.entries) {
      expect(entry.validShapeCount, greaterThan(0));
      expect(entry.families, isNotEmpty);
      expect(entry.lowestPracticalPosition, inInclusiveRange(1, 12));
    }
  });

  test('common qualities provide alternatives across all roots', () {
    const commonQualities = {
      ChordQuality.major,
      ChordQuality.minor,
      ChordQuality.dominantSeventh,
      ChordQuality.majorSeventh,
      ChordQuality.minorSeventh,
      ChordQuality.suspendedSecond,
      ChordQuality.suspendedFourth,
      ChordQuality.addNinth,
    };
    for (final entry in report.entries.where(
      (entry) => commonQualities.contains(entry.quality),
    )) {
      expect(
        entry.hasAlternatives,
        isTrue,
        reason: '${entry.root.name} ${entry.quality.id}',
      );
    }
  });

  test('representative everyday and extended chords have valid shapes', () {
    const examples = [
      (PitchClass.c, ChordQuality.major),
      (PitchClass.c, ChordQuality.minor),
      (PitchClass.f, ChordQuality.major),
      (PitchClass.f, ChordQuality.minor),
      (PitchClass.aSharpBFlat, ChordQuality.major),
      (PitchClass.fSharpGFlat, ChordQuality.major),
      (PitchClass.c, ChordQuality.dominantSeventh),
      (PitchClass.aSharpBFlat, ChordQuality.majorSeventh),
      (PitchClass.fSharpGFlat, ChordQuality.minorSeventh),
      (PitchClass.cSharpDFlat, ChordQuality.halfDiminishedSeventh),
      (PitchClass.b, ChordQuality.diminishedSeventh),
      (PitchClass.fSharpGFlat, ChordQuality.minorMajorSeventh),
      (PitchClass.dSharpEFlat, ChordQuality.majorNinth),
      (PitchClass.gSharpAFlat, ChordQuality.dominantNinth),
      (PitchClass.d, ChordQuality.minorEleventh),
      (PitchClass.aSharpBFlat, ChordQuality.thirteenth),
      (PitchClass.g, ChordQuality.minorSixth),
      (PitchClass.a, ChordQuality.suspendedSecond),
      (PitchClass.d, ChordQuality.suspendedFourth),
      (PitchClass.c, ChordQuality.addNinth),
    ];

    for (final (root, quality) in examples) {
      expect(
        GuitarChordShapes.forChord(root, quality),
        isNotEmpty,
        reason: '${root.name} ${quality.id}',
      );
    }
  });
}
