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

    // Lines are walked by index rather than split, so every chord and lyric
    // fragment keeps its position in the original text. The chord editor uses
    // those positions to place a bracket on the word the performer taps.
    final lines = <SongSheetLine>[];
    var lineStart = 0;
    while (true) {
      final newline = source.indexOf('\n', lineStart);
      final lineEnd = newline == -1 ? source.length : newline;
      var text = source.substring(lineStart, lineEnd);
      if (text.endsWith('\r')) {
        text = text.substring(0, text.length - 1);
      }

      final line = _parseLine(text, lineStart);
      if (line != null) lines.add(line);

      if (newline == -1) break;
      lineStart = newline + 1;
    }
    return SongSheet(lines);
  }

  static SongSheetLine? _parseLine(String raw, int lineOffset) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const SongSheetLine.blank();

    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return _parseDirective(trimmed.substring(1, trimmed.length - 1));
    }

    final segments = _parseSegments(raw, lineOffset);
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

  static List<SongSheetSegment> _parseSegments(String raw, int lineOffset) {
    final segments = <SongSheetSegment>[];
    final lyrics = StringBuffer();
    ChordAnnotation? pending;
    var lyricsStart = lineOffset;

    void flush() {
      if (pending == null && lyrics.isEmpty) return;
      segments.add(
        SongSheetSegment(
          chord: pending,
          lyrics: lyrics.toString(),
          lyricsOffset: lyricsStart,
        ),
      );
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
            sourceStart: lineOffset + index,
            sourceEnd: lineOffset + close + 1,
          );
          index = close + 1;
          lyricsStart = lineOffset + index;
          continue;
        }
      }
      if (pending == null && lyrics.isEmpty) {
        lyricsStart = lineOffset + index;
      }
      lyrics.write(character);
      index++;
    }
    flush();

    return segments;
  }
}
