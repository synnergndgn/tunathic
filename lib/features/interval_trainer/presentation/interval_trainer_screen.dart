import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_identity.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_question.dart';
import 'package:tunathic/features/interval_trainer/domain/interval_training_session.dart';
import 'package:tunathic/features/interval_trainer/domain/spelled_note.dart';
import 'package:tunathic/features/interval_trainer/presentation/interval_trainer_controller.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class IntervalTrainerScreen extends ConsumerWidget {
  const IntervalTrainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(intervalTrainerProvider);
    final controller = ref.read(intervalTrainerProvider.notifier);
    final haptics = ref.read(appHapticsProvider);
    final session = state.session;
    final question = session.question;

    void submit(String answer) {
      if (session.hasAnswered) return;
      unawaited(haptics.lightImpact());
      controller.submit(answer);
    }

    return Scaffold(
      appBar: AppBar(title: Text(localizations.intervalTrainer)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              key: const Key('intervalTrainerScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.small,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                _ConfigurationControls(
                  config: state.config,
                  localizations: localizations,
                  onMode: controller.setMode,
                  onDifficulty: controller.setDifficulty,
                  onDirection: controller.setDirection,
                ),
                const SizedBox(height: AppSpacing.large),
                _QuestionCard(question: question, localizations: localizations),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  question.mode == IntervalTrainingMode.identifyInterval
                      ? localizations.intervalIdentifyPrompt
                      : localizations.intervalFindTargetPrompt,
                  key: const Key('intervalPrompt'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.medium),
                _AnswerGrid(
                  question: question,
                  hasAnswered: session.hasAnswered,
                  localizations: localizations,
                  onAnswer: submit,
                ),
                if (session.hasAnswered) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _FeedbackCard(session: session, localizations: localizations),
                  const SizedBox(height: AppSpacing.medium),
                  FilledButton.icon(
                    key: const Key('intervalNext'),
                    onPressed: () {
                      unawaited(haptics.selection());
                      controller.next();
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(localizations.next),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                _SessionStats(session: session, localizations: localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _ConfigurationControls extends StatelessWidget {
  const _ConfigurationControls({
    required this.config,
    required this.localizations,
    required this.onMode,
    required this.onDifficulty,
    required this.onDirection,
  });

  final IntervalTrainingConfig config;
  final AppLocalizations localizations;
  final ValueChanged<IntervalTrainingMode> onMode;
  final ValueChanged<IntervalDifficulty> onDifficulty;
  final ValueChanged<IntervalDirectionPreference> onDirection;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingSegment<IntervalTrainingMode>(
              label: localizations.intervalMode,
              selected: config.mode,
              entries: [
                (
                  IntervalTrainingMode.identifyInterval,
                  localizations.identifyInterval,
                ),
                (
                  IntervalTrainingMode.findTargetNote,
                  localizations.findTargetNote,
                ),
              ],
              onSelected: onMode,
            ),
            const SizedBox(height: AppSpacing.medium),
            _SettingSegment<IntervalDifficulty>(
              label: localizations.difficulty,
              selected: config.difficulty,
              entries: [
                (IntervalDifficulty.beginner, localizations.beginner),
                (IntervalDifficulty.intermediate, localizations.intermediate),
                (IntervalDifficulty.advanced, localizations.advanced),
              ],
              onSelected: onDifficulty,
            ),
            const SizedBox(height: AppSpacing.medium),
            _SettingSegment<IntervalDirectionPreference>(
              label: localizations.direction,
              selected: config.direction,
              entries: [
                (
                  IntervalDirectionPreference.ascending,
                  localizations.ascending,
                ),
                (
                  IntervalDirectionPreference.descending,
                  localizations.descending,
                ),
                (IntervalDirectionPreference.mixed, localizations.mixed),
              ],
              onSelected: onDirection,
            ),
          ],
        ),
      ),
    );
  }
}

final class _SettingSegment<T> extends StatelessWidget {
  const _SettingSegment({
    required this.label,
    required this.selected,
    required this.entries,
    required this.onSelected,
  });

  final String label;
  final T selected;
  final List<(T, String)> entries;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.small),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 440 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.25;
            if (compact) {
              return Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final entry in entries)
                    Semantics(
                      selected: selected == entry.$1,
                      child: SizedBox(
                        height: AppSpacing.minTouchTarget,
                        child: OutlinedButton(
                          onPressed: () => onSelected(entry.$1),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected == entry.$1
                                ? Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer
                                : null,
                          ),
                          child: Text(entry.$2),
                        ),
                      ),
                    ),
                ],
              );
            }
            return SegmentedButton<T>(
              segments: entries
                  .map(
                    (entry) => ButtonSegment<T>(
                      value: entry.$1,
                      label: Text(entry.$2, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              selected: {selected},
              showSelectedIcon: false,
              multiSelectionEnabled: false,
              emptySelectionAllowed: false,
              expandedInsets: EdgeInsets.zero,
              onSelectionChanged: (selection) => onSelected(selection.first),
            );
          },
        ),
      ],
    );
  }
}

