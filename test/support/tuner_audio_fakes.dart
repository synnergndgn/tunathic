import 'dart:async';
import 'dart:typed_data';

import 'package:tunathic/features/tuner_audio/audio/tuner_audio_input.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';

final class FakeTunerAudioInput implements TunerAudioInput {
  MicrophonePermissionResult permission = MicrophonePermissionResult.granted;
  Object? startError;
  Object? stopError;
  Object? disposeError;
  Completer<void>? permissionGate;
  Completer<void>? startGate;
  int checkPermissionCount = 0;
  int requestPermissionCount = 0;
  int startCount = 0;
  int stopCount = 0;
  int disposeCount = 0;
  AudioInputConfiguration? lastConfiguration;
  AudioStreamFormat? initialReportedFormat;

  StreamController<AudioFrame>? _frames;
  StreamController<AudioStreamFormat>? _formats;

  @override
  Future<MicrophonePermissionResult> checkPermission() async {
    checkPermissionCount++;
    return permission;
  }

  @override
  Future<MicrophonePermissionResult> requestPermission() async {
    requestPermissionCount++;
    await permissionGate?.future;
    return permission;
  }

  @override
  Future<AudioCaptureSession> start(
    AudioInputConfiguration configuration,
  ) async {
    startCount++;
    lastConfiguration = configuration;
    await startGate?.future;
    final error = startError;
    if (error != null) throw error;
    _frames = StreamController<AudioFrame>.broadcast();
    _formats = StreamController<AudioStreamFormat>.broadcast();
    return AudioCaptureSession(
      frames: _frames!.stream,
      configurationChanges: _formats!.stream,
      reportedFormat: initialReportedFormat,
    );
  }

  @override
  Future<void> stop() async {
    stopCount++;
    final error = stopError;
    if (error != null) throw error;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    final frames = _frames;
    final formats = _formats;
    _frames = null;
    _formats = null;
    if (frames != null && !frames.isClosed) unawaited(frames.close());
    if (formats != null && !formats.isClosed) unawaited(formats.close());
    final error = disposeError;
    if (error != null) throw error;
  }

  void emitSamples(
    List<double> samples, {
    Duration arrivalTime = Duration.zero,
    int sequenceNumber = 0,
    AudioStreamFormat format = const AudioStreamFormat(
      sampleRate: 48000,
      channelCount: 1,
      encoding: AudioSampleEncoding.signedPcm16LittleEndian,
      isReportedByBackend: false,
    ),
  }) {
    _frames?.add(
      AudioFrame(
        samples: Float32List.fromList(samples),
        format: format,
        arrivalTime: arrivalTime,
        sequenceNumber: sequenceNumber,
      ),
    );
  }

  void emitFrameError(Object error) =>
      _frames?.addError(error, StackTrace.current);

  void emitFormat(AudioStreamFormat format) => _formats?.add(format);

  Future<void> closeFrames() => _frames?.close() ?? Future.value();
}
