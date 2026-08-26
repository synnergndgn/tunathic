import 'package:tunathic/core/music_theory/music_theory.dart';

final class ChordLibraryRouteState {
  const ChordLibraryRouteState({
    this.root = const SpelledPitchClass(
      letter: NoteLetter.c,
      accidental: Accidental.natural,
    ),
    this.quality = ChordQuality.major,
  });

  final SpelledPitchClass root;
  final ChordQuality quality;

  factory ChordLibraryRouteState.fromQuery(Map<String, String> query) =>
      ChordLibraryRouteState(
        root:
            SpelledPitchClass.tryParse(query['root'] ?? '') ??
            const SpelledPitchClass(
              letter: NoteLetter.c,
              accidental: Accidental.natural,
            ),
        quality:
            ChordQuality.fromId(query['quality'] ?? '') ?? ChordQuality.major,
      );

  Map<String, String> toQuery() => {'root': root.symbol, 'quality': quality.id};
}
