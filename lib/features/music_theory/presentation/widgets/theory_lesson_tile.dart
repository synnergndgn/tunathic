import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/presentation/theory_localizations.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// One lesson in a list, with its level and a favourite toggle.
final class TheoryLessonTile extends StatelessWidget {
  const TheoryLessonTile({
    required this.lesson,
    required this.content,
    required this.isFavorite,
    required this.onOpen,
    required this.onToggleFavorite,
    this.showCategory = false,
    super.key,
  });

  final TheoryLesson lesson;
  final TheoryContent content;
  final bool isFavorite;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final title = content.text(lesson.titleId);
    final summary = content.text(lesson.summaryId);
    final level = localizations.theoryLevelName(lesson.level);
    final subtitle = showCategory
        ? '${localizations.theoryCategoryName(lesson.category)} · $level'
        : level;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: localizations.theoryLessonSemantics(title, level, summary),
              child: ExcludeSemantics(
                child: InkWell(
                  key: Key('theoryLesson_${lesson.id}'),
                  onTap: onOpen,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.secondary),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          summary,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          TheoryFavoriteButton(
            lessonId: lesson.id,
            isFavorite: isFavorite,
            onPressed: onToggleFavorite,
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
    );
  }
}

/// The star that keeps a lesson in the reader's favourites.
final class TheoryFavoriteButton extends StatelessWidget {
  const TheoryFavoriteButton({
    required this.lessonId,
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final String lessonId;
  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return IconButton(
      key: Key('theoryFavorite_$lessonId'),
      onPressed: onPressed,
      tooltip: isFavorite
          ? localizations.theoryRemoveFavorite
          : localizations.theoryAddFavorite,
      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
      color: isFavorite ? Theme.of(context).colorScheme.primary : null,
    );
  }
}
