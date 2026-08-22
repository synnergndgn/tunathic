import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/about/presentation/license_page.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_controller.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuning_reference_selector.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/settings_group.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

/// Device preferences, grouped the way a rack unit's menu would be.
final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final applicationInfo = ref.watch(initialApplicationInfoProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final haptics = ref.read(appHapticsProvider);
    final reference = ref.watch(tuningReferenceProvider);

    void selectTheme(ThemeMode mode) {
      unawaited(haptics.selection());
      unawaited(controller.setThemeMode(mode));
    }

    void selectLocale(AppLocale locale) {
      unawaited(haptics.selection());
      unawaited(controller.setLocale(locale));
    }

    return TunathicScaffold(
      title: localizations.settingsTitle,
      body: ListView(
        key: const Key('settingsScroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.xLarge,
        ),
        children: [
          SettingsGroup(
            title: localizations.settingsAudioSection,
            icon: Icons.graphic_eq,
            children: [
              _ChoiceRow(
                label: localizations.referencePitchLabel,
                description: localizations.referencePitchRangeNote,
                child: TuningReferenceSelector(
                  reference: reference,
                  showSlider: true,
                  onChanged: (value) {
                    unawaited(haptics.selection());
                    unawaited(
                      ref
                          .read(tuningReferenceProvider.notifier)
                          .setReference(value),
                    );
                  },
                ),
              ),
              _InfoRow(
                label: localizations.microphoneUsageLabel,
                value: localizations.microphoneUsageValue,
                description: localizations.microphoneUsageDescription,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SettingsGroup(
            title: localizations.appearanceTitle,
            icon: Icons.contrast,
            children: [
              _ChoiceRow(
                label: localizations.themeModeLabel,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
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
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SettingsGroup(
            title: localizations.interactionTitle,
            icon: Icons.vibration,
            children: [
              _ToggleRow(
                key: const Key('hapticsToggle'),
                label: localizations.hapticFeedbackTitle,
                description: localizations.hapticFeedbackDescription,
                value: settings.hapticsEnabled,
                onChanged: (enabled) =>
                    unawaited(controller.setHapticsEnabled(enabled)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SettingsGroup(
            title: localizations.languageTitle,
            icon: Icons.translate,
            children: [
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
          const SizedBox(height: AppSpacing.medium),
          SettingsGroup(
            title: localizations.applicationTitle,
            icon: Icons.info_outline,
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
              RackRow(
                key: const Key('settingsVersion'),
                icon: Icons.tag_outlined,
                label: localizations.versionLabel,
                value: Text(
                  applicationInfo.displayVersion,
                  style: TunathicTextStyles.metadata(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A read-only fact about how the device behaves.
final class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.description,
  });

  final String label;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SkeuoInsetPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(label, style: TunathicTextStyles.compactLabel(context)),
              Text(
                value,
                style: TunathicTextStyles.metadata(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: TunathicTextStyles.metadata(context)),
        ],
      ),
    );
  }
}

/// A labelled row whose control is too wide to sit beside its label.
final class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final Widget child;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return SkeuoInsetPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TunathicTextStyles.compactLabel(context)),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: TunathicTextStyles.metadata(context)),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
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
    return RackRow(
      icon: icon,
      label: title,
      onTap: onTap,
      value: Icon(
        Icons.chevron_right,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
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
    return SkeuoButton(
      compact: true,
      selected: selected,
      semanticLabel: label,
      onPressed: () => onSelected(value),
      child: Text(label, textAlign: TextAlign.center),
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
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: RackRow(
        label: label,
        onTap: () => onSelected(value),
        value: selected
            ? SkeuoStatusBadge(
                label: label,
                color: colors.primary,
                icon: Icons.check,
              )
            : Icon(
                Icons.radio_button_unchecked,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
      ),
    );
  }
}

final class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SkeuoInsetPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TunathicTextStyles.compactLabel(context)),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: TunathicTextStyles.metadata(context)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SkeuoSwitch(value: value, semanticLabel: label, onChanged: onChanged),
        ],
      ),
    );
  }
}
