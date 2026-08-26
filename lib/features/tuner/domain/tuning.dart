import 'dart:math' as math;

import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

enum TunerMode {
  /// Tunathic picks the closest string of the active preset.
  automatic('automatic'),

  /// The player locks one string of the active preset.
  manual('manual'),

  /// No preset at all: whatever note is played is named and measured.
  chromatic('chromatic');

  const TunerMode(this.id);

  final String id;

  static TunerMode fromId(String? id) {
    for (final mode in values) {
      if (mode.id == id) return mode;
    }
    return automatic;
  }
}

enum TuningPresetId {
  standard('standard'),
  dropD('drop-d'),
  halfStepDown('half-step-down'),
  fullStepDown('full-step-down'),
  dadgad('dadgad'),
  openG('open-g'),
  openD('open-d');

  const TuningPresetId(this.id);

  final String id;

  static TuningPresetId fromId(String? id) {
    for (final preset in values) {
      if (preset.id == id) return preset;
    }
    return standard;
  }
}

final class TuningStringTarget {
  const TuningStringTarget({
    required this.stringPosition,
    required this.midiNote,
    required this.displayName,
  }) : assert(stringPosition >= 1 && stringPosition <= 6),
       assert(midiNote >= 0 && midiNote <= 127);

  final int stringPosition;
  final int midiNote;
  final String displayName;

  int get octave => midiNote ~/ 12 - 1;

  /// The target at concert pitch. Use [frequencyHzFor] when the player has
  /// chosen a different reference.
  double get frequencyHz => TunerPitchMath.frequencyForMidi(midiNote);

  double frequencyHzFor(TuningReference reference) =>
      TunerPitchMath.frequencyForMidi(
        midiNote,
        referenceFrequencyHz: reference.a4FrequencyHz,
      );
}

final class TuningPreset {
  const TuningPreset({required this.id, required this.strings});

  final TuningPresetId id;
  final List<TuningStringTarget> strings;

  TuningStringTarget stringAt(int position) {
    for (final target in strings) {
      if (target.stringPosition == position) return target;
    }
    return strings.first;
  }
}

abstract final class TuningPresets {
  static const standard = TuningPreset(
    id: TuningPresetId.standard,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 40, displayName: 'E2'),
      TuningStringTarget(stringPosition: 5, midiNote: 45, displayName: 'A2'),
      TuningStringTarget(stringPosition: 4, midiNote: 50, displayName: 'D3'),
      TuningStringTarget(stringPosition: 3, midiNote: 55, displayName: 'G3'),
      TuningStringTarget(stringPosition: 2, midiNote: 59, displayName: 'B3'),
      TuningStringTarget(stringPosition: 1, midiNote: 64, displayName: 'E4'),
    ],
  );

  static const dropD = TuningPreset(
    id: TuningPresetId.dropD,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 38, displayName: 'D2'),
      TuningStringTarget(stringPosition: 5, midiNote: 45, displayName: 'A2'),
      TuningStringTarget(stringPosition: 4, midiNote: 50, displayName: 'D3'),
      TuningStringTarget(stringPosition: 3, midiNote: 55, displayName: 'G3'),
      TuningStringTarget(stringPosition: 2, midiNote: 59, displayName: 'B3'),
      TuningStringTarget(stringPosition: 1, midiNote: 64, displayName: 'E4'),
    ],
  );

  static const halfStepDown = TuningPreset(
    id: TuningPresetId.halfStepDown,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 39, displayName: 'D#2'),
      TuningStringTarget(stringPosition: 5, midiNote: 44, displayName: 'G#2'),
      TuningStringTarget(stringPosition: 4, midiNote: 49, displayName: 'C#3'),
      TuningStringTarget(stringPosition: 3, midiNote: 54, displayName: 'F#3'),
      TuningStringTarget(stringPosition: 2, midiNote: 58, displayName: 'A#3'),
      TuningStringTarget(stringPosition: 1, midiNote: 63, displayName: 'D#4'),
    ],
  );

  static const fullStepDown = TuningPreset(
    id: TuningPresetId.fullStepDown,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 38, displayName: 'D2'),
      TuningStringTarget(stringPosition: 5, midiNote: 43, displayName: 'G2'),
      TuningStringTarget(stringPosition: 4, midiNote: 48, displayName: 'C3'),
      TuningStringTarget(stringPosition: 3, midiNote: 53, displayName: 'F3'),
      TuningStringTarget(stringPosition: 2, midiNote: 57, displayName: 'A3'),
      TuningStringTarget(stringPosition: 1, midiNote: 62, displayName: 'D4'),
    ],
  );

  static const dadgad = TuningPreset(
    id: TuningPresetId.dadgad,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 38, displayName: 'D2'),
      TuningStringTarget(stringPosition: 5, midiNote: 45, displayName: 'A2'),
      TuningStringTarget(stringPosition: 4, midiNote: 50, displayName: 'D3'),
      TuningStringTarget(stringPosition: 3, midiNote: 55, displayName: 'G3'),
      TuningStringTarget(stringPosition: 2, midiNote: 57, displayName: 'A3'),
      TuningStringTarget(stringPosition: 1, midiNote: 62, displayName: 'D4'),
    ],
  );

  static const openG = TuningPreset(
    id: TuningPresetId.openG,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 38, displayName: 'D2'),
      TuningStringTarget(stringPosition: 5, midiNote: 43, displayName: 'G2'),
      TuningStringTarget(stringPosition: 4, midiNote: 50, displayName: 'D3'),
      TuningStringTarget(stringPosition: 3, midiNote: 55, displayName: 'G3'),
      TuningStringTarget(stringPosition: 2, midiNote: 59, displayName: 'B3'),
      TuningStringTarget(stringPosition: 1, midiNote: 62, displayName: 'D4'),
    ],
  );

  static const openD = TuningPreset(
    id: TuningPresetId.openD,
    strings: [
      TuningStringTarget(stringPosition: 6, midiNote: 38, displayName: 'D2'),
      TuningStringTarget(stringPosition: 5, midiNote: 45, displayName: 'A2'),
      TuningStringTarget(stringPosition: 4, midiNote: 50, displayName: 'D3'),
      TuningStringTarget(stringPosition: 3, midiNote: 54, displayName: 'F#3'),
      TuningStringTarget(stringPosition: 2, midiNote: 57, displayName: 'A3'),
      TuningStringTarget(stringPosition: 1, midiNote: 62, displayName: 'D4'),
    ],
  );

  static const all = [
    standard,
    dropD,
    halfStepDown,
    fullStepDown,
    dadgad,
    openG,
    openD,
  ];

  static TuningPreset byId(TuningPresetId id) =>
      all.firstWhere((preset) => preset.id == id);
}

