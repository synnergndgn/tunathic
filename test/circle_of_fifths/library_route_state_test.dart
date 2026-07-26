import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/chord_library/domain/chord_library_route_state.dart';
import 'package:tunathic/features/scale_library/domain/scale_library_route_state.dart';

void main() {
  group('ScaleLibraryRouteState', () {
    test('round-trips preconfigured root and scale', () {
      final state = ScaleLibraryRouteState.fromQuery(
        const ScaleLibraryRouteState(
          root: SpelledPitchClass(
            letter: NoteLetter.b,
            accidental: Accidental.flat,
          ),
          definition: ScaleDefinition.naturalMinor,
        ).toQuery(),
      );
      expect(state.root.symbol, 'Bb');
      expect(state.definition, ScaleDefinition.naturalMinor);
    });

    test('keeps direct and malformed routes on existing defaults', () {
      for (final query in [
        <String, String>{},
        {'root': 'H', 'scale': 'invented'},
      ]) {
        final state = ScaleLibraryRouteState.fromQuery(query);
        expect(state.root.symbol, 'C');
        expect(state.definition, ScaleDefinition.major);
      }
    });
  });

  group('ChordLibraryRouteState', () {
    test('round-trips preconfigured root and quality', () {
      final state = ChordLibraryRouteState.fromQuery(
        const ChordLibraryRouteState(
          root: SpelledPitchClass(
            letter: NoteLetter.f,
            accidental: Accidental.sharp,
          ),
          quality: ChordQuality.halfDiminishedSeventh,
        ).toQuery(),
      );
      expect(state.root.symbol, 'F#');
      expect(state.quality, ChordQuality.halfDiminishedSeventh);
    });

    test('keeps direct and malformed routes on existing defaults', () {
      for (final query in [
        <String, String>{},
        {'root': 'Q', 'quality': 'invented'},
      ]) {
        final state = ChordLibraryRouteState.fromQuery(query);
        expect(state.root.symbol, 'C');
        expect(state.quality, ChordQuality.major);
      }
    });
  });
}
