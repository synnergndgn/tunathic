import 'package:tunathic/core/music_theory/chord.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';

final class ParsedChordSymbol {
  const ParsedChordSymbol({required this.root, required this.quality});

  final SpelledPitchClass root;
  final ChordQuality quality;
}

abstract final class ChordSymbolParser {
  static final Map<String, ChordQuality> _qualityBySuffix = {
    for (final quality in ChordQuality.values) quality.symbol: quality,
    'M7': ChordQuality.majorSeventh,
    'min': ChordQuality.minor,
    'min7': ChordQuality.minorSeventh,
    'min9': ChordQuality.minorNinth,
    'min11': ChordQuality.minorEleventh,
    'mMaj7': ChordQuality.minorMajorSeventh,
    'ø7': ChordQuality.halfDiminishedSeventh,
  };

  static ParsedChordSymbol? tryParse(String input) {
    final compact = input.trim().replaceAll(' ', '');
    if (compact.isEmpty) return null;

    final rootLength =
        compact.length >= 2 && '#b♯♭'.contains(compact.substring(1, 2)) ? 2 : 1;
    final root = SpelledPitchClass.tryParse(compact.substring(0, rootLength));
    if (root == null) return null;

    final suffix = compact.substring(rootLength);
    final quality = _qualityBySuffix[suffix];
    if (quality == null) return null;
    return ParsedChordSymbol(root: root, quality: quality);
  }
}
