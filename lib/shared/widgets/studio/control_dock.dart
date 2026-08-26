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
/// keeps the longer Turkish tool names readable on a 320 pt screen. A label
/// that is one long word instead shrinks to fit — see [_DockLabel].
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
          // Compact padding, so three footswitches across a 411 pt phone leave
          // their labels room to sit on one line at the default text scale.
          compact: true,
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
                _DockLabel(label: label, color: foreground),
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

/// A dock label that never gets cut in half.
///
/// Flutter wraps at a space when it can and breaks mid-word when it cannot, so
/// a one-word tool name wider than its column came out as "Metrono / me". This
/// measures the longest word first and shrinks the whole label just enough for
/// that word to fit on one line, which leaves two-word labels wrapping at their
/// space exactly as before.
final class _DockLabel extends StatelessWidget {
  const _DockLabel({required this.label, required this.color});

  /// Below this the label would be too small to read; it ellipsises instead.
  static const _minimumScale = 0.74;

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TunathicTextStyles.compactLabel(
      context,
    ).copyWith(color: color);

    return LayoutBuilder(
      builder: (context, constraints) {
        var effective = style;
        final available = constraints.maxWidth;
        if (available.isFinite && available > 0) {
          final longest = label
              .split(RegExp(r'\s+'))
              .fold<String>('', (a, b) => b.length > a.length ? b : a);
          final painter = TextPainter(
            text: TextSpan(text: longest, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          if (painter.width > available) {
            final scale = (available / painter.width).clamp(_minimumScale, 1.0);
            effective = style.copyWith(
              fontSize: (style.fontSize ?? 14) * scale,
            );
          }
          painter.dispose();
        }

        return Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: effective,
        );
      },
    );
  }
}
