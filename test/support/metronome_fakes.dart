import 'dart:async';

import 'package:tunathic/features/metronome/audio/metronome_engine.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

final class FakeMetronomeEngine implements MetronomeEngine {
  final StreamController<MetronomeEngineEvent> _events =
      StreamController<MetronomeEngineEvent>.broadcast(sync: true);

  bool failInitialization = false;
  bool failStart = false;
  bool failStop = false;
  bool failUpdates = false;
  Completer<void>? pendingInitialization;
  Completer<void>? pendingStop;
  Completer<void>? pendingDispose;
  int initializeCount = 0;
  int startCount = 0;
  int stopCount = 0;
  int disposeCount = 0;
  int _nextRunId = 0;
  int _streamGeneration = 0;
  int _nextSequence = 0;
  int currentRunId = 0;
  int get currentStreamGeneration => _streamGeneration;
  final List<MetronomeConfig> initializedConfigs = [];
  final List<int> bpms = [];
  final List<MetronomeTimeSignature> timeSignatures = [];
  final List<double> volumes = [];
  final List<bool> accents = [];
  MetronomeStopReport stopReport = const MetronomeStopReport();

  @override
  String get implementationName => 'fake engine';

  @override
  bool isInitialized = false;

  @override
  bool isRunning = false;

  @override
  Stream<MetronomeEngineEvent> get events => _events.stream;

  @override
  Future<MetronomeEngineInfo> initialize(MetronomeConfig config) async {
    initializeCount++;
    initializedConfigs.add(config);
    await pendingInitialization?.future;
    if (failInitialization) {
      throw StateError('Engine initialization failed');
    }
    isInitialized = true;
    _streamGeneration++;
    return MetronomeEngineInfo(
      implementation: 'Fake metronome engine',
      engineInstanceId: 1,
      streamGeneration: _streamGeneration,
      lifecycleState: 'initialized',
      audioApi: 'fake',
      sampleRate: 48000,
      framesPerBurst: 192,
      bufferSizeFrames: 384,
    );
  }

  @override
  Future<MetronomeEngineRun> start() async {
    startCount++;
    if (failStart) throw StateError('Engine start failed');
    if (!isInitialized) throw StateError('Engine is not initialized');
    isRunning = true;
    currentRunId = ++_nextRunId;
    _nextSequence = 0;
    return MetronomeEngineRun(
      runId: currentRunId,
      streamGeneration: _streamGeneration,
    );
  }

  @override
  Future<MetronomeStopReport> stop() async {
    stopCount++;
    await pendingStop?.future;
    if (failStop) throw StateError('Engine stop failed');
    isRunning = false;
    return stopReport;
  }

  @override
  Future<void> setBpm(int bpm) async {
    _throwIfUpdateFails();
    bpms.add(bpm);
  }

  @override
  Future<void> setTimeSignature(MetronomeTimeSignature timeSignature) async {
    _throwIfUpdateFails();
    timeSignatures.add(timeSignature);
  }

  @override
  Future<void> setVolume(double volume) async {
    _throwIfUpdateFails();
    volumes.add(volume);
  }

  @override
  Future<void> setAccentEnabled(bool enabled) async {
    _throwIfUpdateFails();
    accents.add(enabled);
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    await pendingDispose?.future;
    isRunning = false;
    isInitialized = false;
  }

  void emitBeat({
    int? runId,
    int? streamGeneration,
    int? sequence,
    required int beatNumber,
    bool accented = false,
  }) {
    _events.add(
      MetronomeEngineBeat(
        runId: runId ?? currentRunId,
        streamGeneration: streamGeneration ?? _streamGeneration,
        sequence: sequence ?? ++_nextSequence,
        beatNumber: beatNumber,
        isAccented: accented,
        audioFramePosition: (sequence ?? _nextSequence) * 24000,
        callbackTimeNanos: (sequence ?? _nextSequence) * 500000000,
      ),
    );
  }

  void emitFailure({
    int? runId,
    int? streamGeneration,
    String code = 'fake_runtime',
    String message = 'Fake runtime failure',
  }) {
    final eventRunId = runId ?? currentRunId;
    final eventStreamGeneration = streamGeneration ?? _streamGeneration;
    if (eventRunId == currentRunId &&
        eventStreamGeneration == _streamGeneration) {
      isRunning = false;
    }
    _events.add(
      MetronomeEngineFailure(
        runId: eventRunId,
        streamGeneration: eventStreamGeneration,
        code: code,
        message: message,
      ),
    );
  }

  void _throwIfUpdateFails() {
    if (failUpdates) throw StateError('Engine update failed');
  }
}
