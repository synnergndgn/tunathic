import 'package:tunathic/features/metronome/domain/metronome_config.dart';

sealed class MetronomeEngineEvent {
  const MetronomeEngineEvent({
    required this.runId,
    required this.streamGeneration,
  });

  final int runId;
  final int streamGeneration;
}

final class MetronomeEngineBeat extends MetronomeEngineEvent {
  const MetronomeEngineBeat({
    required super.runId,
    required super.streamGeneration,
    required this.sequence,
    required this.beatNumber,
    required this.isAccented,
    required this.audioFramePosition,
    required this.callbackTimeNanos,
  });

  final int sequence;
  final int beatNumber;
  final bool isAccented;

  /// The output frame at which the engine rendered the click transient.
  final int audioFramePosition;

  /// Native monotonic time when the visual callback left the engine.
  ///
  /// This is diagnostic callback timing, not an acoustic timestamp.
  final int callbackTimeNanos;
}

final class MetronomeEngineFailure extends MetronomeEngineEvent {
  const MetronomeEngineFailure({
    required super.runId,
    required super.streamGeneration,
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

final class MetronomeEngineInfo {
  const MetronomeEngineInfo({
    required this.implementation,
    required this.engineInstanceId,
    required this.streamGeneration,
    required this.lifecycleState,
    required this.audioApi,
    required this.sampleRate,
    required this.framesPerBurst,
    required this.bufferSizeFrames,
  });

  final String implementation;
  final int engineInstanceId;
  final int streamGeneration;
  final String lifecycleState;
  final String audioApi;
  final int sampleRate;
  final int framesPerBurst;
  final int bufferSizeFrames;
}

final class MetronomeEngineRun {
  const MetronomeEngineRun({
    required this.runId,
    required this.streamGeneration,
  });

  final int runId;
  final int streamGeneration;
}

final class MetronomeStopReport {
  const MetronomeStopReport({this.framesRendered = 0, this.xRunCount = 0});

  final int framesRendered;

  /// Native buffer underruns/overruns reported by the audio backend.
  final int xRunCount;
}

abstract interface class MetronomeEngine {
  String get implementationName;

  bool get isInitialized;

  bool get isRunning;

  Stream<MetronomeEngineEvent> get events;

  Future<MetronomeEngineInfo> initialize(MetronomeConfig config);

  Future<MetronomeEngineRun> start();

  Future<MetronomeStopReport> stop();

  Future<void> setBpm(int bpm);

  Future<void> setTimeSignature(MetronomeTimeSignature timeSignature);

  Future<void> setVolume(double volume);

  Future<void> setAccentEnabled(bool enabled);

  Future<void> dispose();
}
