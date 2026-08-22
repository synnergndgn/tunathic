import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// The six string pads, laid out like the pads on a pedal tuner.
///
/// Wraps rather than scrolls, so every string stays reachable without a
/// horizontal gesture even on the narrowest phone.
final class TuningPresetStrip extends StatelessWidget {
  const TuningPresetStrip({
    required this.strings,
    required this.selectedPosition,
    required this.enabled,
    required this.onSelected,
    required this.semanticsFor,
    super.key,
  });

  final List<TuningStringTarget> strings;
  final int? selectedPosition;

  /// False in automatic mode, where the tuner picks the string itself.
  final bool enabled;

  final ValueChanged<int> onSelected;
  final String Function(TuningStringTarget) semanticsFor;

  @override
  Widget build(BuildContext context) {
    return SkeuoInsetPanel(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Six across on anything roomy, three across on a small phone, so
            // a pad never gets narrower than a fingertip.
            final columns = constraints.maxWidth >= 380 ? 6 : 3;
            final spacing = AppSpacing.sm;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final string in strings)
                  SizedBox(
                    width: width,
                    child: _StringPad(
                      key: Key('tunerString${string.stringPosition}'),
                      label: '${string.stringPosition} · ${string.displayName}',
                      semanticsLabel: semanticsFor(string),
                      selected: selectedPosition == string.stringPosition,
                      enabled: enabled,
                      onTap: () => onSelected(string.stringPosition),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _StringPad extends StatelessWidget {
  const _StringPad({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final String label;
  final String semanticsLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.onSurface : colors.onSurfaceVariant;

    return Semantics(
      label: semanticsLabel,
      selected: selected,
      button: enabled,
      enabled: enabled,
      child: ExcludeSemantics(
        child: SkeuoButton(
          compact: true,
          selected: selected,
          onPressed: enabled ? onTap : null,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TunathicTextStyles.compactLabel(context).copyWith(
                  color: enabled
                      ? foreground
                      : foreground.withValues(alpha: 0.55),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
