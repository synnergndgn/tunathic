import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/audio/tool_audio_coordinator.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/metronome/application/metronome_preferences.dart';
import 'package:tunathic/features/metronome/audio/metronome_engine.dart';
import 'package:tunathic/features/metronome/audio/native_metronome_engine.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

enum MetronomeFailure { audioUnavailable }

enum MetronomeStopReason {
  user,
  lifecycle,
  navigation,
  tunerCoordination,
  nativeError,
  staleOperation,
  initializationCleanup,
  engineCallback,
}

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

final metronomeEngineProvider = Provider<MetronomeEngine>((ref) {
  final engine = NativeMetronomeEngine();
  ref.onDispose(() => unawaited(engine.dispose()));
  return engine;
});

final metronomeProvider = NotifierProvider<MetronomeController, MetronomeState>(
  MetronomeController.new,
);

final class MetronomeController extends Notifier<MetronomeState> {
  late final MetronomeEngine _engine;
  late final MetronomePreferences _preferences;
  late final AppLogger _logger;
  late final ToolAudioCoordinator _audioCoordinator;
  late final StreamSubscription<MetronomeEngineEvent> _engineEvents;

  bool _acceptRuntimeEvents = true;
  bool _runRequested = false;
  bool _resumeAfterLifecycle = false;
  int _operationVersion = 0;
  int? _activeRunId;
  int? _activeStreamGeneration;
  AudioToolLease? _audioLease;
  Future<void>? _releaseFuture;
  Stopwatch? _callbackClock;
  Duration? _lastCallbackTime;
  int _lastSequence = 0;
  int _callbackCount = 0;
  int _missedCallbackCount = 0;

  @override
  MetronomeState build() {
    _engine = ref.read(metronomeEngineProvider);
    _preferences = MetronomePreferences(ref.read(preferencesStoreProvider));
    _logger = ref.read(appLoggerProvider);
    _audioCoordinator = ref.read(toolAudioCoordinatorProvider);
    _engineEvents = _engine.events.listen(_onEngineEvent);
    ref.onDispose(() {
      unawaited(_engineEvents.cancel());
    });
    return MetronomeState(config: ref.read(initialMetronomeConfigProvider));
  }

  Future<void> toggle() => state.isRunning ? stop() : start();

  Future<void> start() {
    _runRequested = true;
    _resumeAfterLifecycle = false;
    return _startEngine();
  }

  Future<void> _startEngine() async {
    if (!_acceptRuntimeEvents || state.isRunning || state.isInitializing) {
      return;
    }
    final operation = ++_operationVersion;
    state = state.copyWith(
      currentBeat: 0,
      isInitializing: true,
      clearFailure: true,
    );
    _resetDiagnostics();
    _callbackClock = Stopwatch()..start();
    _debug(
      'Metronome controller start operation=$operation '
      'pendingRelease=${_releaseFuture != null}',
    );

    try {
      final pendingRelease = _releaseFuture;
      if (pendingRelease != null) {
        _debug(
          'Metronome controller operation=$operation '
          'awaitingPreviousRelease=true',
        );
        await pendingRelease;
        if (!_isCurrent(operation)) return;
      }
      final lease = await _audioCoordinator.acquireMetronome();
      if (!_isCurrent(operation) || !_audioCoordinator.isCurrent(lease)) {
        _debug(
          'Metronome coordinator acquisition rejected '
          'operation=$operation leaseGeneration=${lease.generation} '
          'coordinatorGeneration=${_audioCoordinator.generation} '
          'owner=${_audioCoordinator.owner.name}',
        );
        return;
      }
      _audioLease = lease;
      _debug(
        'Metronome coordinator acquired operation=$operation '
        'generation=${lease.generation} owner=${lease.owner.name}',
      );

      final info = _engine.isInitialized
          ? null
          : await _engine.initialize(state.config);
      if (!_isCurrent(operation)) {
        await _engine.stop();
        return;
      }
      if (info != null) {
        _debug(
          'Metronome engine initialized implementation=${info.implementation} '
          'api=${info.audioApi} sampleRate=${info.sampleRate} '
          'framesPerBurst=${info.framesPerBurst} '
          'bufferFrames=${info.bufferSizeFrames} '
          'engineInstance=${info.engineInstanceId} '
          'streamGeneration=${info.streamGeneration} '
          'lifecycleState=${info.lifecycleState}',
        );
      } else {
        _debug(
          'Metronome engine reused implementation='
          '${_engine.implementationName}',
        );
      }

      final run = await _engine.start();
      if (!_isCurrent(operation)) {
        _debug(
          'Metronome controller operation=$operation staleAfterStart=true '
          'stopReason=${MetronomeStopReason.staleOperation.name}',
        );
        await _engine.stop();
        return;
      }
      _activeRunId = run.runId;
      _activeStreamGeneration = run.streamGeneration;
      state = state.copyWith(
        currentBeat: 0,
        isRunning: true,
        isInitializing: false,
        clearFailure: true,
      );
      _debug(
        'Metronome start operation=$operation run=${run.runId} '
        'streamGeneration=${run.streamGeneration} '
        'requestedBpm=${state.config.bpm} '
        'signature=${state.config.timeSignature.id}',
      );
    } on Object catch (error, stackTrace) {
      await _handleStartFailure(operation, error, stackTrace);
    }
  }

