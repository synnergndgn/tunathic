import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tunathic/features/tuner_pitch/domain/musical_note.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_detector.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_detector_configuration.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';

final class YinPitchDetector implements PitchDetector {
  YinPitchDetector({PitchDetectorConfiguration? configuration})
    : configuration = configuration ?? PitchDetectorConfiguration();

  final PitchDetectorConfiguration configuration;

  @override
  PitchEstimate detect(Float32List samples, {required int sampleRate}) {
    if (sampleRate <= 0) {
      return PitchEstimate.noPitch(NoPitchReason.invalidSampleRate);
    }
    if (samples.isEmpty) {
      return PitchEstimate.noPitch(NoPitchReason.emptyFrame);
    }
    if (configuration.maximumFrequencyHz >= sampleRate / 2) {
      return PitchEstimate.noPitch(NoPitchReason.unsupportedRange);
    }
    var sum = 0.0;
    for (final sample in samples) {
      if (!sample.isFinite || sample < -1 || sample > 1) {
        return PitchEstimate.noPitch(NoPitchReason.invalidSamples);
      }
      sum += sample;
    }
    if (samples.length < configuration.minimumFrameLength(sampleRate)) {
      return PitchEstimate.noPitch(NoPitchReason.insufficientSamples);
    }
    final mean = sum / samples.length;
    var sumSquares = 0.0;
    for (final sample in samples) {
      final centered = sample - mean;
      sumSquares += centered * centered;
    }
    final rms = math.sqrt(sumSquares / samples.length);
    if (rms < configuration.minimumRms) {
      return PitchEstimate.noPitch(NoPitchReason.silence);
    }

    final maximumLag = (sampleRate / configuration.minimumFrequencyHz).ceil();
    final searchMaximumLag = math.min(
      samples.length - 1,
      (maximumLag * (1 + configuration.lowerRangeGuardRatio)).ceil(),
    );
    final minimumLag = math.max(
      2,
      (sampleRate / configuration.maximumFrequencyHz).ceil(),
    );
    final analysisLength = samples.length - maximumLag;
    if (analysisLength <= 0) {
      return PitchEstimate.noPitch(NoPitchReason.insufficientSamples);
    }

    final differenceFunctions = _differenceFunctions(
      samples,
      maximumLag: searchMaximumLag,
      analysisLength: analysisLength,
    );
    final normalizedDifference = differenceFunctions.normalized;
    final initialCandidate = _firstThresholdMinimum(normalizedDifference);
    if (initialCandidate == null) {
      return PitchEstimate.noPitch(
        NoPitchReason.lowConfidence,
        confidence: _bestConfidence(
          normalizedDifference,
          minimumLag,
          maximumLag,
        ),
      );
    }

    final candidate = _preferClearerSubharmonic(
      normalizedDifference,
      initialCandidate,
      searchMaximumLag,
    );
    if (candidate < minimumLag || candidate > maximumLag) {
      return PitchEstimate.noPitch(
        NoPitchReason.unsupportedRange,
        confidence: 1 - normalizedDifference[candidate],
      );
    }

    final confidence = (1 - normalizedDifference[candidate])
        .clamp(0, 1)
        .toDouble();
    if (confidence < configuration.minimumConfidence) {
      return PitchEstimate.noPitch(
        NoPitchReason.lowConfidence,
        confidence: confidence,
      );
    }

    final periodSamples = _parabolicMinimum(differenceFunctions.raw, candidate);
    var frequencyHz = sampleRate / periodSamples;
    // Interpolation can drift just below the exact lower-frequency boundary.
    // The guarded lag search has already rejected genuinely lower pitches, so
    // keep the maximum in-range lag on the configured boundary.
    if (candidate == maximumLag &&
        frequencyHz < configuration.minimumFrequencyHz) {
      frequencyHz = configuration.minimumFrequencyHz;
    }
    if (!frequencyHz.isFinite ||
        frequencyHz < configuration.minimumFrequencyHz ||
        frequencyHz > configuration.maximumFrequencyHz) {
      return PitchEstimate.noPitch(
        NoPitchReason.unsupportedRange,
        confidence: confidence,
      );
    }

    final note = MusicalNoteConverter.fromFrequency(frequencyHz);
    if (note == null) {
      return PitchEstimate.noPitch(
        NoPitchReason.unsupportedRange,
        confidence: confidence,
      );
    }
    return PitchEstimate.detected(
      frequencyHz: frequencyHz,
      confidence: confidence,
      midiNote: note.midiNote,
      noteName: note.noteName,
      octave: note.octave,
      centsDeviation: note.centsDeviation,
      periodSamples: periodSamples,
    );
  }

