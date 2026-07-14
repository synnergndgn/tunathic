import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';
import 'package:tunathic/features/tuner_audio/domain/pcm16_converter.dart';

void main() {
  const format = AudioStreamFormat(
    sampleRate: 48000,
    channelCount: 1,
    encoding: AudioSampleEncoding.signedPcm16LittleEndian,
    isReportedByBackend: false,
  );

  test('converts signed PCM16 little-endian values to normalized samples', () {
    final bytes = Uint8List.fromList([
      0x00, 0x00, // zero
      0x00, 0x40, // 16384
      0x00, 0xC0, // -16384
      0xFF, 0x7F, // 32767
      0x00, 0x80, // -32768
    ]);

    final frame = Pcm16LittleEndianConverter.convert(
      bytes,
      format: format,
      arrivalTime: const Duration(milliseconds: 12),
      sequenceNumber: 7,
    );

    expect(frame.samples[0], 0);
    expect(frame.samples[1], 0.5);
    expect(frame.samples[2], -0.5);
    expect(frame.samples[3], closeTo(32767 / 32768, 0.000001));
    expect(frame.samples[4], -1);
    expect(frame.rawSampleCount, 5);
    expect(frame.sequenceNumber, 7);
    expect(frame.arrivalTime, const Duration(milliseconds: 12));
  });

  test('rejects an odd-length PCM16 byte buffer', () {
    expect(
      () => Pcm16LittleEndianConverter.convert(
        Uint8List.fromList([0, 1, 2]),
        format: format,
        arrivalTime: Duration.zero,
        sequenceNumber: 0,
      ),
      throwsA(
        isA<MalformedPcm16FrameException>().having(
          (error) => error.byteLength,
          'byte length',
          3,
        ),
      ),
    );
  });
}
