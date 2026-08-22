import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/studio_state_panel.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class ToolPlaceholderScreen extends StatelessWidget {
  const ToolPlaceholderScreen({required this.tool, super.key});

  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final title = tool.title(localizations);

    return TunathicScaffold(
      title: title,
      maxContentWidth: AppSpacing.readingMaxWidth,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          StudioStatePanel(
            icon: tool.icon,
            title: localizations.comingSoon,
            description: localizations.comingSoonDescription(title),
            actionLabel: localizations.backToDashboard,
            onAction: () => context.go(AppRoutes.dashboard),
          ),
        ],
      ),
    );
  }
}
