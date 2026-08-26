/// The reader's local place in the hub: starred lessons and recent reading.
///
/// This is the only Music Theory state that outlives a session. It holds
/// lesson identifiers and nothing about the reader.
final class TheoryProgress {
  const TheoryProgress({
    this.favoriteIds = const [],
    this.recentIds = const [],
  });

  static const empty = TheoryProgress();

  /// Recent reading is a short trail, not a history log.
  static const maximumRecent = 10;

  final List<String> favoriteIds;
  final List<String> recentIds;

  bool isFavorite(String lessonId) => favoriteIds.contains(lessonId);

  TheoryProgress toggleFavorite(String lessonId) => TheoryProgress(
    favoriteIds: favoriteIds.contains(lessonId)
        ? [
            for (final id in favoriteIds)
              if (id != lessonId) id,
          ]
        : [lessonId, ...favoriteIds],
    recentIds: recentIds,
  );

  /// Moves [lessonId] to the front of the trail, keeping it duplicate free.
  TheoryProgress markViewed(String lessonId) => TheoryProgress(
    favoriteIds: favoriteIds,
    recentIds: [
      lessonId,
      for (final id in recentIds)
        if (id != lessonId) id,
    ].take(maximumRecent).toList(growable: false),
  );

  /// Drops identifiers that no longer exist in the catalog.
  TheoryProgress prunedTo(Set<String> knownLessonIds) => TheoryProgress(
    favoriteIds: [
      for (final id in favoriteIds)
        if (knownLessonIds.contains(id)) id,
    ],
    recentIds: [
      for (final id in recentIds)
        if (knownLessonIds.contains(id)) id,
    ],
  );

  Map<String, Object?> toJson() => {
    'favorites': favoriteIds,
    'recent': recentIds,
  };

  static TheoryProgress? fromJson(Object? value) {
    if (value is! Map) return null;
    return TheoryProgress(
      favoriteIds: _stringList(value['favorites']),
      recentIds: _stringList(value['recent']).take(maximumRecent).toList(),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return [
      for (final entry in value)
        if (entry is String && entry.isNotEmpty) entry,
    ];
  }
}
