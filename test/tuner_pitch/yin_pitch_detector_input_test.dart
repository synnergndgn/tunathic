import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';
import 'package:tunathic/features/tuner_pitch/dsp/yin_pitch_detector.dart';

void main() {
  late YinPitchDetector detector;

  setUp(() => detector = YinPitchDetector());

  test('returns typed no-pitch for an empty frame', () {
    final result = detector.detect(Float32List(0), sampleRate: 48000);

    expect(result.isDetected, isFalse);
    expect(result.noPitchReason, NoPitchReason.emptyFrame);
  });

  test('returns typed no-pitch for an invalid sample rate', () {
    final result = detector.detect(Float32List(4096), sampleRate: 0);

    expect(result.noPitchReason, NoPitchReason.invalidSampleRate);
  });

  test('rejects an undersized frame without throwing', () {
    final result = detector.detect(Float32List(2048), sampleRate: 48000);

    expect(result.noPitchReason, NoPitchReason.insufficientSamples);
  });

  for (final invalidValue in [double.nan, double.infinity, -double.infinity]) {
    test('rejects non-finite sample $invalidValue', () {
      final samples = Float32List(4096)..[100] = invalidValue;
      final result = detector.detect(samples, sampleRate: 48000);

      expect(result.noPitchReason, NoPitchReason.invalidSamples);
    });
  }

  test('rejects samples outside the normalized input contract', () {
    final samples = Float32List(4096)..[100] = 1.2;
    final result = detector.detect(samples, sampleRate: 48000);

    expect(result.noPitchReason, NoPitchReason.invalidSamples);
  });

  test('rejects a configured range beyond the sample-rate Nyquist limit', () {
    final result = detector.detect(Float32List(4096), sampleRate: 2000);

    expect(result.noPitchReason, NoPitchReason.unsupportedRange);
  });
}
