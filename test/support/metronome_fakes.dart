import 'dart:async';

import 'package:tunathic/features/metronome/application/metronome_scheduler.dart';
import 'package:tunathic/features/metronome/audio/metronome_audio_output.dart';

final class FakeMetronomeAudioOutput implements MetronomeAudioOutput {
  bool failInitialization = false;
  bool failPlayback = false;
  int initializeCount = 0;
  int disposeCount = 0;
  Completer<void>? pendingPlayback;
  final List<({bool accented, double volume})> plays = [];

  @override
  Future<void> initialize() async {
    initializeCount++;
    if (failInitialization) throw StateError('Audio initialization failed');
  }

  @override
  Future<void> play({required bool accented, required double volume}) async {
    if (failPlayback) throw StateError('Audio playback failed');
    plays.add((accented: accented, volume: volume));
    await pendingPlayback?.future;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
  }
}

final class FakeMetronomeScheduler implements MetronomeScheduler {
  int startCount = 0;
  int stopCount = 0;
  final List<Duration> intervals = [];
  void Function(MetronomeTick tick)? _onBeat;
  MetronomeTick nextTick = const MetronomeTick(
    intendedDeadline: Duration.zero,
    callbackTime: Duration.zero,
    lateness: Duration.zero,
    skippedDeadlines: 0,
  );

  @override
  bool isRunning = false;

  @override
  void start({
    required Duration interval,
    required void Function(MetronomeTick tick) onBeat,
  }) {
    startCount++;
    isRunning = true;
    intervals.add(interval);
    _onBeat = onBeat;
  }

  @override
  void updateInterval(Duration interval) {
    intervals.add(interval);
  }

  @override
  void stop() {
    stopCount++;
    isRunning = false;
    _onBeat = null;
  }

  @override
  void dispose() => stop();

  void fire() => _onBeat?.call(nextTick);
}
