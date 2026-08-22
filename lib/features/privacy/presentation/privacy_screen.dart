import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return TunathicScaffold(
      title: localizations.privacyTitle,
      maxContentWidth: AppSpacing.readingMaxWidth,
      body: ListView(
        key: const Key('privacyScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.xLarge,
        ),
        children: [
          DecoratedBox(
            decoration: TunathicSurfaces.tunerDisplay(context),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Text(
                localizations.privacySummary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          _PrivacyItem(
            icon: Icons.touch_app_outlined,
            title: localizations.privacyBpmTitle,
            description: localizations.privacyBpmDescription,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrivacyItem(
            icon: Icons.phone_android_outlined,
            title: localizations.privacyLocalTitle,
            description: localizations.privacyLocalDescription,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrivacyItem(
            icon: Icons.library_books_outlined,
            title: localizations.privacyRepertoireTitle,
            description: localizations.privacyRepertoireDescription,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrivacyItem(
            icon: Icons.mic_none_outlined,
            title: localizations.privacyMicrophoneTitle,
            description: localizations.privacyMicrophoneDescription,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrivacyItem(
            icon: Icons.cloud_off_outlined,
            title: localizations.privacyNoCollectionTitle,
            description: localizations.privacyNoCollectionDescription,
          ),
          const SizedBox(height: AppSpacing.medium),
          RackPanel(
            child: Text(
              localizations.privacyFutureChanges,
              style: TunathicTextStyles.metadata(context),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studio = StudioTheme.of(context);
    return RackPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: studio.display,
              borderRadius: AppRadii.mediumBorder,
              border: Border.all(color: studio.panelBorder),
            ),
            child: Icon(icon, size: 18, color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: TunathicTextStyles.metadata(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
