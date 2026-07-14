import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';

final class SignalLevel {
  const SignalLevel({
    required this.peak,
    required this.rms,
    required this.dbfs,
  });

  final double peak;
  final double rms;
  final double dbfs;

  static SignalLevel calculate(Float32List samples) {
    if (samples.isEmpty) {
      return const SignalLevel(peak: 0, rms: 0, dbfs: double.negativeInfinity);
    }

    var peak = 0.0;
    var sumSquares = 0.0;
    for (final sample in samples) {
      final absolute = sample.abs();
      if (absolute > peak) peak = absolute;
      sumSquares += sample * sample;
    }
    final rms = math.sqrt(sumSquares / samples.length);
    final dbfs = rms == 0
        ? double.negativeInfinity
        : 20 * math.log(rms) / math.ln10;
    return SignalLevel(peak: peak, rms: rms, dbfs: dbfs);
  }
}

final class SignalStatistics {
  const SignalStatistics({
    required this.frameCount,
    required this.samplesReceived,
    required this.malformedFrameCount,
    required this.latestLevel,
    required this.streamDuration,
    required this.minimumFrameSamples,
    required this.maximumFrameSamples,
    required this.averageFrameSamples,
    required this.averageArrivalInterval,
    required this.framesPerSecond,
  });

  const SignalStatistics.empty()
    : frameCount = 0,
      samplesReceived = 0,
      malformedFrameCount = 0,
      latestLevel = const SignalLevel(
        peak: 0,
        rms: 0,
        dbfs: double.negativeInfinity,
      ),
      streamDuration = Duration.zero,
      minimumFrameSamples = 0,
      maximumFrameSamples = 0,
      averageFrameSamples = 0,
      averageArrivalInterval = Duration.zero,
      framesPerSecond = 0;

  final int frameCount;
  final int samplesReceived;
  final int malformedFrameCount;
  final SignalLevel latestLevel;
  final Duration streamDuration;
  final int minimumFrameSamples;
  final int maximumFrameSamples;
  final double averageFrameSamples;
  final Duration averageArrivalInterval;
  final double framesPerSecond;
}

final class SignalStatisticsAccumulator {
  int _frameCount = 0;
  int _samplesReceived = 0;
  int _malformedFrameCount = 0;
  int _minimumFrameSamples = 0;
  int _maximumFrameSamples = 0;
  double _streamMicroseconds = 0;
  Duration? _previousArrivalTime;
  int _arrivalIntervalCount = 0;
  int _arrivalMicroseconds = 0;
  SignalLevel _latestLevel = const SignalLevel(
    peak: 0,
    rms: 0,
    dbfs: double.negativeInfinity,
  );

  void addFrame(AudioFrame frame) {
    final sampleCount = frame.rawSampleCount;
    _frameCount++;
    _samplesReceived += sampleCount;
    _minimumFrameSamples = _minimumFrameSamples == 0
        ? sampleCount
        : math.min(_minimumFrameSamples, sampleCount);
    _maximumFrameSamples = math.max(_maximumFrameSamples, sampleCount);
    _streamMicroseconds +=
        sampleCount * Duration.microsecondsPerSecond / frame.format.sampleRate;
    _latestLevel = SignalLevel.calculate(frame.samples);

    final previousArrivalTime = _previousArrivalTime;
    if (previousArrivalTime != null &&
        frame.arrivalTime >= previousArrivalTime) {
      _arrivalIntervalCount++;
      _arrivalMicroseconds +=
          (frame.arrivalTime - previousArrivalTime).inMicroseconds;
    }
    _previousArrivalTime = frame.arrivalTime;
  }

  void recordMalformedFrame() => _malformedFrameCount++;

  SignalStatistics snapshot() {
    final averageArrivalMicros = _arrivalIntervalCount == 0
        ? 0.0
        : _arrivalMicroseconds / _arrivalIntervalCount;
    return SignalStatistics(
      frameCount: _frameCount,
      samplesReceived: _samplesReceived,
      malformedFrameCount: _malformedFrameCount,
      latestLevel: _latestLevel,
      streamDuration: Duration(microseconds: _streamMicroseconds.round()),
      minimumFrameSamples: _minimumFrameSamples,
      maximumFrameSamples: _maximumFrameSamples,
      averageFrameSamples: _frameCount == 0
          ? 0
          : _samplesReceived / _frameCount,
      averageArrivalInterval: Duration(
        microseconds: averageArrivalMicros.round(),
      ),
      framesPerSecond: averageArrivalMicros == 0
          ? 0
          : Duration.microsecondsPerSecond / averageArrivalMicros,
    );
  }
}
