import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// The strip of controls at the foot of a screen.
///
/// Reads as the row of footswitches on a pedal rather than a toolbar.
final class ControlDock extends StatelessWidget {
  const ControlDock({
    required this.children,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SkeuoSurface(
      prominent: true,
      padding: padding,
      child: Row(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: children[index]),
          ],
        ],
      ),
    );
  }
}

/// One control on a dock: an icon over a short label, sized like a footswitch.
///
/// The label wraps to two lines before it is ever ellipsised, which is what
/// keeps the longer Turkish tool names readable on a 320 pt screen.
final class ControlDockItem extends StatelessWidget {
  const ControlDockItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.accent = false,
    this.caption,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  /// Marks the one control the screen wants pressed first.
  final bool accent;

  /// Optional second line, e.g. the tuning a preset would load.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = !enabled
        ? colors.onSurfaceVariant.withValues(alpha: 0.5)
        : accent
        ? colors.primary
        : colors.onSurface;

    return Semantics(
      button: true,
      enabled: enabled,
      label: caption == null ? label : '$label, $caption',
      child: ExcludeSemantics(
        child: SkeuoButton(
          selected: accent,
          expand: true,
          onPressed: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: foreground),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TunathicTextStyles.compactLabel(
                    context,
                  ).copyWith(color: foreground),
                ),
                if (caption != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    caption!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TunathicTextStyles.metadata(
                      context,
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
