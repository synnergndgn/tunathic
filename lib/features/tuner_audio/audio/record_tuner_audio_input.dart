import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:tunathic/features/tuner_audio/audio/tuner_audio_input.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';
import 'package:tunathic/features/tuner_audio/domain/pcm16_converter.dart';

final class RecordTunerAudioInput implements TunerAudioInput {
  AudioRecorder _recorder = AudioRecorder();
  StreamController<AudioStreamFormat>? _configurationController;
  bool _isCapturing = false;
  bool _isDisposed = false;

  @override
  Future<MicrophonePermissionResult> checkPermission() async {
    _ensureAvailable();
    final granted = await _recorder.hasPermission(request: false);
    return granted
        ? MicrophonePermissionResult.granted
        : MicrophonePermissionResult.denied;
  }

  @override
  Future<MicrophonePermissionResult> requestPermission() async {
    _ensureAvailable();
    final granted = await _recorder.hasPermission();
    return granted
        ? MicrophonePermissionResult.granted
        : MicrophonePermissionResult.denied;
  }

  @override
  Future<AudioCaptureSession> start(
    AudioInputConfiguration configuration,
  ) async {
    _ensureAvailable();
    if (_isCapturing) throw StateError('Audio capture is already active');
    if (!await _recorder.isEncoderSupported(AudioEncoder.pcm16bits)) {
      throw const UnsupportedAudioConfigurationException();
    }

    var decodingFormat = configuration.requestedFormat;
    AudioStreamFormat? reportedFormat;
    final configurationController =
        StreamController<AudioStreamFormat>.broadcast();
    _configurationController = configurationController;

    try {
      await _recorder.setOnConfigChanged((adjustedConfiguration) {
        final adjustedFormat = AudioStreamFormat(
          sampleRate: adjustedConfiguration.sampleRate,
          channelCount: adjustedConfiguration.numChannels,
          encoding: AudioSampleEncoding.signedPcm16LittleEndian,
          isReportedByBackend: true,
        );
        decodingFormat = adjustedFormat;
        reportedFormat = adjustedFormat;
        if (!configurationController.isClosed) {
          configurationController.add(adjustedFormat);
        }
      });

      final byteStream = await _recorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: configuration.sampleRate,
          numChannels: configuration.channelCount,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
          androidConfig: const AndroidRecordConfig(
            manageBluetooth: false,
            audioSource: AndroidAudioSource.defaultSource,
          ),
        ),
      );
      _isCapturing = true;

      var sequenceNumber = 0;
      final arrivalClock = Stopwatch()..start();
      final frameStream = byteStream.transform(
        StreamTransformer<Uint8List, AudioFrame>.fromHandlers(
          handleData: (bytes, sink) {
            final currentSequence = sequenceNumber++;
            try {
              sink.add(
                Pcm16LittleEndianConverter.convert(
                  bytes,
                  format: decodingFormat,
                  arrivalTime: arrivalClock.elapsed,
                  sequenceNumber: currentSequence,
                ),
              );
            } on Object catch (error, stackTrace) {
              sink.addError(error, stackTrace);
            }
          },
        ),
      );

      return AudioCaptureSession(
        frames: frameStream,
        configurationChanges: configurationController.stream,
        reportedFormat: reportedFormat,
      );
    } on Object catch (error, stackTrace) {
      try {
        await _recorder.stop();
      } on Object {
        // Preserve the start failure; stop is best-effort for a partial start.
      }
      try {
        await _unregisterConfigurationCallback();
      } on Object {
        // Preserve the original failure reported by start/configuration.
      }
      if (!configurationController.isClosed) {
        await configurationController.close();
      }
      if (identical(_configurationController, configurationController)) {
        _configurationController = null;
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<void> stop() async {
    if (!_isCapturing) return;
    _isCapturing = false;
    Object? stopError;
    StackTrace? stopStackTrace;
    try {
      await _recorder.stop();
    } on Object catch (error, stackTrace) {
      stopError = error;
      stopStackTrace = stackTrace;
      await _replaceRecorderAfterFailure();
    } finally {
      await _unregisterConfigurationCallback();
      final controller = _configurationController;
      _configurationController = null;
      await controller?.close();
    }
    if (stopError != null) {
      Error.throwWithStackTrace(stopError, stopStackTrace!);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    try {
      await stop();
    } finally {
      _isDisposed = true;
      await _recorder.dispose();
    }
  }

  Future<void> _replaceRecorderAfterFailure() async {
    try {
      await _recorder.dispose();
    } finally {
      if (!_isDisposed) _recorder = AudioRecorder();
    }
  }

  Future<void> _unregisterConfigurationCallback() async {
    if (_isDisposed) return;
    await _recorder.setOnConfigChanged(null);
  }

  void _ensureAvailable() {
    if (_isDisposed) throw StateError('Audio input has been disposed');
  }
}
