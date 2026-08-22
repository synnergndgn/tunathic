import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_motion.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// A physical push button with distinct raised, pressed, and disabled states.
final class SkeuoButton extends StatefulWidget {
  const SkeuoButton({
    required this.child,
    required this.onPressed,
    this.icon,
    this.selected = false,
    this.destructive = false,
    this.compact = false,
    this.expand = false,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool selected;
  final bool destructive;
  final bool compact;
  final bool expand;
  final String? semanticLabel;

  @override
  State<SkeuoButton> createState() => _SkeuoButtonState();
}

final class _SkeuoButtonState extends State<SkeuoButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studio = StudioTheme.of(context);
    final enabled = widget.onPressed != null;
    final accent = widget.destructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final active = widget.selected && enabled;
    final face = active
        ? Color.alphaBlend(
            accent.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.58 : 0.82,
            ),
            studio.panelRaised,
          )
        : studio.panelRaised;
    final foreground = !enabled
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : active
        ? theme.brightness == Brightness.light
              ? const Color(0xFF2E180D)
              : theme.colorScheme.onPrimary
        : widget.destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    final padding = EdgeInsets.symmetric(
      horizontal: widget.compact ? AppSpacing.md : AppSpacing.large,
      vertical: widget.compact ? AppSpacing.sm : AppSpacing.md,
    );

    Widget content = IconTheme.merge(
      data: IconThemeData(color: foreground, size: widget.compact ? 18 : 20),
      child: DefaultTextStyle.merge(
        style: theme.textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.25,
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (widget.expand)
              Expanded(child: Center(child: widget.child))
            else
              Flexible(child: widget.child),
          ],
        ),
      ),
    );

    Widget surface = _pressed && enabled
        ? SkeuoInsetPanel(
            radius: AppRadii.medium,
            surfaceColor: Color.alphaBlend(
              Colors.black.withValues(alpha: 0.04),
              face,
            ),
            accent: active ? accent : null,
            padding: padding,
            child: content,
          )
        : SkeuoSurface(
            radius: AppRadii.medium,
            prominent: active,
            surfaceColor: face,
            accent: active ? accent : null,
            padding: padding,
            child: Opacity(opacity: enabled ? 1 : 0.62, child: content),
          );
    surface = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.minTouchTarget,
        minWidth: AppSpacing.minTouchTarget,
      ),
      child: surface,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        excluding: widget.semanticLabel != null,
        child: AnimatedScale(
          scale: _pressed && enabled ? 0.988 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.fast,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: enabled
                  ? (value) => setState(() => _pressed = value)
                  : null,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              borderRadius: AppRadii.mediumBorder,
              child: surface,
            ),
          ),
        ),
      ),
    );
  }
}

/// A toggle switch built as a recessed slot with a raised enamel thumb.
final class SkeuoSwitch extends StatelessWidget {
  const SkeuoSwitch({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studio = StudioTheme.of(context);
    final enabled = onChanged != null;
    final active = theme.colorScheme.primary;

    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: enabled,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onChanged!(!value) : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 60,
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Center(
              child: SizedBox(
                width: 58,
                height: 34,
                child: SkeuoInsetPanel(
                  radius: const Radius.circular(17),
                  surfaceColor: value
                      ? Color.alphaBlend(
                          active.withValues(alpha: 0.46),
                          studio.display,
                        )
                      : studio.display,
                  child: AnimatedAlign(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppMotion.fast,
                    curve: AppMotion.standardCurve,
                    alignment: value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: SizedBox.square(
                        dimension: 26,
                        child: SkeuoSurface(
                          radius: const Radius.circular(13),
                          prominent: true,
                          surfaceColor: value ? active : studio.panelRaised,
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: value
                                    ? theme.colorScheme.onPrimary
                                    : studio.panelBorderStrong,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One option in a [SkeuoSegmentedControl].
final class SkeuoSegment<T> {
  const SkeuoSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// A bank of physical selector keys seated in one recessed control well.
final class SkeuoSegmentedControl<T> extends StatelessWidget {
  const SkeuoSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<SkeuoSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SkeuoInsetPanel(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final segment in segments)
            SkeuoButton(
              compact: true,
              selected: selected == segment.value,
              icon: segment.icon,
              onPressed: onChanged == null
                  ? null
                  : () => onChanged!(segment.value),
              child: Text(
                segment.label,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
