import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/tuner_preferences.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_controller.dart';
import 'package:tunathic/features/tuner/domain/chromatic_tuner_engine.dart';
import 'package:tunathic/features/tuner/domain/tuner_target_selector.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';
import 'package:tunathic/features/tuner_realtime/application/realtime_pitch_pipeline.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';

enum TunerSignalState {
  stopped,
  requestingPermission,
  listening,
  waitingForSignal,
  unstableSignal,
  stablePitch,
  noSignal,
  permissionDenied,
  microphoneUnavailable,
  processingError,
}

final class GuitarTunerState {
  const GuitarTunerState({
    required this.audio,
    required this.settings,
    required this.preset,
    required this.signalState,
    this.reference = TuningReference.standard,
    this.target,
    this.pitch,
    this.note,
    this.cents,
    this.accuracy,
    this.direction,
    this.settingsLoaded = false,
  });

  factory GuitarTunerState.initial(
    TunerAudioState audio,
    TuningReference reference,
  ) => GuitarTunerState(
    audio: audio,
    settings: const TunerPreferencesState(),
    preset: TuningPresets.standard,
    signalState: TunerSignalState.stopped,
    reference: reference,
  );

  final TunerAudioState audio;
  final TunerPreferencesState settings;
  final TuningPreset preset;
  final TunerSignalState signalState;

  /// The concert pitch every note name and cents value here was measured
  /// against.
  final TuningReference reference;

  /// The string being tuned. Always null in chromatic mode, which has no
  /// preset to aim at.
  final TuningStringTarget? target;

  final StabilizedPitch? pitch;

  /// What [pitch] is called at [reference]. Named for every mode, so the big
  /// readout never disagrees with the reference the player chose.
  final ChromaticPitch? note;

  final double? cents;
  final TunerAccuracy? accuracy;
  final TunerDirection? direction;
  final bool settingsLoaded;

  bool get isCapturing =>
      audio.status == TunerCaptureStatus.capturing ||
      audio.status == TunerCaptureStatus.starting ||
      audio.status == TunerCaptureStatus.requestingPermission;

  bool get isChromatic => settings.mode == TunerMode.chromatic;
}

final tunerUiConfigurationProvider = Provider<TunerUiConfiguration>(
  (ref) => const TunerUiConfiguration(),
);

final guitarTunerProvider =
    NotifierProvider.autoDispose<GuitarTunerController, GuitarTunerState>(
      GuitarTunerController.new,
    );

final class GuitarTunerController extends Notifier<GuitarTunerState> {
  late final TunerPreferences _preferences;
  late final TunerTargetSelector _targetSelector;
  late final TunerUiConfiguration _configuration;
  late final AppHaptics _haptics;
  late final AppLogger _logger;
  late TunerAudioState _audio;
  late TuningReference _reference;
  TunerPreferencesState _settings = const TunerPreferencesState();
  bool _settingsLoaded = false;
  bool _disposed = false;

  /// Whether the screen wants the microphone open. Set when the screen asks
  /// to listen, cleared when the player stops on purpose, so returning from
  /// the background only resumes a session the player did not end.
  bool _autoListenRequested = false;
  int _inTuneCount = 0;
  bool _inTuneHapticArmed = true;
  StabilizedPitch? _displayPitch;
  int _displayPitchMissCount = 0;
  Object? _lastDisplayEstimate;
  bool _displayPitchFresh = false;

  @override
  GuitarTunerState build() {
    _configuration = ref.read(tunerUiConfigurationProvider);
    _targetSelector = TunerTargetSelector(configuration: _configuration);
    _preferences = TunerPreferences(ref.read(preferencesStoreProvider));
    _haptics = ref.read(appHapticsProvider);
    _logger = ref.read(appLoggerProvider);
    _audio = ref.read(tunerAudioProvider);
    _reference = ref.read(tuningReferenceProvider);
    ref.listen<TunerAudioState>(tunerAudioProvider, (previous, next) {
      _onAudioState(previous, next);
    });
    ref.listen<TuningReference>(tuningReferenceProvider, (previous, next) {
      _onReferenceChanged(next);
    });
    ref.onDispose(() => _disposed = true);
    unawaited(_loadPreferences());
    return GuitarTunerState.initial(_audio, _reference);
  }

