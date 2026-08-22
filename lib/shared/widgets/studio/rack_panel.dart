import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// The engraved label that names a rack panel or a settings group.
final class StudioSectionLabel extends StatelessWidget {
  const StudioSectionLabel({
    required this.label,
    this.icon,
    this.trailing,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = TunathicTextStyles.sectionTitle(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: style.color),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Semantics(
              header: true,
              // Left in its authored case: the wide letter spacing already
              // reads as engraving, and upper-casing would mangle Turkish
              // dotted i and hurt screen readers.
              child: Text(
                label,
                style: style,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: trailing!),
          ],
        ],
      ),
    );
  }
}

/// One rack unit: a bordered device surface holding a group of controls.
///
/// This replaces the card stack. Depth comes from the studio elevation scale
/// and a hairline bevel along the top edge — lit from above, like a face plate
/// — never from a Material elevation tint.
final class RackPanel extends StatelessWidget {
  const RackPanel({
    required this.child,
    this.label,
    this.labelIcon,
    this.labelTrailing,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
    this.active = false,
    this.accent,
    this.onTap,
    super.key,
  });

  final Widget child;

  /// Printed above the panel, outside its border, like a silkscreen legend.
  final String? label;
  final IconData? labelIcon;
  final Widget? labelTrailing;

  final EdgeInsetsGeometry padding;

  /// Lifts the surface for the row currently in use.
  final bool active;

  /// Borders the panel in a signal colour when it is reporting something.
  final Color? accent;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget panel = SkeuoSurface(
      prominent: active,
      accent: accent,
      padding: padding,
      child: child,
    );
    if (onTap != null) {
      panel = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: AppRadii.largeBorder,
          child: panel,
        ),
      );
    }

    if (label == null) return panel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioSectionLabel(
          label: label!,
          icon: labelIcon,
          trailing: labelTrailing,
        ),
        panel,
      ],
    );
  }
}

/// A single line inside a rack panel: legend on the left, value on the right.
///
/// Both sides flex, so a long Turkish label pushes the value down to its own
/// line instead of overflowing.
final class RackRow extends StatelessWidget {
  const RackRow({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final Widget value;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final legend = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.md),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TunathicTextStyles.compactLabel(context),
                ),
              ),
            ],
          );
          // Below this width a side-by-side row starts squeezing the value, so
          // the two halves stack instead.
          if (constraints.maxWidth < 280) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                legend,
                const SizedBox(height: AppSpacing.sm),
                Align(alignment: Alignment.centerLeft, child: value),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: legend),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Align(alignment: Alignment.centerRight, child: value),
              ),
            ],
          );
        },
      ),
    );

    final well = SkeuoInsetPanel(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: content,
      ),
    );
    if (onTap == null) return well;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: AppRadii.mediumBorder,
        child: well,
      ),
    );
  }
}
