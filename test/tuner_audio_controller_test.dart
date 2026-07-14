import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/features/tuner_audio/audio/tuner_audio_input.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';
import 'package:tunathic/features/tuner_audio/domain/pcm16_converter.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';

import 'support/fakes.dart';
import 'support/tuner_audio_fakes.dart';

void main() {
  late FakeTunerAudioInput audioInput;
  late RecordingLogger logger;
  late ProviderContainer container;
  late ProviderSubscription<TunerAudioState> subscription;
  late TunerAudioController controller;
  var metronomeStopCount = 0;

  setUp(() {
    audioInput = FakeTunerAudioInput();
    logger = RecordingLogger();
    metronomeStopCount = 0;
    container = ProviderContainer(
      overrides: [
        tunerAudioInputFactoryProvider.overrideWithValue(() => audioInput),
        stopMetronomeBeforeCaptureProvider.overrideWithValue(() async {
          metronomeStopCount++;
        }),
        appLoggerProvider.overrideWithValue(logger),
      ],
    );
    subscription = container.listen(
      tunerAudioProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    controller = container.read(tunerAudioProvider.notifier);
  });

  tearDown(() async {
    subscription.close();
    container.dispose();
    await _flushMicrotasks();
  });

  test(
    'permission granted starts capture and stops metronome output',
    () async {
      await controller.start();

      final state = container.read(tunerAudioProvider);
      expect(state.permissionStatus, TunerPermissionStatus.granted);
      expect(state.status, TunerCaptureStatus.capturing);
      expect(audioInput.requestPermissionCount, 1);
      expect(audioInput.startCount, 1);
      expect(audioInput.lastConfiguration?.sampleRate, 48000);
      expect(audioInput.lastConfiguration?.channelCount, 1);
      expect(metronomeStopCount, 1);
    },
  );

  test('permission denied stays stopped and offers a retry state', () async {
    audioInput.permission = MicrophonePermissionResult.denied;

    await controller.start();

    final state = container.read(tunerAudioProvider);
    expect(state.status, TunerCaptureStatus.idle);
    expect(state.permissionStatus, TunerPermissionStatus.denied);
    expect(state.failure, TunerCaptureFailure.permissionDenied);
    expect(audioInput.startCount, 0);
    expect(metronomeStopCount, 0);
  });

  test('start failure is friendly and retryable', () async {
    audioInput.startError = StateError('platform start failed');

    await controller.start();

    expect(
      container.read(tunerAudioProvider).failure,
      TunerCaptureFailure.startFailed,
    );
    expect(container.read(tunerAudioProvider).status, TunerCaptureStatus.error);
    expect(logger.errorMessages, isNotEmpty);

    audioInput.startError = null;
    await controller.start();
    expect(
      container.read(tunerAudioProvider).status,
      TunerCaptureStatus.capturing,
    );
  });

  test('unsupported PCM configuration has a distinct friendly state', () async {
    audioInput.startError = const UnsupportedAudioConfigurationException();

    await controller.start();

    expect(
      container.read(tunerAudioProvider).failure,
      TunerCaptureFailure.unsupportedConfiguration,
    );
    expect(container.read(tunerAudioProvider).status, TunerCaptureStatus.error);
    expect(logger.errorMessages, isNotEmpty);
  });

  test('prevents duplicate capture starts', () async {
    final gate = Completer<void>();
    audioInput.permissionGate = gate;

    final firstStart = controller.start();
    final duplicateStart = controller.start();
    gate.complete();
    await Future.wait([firstStart, duplicateStart]);

    expect(audioInput.requestPermissionCount, 1);
    expect(audioInput.startCount, 1);
  });

  test('stops capture and preserves final counters', () async {
    await controller.start();
    audioInput.emitSamples([0.25, -0.25], arrivalTime: Duration.zero);
    await _flushMicrotasks();

    await controller.stop();

    final state = container.read(tunerAudioProvider);
    expect(state.status, TunerCaptureStatus.idle);
    expect(state.statistics.frameCount, 1);
    expect(state.statistics.samplesReceived, 2);
    expect(audioInput.stopCount, 1);
  });

  test('rapid stop invalidates a pending permission request', () async {
    final gate = Completer<void>();
    audioInput.permissionGate = gate;
    final startFuture = controller.start();

    await controller.stop();
    gate.complete();
    await startFuture;

    expect(container.read(tunerAudioProvider).status, TunerCaptureStatus.idle);
    expect(audioInput.startCount, 0);
  });

  test('stop failure is reported and remains retryable', () async {
    await controller.start();
    audioInput.stopError = StateError('platform stop failed');

    await controller.stop();

    final state = container.read(tunerAudioProvider);
    expect(state.status, TunerCaptureStatus.error);
    expect(state.failure, TunerCaptureFailure.stopFailed);
    expect(logger.errorMessages, isNotEmpty);
  });

  test('lifecycle stop does not automatically restart on resume', () async {
    await controller.start();
    await controller.handleLifecycle(isForeground: false);

    expect(container.read(tunerAudioProvider).status, TunerCaptureStatus.idle);
    expect(audioInput.stopCount, 1);

    await controller.handleLifecycle(isForeground: true);
    expect(container.read(tunerAudioProvider).status, TunerCaptureStatus.idle);
    expect(audioInput.startCount, 1);
  });

  test('stream failure stops capture without exposing the exception', () async {
    await controller.start();
    audioInput.emitFrameError(StateError('native stream failed'));
    await _flushMicrotasks();

    final state = container.read(tunerAudioProvider);
    expect(state.status, TunerCaptureStatus.error);
    expect(state.failure, TunerCaptureFailure.streamFailed);
    expect(audioInput.stopCount, 1);
    expect(logger.errorMessages, isNotEmpty);
  });

  test('malformed frames are counted and later frames continue', () async {
    await controller.start();
    audioInput.emitFrameError(const MalformedPcm16FrameException(3));
    audioInput.emitSamples([0.5], arrivalTime: Duration.zero);
    await _flushMicrotasks();

    final statistics = container.read(tunerAudioProvider).statistics;
    expect(statistics.malformedFrameCount, 1);
    expect(statistics.frameCount, 1);
    expect(
      container.read(tunerAudioProvider).status,
      TunerCaptureStatus.capturing,
    );
  });

  test(
    'accumulates every frame but throttles published UI statistics',
    () async {
      await controller.start();
      audioInput.emitSamples([0.1], arrivalTime: Duration.zero);
      await _flushMicrotasks();
      expect(container.read(tunerAudioProvider).statistics.frameCount, 1);

      audioInput.emitSamples(
        [0.2],
        arrivalTime: const Duration(milliseconds: 50),
        sequenceNumber: 1,
      );
      await _flushMicrotasks();
      expect(container.read(tunerAudioProvider).statistics.frameCount, 1);

      audioInput.emitSamples(
        [0.3],
        arrivalTime: const Duration(milliseconds: 100),
        sequenceNumber: 2,
      );
      await _flushMicrotasks();
      expect(container.read(tunerAudioProvider).statistics.frameCount, 3);
    },
  );

  test('accepts adjusted configuration reported by the backend', () async {
    await controller.start();
    audioInput.emitFormat(
      const AudioStreamFormat(
        sampleRate: 44100,
        channelCount: 1,
        encoding: AudioSampleEncoding.signedPcm16LittleEndian,
        isReportedByBackend: true,
      ),
    );
    await _flushMicrotasks();

    expect(
      container.read(tunerAudioProvider).reportedFormat?.sampleRate,
      44100,
    );
  });

  test('route release stops and disposes capture resources', () async {
    await controller.start();

    controller.releaseForNavigation();
    await _flushMicrotasks();

    expect(audioInput.stopCount, 1);
    expect(audioInput.disposeCount, 1);
  });

  test(
    'route release logs disposal failures without leaking an exception',
    () async {
      await controller.start();
      audioInput.disposeError = StateError('platform dispose failed');

      controller.releaseForNavigation();
      await _flushMicrotasks();

      expect(audioInput.disposeCount, 1);
      expect(logger.errorMessages, isNotEmpty);
    },
  );
}

Future<void> _flushMicrotasks() async {
  for (var index = 0; index < 8; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}