  Future<void> stop({MetronomeStopReason reason = MetronomeStopReason.user}) {
    _runRequested = false;
    _resumeAfterLifecycle = false;
    return _stopEngine(reason);
  }

  Future<void> _stopEngine(MetronomeStopReason reason) {
    _operationVersion++;
    _activeRunId = null;
    _activeStreamGeneration = null;
    _audioCoordinator.release(_audioLease);
    _audioLease = null;
    _callbackClock?.stop();
    _debug(
      'Metronome transition running=false operation=$_operationVersion '
      'reason=${reason.name}',
    );
    state = state.copyWith(
      currentBeat: 0,
      isRunning: false,
      isInitializing: false,
    );
    return _runLifecycleCleanup(() => _performStop(reason), reason: reason);
  }

  Future<void> _performStop(MetronomeStopReason reason) async {
    try {
      final report = await _engine.stop();
      _debug(
        'Metronome stop reason=${reason.name} '
        'framesRendered=${report.framesRendered} '
        'xRuns=${report.xRunCount} callbacks=$_callbackCount '
        'missedCallbacks=$_missedCallbackCount',
      );
    } on Object catch (error, stackTrace) {
      _logger.error('Could not stop metronome engine', error, stackTrace);
      await _disposeEngineSafely();
      if (_acceptRuntimeEvents) {
        state = state.copyWith(failure: MetronomeFailure.audioUnavailable);
      }
    } finally {
      _resetDiagnostics();
    }
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
    _debug(
      'Metronome signature update requested signature=${signature.id} '
      'behavior=next-pulse-beat-one',
    );
    if (_engine.isInitialized) {
      _runEngineUpdate(
        _engine.setTimeSignature(signature),
        'update metronome time signature',
      );
    }
    unawaited(_persist());
  }

  void setAccentEnabled(bool enabled) {
    if (state.config.accentEnabled == enabled) return;
    state = state.copyWith(
      config: state.config.copyWith(accentEnabled: enabled),
    );
    if (_engine.isInitialized) {
      _runEngineUpdate(
        _engine.setAccentEnabled(enabled),
        'update metronome accent',
      );
    }
    unawaited(_persist());
  }

  void previewVolume(double volume) {
    final normalizedVolume = volume.clamp(0.0, 1.0);
    if (state.config.volume == normalizedVolume) return;
    state = state.copyWith(
      config: state.config.copyWith(volume: normalizedVolume),
    );
    if (_engine.isInitialized) {
      _runEngineUpdate(
        _engine.setVolume(normalizedVolume),
        'update metronome volume',
      );
    }
  }

  void commitVolume() => unawaited(_persist());

  Future<void> reset() async {
    await stop();
    state = const MetronomeState();
    if (_engine.isInitialized) {
      try {
        await _configureInitializedEngine(state.config);
      } on Object catch (error, stackTrace) {
        _logger.error('Could not reset metronome engine', error, stackTrace);
        await _disposeEngineSafely();
        state = state.copyWith(failure: MetronomeFailure.audioUnavailable);
      }
    }
    await _persist();
  }

  Future<void> handleLifecycle({required bool isForeground}) async {
    if (!isForeground) {
      if (!_runRequested || _resumeAfterLifecycle) return;
      _resumeAfterLifecycle = true;
      await _stopEngine(MetronomeStopReason.lifecycle);
      return;
    }
    if (!_resumeAfterLifecycle || !_runRequested) return;
    _resumeAfterLifecycle = false;
    await _startEngine();
  }

  void prepareForScreen() {
    _acceptRuntimeEvents = true;
    _debug(
      'Metronome route prepared operation=$_operationVersion '
      'pendingRelease=${_releaseFuture != null}',
    );
  }

