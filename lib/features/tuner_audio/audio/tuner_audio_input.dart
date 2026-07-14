import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';

enum MicrophonePermissionResult { granted, denied }

final class UnsupportedAudioConfigurationException implements Exception {
  const UnsupportedAudioConfigurationException();
}

final class AudioCaptureSession {
  const AudioCaptureSession({
    required this.frames,
    required this.configurationChanges,
    this.reportedFormat,
  });

  final Stream<AudioFrame> frames;
  final Stream<AudioStreamFormat> configurationChanges;
  final AudioStreamFormat? reportedFormat;
}

abstract interface class TunerAudioInput {
  Future<MicrophonePermissionResult> checkPermission();

  Future<MicrophonePermissionResult> requestPermission();

  Future<AudioCaptureSession> start(AudioInputConfiguration configuration);

  Future<void> stop();

  Future<void> dispose();
}
