import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_identity.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_question.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_question_generator.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_training_session.dart';
import 'package:tunathic/features/interval_trainer/domain/spelled_note.dart';

void main() {
  group('SpelledNote interval construction', () {
    test('constructs ascending and descending intervals structurally', () {
      expect(
        SpelledNote.constructInterval(
          const SpelledNote(NoteLetter.c),
          IntervalIdentity.perfectFifth,
          IntervalDirection.ascending,
        )?.display,
        'G',
      );
      expect(
        SpelledNote.constructInterval(
          const SpelledNote(NoteLetter.d),
          IntervalIdentity.minorThird,
          IntervalDirection.descending,
        )?.display,
        'B',
      );
    });

    test('keeps the two tritone spellings structurally distinct', () {
      const c = SpelledNote(NoteLetter.c);
      expect(
        SpelledNote.constructInterval(
          c,
          IntervalIdentity.augmentedFourth,
          IntervalDirection.ascending,
        )?.display,
        'F#',
      );
      expect(
        SpelledNote.constructInterval(
          c,
          IntervalIdentity.diminishedFifth,
          IntervalDirection.ascending,
        )?.display,
        'Gb',
      );
    });

    test('refuses a construction that would need a double accidental', () {
      expect(
        SpelledNote.constructInterval(
          const SpelledNote(NoteLetter.c, NoteAccidental.sharp),
          IntervalIdentity.augmentedFourth,
          IntervalDirection.ascending,
        ),
        isNull,
      );
    });
  });

  group('IntervalQuestionGenerator', () {
    const advanced = IntervalTrainingConfig(
      mode: IntervalTrainingMode.findTargetNote,
      difficulty: IntervalDifficulty.advanced,
      direction: IntervalDirectionPreference.mixed,
    );

    test('is deterministic with a seeded random source', () {
      final first = IntervalQuestionGenerator(random: Random(42));
      final second = IntervalQuestionGenerator(random: Random(42));
      final firstQuestions = List.generate(20, (_) => first.next(advanced));
      final secondQuestions = List.generate(20, (_) => second.next(advanced));

      expect(
        firstQuestions.map((question) => question.signature),
        secondQuestions.map((question) => question.signature),
      );
    });

    test(
      'avoids immediate identical questions and retains target spelling',
      () {
        final generator = IntervalQuestionGenerator(random: Random(8));
        String? previous;
        for (var index = 0; index < 70; index++) {
          final question = generator.next(advanced);
          expect(question.signature, isNot(previous));
          expect(question.answerOptions, contains(question.target.display));
          previous = question.signature;
        }
      },
    );

    test('filters intervals and directions by the selected configuration', () {
      const beginner = IntervalTrainingConfig(
        difficulty: IntervalDifficulty.beginner,
        direction: IntervalDirectionPreference.descending,
      );
      final generator = IntervalQuestionGenerator(random: Random(4));
      for (var index = 0; index < 28; index++) {
        final question = generator.next(beginner);
        expect(
          IntervalDifficulty.beginner.identities,
          contains(question.interval),
        );
        expect(question.direction, IntervalDirection.descending);
      }
    });
  });

  test('session scores accuracy and streaks and protects double answers', () {
    final generator = IntervalQuestionGenerator(random: Random(1));
    final session = IntervalTrainingSession(
      generator: generator,
      config: const IntervalTrainingConfig(),
    );
    final firstAnswer = session.state.question.correctAnswer;

    expect(session.submit(firstAnswer), isTrue);
    expect(session.submit(firstAnswer), isFalse);
    expect(session.state.questionsAnswered, 1);
    expect(session.state.correctAnswers, 1);
    expect(session.state.currentStreak, 1);
    expect(session.state.bestStreak, 1);
    expect(session.state.accuracy, 1);

    expect(session.next(), isTrue);
    final wrongAnswer = session.state.question.answerOptions.firstWhere(
      (answer) => answer != session.state.question.correctAnswer,
    );
    expect(session.submit(wrongAnswer), isTrue);
    expect(session.state.questionsAnswered, 2);
    expect(session.state.correctAnswers, 1);
    expect(session.state.currentStreak, 0);
    expect(session.state.bestStreak, 1);
    expect(session.state.accuracy, 0.5);
    expect(session.next(), isTrue);
  });
}
