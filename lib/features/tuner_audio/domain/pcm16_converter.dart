import 'dart:typed_data';

import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';

final class MalformedPcm16FrameException implements Exception {
  const MalformedPcm16FrameException(this.byteLength);

  final int byteLength;

  @override
  String toString() => 'PCM16 byte length must be even; received $byteLength';
}

abstract final class Pcm16LittleEndianConverter {
  static AudioFrame convert(
    Uint8List bytes, {
    required AudioStreamFormat format,
    required Duration arrivalTime,
    required int sequenceNumber,
  }) {
    if (bytes.length.isOdd) {
      throw MalformedPcm16FrameException(bytes.length);
    }

    final byteData = ByteData.sublistView(bytes);
    final samples = Float32List(bytes.length ~/ 2);
    for (var sampleIndex = 0; sampleIndex < samples.length; sampleIndex++) {
      final byteOffset = sampleIndex * 2;
      samples[sampleIndex] =
          byteData.getInt16(byteOffset, Endian.little) / 32768.0;
    }

    return AudioFrame(
      samples: samples,
      format: format,
      arrivalTime: arrivalTime,
      sequenceNumber: sequenceNumber,
    );
  }
}
