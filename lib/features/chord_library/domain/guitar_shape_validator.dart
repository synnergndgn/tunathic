import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/features/chord_library/domain/guitar_chord_shape.dart';

enum GuitarShapeIssueCode {
  invalidStringCount,
  invalidFret,
  inconsistentStringKind,
  invalidFinger,
  invalidStartingFret,
  outsideDiagramWindow,
  foreignChordTone,
  missingRoot,
  invalidBarreFret,
  invalidBarreRange,
  invalidBarreFinger,
  invalidBarreCoverage,
}

final class GuitarShapeIssue {
  const GuitarShapeIssue(this.code, this.message);

  final GuitarShapeIssueCode code;
  final String message;
}

final class GuitarShapeValidation {
  const GuitarShapeValidation(this.issues);

  final List<GuitarShapeIssue> issues;

  bool get isValid => issues.isEmpty;
}

abstract final class GuitarShapePitch {
  static const standardTuning = [
    PitchClass.e,
    PitchClass.a,
    PitchClass.d,
    PitchClass.g,
    PitchClass.b,
    PitchClass.e,
  ];

  static List<PitchClass> soundingPitchClasses(GuitarChordShape shape) {
    final result = <PitchClass>[];
    final count = shape.strings.length < standardTuning.length
        ? shape.strings.length
        : standardTuning.length;
    for (var index = 0; index < count; index++) {
      final string = shape.strings[index];
      if (!string.isSounding || string.fret < 0) continue;
      result.add(standardTuning[index].transpose(string.fret));
    }
    return result;
  }
}

abstract final class GuitarShapeValidator {
  static const maximumFret = 24;
  static const diagramFretCount = 5;

  static GuitarShapeValidation validate(GuitarChordShape shape) {
    final issues = <GuitarShapeIssue>[];
    if (shape.strings.length != 6) {
      issues.add(
        GuitarShapeIssue(
          GuitarShapeIssueCode.invalidStringCount,
          '${shape.id}: expected six strings, found ${shape.strings.length}.',
        ),
      );
    }

    if (shape.startingFret < 1 || shape.startingFret > maximumFret) {
      issues.add(
        GuitarShapeIssue(
          GuitarShapeIssueCode.invalidStartingFret,
          '${shape.id}: starting fret must be between 1 and $maximumFret.',
        ),
      );
    }

    for (var index = 0; index < shape.strings.length; index++) {
      final string = shape.strings[index];
      final fretIsValid = string.fret >= -1 && string.fret <= maximumFret;
      if (!fretIsValid) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidFret,
            '${shape.id}: string $index has invalid fret ${string.fret}.',
          ),
        );
      }

      final kindMatchesFret = switch (string.kind) {
        GuitarStringKind.muted => string.fret == -1,
        GuitarStringKind.open => string.fret == 0,
        GuitarStringKind.fretted => string.fret > 0,
      };
      if (!kindMatchesFret) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.inconsistentStringKind,
            '${shape.id}: string $index kind does not match its fret.',
          ),
        );
      }

      if (string.finger != null &&
          (string.finger! < 1 ||
              string.finger! > 4 ||
              string.kind != GuitarStringKind.fretted)) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidFinger,
            '${shape.id}: string $index has invalid finger ${string.finger}.',
          ),
        );
      }

      if (string.fret > 0 &&
          (string.fret < shape.startingFret ||
              string.fret >= shape.startingFret + diagramFretCount)) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.outsideDiagramWindow,
            '${shape.id}: fret ${string.fret} is outside its diagram window.',
          ),
        );
      }
    }

    for (final barre in shape.barres) {
      if (barre.fret < 1 || barre.fret > maximumFret) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidBarreFret,
            '${shape.id}: barre fret ${barre.fret} is invalid.',
          ),
        );
      }
      if (barre.fromString < 0 ||
          barre.toStringIndex >= 6 ||
          barre.fromString >= barre.toStringIndex) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidBarreRange,
            '${shape.id}: barre string range is invalid.',
          ),
        );
        continue;
      }
      if (barre.finger < 1 || barre.finger > 4) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidBarreFinger,
            '${shape.id}: barre finger ${barre.finger} is invalid.',
          ),
        );
      }
      if (shape.strings.length == 6) {
        var notesAtBarreFret = 0;
        var coverageIsValid = true;
        for (
          var stringIndex = barre.fromString;
          stringIndex <= barre.toStringIndex;
          stringIndex++
        ) {
          final fret = shape.strings[stringIndex].fret;
          if (fret < barre.fret) coverageIsValid = false;
          if (fret == barre.fret) notesAtBarreFret++;
        }
        if (!coverageIsValid || notesAtBarreFret < 2) {
          issues.add(
            GuitarShapeIssue(
              GuitarShapeIssueCode.invalidBarreCoverage,
              '${shape.id}: barre does not match the covered strings.',
            ),
          );
        }
      }
    }

    if (shape.strings.length == 6) {
      final allowedPitchClasses = {
        for (final interval in shape.quality.formula)
          shape.root.transpose(interval.semitones),
      };
      final sounding = GuitarShapePitch.soundingPitchClasses(shape);
      for (final pitchClass in sounding) {
        if (!allowedPitchClasses.contains(pitchClass)) {
          issues.add(
            GuitarShapeIssue(
              GuitarShapeIssueCode.foreignChordTone,
              '${shape.id}: contains pitch class ${pitchClass.name} '
              'outside ${shape.quality.id}.',
            ),
          );
        }
      }
      if (!shape.isRootless && !sounding.contains(shape.root)) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.missingRoot,
            '${shape.id}: root is not present.',
          ),
        );
      }
    }

    return GuitarShapeValidation(List.unmodifiable(issues));
  }

  static Map<String, GuitarShapeValidation> validateAll(
    Iterable<GuitarChordShape> shapes,
  ) => {for (final shape in shapes) shape.id: validate(shape)};
}
