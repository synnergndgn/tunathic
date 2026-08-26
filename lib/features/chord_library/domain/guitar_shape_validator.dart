import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/interval.dart';
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
  undeclaredMissingTone,
  invalidOmission,
  presentOmittedTone,
  invalidBarreFret,
  invalidBarreRange,
  invalidBarreFinger,
  invalidBarreCoverage,
  inconsistentFingerAssignment,
  excessiveFretSpan,
  duplicateId,
  duplicateFingering,
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
  static const maximumFrettedSpan = 4;

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

    final frettedValues = [
      for (final string in shape.strings)
        if (string.kind == GuitarStringKind.fretted) string.fret,
    ];
    if (frettedValues.isNotEmpty) {
      final minimum = frettedValues.reduce((a, b) => a < b ? a : b);
      final maximum = frettedValues.reduce((a, b) => a > b ? a : b);
      if (maximum - minimum > maximumFrettedSpan) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.excessiveFretSpan,
            '${shape.id}: fretted span ${maximum - minimum} exceeds '
            '$maximumFrettedSpan frets.',
          ),
        );
      }
    }

    final stringsByFinger = <int, List<int>>{};
    for (var index = 0; index < shape.strings.length; index++) {
      final finger = shape.strings[index].finger;
      if (finger != null) {
        stringsByFinger.putIfAbsent(finger, () => []).add(index);
      }
    }
    for (final entry in stringsByFinger.entries) {
      final frets = {
        for (final stringIndex in entry.value) shape.strings[stringIndex].fret,
      };
      if (frets.length > 1) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.inconsistentFingerAssignment,
            '${shape.id}: finger ${entry.key} is assigned to multiple frets.',
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
          final string = shape.strings[stringIndex];
          final fret = string.fret;
          if (fret < barre.fret) coverageIsValid = false;
          if (fret == barre.fret) notesAtBarreFret++;
          if (fret == barre.fret &&
              string.finger != null &&
              string.finger != barre.finger) {
            coverageIsValid = false;
          }
          if (fret > barre.fret && string.finger == barre.finger) {
            coverageIsValid = false;
          }
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

      final formulaIntervals = shape.quality.formula.toSet();
      final omittedIntervals = shape.omittedIntervals.toSet();
      if (shape.isRootless &&
          !omittedIntervals.contains(TheoryInterval.perfectUnison)) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidOmission,
            '${shape.id}: a rootless shape must declare the root omitted.',
          ),
        );
      }
      if (omittedIntervals.length != shape.omittedIntervals.length) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.invalidOmission,
            '${shape.id}: omitted intervals must not contain duplicates.',
          ),
        );
      }
      final allowedOmissions = _allowedOmissions(shape);
      for (final interval in omittedIntervals) {
        if (!formulaIntervals.contains(interval)) {
          issues.add(
            GuitarShapeIssue(
              GuitarShapeIssueCode.invalidOmission,
              '${shape.id}: ${interval.id} is not part of the chord formula.',
            ),
          );
          continue;
        }
        if (!allowedOmissions.contains(interval)) {
          issues.add(
            GuitarShapeIssue(
              GuitarShapeIssueCode.invalidOmission,
              '${shape.id}: ${interval.id} is not an allowed omission.',
            ),
          );
        }
        final pitchClass = shape.root.transpose(interval.semitones);
        if (sounding.contains(pitchClass)) {
          issues.add(
            GuitarShapeIssue(
              GuitarShapeIssueCode.presentOmittedTone,
              '${shape.id}: declared omitted tone ${interval.id} is present.',
            ),
          );
        }
      }

      for (final interval in formulaIntervals.difference(omittedIntervals)) {
        final pitchClass = shape.root.transpose(interval.semitones);
        if (!sounding.contains(pitchClass)) {
          issues.add(
            GuitarShapeIssue(
              GuitarShapeIssueCode.undeclaredMissingTone,
              '${shape.id}: required tone ${interval.id} is missing.',
            ),
          );
        }
      }
    }

    return GuitarShapeValidation(List.unmodifiable(issues));
  }

  static Map<String, GuitarShapeValidation> validateAll(
    Iterable<GuitarChordShape> shapes,
  ) => {for (final shape in shapes) shape.id: validate(shape)};

  static GuitarShapeValidation validateCollection(
    Iterable<GuitarChordShape> shapes,
  ) {
    final issues = <GuitarShapeIssue>[];
    final ids = <String>{};
    final fingerings = <String, String>{};
    for (final shape in shapes) {
      if (!ids.add(shape.id)) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.duplicateId,
            '${shape.id}: duplicate shape ID.',
          ),
        );
      }
      final signature = _fingeringSignature(shape);
      final existingId = fingerings[signature];
      if (existingId != null) {
        issues.add(
          GuitarShapeIssue(
            GuitarShapeIssueCode.duplicateFingering,
            '${shape.id}: duplicates the fingering of $existingId.',
          ),
        );
      } else {
        fingerings[signature] = shape.id;
      }
    }
    return GuitarShapeValidation(List.unmodifiable(issues));
  }

  static Set<TheoryInterval> _allowedOmissions(GuitarChordShape shape) {
    final allowed = <TheoryInterval>{};
    if (shape.isRootless) {
      allowed.add(TheoryInterval.perfectUnison);
    }
    if (shape.quality.formula.length >= 4 &&
        shape.quality.formula.contains(TheoryInterval.perfectFifth)) {
      allowed.add(TheoryInterval.perfectFifth);
    }
    if (shape.quality == ChordQuality.eleventh ||
        shape.quality == ChordQuality.minorEleventh ||
        shape.quality == ChordQuality.thirteenth) {
      allowed.add(TheoryInterval.majorNinth);
    }
    return allowed;
  }

  static String _fingeringSignature(GuitarChordShape shape) => [
    shape.root.name,
    shape.quality.id,
    shape.isRootless,
    for (final string in shape.strings) '${string.kind.name}:${string.fret}',
  ].join('|');
}