  /// Opens the microphone. Safe to call more than once: the audio controller
  /// ignores a start while a session is already opening or running, so a
  /// rebuild cannot produce a second listener.
  Future<void> start() async {
    _autoListenRequested = true;
    _targetSelector.reset();
    _resetDisplayPitch();
    _resetInTuneHaptic();
    _publish();
    await ref.read(tunerAudioProvider.notifier).start();
  }

  /// What the screen calls when it appears. Starts listening straight away,
  /// except after a refusal: re-asking on every visit would be nagging, so a
  /// denied microphone waits for the player to ask again with [start].
  Future<void> ensureListening() async {
    _autoListenRequested = true;
    if (_audio.permissionStatus == TunerPermissionStatus.denied) return;
    await start();
  }

  Future<void> stop() async {
    _autoListenRequested = false;
    await ref.read(tunerAudioProvider.notifier).stop();
  }

  Future<void> handleLifecycle({required bool isForeground}) async {
    if (!isForeground) {
      await ref
          .read(tunerAudioProvider.notifier)
          .handleLifecycle(isForeground: false);
      return;
    }
    if (!_autoListenRequested) return;
    await ensureListening();
  }

  Future<void> setReference(TuningReference reference) =>
      ref.read(tuningReferenceProvider.notifier).setReference(reference);

  Future<void> setMode(TunerMode mode) async {
    if (_settings.mode == mode) return;
    _settings = _settings.copyWith(mode: mode);
    _targetSelector.reset();
    _resetDisplayPitch();
    _resetInTuneHaptic();
    _processPitch(_audio);
    _publish();
    await _savePreferences();
  }

  Future<void> setPreset(TuningPresetId id) async {
    if (_settings.presetId == id) return;
    _settings = _settings.copyWith(presetId: id);
    _targetSelector.reset();
    _resetDisplayPitch();
    _resetInTuneHaptic();
    _processPitch(_audio);
    _publish();
    await _savePreferences();
  }

  void _onReferenceChanged(TuningReference reference) {
    if (_disposed || reference == _reference) return;
    _reference = reference;
    // Targets move with the reference, so the evidence behind the current one
    // no longer applies. Nothing about the microphone changes here: a new
    // reference must never open a second capture session.
    _targetSelector.reset();
    _resetInTuneHaptic();
    _processPitch(_audio);
    _publish();
  }

