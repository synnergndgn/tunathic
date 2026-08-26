import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/shared/widgets/studio/frequency_readout.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';
import 'package:tunathic/features/tuner/presentation/widgets/note_readout.dart';
import 'package:tunathic/features/tuner/presentation/widgets/pitch_meter.dart';

/// The tuner's readout, presented as one recessed instrument display.
///
/// Everything needed to tune a string is inside this one rectangle in reading
/// order: what is being aimed at, what is sounding, how far off it is, and
/// which way to turn. Localisation stays with the screen; this panel only
/// arranges text it is handed.
final class TunerDisplayPanel extends StatelessWidget {
  const TunerDisplayPanel({
    required this.signal,
    required this.noteName,
    required this.octave,
    required this.cents,
    required this.centsText,
    required this.noteSemantics,
    required this.centsSemantics,
    required this.frequencyText,
    required this.frequencySemantics,
    required this.referenceText,
    required this.referenceSemantics,
    required this.targetText,
    required this.targetSemantics,
    required this.flatLabel,
    required this.inTuneLabel,
    required this.sharpLabel,
    this.showTarget = true,
    this.showReference = true,
    super.key,
  });

  final StudioSignal signal;
  final String? noteName;
  final int? octave;
  final double? cents;
  final String centsText;
  final String noteSemantics;
  final String centsSemantics;
  final String frequencyText;
  final String frequencySemantics;
  final String referenceText;
  final String referenceSemantics;
  final String targetText;
  final String targetSemantics;
  final String flatLabel;
  final String inTuneLabel;
  final String sharpLabel;
  final bool showTarget;
  final bool showReference;

  @override
  Widget build(BuildContext context) {
    final studio = StudioTheme.of(context);
    final signalColor = studio.signalColor(signal);
    final isReading = signal != StudioSignal.idle;

    return _display(context, signalColor: signalColor, isReading: isReading);
  }

  Widget _display(
    BuildContext context, {
    required Color signalColor,
    required bool isReading,
  }) {
    final studio = StudioTheme.of(context);
    return SkeuoSurface(
      prominent: true,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SkeuoDisplayPanel(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Target and reference share a Wrap so a long preset name pushes
            // the reference onto its own line instead of squeezing it.
            if (showTarget || showReference) ...[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (showTarget)
                    FrequencyReadout(
                      label: targetSemantics,
                      value: targetText,
                      icon: Icons.adjust_outlined,
                    ),
                  if (showReference)
                    FrequencyReadout(
                      label: referenceSemantics,
                      value: referenceText,
                      icon: Icons.tune_outlined,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
            SkeuoDisplayPanel(
              radius: const Radius.circular(5),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.sm,
              ),
              child: Semantics(
                key: const Key('detectedNoteSemantics'),
                container: true,
                label: noteSemantics,
                liveRegion: true,
                child: ExcludeSemantics(
                  child: NoteReadout(
                    noteName: noteName,
                    octave: octave,
                    color: isReading
                        ? signalColor
                        : Theme.of(context).colorScheme.onSurface,
                    glow: signal == StudioSignal.inTune
                        ? studio.glowOpacity
                        : 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              child: SkeuoDisplayPanel(
                radius: const Radius.circular(4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.sm,
                ),
                child: Semantics(
                  container: true,
                  label: centsSemantics,
                  child: ExcludeSemantics(
                    child: Text(
                      centsText,
                      key: const Key('tunerCentsValue'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TunathicTextStyles.tunerValue(
                        context,
                        size: 24,
                      ).copyWith(color: signalColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            PitchMeter(
              key: const Key('tunerCentsIndicator'),
              cents: cents,
              signal: signal,
              semanticsLabel: centsSemantics,
              flatLabel: flatLabel,
              inTuneLabel: inTuneLabel,
              sharpLabel: sharpLabel,
            ),
            const SizedBox(height: AppSpacing.medium),
            Align(
              child: FrequencyReadout(
                label: frequencySemantics,
                value: frequencyText,
                valueKey: const Key('tunerFrequencyValue'),
                icon: Icons.graphic_eq,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
