import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/about/presentation/license_page.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final applicationInfo = ref.watch(initialApplicationInfoProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final haptics = ref.read(appHapticsProvider);

    void selectTheme(ThemeMode mode) {
      unawaited(haptics.selection());
      unawaited(controller.setThemeMode(mode));
    }

    void selectLocale(AppLocale locale) {
      unawaited(haptics.selection());
      unawaited(controller.setLocale(locale));
    }

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              key: const Key('settingsScroll'),
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                _SettingsSection(
                  title: localizations.appearanceTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.themeModeLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          _ThemeChoice(
                            value: ThemeMode.system,
                            label: localizations.themeSystem,
                            selected: settings.themeMode == ThemeMode.system,
                            onSelected: selectTheme,
                          ),
                          _ThemeChoice(
                            value: ThemeMode.light,
                            label: localizations.themeLight,
                            selected: settings.themeMode == ThemeMode.light,
                            onSelected: selectTheme,
                          ),
                          _ThemeChoice(
                            value: ThemeMode.dark,
                            label: localizations.themeDark,
                            selected: settings.themeMode == ThemeMode.dark,
                            onSelected: selectTheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        localizations.languageTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      _LocaleChoice(
                        value: AppLocale.system,
                        label: localizations.languageSystem,
                        selected: settings.locale == AppLocale.system,
                        onSelected: selectLocale,
                      ),
                      _LocaleChoice(
                        value: AppLocale.english,
                        label: localizations.languageEnglish,
                        selected: settings.locale == AppLocale.english,
                        onSelected: selectLocale,
                      ),
                      _LocaleChoice(
                        value: AppLocale.turkish,
                        label: localizations.languageTurkish,
                        selected: settings.locale == AppLocale.turkish,
                        onSelected: selectLocale,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _SettingsSection(
                  title: localizations.interactionTitle,
                  child: SwitchListTile(
                    key: const Key('hapticsToggle'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(localizations.hapticFeedbackTitle),
                    subtitle: Text(localizations.hapticFeedbackDescription),
                    value: settings.hapticsEnabled,
                    onChanged: (enabled) =>
                        unawaited(controller.setHapticsEnabled(enabled)),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _SettingsSection(
                  title: localizations.applicationTitle,
                  child: Column(
                    children: [
                      _ApplicationTile(
                        key: const Key('settingsAbout'),
                        icon: Icons.info_outline,
                        title: localizations.aboutTunathic,
                        onTap: () {
                          unawaited(haptics.selection());
                          context.push(AppRoutes.about);
                        },
                      ),
                      _ApplicationTile(
                        key: const Key('settingsPrivacy'),
                        icon: Icons.privacy_tip_outlined,
                        title: localizations.privacyTitle,
                        onTap: () {
                          unawaited(haptics.selection());
                          context.push(AppRoutes.privacy);
                        },
                      ),
                      _ApplicationTile(
                        key: const Key('settingsLicenses'),
                        icon: Icons.code_outlined,
                        title: localizations.openSourceLicenses,
                        onTap: () {
                          unawaited(haptics.selection());
                          showTunathicLicensePage(context, applicationInfo);
                        },
                      ),
                      ListTile(
                        key: const Key('settingsVersion'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.tag_outlined),
                        title: Text(localizations.versionLabel),
                        trailing: Text(applicationInfo.displayVersion),
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

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: AppSpacing.small),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: child,
          ),
        ),
      ],
    );
  }
}

final class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

final class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.value,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final ThemeMode value;
  final String label;
  final bool selected;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(value),
      ),
    );
  }
}

final class _LocaleChoice extends StatelessWidget {
  const _LocaleChoice({
    required this.value,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final AppLocale value;
  final String label;
  final bool selected;
  final ValueChanged<AppLocale> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () => onSelected(value),
      ),
    );
  }
}
