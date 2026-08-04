/// Places, replaces, and removes chord brackets in ChordPro song text.
///
/// Every edit is a plain string operation on the stored text, driven by the
/// source positions the parser recorded. Keeping it here means tapping a word
/// on screen and typing a bracket by hand produce exactly the same content.
abstract final class SongChordEditor {
  /// Writes `[chord]` at [offset].
  static String insert(
    String content, {
    required int offset,
    required String chord,
  }) {
    final symbol = chord.trim();
    if (symbol.isEmpty) return content;
    final at = _clamp(offset, content.length);
    return '${content.substring(0, at)}[$symbol]${content.substring(at)}';
  }

  /// Replaces the bracket spanning [start] until [end] with `[chord]`.
  static String replace(
    String content, {
    required int start,
    required int end,
    required String chord,
  }) {
    final symbol = chord.trim();
    if (symbol.isEmpty) return content;
    if (!_isValidSpan(content, start, end)) return content;
    return '${content.substring(0, start)}[$symbol]${content.substring(end)}';
  }

  /// Deletes the bracket spanning [start] until [end].
  static String remove(String content, {required int start, required int end}) {
    if (!_isValidSpan(content, start, end)) return content;
    return content.substring(0, start) + content.substring(end);
  }

  static bool _isValidSpan(String content, int start, int end) =>
      start >= 0 && end <= content.length && start < end;

  static int _clamp(int offset, int length) {
    if (offset < 0) return 0;
    return offset > length ? length : offset;
  }
}
