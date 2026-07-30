import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_identity.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_question.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_question_generator.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_training_session.dart';
import 'package:tunathic/features/interval_trainer/domain/spelled_note.dart';

final intervalTrainerProvider =
    NotifierProvider<IntervalTrainerController, IntervalTrainerViewState>(
      IntervalTrainerController.new,
    );

final class IntervalTrainerViewState {
  const IntervalTrainerViewState({required this.config, required this.session});

  final IntervalTrainingConfig config;
  final IntervalTrainingSessionState session;
}

final class IntervalTrainerController
    extends Notifier<IntervalTrainerViewState> {
  late IntervalQuestionGenerator _generator;
  late IntervalTrainingSession _session;

  @override
  IntervalTrainerViewState build() {
    _generator = IntervalQuestionGenerator();
    _sessionConfig = const IntervalTrainingConfig();
    _session = IntervalTrainingSession(
      generator: _generator,
      config: _sessionConfig!,
    );
    return _viewState;
  }

  void setMode(IntervalTrainingMode mode) =>
      _restart(state.config.copyWith(mode: mode));

  void setDifficulty(IntervalDifficulty difficulty) =>
      _restart(state.config.copyWith(difficulty: difficulty));

  void setDirection(IntervalDirectionPreference direction) =>
      _restart(state.config.copyWith(direction: direction));

  void submit(String answer) {
    if (_session.submit(answer)) state = _viewState;
  }

  void next() {
    if (_session.next()) state = _viewState;
  }

  IntervalTrainerViewState get _viewState => IntervalTrainerViewState(
    config: _sessionConfig!,
    session: _session.state,
  );
  IntervalTrainingConfig? _sessionConfig;

  void _restart(IntervalTrainingConfig config) {
    _sessionConfig = config;
    _session = IntervalTrainingSession(generator: _generator, config: config);
    state = _viewState;
  }
}
