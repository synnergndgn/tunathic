import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// The last-resort screen when a build fails.
///
/// It runs outside the router and sometimes outside localisation, so it falls
/// back to its own copy and to the brightness-derived studio palette rather
/// than assuming either is available.
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
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: TunathicSurfaces.studioBackground(context),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Semantics(
              container: true,
              label: resolvedTitle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SkeuoSurface(
                  prominent: true,
                  accent: colors.error.withValues(alpha: 0.55),
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 56,
                        child: SkeuoInsetPanel(
                          radius: const Radius.circular(28),
                          surfaceColor: colors.error.withValues(alpha: 0.10),
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 30,
                              color: colors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        resolvedTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        resolvedDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (onAction != null && actionLabel != null) ...[
                        const SizedBox(height: AppSpacing.large),
                        SkeuoButton(
                          selected: true,
                          onPressed: onAction,
                          icon: Icons.home_outlined,
                          child: Text(actionLabel!),
                        ),
                      ],
                    ],
                  ),
                ),
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
