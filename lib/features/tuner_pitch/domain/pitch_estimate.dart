enum NoPitchReason {
  emptyFrame,
  invalidSampleRate,
  invalidSamples,
  insufficientSamples,
  silence,
  unsupportedRange,
  lowConfidence,
}

final class PitchEstimate {
  const PitchEstimate._({
    required this.isDetected,
    required this.confidence,
    this.frequencyHz,
    this.midiNote,
    this.noteName,
    this.octave,
    this.centsDeviation,
    this.periodSamples,
    this.noPitchReason,
  });

  factory PitchEstimate.detected({
    required double frequencyHz,
    required double confidence,
    required int midiNote,
    required String noteName,
    required int octave,
    required double centsDeviation,
    required double periodSamples,
  }) => PitchEstimate._(
    isDetected: true,
    frequencyHz: frequencyHz,
    confidence: confidence.clamp(0, 1).toDouble(),
    midiNote: midiNote,
    noteName: noteName,
    octave: octave,
    centsDeviation: centsDeviation,
    periodSamples: periodSamples,
  );

  factory PitchEstimate.noPitch(
    NoPitchReason reason, {
    double confidence = 0,
  }) => PitchEstimate._(
    isDetected: false,
    confidence: confidence.clamp(0, 1).toDouble(),
    noPitchReason: reason,
  );

  final bool isDetected;
  final double? frequencyHz;
  final double confidence;
  final int? midiNote;
  final String? noteName;
  final int? octave;
  final double? centsDeviation;
  final double? periodSamples;
  final NoPitchReason? noPitchReason;
}
