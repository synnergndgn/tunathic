import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/presentation/cents_indicator.dart';
import 'package:tunathic/l10n/app_localizations.dart';

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
    _controller?.releaseForNavigation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guitarTunerProvider);
    final controller = ref.read(guitarTunerProvider.notifier);
    _controller = controller;
    return GuitarTunerView(
      state: state,
      onStart: () => unawaited(controller.start()),
      onStop: () => unawaited(controller.stop()),
      onModeChanged: (mode) => unawaited(controller.setMode(mode)),
      onPresetChanged: (preset) => unawaited(controller.setPreset(preset)),
      onStringSelected: (position) =>
          unawaited(controller.selectManualString(position)),
      onOpenDiagnostics: kDebugMode
          ? () => context.push(AppRoutes.tunerDiagnostics)
          : null,
    );
  }
}

final class GuitarTunerView extends StatelessWidget {
  const GuitarTunerView({
    required this.state,
    required this.onStart,
    required this.onStop,
    required this.onModeChanged,
    required this.onPresetChanged,
    required this.onStringSelected,
    this.onOpenDiagnostics,
    super.key,
  });

  final GuitarTunerState state;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final ValueChanged<TunerMode> onModeChanged;
  final ValueChanged<TuningPresetId> onPresetChanged;
  final ValueChanged<int> onStringSelected;
  final VoidCallback? onOpenDiagnostics;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final pitch = state.pitch;
    final target = state.target;
    final cents = state.cents;
    final direction = state.direction;
    final statusText = _signalText(localizations, state.signalState);
    final directionText = _directionText(localizations, direction);
    final noteSemantics = pitch == null
        ? localizations.noDetectedNote
        : localizations.detectedNoteSemantics(pitch.noteName, pitch.octave);
    final centsSemantics = cents == null
        ? localizations.centsUnavailableSemantics
        : localizations.centsDirectionSemantics(
            cents.abs().round(),
            directionText,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.guitarTuner),
        actions: [
          if (onOpenDiagnostics != null)
            IconButton(
              key: const Key('openTunerDiagnostics'),
              tooltip: localizations.openTunerDiagnostics,
              onPressed: onOpenDiagnostics,
              icon: const Icon(Icons.science_outlined),
            ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              key: const Key('guitarTunerScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                DropdownButtonFormField<TuningPresetId>(
                  key: ValueKey('tunerPreset-${state.settings.presetId.id}'),
                  initialValue: state.settings.presetId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: localizations.tuningPresetLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final preset in TuningPresetId.values)
                      DropdownMenuItem(
                        value: preset,
                        child: Text(_presetName(localizations, preset)),
                      ),
                  ],
                  onChanged: state.settingsLoaded
                      ? (value) {
                          if (value != null) onPresetChanged(value);
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                _ModeSelector(
                  selected: state.settings.mode,
                  enabled: state.settingsLoaded,
                  automaticLabel: localizations.automaticMode,
                  manualLabel: localizations.manualMode,
                  semanticsLabel: localizations.tunerModeSemantics(
                    _modeName(localizations, state.settings.mode),
                  ),
                  onChanged: onModeChanged,
                ),
                const SizedBox(height: AppSpacing.large),
                Semantics(
                  header: true,
                  child: Text(
                    localizations.targetStringLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    for (final string in state.preset.strings)
                      Semantics(
                        label: localizations.targetStringSemantics(
                          string.stringPosition,
                          string.displayName,
                        ),
                        selected:
                            target?.stringPosition == string.stringPosition,
                        child: ChoiceChip(
                          key: Key('tunerString${string.stringPosition}'),
                          label: Text(
                            '${string.stringPosition} · ${string.displayName}',
                          ),
                          selected:
                              target?.stringPosition == string.stringPosition,
                          onSelected:
                              state.settings.mode == TunerMode.manual &&
                                  state.settingsLoaded
                              ? (_) => onStringSelected(string.stringPosition)
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xLarge),
                Semantics(
                  key: const Key('detectedNoteSemantics'),
                  label: noteSemantics,
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: AppSpacing.small,
                      children: [
                        Text(
                          pitch?.noteName ?? '—',
                          key: const Key('tunerDetectedNote'),
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 104,
                                height: 0.95,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (pitch != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.small,
                            ),
                            child: Text(
                              pitch.octave.toString(),
                              key: const Key('tunerDetectedOctave'),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                CentsIndicator(
                  key: const Key('tunerCentsIndicator'),
                  cents: cents,
                  accuracy: state.accuracy,
                  semanticsLabel: centsSemantics,
                  flatLabel: localizations.flatLabel,
                  inTuneLabel: localizations.inTuneLabel,
                  sharpLabel: localizations.sharpLabel,
                ),
                const SizedBox(height: AppSpacing.medium),
                Semantics(
                  label: centsSemantics,
                  child: ExcludeSemantics(
                    child: Text(
                      cents == null
                          ? '—'
                          : localizations.signedCentsValue(
                              cents >= 0
                                  ? '+${cents.round()}'
                                  : cents.round().toString(),
                            ),
                      key: const Key('tunerCentsValue'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Semantics(
                  label: pitch == null
                      ? localizations.frequencyUnavailableSemantics
                      : localizations.frequencySemantics(
                          pitch.frequencyHz.toStringAsFixed(1),
                        ),
                  child: ExcludeSemantics(
                    child: Text(
                      pitch == null
                          ? localizations.frequencyUnavailable
                          : localizations.frequencyHertzValue(
                              pitch.frequencyHz.toStringAsFixed(1),
                            ),
                      key: const Key('tunerFrequencyValue'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _SignalMessage(
                  state: state.signalState,
                  text: statusText,
                  accuracy: state.accuracy,
                ),
                const SizedBox(height: AppSpacing.large),
                SizedBox(
                  height: 56,
                  child: state.isCapturing
                      ? OutlinedButton.icon(
                          key: const Key('stopGuitarTuner'),
                          onPressed: state.audio.isBusy && !state.audio.canStop
                              ? null
                              : onStop,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: Text(localizations.stopTuning),
                        )
                      : FilledButton.icon(
                          key: const Key('startGuitarTuner'),
                          onPressed: onStart,
                          icon: const Icon(Icons.mic_outlined),
                          label: Text(
                            state.signalState ==
                                    TunerSignalState.permissionDenied
                                ? localizations.retryMicrophone
                                : localizations.startTuning,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _presetName(AppLocalizations localizations, TuningPresetId preset) =>
      switch (preset) {
        TuningPresetId.standard => localizations.tuningStandard,
        TuningPresetId.dropD => localizations.tuningDropD,
        TuningPresetId.halfStepDown => localizations.tuningHalfStepDown,
        TuningPresetId.fullStepDown => localizations.tuningFullStepDown,
        TuningPresetId.dadgad => localizations.tuningDadgad,
        TuningPresetId.openG => localizations.tuningOpenG,
        TuningPresetId.openD => localizations.tuningOpenD,
      };

  String _modeName(AppLocalizations localizations, TunerMode mode) =>
      switch (mode) {
        TunerMode.automatic => localizations.automaticMode,
        TunerMode.manual => localizations.manualMode,
      };

  String _directionText(
    AppLocalizations localizations,
    TunerDirection? direction,
  ) => switch (direction) {
    TunerDirection.flat => localizations.flatLabel,
    TunerDirection.inTune => localizations.inTuneLabel,
    TunerDirection.sharp => localizations.sharpLabel,
    null => localizations.noSignal,
  };

  String _signalText(AppLocalizations localizations, TunerSignalState signal) =>
      switch (signal) {
        TunerSignalState.stopped => localizations.tunerStoppedMessage,
        TunerSignalState.requestingPermission =>
          localizations.tunerRequestingPermissionMessage,
        TunerSignalState.listening => localizations.tunerListeningMessage,
        TunerSignalState.waitingForSignal =>
          localizations.tunerWaitingForSignalMessage,
        TunerSignalState.unstableSignal =>
          localizations.tunerUnstableSignalMessage,
        TunerSignalState.stablePitch => localizations.tunerStablePitchMessage,
        TunerSignalState.noSignal => localizations.tunerNoSignalMessage,
        TunerSignalState.permissionDenied =>
          localizations.tunerPermissionDeniedMessage,
        TunerSignalState.microphoneUnavailable =>
          localizations.tunerMicrophoneUnavailableMessage,
        TunerSignalState.processingError =>
          localizations.tunerProcessingErrorMessage,
      };
}

final class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selected,
    required this.enabled,
    required this.automaticLabel,
    required this.manualLabel,
    required this.semanticsLabel,
    required this.onChanged,
  });

  final TunerMode selected;
  final bool enabled;
  final String automaticLabel;
  final String manualLabel;
  final String semanticsLabel;
  final ValueChanged<TunerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Semantics(
      label: semanticsLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360 || textScale > 1.3) {
            return Column(
              key: const Key('tunerModeSelector'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModeButton(
                  selected: selected == TunerMode.automatic,
                  enabled: enabled,
                  icon: Icons.auto_awesome_outlined,
                  label: automaticLabel,
                  onPressed: () => onChanged(TunerMode.automatic),
                ),
                const SizedBox(height: AppSpacing.small),
                _ModeButton(
                  selected: selected == TunerMode.manual,
                  enabled: enabled,
                  icon: Icons.touch_app_outlined,
                  label: manualLabel,
                  onPressed: () => onChanged(TunerMode.manual),
                ),
              ],
            );
          }
          return SegmentedButton<TunerMode>(
            key: const Key('tunerModeSelector'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: TunerMode.automatic,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(automaticLabel),
              ),
              ButtonSegment(
                value: TunerMode.manual,
                icon: const Icon(Icons.touch_app_outlined),
                label: Text(manualLabel),
              ),
            ],
            selected: {selected},
            onSelectionChanged: enabled
                ? (selection) => onChanged(selection.first)
                : null,
          );
        },
      ),
    );
  }
}

final class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.enabled,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final bool enabled;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return selected
        ? FilledButton.tonalIcon(
            onPressed: enabled ? onPressed : null,
            icon: Icon(icon),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: Icon(icon),
            label: Text(label),
          );
  }
}

final class _SignalMessage extends StatelessWidget {
  const _SignalMessage({
    required this.state,
    required this.text,
    required this.accuracy,
  });

  final TunerSignalState state;
  final String text;
  final TunerAccuracy? accuracy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (state) {
      TunerSignalState.stablePitch when accuracy == TunerAccuracy.inTune =>
        Icons.check_circle_outline,
      TunerSignalState.stablePitch => Icons.graphic_eq,
      TunerSignalState.requestingPermission ||
      TunerSignalState.listening ||
      TunerSignalState.waitingForSignal => Icons.hearing_outlined,
      TunerSignalState.unstableSignal => Icons.waves_outlined,
      TunerSignalState.permissionDenied ||
      TunerSignalState.microphoneUnavailable ||
      TunerSignalState.processingError => Icons.error_outline,
      TunerSignalState.stopped => Icons.mic_off_outlined,
      TunerSignalState.noSignal => Icons.signal_cellular_off_outlined,
    };
    final color = switch (state) {
      TunerSignalState.stablePitch when accuracy == TunerAccuracy.inTune =>
        colors.tertiary,
      TunerSignalState.permissionDenied ||
      TunerSignalState.microphoneUnavailable ||
      TunerSignalState.processingError => colors.error,
      _ => colors.primary,
    };
    return Semantics(
      key: const Key('tunerSignalState'),
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadii.smallBorder,
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.small),
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
