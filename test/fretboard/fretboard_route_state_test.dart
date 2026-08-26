import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';

void main() {
  test('direct open uses sensible chord defaults', () {
    final state = FretboardRouteState.fromQuery(const {});
    expect(state.mode, FretboardMode.chord);
    expect(state.root.symbol, 'C');
    expect(state.chordQuality, ChordQuality.major);
    expect(state.scaleDefinition, ScaleDefinition.major);
  });

  test('chord-prefilled route preserves root and quality', () {
    final original = FretboardRouteState(
      root: SpelledPitchClass.tryParse('F#')!,
      chordQuality: ChordQuality.minorSeventh,
    );
    final parsed = FretboardRouteState.fromQuery(original.toQuery());
    expect(parsed.mode, FretboardMode.chord);
    expect(parsed.root.symbol, 'F#');
    expect(parsed.chordQuality, ChordQuality.minorSeventh);
  });

  test('scale-prefilled route preserves root and scale', () {
    final original = FretboardRouteState(
      mode: FretboardMode.scale,
      root: SpelledPitchClass.tryParse('Bb')!,
      scaleDefinition: ScaleDefinition.minorPentatonic,
    );
    final parsed = FretboardRouteState.fromQuery(original.toQuery());
    expect(parsed.mode, FretboardMode.scale);
    expect(parsed.root.symbol, 'Bb');
    expect(parsed.scaleDefinition, ScaleDefinition.minorPentatonic);
  });

  test('malformed parameters safely fall back independently', () {
    final state = FretboardRouteState.fromQuery(const {
      'mode': 'other',
      'root': 'H#',
      'quality': 'unknown',
      'scale': 'mystery',
    });
    expect(state.mode, FretboardMode.chord);
    expect(state.root.symbol, 'C');
    expect(state.chordQuality, ChordQuality.major);
    expect(state.scaleDefinition, ScaleDefinition.major);
  });
}
