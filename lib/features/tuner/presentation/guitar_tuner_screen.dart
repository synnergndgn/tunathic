import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_breakpoints.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/app/theme/app_typography.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';
import 'package:tunathic/features/tuner/presentation/tuner_localizations.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuner_display_panel.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuning_preset_strip.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuning_reference_selector.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/animated_signal_transition.dart';
import 'package:tunathic/shared/widgets/studio/control_dock.dart';
import 'package:tunathic/shared/widgets/studio/rack_panel.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';
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
    // The tuner has no start button: arriving here is the request to listen.
    // Deferred one frame so the permission dialog is raised over a screen that
    // has already been laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(guitarTunerProvider.notifier).ensureListening());
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
    // Nothing stops the microphone from here on purpose. Stopping writes to
    // the provider, and by the time dispose() runs this element is defunct,
    // so that write would try to rebuild a widget that no longer exists. The
    // tuner providers are auto-disposed the moment this screen goes, and
    // their teardown closes the capture.
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
      onStop: () => unawaited(controller.stop()),
      onModeChanged: (mode) => unawaited(controller.setMode(mode)),
      onPresetChanged: (preset) => unawaited(controller.setPreset(preset)),
      onStringSelected: (position) =>
          unawaited(controller.selectManualString(position)),
      onReferenceChanged: (reference) =>
          unawaited(controller.setReference(reference)),
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
    required this.onStop,
    required this.onModeChanged,
    required this.onPresetChanged,
    required this.onStringSelected,
    required this.onReferenceChanged,
    this.onOpenDiagnostics,
    super.key,
  });

  final GuitarTunerState state;

  /// Listening starts on its own; this is only for picking it back up after
  /// the player stopped it or the microphone was refused.
  final VoidCallback onResume;

  final VoidCallback onStop;
  final ValueChanged<TunerMode> onModeChanged;
  final ValueChanged<TuningPresetId> onPresetChanged;
  final ValueChanged<int> onStringSelected;
  final ValueChanged<TuningReference> onReferenceChanged;
  final VoidCallback? onOpenDiagnostics;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return TunathicScaffold(
      title: localizations.guitarTuner,
      // The tuner is read at a glance, often in the dark. Nothing decorative
      // competes with the readout.
      showSignalLines: false,
      maxContentWidth: AppSpacing.pageMaxWidth,
      actions: [
        if (onOpenDiagnostics != null)
          IconButton(
            key: const Key('openTunerDiagnostics'),
            tooltip: localizations.openTunerDiagnostics,
            onPressed: onOpenDiagnostics,
            icon: const Icon(Icons.science_outlined),
          ),
      ],
      bottomDock: switch (_transportButton(context, localizations)) {
        null => null,
        final button => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.sm,
            AppSpacing.medium,
            AppSpacing.medium,
          ),
          child: ControlDock(children: [button]),
        ),
      },
      body: LayoutBuilder(
        builder: (context, constraints) {
          final display = _display(context, localizations);
          final status = _status(context, localizations);
          final controls = _controls(context, localizations);

          if (!TunathicBreakpoints.allowsSidePanel(constraints)) {
            return ListView(
              key: const Key('guitarTunerScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              children: [
                display,
                const SizedBox(height: AppSpacing.md),
                status,
                const SizedBox(height: AppSpacing.large),
                ...controls,
              ],
            );
          }

          // Wide and tall enough: the readout keeps the left half at a size
          // worth reading across a room, the setup moves beside it.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ListView(
                  key: const Key('guitarTunerScroll'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.medium,
                    AppSpacing.medium,
                    AppSpacing.sm,
                    AppSpacing.medium,
                  ),
                  children: [
                    display,
                    const SizedBox(height: AppSpacing.md),
                    status,
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ListView(
                  key: const Key('guitarTunerControlScroll'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.medium,
                    AppSpacing.medium,
                    AppSpacing.medium,
                  ),
                  children: controls,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The dock never gates the tuner behind a start button.
  ///
  /// Listening begins on arrival and picks itself back up after an ordinary
  /// interruption, so the only two things worth a button are ending it
  /// deliberately and recovering a microphone the system refused. Returns null
  /// when neither applies, and the dock goes with it.
  Widget? _transportButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    if (state.isCapturing) {
      return SkeuoButton(
        key: const Key('stopGuitarTuner'),
        onPressed: state.audio.isBusy && !state.audio.canStop ? null : onStop,
        icon: Icons.stop_circle_outlined,
        expand: true,
        child: Text(
          localizations.stopTuning,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    final needsMicrophone =
        state.signalState == TunerSignalState.permissionDenied ||
        state.signalState == TunerSignalState.microphoneUnavailable;
    if (!needsMicrophone) return null;
    return SkeuoButton(
      key: const Key('retryGuitarTunerMicrophone'),
      onPressed: onResume,
      icon: Icons.mic_outlined,
      selected: true,
      expand: true,
      child: Text(
        localizations.retryMicrophone,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _display(BuildContext context, AppLocalizations localizations) {
    final pitch = state.pitch;
    // The note is named against the player's reference, so the big readout
    // agrees with the cents value beneath it at any A4.
    final note = state.note;
    final target = state.target;
    final cents = state.cents;
    final signal = _studioSignal(state.accuracy, state.direction);
    final referenceValue = state.reference.label;

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
      referenceText: localizations.referencePitchValue(referenceValue),
      referenceSemantics: localizations.referencePitchSemantics(referenceValue),
      targetText: state.isChromatic
          ? localizations.tunerChromaticTargetLabel
          : target == null
          ? localizations.tunerTargetPending
          : '${target.stringPosition} · ${target.displayName}',
      targetSemantics: state.isChromatic
          ? localizations.tunerChromaticTargetLabel
          : target == null
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

  /// The signal area: a one-line strip normally, a full panel when something
  /// needs the user's attention.
  Widget _status(BuildContext context, AppLocalizations localizations) {
    final message = _signalText(localizations, state.signalState);

    final problem = switch (state.signalState) {
      TunerSignalState.permissionDenied => (
        icon: Icons.mic_off_outlined,
        title: localizations.tunerMicrophonePermissionTitle,
        tone: StudioStateTone.problem,
      ),
      TunerSignalState.microphoneUnavailable => (
        icon: Icons.mic_external_off_outlined,
        title: localizations.tunerMicrophoneUnavailableTitle,
        tone: StudioStateTone.problem,
      ),
      TunerSignalState.processingError => (
        icon: Icons.error_outline,
        title: localizations.tunerProcessingErrorTitle,
        tone: StudioStateTone.problem,
      ),
      TunerSignalState.noSignal => (
        icon: Icons.signal_cellular_off_outlined,
        title: localizations.tunerNoSignalTitle,
        tone: StudioStateTone.action,
      ),
      _ => null,
    };

    return Semantics(
      key: const Key('tunerSignalState'),
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: AnimatedSignalTransition(
          child: problem == null
              ? _SignalStrip(
                  key: ValueKey('signalStrip:${state.signalState}'),
                  state: state.signalState,
                  accuracy: state.accuracy,
                  text: message,
                )
              : StudioStatePanel(
                  key: ValueKey('signalPanel:${state.signalState}'),
                  icon: problem.icon,
                  title: problem.title,
                  description: message,
                  tone: problem.tone,
                ),
        ),
      ),
    );
  }

  List<Widget> _controls(BuildContext context, AppLocalizations localizations) {
    final target = state.target;
    return [
      RackPanel(
        label: localizations.tunerModeLabel,
        labelIcon: Icons.tune,
        child: _ModeSelector(
          selected: state.settings.mode,
          enabled: state.settingsLoaded,
          labelFor: localizations.tunerModeName,
          semanticsLabel: localizations.tunerModeSemantics(
            localizations.tunerModeName(state.settings.mode),
          ),
          onChanged: onModeChanged,
        ),
      ),
      const SizedBox(height: AppSpacing.medium),
      RackPanel(
        label: localizations.referencePitchLabel,
        labelIcon: Icons.tune_outlined,
        child: TuningReferenceSelector(
          reference: state.reference,
          enabled: state.settingsLoaded,
          onChanged: onReferenceChanged,
        ),
      ),
      const SizedBox(height: AppSpacing.medium),
      // A preset and a string only mean something when a preset is in play.
      if (state.isChromatic) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            localizations.tunerChromaticTargetHint,
            style: TunathicTextStyles.metadata(context),
          ),
        ),
      ] else ...[
        RackPanel(
          label: localizations.tuningPresetLabel,
          labelIcon: Icons.piano_outlined,
          child: SkeuoInsetPanel(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: DropdownButtonFormField<TuningPresetId>(
              key: ValueKey('tunerPreset-${state.settings.presetId.id}'),
              initialValue: state.settings.presetId,
              isExpanded: true,
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              items: [
                for (final preset in TuningPresetId.values)
                  DropdownMenuItem(
                    value: preset,
                    child: Text(
                      localizations.tuningPresetName(preset),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: state.settingsLoaded
                  ? (value) {
                      if (value != null) onPresetChanged(value);
                    }
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        StudioSectionLabel(
          label: localizations.targetStringLabel,
          icon: Icons.linear_scale,
        ),
        TuningPresetStrip(
          strings: state.preset.strings,
          selectedPosition: target?.stringPosition,
          enabled:
              state.settings.mode == TunerMode.manual && state.settingsLoaded,
          onSelected: onStringSelected,
          semanticsFor: (string) => localizations.targetStringSemantics(
            string.stringPosition,
            string.displayName,
          ),
        ),
        if (state.settings.mode == TunerMode.automatic) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              localizations.tunerAutomaticTargetHint,
              style: TunathicTextStyles.metadata(context),
            ),
          ),
        ],
      ],
    ];
  }

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
    required this.labelFor,
    required this.semanticsLabel,
    required this.onChanged,
  });

  final TunerMode selected;
  final bool enabled;
  final String Function(TunerMode) labelFor;
  final String semanticsLabel;
  final ValueChanged<TunerMode> onChanged;

  static IconData _iconFor(TunerMode mode) => switch (mode) {
    TunerMode.automatic => Icons.auto_awesome_outlined,
    TunerMode.manual => Icons.touch_app_outlined,
    TunerMode.chromatic => Icons.piano_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Semantics(
      label: semanticsLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A segmented control cannot shrink its labels, so past this point
          // the modes become full-width buttons instead of clipping. Three
          // modes need more room than two did before it is worth switching.
          if (constraints.maxWidth < 480 || textScale > 1.2) {
            return Column(
              key: const Key('tunerModeSelector'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final mode in TunerMode.values) ...[
                  if (mode != TunerMode.values.first)
                    const SizedBox(height: AppSpacing.small),
                  _ModeButton(
                    selected: selected == mode,
                    enabled: enabled,
                    icon: _iconFor(mode),
                    label: labelFor(mode),
                    onPressed: () => onChanged(mode),
                  ),
                ],
              ],
            );
          }
          return Row(
            key: const Key('tunerModeSelector'),
            children: [
              for (var index = 0; index < TunerMode.values.length; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ModeButton(
                    selected: selected == TunerMode.values[index],
                    enabled: enabled,
                    icon: _iconFor(TunerMode.values[index]),
                    label: labelFor(TunerMode.values[index]),
                    onPressed: () => onChanged(TunerMode.values[index]),
                  ),
                ),
              ],
            ],
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
    return SkeuoButton(
      selected: selected,
      compact: true,
      expand: true,
      icon: icon,
      onPressed: enabled ? onPressed : null,
      child: Text(label, maxLines: 2, textAlign: TextAlign.center),
    );
  }
}

/// The quiet form of the signal readout: one icon and one line.
final class _SignalStrip extends StatelessWidget {
  const _SignalStrip({
    required this.state,
    required this.text,
    required this.accuracy,
    super.key,
  });

  final TunerSignalState state;
  final String text;
  final TunerAccuracy? accuracy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studio = StudioTheme.of(context);
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
    final accent = switch (state) {
      TunerSignalState.stablePitch when accuracy == TunerAccuracy.inTune =>
        studio.inTune,
      TunerSignalState.stopped => studio.idle,
      _ => colors.primary,
    };

    return SkeuoSurface(
      accent: accent.withValues(alpha: 0.42),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 30,
            child: SkeuoInsetPanel(
              radius: const Radius.circular(15),
              surfaceColor: accent.withValues(alpha: 0.10),
              child: Center(child: Icon(icon, color: accent, size: 18)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
