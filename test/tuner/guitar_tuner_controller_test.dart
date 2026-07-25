import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/application/tuner_preferences.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';
import 'package:tunathic/features/tuner_pitch/domain/musical_note.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';

import '../support/fakes.dart';
import '../support/tuner_audio_fakes.dart';

void main() {
  late FakeTunerAudioInput audioInput;
  late FakePitchDetectionExecutor pitchExecutor;
  late FakeHapticFeedbackOutput haptics;
  late MemoryPreferencesStore preferences;
  late ProviderContainer container;
  late ProviderSubscription<GuitarTunerState> subscription;
  late GuitarTunerController controller;
  var now = Duration.zero;

  setUp(() async {
    audioInput = FakeTunerAudioInput();
    pitchExecutor = FakePitchDetectionExecutor();
    haptics = FakeHapticFeedbackOutput();
    preferences = MemoryPreferencesStore();
    now = Duration.zero;
    container = ProviderContainer(
      overrides: [
        tunerAudioInputFactoryProvider.overrideWithValue(() => audioInput),
        stopMetronomeBeforeCaptureProvider.overrideWithValue(() async {}),
        pitchDetectionExecutorProvider.overrideWithValue(pitchExecutor),
        tunerRealtimeClockProvider.overrideWithValue(() => now),
        preferencesStoreProvider.overrideWithValue(preferences),
        hapticFeedbackOutputProvider.overrideWithValue(haptics),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
      ],
    );
    subscription = container.listen(
      guitarTunerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    controller = container.read(guitarTunerProvider.notifier);
    await _flushMicrotasks();
  });

  tearDown(() async {
    subscription.close();
    container.dispose();
    await _flushMicrotasks();
  });

  Future<void> emitAnalysisFrame({int sampleCount = 4096}) async {
    now += const Duration(milliseconds: 100);
    audioInput.emitSamples(
      List<double>.filled(sampleCount, 0.2),
      arrivalTime: now,
    );
    await _flushMicrotasks();
  }

  test(
    'loads, changes, and persists mode, preset, and manual string',
    () async {
      await controller.setPreset(TuningPresetId.dadgad);
      await controller.setMode(TunerMode.manual);
      await controller.selectManualString(2);

      final state = container.read(guitarTunerProvider);
      expect(state.settings.presetId, TuningPresetId.dadgad);
      expect(state.settings.mode, TunerMode.manual);
      expect(state.target?.displayName, 'A3');
      expect(preferences.values[TunerPreferences.presetKey], 'dadgad');
      expect(preferences.values[TunerPreferences.modeKey], 'manual');
      expect(preferences.values[TunerPreferences.manualStringKey], '2');
    },
  );

  test('automatic mode selects from stabilized pitch', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame();

    final state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.stablePitch);
    expect(state.target?.displayName, 'A2');
    expect(state.cents, closeTo(0, 0.01));
  });

  test('retains the visible pitch across a short unreliable gap', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame();

    pitchExecutor.result = PitchEstimate.noPitch(NoPitchReason.lowConfidence);
    await emitAnalysisFrame(sampleCount: 2048);

    var state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.stablePitch);
    expect(state.pitch?.frequencyHz, closeTo(110, 0.01));
    expect(state.target?.displayName, 'A2');

    for (var index = 0; index < 7; index++) {
      await emitAnalysisFrame(sampleCount: 2048);
    }
    state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.noSignal);
    expect(state.pitch, isNull);
    expect(state.target, isNull);
  });

  test('does not display an octave below every tuning target', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame();

    pitchExecutor.result = _estimate(55);
    await emitAnalysisFrame(sampleCount: 2048);
    pitchExecutor.result = _estimate(55);
    await emitAnalysisFrame(sampleCount: 2048);

    var state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.stablePitch);
    expect(state.pitch?.frequencyHz, closeTo(110, 0.01));
    expect(state.target?.displayName, 'A2');
    expect(state.cents, closeTo(0, 0.01));

    for (var index = 0; index < 8; index++) {
      pitchExecutor.result = _estimate(55);
      await emitAnalysisFrame(sampleCount: 2048);
    }
    state = container.read(guitarTunerProvider);
    expect(
      state.signalState,
      TunerSignalState.unstableSignal,
      reason:
          'pitch=${state.pitch?.frequencyHz}, target=${state.target?.displayName}, '
          'raw=${state.audio.realtime.rawEstimate?.frequencyHz}, '
          'stable=${state.audio.realtime.stabilizedPitch?.frequencyHz}, '
          'frames=${state.audio.realtime.diagnostics.framesAnalyzed}',
    );
    expect(state.pitch, isNull);
    expect(state.target?.displayName, 'A2');
  });

  test('manual mode keeps the selected string locked', () async {
    await controller.setMode(TunerMode.manual);
    await controller.selectManualString(6);
    pitchExecutor.result = _estimate(146.832384);
    await controller.start();
    await emitAnalysisFrame();

    final state = container.read(guitarTunerProvider);
    expect(state.target?.displayName, 'E2');
    expect(state.cents, greaterThan(900));
  });

  test(
    'preset change recomputes target without old pending evidence',
    () async {
      pitchExecutor.result = _estimate(82.406889);
      await controller.start();
      await emitAnalysisFrame();
      expect(container.read(guitarTunerProvider).target?.displayName, 'E2');

      await controller.setPreset(TuningPresetId.dropD);

      expect(container.read(guitarTunerProvider).target?.displayName, 'D2');
    },
  );

  test('stable in-tune feedback triggers once and does not repeat', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame(sampleCount: 4096);
    for (var index = 0; index < 5; index++) {
      await emitAnalysisFrame(sampleCount: 2048);
    }

    expect(haptics.lightImpactCount, 1);

    for (var index = 0; index < 3; index++) {
      await emitAnalysisFrame(sampleCount: 2048);
    }
    expect(haptics.lightImpactCount, 1);
  });

  test('stop and lifecycle interruption clear automatic target', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame();
    expect(container.read(guitarTunerProvider).target, isNotNull);

    await controller.handleLifecycle(isForeground: false);

    final state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.stopped);
    expect(state.target, isNull);
    expect(audioInput.stopCount, 1);
  });

  test('late detector completion cannot restore a stopped session', () async {
    final gate = Completer<void>();
    pitchExecutor
      ..result = _estimate(110)
      ..gate = gate;
    await controller.start();
    audioInput.emitSamples(List<double>.filled(4096, 0.2));
    await _flushMicrotasks();

    await controller.stop();
    gate.complete();
    await _flushMicrotasks();

    final state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.stopped);
    expect(state.pitch, isNull);
    expect(state.target, isNull);
  });
}

Future<void> _flushMicrotasks() async {
  for (var index = 0; index < 10; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

PitchEstimate _estimate(double frequency) {
  final note = MusicalNoteConverter.fromFrequency(frequency)!;
  return PitchEstimate.detected(
    frequencyHz: frequency,
    confidence: 0.98,
    midiNote: note.midiNote,
    noteName: note.noteName,
    octave: note.octave,
    centsDeviation: note.centsDeviation,
    periodSamples: 48000 / frequency,
  );
}
