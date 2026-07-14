import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/metronome/application/metronome_preferences.dart';
import 'package:tunathic/features/metronome/application/metronome_scheduler.dart';
import 'package:tunathic/features/metronome/audio/metronome_audio_output.dart';
import 'package:tunathic/features/metronome/domain/beat_sequence.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

enum MetronomeFailure { audioUnavailable }

final class MetronomeState {
  const MetronomeState({
    this.config = const MetronomeConfig(),
    this.currentBeat = 0,
    this.isRunning = false,
    this.isInitializing = false,
    this.failure,
  });

  final MetronomeConfig config;
  final int currentBeat;
  final bool isRunning;
  final bool isInitializing;
  final MetronomeFailure? failure;

  MetronomeState copyWith({
    MetronomeConfig? config,
    int? currentBeat,
    bool? isRunning,
    bool? isInitializing,
    MetronomeFailure? failure,
    bool clearFailure = false,
  }) {
    return MetronomeState(
      config: config ?? this.config,
      currentBeat: currentBeat ?? this.currentBeat,
      isRunning: isRunning ?? this.isRunning,
      isInitializing: isInitializing ?? this.isInitializing,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

final initialMetronomeConfigProvider = Provider<MetronomeConfig>(
  (ref) => const MetronomeConfig(),
);

final metronomeAudioOutputProvider = Provider<MetronomeAudioOutput>((ref) {
  final output = AudioplayersMetronomeAudioOutput();
  ref.onDispose(() => unawaited(output.dispose()));
  return output;
});

final metronomeSchedulerProvider = Provider<MetronomeScheduler>((ref) {
  final scheduler = AnchoredMetronomeScheduler();
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final metronomeProvider = NotifierProvider<MetronomeController, MetronomeState>(
  MetronomeController.new,
);

final class MetronomeController extends Notifier<MetronomeState> {
  static const _sequence = BeatSequence();

  late final MetronomeAudioOutput _audio;
  late final MetronomeScheduler _scheduler;
  late final MetronomePreferences _preferences;
  late final AppLogger _logger;
  bool _audioInitialized = false;
  bool _acceptRuntimeEvents = true;
  bool _handlingAudioFailure = false;
  int _operationVersion = 0;
  int _audioRequestId = 0;
  int _pendingAudioRequests = 0;

  @override
  MetronomeState build() {
    _audio = ref.read(metronomeAudioOutputProvider);
    _scheduler = ref.read(metronomeSchedulerProvider);
    _preferences = MetronomePreferences(ref.read(preferencesStoreProvider));
    _logger = ref.read(appLoggerProvider);
    return MetronomeState(config: ref.read(initialMetronomeConfigProvider));
  }

  Future<void> toggle() => state.isRunning ? stop() : start();

  Future<void> start() async {
    if (!_acceptRuntimeEvents || state.isRunning || state.isInitializing) {
      return;
    }
    final operation = ++_operationVersion;
    state = state.copyWith(isInitializing: true, clearFailure: true);

    try {
      if (!_audioInitialized) {
        await _audio.initialize();
        _audioInitialized = true;
      }
      if (operation != _operationVersion || !_acceptRuntimeEvents) {
        _audioInitialized = false;
        await _audio.dispose();
        return;
      }

      state = state.copyWith(
        currentBeat: 0,
        isRunning: true,
        isInitializing: false,
        clearFailure: true,
      );
      _scheduler.start(interval: state.config.beatDuration, onBeat: _onBeat);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not initialize metronome audio', error, stackTrace);
      _scheduler.stop();
      _audioInitialized = false;
      await _audio.dispose();
      if (operation == _operationVersion) {
        state = state.copyWith(
          currentBeat: 0,
          isRunning: false,
          isInitializing: false,
          failure: MetronomeFailure.audioUnavailable,
        );
      }
    }
  }

  Future<void> stop() async {
    _operationVersion++;
    _scheduler.stop();
    state = state.copyWith(
      currentBeat: 0,
      isRunning: false,
      isInitializing: false,
    );
  }

  void incrementBpm() => setBpm(state.config.bpm + 1);

  void decrementBpm() => setBpm(state.config.bpm - 1);

  void setBpm(int bpm) {
    _updateBpm(MetronomeConfig.clampBpm(bpm));
    unawaited(_persist());
  }

  void previewBpm(int bpm) => _updateBpm(MetronomeConfig.clampBpm(bpm));

  void commitBpm() => unawaited(_persist());

  bool applyBpmTap(int bpm) {
    if (bpm < MetronomeConfig.minimumBpm || bpm > MetronomeConfig.maximumBpm) {
      return false;
    }
    setBpm(bpm);
    return true;
  }

  void setTimeSignature(MetronomeTimeSignature signature) {
    if (state.config.timeSignature == signature) return;
    final config = state.config.copyWith(timeSignature: signature);
    state = state.copyWith(config: config, currentBeat: 0);
    if (state.isRunning) {
      _scheduler.updateInterval(config.beatDuration);
    }
    unawaited(_persist());
  }

  void setAccentEnabled(bool enabled) {
    if (state.config.accentEnabled == enabled) return;
    state = state.copyWith(
      config: state.config.copyWith(accentEnabled: enabled),
    );
    unawaited(_persist());
  }

  void previewVolume(double volume) {
    state = state.copyWith(
      config: state.config.copyWith(volume: volume.clamp(0.0, 1.0)),
    );
  }

  void commitVolume() => unawaited(_persist());

  Future<void> reset() async {
    await stop();
    state = const MetronomeState();
    await _persist();
  }

  Future<void> handleLifecycle({required bool isForeground}) async {
    if (!isForeground) await stop();
  }

  void prepareForScreen() {
    _acceptRuntimeEvents = true;
    if (!state.isRunning && !state.isInitializing && state.currentBeat == 0) {
      return;
    }
    state = state.copyWith(
      currentBeat: 0,
      isRunning: false,
      isInitializing: false,
    );
  }

  Future<void> releaseAudio() async {
    _acceptRuntimeEvents = false;
    _operationVersion++;
    _scheduler.stop();
    await _audio.dispose();
    _audioInitialized = false;
  }

  void _updateBpm(int bpm) {
    if (state.config.bpm == bpm) return;
    state = state.copyWith(config: state.config.copyWith(bpm: bpm));
    if (state.isRunning) {
      _scheduler.updateInterval(state.config.beatDuration);
    }
  }

  void _onBeat(MetronomeTick tick) {
    if (!state.isRunning) return;
    final config = state.config;
    final beat = _sequence.nextBeat(state.currentBeat, config);
    if (kDebugMode) {
      _logger.debug(
        'Metronome timing beat=${beat.number} bpm=${config.bpm} '
        'deadlineMs=${_milliseconds(tick.intendedDeadline)} '
        'callbackMs=${_milliseconds(tick.callbackTime)} '
        'latenessMs=${_milliseconds(tick.lateness)} '
        'skipped=${tick.skippedDeadlines} '
        'audioPending=$_pendingAudioRequests',
      );
    }
    state = state.copyWith(currentBeat: beat.number);
    unawaited(
      _playBeat(
        accented: beat.isAccented,
        beatNumber: beat.number,
        bpm: config.bpm,
        volume: config.volume,
      ),
    );
  }

  Future<void> _playBeat({
    required bool accented,
    required int beatNumber,
    required int bpm,
    required double volume,
  }) async {
    final requestId = ++_audioRequestId;
    _pendingAudioRequests++;
    _debugAudioRequest(
      requestId: requestId,
      beatNumber: beatNumber,
      bpm: bpm,
      status: 'pending',
      pending: _pendingAudioRequests,
    );
    try {
      await _audio.play(accented: accented, volume: volume);
      _debugAudioRequest(
        requestId: requestId,
        beatNumber: beatNumber,
        bpm: bpm,
        status: 'completed',
        pending: _pendingAudioRequests - 1,
      );
    } on Object catch (error, stackTrace) {
      _debugAudioRequest(
        requestId: requestId,
        beatNumber: beatNumber,
        bpm: bpm,
        status: 'failed',
        pending: _pendingAudioRequests - 1,
      );
      if (!state.isRunning || !_acceptRuntimeEvents || _handlingAudioFailure) {
        return;
      }
      _handlingAudioFailure = true;
      _logger.error('Could not play metronome beat', error, stackTrace);
      _scheduler.stop();
      _audioInitialized = false;
      if (_acceptRuntimeEvents) {
        state = state.copyWith(
          currentBeat: 0,
          isRunning: false,
          isInitializing: false,
          failure: MetronomeFailure.audioUnavailable,
        );
      }
      try {
        await _audio.dispose();
      } on Object catch (disposeError, disposeStackTrace) {
        _logger.error(
          'Could not dispose metronome audio after playback failure',
          disposeError,
          disposeStackTrace,
        );
      } finally {
        _handlingAudioFailure = false;
      }
    } finally {
      _pendingAudioRequests--;
    }
  }

  void _debugAudioRequest({
    required int requestId,
    required int beatNumber,
    required int bpm,
    required String status,
    required int pending,
  }) {
    if (!kDebugMode) return;
    _logger.debug(
      'Metronome audio request=$requestId beat=$beatNumber bpm=$bpm '
      'status=$status pending=$pending',
    );
  }

  String _milliseconds(Duration duration) =>
      (duration.inMicroseconds / Duration.microsecondsPerMillisecond)
          .toStringAsFixed(3);

  Future<void> _persist() async {
    try {
      await _preferences.save(state.config);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save metronome preferences', error, stackTrace);
    }
  }
}
