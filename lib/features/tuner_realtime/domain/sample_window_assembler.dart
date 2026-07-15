import 'dart:typed_data';

final class SampleWindowDiagnostics {
  const SampleWindowDiagnostics({
    required this.totalSamplesReceived,
    required this.framesEmitted,
    required this.samplesDropped,
    required this.resetCount,
    required this.bufferedSamples,
    required this.maximumBufferedSamples,
  });

  final int totalSamplesReceived;
  final int framesEmitted;
  final int samplesDropped;
  final int resetCount;
  final int bufferedSamples;
  final int maximumBufferedSamples;
}

final class SampleWindowAssembler {
  SampleWindowAssembler({required this.frameSize, required this.hopSize})
    : _ring = Float32List(frameSize) {
    if (frameSize <= 0) {
      throw ArgumentError.value(frameSize, 'frameSize', 'Must be positive.');
    }
    if (hopSize <= 0 || hopSize > frameSize) {
      throw ArgumentError.value(
        hopSize,
        'hopSize',
        'Must be positive and no greater than frameSize.',
      );
    }
  }

  final int frameSize;
  final int hopSize;
  final Float32List _ring;

  int _writeIndex = 0;
  int _bufferedSamples = 0;
  int _samplesSinceEmission = 0;
  int _totalSamplesReceived = 0;
  int _framesEmitted = 0;
  int _samplesDropped = 0;
  int _resetCount = 0;
  int _maximumBufferedSamples = 0;

  SampleWindowDiagnostics get diagnostics => SampleWindowDiagnostics(
    totalSamplesReceived: _totalSamplesReceived,
    framesEmitted: _framesEmitted,
    samplesDropped: _samplesDropped,
    resetCount: _resetCount,
    bufferedSamples: _bufferedSamples,
    maximumBufferedSamples: _maximumBufferedSamples,
  );

  List<Float32List> add(Float32List chunk) {
    if (chunk.isEmpty) return const [];
    final frames = <Float32List>[];
    for (final sample in chunk) {
      _totalSamplesReceived++;
      if (_bufferedSamples < frameSize) {
        _ring[_writeIndex] = sample;
        _writeIndex = (_writeIndex + 1) % frameSize;
        _bufferedSamples++;
        if (_bufferedSamples > _maximumBufferedSamples) {
          _maximumBufferedSamples = _bufferedSamples;
        }
        if (_bufferedSamples == frameSize) {
          frames.add(_snapshot());
          _framesEmitted++;
          _samplesSinceEmission = 0;
        }
        continue;
      }

      _ring[_writeIndex] = sample;
      _writeIndex = (_writeIndex + 1) % frameSize;
      _samplesSinceEmission++;
      if (_samplesSinceEmission == hopSize) {
        frames.add(_snapshot());
        _framesEmitted++;
        _samplesSinceEmission = 0;
      }
    }
    return frames;
  }

  void recordDroppedSamples(int count) {
    if (count > 0) _samplesDropped += count;
  }

  void reset({bool clearDiagnostics = false}) {
    _writeIndex = 0;
    _bufferedSamples = 0;
    _samplesSinceEmission = 0;
    if (clearDiagnostics) {
      _totalSamplesReceived = 0;
      _framesEmitted = 0;
      _samplesDropped = 0;
      _resetCount = 0;
      _maximumBufferedSamples = 0;
    } else {
      _resetCount++;
    }
  }

  Float32List _snapshot() {
    final frame = Float32List(frameSize);
    final oldestIndex = _bufferedSamples == frameSize ? _writeIndex : 0;
    final firstLength = frameSize - oldestIndex;
    frame.setRange(0, firstLength, _ring, oldestIndex);
    if (oldestIndex > 0) {
      frame.setRange(firstLength, frameSize, _ring, 0);
    }
    return frame;
  }
}
