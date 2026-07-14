import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

abstract interface class MetronomeAudioOutput {
  Future<void> initialize();

  Future<void> play({required bool accented, required double volume});

  Future<void> dispose();
}

final class AudioplayersMetronomeAudioOutput implements MetronomeAudioOutput {
  static const _regularAsset = 'audio/metronome_regular.wav';
  static const _accentAsset = 'audio/metronome_accent.wav';
  static const _releaseDelay = Duration(milliseconds: 100);

  AudioPool? _regularPool;
  AudioPool? _accentPool;
  final Set<StopFunction> _activeStops = {};
  final Set<Timer> _releaseTimers = {};

  @override
  Future<void> initialize() async {
    if (_regularPool != null && _accentPool != null) return;
    await dispose();

    final context = AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );

    try {
      _regularPool = await AudioPool.create(
        source: AssetSource(_regularAsset),
        maxPlayers: 3,
        minPlayers: 2,
        playerMode: PlayerMode.lowLatency,
        audioContext: context,
      );
      _accentPool = await AudioPool.create(
        source: AssetSource(_accentAsset),
        maxPlayers: 3,
        minPlayers: 2,
        playerMode: PlayerMode.lowLatency,
        audioContext: context,
      );
    } on Object {
      await dispose();
      rethrow;
    }
  }

  @override
  Future<void> play({required bool accented, required double volume}) async {
    final pool = accented ? _accentPool : _regularPool;
    if (pool == null) throw StateError('Metronome audio is not initialized');

    final stop = await pool.start(volume: volume.clamp(0.0, 1.0));
    _activeStops.add(stop);
    late final Timer releaseTimer;
    releaseTimer = Timer(_releaseDelay, () {
      _releaseTimers.remove(releaseTimer);
      unawaited(_release(stop));
    });
    _releaseTimers.add(releaseTimer);
  }

  @override
  Future<void> dispose() async {
    for (final timer in _releaseTimers) {
      timer.cancel();
    }
    _releaseTimers.clear();

    final stops = _activeStops.toList();
    _activeStops.clear();
    await Future.wait(stops.map(_stopSafely));

    final regularPool = _regularPool;
    final accentPool = _accentPool;
    _regularPool = null;
    _accentPool = null;
    await Future.wait([
      if (regularPool != null) regularPool.dispose(),
      if (accentPool != null) accentPool.dispose(),
    ]);
  }

  Future<void> _release(StopFunction stop) async {
    if (!_activeStops.remove(stop)) return;
    await _stopSafely(stop);
  }

  Future<void> _stopSafely(StopFunction stop) async {
    try {
      await stop();
    } on Object {
      // Disposal is best effort; playback failures are reported by play().
    }
  }
}
