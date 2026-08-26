import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tunathic/features/metronome/audio/metronome_engine.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

final class NativeMetronomeEngine implements MetronomeEngine {
  NativeMetronomeEngine({
    this._methodChannel = const MethodChannel(_methodChannelName),
    this._eventChannel = const EventChannel(_eventChannelName),
    AssetBundle? assetBundle,
  }) : _assetBundle = assetBundle ?? rootBundle;

  static const _methodChannelName =
      'dev.gundev.tunathic/metronome_engine/methods';
  static const _eventChannelName =
      'dev.gundev.tunathic/metronome_engine/events';
  static const _regularAsset = 'assets/audio/metronome_regular.wav';
  static const _accentAsset = 'assets/audio/metronome_accent.wav';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final AssetBundle _assetBundle;
  final StreamController<MetronomeEngineEvent> _events =
      StreamController<MetronomeEngineEvent>.broadcast(sync: true);

  StreamSubscription<Object?>? _nativeEvents;
  bool _isInitialized = false;
  bool _isRunning = false;
  int _currentRunId = 0;
  int _currentStreamGeneration = 0;

  @override
  String get implementationName => 'Oboe native audio callback';

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isRunning => _isRunning;

  @override
  Stream<MetronomeEngineEvent> get events => _events.stream;

  @override
  Future<MetronomeEngineInfo> initialize(MetronomeConfig config) async {
    if (_isInitialized) return _readInfo();
    _listenToNativeEvents();

    final regular = await _loadAsset(_regularAsset);
    final accent = await _loadAsset(_accentAsset);
    final result = await _methodChannel.invokeMapMethod<String, Object?>(
      'initialize',
      <String, Object?>{
        'regularWav': regular,
        'accentWav': accent,
        ..._configurationArguments(config),
      },
    );
    if (result == null) {
      throw StateError('Native metronome returned no initialization data');
    }
    _isInitialized = true;
    return _parseInfo(result);
  }

  @override
  Future<MetronomeEngineRun> start() async {
    _requireInitialized();
    final result = await _methodChannel.invokeMapMethod<String, Object?>(
      'start',
    );
    if (result == null) {
      throw StateError('Native metronome returned no start result');
    }
    final runId = _asInt(result['runId']);
    final streamGeneration = _asInt(result['streamGeneration']);
    if (runId <= 0 || streamGeneration <= 0) {
      throw StateError('Native metronome returned an invalid run identity');
    }
    _currentRunId = runId;
    _currentStreamGeneration = streamGeneration;
    _isRunning = true;
    return MetronomeEngineRun(runId: runId, streamGeneration: streamGeneration);
  }

  @override
  Future<MetronomeStopReport> stop() async {
    if (!_isInitialized) {
      _isRunning = false;
      return const MetronomeStopReport();
    }
    final result = await _methodChannel.invokeMapMethod<String, Object?>(
      'stop',
    );
    _isRunning = false;
    if (result == null) return const MetronomeStopReport();
    return MetronomeStopReport(
      framesRendered: _asInt(result['framesRendered']),
      xRunCount: _asInt(result['xRunCount']),
    );
  }

  @override
  Future<void> setBpm(int bpm) async {
    _requireInitialized();
    await _methodChannel.invokeMethod<void>('setBpm', <String, Object?>{
      'bpm': bpm,
    });
  }

  @override
  Future<void> setTimeSignature(MetronomeTimeSignature timeSignature) async {
    _requireInitialized();
    await _methodChannel
        .invokeMethod<void>('setTimeSignature', <String, Object?>{
          'beatsPerMeasure': timeSignature.beatsPerMeasure,
          'beatUnit': timeSignature.beatUnit,
        });
  }

  @override
  Future<void> setVolume(double volume) async {
    _requireInitialized();
    await _methodChannel.invokeMethod<void>('setVolume', <String, Object?>{
      'volume': volume.clamp(0.0, 1.0),
    });
  }

