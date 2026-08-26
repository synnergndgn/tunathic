import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/interval.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';

enum GuitarStringKind { muted, open, fretted }

final class GuitarStringFingering {
  const GuitarStringFingering._({
    required this.kind,
    required this.fret,
    this.finger,
  });

  const GuitarStringFingering.muted()
    : this._(kind: GuitarStringKind.muted, fret: -1);

  const GuitarStringFingering.open()
    : this._(kind: GuitarStringKind.open, fret: 0);

  const GuitarStringFingering.fretted(int fret, {int? finger})
    : this._(kind: GuitarStringKind.fretted, fret: fret, finger: finger);

  final GuitarStringKind kind;
  final int fret;
  final int? finger;

  bool get isSounding => kind != GuitarStringKind.muted;
}

final class GuitarBarre {
  const GuitarBarre({
    required this.fret,
    required this.fromString,
    required this.toStringIndex,
    this.finger = 1,
  });

  /// Zero-based string index in low-E to high-E order.
  final int fromString;

  /// Zero-based string index in low-E to high-E order.
  final int toStringIndex;

  final int fret;
  final int finger;
}

enum GuitarShapeCategory { open, movableEShape, movableAShape, compact }

enum GuitarShapeDifficulty { beginner, intermediate, advanced }

enum GuitarShapeProvenance { curated, generated }

final class GuitarChordShape {
  const GuitarChordShape({
    required this.id,
    required this.root,
    required this.quality,
    required this.strings,
    required this.startingFret,
    required this.category,
    required this.difficulty,
    this.barres = const [],
    this.omittedIntervals = const [],
    this.isRootless = false,
    this.provenance = GuitarShapeProvenance.curated,
    this.source = 'Tunathic project-owned shape library',
  });

  final String id;
  final PitchClass root;
  final ChordQuality quality;

  /// Six entries in low E, A, D, G, B, high E order.
  final List<GuitarStringFingering> strings;

  final List<GuitarBarre> barres;
  final int startingFret;
  final GuitarShapeCategory category;
  final GuitarShapeDifficulty difficulty;
  final List<TheoryInterval> omittedIntervals;
  final bool isRootless;
  final GuitarShapeProvenance provenance;
  final String source;
}
