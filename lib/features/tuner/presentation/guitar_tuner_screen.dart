import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuner_display_panel.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuning_preset_strip.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/studio_state_panel.dart';
import 'package:tunathic/shared/widgets/studio/tunathic_scaffold.dart';

final class GuitarTunerScreen extends ConsumerStatefulWidget {
  const GuitarTunerScreen({super.key});

  @override
  ConsumerState<GuitarTunerScreen> createState() => _GuitarTunerScreenState();
}

final class _GuitarTunerScreenState extends ConsumerState<GuitarTunerScreen>
    with WidgetsBindingObserver {
  GuitarTunerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(guitarTunerProvider.notifier).ensureListening());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller != null) {
      unawaited(
        controller.handleLifecycle(
          isForeground: state == AppLifecycleState.resumed,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guitarTunerProvider);
    final controller = ref.read(guitarTunerProvider.notifier);
    _controller = controller;
    return GuitarTunerView(
      state: state,
      onResume: () => unawaited(controller.start()),
      onModeChanged: (mode) => unawaited(controller.setMode(mode)),
      onStringSelected: (position) =>
          unawaited(controller.selectManualString(position)),
      onOpenSettings: () => context.push(AppRoutes.tunerSettings),
      onOpenDiagnostics: kDebugMode
          ? () => context.push(AppRoutes.tunerDiagnostics)
          : null,
    );
  }
}

final class GuitarTunerView extends StatelessWidget {
  const GuitarTunerView({
    required this.state,
    required this.onResume,
    required this.onModeChanged,
    required this.onStringSelected,
    required this.onOpenSettings,
    this.onOpenDiagnostics,
    super.key,
  });

  final GuitarTunerState state;
  final VoidCallback onResume;
  final ValueChanged<TunerMode> onModeChanged;
  final ValueChanged<int> onStringSelected;
  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenDiagnostics;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final error = _errorPanel(localizations);

    return TunathicScaffold(
      title: localizations.guitarTuner,
      showSignalLines: false,
      maxContentWidth: AppSpacing.readingMaxWidth,
      actions: [
        if (onOpenDiagnostics != null)
          IconButton(
            key: const Key('openTunerDiagnostics'),
            tooltip: localizations.openTunerDiagnostics,
            onPressed: onOpenDiagnostics,
            icon: const Icon(Icons.science_outlined),
          ),
        IconButton(
          key: const Key('openTuningSettings'),
          tooltip: localizations.tunerSettingsTooltip,
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      bottomDock: error == null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.sm,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              child: SkeuoButton(
                key: const Key('retryGuitarTunerMicrophone'),
                onPressed: onResume,
                icon: Icons.mic_outlined,
                selected: true,
                expand: true,
                child: Text(localizations.retryMicrophone),
              ),
            ),
      body: ListView(
        key: const Key('guitarTunerScroll'),
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _AutoManualToggle(
              selected: state.settings.mode == TunerMode.manual
                  ? TunerMode.manual
                  : TunerMode.automatic,
              enabled: state.settingsLoaded,
              automaticLabel: localizations.automaticMode,
              manualLabel: localizations.manualMode,
              onChanged: onModeChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          RepaintBoundary(child: _display(context, localizations)),
          if (state.settings.mode == TunerMode.manual) ...[
            const SizedBox(height: AppSpacing.medium),
            RackPanel(
              label: localizations.targetStringLabel,
              labelIcon: Icons.linear_scale,
              child: TuningPresetStrip(
                strings: state.preset.strings,
                selectedPosition: state.target?.stringPosition,
                enabled: state.settingsLoaded,
                onSelected: onStringSelected,
                semanticsFor: (string) => localizations.targetStringSemantics(
                  string.stringPosition,
                  string.displayName,
                ),
              ),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: AppSpacing.medium),
            error,
          ],
        ],
      ),
    );
  }

