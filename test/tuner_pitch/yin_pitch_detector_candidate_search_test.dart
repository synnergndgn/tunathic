import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/dsp/yin_pitch_detector.dart';

import '../support/synthetic_pitch_signal.dart';

void main() {
  const sampleRate = 48000;
  const frameLength = 4096;
  late YinPitchDetector detector;

  setUp(() => detector = YinPitchDetector());

  test('finds 440 Hz beneath a stronger unsupported fourth harmonic', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 440,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.18, 4: 0.75},
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result.frequencyHz, 440);
  });

  test('finds 220 Hz beneath strong harmonics above the upper limit', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 220,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.18, 6: 0.48, 8: 0.28},
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result.frequencyHz, 220);
  });

  test('finds a low guitar fundamental beneath a decaying high transient', () {
    final fundamental = SyntheticPitchSignal.harmonic(
      sampleRate: sampleRate,
      fundamentalHz: 82.41,
      length: frameLength,
      harmonicAmplitudes: const {1: 0.45, 2: 0.12},
    );
    final highTone = SyntheticPitchSignal.sine(
      sampleRate: sampleRate,
      frequencyHz: 3000,
      length: frameLength,
      amplitude: 0.4,
    );
    final transient = Float32List(frameLength);
    const transientLength = 600;
    for (var index = 0; index < transientLength; index++) {
      transient[index] = highTone[index] * (1 - index / transientLength);
    }

    final result = detector.detect(
      SyntheticPitchSignal.combine([fundamental, transient]),
      sampleRate: sampleRate,
    );

    _expectFrequency(result.frequencyHz, 82.41, maximumRelativeError: 0.007);
  });

  test('rejects a lone unsupported high-frequency tone', () {
    final result = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: 1760,
        length: frameLength,
      ),
      sampleRate: sampleRate,
    );

    expect(result.isDetected, isFalse);
  });

  test('rejects an unsupported high tone without a valid fundamental', () {
    final result = detector.detect(
      SyntheticPitchSignal.combine([
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: 1760,
          length: frameLength,
          amplitude: 0.55,
        ),
        SyntheticPitchSignal.whiteNoise(
          length: frameLength,
          amplitude: 0.18,
          seed: 1760,
        ),
      ]),
      sampleRate: sampleRate,
    );

    expect(result.isDetected, isFalse);
  });

  for (final frequency in [40.0, 1200.0]) {
    test('accepts the exact $frequency Hz boundary', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: frequency,
          length: frequency == 40 ? 8192 : frameLength,
        ),
        sampleRate: sampleRate,
      );

      expect(
        result.isDetected,
        isTrue,
        reason:
            'reason=${result.noPitchReason?.name}, confidence=${result.confidence}',
      );
      _expectFrequency(result.frequencyHz, frequency);
      if (frequency == 40) {
        final rawFrequency = sampleRate / result.periodSamples!;
        expect(rawFrequency, greaterThanOrEqualTo(40 * (1 - 1e-6)));
      }
    });
  }

  for (final frequency in [1201.0, 1760.0]) {
    test('rejects unsupported high frequency at $frequency Hz', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: frequency,
          length: frameLength,
        ),
        sampleRate: sampleRate,
      );

      expect(result.isDetected, isFalse);
    });
  }

  for (final frequency in [39.0, 39.5, 39.75, 39.9, 39.99, 39.999, 39.9999]) {
    test(
      'rejects frequency just below the lower boundary at $frequency Hz',
      () {
        final result = detector.detect(
          SyntheticPitchSignal.sine(
            sampleRate: sampleRate,
            frequencyHz: frequency,
            length: 8192,
          ),
          sampleRate: sampleRate,
        );

        expect(result.isDetected, isFalse);
      },
    );
  }

  for (final frequency in [40.0, 41.2, 44.0]) {
    test('finds $frequency Hz beneath strong second and third harmonics', () {
      final result = detector.detect(
        SyntheticPitchSignal.harmonic(
          sampleRate: sampleRate,
          fundamentalHz: frequency,
          length: 8192,
          harmonicAmplitudes: const {1: 0.12, 2: 0.52, 3: 0.28},
        ),
        sampleRate: sampleRate,
      );

      expect(
        result.isDetected,
        isTrue,
        reason:
            'reason=${result.noPitchReason?.name}, confidence=${result.confidence}',
      );
      _expectFrequency(
        result.frequencyHz,
        frequency,
        maximumRelativeError: 0.007,
      );
    });
  }
}

void _expectFrequency(
  double? actual,
  double expected, {
  double maximumRelativeError = 0.005,
}) {
  expect(actual, isNotNull);
  expect((actual! - expected).abs() / expected, lessThan(maximumRelativeError));
}
