import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/about/presentation/license_page.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(localizations.aboutTunathic)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.readingMaxWidth,
            ),
            child: ListView(
              key: const Key('aboutScroll'),
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.productFullName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          localizations.tagline,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        Text(localizations.aboutProductDescription),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          '${localizations.publisherLabel}: GUNDEV',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          '${localizations.versionLabel}: ${applicationInfo.displayVersion}',
                          key: const Key('aboutVersion'),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(localizations.copyrightNotice),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _ToolList(
                  title: localizations.availableToolsTitle,
                  tools: availableTools,
                ),
                const SizedBox(height: AppSpacing.large),
                _ToolList(
                  title: localizations.plannedToolsTitle,
                  tools: plannedTools,
                ),
                const SizedBox(height: AppSpacing.large),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        key: const Key('aboutPrivacy'),
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(localizations.privacyTitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          unawaited(haptics.selection());
                          context.push(AppRoutes.privacy);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        key: const Key('aboutLicenses'),
                        leading: const Icon(Icons.code_outlined),
                        title: Text(localizations.openSourceLicenses),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          unawaited(haptics.selection());
                          showTunathicLicensePage(context, applicationInfo);
                        },
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

final class _ToolList extends StatelessWidget {
  const _ToolList({required this.title, required this.tools});

  final String title;
  final Iterable<ToolDefinition> tools;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final tool in tools)
              Chip(
                avatar: Icon(tool.icon, size: 18),
                label: Text(tool.title(AppLocalizations.of(context))),
              ),
          ],
        ),
      ],
    );
  }
}