  Widget _display(BuildContext context, AppLocalizations localizations) {
    final pitch = state.pitch;
    final note = state.note;
    final target = state.target;
    final cents = state.cents;
    final signal = _studioSignal(state.accuracy, state.direction);

    return TunerDisplayPanel(
      signal: signal,
      noteName: note?.noteName,
      octave: note?.octave,
      cents: cents,
      centsText: cents == null
          ? '—'
          : localizations.signedCentsValue(
              cents >= 0 ? '+${cents.round()}' : cents.round().toString(),
            ),
      noteSemantics: note == null
          ? localizations.noDetectedNote
          : localizations.detectedNoteSemantics(note.noteName, note.octave),
      centsSemantics: cents == null
          ? localizations.centsUnavailableSemantics
          : localizations.centsDirectionSemantics(
              cents.abs().round(),
              _directionText(localizations, state.direction),
            ),
      frequencyText: pitch == null
          ? localizations.frequencyUnavailable
          : localizations.frequencyHertzValue(
              pitch.frequencyHz.toStringAsFixed(1),
            ),
      frequencySemantics: pitch == null
          ? localizations.frequencyUnavailableSemantics
          : localizations.frequencySemantics(
              pitch.frequencyHz.toStringAsFixed(1),
            ),
      referenceText: '',
      referenceSemantics: '',
      showReference: false,
      showTarget: !state.isChromatic,
      targetText: target == null
          ? localizations.tunerTargetPending
          : '${target.stringPosition} · ${target.displayName}',
      targetSemantics: target == null
          ? localizations.tunerTargetPending
          : localizations.tunerActiveTargetSemantics(
              target.displayName,
              target.stringPosition,
            ),
      flatLabel: localizations.flatLabel,
      inTuneLabel: localizations.inTuneLabel,
      sharpLabel: localizations.sharpLabel,
    );
  }

  Widget? _errorPanel(AppLocalizations localizations) =>
      switch (state.signalState) {
        TunerSignalState.permissionDenied => StudioStatePanel(
          icon: Icons.mic_off_outlined,
          title: localizations.tunerMicrophonePermissionTitle,
          description: localizations.tunerPermissionDeniedMessage,
          tone: StudioStateTone.problem,
        ),
        TunerSignalState.microphoneUnavailable => StudioStatePanel(
          icon: Icons.mic_external_off_outlined,
          title: localizations.tunerMicrophoneUnavailableTitle,
          description: localizations.tunerMicrophoneUnavailableMessage,
          tone: StudioStateTone.problem,
        ),
        TunerSignalState.processingError => StudioStatePanel(
          icon: Icons.error_outline,
          title: localizations.tunerProcessingErrorTitle,
          description: localizations.tunerProcessingErrorMessage,
          tone: StudioStateTone.problem,
        ),
        _ => null,
      };

  StudioSignal _studioSignal(
    TunerAccuracy? accuracy,
    TunerDirection? direction,
  ) {
    if (accuracy == null) return StudioSignal.idle;
    if (accuracy == TunerAccuracy.inTune ||
        direction == TunerDirection.inTune) {
      return StudioSignal.inTune;
    }
    return switch (direction) {
      TunerDirection.flat => StudioSignal.flat,
      TunerDirection.sharp => StudioSignal.sharp,
      _ => StudioSignal.idle,
    };
  }

  String _directionText(
    AppLocalizations localizations,
    TunerDirection? direction,
  ) => switch (direction) {
    TunerDirection.flat => localizations.flatLabel,
    TunerDirection.inTune => localizations.inTuneLabel,
    TunerDirection.sharp => localizations.sharpLabel,
    null => localizations.centsUnavailableSemantics,
  };
}

final class _AutoManualToggle extends StatelessWidget {
  const _AutoManualToggle({
    required this.selected,
    required this.enabled,
    required this.automaticLabel,
    required this.manualLabel,
    required this.onChanged,
  });

  final TunerMode selected;
  final bool enabled;
  final String automaticLabel;
  final String manualLabel;
  final ValueChanged<TunerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = selected == TunerMode.manual
        ? manualLabel
        : automaticLabel;
    return Semantics(
      label: AppLocalizations.of(context).tunerModeSemantics(selectedLabel),
      child: Wrap(
        key: const Key('tunerAutoManualToggle'),
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          SkeuoButton(
            key: const Key('tunerAutomaticMode'),
            compact: true,
            selected: selected == TunerMode.automatic,
            onPressed: enabled ? () => onChanged(TunerMode.automatic) : null,
            child: Text(automaticLabel),
          ),
          SkeuoButton(
            key: const Key('tunerManualMode'),
            compact: true,
            selected: selected == TunerMode.manual,
            onPressed: enabled ? () => onChanged(TunerMode.manual) : null,
            child: Text(manualLabel),
          ),
        ],
      ),
    );
  }
}
