import 'package:tunathic/features/music_theory/domain/theory_content.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

/// One lesson matched by a query, with the rank that ordered it.
final class TheorySearchResult {
  const TheorySearchResult({required this.lesson, required this.score});

  final TheoryLesson lesson;
  final int score;
}

/// Offline lesson search over titles, aliases, keywords, and summaries.
///
/// Matching is substring based rather than fuzzy: a reader searching `m7b5`
/// or `aralık` should get the lesson, and should not get four unrelated ones.
/// Turkish letters fold to their ASCII base so `muzik` finds `müzik`.
abstract final class TheorySearch {
  static const _titleStartScore = 100;
  static const _titleContainsScore = 80;
  static const _aliasScore = 70;
  static const _keywordScore = 50;
  static const _summaryScore = 20;

  static List<TheorySearchResult> rank({
    required Iterable<TheoryLesson> lessons,
    required TheoryContent content,
    required String query,
    TheoryLevel? level,
  }) {
    final normalizedQuery = normalize(query);
    final results = <TheorySearchResult>[];
    for (final lesson in lessons) {
      if (level != null && lesson.level != level) continue;
      if (normalizedQuery.isEmpty) {
        results.add(TheorySearchResult(lesson: lesson, score: 0));
        continue;
      }
      final score = _score(lesson, content, normalizedQuery);
      if (score > 0) {
        results.add(TheorySearchResult(lesson: lesson, score: score));
      }
    }
    if (normalizedQuery.isEmpty) return results;

    final ordered = [...results]
      ..sort((first, second) {
        final byScore = second.score.compareTo(first.score);
        if (byScore != 0) return byScore;
        return first.lesson.id.compareTo(second.lesson.id);
      });
    return ordered;
  }

  static List<TheoryLesson> query({
    required Iterable<TheoryLesson> lessons,
    required TheoryContent content,
    required String query,
    TheoryLevel? level,
  }) => [
    for (final result in rank(
      lessons: lessons,
      content: content,
      query: query,
      level: level,
    ))
      result.lesson,
  ];

  static int _score(TheoryLesson lesson, TheoryContent content, String query) {
    final title = normalize(content.text(lesson.titleId));
    if (title.startsWith(query)) return _titleStartScore;
    if (title.contains(query)) return _titleContainsScore;

    for (final alias in lesson.aliases) {
      final normalizedAlias = normalize(alias);
      if (normalizedAlias == query || normalizedAlias.startsWith(query)) {
        return _aliasScore;
      }
    }

    final keywords = content.maybeText(lesson.keywordsId);
    if (keywords != null) {
      for (final keyword in keywords.split(',')) {
        final normalizedKeyword = normalize(keyword);
        if (normalizedKeyword.isEmpty) continue;
        if (normalizedKeyword.contains(query)) return _keywordScore;
      }
    }

    final summary = normalize(content.text(lesson.summaryId));
    if (summary.contains(query)) return _summaryScore;

    return 0;
  }

  /// Lowercases, folds Turkish letters, and collapses whitespace.
  static String normalize(String value) {
    final buffer = StringBuffer();
    var lastWasSpace = true;
    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      final folded = _folded[character] ?? character.toLowerCase();
      if (folded.trim().isEmpty) {
        if (!lastWasSpace) buffer.write(' ');
        lastWasSpace = true;
        continue;
      }
      buffer.write(folded);
      lastWasSpace = false;
    }
    return buffer.toString().trimRight();
  }

  static const _folded = {
    'ç': 'c',
    'Ç': 'c',
    'ğ': 'g',
    'Ğ': 'g',
    'ı': 'i',
    'I': 'i',
    'İ': 'i',
    'ö': 'o',
    'Ö': 'o',
    'ş': 's',
    'Ş': 's',
    'ü': 'u',
    'Ü': 'u',
    '♭': 'b',
    '♯': '#',
  };
}
