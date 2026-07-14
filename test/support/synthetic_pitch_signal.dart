import 'dart:math' as math;
import 'dart:typed_data';

abstract final class SyntheticPitchSignal {
  static Float32List silence(int length) => Float32List(length);

  static Float32List sine({
    required int sampleRate,
    required double frequencyHz,
    required int length,
    double amplitude = 0.7,
    double phaseRadians = 0,
    double dcOffset = 0,
  }) {
    final samples = Float32List(length);
    final angularStep = 2 * math.pi * frequencyHz / sampleRate;
    for (var index = 0; index < length; index++) {
      samples[index] =
          dcOffset + amplitude * math.sin(angularStep * index + phaseRadians);
    }
    return samples;
  }

  static Float32List harmonic({
    required int sampleRate,
    required double fundamentalHz,
    required int length,
    required Map<int, double> harmonicAmplitudes,
    double phaseRadians = 0,
    double dcOffset = 0,
    double noiseAmplitude = 0,
    int noiseSeed = 1,
  }) {
    final samples = Float32List(length);
    final random = math.Random(noiseSeed);
    for (var index = 0; index < length; index++) {
      var value = dcOffset;
      for (final entry in harmonicAmplitudes.entries) {
        value +=
            entry.value *
            math.sin(
              2 * math.pi * fundamentalHz * entry.key * index / sampleRate +
                  phaseRadians * entry.key,
            );
      }
      if (noiseAmplitude > 0) {
        value += (random.nextDouble() * 2 - 1) * noiseAmplitude;
      }
      samples[index] = value;
    }
    return samples;
  }

  static Float32List whiteNoise({
    required int length,
    required double amplitude,
    int seed = 1,
  }) {
    final random = math.Random(seed);
    return Float32List.fromList(
      List<double>.generate(
        length,
        (_) => (random.nextDouble() * 2 - 1) * amplitude,
        growable: false,
      ),
    );
  }

  static Float32List combine(List<Float32List> signals) {
    if (signals.isEmpty) return Float32List(0);
    final length = signals.first.length;
    if (signals.any((signal) => signal.length != length)) {
      throw ArgumentError('All combined signals must have equal lengths.');
    }
    final combined = Float32List(length);
    for (final signal in signals) {
      for (var index = 0; index < length; index++) {
        combined[index] += signal[index];
      }
    }
    return combined;
  }

  static Float32List addDcOffset(Float32List input, double offset) =>
      Float32List.fromList(
        input.map((sample) => sample + offset).toList(growable: false),
      );

  static Float32List applyEnvelope(
    Float32List input, {
    double attackFraction = 0.1,
    double releaseFraction = 0.2,
  }) {
    if (attackFraction < 0 ||
        releaseFraction < 0 ||
        attackFraction + releaseFraction > 1) {
      throw ArgumentError('Envelope fractions must fit inside the signal.');
    }
    final output = Float32List(input.length);
    final attackLength = (input.length * attackFraction).round();
    final releaseLength = (input.length * releaseFraction).round();
    final releaseStart = input.length - releaseLength;
    for (var index = 0; index < input.length; index++) {
      var gain = 1.0;
      if (attackLength > 0 && index < attackLength) {
        gain = index / attackLength;
      } else if (releaseLength > 0 && index >= releaseStart) {
        gain = (input.length - 1 - index) / releaseLength;
      }
      output[index] = input[index] * gain.clamp(0, 1);
    }
    return output;
  }
}
