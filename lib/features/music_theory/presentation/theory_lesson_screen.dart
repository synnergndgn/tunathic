import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_controller.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_progress.dart';
import 'package:tunathic/features/music_theory/presentation/theory_localizations.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_block_view.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_lesson_tile.dart';
import 'package:tunathic/features/tool_placeholder/presentation/not_found_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// One lesson: explanation, worked examples, and links into the tools.
final class TheoryLessonScreen extends ConsumerStatefulWidget {
  const TheoryLessonScreen({required this.lessonId, super.key});

  final String? lessonId;

  @override
  ConsumerState<TheoryLessonScreen> createState() => _TheoryLessonScreenState();
}

final class _TheoryLessonScreenState extends ConsumerState<TheoryLessonScreen> {
  @override
  void initState() {
    super.initState();
    final lesson = TheoryLibrary.byId(widget.lessonId);
    if (lesson == null) return;
    // Recording the visit after the first frame keeps the read of stored
    // progress out of the build that is already running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(theoryProgressProvider.notifier).markViewed(lesson.id),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = TheoryLibrary.byId(widget.lessonId);
    if (lesson == null) return const NotFoundScreen();

    final localizations = AppLocalizations.of(context);
    final content = context.theoryContent;
    final progress =
        ref.watch(theoryProgressProvider).value ?? TheoryProgress.empty;
    final next = TheoryLibrary.next(lesson);
    final previous = TheoryLibrary.previous(lesson);

    return Scaffold(
      appBar: AppBar(
        title: Text(content.text(lesson.titleId)),
        actions: [
          TheoryFavoriteButton(
            lessonId: lesson.id,
            isFavorite: progress.isFavorite(lesson.id),
            onPressed: () => unawaited(
              ref
                  .read(theoryProgressProvider.notifier)
                  .toggleFavorite(lesson.id),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.readingMaxWidth,
            ),
            child: ListView(
              key: const Key('theoryLessonScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    Chip(
                      label: Text(
                        localizations.theoryCategoryName(lesson.category),
                      ),
                      avatar: Icon(theoryCategoryIcon(lesson.category)),
                    ),
                    Chip(
                      key: const Key('theoryLessonLevel'),
                      label: Text(localizations.theoryLevelName(lesson.level)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  content.text(lesson.summaryId),
                  key: const Key('theoryLessonSummary'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.large),
                for (final block in lesson.blocks) ...[
                  TheoryBlockView(
                    block: block,
                    content: content,
                    onOpenAction: _open,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                const SizedBox(height: AppSpacing.medium),
                _LessonNavigation(
                  previous: previous,
                  next: next,
                  onOpen: (TheoryLesson target) =>
                      _open(AppRoutes.musicTheoryLesson(target.id)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(String route) {
    unawaited(ref.read(appHapticsProvider).selection());
    context.push(route);
  }
}

final class _LessonNavigation extends StatelessWidget {
  const _LessonNavigation({
    required this.previous,
    required this.next,
    required this.onOpen,
  });

  final TheoryLesson? previous;
  final TheoryLesson? next;
  final ValueChanged<TheoryLesson> onOpen;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final content = context.theoryContent;
    if (previous == null && next == null) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        if (previous case final lesson?)
          OutlinedButton.icon(
            key: const Key('theoryPreviousLesson'),
            onPressed: () => onOpen(lesson),
            icon: const Icon(Icons.arrow_back),
            label: Text(
              '${localizations.theoryPreviousLesson}: '
              '${content.text(lesson.titleId)}',
            ),
          ),
        if (next case final lesson?)
          FilledButton.icon(
            key: const Key('theoryNextLesson'),
            onPressed: () => onOpen(lesson),
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              '${localizations.theoryNextLesson}: '
              '${content.text(lesson.titleId)}',
            ),
          ),
      ],
    );
  }
}
