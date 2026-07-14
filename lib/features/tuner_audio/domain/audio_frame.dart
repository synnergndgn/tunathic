import 'dart:typed_data';

import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';

final class AudioFrame {
  const AudioFrame({
    required this.samples,
    required this.format,
    required this.arrivalTime,
    required this.sequenceNumber,
  });

  /// A frame-owned buffer that is never reused by the capture adapter.
  final Float32List samples;
  final AudioStreamFormat format;
  final Duration arrivalTime;
  final int sequenceNumber;

  int get rawSampleCount => samples.length;
}
