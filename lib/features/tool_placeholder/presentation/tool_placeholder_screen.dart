import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/tools/tool_definition.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class ToolPlaceholderScreen extends StatelessWidget {
  const ToolPlaceholderScreen({required this.tool, super.key});

  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final title = tool.title(localizations);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Semantics(
              container: true,
              label: '$title, ${localizations.comingSoon}',
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        tool.icon,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      localizations.comingSoon,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      localizations.comingSoonDescription(title),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.dashboard),
                      icon: const Icon(Icons.home_outlined),
                      label: Text(localizations.backToDashboard),
                    ),
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
