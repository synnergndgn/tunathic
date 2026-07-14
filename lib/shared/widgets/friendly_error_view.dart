import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class FriendlyErrorView extends StatelessWidget {
  const FriendlyErrorView({
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    final fallback = _ErrorCopy.forLanguageCode(
      PlatformDispatcher.instance.locale.languageCode,
    );
    final resolvedTitle =
        title ?? localizations?.unexpectedErrorTitle ?? fallback.title;
    final resolvedDescription =
        description ??
        localizations?.unexpectedErrorDescription ??
        fallback.description;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Semantics(
            container: true,
            label: resolvedTitle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    resolvedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(resolvedDescription, textAlign: TextAlign.center),
                  if (onAction != null && actionLabel != null) ...[
                    const SizedBox(height: AppSpacing.large),
                    FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.home_outlined),
                      label: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _ErrorCopy {
  const _ErrorCopy(this.title, this.description);

  final String title;
  final String description;

  static _ErrorCopy forLanguageCode(String languageCode) {
    if (languageCode == 'tr') {
      return const _ErrorCopy(
        'Bir sorun oluştu',
        'Tunathic bu ekranı gösteremedi. Lütfen uygulamayı yeniden açın.',
      );
    }
    return const _ErrorCopy(
      'Something went wrong',
      'Tunathic could not show this screen. Please reopen the app.',
    );
  }
}
