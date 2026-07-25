import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_motion.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

final class CentsIndicator extends StatelessWidget {
  const CentsIndicator({
    required this.cents,
    required this.accuracy,
    required this.semanticsLabel,
    required this.flatLabel,
    required this.inTuneLabel,
    required this.sharpLabel,
    this.visualRangeCents = 50,
    super.key,
  });

  final double? cents;
  final TunerAccuracy? accuracy;
  final String semanticsLabel;
  final String flatLabel;
  final String inTuneLabel;
  final String sharpLabel;
  final double visualRangeCents;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final visualCents = (cents ?? 0).clamp(-visualRangeCents, visualRangeCents);
    final alignment = visualCents / visualRangeCents;
    final indicatorColor = switch (accuracy) {
      TunerAccuracy.inTune => colors.tertiary,
      TunerAccuracy.near => colors.secondary,
      TunerAccuracy.out => colors.primary,
      null => colors.outline,
    };

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 35,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: AppRadii.smallBorder,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 26,
                    bottom: 25,
                    child: Container(width: 3, color: colors.onSurface),
                  ),
                  for (final fraction in const [
                    -0.75,
                    -0.5,
                    -0.25,
                    0.25,
                    0.5,
                    0.75,
                  ])
                    Align(
                      alignment: Alignment(fraction, -0.05),
                      child: Container(
                        width: 1,
                        height: fraction.abs() == 0.5 ? 22 : 16,
                        color: colors.outline,
                      ),
                    ),
                  AnimatedAlign(
                    duration: reducedMotion
                        ? Duration.zero
                        : AppMotion.standard,
                    curve: AppMotion.standardCurve,
                    alignment: Alignment(alignment, -0.75),
                    child: AnimatedOpacity(
                      duration: reducedMotion ? Duration.zero : AppMotion.fast,
                      opacity: cents == null ? 0 : 1,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 42,
                        color: indicatorColor,
                      ),
                    ),
                  ),
                  const Positioned(left: 0, bottom: 0, child: Text('−50')),
                  const Positioned(bottom: 0, child: Text('0')),
                  const Positioned(right: 0, bottom: 0, child: Text('+50')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 18),
                      const SizedBox(width: AppSpacing.xSmall),
                      Flexible(child: Text(flatLabel)),
                    ],
                  ),
                ),
                Text(
                  inTuneLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(sharpLabel, textAlign: TextAlign.end),
                      ),
                      const SizedBox(width: AppSpacing.xSmall),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
