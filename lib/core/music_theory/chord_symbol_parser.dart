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

  /// Parses a written chord symbol without resolving it to a [ChordQuality].
  ///
  /// Chord charts contain far more suffixes than the library models, so the
  /// suffix is preserved verbatim and only the root and optional slash bass are
  /// interpreted. The accepted suffix alphabet stays deliberately narrow so
  /// ordinary words that begin with a note letter are rejected.
  static WrittenChordSymbol? tryParseWritten(String input) {
    final compact = input.trim();
    if (compact.isEmpty) return null;

    final slashIndex = compact.indexOf('/');
    final rootPart = slashIndex == -1
        ? compact
        : compact.substring(0, slashIndex);
    final bassPart = slashIndex == -1
        ? null
        : compact.substring(slashIndex + 1);

    final rootLength =
        rootPart.length >= 2 && _accidentals.contains(rootPart.substring(1, 2))
        ? 2
        : 1;
    final root = SpelledPitchClass.tryParse(rootPart.substring(0, rootLength));
    if (root == null) return null;

    final suffix = rootPart.substring(rootLength);
    if (!_suffixPattern.hasMatch(suffix)) return null;

    SpelledPitchClass? bass;
    if (bassPart != null) {
      bass = SpelledPitchClass.tryParse(bassPart);
      if (bass == null) return null;
    }

    return WrittenChordSymbol(root: root, suffix: suffix, bass: bass);
  }

  static const _accidentals = '#b♯♭';

  static final _suffixPattern = RegExp(
    r'^(?:maj|Maj|MAJ|min|Min|dim|Dim|aug|Aug|sus|add|alt|no|M|m|°|ø|Δ|\+|-|\(|\)|[0-9]|#|b|♯|♭)*$',
  );
}

/// A chord symbol exactly as it appears in a chart, with a transposable root.
final class WrittenChordSymbol {
  const WrittenChordSymbol({required this.root, this.suffix = '', this.bass});

  final SpelledPitchClass root;

  /// The quality text as written, for example `m7`, `sus4`, or `add9`.
  final String suffix;

  /// The slash bass note, when the symbol names one.
  final SpelledPitchClass? bass;

  String get symbol {
    final slash = bass == null ? '' : '/${bass!.symbol}';
    return '${root.symbol}$suffix$slash';
  }

  WrittenChordSymbol transpose(
    int semitones, {
    SpellingPreference preference = SpellingPreference.contextual,
  }) {
    if (semitones == 0) return this;
    return WrittenChordSymbol(
      root: NoteSpelling.forPitchClass(
        root.pitchClass.transpose(semitones),
        preference: preference,
      ),
      suffix: suffix,
      bass: bass == null
          ? null
          : NoteSpelling.forPitchClass(
              bass!.pitchClass.transpose(semitones),
              preference: preference,
            ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WrittenChordSymbol &&
      root == other.root &&
      suffix == other.suffix &&
      bass == other.bass;

  @override
  int get hashCode => Object.hash(root, suffix, bass);

  @override
  String toString() => symbol;
}
