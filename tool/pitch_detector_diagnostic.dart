// ignore_for_file: avoid_print

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tunathic/features/tuner_pitch/dsp/yin_pitch_detector.dart';

void main() {
  const sampleRate = 48000;
  const frequencies = [
    40.00,
    41.20,
    55.00,
    61.74,
    82.41,
    110.00,
    146.83,
    196.00,
    246.94,
    329.63,
    440.00,
    659.25,
    880.00,
    1000.00,
    1200.00,
  ];
  final detector = YinPitchDetector();

  print(
    'expected_hz,estimated_hz,error_percent,error_cents,'
    'note_cents,confidence',
  );
  for (final frequency in frequencies) {
    final result = detector.detect(
      _sine(sampleRate, frequency, 4096),
      sampleRate: sampleRate,
    );
    final estimate = result.frequencyHz;
    if (estimate == null) {
      print('$frequency,no_pitch,,,,${result.confidence.toStringAsFixed(6)}');
      continue;
    }
    final errorPercent = (estimate - frequency).abs() / frequency * 100;
    final errorCents = 1200 * math.log(estimate / frequency) / math.ln2;
    print(
      '${frequency.toStringAsFixed(2)},'
      '${estimate.toStringAsFixed(6)},'
      '${errorPercent.toStringAsFixed(6)},'
      '${errorCents.toStringAsFixed(4)},'
      '${result.centsDeviation!.toStringAsFixed(4)},'
      '${result.confidence.toStringAsFixed(6)}',
    );
  }

  print('');
  for (final frameLength in [4096, 8192]) {
    final signal = _harmonic(sampleRate, 82.41, frameLength);
    for (var index = 0; index < 5; index++) {
      detector.detect(signal, sampleRate: sampleRate);
    }
    final timings = <int>[];
    for (var index = 0; index < 30; index++) {
      final stopwatch = Stopwatch()..start();
      detector.detect(signal, sampleRate: sampleRate);
      stopwatch.stop();
      timings.add(stopwatch.elapsedMicroseconds);
    }
    timings.sort();
    final average =
        timings.reduce((left, right) => left + right) / timings.length;
    final median = timings[timings.length ~/ 2];
    print(
      'frame=$frameLength runs=${timings.length} '
      'median_ms=${(median / 1000).toStringAsFixed(3)} '
      'average_ms=${(average / 1000).toStringAsFixed(3)} '
      'min_ms=${(timings.first / 1000).toStringAsFixed(3)} '
      'max_ms=${(timings.last / 1000).toStringAsFixed(3)}',
    );
  }
}

Float32List _sine(int sampleRate, double frequency, int length) {
  final samples = Float32List(length);
  for (var index = 0; index < length; index++) {
    samples[index] =
        0.7 * math.sin(2 * math.pi * frequency * index / sampleRate);
  }
  return samples;
}

Float32List _harmonic(int sampleRate, double frequency, int length) {
  final samples = Float32List(length);
  for (var index = 0; index < length; index++) {
    final phase = 2 * math.pi * frequency * index / sampleRate;
    samples[index] =
        0.45 * math.sin(phase) +
        0.28 * math.sin(phase * 2) +
        0.14 * math.sin(phase * 3);
  }
  return samples;
}
