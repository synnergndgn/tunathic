import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/musical_note.dart';
import 'package:tunathic/features/tuner_pitch/dsp/yin_pitch_detector.dart';

import '../support/synthetic_pitch_signal.dart';

void main() {
  const sampleRate = 48000;
  const frameLength = 4096;
  late YinPitchDetector detector;

  setUp(() => detector = YinPitchDetector());

  const requiredFrequencies = <(double, String, int)>[
    (41.20, 'E', 1),
    (55.00, 'A', 1),
    (61.74, 'B', 1),
    (82.41, 'E', 2),
    (110.00, 'A', 2),
    (146.83, 'D', 3),
    (196.00, 'G', 3),
    (246.94, 'B', 3),
    (329.63, 'E', 4),
    (440.00, 'A', 4),
    (659.25, 'E', 5),
    (880.00, 'A', 5),
    (1000.00, 'B', 5),
  ];

  for (final (frequency, noteName, octave) in requiredFrequencies) {
    test('detects ${frequency.toStringAsFixed(2)} Hz as $noteName$octave', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: frequency,
          length: frameLength,
        ),
        sampleRate: sampleRate,
      );

      expect(result.isDetected, isTrue);
      expect(_relativeError(result.frequencyHz!, frequency), lessThan(0.005));
      expect(result.noteName, noteName);
      expect(result.octave, octave);
      final expectedNote = MusicalNoteConverter.fromFrequency(frequency)!;
      expect(result.centsDeviation, closeTo(expectedNote.centsDeviation, 1));
      expect(result.confidence, inInclusiveRange(0.82, 1));
      expect(result.periodSamples, isNotNull);
    });
  }

  for (final boundaryFrequency in [40.0, 1200.0]) {
    test('detects configured boundary at $boundaryFrequency Hz', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: boundaryFrequency,
          length: frameLength,
        ),
        sampleRate: sampleRate,
      );

      expect(result.isDetected, isTrue);
      expect(
        _relativeError(result.frequencyHz!, boundaryFrequency),
        lessThan(0.005),
      );
    });
  }

  for (final rate in [44100, 48000]) {
    test('supports $rate Hz input', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: rate,
          frequencyHz: 82.41,
          length: 4096,
        ),
        sampleRate: rate,
      );

      expect(result.isDetected, isTrue);
      expect(_relativeError(result.frequencyHz!, 82.41), lessThan(0.005));
      expect(result.noteName, 'E');
      expect(result.octave, 2);
    });
  }

  for (final phase in [0.0, math.pi / 3, math.pi, 1.75 * math.pi]) {
    test('is accurate with phase ${phase.toStringAsFixed(3)}', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: 196,
          length: frameLength,
          phaseRadians: phase,
        ),
        sampleRate: sampleRate,
      );

      expect(result.isDetected, isTrue);
      expect(_relativeError(result.frequencyHz!, 196), lessThan(0.005));
    });
  }

  for (final length in [3600, 4096, 8192]) {
    test('supports a $length-sample 48 kHz frame', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: 110,
          length: length,
        ),
        sampleRate: sampleRate,
      );

      expect(result.isDetected, isTrue);
      expect(_relativeError(result.frequencyHz!, 110), lessThan(0.005));
    });
  }

  test('returns signed cents for slightly sharp and flat A4 signals', () {
    final sharpFrequency = (440 * math.pow(2, 18 / 1200)).toDouble();
    final flatFrequency = (440 * math.pow(2, -21 / 1200)).toDouble();
    final sharp = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: sharpFrequency,
        length: frameLength,
      ),
      sampleRate: sampleRate,
    );
    final flat = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: flatFrequency,
        length: frameLength,
      ),
      sampleRate: sampleRate,
    );

    expect(sharp.noteName, 'A');
    expect(sharp.centsDeviation, closeTo(18, 1));
    expect(flat.noteName, 'A');
    expect(flat.centsDeviation, closeTo(-21, 1));
  });

  test('keeps note classification stable around a semitone boundary', () {
    final midpoint = (440 * math.pow(2, 0.5 / 12)).toDouble();
    final below = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: midpoint * 0.999,
        length: frameLength,
      ),
      sampleRate: sampleRate,
    );
    final above = detector.detect(
      SyntheticPitchSignal.sine(
        sampleRate: sampleRate,
        frequencyHz: midpoint * 1.001,
        length: frameLength,
      ),
      sampleRate: sampleRate,
    );

    expect(below.noteName, 'A');
    expect(above.noteName, 'A#');
  });

  for (final (frequency, length) in [
    (30.0, 8192),
    (39.0, 8192),
    (1201.0, frameLength),
    (1500.0, frameLength),
  ]) {
    test('rejects out-of-range clean frequency at $frequency Hz', () {
      final result = detector.detect(
        SyntheticPitchSignal.sine(
          sampleRate: sampleRate,
          frequencyHz: frequency,
          length: length,
        ),
        sampleRate: sampleRate,
      );

      expect(result.isDetected, isFalse);
    });
  }
}

double _relativeError(double actual, double expected) =>
    (actual - expected).abs() / expected;
