import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';

/// A group of device preferences.
///
/// Rows are separated by hairlines inside one panel rather than each getting
/// its own card, which is what turns the settings screen from a SaaS list into
/// a device menu.
final class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
    this.icon,
    this.description,
    super.key,
  });

  final String title;
  final IconData? icon;

  /// One short line explaining what the group controls, when the row labels
  /// alone would not say it.
  final String? description;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SkeuoSettingsSection(
      title: title,
      icon: icon,
      description: description,
      children: children,
    );
  }
}

/// The physical faceplate used for one group of device preferences.
///
/// Kept public so screens that are not yet settings screens can use the same
/// control-panel language without rebuilding a labelled rack panel.
final class SkeuoSettingsSection extends StatelessWidget {
  const SkeuoSettingsSection({
    required this.title,
    required this.children,
    this.icon,
    this.description,
    super.key,
  });

  final String title;
  final IconData? icon;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RackPanel(
      label: title,
      labelIcon: icon,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0 || description != null)
              const SizedBox(height: AppSpacing.sm),
            children[index],
          ],
        ],
      ),
    );
  }
}
