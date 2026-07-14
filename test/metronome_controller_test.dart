import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

import 'support/fakes.dart';
import 'support/metronome_fakes.dart';

void main() {
  late FakeMetronomeAudioOutput audio;
  late FakeMetronomeScheduler scheduler;
  late MemoryPreferencesStore store;
  late RecordingLogger logger;
  late ProviderContainer container;
  late MetronomeController controller;

  setUp(() {
    audio = FakeMetronomeAudioOutput();
    scheduler = FakeMetronomeScheduler();
    store = MemoryPreferencesStore();
    logger = RecordingLogger();
    container = ProviderContainer(
      overrides: [
        metronomeAudioOutputProvider.overrideWithValue(audio),
        metronomeSchedulerProvider.overrideWithValue(scheduler),
        preferencesStoreProvider.overrideWithValue(store),
        appLoggerProvider.overrideWithValue(logger),
      ],
    );
    controller = container.read(metronomeProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('starts, sequences accented audio, and stops', () async {
    await controller.start();

    expect(container.read(metronomeProvider).isRunning, isTrue);
    expect(audio.initializeCount, 1);
    expect(scheduler.startCount, 1);

    scheduler.fire();
    await Future<void>.delayed(Duration.zero);
    scheduler.fire();
    await Future<void>.delayed(Duration.zero);

    expect(audio.plays, [
      (accented: true, volume: MetronomeConfig.defaultVolume),
      (accented: false, volume: MetronomeConfig.defaultVolume),
    ]);
    expect(container.read(metronomeProvider).currentBeat, 2);

    await controller.stop();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(container.read(metronomeProvider).currentBeat, 0);
    expect(scheduler.isRunning, isFalse);
  });

  test('prevents duplicate scheduler starts', () async {
    final firstStart = controller.start();
    final duplicateStart = controller.start();
    await Future.wait([firstStart, duplicateStart]);

    expect(audio.initializeCount, 1);
    expect(scheduler.startCount, 1);
  });

  test('updates running interval when BPM changes', () async {
    await controller.start();

    controller.setBpm(150);

    expect(container.read(metronomeProvider).config.bpm, 150);
    expect(scheduler.intervals.last, const Duration(milliseconds: 400));
  });

  test('stops on background lifecycle and remains stopped on return', () async {
    await controller.start();

    await controller.handleLifecycle(isForeground: false);
    await controller.handleLifecycle(isForeground: true);

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(scheduler.startCount, 1);
  });

  test('releases screen resources and normalizes state on re-entry', () async {
    await controller.start();

    await controller.releaseAudio();

    expect(scheduler.isRunning, isFalse);
    expect(audio.disposeCount, 1);
    await controller.start();
    expect(scheduler.startCount, 1);

    controller.prepareForScreen();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    await controller.start();
    expect(scheduler.startCount, 2);
  });

  test('reports initialization failure and permits retry', () async {
    audio.failInitialization = true;

    await controller.start();

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(
      container.read(metronomeProvider).failure,
      MetronomeFailure.audioUnavailable,
    );
    expect(logger.errorMessages, isNotEmpty);

    audio.failInitialization = false;
    await controller.start();

    expect(container.read(metronomeProvider).isRunning, isTrue);
    expect(audio.initializeCount, 2);
  });

  test('stops safely when beat playback fails', () async {
    audio.failPlayback = true;
    await controller.start();

    scheduler.fire();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(metronomeProvider).isRunning, isFalse);
    expect(
      container.read(metronomeProvider).failure,
      MetronomeFailure.audioUnavailable,
    );
    expect(scheduler.isRunning, isFalse);
  });

  test('persists configuration changes and reset defaults', () async {
    controller.setBpm(132);
    controller.setTimeSignature(MetronomeTimeSignature.sixEight);
    controller.setAccentEnabled(false);
    controller.previewVolume(0.3);
    controller.commitVolume();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(store.values['metronome.bpm'], '132');
    expect(store.values['metronome.timeSignature'], '6/8');
    expect(store.values['metronome.accentEnabled'], 'false');
    expect(store.values['metronome.volume'], '0.3');

    await controller.reset();

    expect(container.read(metronomeProvider).config, const MetronomeConfig());
    expect(store.values['metronome.bpm'], '120');
    expect(store.values['metronome.timeSignature'], '4/4');
  });

  test('applies only supported BPM Tap values', () {
    expect(controller.applyBpmTap(184), isTrue);
    expect(container.read(metronomeProvider).config.bpm, 184);

    expect(controller.applyBpmTap(301), isFalse);
    expect(container.read(metronomeProvider).config.bpm, 184);
  });
}
