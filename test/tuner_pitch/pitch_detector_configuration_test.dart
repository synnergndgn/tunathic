import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_detector_configuration.dart';

void main() {
  test('defaults cover guitar and bass with three low-frequency periods', () {
    final configuration = PitchDetectorConfiguration();

    expect(configuration.minimumFrequencyHz, 40);
    expect(configuration.maximumFrequencyHz, 1200);
    expect(configuration.lowerRangeGuardRatio, 0.1);
    expect(configuration.minimumFrameLength(48000), 3600);
    expect(configuration.minimumFrameLength(44100), 3308);
  });

  test('rejects invalid frequency ranges', () {
    expect(
      () => PitchDetectorConfiguration(minimumFrequencyHz: 0),
      throwsArgumentError,
    );
    expect(
      () => PitchDetectorConfiguration(
        minimumFrequencyHz: 100,
        maximumFrequencyHz: 100,
      ),
      throwsArgumentError,
    );
  });

  test('rejects invalid thresholds and period requirements', () {
    expect(
      () => PitchDetectorConfiguration(yinThreshold: 1),
      throwsArgumentError,
    );
    expect(
      () => PitchDetectorConfiguration(minimumConfidence: 0),
      throwsArgumentError,
    );
    expect(
      () => PitchDetectorConfiguration(minimumPeriods: 1.5),
      throwsArgumentError,
    );
    expect(
      () => PitchDetectorConfiguration(minimumRms: double.nan),
      throwsArgumentError,
    );
  });

  test('rejects invalid harmonic correction configuration', () {
    expect(
      () => PitchDetectorConfiguration(harmonicImprovementThreshold: -0.1),
      throwsArgumentError,
    );
    expect(
      () => PitchDetectorConfiguration(lowerRangeGuardRatio: 0.6),
      throwsArgumentError,
    );
    expect(
      () => PitchDetectorConfiguration(maximumHarmonicMultiple: 9),
      throwsArgumentError,
    );
  });
}
