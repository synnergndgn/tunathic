final class RealtimePitchConfiguration {
  const RealtimePitchConfiguration({
    this.frameSize = 4096,
    this.hopSize = 1024,
    this.historyLength = 5,
    this.smoothingFactor = 0.35,
    this.outlierThresholdCents = 45,
    this.noteBoundaryMarginCents = 8,
    this.noteSwitchConfirmations = 2,
    this.octaveSwitchConfirmations = 2,
    this.noPitchClearCount = 4,
    this.minimumConfidence = 0.82,
    this.staleTimeout = const Duration(milliseconds: 350),
    this.uiPublicationInterval = const Duration(milliseconds: 75),
  }) : assert(frameSize > 0),
       assert(hopSize > 0 && hopSize <= frameSize),
       assert(historyLength > 0),
       assert(smoothingFactor > 0 && smoothingFactor <= 1),
       assert(outlierThresholdCents > 0),
       assert(noteBoundaryMarginCents >= 0 && noteBoundaryMarginCents < 50),
       assert(noteSwitchConfirmations > 0),
       assert(octaveSwitchConfirmations > 0),
       assert(noPitchClearCount > 0),
       assert(minimumConfidence >= 0 && minimumConfidence <= 1);

  final int frameSize;
  final int hopSize;
  final int historyLength;
  final double smoothingFactor;
  final double outlierThresholdCents;
  final double noteBoundaryMarginCents;
  final int noteSwitchConfirmations;
  final int octaveSwitchConfirmations;
  final int noPitchClearCount;
  final double minimumConfidence;
  final Duration staleTimeout;
  final Duration uiPublicationInterval;

  void validateFrameRequirement(int minimumFrameLength) {
    if (staleTimeout <= Duration.zero) {
      throw ArgumentError.value(staleTimeout, 'staleTimeout');
    }
    if (uiPublicationInterval <= Duration.zero) {
      throw ArgumentError.value(uiPublicationInterval, 'uiPublicationInterval');
    }
    if (frameSize < minimumFrameLength) {
      throw ArgumentError.value(
        frameSize,
        'frameSize',
        'Must satisfy the detector minimum of $minimumFrameLength samples.',
      );
    }
  }
}
