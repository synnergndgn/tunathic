import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';
import 'package:tunathic/features/repertoire/domain/song_sheet.dart';

/// Reads ChordPro-style song text into a renderable [SongSheet].
///
/// Supported input:
/// - inline chords, for example `[Am]this is a lyric line`
/// - `{comment: ...}` and `{c: ...}` directives, shown as section headings
/// - a bracket token alone on its line, for example `[Chorus]`, shown as a
///   section heading when it is not a chord
///
/// Unknown directives are dropped rather than shown as raw text.
abstract final class ChordProParser {
  static SongSheet parse(String source) {
    if (source.trim().isEmpty) return SongSheet.empty;

    final lines = <SongSheetLine>[];
    for (final raw in source.replaceAll('\r\n', '\n').split('\n')) {
      final line = _parseLine(raw);
      if (line != null) lines.add(line);
    }
    return SongSheet(lines);
  }

  static SongSheetLine? _parseLine(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const SongSheetLine.blank();

    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return _parseDirective(trimmed.substring(1, trimmed.length - 1));
    }

    final segments = _parseSegments(raw);
    if (segments.isEmpty) return const SongSheetLine.blank();

    final onlyChord = segments.length == 1 ? segments.single.chord : null;
    if (onlyChord != null &&
        onlyChord.symbol == null &&
        segments.single.lyrics.trim().isEmpty) {
      return SongSheetLine.section(onlyChord.text);
    }

    return SongSheetLine(kind: SongLineKind.lyrics, segments: segments);
  }

  static SongSheetLine? _parseDirective(String body) {
    final separator = body.indexOf(':');
    if (separator == -1) return null;
    final name = body.substring(0, separator).trim().toLowerCase();
    if (name != 'comment' && name != 'c') return null;
    final value = body.substring(separator + 1).trim();
    return value.isEmpty ? null : SongSheetLine.section(value);
  }

  static List<SongSheetSegment> _parseSegments(String raw) {
    final segments = <SongSheetSegment>[];
    final lyrics = StringBuffer();
    ChordAnnotation? pending;

    void flush() {
      if (pending == null && lyrics.isEmpty) return;
      segments.add(SongSheetSegment(chord: pending, lyrics: lyrics.toString()));
      pending = null;
      lyrics.clear();
    }

    var index = 0;
    while (index < raw.length) {
      final character = raw[index];
      if (character == '[') {
        final close = raw.indexOf(']', index + 1);
        if (close != -1) {
          flush();
          final text = raw.substring(index + 1, close).trim();
          pending = ChordAnnotation(
            text: text,
            symbol: ChordSymbolParser.tryParseWritten(text),
          );
          index = close + 1;
          continue;
        }
      }
      lyrics.write(character);
      index++;
    }
    flush();

    return segments;
  }
}
