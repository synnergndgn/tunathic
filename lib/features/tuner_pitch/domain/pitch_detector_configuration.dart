final class PitchDetectorConfiguration {
  PitchDetectorConfiguration({
    this.minimumFrequencyHz = 40,
    this.maximumFrequencyHz = 1200,
    this.minimumRms = 0.002,
    this.yinThreshold = 0.18,
    this.minimumConfidence = 0.82,
    this.minimumPeriods = 3,
    this.lowerRangeGuardRatio = 0.1,
    this.harmonicImprovementThreshold = 0.01,
    this.maximumHarmonicMultiple = 4,
  }) {
    if (!minimumFrequencyHz.isFinite || minimumFrequencyHz <= 0) {
      throw ArgumentError.value(
        minimumFrequencyHz,
        'minimumFrequencyHz',
        'Must be finite and greater than zero.',
      );
    }
    if (!maximumFrequencyHz.isFinite ||
        maximumFrequencyHz <= minimumFrequencyHz) {
      throw ArgumentError.value(
        maximumFrequencyHz,
        'maximumFrequencyHz',
        'Must be finite and greater than minimumFrequencyHz.',
      );
    }
    if (!minimumRms.isFinite || minimumRms < 0 || minimumRms >= 1) {
      throw ArgumentError.value(
        minimumRms,
        'minimumRms',
        'Must be finite and in [0, 1).',
      );
    }
    if (!yinThreshold.isFinite || yinThreshold <= 0 || yinThreshold >= 1) {
      throw ArgumentError.value(
        yinThreshold,
        'yinThreshold',
        'Must be finite and in (0, 1).',
      );
    }
    if (!minimumConfidence.isFinite ||
        minimumConfidence <= 0 ||
        minimumConfidence > 1) {
      throw ArgumentError.value(
        minimumConfidence,
        'minimumConfidence',
        'Must be finite and in (0, 1].',
      );
    }
    if (!minimumPeriods.isFinite || minimumPeriods < 2) {
      throw ArgumentError.value(
        minimumPeriods,
        'minimumPeriods',
        'Must be finite and at least two.',
      );
    }
    if (!lowerRangeGuardRatio.isFinite ||
        lowerRangeGuardRatio < 0 ||
        lowerRangeGuardRatio > 0.5) {
      throw ArgumentError.value(
        lowerRangeGuardRatio,
        'lowerRangeGuardRatio',
        'Must be finite and in [0, 0.5].',
      );
    }
    if (!harmonicImprovementThreshold.isFinite ||
        harmonicImprovementThreshold < 0 ||
        harmonicImprovementThreshold >= 1) {
      throw ArgumentError.value(
        harmonicImprovementThreshold,
        'harmonicImprovementThreshold',
        'Must be finite and in [0, 1).',
      );
    }
    if (maximumHarmonicMultiple < 1 || maximumHarmonicMultiple > 8) {
      throw ArgumentError.value(
        maximumHarmonicMultiple,
        'maximumHarmonicMultiple',
        'Must be from one through eight.',
      );
    }
  }

  final double minimumFrequencyHz;
  final double maximumFrequencyHz;
  final double minimumRms;
  final double yinThreshold;
  final double minimumConfidence;
  final double minimumPeriods;
  final double lowerRangeGuardRatio;
  final double harmonicImprovementThreshold;
  final int maximumHarmonicMultiple;

  int minimumFrameLength(int sampleRate) {
    if (sampleRate <= 0) return 0;
    return (sampleRate * minimumPeriods / minimumFrequencyHz).ceil();
  }
}
