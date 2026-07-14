import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            tooltip: localizations.settingsTooltip,
            onPressed: () => context.push(AppRoutes.settings),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _columnCount(constraints.maxWidth);
                    final gaps = AppSpacing.medium * (columns - 1);
                    final itemWidth = (constraints.maxWidth - gaps) / columns;
                    return Wrap(
                      spacing: AppSpacing.medium,
                      runSpacing: AppSpacing.medium,
                      children: [
                        for (final tool in ToolDefinition.values)
                          SizedBox(
                            width: itemWidth,
                            child: _ToolCard(tool: tool),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
  const _ToolCard({required this.tool});

  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final title = tool.title(localizations);
    final isAvailable = tool == ToolDefinition.bpmTap;
    final availability = isAvailable
        ? localizations.openTool
        : localizations.comingSoon;

    return Semantics(
      button: true,
      label: '$title, $availability',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.tool(tool)),
          borderRadius: AppRadii.mediumBorder,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 116),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Icon(
                      tool.icon,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            availability,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
