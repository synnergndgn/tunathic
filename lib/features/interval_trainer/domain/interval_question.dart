import 'interval_identity.dart';
import 'spelled_note.dart';

enum IntervalTrainingMode { identifyInterval, findTargetNote }

final class IntervalTrainingConfig {
  const IntervalTrainingConfig({
    this.mode = IntervalTrainingMode.identifyInterval,
    this.difficulty = IntervalDifficulty.beginner,
    this.direction = IntervalDirectionPreference.mixed,
  });

  final IntervalTrainingMode mode;
  final IntervalDifficulty difficulty;
  final IntervalDirectionPreference direction;

  IntervalTrainingConfig copyWith({
    IntervalTrainingMode? mode,
    IntervalDifficulty? difficulty,
    IntervalDirectionPreference? direction,
  }) => IntervalTrainingConfig(
    mode: mode ?? this.mode,
    difficulty: difficulty ?? this.difficulty,
    direction: direction ?? this.direction,
  );
}

final class IntervalQuestion {
  const IntervalQuestion({
    required this.mode,
    required this.root,
    required this.target,
    required this.interval,
    required this.direction,
    required this.answerOptions,
  });

  final IntervalTrainingMode mode;
  final SpelledNote root;
  final SpelledNote target;
  final IntervalIdentity interval;
  final IntervalDirection direction;
  final List<String> answerOptions;

  String get correctAnswer => switch (mode) {
    IntervalTrainingMode.identifyInterval => interval.name,
    IntervalTrainingMode.findTargetNote => target.display,
  };

  String get signature =>
      '${mode.name}:${root.display}:${target.display}:${interval.name}:${direction.name}';
}
