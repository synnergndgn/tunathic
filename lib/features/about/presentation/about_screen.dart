import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/about/presentation/license_page.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/settings_group.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final applicationInfo = ref.watch(initialApplicationInfoProvider);
    final haptics = ref.read(appHapticsProvider);
    final availableTools = ToolDefinition.values.where(
      (tool) => tool.isAvailable,
    );
    final plannedTools = ToolDefinition.values.where(
      (tool) => !tool.isAvailable,
    );

    return TunathicScaffold(
      title: localizations.aboutTunathic,
      maxContentWidth: AppSpacing.readingMaxWidth,
      body: ListView(
        key: const Key('aboutScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.xLarge,
        ),
        children: [
          _Manifesto(
            productName: localizations.productFullName,
            tagline: localizations.tagline,
            manifesto: localizations.aboutManifesto,
            description: localizations.aboutProductDescription,
          ),
          const SizedBox(height: AppSpacing.large),
          _ToolList(
            title: localizations.availableToolsTitle,
            icon: Icons.check_circle_outline,
            tools: availableTools,
          ),
          const SizedBox(height: AppSpacing.large),
          _ToolList(
            title: localizations.plannedToolsTitle,
            icon: Icons.schedule_outlined,
            tools: plannedTools,
          ),
          const SizedBox(height: AppSpacing.large),
          SettingsGroup(
            title: localizations.applicationTitle,
            icon: Icons.badge_outlined,
            children: [
              RackRow(
                icon: Icons.storefront_outlined,
                label: localizations.publisherLabel,
                value: Text(
                  'GUNDEV',
                  style: TunathicTextStyles.metadata(context),
                ),
              ),
              RackRow(
                key: const Key('aboutVersion'),
                icon: Icons.tag_outlined,
                label: localizations.versionLabel,
                value: Text(
                  applicationInfo.displayVersion,
                  style: TunathicTextStyles.metadata(context),
                ),
              ),
              RackRow(
                key: const Key('aboutPrivacy'),
                icon: Icons.privacy_tip_outlined,
                label: localizations.privacyTitle,
                onTap: () {
                  unawaited(haptics.selection());
                  context.push(AppRoutes.privacy);
                },
                value: const Icon(Icons.chevron_right, size: 20),
              ),
              RackRow(
                key: const Key('aboutLicenses'),
                icon: Icons.code_outlined,
                label: localizations.openSourceLicenses,
                onTap: () {
                  unawaited(haptics.selection());
                  showTunathicLicensePage(context, applicationInfo);
                },
                value: const Icon(Icons.chevron_right, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            localizations.copyrightNotice,
            textAlign: TextAlign.center,
            style: TunathicTextStyles.metadata(context),
          ),
        ],
      ),
    );
  }
}

/// What Tunathic is for, said once and plainly.
final class _Manifesto extends StatelessWidget {
  const _Manifesto({
    required this.productName,
    required this.tagline,
    required this.manifesto,
    required this.description,
  });

  final String productName;
  final String tagline;
  final String manifesto;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: TunathicSurfaces.tunerDisplay(context),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tagline,
              style: TunathicTextStyles.sectionTitle(
                context,
              ).copyWith(color: colors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(productName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.medium),
            Text(
              manifesto,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(description, style: TunathicTextStyles.metadata(context)),
          ],
        ),
      ),
    );
  }
}

final class _ToolList extends StatelessWidget {
  const _ToolList({
    required this.title,
    required this.icon,
    required this.tools,
  });

  final String title;
  final IconData icon;
  final Iterable<ToolDefinition> tools;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final studio = StudioTheme.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioSectionLabel(label: title, icon: icon),
        // Chips are capped at the list's own width and their labels wrap, so a
        // long tool name at double text scale takes a second line instead of
        // running off the edge.
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tool in tools)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: studio.panel,
                      borderRadius: AppRadii.mediumBorder,
                      border: Border.all(color: studio.panelBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tool.icon,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            tool.title(localizations),
                            style: TunathicTextStyles.compactLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
