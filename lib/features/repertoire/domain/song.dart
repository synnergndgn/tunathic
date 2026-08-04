/// A user-authored song stored on this device.
///
/// [content] holds ChordPro-style text, where chords appear in square brackets
/// immediately before the syllable they are played on.
final class Song {
  const Song({
    required this.id,
    required this.title,
    this.artist = '',
    this.content = '',
    this.transpose = 0,
    this.scrollSpeedLevel = defaultScrollSpeedLevel,
    this.updatedAt,
  });

  static const minTranspose = -11;
  static const maxTranspose = 11;
  static const minScrollSpeedLevel = 1;
  static const maxScrollSpeedLevel = 10;
  static const defaultScrollSpeedLevel = 3;

  final String id;
  final String title;
  final String artist;
  final String content;

  /// Performance transposition in semitones, relative to the written chords.
  final int transpose;

  /// Preferred auto-scroll speed for this song.
  final int scrollSpeedLevel;

  final DateTime? updatedAt;

  Song copyWith({
    String? title,
    String? artist,
    String? content,
    int? transpose,
    int? scrollSpeedLevel,
    DateTime? updatedAt,
  }) => Song(
    id: id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    content: content ?? this.content,
    transpose: clampTranspose(transpose ?? this.transpose),
    scrollSpeedLevel: clampScrollSpeedLevel(
      scrollSpeedLevel ?? this.scrollSpeedLevel,
    ),
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static int clampTranspose(int value) {
    if (value < minTranspose) return minTranspose;
    if (value > maxTranspose) return maxTranspose;
    return value;
  }

  static int clampScrollSpeedLevel(int value) {
    if (value < minScrollSpeedLevel) return minScrollSpeedLevel;
    if (value > maxScrollSpeedLevel) return maxScrollSpeedLevel;
    return value;
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'content': content,
    'transpose': transpose,
    'scrollSpeedLevel': scrollSpeedLevel,
    if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
  };

  /// Reads a stored song, returning null when the entry is unusable.
  ///
  /// Individual fields fall back to defaults so that a partially written entry
  /// still restores the user's lyrics.
  static Song? fromJson(Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    if (id is! String || id.isEmpty) return null;
    final title = value['title'];
    if (title is! String) return null;

    final storedUpdatedAt = value['updatedAt'];
    return Song(
      id: id,
      title: title,
      artist: value['artist'] is String ? value['artist'] as String : '',
      content: value['content'] is String ? value['content'] as String : '',
      transpose: clampTranspose(
        value['transpose'] is int ? value['transpose'] as int : 0,
      ),
      scrollSpeedLevel: clampScrollSpeedLevel(
        value['scrollSpeedLevel'] is int
            ? value['scrollSpeedLevel'] as int
            : defaultScrollSpeedLevel,
      ),
      updatedAt: storedUpdatedAt is String
          ? DateTime.tryParse(storedUpdatedAt)
          : null,
    );
  }
}