  ({Float64List raw, Float64List normalized}) _differenceFunctions(
    Float32List samples, {
    required int maximumLag,
    required int analysisLength,
  }) {
    final difference = Float64List(maximumLag + 1);
    for (var lag = 1; lag <= maximumLag; lag++) {
      var squaredDifference = 0.0;
      final lagAnalysisLength = math.min(analysisLength, samples.length - lag);
      for (var index = 0; index < lagAnalysisLength; index++) {
        final delta = samples[index] - samples[index + lag];
        squaredDifference += delta * delta;
      }
      difference[lag] = squaredDifference * analysisLength / lagAnalysisLength;
    }

    final normalized = Float64List(maximumLag + 1);
    normalized[0] = 1;
    var cumulativeDifference = 0.0;
    for (var lag = 1; lag <= maximumLag; lag++) {
      cumulativeDifference += difference[lag];
      normalized[lag] = cumulativeDifference == 0
          ? 1
          : difference[lag] * lag / cumulativeDifference;
    }
    return (raw: difference, normalized: normalized);
  }

  int? _firstThresholdMinimum(Float64List normalizedDifference) {
    var lag = 2;
    while (lag < normalizedDifference.length - 1) {
      if (normalizedDifference[lag] < configuration.yinThreshold) {
        while (lag + 1 < normalizedDifference.length &&
            normalizedDifference[lag + 1] < normalizedDifference[lag]) {
          lag++;
        }
        return lag;
      }
      lag++;
    }
    return null;
  }

  int _preferClearerSubharmonic(
    Float64List normalizedDifference,
    int initialCandidate,
    int maximumLag,
  ) {
    var selectedLag = initialCandidate;
    var selectedScore = normalizedDifference[initialCandidate];
    for (
      var multiple = 2;
      multiple <= configuration.maximumHarmonicMultiple;
      multiple++
    ) {
      final target = initialCandidate * multiple;
      if (target > maximumLag) break;
      final searchRadius = math.max(2, (target * 0.01).round());
      final nearbyMinimum = _minimumNear(
        normalizedDifference,
        target,
        searchRadius,
        maximumLag,
      );
      final score = normalizedDifference[nearbyMinimum];
      if (selectedScore - score >= configuration.harmonicImprovementThreshold) {
        selectedLag = nearbyMinimum;
        selectedScore = score;
      }
    }
    return selectedLag;
  }

  int _minimumNear(Float64List values, int target, int radius, int maximumLag) {
    final start = math.max(2, target - radius);
    final end = math.min(maximumLag, target + radius);
    var bestIndex = start;
    var bestValue = values[start];
    for (var index = start + 1; index <= end; index++) {
      if (values[index] < bestValue) {
        bestIndex = index;
        bestValue = values[index];
      }
    }
    return bestIndex;
  }

  double _bestConfidence(
    Float64List normalizedDifference,
    int minimumLag,
    int maximumLag,
  ) {
    var bestScore = 1.0;
    for (var lag = minimumLag; lag <= maximumLag; lag++) {
      bestScore = math.min(bestScore, normalizedDifference[lag]);
    }
    return (1 - bestScore).clamp(0, 1).toDouble();
  }

  double _parabolicMinimum(Float64List values, int index) {
    if (index <= 0 || index >= values.length - 1) return index.toDouble();
    final left = values[index - 1];
    final center = values[index];
    final right = values[index + 1];
    final denominator = 2 * (2 * center - right - left);
    if (denominator.abs() < 1e-12) return index.toDouble();
    final adjustment = ((right - left) / denominator).clamp(-1, 1).toDouble();
    return index + adjustment;
  }
}
