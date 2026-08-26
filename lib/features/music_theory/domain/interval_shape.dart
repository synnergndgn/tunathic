import 'package:tunathic/core/music_theory/music_theory.dart';

/// Two fretboard points a fixed interval apart.
///
/// Strings are indexed low to high, matching [GuitarTuning].
final class IntervalShape {
  const IntervalShape({
    required this.interval,
    required this.rootStringIndex,
    required this.rootFret,
    required this.targetStringIndex,
    required this.targetFret,
  });

  final TheoryInterval interval;
  final int rootStringIndex;
  final int rootFret;
  final int targetStringIndex;
  final int targetFret;

  /// How many strings the shape crosses. Zero means it stays on one string.
  int get stringSpan => targetStringIndex - rootStringIndex;

  /// How many frets the hand moves. Negative means the target sits behind the
  /// root, which is normal once the shape crosses to a higher string.
  int get fretSpan => targetFret - rootFret;

  int get lowestFret => rootFret < targetFret ? rootFret : targetFret;

  int get highestFret => rootFret > targetFret ? rootFret : targetFret;
}

/// Derives playable interval shapes from a tuning instead of storing diagrams.
///
/// Guitarists learn intervals as hand shapes, so the search prefers the
/// closest string that keeps the reach small, and only falls back to staying
/// on one string when no neighbouring string can hold the note.
abstract final class IntervalShapes {
  /// The widest comfortable reach, in frets, for a two-note shape.
  static const maximumReach = 5;

  static IntervalShape? findFrom({
    required TheoryInterval interval,
    GuitarTuning tuning = GuitarTuning.standard,
    int rootStringIndex = 1,
    int rootFret = 5,
    int maximumFret = GuitarFretboard.maximumSupportedFret,
  }) {
    if (rootStringIndex < 0 || rootStringIndex >= tuning.strings.length) {
      return null;
    }
    if (rootFret < 0 || rootFret > maximumFret) return null;

    final rootMidi = tuning.strings[rootStringIndex].openMidiNote + rootFret;
    final targetMidi = rootMidi + interval.semitones;

    IntervalShape? best;
    var bestCost = 1 << 30;
    for (
      var stringIndex = rootStringIndex;
      stringIndex < tuning.strings.length;
      stringIndex++
    ) {
      final fret = targetMidi - tuning.strings[stringIndex].openMidiNote;
      if (fret < 0 || fret > maximumFret) continue;
      final reach = (fret - rootFret).abs();
      if (reach > maximumReach) continue;

      // Crossing strings is idiomatic; a long reach on one string is not.
      final cost = reach * 2 + (stringIndex - rootStringIndex);
      if (cost < bestCost) {
        bestCost = cost;
        best = IntervalShape(
          interval: interval,
          rootStringIndex: rootStringIndex,
          rootFret: rootFret,
          targetStringIndex: stringIndex,
          targetFret: fret,
        );
      }
    }
    return best;
  }
}
