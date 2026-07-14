import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                _SectionTitle(localizations.appearanceTitle),
                const SizedBox(height: AppSpacing.medium),
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
                      onSelected: controller.setThemeMode,
                    ),
                    _ThemeChoice(
                      value: ThemeMode.light,
                      label: localizations.themeLight,
                      selected: settings.themeMode == ThemeMode.light,
                      onSelected: controller.setThemeMode,
                    ),
                    _ThemeChoice(
                      value: ThemeMode.dark,
                      label: localizations.themeDark,
                      selected: settings.themeMode == ThemeMode.dark,
                      onSelected: controller.setThemeMode,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xLarge),
                _SectionTitle(localizations.languageTitle),
                const SizedBox(height: AppSpacing.small),
                _LocaleChoice(
                  value: AppLocale.system,
                  label: localizations.languageSystem,
                  selected: settings.locale == AppLocale.system,
                  onSelected: controller.setLocale,
                ),
                _LocaleChoice(
                  value: AppLocale.english,
                  label: localizations.languageEnglish,
                  selected: settings.locale == AppLocale.english,
                  onSelected: controller.setLocale,
                ),
                _LocaleChoice(
                  value: AppLocale.turkish,
                  label: localizations.languageTurkish,
                  selected: settings.locale == AppLocale.turkish,
                  onSelected: controller.setLocale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
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
        minTileHeight: AppSpacing.minTouchTarget,
        title: Text(label),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () => onSelected(value),
      ),
    );
  }
}
