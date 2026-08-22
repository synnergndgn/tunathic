import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_controller.dart';
import 'package:tunathic/features/music_theory/domain/theory_category.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';
import 'package:tunathic/features/music_theory/domain/theory_lesson.dart';
import 'package:tunathic/features/music_theory/domain/theory_level.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_progress.dart';
import 'package:tunathic/features/music_theory/domain/theory_search.dart';
import 'package:tunathic/features/music_theory/presentation/theory_localizations.dart';
import 'package:tunathic/features/music_theory/presentation/widgets/theory_lesson_tile.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// The Music Theory hub: search, level filter, saved reading, and categories.
final class MusicTheoryScreen extends ConsumerStatefulWidget {
  const MusicTheoryScreen({super.key});

  @override
  ConsumerState<MusicTheoryScreen> createState() => _MusicTheoryScreenState();
}

final class _MusicTheoryScreenState extends ConsumerState<MusicTheoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  TheoryLevel? _level;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isFiltering => _query.trim().isNotEmpty || _level != null;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final content = context.theoryContent;
    final progress =
        ref.watch(theoryProgressProvider).value ?? TheoryProgress.empty;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.musicTheory)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.pageMaxWidth,
            ),
            child: ListView(
              key: const Key('musicTheoryScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Text(
                  localizations.musicTheoryTagline,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xSmall),
                Text(
                  localizations.theoryHubIntro,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.medium),
                _SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                _LevelFilter(
                  level: _level,
                  onChanged: (level) => setState(() => _level = level),
                ),
                const SizedBox(height: AppSpacing.large),
                if (_isFiltering)
                  ..._buildResults(context, content, progress)
                else
                  ..._buildBrowse(context, content, progress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResults(
    BuildContext context,
    TheoryContent content,
    TheoryProgress progress,
  ) {
    final localizations = AppLocalizations.of(context);
    final results = TheorySearch.query(
      lessons: TheoryLibrary.lessons,
      content: content,
      query: _query,
      level: _level,
    );

    return [
      Text(
        localizations.theoryResultCount(results.length),
        key: const Key('theoryResultCount'),
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: AppSpacing.medium),
      if (results.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.medium),
          child: Column(
            key: const Key('theoryNoResults'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.theoryNoResults(_query.trim()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                localizations.theoryNoResultsHint,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
      else
        for (final lesson in results)
          _lessonTile(context, lesson, content, progress, showCategory: true),
    ];
  }

  List<Widget> _buildBrowse(
    BuildContext context,
    TheoryContent content,
    TheoryProgress progress,
  ) {
    final localizations = AppLocalizations.of(context);
    final recent = TheoryLibrary.byIds(progress.recentIds);
    final favorites = TheoryLibrary.byIds(progress.favoriteIds);

    return [
      if (recent.isNotEmpty) ...[
        _CollapsibleSection(
          sectionKey: const Key('theoryRecentSection'),
          title: localizations.theoryRecentlyViewed,
          icon: Icons.history,
          children: [
            for (final lesson in recent)
              _lessonTile(
                context,
                lesson,
                content,
                progress,
                showCategory: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
      ],
      if (favorites.isNotEmpty) ...[
        _CollapsibleSection(
          sectionKey: const Key('theoryFavoritesSection'),
          title: localizations.theoryFavorites,
          icon: Icons.star,
          children: [
            for (final lesson in favorites)
              _lessonTile(
                context,
                lesson,
                content,
                progress,
                showCategory: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
      ],
      Semantics(
        header: true,
        child: Text(
          localizations.theoryCategoriesTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      const SizedBox(height: AppSpacing.medium),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnCount(constraints.maxWidth);
          final gaps = AppSpacing.medium * (columns - 1);
          final itemWidth = (constraints.maxWidth - gaps) / columns;
          return Wrap(
            spacing: AppSpacing.medium,
            runSpacing: AppSpacing.medium,
            children: [
              for (final category in TheoryCategory.values)
                SizedBox(
                  width: itemWidth,
                  child: _CategoryCard(
                    category: category,
                    onOpen: () =>
                        _open(AppRoutes.musicTheoryCategory(category.id)),
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }

  Widget _lessonTile(
    BuildContext context,
    TheoryLesson lesson,
    TheoryContent content,
    TheoryProgress progress, {
    bool showCategory = false,
  }) => TheoryLessonTile(
    lesson: lesson,
    content: content,
    isFavorite: progress.isFavorite(lesson.id),
    showCategory: showCategory,
    onOpen: () => _open(AppRoutes.musicTheoryLesson(lesson.id)),
    onToggleFavorite: () => unawaited(
      ref.read(theoryProgressProvider.notifier).toggleFavorite(lesson.id),
    ),
  );

  void _open(String route) {
    unawaited(ref.read(appHapticsProvider).selection());
    context.push(route);
  }

  static int _columnCount(double width) {
    if (width >= 1000) return 3;
    if (width >= 640) return 2;
    return 1;
  }
}

final class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return TextField(
      key: const Key('theorySearchField'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: localizations.theorySearchLabel,
        hintText: localizations.theorySearchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                key: const Key('theoryClearSearch'),
                onPressed: onClear,
                tooltip: localizations.theoryClearSearch,
                icon: const Icon(Icons.clear),
              ),
        border: const OutlineInputBorder(borderRadius: AppRadii.mediumBorder),
      ),
    );
  }
}

final class _LevelFilter extends StatelessWidget {
  const _LevelFilter({required this.level, required this.onChanged});

  final TheoryLevel? level;
  final ValueChanged<TheoryLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final entries = <(TheoryLevel?, String)>[
      (null, localizations.theoryLevelAll),
      for (final value in TheoryLevel.values)
        (value, localizations.theoryLevelName(value)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.theoryLevelLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          key: const Key('theoryLevelFilter'),
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final entry in entries)
              SkeuoButton(
                key: Key('theoryLevel_${entry.$1?.id ?? 'all'}'),
                compact: true,
                selected: level == entry.$1,
                onPressed: () => onChanged(entry.$1),
                child: Text(entry.$2),
              ),
          ],
        ),
      ],
    );
  }
}

final class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.sectionKey,
    required this.title,
    required this.icon,
    required this.children,
  });

  final Key sectionKey;
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SkeuoCard(
    margin: EdgeInsets.zero,
    child: ExpansionTile(
      key: sectionKey,
      initiallyExpanded: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.mediumBorder),
      collapsedShape: const RoundedRectangleBorder(
        borderRadius: AppRadii.mediumBorder,
      ),
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.small,
      ),
      children: children,
    ),
  );
}

final class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onOpen});

  final TheoryCategory category;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final name = localizations.theoryCategoryName(category);
    final description = localizations.theoryCategoryDescription(category);
    final count = localizations.theoryLessonCount(
      TheoryLibrary.lessonCount(category),
    );

    return Semantics(
      button: true,
      label: localizations.theoryCategorySemantics(name, count, description),
      child: ExcludeSemantics(
        child: SkeuoCard(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('theoryCategory_${category.id}'),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(theoryCategoryIcon(category), color: colors.primary),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          count,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.secondary),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
