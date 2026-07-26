import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReleaseAudioTool = Future<void> Function();

enum AudioToolOwner { none, metronome, tuner }

final class AudioToolLease {
  const AudioToolLease({required this.owner, required this.generation});

  final AudioToolOwner owner;
  final int generation;
}

final toolAudioCoordinatorProvider = Provider<ToolAudioCoordinator>(
  (ref) => ToolAudioCoordinator(),
);

/// Coordinates the two Tunathic tools that currently own Android audio.
///
/// This intentionally remains a small callback registry rather than an audio
/// policy layer. Each feature still owns its platform resources and lifecycle.
final class ToolAudioCoordinator {
  ReleaseAudioTool? _releaseMetronome;
  ReleaseAudioTool? _releaseTuner;
  AudioToolOwner _owner = AudioToolOwner.none;
  int _generation = 0;

  AudioToolOwner get owner => _owner;

  int get generation => _generation;

  void registerMetronome(ReleaseAudioTool release) {
    _releaseMetronome = release;
  }

  void unregisterMetronome(ReleaseAudioTool release) {
    if (identical(_releaseMetronome, release)) {
      _releaseMetronome = null;
    }
  }

  void registerTuner(ReleaseAudioTool release) {
    _releaseTuner = release;
  }

  void unregisterTuner(ReleaseAudioTool release) {
    if (identical(_releaseTuner, release)) {
      _releaseTuner = null;
    }
  }

  Future<void> releaseMetronome() async {
    final request = ++_generation;
    _owner = AudioToolOwner.none;
    await _releaseMetronome?.call();
    if (request == _generation) {
      _owner = AudioToolOwner.tuner;
    }
  }

  Future<AudioToolLease> acquireMetronome() async {
    final request = ++_generation;
    _owner = AudioToolOwner.none;
    await _releaseTuner?.call();
    if (request == _generation) {
      _owner = AudioToolOwner.metronome;
    }
    return AudioToolLease(owner: AudioToolOwner.metronome, generation: request);
  }

  bool isCurrent(AudioToolLease lease) =>
      lease.generation == _generation && lease.owner == _owner;

  void release(AudioToolLease? lease) {
    if (lease == null || !isCurrent(lease)) return;
    _generation++;
    _owner = AudioToolOwner.none;
  }
}
