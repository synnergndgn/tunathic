import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';
import 'package:tunathic/features/tuner_audio/domain/signal_statistics.dart';

void main() {
  test('calculates peak, RMS, and known-amplitude dBFS', () {
    final level = SignalLevel.calculate(
      Float32List.fromList([0.5, -0.5, 0.5, -0.5]),
    );

    expect(level.peak, 0.5);
    expect(level.rms, 0.5);
    expect(level.dbfs, closeTo(-6.0206, 0.0001));
  });

  test('handles silence without logarithm errors', () {
    final level = SignalLevel.calculate(Float32List(8));

    expect(level.peak, 0);
    expect(level.rms, 0);
    expect(level.dbfs, double.negativeInfinity);
  });

  test('accumulates bounded frame counters and arrival statistics', () {
    final accumulator = SignalStatisticsAccumulator();
    accumulator.addFrame(_frame(240, Duration.zero));
    accumulator.addFrame(_frame(480, const Duration(milliseconds: 10)));
    accumulator.addFrame(_frame(720, const Duration(milliseconds: 30)));
    accumulator.recordMalformedFrame();

    final statistics = accumulator.snapshot();
    expect(statistics.frameCount, 3);
    expect(statistics.samplesReceived, 1440);
    expect(statistics.minimumFrameSamples, 240);
    expect(statistics.maximumFrameSamples, 720);
    expect(statistics.averageFrameSamples, 480);
    expect(statistics.streamDuration, const Duration(milliseconds: 30));
    expect(statistics.averageArrivalInterval, const Duration(milliseconds: 15));
    expect(statistics.framesPerSecond, closeTo(66.6667, 0.001));
    expect(statistics.malformedFrameCount, 1);
  });
}

AudioFrame _frame(int sampleCount, Duration arrivalTime) {
  return AudioFrame(
    samples: Float32List(sampleCount),
    format: const AudioStreamFormat(
      sampleRate: 48000,
      channelCount: 1,
      encoding: AudioSampleEncoding.signedPcm16LittleEndian,
      isReportedByBackend: false,
    ),
    arrivalTime: arrivalTime,
    sequenceNumber: 0,
  );
}
