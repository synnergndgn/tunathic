import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/studio_state_panel.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return TunathicScaffold(
      title: localizations.appTitle,
      maxContentWidth: AppSpacing.readingMaxWidth,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          StudioStatePanel(
            icon: Icons.explore_off_outlined,
            title: localizations.pageNotFoundTitle,
            description: localizations.pageNotFoundDescription,
            actionLabel: localizations.backToDashboard,
            onAction: () => context.go(AppRoutes.dashboard),
            tone: StudioStateTone.action,
          ),
        ],
      ),
    );
  }
}