abstract final class TunerPitchMath {
  static const a4ReferenceFrequencyHz = 440.0;

  static double frequencyForMidi(
    int midiNote, {
    double referenceFrequencyHz = a4ReferenceFrequencyHz,
  }) {
    if (midiNote < 0 || midiNote > 127) {
      throw ArgumentError.value(midiNote, 'midiNote');
    }
    if (!referenceFrequencyHz.isFinite || referenceFrequencyHz <= 0) {
      throw ArgumentError.value(referenceFrequencyHz, 'referenceFrequencyHz');
    }
    return referenceFrequencyHz * math.pow(2, (midiNote - 69) / 12).toDouble();
  }

  static double? centsBetween(double? frequencyHz, double? targetFrequencyHz) {
    if (frequencyHz == null ||
        targetFrequencyHz == null ||
        !frequencyHz.isFinite ||
        !targetFrequencyHz.isFinite ||
        frequencyHz <= 0 ||
        targetFrequencyHz <= 0) {
      return null;
    }
    return 1200 * math.log(frequencyHz / targetFrequencyHz) / math.ln2;
  }
}

enum TunerAccuracy { inTune, near, out }

enum TunerDirection { flat, inTune, sharp }

final class TunerUiConfiguration {
  const TunerUiConfiguration({
    this.inTuneThresholdCents = 5,
    this.nearThresholdCents = 15,
    this.visualRangeCents = 50,
    this.targetHysteresisCents = 25,
    this.maximumAutomaticTargetDistanceCents = 200,
    this.targetSwitchConfirmations = 2,
    this.noPitchTargetClearCount = 8,
    this.inTuneHapticConfirmations = 3,
    this.centsDisplayThreshold = 1,
    this.frequencyDisplayThresholdHz = 0.1,
  }) : assert(inTuneThresholdCents > 0),
       assert(nearThresholdCents >= inTuneThresholdCents),
       assert(visualRangeCents >= nearThresholdCents),
       assert(targetHysteresisCents >= 0),
       assert(maximumAutomaticTargetDistanceCents > 0),
       assert(targetSwitchConfirmations > 0),
       assert(noPitchTargetClearCount > 0),
       assert(inTuneHapticConfirmations > 0),
       assert(centsDisplayThreshold > 0),
       assert(frequencyDisplayThresholdHz > 0);

  final double inTuneThresholdCents;
  final double nearThresholdCents;
  final double visualRangeCents;
  final double targetHysteresisCents;
  final double maximumAutomaticTargetDistanceCents;
  final int targetSwitchConfirmations;
  final int noPitchTargetClearCount;
  final int inTuneHapticConfirmations;

  /// Minimum movement worth publishing to the presentation layer.
  /// Detection and haptic confirmation still process every estimate.
  final double centsDisplayThreshold;
  final double frequencyDisplayThresholdHz;

  TunerAccuracy accuracyFor(double cents) {
    final distance = cents.abs();
    if (distance <= inTuneThresholdCents) return TunerAccuracy.inTune;
    if (distance <= nearThresholdCents) return TunerAccuracy.near;
    return TunerAccuracy.out;
  }

  TunerDirection directionFor(double cents) {
    if (cents.abs() <= inTuneThresholdCents) return TunerDirection.inTune;
    return cents < 0 ? TunerDirection.flat : TunerDirection.sharp;
  }
}
