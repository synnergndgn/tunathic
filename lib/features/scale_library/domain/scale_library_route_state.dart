import 'package:tunathic/core/music_theory/music_theory.dart';

final class ScaleLibraryRouteState {
  const ScaleLibraryRouteState({
    this.root = const SpelledPitchClass(
      letter: NoteLetter.c,
      accidental: Accidental.natural,
    ),
    this.definition = ScaleDefinition.major,
  });

  final SpelledPitchClass root;
  final ScaleDefinition definition;

  factory ScaleLibraryRouteState.fromQuery(Map<String, String> query) =>
      ScaleLibraryRouteState(
        root:
            SpelledPitchClass.tryParse(query['root'] ?? '') ??
            const SpelledPitchClass(
              letter: NoteLetter.c,
              accidental: Accidental.natural,
            ),
        definition:
            ScaleDefinition.fromIdOrAlias(query['scale'] ?? '') ??
            ScaleDefinition.major,
      );

  Map<String, String> toQuery() => {
    'root': root.symbol,
    'scale': definition.id,
  };
}
