import 'dart:math';

import 'interval_identity.dart';
import 'interval_question.dart';
import 'spelled_note.dart';

/// Produces one spelling-correct question at a time from a seeded [Random].
///
/// A shuffled interval bag keeps coverage even across a session. Roots and
/// directions are then sampled only from combinations that can be spelled with
/// at most one accidental. No question table is stored or consulted.
final class IntervalQuestionGenerator {
  IntervalQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<IntervalIdentity> _intervalBag = [];
  String? _bagSignature;
  String? _previousSignature;

  IntervalQuestion next(IntervalTrainingConfig config) {
    final identities = config.difficulty.identities;
    final configSignature = identities.map((item) => item.name).join(',');
    if (_bagSignature != configSignature || _intervalBag.isEmpty) {
      _intervalBag
        ..clear()
        ..addAll(identities)
        ..shuffle(_random);
      _bagSignature = configSignature;
    }

    final interval = _intervalBag.removeLast();
    final roots = config.difficulty == IntervalDifficulty.advanced
        ? SpelledNote.singleAccidentalNotes
        : SpelledNote.naturalNotes;
    final directions = config.direction.choices;

    for (var attempt = 0; attempt < 80; attempt++) {
      final root = roots[_random.nextInt(roots.length)];
      final direction = directions[_random.nextInt(directions.length)];
      final target = SpelledNote.constructInterval(root, interval, direction);
      if (target == null) continue;
      final question = IntervalQuestion(
        mode: config.mode,
        root: root,
        target: target,
        interval: interval,
        direction: direction,
        answerOptions: _answerOptions(config, target, interval),
      );
      if (question.signature != _previousSignature || attempt > 20) {
        _previousSignature = question.signature;
        return question;
      }
    }

    throw StateError(
      'No supported spelling for the selected interval options.',
    );
  }

  List<String> _answerOptions(
    IntervalTrainingConfig config,
    SpelledNote target,
    IntervalIdentity interval,
  ) {
    if (config.mode == IntervalTrainingMode.identifyInterval) {
      final candidates = List<IntervalIdentity>.of(config.difficulty.identities)
        ..remove(interval)
        ..shuffle(_random);
      return ([
        interval,
        ...candidates.take(5),
      ]..shuffle(_random)).map((item) => item.name).toList(growable: false);
    }

    final notes = <SpelledNote>{
      ...SpelledNote.naturalNotes,
      if (config.difficulty == IntervalDifficulty.advanced)
        ...SpelledNote.singleAccidentalNotes,
    }.toList()..remove(target);
    notes.shuffle(_random);
    return ([
      target.display,
      ...notes.take(5).map((item) => item.display),
    ]..shuffle(_random)).toList(growable: false);
  }
}
