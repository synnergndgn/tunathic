import 'interval_question.dart';
import 'interval_question_generator.dart';

final class IntervalTrainingSessionState {
  const IntervalTrainingSessionState({
    required this.question,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.selectedAnswer,
    this.wasCorrect,
  });

  final IntervalQuestion question;
  final int questionsAnswered;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final String? selectedAnswer;
  final bool? wasCorrect;

  bool get hasAnswered => selectedAnswer != null;
  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;
}

/// In-memory scoring for one visual-theory practice session.
final class IntervalTrainingSession {
  IntervalTrainingSession({
    required IntervalQuestionGenerator generator,
    required IntervalTrainingConfig config,
  }) : _generator = generator,
       _config = config,
       _state = IntervalTrainingSessionState(question: generator.next(config));

  final IntervalQuestionGenerator _generator;
  final IntervalTrainingConfig _config;
  IntervalTrainingSessionState _state;

  IntervalTrainingSessionState get state => _state;

  /// Returns false after a result has already been recorded for this question.
  bool submit(String answer) {
    if (_state.hasAnswered) return false;
    final correct = answer == _state.question.correctAnswer;
    final streak = correct ? _state.currentStreak + 1 : 0;
    _state = IntervalTrainingSessionState(
      question: _state.question,
      questionsAnswered: _state.questionsAnswered + 1,
      correctAnswers: _state.correctAnswers + (correct ? 1 : 0),
      currentStreak: streak,
      bestStreak: streak > _state.bestStreak ? streak : _state.bestStreak,
      selectedAnswer: answer,
      wasCorrect: correct,
    );
    return true;
  }

  bool next() {
    if (!_state.hasAnswered) return false;
    _state = IntervalTrainingSessionState(
      question: _generator.next(_config),
      questionsAnswered: _state.questionsAnswered,
      correctAnswers: _state.correctAnswers,
      currentStreak: _state.currentStreak,
      bestStreak: _state.bestStreak,
    );
    return true;
  }
}
