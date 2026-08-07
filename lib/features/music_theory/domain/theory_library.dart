import 'package:tunathic/features/music_theory/domain/lessons/chord_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/circle_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/fretboard_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/guitar_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/harmony_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/interval_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/musical_notes_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/rhythm_lessons.dart';
import 'package:tunathic/features/music_theory/domain/lessons/scale_lessons.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';

/// The complete offline lesson catalog.
///
/// The catalog is a compile-time constant, so opening the hub costs no I/O and
/// the app works with no network, no account, and no first-run download.
abstract final class TheoryLibrary {
  static const lessons = <TheoryLesson>[
    ...musicalNotesLessons,
    ...intervalLessons,
    ...chordLessons,
    ...scaleLessons,
    ...circleLessons,
    ...fretboardLessons,
    ...rhythmLessons,
    ...harmonyLessons,
    ...guitarLessons,
  ];

  static List<TheoryLesson> byCategory(TheoryCategory category) => [
    for (final lesson in lessons)
      if (lesson.category == category) lesson,
  ];

  /// Lessons of one category ordered beginner first, keeping the authored
  /// order inside each level.
  static List<TheoryLesson> byCategoryInLearningOrder(
    TheoryCategory category,
  ) => [
    for (final level in TheoryLevel.values)
      for (final lesson in lessons)
        if (lesson.category == category && lesson.level == level) lesson,
  ];

  static int lessonCount(TheoryCategory category) {
    var count = 0;
    for (final lesson in lessons) {
      if (lesson.category == category) count++;
    }
    return count;
  }

  static TheoryLesson? byId(String? id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  static List<TheoryLesson> byIds(Iterable<String> ids) => [
    for (final id in ids) ?byId(id),
  ];

  static Set<String> get lessonIds => {for (final lesson in lessons) lesson.id};

  /// The next lesson in the same category, for continuous reading.
  static TheoryLesson? next(TheoryLesson lesson) {
    final ordered = byCategoryInLearningOrder(lesson.category);
    final index = ordered.indexWhere((entry) => entry.id == lesson.id);
    if (index < 0 || index + 1 >= ordered.length) return null;
    return ordered[index + 1];
  }

  static TheoryLesson? previous(TheoryLesson lesson) {
    final ordered = byCategoryInLearningOrder(lesson.category);
    final index = ordered.indexWhere((entry) => entry.id == lesson.id);
    if (index <= 0) return null;
    return ordered[index - 1];
  }
}
