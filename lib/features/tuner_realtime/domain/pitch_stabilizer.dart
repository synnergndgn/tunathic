import 'dart:math' as math;

import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';
import 'package:tunathic/features/tuner_realtime/domain/realtime_pitch_configuration.dart';

final class StabilizedPitch {
  const StabilizedPitch({
    required this.frequencyHz,
    required this.continuousMidi,
    required this.midiNote,
    required this.noteName,
    required this.octave,
    required this.centsDeviation,
    required this.confidence,
  });

  final double frequencyHz;
  final double continuousMidi;
  final int midiNote;
  final String noteName;
  final int octave;
  final double centsDeviation;
  final double confidence;
}

final class PitchStabilizerResult {
  const PitchStabilizerResult({
    required this.pitch,
    required this.acceptedCurrentEstimate,
    required this.cleared,
    required this.noteChanged,
  });

  final StabilizedPitch? pitch;
  final bool acceptedCurrentEstimate;
  final bool cleared;
  final bool noteChanged;
}

final class PitchStabilizer {
  PitchStabilizer({this.configuration = const RealtimePitchConfiguration()});

  static const _noteNames = <String>[
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  final RealtimePitchConfiguration configuration;
  final List<double> _history = [];
  double? _smoothedMidi;
  int? _lockedMidiNote;
  int? _pendingMidiNote;
  int _pendingCount = 0;
  int _consecutiveNoPitch = 0;
  double _lastConfidence = 0;

  StabilizedPitch? get current => _buildCurrent();

  PitchStabilizerResult add(PitchEstimate estimate) {
    if (!estimate.isDetected ||
        estimate.frequencyHz == null ||
        estimate.confidence < configuration.minimumConfidence) {
      return _recordNoPitch();
    }

    final continuousMidi =
        69 + 12 * math.log(estimate.frequencyHz! / 440) / math.ln2;
    _consecutiveNoPitch = 0;
    _lastConfidence = estimate.confidence;
    final rawMidiNote = continuousMidi.round();
    final previousNote = _lockedMidiNote;

    if (_smoothedMidi == null || previousNote == null) {
      _acceptNewNote(continuousMidi, rawMidiNote);
      return PitchStabilizerResult(
        pitch: _buildCurrent(),
        acceptedCurrentEstimate: true,
        cleared: false,
        noteChanged: false,
      );
    }

    if (rawMidiNote != previousNote) {
      final distanceSemitones = (continuousMidi - _smoothedMidi!).abs();
      final beyondBoundary = continuousMidi > previousNote
          ? continuousMidi >=
                previousNote + 0.5 + configuration.noteBoundaryMarginCents / 100
          : continuousMidi <=
                previousNote -
                    0.5 -
                    configuration.noteBoundaryMarginCents / 100;
      if (!beyondBoundary) {
        _clearPendingSwitch();
        return PitchStabilizerResult(
          pitch: _buildCurrent(),
          acceptedCurrentEstimate: false,
          cleared: false,
          noteChanged: false,
        );
      }
      final requiredConfirmations = distanceSemitones >= 11.5
          ? configuration.octaveSwitchConfirmations
          : configuration.noteSwitchConfirmations;
      if (_pendingMidiNote == rawMidiNote) {
        _pendingCount++;
      } else {
        _pendingMidiNote = rawMidiNote;
        _pendingCount = 1;
      }
      if (_pendingCount < requiredConfirmations) {
        return PitchStabilizerResult(
          pitch: _buildCurrent(),
          acceptedCurrentEstimate: false,
          cleared: false,
          noteChanged: false,
        );
      }
      _acceptNewNote(continuousMidi, rawMidiNote);
      return PitchStabilizerResult(
        pitch: _buildCurrent(),
        acceptedCurrentEstimate: true,
        cleared: false,
        noteChanged: true,
      );
    }

    _clearPendingSwitch();
    _history.add(continuousMidi);
    if (_history.length > configuration.historyLength) {
      _history.removeAt(0);
    }
    final median = _median(_history);
    final accepted = _history
        .where(
          (value) =>
              (value - median).abs() * 100 <=
              configuration.outlierThresholdCents,
        )
        .toList(growable: false);
    final target = accepted.reduce((a, b) => a + b) / accepted.length;
    _smoothedMidi =
        _smoothedMidi! +
        configuration.smoothingFactor * (target - _smoothedMidi!);
    return PitchStabilizerResult(
      pitch: _buildCurrent(),
      acceptedCurrentEstimate: true,
      cleared: false,
      noteChanged: false,
    );
  }

  void reset() {
    _history.clear();
    _smoothedMidi = null;
    _lockedMidiNote = null;
    _clearPendingSwitch();
    _consecutiveNoPitch = 0;
    _lastConfidence = 0;
  }

  PitchStabilizerResult _recordNoPitch() {
    _consecutiveNoPitch++;
    final shouldClear = _consecutiveNoPitch >= configuration.noPitchClearCount;
    if (shouldClear) reset();
    return PitchStabilizerResult(
      pitch: _buildCurrent(),
      acceptedCurrentEstimate: false,
      cleared: shouldClear,
      noteChanged: false,
    );
  }

  void _acceptNewNote(double continuousMidi, int midiNote) {
    _history
      ..clear()
      ..add(continuousMidi);
    _smoothedMidi = continuousMidi;
    _lockedMidiNote = midiNote;
    _clearPendingSwitch();
  }

  void _clearPendingSwitch() {
    _pendingMidiNote = null;
    _pendingCount = 0;
  }

  StabilizedPitch? _buildCurrent() {
    final continuousMidi = _smoothedMidi;
    final midiNote = _lockedMidiNote;
    if (continuousMidi == null || midiNote == null) return null;
    final frequencyHz = 440 * math.pow(2, (continuousMidi - 69) / 12);
    return StabilizedPitch(
      frequencyHz: frequencyHz.toDouble(),
      continuousMidi: continuousMidi,
      midiNote: midiNote,
      noteName: _noteNames[midiNote % 12],
      octave: midiNote ~/ 12 - 1,
      centsDeviation: 100 * (continuousMidi - midiNote),
      confidence: _lastConfidence,
    );
  }

  double _median(List<double> values) {
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
