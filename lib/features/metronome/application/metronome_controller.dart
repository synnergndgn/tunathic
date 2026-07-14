import 'dart:async';

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
  int _operationVersion = 0;

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
    state = state.copyWith(
      config: state.config.copyWith(timeSignature: signature),
      currentBeat: 0,
    );
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

  void _onBeat() {
    if (!state.isRunning) return;
    final beat = _sequence.nextBeat(state.currentBeat, state.config);
    state = state.copyWith(currentBeat: beat.number);
    unawaited(_playBeat(beat.isAccented));
  }

  Future<void> _playBeat(bool accented) async {
    try {
      await _audio.play(accented: accented, volume: state.config.volume);
    } on Object catch (error, stackTrace) {
      if (!state.isRunning || !_acceptRuntimeEvents) return;
      _logger.error('Could not play metronome beat', error, stackTrace);
      _scheduler.stop();
      _audioInitialized = false;
      await _audio.dispose();
      state = state.copyWith(
        currentBeat: 0,
        isRunning: false,
        isInitializing: false,
        failure: MetronomeFailure.audioUnavailable,
      );
    }
  }

  Future<void> _persist() async {
    try {
      await _preferences.save(state.config);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save metronome preferences', error, stackTrace);
    }
  }
}