  Future<void> selectManualString(int position) async {
    if (position < 1 || position > 6) {
      throw ArgumentError.value(position, 'position');
    }
    if (_settings.manualStringPosition == position) return;
    _settings = _settings.copyWith(manualStringPosition: position);
    _resetDisplayPitch();
    _resetInTuneHaptic();
    _publish();
    await _savePreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      _settings = await _preferences.load();
    } on Object catch (error, stackTrace) {
      _logger.error('Could not load tuner preferences', error, stackTrace);
      _settings = const TunerPreferencesState();
    }
    if (_disposed) return;
    _settingsLoaded = true;
    _targetSelector.reset();
    _processPitch(_audio);
    _publish();
  }

  Future<void> _savePreferences() async {
    try {
      await _preferences.save(_settings);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save tuner preferences', error, stackTrace);
    }
  }

  void _onAudioState(TunerAudioState? previous, TunerAudioState next) {
    if (_disposed) return;
    final started =
        next.status == TunerCaptureStatus.requestingPermission &&
        previous?.status != TunerCaptureStatus.requestingPermission;
    if (started) {
      _targetSelector.reset();
      _resetDisplayPitch();
      _resetInTuneHaptic();
    }
    _audio = next;
    _processPitch(next);
    _publish();
  }

  void _processPitch(TunerAudioState audio) {
    // Only automatic mode picks its own target: manual is locked to a string
    // and chromatic aims at nothing.
    if (_settings.mode != TunerMode.automatic) return;
    final status = audio.analysisStatus;
    final pitch = _retainedPitch(audio);
    if (pitch != null) {
      _targetSelector.select(
        pitch,
        TuningPresets.byId(_settings.presetId),
        reference: _reference,
      );
    } else if (status == RealtimePitchStatus.noSignal ||
        status == RealtimePitchStatus.stopped ||
        status == RealtimePitchStatus.permissionDenied ||
        status == RealtimePitchStatus.captureError ||
        status == RealtimePitchStatus.analysisError) {
      _targetSelector.reset();
    } else if (status == RealtimePitchStatus.unstableSignal) {
      _targetSelector.recordNoPitch();
    }
  }

  void _publish() {
    if (_disposed) return;
    final preset = TuningPresets.byId(_settings.presetId);
    final target = switch (_settings.mode) {
      TunerMode.manual => preset.stringAt(_settings.manualStringPosition),
      TunerMode.automatic => _targetSelector.current,
      TunerMode.chromatic => null,
    };
    final pitch = _updateDisplayPitch(_audio, target);
    final note = ChromaticTunerEngine.resolve(
      pitch?.frequencyHz,
      reference: _reference,
    );
    // Chromatic measures against the note it just named; the other modes
    // measure against the string being tuned.
    final cents = _settings.mode == TunerMode.chromatic
        ? note?.cents
        : TunerPitchMath.centsBetween(
            pitch?.frequencyHz,
            target?.frequencyHzFor(_reference),
          );
    final accuracy = cents == null ? null : _configuration.accuracyFor(cents);
    final direction = cents == null ? null : _configuration.directionFor(cents);
    final previous = stateOrNull;
    final targetChanged = _settings.mode == TunerMode.chromatic
        ? previous?.note?.midiNote != note?.midiNote
        : previous?.target?.stringPosition != target?.stringPosition ||
              previous?.preset.id != preset.id;
    if (targetChanged) _resetInTuneHaptic();

    state = GuitarTunerState(
      audio: _audio,
      settings: _settings,
      preset: preset,
      signalState: _signalState(_audio),
      reference: _reference,
      target: target,
      pitch: pitch,
      note: note,
      cents: cents,
      accuracy: accuracy,
      direction: direction,
      settingsLoaded: _settingsLoaded,
    );
    _updateInTuneHaptic(state, targetChanged: targetChanged);
  }

  void _updateInTuneHaptic(
    GuitarTunerState next, {
    required bool targetChanged,
  }) {
    final hasSomethingToTuneTo = next.isChromatic
        ? next.note != null
        : next.target != null;
    final isStableInTune =
        !targetChanged &&
        next.signalState == TunerSignalState.stablePitch &&
        _displayPitchFresh &&
        next.accuracy == TunerAccuracy.inTune &&
        hasSomethingToTuneTo;
    if (!isStableInTune) {
      _inTuneCount = 0;
      if (!targetChanged) _inTuneHapticArmed = true;
      return;
    }
    _inTuneCount++;
    if (_inTuneHapticArmed &&
        _inTuneCount >= _configuration.inTuneHapticConfirmations) {
      _inTuneHapticArmed = false;
      unawaited(_haptics.lightImpact());
    }
  }

  void _resetInTuneHaptic() {
    _inTuneCount = 0;
    _inTuneHapticArmed = true;
  }

  void _resetDisplayPitch() {
    _displayPitch = null;
    _displayPitchMissCount = 0;
    _lastDisplayEstimate = null;
    _displayPitchFresh = false;
  }

  StabilizedPitch? _updateDisplayPitch(
    TunerAudioState audio,
    TuningStringTarget? target,
  ) {
    final candidate = _retainedPitch(audio);
    final candidateCents = TunerPitchMath.centsBetween(
      candidate?.frequencyHz,
      target?.frequencyHzFor(_reference),
    );
    // Only automatic mode rejects a reading for being far from its target:
    // that guard exists to stop it chasing an octave error. Manual and
    // chromatic show whatever was played.
    final candidateIsSupported =
        candidate != null &&
        (_settings.mode != TunerMode.automatic ||
            (candidateCents != null &&
                candidateCents.abs() <=
                    _configuration.maximumAutomaticTargetDistanceCents));
    final estimate = audio.realtime.rawEstimate;
    final isNewEstimate = !identical(estimate, _lastDisplayEstimate);
    _lastDisplayEstimate = estimate;
    _displayPitchFresh =
        candidateIsSupported &&
        audio.analysisStatus == RealtimePitchStatus.stablePitch;

    if (candidateIsSupported) {
      _displayPitch = candidate;
      _displayPitchMissCount = 0;
      return _displayPitch;
    }

    final shouldClearImmediately =
        audio.status == TunerCaptureStatus.idle ||
        audio.status == TunerCaptureStatus.error ||
        audio.analysisStatus == RealtimePitchStatus.noSignal ||
        audio.analysisStatus == RealtimePitchStatus.permissionDenied ||
        audio.analysisStatus == RealtimePitchStatus.captureError ||
        audio.analysisStatus == RealtimePitchStatus.analysisError ||
        audio.analysisStatus == RealtimePitchStatus.stopped;
    if (shouldClearImmediately) {
      _displayPitch = null;
      _displayPitchMissCount = 0;
      return null;
    }

    if (isNewEstimate) {
      _displayPitchMissCount++;
      if (_displayPitchMissCount >= _configuration.noPitchTargetClearCount) {
        _displayPitch = null;
      }
    }
    return _displayPitch;
  }

  TunerSignalState _signalState(TunerAudioState audio) {
    if (audio.permissionStatus == TunerPermissionStatus.denied) {
      return TunerSignalState.permissionDenied;
    }
    if (audio.failure == TunerCaptureFailure.analysisFailed) {
      return TunerSignalState.processingError;
    }
    if (audio.failure != null) return TunerSignalState.microphoneUnavailable;
    final signal = switch (audio.status) {
      TunerCaptureStatus.requestingPermission =>
        TunerSignalState.requestingPermission,
      TunerCaptureStatus.starting ||
      TunerCaptureStatus.stopping => TunerSignalState.listening,
      TunerCaptureStatus.idle => TunerSignalState.stopped,
      TunerCaptureStatus.error => TunerSignalState.microphoneUnavailable,
      TunerCaptureStatus.capturing => switch (audio.analysisStatus) {
        RealtimePitchStatus.waitingForSamples ||
        RealtimePitchStatus.analyzing => TunerSignalState.waitingForSignal,
        RealtimePitchStatus.stablePitch => TunerSignalState.stablePitch,
        RealtimePitchStatus.unstableSignal
            when audio.realtime.stabilizedPitch != null =>
          TunerSignalState.stablePitch,
        RealtimePitchStatus.unstableSignal => TunerSignalState.unstableSignal,
        RealtimePitchStatus.noSignal => TunerSignalState.noSignal,
        RealtimePitchStatus.permissionDenied =>
          TunerSignalState.permissionDenied,
        RealtimePitchStatus.analysisError => TunerSignalState.processingError,
        RealtimePitchStatus.captureError =>
          TunerSignalState.microphoneUnavailable,
        RealtimePitchStatus.stopped => TunerSignalState.listening,
      },
    };
    if (audio.status == TunerCaptureStatus.capturing &&
        _displayPitch != null &&
        (signal == TunerSignalState.stablePitch ||
            signal == TunerSignalState.unstableSignal)) {
      return TunerSignalState.stablePitch;
    }
    if (signal == TunerSignalState.stablePitch && _displayPitch == null) {
      return TunerSignalState.unstableSignal;
    }
    return signal;
  }

  StabilizedPitch? _retainedPitch(TunerAudioState audio) =>
      switch (audio.analysisStatus) {
        RealtimePitchStatus.stablePitch ||
        RealtimePitchStatus.unstableSignal => audio.realtime.stabilizedPitch,
        _ => null,
      };
}
