import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/audio/tool_audio_coordinator.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

import 'support/fakes.dart';
import 'support/metronome_fakes.dart';

void main() {
  late FakeMetronomeEngine engine;
  late MemoryPreferencesStore store;
  late RecordingLogger logger;
  late ProviderContainer container;
  late MetronomeController controller;

  setUp(() {
    engine = FakeMetronomeEngine();
    store = MemoryPreferencesStore();
    logger = RecordingLogger();
    container = ProviderContainer(
      overrides: [
        metronomeEngineProvider.overrideWith((ref) {
          ref.onDispose(() => unawaited(engine.dispose()));
          return engine;
        }),
        preferencesStoreProvider.overrideWithValue(store),
        appLoggerProvider.overrideWithValue(logger),
      ],
    );
    controller = container.read(metronomeProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('initializes once, starts on beat one, and stops', () async {
    await controller.start();

    expect(engine.initializeCount, 1);
    expect(engine.startCount, 1);
    expect(container.read(metronomeProvider).isRunning, isTrue);

    engine.emitBeat(beatNumber: 1, accented: true);

    expect(container.read(metronomeProvider).currentBeat, 1);

    await controller.stop();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(container.read(metronomeProvider).currentBeat, 0);
    expect(engine.stopCount, 1);
  });

  test('fresh first start remains running across multiple callbacks', () async {
    await controller.start();

    for (final beat in [1, 2, 3, 4, 1, 2, 3, 4]) {
      engine.emitBeat(beatNumber: beat, accented: beat == 1);
    }

    expect(engine.initializeCount, 1);
    expect(engine.startCount, 1);
    expect(engine.isRunning, isTrue);
    expect(container.read(metronomeProvider).isRunning, isTrue);
    expect(container.read(metronomeProvider).currentBeat, 4);
  });

  test('restart reuses initialized engine and gets a new run', () async {
    await controller.start();
    final firstRun = engine.currentRunId;
    await controller.stop();
    await controller.start();

    expect(engine.initializeCount, 1);
    expect(engine.startCount, 2);
    expect(engine.currentRunId, isNot(firstRun));
  });

  test('duplicate Start is ignored while initialization is pending', () async {
    engine.pendingInitialization = Completer<void>();

    final first = controller.start();
    final duplicate = controller.start();
    await _flushMicrotasks();

    expect(engine.initializeCount, 1);

    engine.pendingInitialization!.complete();
    await Future.wait([first, duplicate]);

    expect(engine.startCount, 1);
  });

  test('rapid Stop invalidates a pending Start', () async {
    engine.pendingInitialization = Completer<void>();

    final start = controller.start();
    await _flushMicrotasks();
    await controller.stop();
    engine.pendingInitialization!.complete();
    await start;

    expect(engine.startCount, 0);
    expect(container.read(metronomeProvider).isRunning, isFalse);
  });

  test('rapid repeated Start and Stop remains restartable', () async {
    for (var index = 0; index < 20; index++) {
      await controller.start();
      await controller.stop();
    }

    expect(engine.startCount, 20);
    expect(engine.stopCount, 20);
    expect(container.read(metronomeProvider).isRunning, isFalse);

    await controller.start();
    expect(container.read(metronomeProvider).isRunning, isTrue);
  });

  test('late callback after Stop is ignored', () async {
    await controller.start();
    final stoppedRun = engine.currentRunId;
    await controller.stop();

    engine.emitBeat(runId: stoppedRun, beatNumber: 2);

    expect(container.read(metronomeProvider).currentBeat, 0);
  });

  test('late callback from an old run is ignored after restart', () async {
    await controller.start();
    final oldRun = engine.currentRunId;
    await controller.stop();
    await controller.start();

    engine.emitBeat(runId: oldRun, beatNumber: 4);
    expect(container.read(metronomeProvider).currentBeat, 0);

    engine.emitBeat(beatNumber: 1, accented: true);
    expect(container.read(metronomeProvider).currentBeat, 1);
  });

  test('stale error from an old stream cannot stop a replacement', () async {
    await controller.start();
    final oldStreamGeneration = engine.currentStreamGeneration;

    await controller.releaseAudio();
    controller.prepareForScreen();
    await controller.start();

    expect(engine.currentStreamGeneration, isNot(oldStreamGeneration));
    engine.emitFailure(
      runId: engine.currentRunId,
      streamGeneration: oldStreamGeneration,
    );
    await _flushMicrotasks();

    expect(engine.isRunning, isTrue);
    expect(container.read(metronomeProvider).isRunning, isTrue);
    expect(container.read(metronomeProvider).failure, isNull);
  });

  test('BPM limits and stopped update are passed at initialization', () async {
    controller.setBpm(5);
    expect(container.read(metronomeProvider).config.bpm, 20);
    controller.setBpm(500);
    expect(container.read(metronomeProvider).config.bpm, 300);

    await controller.start();

    expect(engine.initializedConfigs.single.bpm, 300);
    expect(engine.bpms, isEmpty);
  });

  test('BPM changes while running without restarting', () async {
    await controller.start();

    controller.setBpm(150);
    await _flushMicrotasks();

    expect(container.read(metronomeProvider).config.bpm, 150);
    expect(engine.bpms, [150]);
    expect(engine.startCount, 1);
    expect(container.read(metronomeProvider).isRunning, isTrue);
  });

  test('repeated rapid BPM updates reach the engine in order', () async {
    await controller.start();

    for (final bpm in [40, 60, 90, 120, 160, 200, 300]) {
      controller.previewBpm(bpm);
    }
    await _flushMicrotasks();

    expect(engine.bpms, [40, 60, 90, 120, 160, 200, 300]);
    expect(container.read(metronomeProvider).config.bpm, 300);
  });

  test('persisted BPM is saved', () async {
    controller.setBpm(132);
    await _flushMicrotasks();

    expect(store.values['metronome.bpm'], '132');
  });

  for (final signature in MetronomeTimeSignature.values) {
    test(
      '${signature.id} visual beat callbacks preserve engine order',
      () async {
        controller.setTimeSignature(signature);
        await controller.start();

        for (var beat = 1; beat <= signature.beatsPerMeasure; beat++) {
          engine.emitBeat(beatNumber: beat, accented: beat == 1);
          expect(container.read(metronomeProvider).currentBeat, beat);
        }
        engine.emitBeat(beatNumber: 1, accented: true);
        expect(container.read(metronomeProvider).currentBeat, 1);
      },
    );
  }

  test(
    'signature change while running resets visual bar predictably',
    () async {
      await controller.start();
      engine.emitBeat(beatNumber: 3);

      controller.setTimeSignature(MetronomeTimeSignature.sixEight);
      await _flushMicrotasks();

      expect(container.read(metronomeProvider).currentBeat, 0);
      expect(engine.timeSignatures, [MetronomeTimeSignature.sixEight]);
      expect(engine.startCount, 1);

      engine.emitBeat(beatNumber: 1, accented: true);
      expect(container.read(metronomeProvider).currentBeat, 1);
    },
  );

  test('6/8 retains denominator-aware quarter-note BPM semantics', () {
    const config = MetronomeConfig(
      bpm: 120,
      timeSignature: MetronomeTimeSignature.sixEight,
    );

    expect(config.beatDuration, const Duration(milliseconds: 250));
    expect(config.timeSignature.beatsPerMeasure, 6);
    expect(config.timeSignature.beatUnit, 8);
  });

  test('volume and accent update live and persist', () async {
    await controller.start();

    controller.previewVolume(0.3);
    controller.commitVolume();
    controller.setAccentEnabled(false);
    await _flushMicrotasks();

    expect(engine.volumes, [0.3]);
    expect(engine.accents, [false]);
    expect(store.values['metronome.volume'], '0.3');
    expect(store.values['metronome.accentEnabled'], 'false');
  });

  test('initialization failure reports an error and permits retry', () async {
    engine.failInitialization = true;

    await controller.start();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(
      container.read(metronomeProvider).failure,
      MetronomeFailure.audioUnavailable,
    );
    expect(logger.errorMessages, isNotEmpty);

    engine.failInitialization = false;
    await controller.start();

    expect(container.read(metronomeProvider).isRunning, isTrue);
    expect(engine.initializeCount, 2);
  });

  test('start failure reports an error and permits retry', () async {
    engine.failStart = true;
    await controller.start();

    expect(
      container.read(metronomeProvider).failure,
      MetronomeFailure.audioUnavailable,
    );

    engine.failStart = false;
    await controller.start();
    expect(container.read(metronomeProvider).isRunning, isTrue);
  });

  test('runtime engine failure stops safely and permits recovery', () async {
    await controller.start();
    engine.emitFailure();
    await _flushMicrotasks();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(
      container.read(metronomeProvider).failure,
      MetronomeFailure.audioUnavailable,
    );

    await controller.start();
    expect(container.read(metronomeProvider).isRunning, isTrue);
  });

  test('failed live update transitions to a recoverable error', () async {
    await controller.start();
    engine.failUpdates = true;

    controller.setBpm(140);
    await _flushMicrotasks();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(
      container.read(metronomeProvider).failure,
      MetronomeFailure.audioUnavailable,
    );
  });

  test('backgrounding stops and foregrounding never auto-starts', () async {
    await controller.start();

    await controller.handleLifecycle(isForeground: false);
    await controller.handleLifecycle(isForeground: true);

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(engine.startCount, 1);
  });

  test('route release disposes resources and re-entry can restart', () async {
    await controller.start();

    await controller.releaseAudio();
    expect(engine.disposeCount, 1);
    expect(engine.isRunning, isFalse);

    controller.prepareForScreen();
    await controller.start();

    expect(engine.initializeCount, 2);
    expect(container.read(metronomeProvider).isRunning, isTrue);
  });

  test(
    're-entry waits for delayed cleanup before opening a new stream',
    () async {
      await controller.start();
      engine.pendingDispose = Completer<void>();

      final oldRelease = controller.releaseAudio();
      await _flushMicrotasks();
      expect(engine.disposeCount, 1);

      controller.prepareForScreen();
      final newStart = controller.start();
      await _flushMicrotasks();

      expect(engine.initializeCount, 1);
      expect(engine.startCount, 1);

      engine.pendingDispose!.complete();
      await oldRelease;
      await newStart;

      expect(engine.initializeCount, 2);
      expect(engine.startCount, 2);
      expect(engine.isRunning, isTrue);
      expect(container.read(metronomeProvider).isRunning, isTrue);
    },
  );

  test('provider disposal releases engine resources', () async {
    await controller.start();

    container.dispose();
    await _flushMicrotasks();

    expect(engine.disposeCount, 1);
  });

  test('starting metronome releases an active tuner first', () async {
    var tunerReleaseCount = 0;
    final coordinator = container.read(toolAudioCoordinatorProvider);
    Future<void> releaseTuner() async {
      tunerReleaseCount++;
    }

    coordinator.registerTuner(releaseTuner);
    await controller.start();

    expect(tunerReleaseCount, 1);
    expect(engine.startCount, 1);
  });

  test('debug diagnostics distinguish Flutter callback timing', () async {
    await controller.start();
    engine.emitBeat(beatNumber: 1, accented: true);

    expect(
      logger.debugMessages,
      contains(contains('note=callback-timing-not-acoustic-timing')),
    );
    expect(
      logger.debugMessages,
      contains(contains('implementation=Fake metronome engine')),
    );
  });

  test('reset stops and restores persisted defaults', () async {
    await controller.start();
    controller.setBpm(144);
    controller.setTimeSignature(MetronomeTimeSignature.sixEight);
    controller.setAccentEnabled(false);
    controller.previewVolume(0.2);

    await controller.reset();

    expect(container.read(metronomeProvider).config, const MetronomeConfig());
    expect(store.values['metronome.bpm'], '120');
    expect(store.values['metronome.timeSignature'], '4/4');
    expect(store.values['metronome.accentEnabled'], 'true');
    expect(store.values['metronome.volume'], '0.65');
  });

  test('BPM Tap applies only supported values', () {
    expect(controller.applyBpmTap(184), isTrue);
    expect(container.read(metronomeProvider).config.bpm, 184);

    expect(controller.applyBpmTap(301), isFalse);
    expect(container.read(metronomeProvider).config.bpm, 184);
  });
}

Future<void> _flushMicrotasks() async {
  for (var index = 0; index < 8; index++) {
    await Future<void>.value();
  }
}
