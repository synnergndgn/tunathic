import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// Compatibility entry point shared by the tuner and Settings.
final class TuningReferenceSelector extends StatelessWidget {
  const TuningReferenceSelector({
    required this.reference,
    required this.onChanged,
    this.enabled = true,
    this.showSlider = false,
    super.key,
  });

  final TuningReference reference;
  final ValueChanged<TuningReference> onChanged;
  final bool enabled;
  final bool showSlider;

  @override
  Widget build(BuildContext context) {
    return SkeuoFrequencyControl(
      reference: reference,
      onChanged: onChanged,
      enabled: enabled,
      showRail: showSlider,
    );
  }
}

/// A physical A4 stepper with a recessed readout and optional frequency rail.
final class SkeuoFrequencyControl extends StatelessWidget {
  const SkeuoFrequencyControl({
    required this.reference,
    required this.onChanged,
    this.enabled = true,
    this.showRail = false,
    super.key,
  });

  final TuningReference reference;
  final ValueChanged<TuningReference> onChanged;
  final bool enabled;
  final bool showRail;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final studio = StudioTheme.of(context);
    final colors = Theme.of(context).colorScheme;
    final value = localizations.referencePitchValue(reference.label);

    return Column(
      key: const Key('tunerReferenceSelector'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _StepButton(
              buttonKey: const Key('tunerReferenceDecrease'),
              icon: Icons.remove,
              tooltip: localizations.decreaseReferencePitch,
              onPressed: enabled && reference.canDecrease
                  ? () => onChanged(reference.stepped(-1))
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SkeuoDisplayPanel(
                radius: const Radius.circular(4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                child: Semantics(
                  liveRegion: true,
                  label: localizations.referencePitchSemantics(reference.label),
                  child: ExcludeSemantics(
                    child: Text(
                      value,
                      key: const Key('tunerReferenceValue'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TunathicTextStyles.tunerValue(
                        context,
                        size: 20,
                      ).copyWith(letterSpacing: 0.7),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StepButton(
              buttonKey: const Key('tunerReferenceIncrease'),
              icon: Icons.add,
              tooltip: localizations.increaseReferencePitch,
              onPressed: enabled && reference.canIncrease
                  ? () => onChanged(reference.stepped(1))
                  : null,
            ),
          ],
        ),
        if (showRail) ...[
          const SizedBox(height: AppSpacing.md),
          SkeuoInsetPanel(
            radius: const Radius.circular(5),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colors.primary,
                inactiveTrackColor: studio.panelBorderStrong,
                trackHeight: 8,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                thumbShape: const _SkeuoSliderThumbShape(),
              ),
              child: Slider(
                key: const Key('tunerReferenceSlider'),
                value: reference.a4FrequencyHz,
                min: TuningReference.minimumHz,
                max: TuningReference.maximumHz,
                divisions:
                    ((TuningReference.maximumHz - TuningReference.minimumHz) /
                            TuningReference.stepHz)
                        .round(),
                label: value,
                onChanged: enabled
                    ? (raw) => onChanged(TuningReference.resolve(raw))
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${TuningReference.minimumHz.round()}',
                style: TunathicTextStyles.metadata(context),
              ),
              Text('Hz', style: TunathicTextStyles.compactLabel(context)),
              Text(
                '${TuningReference.maximumHz.round()}',
                style: TunathicTextStyles.metadata(context),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Align(
          child: SkeuoButton(
            key: const Key('tunerReferenceReset'),
            compact: true,
            selected: reference == TuningReference.standard,
            semanticLabel: localizations.resetReferencePitch,
            onPressed: enabled && reference != TuningReference.standard
                ? () => onChanged(TuningReference.standard)
                : null,
            icon: Icons.settings_backup_restore_outlined,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '440',
                  style: TunathicTextStyles.readout(
                    context,
                  ).copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  localizations.resetReferencePitch,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.buttonKey,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SkeuoButton(
        key: buttonKey,
        compact: true,
        semanticLabel: tooltip,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}

final class _SkeuoSliderThumbShape extends SliderComponentShape {
  const _SkeuoSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 28);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final enabled = enableAnimation.value;
    final base = sliderTheme.thumbColor ?? Colors.orange;
    final rect = Rect.fromCenter(center: center, width: 22, height: 26);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(
      rrect.shift(const Offset(2, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.28 * enabled),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92 * enabled),
            base.withValues(alpha: enabled),
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.22),
              base,
            ).withValues(alpha: enabled),
          ],
        ).createShader(rect),
    );
    canvas.drawRRect(
      rrect.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black.withValues(alpha: 0.28 * enabled),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 6),
      Offset(center.dx, center.dy + 6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72 * enabled)
        ..strokeWidth = 1.3,
    );
  }
}
