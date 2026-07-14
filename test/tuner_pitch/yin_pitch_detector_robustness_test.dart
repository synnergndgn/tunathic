import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';
import 'package:tunathic/features/tuner_pitch/dsp/yin_pitch_detector.dart';

import '../support/synthetic_pitch_signal.dart';

void main() {
  const sampleRate = 48000;
  const frameLength = 4096;
  late YinPitchDetector detector;

  setUp(() => detector = YinPitchDetector());

  test('rejects silence', () {
    final result = detector.detect(
      SyntheticPitchSignal.silence(frameLength),
      sampleRate: sampleRate,
    );

    expect(result.isDetected, isFalse);
    expect(result.noPitchReason, NoPitchReason.silence);
    expect(result.confidence, 0);
  });

  test('rejects near-silence and very-low-amplitude input', () {
    for (final amplitude in [0.0001, 0.001]) {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: 110,
          length: frameLength,
          amplitude: amplitude,
        ),
        sampleRate: sampleRate,
      );
      expect(result.noPitchReason, NoPitchReason.silence);
    }
  });

  test('detects a quiet but usable periodic signal', () {
    final result = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: 110,
        length: frameLength,
        amplitude: 0.01,
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 110);
  });

  test('handles clipping-like normalized amplitude', () {
    final overdriven = SyntheticPitchSignal.sine(
      sampleRate: sampleRate,
      frequencyHz: 329.63,
      length: frameLength,
      amplitude: 1.4,
    );
    final clipped = Float32List.fromList(
      overdriven
          .map((sample) => sample.clamp(-1, 1).toDouble())
          .toList(growable: false),
    );
    final result = detector.detect(clipped, sampleRate: sampleRate);

    _expectFrequency(result, 329.63);
  });

  test('removes DC offset through centered level and difference analysis', () {
    final result = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: 146.83,
        length: frameLength,
        amplitude: 0.45,
        dcOffset: 0.35,
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 146.83);
  });

  test('rejects deterministic white noise', () {
    final result = detector.detect(
      SyntheticPitchSignal.whiteNoise(
        length: frameLength,
        amplitude: 0.7,
        seed: 742,
      ),
      sampleRate: sampleRate,
    );

    expect(result.isDetected, isFalse);
    expect(result.noPitchReason, NoPitchReason.lowConfidence);
  });

  test('prefers no pitch for a very low signal-to-noise ratio', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 110,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.06},
        noiseAmplitude: 0.65,
        noiseSeed: 91,
      ),
      sampleRate: sampleRate,
    );

    expect(result.isDetected, isFalse);
  });

  test('detects a moderate signal-to-noise ratio', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 110,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.55},
        noiseAmplitude: 0.12,
        noiseSeed: 91,
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 110, maximumRelativeError: 0.007);
  });

  test('resists a dominant second harmonic', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 82.41,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.18, 2: 0.62, 3: 0.12},
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 82.41);
  });

  test('resists strong third-harmonic content', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 110,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.18, 2: 0.08, 3: 0.65},
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 110);
  });

  test('finds a weak fundamental under stronger harmonics', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 61.74,
        length: frameLength,
        harmonicAmplitudes: const {1: 0.06, 2: 0.52, 3: 0.32},
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 61.74);
  });

  test('finds a missing fundamental from second and third harmonics', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 110,
        length: frameLength,
        harmonicAmplitudes: const {2: 0.5, 3: 0.35, 4: 0.1},
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 110);
  });

  test('handles a bass-like harmonic spectrum', () {
    final result = detector.detect(
      SyntheticPitchSignal.harmonic(
        sampleRate: sampleRate,
        fundamentalHz: 41.2,
        length: 8192,
        harmonicAmplitudes: const {1: 0.32, 2: 0.28, 3: 0.18, 4: 0.1},
        noiseAmplitude: 0.03,
        noiseSeed: 12,
      ),
      sampleRate: sampleRate,
    );

    _expectFrequency(result, 41.2, maximumRelativeError: 0.007);
  });

  test('handles a deterministic attack and release envelope', () {
    final enveloped = SyntheticPitchSignal.applyEnvelope(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: 196,
        length: frameLength,
        amplitude: 0.7,
      ),
    );
    final result = detector.detect(enveloped, sampleRate: sampleRate);

    _expectFrequency(result, 196, maximumRelativeError: 0.007);
  });

  test('produces identical output for repeated deterministic runs', () {
    final signal = SyntheticPitchSignal.harmonic(
      sampleRate: sampleRate,
      fundamentalHz: 246.94,
      length: frameLength,
      harmonicAmplitudes: const {1: 0.45, 2: 0.25, 3: 0.12},
      noiseAmplitude: 0.04,
      noiseSeed: 440,
    );
    final first = detector.detect(signal, sampleRate: sampleRate);
    final second = detector.detect(signal, sampleRate: sampleRate);

    expect(second.isDetected, first.isDetected);
    expect(second.frequencyHz, first.frequencyHz);
    expect(second.confidence, first.confidence);
    expect(second.periodSamples, first.periodSamples);
  });

  test(
    'synthetic utilities combine signals and add offsets deterministically',
    () {
      final sine = SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: 440,
        length: 64,
        amplitude: 0.2,
      );
      final noise = SyntheticPitchSignal.whiteNoise(
        length: 64,
        amplitude: 0.01,
        seed: 8,
      );
      final combined = SyntheticPitchSignal.combine([sine, noise]);
      final offset = SyntheticPitchSignal.addDcOffset(combined, 0.1);

      expect(combined.length, 64);
      expect(offset[20], closeTo(combined[20] + 0.1, 1e-6));
      expect(
        SyntheticPitchSignal.whiteNoise(length: 64, amplitude: 0.01, seed: 8),
        orderedEquals(noise),
      );
    },
  );

  test('rejects incompatible combined signal lengths', () {
    expect(
      () => SyntheticPitchSignal.combine([Float32List(4), Float32List(5)]),
      throwsArgumentError,
    );
  });
}

void _expectFrequency(
  PitchEstimate result,
  double expected, {
  double maximumRelativeError = 0.005,
}) {
  expect(result.isDetected, isTrue, reason: result.noPitchReason?.name);
  expect(
    (result.frequencyHz! - expected).abs() / expected,
    lessThan(maximumRelativeError),
  );
  expect(result.confidence, inInclusiveRange(0.82, 1));
}
