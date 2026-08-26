// ignore_for_file: avoid_print

import 'package:tunathic/features/chord_library/data/guitar_chord_shapes.dart';
import 'package:tunathic/features/chord_library/domain/guitar_shape_coverage.dart';

void main() {
  final report = GuitarShapeCoverageAudit.calculate(GuitarChordShapes.all);
  print('Valid shapes: ${report.validShapeCount}');
  print('Supported combinations: ${report.totalCombinationCount}');
  print('Covered combinations: ${report.coveredCombinationCount}');
  print('Missing combinations: ${report.missingCombinationCount}');
  print('Coverage: ${report.coveragePercentage.toStringAsFixed(2)}%');
  print('Shapes by quality:');
  for (final entry in report.shapesByQuality.entries) {
    print('  ${entry.key.id}: ${entry.value}');
  }
  print('Shapes by family:');
  for (final entry in report.shapesByCategory.entries) {
    print('  ${entry.key.name}: ${entry.value}');
  }
  if (report.missingCombinations.isNotEmpty) {
    print('Missing root/quality combinations:');
    for (final entry in report.missingCombinations) {
      print('  ${entry.root.name} ${entry.quality.id}');
    }
  }
}
