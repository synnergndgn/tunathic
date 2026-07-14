import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.privacyTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.readingMaxWidth,
            ),
            child: ListView(
              key: const Key('privacyScroll'),
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                Text(
                  localizations.privacySummary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                _PrivacyItem(
                  icon: Icons.touch_app_outlined,
                  title: localizations.privacyBpmTitle,
                  description: localizations.privacyBpmDescription,
                ),
                const SizedBox(height: AppSpacing.small),
                _PrivacyItem(
                  icon: Icons.phone_android_outlined,
                  title: localizations.privacyLocalTitle,
                  description: localizations.privacyLocalDescription,
                ),
                const SizedBox(height: AppSpacing.small),
                _PrivacyItem(
                  icon: Icons.cloud_off_outlined,
                  title: localizations.privacyNoCollectionTitle,
                  description: localizations.privacyNoCollectionDescription,
                ),
                const SizedBox(height: AppSpacing.medium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Text(localizations.privacyFutureChanges),
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: Text(description),
        ),
      ),
    );
  }
}