  Future<void> releaseAudio({
    MetronomeStopReason reason = MetronomeStopReason.navigation,
  }) {
    _runRequested = false;
    _resumeAfterLifecycle = false;
    _acceptRuntimeEvents = false;
    _operationVersion++;
    _activeRunId = null;
    _activeStreamGeneration = null;
    _audioCoordinator.release(_audioLease);
    _audioLease = null;
    _callbackClock?.stop();
    _debug(
      'Metronome release requested operation=$_operationVersion '
      'reason=${reason.name}',
    );
    state = state.copyWith(
      currentBeat: 0,
      isRunning: false,
      isInitializing: false,
    );
    return _runLifecycleCleanup(() => _performRelease(reason), reason: reason);
  }

  Future<void> _performRelease(MetronomeStopReason reason) async {
    try {
      final report = await _engine.stop();
      _debug(
        'Metronome release completedStop reason=${reason.name} '
        'framesRendered=${report.framesRendered} xRuns=${report.xRunCount}',
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Could not stop metronome engine during release',
        error,
        stackTrace,
      );
    }
    await _disposeEngineSafely();
    _debug('Metronome release disposed reason=${reason.name}');
    _resetDiagnostics();
  }

  void _updateBpm(int bpm) {
    if (state.config.bpm == bpm) return;
    state = state.copyWith(config: state.config.copyWith(bpm: bpm));
    _debug(
      'Metronome BPM update requested bpm=$bpm '
      'behavior=phase-preserving',
    );
    if (_engine.isInitialized) {
      _runEngineUpdate(_engine.setBpm(bpm), 'update metronome BPM');
    }
  }

  void _onEngineEvent(MetronomeEngineEvent event) {
    try {
      switch (event) {
        case MetronomeEngineBeat():
          _onEngineBeat(event);
        case MetronomeEngineFailure():
          _onEngineFailure(event);
      }
    } on Object catch (error, stackTrace) {
      // Visual callback processing is non-critical and must never stop audio.
      _logger.error(
        'Could not process metronome visual callback',
        error,
        stackTrace,
      );
    }
  }

  void _onEngineBeat(MetronomeEngineBeat event) {
    if (!state.isRunning ||
        event.runId != _activeRunId ||
        event.streamGeneration != _activeStreamGeneration ||
        !_acceptRuntimeEvents) {
      _debug(
        'Metronome beat filtered run=${event.runId} '
        'streamGeneration=${event.streamGeneration} '
        'activeRun=$_activeRunId '
        'activeStreamGeneration=$_activeStreamGeneration '
        'acceptRuntimeEvents=$_acceptRuntimeEvents',
      );
      return;
    }
    final now = _callbackClock?.elapsed ?? Duration.zero;
    _callbackCount++;
    if (_lastSequence > 0 && event.sequence > _lastSequence + 1) {
      _missedCallbackCount += event.sequence - _lastSequence - 1;
    }
    final actualInterval = _lastCallbackTime == null
        ? null
        : now - _lastCallbackTime!;
    final expectedInterval = state.config.beatDuration;
    final deviation = actualInterval == null
        ? null
        : actualInterval - expectedInterval;
    final startLatency = _callbackCount == 1 ? now : null;
    _lastSequence = event.sequence;
    _lastCallbackTime = now;
    state = state.copyWith(currentBeat: event.beatNumber);
    _debug(
      'Metronome Flutter callback run=${event.runId} '
      'streamGeneration=${event.streamGeneration} '
      'sequence=${event.sequence} beat=${event.beatNumber} '
      'accented=${event.isAccented} audioFrame=${event.audioFramePosition} '
      'requestedBpm=${state.config.bpm} '
      'callbackIntervalMs=${_milliseconds(actualInterval)} '
      'callbackDeviationMs=${_milliseconds(deviation)} '
      'startCallbackLatencyMs=${_milliseconds(startLatency)} '
      'missedCallbacks=$_missedCallbackCount '
      'note=callback-timing-not-acoustic-timing',
    );
  }

