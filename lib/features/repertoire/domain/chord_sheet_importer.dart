import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';

/// Converts pasted "chords above lyrics" charts into ChordPro text.
///
/// A chord line is a line whose tokens are all chords or plain chart markers
/// such as `|` and `x2`. Each chord is moved into the following lyric line at
/// the column it was written above, which is what makes transposition safe:
/// once a chord is attached to a syllable its printed width no longer matters.
abstract final class ChordSheetImporter {
  /// Whether [source] holds any plain chord line that should be converted.
  ///
  /// The question is asked per line, not per document: pasting a second verse
  /// as a plain chart into a song whose first verse was already converted has
  /// to convert the new part too. [isChordLine] ignores bracketed lines, so
  /// fully converted text still answers false.
  static bool looksLikePlainChordSheet(String source) =>
      _lines(source).any(isChordLine);

  /// Returns [source] as ChordPro text, converting the plain chord lines in it
  /// and leaving lines that already use bracket chords untouched.
  static String normalize(String source) =>
      looksLikePlainChordSheet(source) ? convert(source) : source;

  static String convert(String source) {
    final lines = _lines(source);
    final converted = <String>[];

    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      if (line.contains('[') || !isChordLine(line)) {
        converted.add(line.trimRight());
        index++;
        continue;
      }

      final next = index + 1 < lines.length ? lines[index + 1] : null;
      final mergeable =
          next != null &&
          next.trim().isNotEmpty &&
          !next.contains('[') &&
          !isChordLine(next);
      if (mergeable) {
        converted.add(_merge(line, next));
        index += 2;
        continue;
      }

      converted.add(_chordOnlyLine(line));
      index++;
    }

    return converted.join('\n');
  }

  /// Whether every token on [line] is a chord or an ordinary chart marker.
  static bool isChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.contains('[')) return false;

    var chordCount = 0;
    for (final token in trimmed.split(RegExp(r'\s+'))) {
      if (ChordSymbolParser.tryParseWritten(token) != null) {
        chordCount++;
        continue;
      }
      if (!_markerPattern.hasMatch(token)) return false;
    }
    return chordCount > 0;
  }

  static String _merge(String chordLine, String lyricLine) {
    var merged = lyricLine.trimRight();
    final tokens = RegExp(r'\S+').allMatches(chordLine).toList();
    for (final token in tokens.reversed) {
      final text = token.group(0)!;
      if (ChordSymbolParser.tryParseWritten(text) == null) continue;
      final column = token.start <= merged.length ? token.start : merged.length;
      merged =
          '${merged.substring(0, column)}[$text]${merged.substring(column)}';
    }
    return merged;
  }

  static String _chordOnlyLine(String chordLine) {
    final parts = <String>[];
    for (final token in RegExp(r'\S+').allMatches(chordLine)) {
      final text = token.group(0)!;
      parts.add(
        ChordSymbolParser.tryParseWritten(text) == null ? text : '[$text]',
      );
    }
    return parts.join(' ');
  }

  static List<String> _lines(String source) =>
      source.replaceAll('\r\n', '\n').split('\n');

  static final _markerPattern = RegExp(
    r'^(?:\|+|:\||\|:|%|[xX][0-9]+|[-–—]+)$',
  );
}
