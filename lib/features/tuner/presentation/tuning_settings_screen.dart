import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/presentation/tuner_localizations.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuning_reference_selector.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

/// Tuner configuration lives away from the time-sensitive instrument display.
final class TuningSettingsScreen extends ConsumerWidget {
  const TuningSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guitarTunerProvider);
    final controller = ref.read(guitarTunerProvider.notifier);
    final localizations = AppLocalizations.of(context);

    return TunathicScaffold(
      title: localizations.tunerSettingsTitle,
      maxContentWidth: AppSpacing.readingMaxWidth,
      body: ListView(
        key: const Key('tuningSettingsScroll'),
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          RackPanel(
            label: localizations.tuningSystemLabel,
            labelIcon: Icons.piano_outlined,
            child: SkeuoInsetPanel(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  SkeuoButton(
                    key: const Key('tuningSystemChromatic'),
                    selected: state.isChromatic,
                    expand: true,
                    onPressed: state.settingsLoaded
                        ? () =>
                              unawaited(controller.setMode(TunerMode.chromatic))
                        : null,
                    child: Text(localizations.chromaticMode),
                  ),
                  for (final presetId in TuningPresetId.values)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: SkeuoButton(
                        key: Key('tuningSystem-${presetId.id}'),
                        selected:
                            !state.isChromatic &&
                            state.settings.presetId == presetId,
                        expand: true,
                        onPressed: state.settingsLoaded
                            ? () async {
                                await controller.setPreset(presetId);
                                if (state.isChromatic) {
                                  await controller.setMode(TunerMode.automatic);
                                }
                              }
                            : null,
                        child: Text(localizations.tuningPresetName(presetId)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          RackPanel(
            label: localizations.referencePitchLabel,
            labelIcon: Icons.tune_outlined,
            child: TuningReferenceSelector(
              reference: state.reference,
              enabled: state.settingsLoaded,
              onChanged: (reference) =>
                  unawaited(controller.setReference(reference)),
            ),
          ),
        ],
      ),
    );
  }
}
