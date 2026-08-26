import 'package:tunathic/core/music_theory/music_theory.dart';

enum FretboardMode { chord, scale }

final class FretboardRouteState {
  const FretboardRouteState({
    this.mode = FretboardMode.chord,
    this.root = const SpelledPitchClass(
      letter: NoteLetter.c,
      accidental: Accidental.natural,
    ),
    this.chordQuality = ChordQuality.major,
    this.scaleDefinition = ScaleDefinition.major,
  });

  final FretboardMode mode;
  final SpelledPitchClass root;
  final ChordQuality chordQuality;
  final ScaleDefinition scaleDefinition;

  factory FretboardRouteState.fromQuery(Map<String, String> query) {
    final parsedMode = switch (query['mode']) {
      'scale' => FretboardMode.scale,
      'chord' => FretboardMode.chord,
      _ => FretboardMode.chord,
    };
    final parsedRoot = SpelledPitchClass.tryParse(query['root'] ?? '');
    final parsedQuality = ChordQuality.fromId(query['quality'] ?? '');
    final parsedScale = ScaleDefinition.fromIdOrAlias(query['scale'] ?? '');
    return FretboardRouteState(
      mode: parsedMode,
      root:
          parsedRoot ??
          const SpelledPitchClass(
            letter: NoteLetter.c,
            accidental: Accidental.natural,
          ),
      chordQuality: parsedQuality ?? ChordQuality.major,
      scaleDefinition: parsedScale ?? ScaleDefinition.major,
    );
  }

  Map<String, String> toQuery() => {
    'mode': mode.name,
    'root': root.symbol,
    if (mode == FretboardMode.chord) 'quality': chordQuality.id,
    if (mode == FretboardMode.scale) 'scale': scaleDefinition.id,
  };
}