  void _onEngineFailure(MetronomeEngineFailure event) {
    if (event.runId != _activeRunId ||
        event.streamGeneration != _activeStreamGeneration ||
        !_acceptRuntimeEvents) {
      _debug(
        'Metronome error filtered run=${event.runId} '
        'streamGeneration=${event.streamGeneration} '
        'activeRun=$_activeRunId '
        'activeStreamGeneration=$_activeStreamGeneration',
      );
      return;
    }
    final recoveryOperation = ++_operationVersion;
    _activeRunId = null;
    _activeStreamGeneration = null;
    _audioCoordinator.release(_audioLease);
    _audioLease = null;
    _logger.error(
      'Metronome engine runtime failure code=${event.code} '
      'streamGeneration=${event.streamGeneration}',
      event.message,
    );
    _debug(
      'Metronome recovery requested operation=$recoveryOperation '
      'reason=${MetronomeStopReason.nativeError.name}',
    );
    state = state.copyWith(
      currentBeat: 0,
      isRunning: false,
      isInitializing: _runRequested,
      clearFailure: true,
    );
    final cleanup = _runLifecycleCleanup(
      () => _stopAndDisposeAfterFailure(MetronomeStopReason.nativeError),
      reason: MetronomeStopReason.nativeError,
    );
    unawaited(
      cleanup.whenComplete(() => _restartAfterRecovery(recoveryOperation)),
    );
  }

  void _runEngineUpdate(Future<void> update, String description) {
    unawaited(
      update.catchError((Object error, StackTrace stackTrace) {
        _logger.error('Could not $description', error, stackTrace);
      }),
    );
  }

  Future<void> _restartAfterRecovery(int recoveryOperation) async {
    if (!_isCurrent(recoveryOperation) || !_runRequested) return;
    state = state.copyWith(isInitializing: false);
    await _startEngine();
  }

  Future<void> _handleStartFailure(
    int operation,
    Object error,
    StackTrace stackTrace,
  ) async {
    _logger.error('Could not start metronome engine', error, stackTrace);
    _activeRunId = null;
    _activeStreamGeneration = null;
    _audioCoordinator.release(_audioLease);
    _audioLease = null;
    try {
      await _engine.stop();
    } on Object catch (stopError, stopStackTrace) {
      _logger.error(
        'Could not stop metronome after start failure',
        stopError,
        stopStackTrace,
      );
    }
    await _disposeEngineSafely();
    if (_isCurrent(operation)) {
      _debug(
        'Metronome transition running=false operation=$operation '
        'reason=${MetronomeStopReason.initializationCleanup.name}',
      );
      state = state.copyWith(
        currentBeat: 0,
        isRunning: false,
        isInitializing: false,
        failure: MetronomeFailure.audioUnavailable,
      );
    }
    _resetDiagnostics();
  }

  Future<void> _stopAndDisposeAfterFailure(MetronomeStopReason reason) async {
    _debug('Metronome failure cleanup reason=${reason.name}');
    try {
      await _engine.stop();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Could not stop failed metronome engine',
        error,
        stackTrace,
      );
    }
    await _disposeEngineSafely();
    _resetDiagnostics();
  }

  Future<void> _disposeEngineSafely() async {
    try {
      await _engine.dispose();
    } on Object catch (error, stackTrace) {
      _logger.error('Could not dispose metronome engine', error, stackTrace);
    }
  }

  Future<void> _runLifecycleCleanup(
    Future<void> Function() cleanup, {
    required MetronomeStopReason reason,
  }) {
    final existing = _releaseFuture;
    if (existing != null) {
      _debug(
        'Metronome cleanup joined operation=$_operationVersion '
        'reason=${reason.name}',
      );
      return existing;
    }
    final future = cleanup();
    _releaseFuture = future;
    return future.whenComplete(() {
      if (identical(_releaseFuture, future)) {
        _releaseFuture = null;
      }
    });
  }

  Future<void> _configureInitializedEngine(MetronomeConfig config) async {
    await _engine.setBpm(config.bpm);
    await _engine.setTimeSignature(config.timeSignature);
    await _engine.setAccentEnabled(config.accentEnabled);
    await _engine.setVolume(config.volume);
  }

  bool _isCurrent(int operation) =>
      operation == _operationVersion && _acceptRuntimeEvents;

  void _resetDiagnostics() {
    _callbackClock = null;
    _lastCallbackTime = null;
    _lastSequence = 0;
    _callbackCount = 0;
    _missedCallbackCount = 0;
  }

  void _debug(String message) {
    if (kDebugMode) _logger.debug(message);
  }

  String _milliseconds(Duration? duration) {
    if (duration == null) return 'n/a';
    return (duration.inMicroseconds / Duration.microsecondsPerMillisecond)
        .toStringAsFixed(3);
  }

  Future<void> _persist() async {
    try {
      await _preferences.save(state.config);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save metronome preferences', error, stackTrace);
    }
  }
}
