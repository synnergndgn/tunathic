import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/control_dock.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

/// The control room: what to open, in the order a player reaches for it.
final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// The tuner is the first thing anyone picks up, so it gets the whole width.
  static const _hero = ToolDefinition.guitarTuner;

  /// The rest of the practice tools sit on a dock under it, within thumb
  /// reach rather than buried in the grid below.
  static const _quickAccess = [
    ToolDefinition.metronome,
    ToolDefinition.bpmTap,
    ToolDefinition.repertoire,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final haptics = ref.read(appHapticsProvider);
    final theoryTools = ToolDefinition.values
        .where(
          (tool) =>
              tool.isAvailable && tool.category == ToolCategory.theoryReference,
        )
        .toList();
    final trainingTools = ToolDefinition.values
        .where(
          (tool) => tool.isAvailable && tool.category == ToolCategory.training,
        )
        .toList();

    Future<void> openTool(ToolDefinition tool) async {
      unawaited(haptics.selection());
      await context.push(AppRoutes.tool(tool));
    }

    return TunathicScaffold(
      title: localizations.appTitle,
      maxContentWidth: AppSpacing.pageMaxWidth,
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
      ],
      body: ListView(
        key: const Key('dashboardScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.large,
          AppSpacing.medium,
          AppSpacing.xLarge,
        ),
        children: [
          _ConsoleHeader(
            tagline: localizations.tagline,
            title: localizations.dashboardTitle,
            intro: localizations.dashboardIntro,
          ),
          const SizedBox(height: AppSpacing.large),
          StudioSectionLabel(
            label: localizations.practiceSection,
            icon: Icons.graphic_eq,
          ),
          _HeroTool(tool: _hero, onOpen: openTool),
          const SizedBox(height: AppSpacing.md),
          ControlDock(
            children: [
              for (final tool in _quickAccess.where((tool) => tool.isAvailable))
                ControlDockItem(
                  key: Key('dashboardTool-${tool.id}'),
                  icon: tool.icon,
                  label: tool.title(localizations),
                  enabled: tool.isAvailable,
                  onTap: () => openTool(tool),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xLarge),
          _ToolSection(
            title: localizations.theoryReferenceSection,
            icon: Icons.menu_book_outlined,
            tools: theoryTools,
            onOpen: openTool,
          ),
          if (trainingTools.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xLarge),
            _ToolSection(
              title: localizations.trainingSection,
              icon: Icons.fitness_center_outlined,
              tools: trainingTools,
              onOpen: openTool,
            ),
          ],
        ],
      ),
    );
  }
}

/// The wordmark block at the top of the console.
final class _ConsoleHeader extends StatelessWidget {
  const _ConsoleHeader({
    required this.tagline,
    required this.title,
    required this.intro,
  });

  final String tagline;
  final String title;
  final String intro;

  @override
  Widget build(BuildContext context) {
    final studio = StudioTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeuoStatusBadge(
          label: tagline,
          color: studio.inTune,
          icon: Icons.power_settings_new,
        ),
        const SizedBox(height: AppSpacing.md),
        // Sized as device chrome rather than a marketing headline: a display
        // face here costs most of the first screen at double text scale and
        // pushes the tools people came for below the fold.
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(letterSpacing: -0.4),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          intro,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TunathicTextStyles.metadata(context),
        ),
      ],
    );
  }
}

/// The tuner, presented as the console's main unit.
final class _HeroTool extends StatelessWidget {
  const _HeroTool({required this.tool, required this.onOpen});

  final ToolDefinition tool;
  final ValueChanged<ToolDefinition> onOpen;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final title = tool.title(localizations);
    final caption = localizations.startTuning;

    return Semantics(
      button: true,
      label: '$title, $caption',
      child: ExcludeSemantics(
        child: RackPanel(
          key: Key('dashboardTool-${tool.id}'),
          active: true,
          accent: colors.primary.withValues(alpha: 0.55),
          padding: const EdgeInsets.all(AppSpacing.medium),
          onTap: () => onOpen(tool),
          child: Row(
            children: [
              _ToolGlyph(icon: tool.icon, size: 56, accent: true),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      caption,
                      style: TunathicTextStyles.compactLabel(
                        context,
                      ).copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.play_arrow_rounded, color: colors.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ToolSection extends StatelessWidget {
  const _ToolSection({
    required this.title,
    required this.icon,
    required this.tools,
    required this.onOpen,
  });

  final String title;
  final IconData icon;
  final List<ToolDefinition> tools;
  final ValueChanged<ToolDefinition> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioSectionLabel(label: title, icon: icon),
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
                    child: _ToolModule(
                      key: Key('dashboardTool-${tool.id}'),
                      tool: tool,
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

/// One tool, drawn as a rack row rather than a card.
final class _ToolModule extends StatelessWidget {
  const _ToolModule({required this.tool, required this.onTap, super.key});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final available = tool.isAvailable;
    final title = tool.title(localizations);
    // A tool that describes itself says so here; the rest report availability.
    final caption =
        tool.subtitle(localizations) ??
        (available ? localizations.openTool : localizations.comingSoon);

    return Semantics(
      button: available,
      enabled: available,
      label: '$title, $caption',
      child: ExcludeSemantics(
        child: RackPanel(
          padding: const EdgeInsets.all(AppSpacing.md),
          onTap: available ? onTap : null,
          child: Row(
            children: [
              _ToolGlyph(icon: tool.icon, size: 40, accent: available),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: available
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      caption,
                      style: TunathicTextStyles.metadata(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (available) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The tinted plate a tool's icon is mounted on.
final class _ToolGlyph extends StatelessWidget {
  const _ToolGlyph({
    required this.icon,
    required this.size,
    required this.accent,
  });

  final IconData icon;
  final double size;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studio = StudioTheme.of(context);
    return SizedBox.square(
      dimension: size,
      child: SkeuoInsetPanel(
        radius: AppRadii.medium,
        accent: accent ? colors.primary.withValues(alpha: 0.42) : null,
        surfaceColor: accent
            ? colors.primary.withValues(alpha: 0.12)
            : studio.display,
        child: Center(
          child: Icon(
            icon,
            size: size * 0.5,
            color: accent ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
