import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/chord_library/data/guitar_chord_shapes.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';
import 'package:tunathic/features/chord_library/domain/guitar_shape_validator.dart';

void main() {
  test(
    'every project-owned chord shape passes structural and musical validation',
    () {
      final results = GuitarShapeValidator.validateAll(GuitarChordShapes.all);
      final failures = [
        for (final entry in results.entries)
          if (!entry.value.isValid)
            '${entry.key}: ${entry.value.issues.map((issue) => issue.message).join(', ')}',
      ];

      expect(GuitarChordShapes.all.length, greaterThanOrEqualTo(150));
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );

  test('derives sounding pitch classes from standard tuning and frets', () {
    final cMajor = GuitarChordShapes.all.firstWhere(
      (shape) => shape.id == 'c-major-open',
    );
    expect(GuitarShapePitch.soundingPitchClasses(cMajor).toSet(), {
      PitchClass.c,
      PitchClass.e,
      PitchClass.g,
    });
  });

  test('library provides open and alternate movable everyday shapes', () {
    final cMajor = GuitarChordShapes.forChord(PitchClass.c, ChordQuality.major);
    expect(cMajor, hasLength(3));
    expect(
      cMajor.map((shape) => shape.category),
      containsAll([
        GuitarShapeCategory.open,
        GuitarShapeCategory.movableEShape,
        GuitarShapeCategory.movableAShape,
      ]),
    );
    expect(
      GuitarChordShapes.forChord(
        PitchClass.fSharpGFlat,
        ChordQuality.minorSeventh,
      ),
      hasLength(2),
    );
  });

  test(
    'detects invalid count, fret, finger, foreign tone, and missing root',
    () {
      const invalid = GuitarChordShape(
        id: 'invalid',
        root: PitchClass.c,
        quality: ChordQuality.major,
        strings: [
          GuitarStringFingering.fretted(25, finger: 5),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
        ],
        startingFret: 0,
        category: GuitarShapeCategory.compact,
        difficulty: GuitarShapeDifficulty.intermediate,
      );

      final codes = GuitarShapeValidator.validate(
        invalid,
      ).issues.map((issue) => issue.code).toSet();
      expect(codes, contains(GuitarShapeIssueCode.invalidStringCount));
      expect(codes, contains(GuitarShapeIssueCode.invalidFret));
      expect(codes, contains(GuitarShapeIssueCode.invalidFinger));
      expect(codes, contains(GuitarShapeIssueCode.invalidStartingFret));
    },
  );

  test('detects invalid barre ranges and coverage', () {
    const invalid = GuitarChordShape(
      id: 'invalid-barres',
      root: PitchClass.f,
      quality: ChordQuality.major,
      strings: [
        GuitarStringFingering.fretted(1),
        GuitarStringFingering.fretted(3),
        GuitarStringFingering.fretted(3),
        GuitarStringFingering.fretted(2),
        GuitarStringFingering.fretted(1),
        GuitarStringFingering.fretted(1),
      ],
      startingFret: 1,
      category: GuitarShapeCategory.movableEShape,
      difficulty: GuitarShapeDifficulty.intermediate,
      barres: [
        GuitarBarre(fret: 1, fromString: 4, toStringIndex: 4),
        GuitarBarre(fret: 2, fromString: 0, toStringIndex: 5, finger: 6),
      ],
    );

    final codes = GuitarShapeValidator.validate(
      invalid,
    ).issues.map((issue) => issue.code).toSet();
    expect(codes, contains(GuitarShapeIssueCode.invalidBarreRange));
    expect(codes, contains(GuitarShapeIssueCode.invalidBarreFinger));
    expect(codes, contains(GuitarShapeIssueCode.invalidBarreCoverage));
  });

  test(
    'rejects musically foreign notes and roots missing from ordinary voicings',
    () {
      const invalid = GuitarChordShape(
        id: 'wrong-chord',
        root: PitchClass.c,
        quality: ChordQuality.major,
        strings: [
          GuitarStringFingering.muted(),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
          GuitarStringFingering.open(),
        ],
        startingFret: 1,
        category: GuitarShapeCategory.open,
        difficulty: GuitarShapeDifficulty.beginner,
      );

      final codes = GuitarShapeValidator.validate(
        invalid,
      ).issues.map((issue) => issue.code).toSet();
      expect(codes, contains(GuitarShapeIssueCode.foreignChordTone));
      expect(codes, contains(GuitarShapeIssueCode.missingRoot));
    },
  );
}
