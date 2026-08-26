import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/application/tuner_preferences.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_controller.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_preferences.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';
import 'package:tunathic/features/tuner_audio/audio/tuner_audio_input.dart';
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

  test('chromatic mode names any note without a preset target', () async {
    await controller.setMode(TunerMode.chromatic);
    pitchExecutor.result = _estimate(329.63);
    await controller.start();
    await emitAnalysisFrame();

    final state = container.read(guitarTunerProvider);
    expect(state.signalState, TunerSignalState.stablePitch);
    expect(state.target, isNull, reason: 'chromatic aims at no string');
    expect(state.note?.displayName, 'E4');
    expect(state.cents, closeTo(0, 2));
    expect(preferences.values[TunerPreferences.modeKey], 'chromatic');
  });

  test('chromatic mode follows a note no tuning preset contains', () async {
    await controller.setMode(TunerMode.chromatic);
    // Well above the top string of every preset, so automatic mode would
    // have discarded it.
    pitchExecutor.result = _estimate(1046.5);
    await controller.start();
    await emitAnalysisFrame();

    final state = container.read(guitarTunerProvider);
    expect(state.note?.displayName, 'C6');
    expect(state.pitch?.frequencyHz, closeTo(1046.5, 0.5));
  });

  test('the reference renames the note and moves the string target', () async {
    await controller.setMode(TunerMode.chromatic);
    pitchExecutor.result = _estimate(440);
    await controller.start();
    await emitAnalysisFrame();
    expect(container.read(guitarTunerProvider).cents, closeTo(0, 0.01));

    await container
        .read(tuningReferenceProvider.notifier)
        .setReference(TuningReference.resolve(432));
    await _flushMicrotasks();

    var state = container.read(guitarTunerProvider);
    expect(state.reference.a4FrequencyHz, 432);
    expect(state.note?.displayName, 'A4');
    expect(state.cents, closeTo(31.8, 0.2));

    // The same shift moves the string targets the other modes aim at.
    await controller.setMode(TunerMode.manual);
    await controller.selectManualString(5);
    state = container.read(guitarTunerProvider);
    expect(state.target?.displayName, 'A2');
    expect(
      state.target!.frequencyHzFor(state.reference),
      closeTo(108, 0.01),
      reason: 'A2 at 432 Hz is 108 Hz',
    );
  });

  test('changing the reference does not open a second capture', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame();
    expect(audioInput.startCount, 1);

    final reference = container.read(tuningReferenceProvider.notifier);
    await reference.setReference(TuningReference.resolve(438));
    await reference.setReference(TuningReference.resolve(444));
    await _flushMicrotasks();

    expect(audioInput.startCount, 1);
    expect(audioInput.stopCount, 0);
    expect(container.read(guitarTunerProvider).reference.a4FrequencyHz, 444);
  });

  test('the reference is read back from storage on the next launch', () async {
    await container
        .read(tuningReferenceProvider.notifier)
        .setReference(TuningReference.resolve(437));

    final reloaded = await TuningReferencePreferences(preferences).load();

    expect(reloaded.a4FrequencyHz, 437);
  });

  test('ensureListening starts exactly one session, however often it is '
      'called', () async {
    pitchExecutor.result = _estimate(110);

    await controller.ensureListening();
    await controller.ensureListening();
    await controller.ensureListening();
    await emitAnalysisFrame();

    expect(audioInput.startCount, 1);
    expect(container.read(guitarTunerProvider).isCapturing, isTrue);
  });

  test('returning to the foreground resumes an interrupted session', () async {
    pitchExecutor.result = _estimate(110);
    await controller.ensureListening();
    await emitAnalysisFrame();

    await controller.handleLifecycle(isForeground: false);
    expect(container.read(guitarTunerProvider).isCapturing, isFalse);

    await controller.handleLifecycle(isForeground: true);

    expect(audioInput.startCount, 2);
    expect(container.read(guitarTunerProvider).isCapturing, isTrue);
  });

  test('returning to the foreground does not undo a deliberate stop', () async {
    pitchExecutor.result = _estimate(110);
    await controller.ensureListening();
    await emitAnalysisFrame();
    await controller.stop();

    await controller.handleLifecycle(isForeground: true);

    expect(audioInput.startCount, 1);
    expect(container.read(guitarTunerProvider).isCapturing, isFalse);
  });

  test('a refused microphone is not asked again on every visit', () async {
    audioInput.permission = MicrophonePermissionResult.denied;

    await controller.ensureListening();
    await _flushMicrotasks();
    expect(
      container.read(guitarTunerProvider).signalState,
      TunerSignalState.permissionDenied,
    );
    final requestsAfterFirstVisit = audioInput.requestPermissionCount;

    // Coming back from the background must not re-prompt on its own.
    await controller.handleLifecycle(isForeground: true);
    await _flushMicrotasks();
    expect(audioInput.requestPermissionCount, requestsAfterFirstVisit);

    // Asking for it explicitly still does.
    await controller.start();
    await _flushMicrotasks();
    expect(audioInput.requestPermissionCount, requestsAfterFirstVisit + 1);
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

  test('repeated no-signal snapshots do not notify tuner UI', () async {
    pitchExecutor.result = _estimate(110);
    await controller.start();
    await emitAnalysisFrame();
    pitchExecutor.result = PitchEstimate.noPitch(NoPitchReason.lowConfidence);
    for (var index = 0; index < 9; index++) {
      await emitAnalysisFrame(sampleCount: 2048);
    }
    expect(
      container.read(guitarTunerProvider).signalState,
      TunerSignalState.noSignal,
    );

    var notifications = 0;
    final uiSubscription = container.listen<GuitarTunerState>(
      guitarTunerProvider,
      (_, _) => notifications++,
    );
    addTearDown(uiSubscription.close);

    for (var index = 0; index < 5; index++) {
      await emitAnalysisFrame(sampleCount: 2048);
    }

    expect(notifications, 0);
  });

  test('sub-threshold pitch movement does not notify tuner UI', () async {
    await controller.setMode(TunerMode.chromatic);
    pitchExecutor.result = _estimate(440);
    await controller.start();
    await emitAnalysisFrame();

    var notifications = 0;
    final uiSubscription = container.listen<GuitarTunerState>(
      guitarTunerProvider,
      (_, _) => notifications++,
    );
    addTearDown(uiSubscription.close);

    pitchExecutor.result = _estimate(440.02);
    await emitAnalysisFrame(sampleCount: 2048);

    expect(notifications, 0);
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
