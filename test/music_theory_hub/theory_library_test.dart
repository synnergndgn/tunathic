import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/music_theory/domain/theory_action.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';

void main() {
  test('every category has lessons and every lesson has one category', () {
    for (final category in TheoryCategory.values) {
      expect(
        TheoryLibrary.byCategory(category),
        isNotEmpty,
        reason: '${category.id} has no lessons',
      );
    }
    expect(
      TheoryLibrary.lessons.length,
      TheoryCategory.values.fold<int>(
        0,
        (total, category) => total + TheoryLibrary.lessonCount(category),
      ),
    );
  });

  test('lesson identifiers are unique', () {
    final seen = <String>{};
    for (final lesson in TheoryLibrary.lessons) {
      expect(seen.add(lesson.id), isTrue, reason: '${lesson.id} is duplicated');
    }
  });

  test('required interval lessons cover every distance in the octave', () {
    final intervalLessonIds = {
      for (final lesson in TheoryLibrary.byCategory(TheoryCategory.intervals))
        lesson.id,
    };
    expect(
      intervalLessonIds,
      containsAll(<String>{
        'interval-perfect-unison',
        'interval-minor-second',
        'interval-major-second',
        'interval-minor-third',
        'interval-major-third',
        'interval-perfect-fourth',
        'interval-tritone',
        'interval-perfect-fifth',
        'interval-minor-sixth',
        'interval-major-sixth',
        'interval-minor-seventh',
        'interval-major-seventh',
        'interval-octave',
      }),
    );
  });

  test('every interval lesson states size, quality, and a guitar shape', () {
    for (final lesson in TheoryLibrary.byCategory(TheoryCategory.intervals)) {
      if (lesson.id == 'interval-basics') continue;
      expect(
        lesson.blocks.whereType<TheoryIntervalProfile>(),
        isNotEmpty,
        reason: '${lesson.id} has no interval profile',
      );
    }
  });

  test('chord lessons open the Chord Library and scale lessons the Scale '
      'Library', () {
    for (final lesson in TheoryLibrary.byCategory(TheoryCategory.chords)) {
      expect(
        lesson.actions.whereType<OpenChordLibraryAction>().isNotEmpty ||
            lesson.actions.whereType<OpenFretboardAction>().isNotEmpty,
        isTrue,
        reason: '${lesson.id} offers no chord tool',
      );
    }
    for (final lesson in TheoryLibrary.byCategory(TheoryCategory.scales)) {
      expect(
        lesson.actions.whereType<OpenScaleLibraryAction>().isNotEmpty ||
            lesson.actions.whereType<OpenFretboardAction>().isNotEmpty,
        isTrue,
        reason: '${lesson.id} offers no scale tool',
      );
    }
  });

  test(
    'circle lessons open the Circle and fretboard lessons the Fretboard',
    () {
      for (final lesson in TheoryLibrary.byCategory(
        TheoryCategory.circleOfFifths,
      )) {
        expect(
          lesson.actions.whereType<OpenCircleOfFifthsAction>(),
          isNotEmpty,
          reason: '${lesson.id} does not open the Circle',
        );
      }
      for (final lesson in TheoryLibrary.byCategory(
        TheoryCategory.fretboardTheory,
      )) {
        expect(
          lesson.actions.whereType<OpenFretboardAction>(),
          isNotEmpty,
          reason: '${lesson.id} does not open the Interactive Fretboard',
        );
      }
    },
  );

  test('every lesson offers at least one worked example and one action', () {
    for (final lesson in TheoryLibrary.lessons) {
      expect(
        lesson.blocks.whereType<TheoryTryIt>(),
        isNotEmpty,
        reason: '${lesson.id} has no Try it button',
      );
      expect(
        lesson.blocks.any(
          (block) =>
              block is! TheoryParagraph &&
              block is! TheoryBullets &&
              block is! TheoryHeading &&
              block is! TheoryTryIt,
        ),
        isTrue,
        reason: '${lesson.id} is prose only',
      );
    }
  });

  test('every level is represented and lessons are ordered by level', () {
    final levels = {for (final lesson in TheoryLibrary.lessons) lesson.level};
    expect(levels, TheoryLevel.values.toSet());

    for (final category in TheoryCategory.values) {
      final ordered = TheoryLibrary.byCategoryInLearningOrder(category);
      final indices = [
        for (final lesson in ordered) TheoryLevel.values.indexOf(lesson.level),
      ];
      expect(
        indices,
        orderedEquals(indices.toList()..sort()),
        reason: '${category.id} is not ordered beginner first',
      );
      expect(ordered.length, TheoryLibrary.lessonCount(category));
    }
  });

  test('next and previous walk a category and stop at its edges', () {
    final ordered = TheoryLibrary.byCategoryInLearningOrder(
      TheoryCategory.rhythm,
    );
    expect(TheoryLibrary.previous(ordered.first), isNull);
    expect(TheoryLibrary.next(ordered.last), isNull);
    expect(TheoryLibrary.next(ordered.first)?.id, ordered[1].id);
    expect(TheoryLibrary.previous(ordered[1])?.id, ordered.first.id);
  });

  test('lookups reject unknown identifiers', () {
    expect(TheoryLibrary.byId('does-not-exist'), isNull);
    expect(TheoryLibrary.byId(null), isNull);
    expect(TheoryCategory.fromId('nope'), isNull);
    expect(TheoryLevel.fromId('nope'), isNull);
    expect(TheoryLibrary.byIds(['does-not-exist', 'triads']), hasLength(1));
  });

  test('the catalog covers the promised breadth', () {
    expect(TheoryLibrary.lessons.length, greaterThanOrEqualTo(60));
    expect(TheoryCategory.values, hasLength(9));
    expect(
      TheoryLibrary.lessons
          .map((TheoryLesson lesson) => lesson.category)
          .toSet(),
      hasLength(9),
    );
  });
}
