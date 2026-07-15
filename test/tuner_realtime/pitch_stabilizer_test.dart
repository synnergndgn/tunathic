import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/musical_note.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';
import 'package:tunathic/features/tuner_realtime/domain/realtime_pitch_configuration.dart';

void main() {
  late PitchStabilizer stabilizer;

  setUp(() => stabilizer = PitchStabilizer());

  test('stabilizes a constant note and small cents variation', () {
    for (final cents in [0.0, 3.0, -2.0, 1.0, -1.0]) {
      stabilizer.add(_estimate(_frequency(440, cents)));
    }

    expect(stabilizer.current?.noteName, 'A');
    expect(stabilizer.current?.octave, 4);
    expect(stabilizer.current!.centsDeviation.abs(), lessThan(2));
  });

  test('rejects an isolated octave error', () {
    stabilizer.add(_estimate(110));
    final result = stabilizer.add(_estimate(220));

    expect(result.acceptedCurrentEstimate, isFalse);
    expect(result.pitch?.frequencyHz, closeTo(110, 0.1));
  });

  test('rejects an attack-like isolated high transient', () {
    stabilizer.add(_estimate(82.41));
    final transient = stabilizer.add(_estimate(3000));
    final recovered = stabilizer.add(_estimate(82.41));

    expect(transient.acceptedCurrentEstimate, isFalse);
    expect(recovered.pitch?.frequencyHz, closeTo(82.41, 0.1));
  });

  test('accepts a repeated octave change', () {
    stabilizer.add(_estimate(110));
    stabilizer.add(_estimate(220));
    final result = stabilizer.add(_estimate(220));

    expect(result.noteChanged, isTrue);
    expect(result.pitch?.frequencyHz, closeTo(220, 0.1));
  });

  test('responds to a deliberate note change after confirmation', () {
    stabilizer.add(_estimate(440));
    stabilizer.add(_estimate(493.88));
    final result = stabilizer.add(_estimate(493.88));

    expect(result.noteChanged, isTrue);
    expect(result.pitch?.noteName, 'B');
  });

  test('retains a short no-pitch gap and clears sustained no-pitch', () {
    stabilizer.add(_estimate(196));
    for (var index = 0; index < 3; index++) {
      final result = stabilizer.add(_noPitch());
      expect(result.pitch, isNotNull);
      expect(result.acceptedCurrentEstimate, isFalse);
    }

    final cleared = stabilizer.add(_noPitch());
    expect(cleared.cleared, isTrue);
    expect(cleared.pitch, isNull);
  });

  test('low-confidence estimates never create a stable pitch', () {
    final lowConfidence = _estimate(440, confidence: 0.4);
    final result = stabilizer.add(lowConfidence);

    expect(result.acceptedCurrentEstimate, isFalse);
    expect(result.pitch, isNull);
  });

  test('note hysteresis resists semitone-boundary flicker', () {
    final midpoint = 440 * math.pow(2, 0.5 / 12);
    stabilizer.add(_estimate(440));
    for (final centsAroundBoundary in [-3.0, 3.0, -2.0, 2.0]) {
      stabilizer.add(
        _estimate(
          (midpoint * math.pow(2, centsAroundBoundary / 1200)).toDouble(),
        ),
      );
    }

    expect(stabilizer.current?.noteName, 'A');
  });

  test('handles low bass and high guitar notes', () {
    stabilizer.add(_estimate(41.2));
    expect(stabilizer.current?.noteName, 'E');
    expect(stabilizer.current?.octave, 1);

    stabilizer.reset();
    stabilizer.add(_estimate(659.25));
    expect(stabilizer.current?.noteName, 'E');
    expect(stabilizer.current?.octave, 5);
  });

  test('custom no-pitch threshold clears deterministically', () {
    final custom = PitchStabilizer(
      configuration: const RealtimePitchConfiguration(noPitchClearCount: 2),
    );
    custom.add(_estimate(329.63));
    custom.add(_noPitch());
    expect(custom.add(_noPitch()).cleared, isTrue);
  });
}

PitchEstimate _estimate(double frequency, {double confidence = 0.95}) {
  final note = MusicalNoteConverter.fromFrequency(frequency)!;
  return PitchEstimate.detected(
    frequencyHz: frequency,
    confidence: confidence,
    midiNote: note.midiNote,
    noteName: note.noteName,
    octave: note.octave,
    centsDeviation: note.centsDeviation,
    periodSamples: 48000 / frequency,
  );
}

PitchEstimate _noPitch() => PitchEstimate.noPitch(NoPitchReason.lowConfidence);

double _frequency(double base, double cents) =>
    base * math.pow(2, cents / 1200);