final class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.localizations});

  final IntervalQuestion question;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final directionLabel = question.direction == IntervalDirection.ascending
        ? localizations.ascending
        : localizations.descending;
    return Semantics(
      liveRegion: true,
      label: localizations.intervalQuestionSemantics(
        question.root.display,
        question.target.display,
        directionLabel,
      ),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.xLarge,
            ),
            child: Column(
              children: [
                Text(
                  directionLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: _NoteText(note: question.root.display)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                      ),
                      child: Icon(
                        question.direction == IntervalDirection.ascending
                            ? Icons.arrow_forward
                            : Icons.arrow_downward,
                        size: 32,
                      ),
                    ),
                    Flexible(child: _NoteText(note: question.target.display)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _NoteText extends StatelessWidget {
  const _NoteText({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      note,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
  );
}

final class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.question,
    required this.hasAnswered,
    required this.localizations,
    required this.onAnswer,
  });

  final IntervalQuestion question;
  final bool hasAnswered;
  final AppLocalizations localizations;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 520 ? 2 : 1;
      final width =
          (constraints.maxWidth - AppSpacing.small * (columns - 1)) / columns;
      return Wrap(
        spacing: AppSpacing.small,
        runSpacing: AppSpacing.small,
        children: [
          for (final answer in question.answerOptions)
            SizedBox(
              width: width,
              child: Semantics(
                button: true,
                label: localizations.intervalAnswerSemantics(
                  _answerLabel(question, answer, localizations),
                ),
                child: OutlinedButton(
                  key: Key('intervalAnswer_$answer'),
                  onPressed: hasAnswered ? null : () => onAnswer(answer),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppSpacing.minTouchTarget,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(_answerLabel(question, answer, localizations)),
                ),
              ),
            ),
        ],
      );
    },
  );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.session, required this.localizations});

  final IntervalTrainingSessionState session;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final question = session.question;
    final correct = session.wasCorrect!;
    final answer = _answerLabel(
      question,
      question.correctAnswer,
      localizations,
    );
    final interval = _intervalLabel(question.interval, localizations);
    final message = correct
        ? localizations.intervalCorrectFeedback(
            question.root.display,
            question.target.display,
            interval,
            question.interval.semitones,
          )
        : localizations.intervalIncorrectFeedback(
            answer,
            question.root.display,
            question.target.display,
            interval,
            question.interval.semitones,
          );
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label:
          '${correct ? localizations.correct : localizations.incorrect}. $message',
      child: Card(
        color: correct ? colors.secondaryContainer : colors.errorContainer,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  correct ? Icons.check_circle_outline : Icons.info_outline,
                  color: correct
                      ? colors.onSecondaryContainer
                      : colors.onErrorContainer,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        correct
                            ? localizations.correct
                            : localizations.incorrect,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: correct
                                  ? colors.onSecondaryContainer
                                  : colors.onErrorContainer,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: correct
                              ? colors.onSecondaryContainer
                              : colors.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SessionStats extends StatelessWidget {
  const _SessionStats({required this.session, required this.localizations});

  final IntervalTrainingSessionState session;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) => Semantics(
    label: localizations.intervalSessionSemantics(
      session.questionsAnswered,
      session.correctAnswers,
      (session.accuracy * 100).round(),
      session.currentStreak,
      session.bestStreak,
    ),
    child: ExcludeSemantics(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.small,
        runSpacing: AppSpacing.small,
        children: [
          _StatChip(
            icon: Icons.quiz_outlined,
            label: localizations.questionsAnswered(session.questionsAnswered),
          ),
          _StatChip(
            icon: Icons.track_changes_outlined,
            label: localizations.accuracyValue(
              (session.accuracy * 100).round(),
            ),
          ),
          _StatChip(
            icon: Icons.local_fire_department_outlined,
            label: localizations.streakValue(session.currentStreak),
          ),
          _StatChip(
            icon: Icons.emoji_events_outlined,
            label: localizations.bestStreakValue(session.bestStreak),
          ),
        ],
      ),
    ),
  );
}

final class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.medium,
      vertical: AppSpacing.small,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: AppRadii.smallBorder,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.small),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}

String _answerLabel(
  IntervalQuestion question,
  String answer,
  AppLocalizations localizations,
) => question.mode == IntervalTrainingMode.identifyInterval
    ? _intervalLabel(IntervalIdentity.values.byName(answer), localizations)
    : answer;

String _intervalLabel(IntervalIdentity interval, AppLocalizations l10n) =>
    switch (interval) {
      IntervalIdentity.perfectUnison => l10n.intervalPerfectUnison,
      IntervalIdentity.minorSecond => l10n.intervalMinorSecond,
      IntervalIdentity.majorSecond => l10n.intervalMajorSecond,
      IntervalIdentity.minorThird => l10n.intervalMinorThird,
      IntervalIdentity.majorThird => l10n.intervalMajorThird,
      IntervalIdentity.perfectFourth => l10n.intervalPerfectFourth,
      IntervalIdentity.augmentedFourth => l10n.intervalAugmentedFourth,
      IntervalIdentity.diminishedFifth => l10n.intervalDiminishedFifth,
      IntervalIdentity.perfectFifth => l10n.intervalPerfectFifth,
      IntervalIdentity.minorSixth => l10n.intervalMinorSixth,
      IntervalIdentity.majorSixth => l10n.intervalMajorSixth,
      IntervalIdentity.minorSeventh => l10n.intervalMinorSeventh,
      IntervalIdentity.majorSeventh => l10n.intervalMajorSeventh,
      IntervalIdentity.perfectOctave => l10n.intervalPerfectOctave,
    };
