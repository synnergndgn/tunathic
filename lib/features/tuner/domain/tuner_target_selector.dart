import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';

final class TunerTargetSelector {
  TunerTargetSelector({this.configuration = const TunerUiConfiguration()});

  final TunerUiConfiguration configuration;

  TuningStringTarget? _current;
  int? _pendingPosition;
  int _pendingCount = 0;
  int _noPitchCount = 0;

  TuningStringTarget? get current => _current;

  TuningStringTarget? select(
    StabilizedPitch? pitch,
    TuningPreset tuning, {
    TuningReference reference = TuningReference.standard,
  }) {
    if (pitch == null) return recordNoPitch();
    _noPitchCount = 0;

    final candidate = _nearest(pitch.frequencyHz, tuning, reference);
    final candidateDistance = _distance(
      pitch.frequencyHz,
      candidate,
      reference,
    );
    if (candidateDistance > configuration.maximumAutomaticTargetDistanceCents) {
      return recordNoPitch();
    }

    final current = _current;
    if (current == null) {
      _accept(candidate);
      return _current;
    }
    if (current.stringPosition == candidate.stringPosition) {
      _clearPending();
      return current;
    }

    final currentDistance = _distance(pitch.frequencyHz, current, reference);
    if (currentDistance <=
        candidateDistance + configuration.targetHysteresisCents) {
      _clearPending();
      return current;
    }

    if (_pendingPosition == candidate.stringPosition) {
      _pendingCount++;
    } else {
      _pendingPosition = candidate.stringPosition;
      _pendingCount = 1;
    }
    if (_pendingCount >= configuration.targetSwitchConfirmations) {
      _accept(candidate);
    }
    return _current;
  }

  TuningStringTarget? recordNoPitch() {
    _noPitchCount++;
    _clearPending();
    if (_noPitchCount >= configuration.noPitchTargetClearCount) {
      _current = null;
    }
    return _current;
  }

  void reset() {
    _current = null;
    _noPitchCount = 0;
    _clearPending();
  }

  TuningStringTarget _nearest(
    double frequency,
    TuningPreset tuning,
    TuningReference reference,
  ) {
    var nearest = tuning.strings.first;
    var nearestDistance = _distance(frequency, nearest, reference);
    for (final target in tuning.strings.skip(1)) {
      final distance = _distance(frequency, target, reference);
      if (distance < nearestDistance) {
        nearest = target;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  double _distance(
    double frequency,
    TuningStringTarget target,
    TuningReference reference,
  ) => TunerPitchMath.centsBetween(
    frequency,
    target.frequencyHzFor(reference),
  )!.abs();

  void _accept(TuningStringTarget target) {
    _current = target;
    _clearPending();
  }

  void _clearPending() {
    _pendingPosition = null;
    _pendingCount = 0;
  }
}
