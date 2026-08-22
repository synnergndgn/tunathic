import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// How urgently a state panel should present itself.
enum StudioStateTone {
  /// Everything is fine, there is simply nothing to show yet.
  neutral,

  /// The user has to do something before the tool can work.
  action,

  /// Something failed.
  problem,
}

/// The one panel Tunathic uses for "nothing here yet", "grant the microphone"
/// and "that did not work".
///
/// Keeping them one component is deliberate: the three states differ only in
/// tone and wording, and a user who has seen one recognises the next.
final class StudioStatePanel extends StatelessWidget {
  const StudioStatePanel({
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.tone = StudioStateTone.neutral,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final StudioStateTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final studio = StudioTheme.of(context);
    final accent = switch (tone) {
      StudioStateTone.neutral => studio.idle,
      StudioStateTone.action => colors.primary,
      StudioStateTone.problem => colors.error,
    };

    return Semantics(
      container: true,
      label: description == null ? title : '$title. $description',
      child: ExcludeSemantics(
        child: SkeuoSurface(
          prominent: tone != StudioStateTone.neutral,
          accent: accent.withValues(alpha: 0.55),
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(
                    dimension: 44,
                    child: SkeuoInsetPanel(
                      radius: const Radius.circular(22),
                      surfaceColor: accent.withValues(alpha: 0.12),
                      child: Center(child: Icon(icon, color: accent, size: 22)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        if (description != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          SkeuoDisplayPanel(
                            radius: const Radius.circular(4),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: AppSpacing.medium),
                SkeuoButton(
                  selected: true,
                  expand: true,
                  onPressed: onAction,
                  child: Text(actionLabel!, textAlign: TextAlign.center),
                ),
              ],
              if (onSecondaryAction != null &&
                  secondaryActionLabel != null) ...[
                const SizedBox(height: AppSpacing.sm),
                SkeuoButton(
                  expand: true,
                  onPressed: onSecondaryAction,
                  child: Text(
                    secondaryActionLabel!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A state panel that asks for the microphone.
final class PermissionStatePanel extends StatelessWidget {
  const PermissionStatePanel({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.blocked = false,
    super.key,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  /// The request was denied, rather than simply not asked yet.
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    return StudioStatePanel(
      icon: blocked ? Icons.mic_off_outlined : Icons.mic_none_outlined,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: blocked ? StudioStateTone.problem : StudioStateTone.action,
    );
  }
}

/// A state panel for a list or library with nothing in it yet.
final class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return StudioStatePanel(
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: StudioStateTone.neutral,
    );
  }
}
