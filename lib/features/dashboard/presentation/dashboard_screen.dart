import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_elevation.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _practiceOrder = [
    ToolDefinition.metronome,
    ToolDefinition.bpmTap,
    ToolDefinition.guitarTuner,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final haptics = ref.read(appHapticsProvider);

    Future<void> openTool(ToolDefinition tool) async {
      unawaited(haptics.selection());
      await context.push(AppRoutes.tool(tool));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            key: const Key('openSettings'),
            tooltip: localizations.settingsTooltip,
            onPressed: () {
              unawaited(haptics.selection());
              context.push(AppRoutes.settings);
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.pageMaxWidth,
            ),
            child: ListView(
              key: const Key('dashboardScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                Text(
                  localizations.tagline,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  localizations.dashboardTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  localizations.dashboardIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _ToolSection(
                  title: localizations.practiceSection,
                  tools: _practiceOrder,
                  onOpen: openTool,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _ToolSection(
                  title: localizations.theoryReferenceSection,
                  tools: ToolDefinition.values
                      .where(
                        (tool) => tool.category == ToolCategory.theoryReference,
                      )
                      .toList(),
                  onOpen: openTool,
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _ToolSection(
                  title: localizations.trainingSection,
                  tools: ToolDefinition.values
                      .where((tool) => tool.category == ToolCategory.training)
                      .toList(),
                  onOpen: openTool,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _ToolSection extends StatelessWidget {
  const _ToolSection({
    required this.title,
    required this.tools,
    required this.onOpen,
  });

  final String title;
  final List<ToolDefinition> tools;
  final ValueChanged<ToolDefinition> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
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
                for (final tool in tools)
                  SizedBox(
                    width: itemWidth,
                    child: _ToolCard(
                      tool: tool,
                      prominent: tool.isAvailable,
                      onTap: () => onOpen(tool),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  int _columnCount(double width) {
    if (width >= 960) return 4;
    if (width >= 680) return 3;
    if (width >= 440) return 2;
    return 1;
  }
}

final class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.tool,
    required this.prominent,
    required this.onTap,
  });

  final ToolDefinition tool;
  final bool prominent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final title = tool.title(localizations);
    final availability = tool.isAvailable
        ? localizations.openTool
        : localizations.comingSoon;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '$title, $availability',
      child: Card(
        elevation: prominent ? AppElevation.raised : AppElevation.flat,
        color: prominent ? colors.primaryContainer : null,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.mediumBorder,
          child: Padding(
            padding: EdgeInsets.all(
              prominent ? AppSpacing.large : AppSpacing.medium,
            ),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(
                    tool.icon,
                    size: prominent ? 36 : 30,
                    color: prominent
                        ? colors.onPrimaryContainer
                        : colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: prominent
                                    ? colors.onPrimaryContainer
                                    : null,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          availability,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: prominent
                                    ? colors.onPrimaryContainer
                                    : colors.secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Icon(
                    Icons.chevron_right,
                    color: prominent ? colors.onPrimaryContainer : null,
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