  @override
  Future<void> setAccentEnabled(bool enabled) async {
    _requireInitialized();
    await _methodChannel.invokeMethod<void>(
      'setAccentEnabled',
      <String, Object?>{'enabled': enabled},
    );
  }

  @override
  Future<void> dispose() async {
    _isRunning = false;
    _currentRunId = 0;
    _currentStreamGeneration = 0;
    await _methodChannel.invokeMethod<void>('dispose');
    _isInitialized = false;
    await _nativeEvents?.cancel();
    _nativeEvents = null;
  }

  Future<MetronomeEngineInfo> _readInfo() async {
    final result = await _methodChannel.invokeMapMethod<String, Object?>(
      'getInfo',
    );
    if (result == null) {
      throw StateError('Native metronome returned no engine information');
    }
    return _parseInfo(result);
  }

  void _listenToNativeEvents() {
    if (_nativeEvents != null) return;
    _nativeEvents = _eventChannel.receiveBroadcastStream().listen(
      _handleNativeEvent,
      onError: (Object error, StackTrace stackTrace) {
        _events.add(
          MetronomeEngineFailure(
            runId: _currentRunId,
            streamGeneration: _currentStreamGeneration,
            code: 'event_channel',
            message: error.toString(),
          ),
        );
      },
    );
  }

  void _handleNativeEvent(Object? rawEvent) {
    if (rawEvent is! Map<Object?, Object?>) return;
    final type = rawEvent['type'];
    final runId = _asInt(rawEvent['runId']);
    final streamGeneration = _asInt(rawEvent['streamGeneration']);
    if (streamGeneration != _currentStreamGeneration) return;
    switch (type) {
      case 'beat':
        _events.add(
          MetronomeEngineBeat(
            runId: runId,
            streamGeneration: streamGeneration,
            sequence: _asInt(rawEvent['sequence']),
            beatNumber: _asInt(rawEvent['beatNumber']),
            isAccented: rawEvent['accented'] == true,
            audioFramePosition: _asInt(rawEvent['audioFramePosition']),
            callbackTimeNanos: _asInt(rawEvent['callbackTimeNanos']),
          ),
        );
      case 'error':
        if (runId == _currentRunId) _isRunning = false;
        _events.add(
          MetronomeEngineFailure(
            runId: runId,
            streamGeneration: streamGeneration,
            code: rawEvent['code'] as String? ?? 'native_error',
            message: rawEvent['message'] as String? ?? 'Unknown engine error',
          ),
        );
    }
  }

  Future<Uint8List> _loadAsset(String path) async {
    final data = await _assetBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Map<String, Object?> _configurationArguments(MetronomeConfig config) =>
      <String, Object?>{
        'bpm': config.bpm,
        'beatsPerMeasure': config.timeSignature.beatsPerMeasure,
        'beatUnit': config.timeSignature.beatUnit,
        'volume': config.volume,
        'accentEnabled': config.accentEnabled,
      };

  MetronomeEngineInfo _parseInfo(Map<String, Object?> result) {
    final info = MetronomeEngineInfo(
      implementation: result['implementation'] as String? ?? implementationName,
      engineInstanceId: _asInt(result['engineInstanceId']),
      streamGeneration: _asInt(result['streamGeneration']),
      lifecycleState: result['lifecycleState'] as String? ?? 'unknown',
      audioApi: result['audioApi'] as String? ?? 'unknown',
      sampleRate: _asInt(result['sampleRate']),
      framesPerBurst: _asInt(result['framesPerBurst']),
      bufferSizeFrames: _asInt(result['bufferSizeFrames']),
    );
    _currentStreamGeneration = info.streamGeneration;
    return info;
  }

  void _requireInitialized() {
    if (!_isInitialized) {
      throw StateError('Metronome engine is not initialized');
    }
  }

  static int _asInt(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    _ => 0,
  };
}
