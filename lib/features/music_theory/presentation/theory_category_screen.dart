import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_controller.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_progress.dart';
import 'package:tunathic/features/music_theory/presentation/theory_localizations.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_lesson_tile.dart';
import 'package:tunathic/features/tool_placeholder/presentation/not_found_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// The lessons of one category, grouped beginner to advanced.
final class TheoryCategoryScreen extends ConsumerWidget {
  const TheoryCategoryScreen({required this.categoryId, super.key});

  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = TheoryCategory.fromId(categoryId);
    if (category == null) return const NotFoundScreen();

    final localizations = AppLocalizations.of(context);
    final content = context.theoryContent;
    final progress =
        ref.watch(theoryProgressProvider).value ?? TheoryProgress.empty;
    final lessons = TheoryLibrary.byCategoryInLearningOrder(category);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.theoryCategoryName(category))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              key: const Key('theoryCategoryScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Text(
                  localizations.theoryCategoryDescription(category),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                for (final level in TheoryLevel.values)
                  if (lessons.any((lesson) => lesson.level == level)) ...[
                    Semantics(
                      header: true,
                      child: Text(
                        localizations.theoryLevelName(level),
                        key: Key('theoryLevelHeading_${level.id}'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    for (final lesson in lessons)
                      if (lesson.level == level)
                        TheoryLessonTile(
                          lesson: lesson,
                          content: content,
                          isFavorite: progress.isFavorite(lesson.id),
                          onOpen: () {
                            unawaited(ref.read(appHapticsProvider).selection());
                            context.push(
                              AppRoutes.musicTheoryLesson(lesson.id),
                            );
                          },
                          onToggleFavorite: () => unawaited(
                            ref
                                .read(theoryProgressProvider.notifier)
                                .toggleFavorite(lesson.id),
                          ),
                        ),
                    const SizedBox(height: AppSpacing.large),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
