import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/friendly_error_view.dart';

final class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: FriendlyErrorView(
        title: localizations.pageNotFoundTitle,
        description: localizations.pageNotFoundDescription,
        actionLabel: localizations.backToDashboard,
        onAction: () => context.go(AppRoutes.dashboard),
      ),
    );
  }
}
