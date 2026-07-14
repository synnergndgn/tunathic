import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/musical_note.dart';

void main() {
  test('maps A4 at 440 Hz to MIDI 69 with zero cents', () {
    final note = MusicalNoteConverter.fromFrequency(440)!;

    expect(note.midiNote, 69);
    expect(note.noteName, 'A');
    expect(note.octave, 4);
    expect(note.centsDeviation, closeTo(0, 1e-10));
  });

  test('maps representative bass and guitar notes with sharp names', () {
    final e1 = MusicalNoteConverter.fromFrequency(41.203444)!;
    final cSharp4 = MusicalNoteConverter.fromFrequency(277.182631)!;

    expect((e1.noteName, e1.octave, e1.midiNote), ('E', 1, 28));
    expect((cSharp4.noteName, cSharp4.octave, cSharp4.midiNote), ('C#', 4, 61));
  });

  test('calculates signed cents for sharp and flat frequencies', () {
    final sharp = MusicalNoteConverter.fromFrequency(
      (440 * math.pow(2, 12 / 1200)).toDouble(),
    )!;
    final flat = MusicalNoteConverter.fromFrequency(
      (440 * math.pow(2, -17 / 1200)).toDouble(),
    )!;

    expect(sharp.centsDeviation, closeTo(12, 1e-9));
    expect(flat.centsDeviation, closeTo(-17, 1e-9));
  });

  test('classifies frequencies on either side of a semitone midpoint', () {
    final midpoint = (440 * math.pow(2, 0.5 / 12)).toDouble();
    final below = MusicalNoteConverter.fromFrequency(midpoint * 0.999999)!;
    final above = MusicalNoteConverter.fromFrequency(midpoint * 1.000001)!;

    expect((below.noteName, below.octave), ('A', 4));
    expect((above.noteName, above.octave), ('A#', 4));
    expect(below.centsDeviation, closeTo(50, 0.01));
    expect(above.centsDeviation, closeTo(-50, 0.01));
  });

  test('supports a future non-440 reference frequency', () {
    final note = MusicalNoteConverter.fromFrequency(
      442,
      referenceFrequencyHz: 442,
    )!;

    expect(note.midiNote, 69);
    expect(note.centsDeviation, closeTo(0, 1e-10));
  });

  test('rejects invalid frequency and reference inputs', () {
    expect(
      () => MusicalNoteConverter.fromFrequency(double.nan),
      throwsArgumentError,
    );
    expect(
      () => MusicalNoteConverter.fromFrequency(440, referenceFrequencyHz: 0),
      throwsArgumentError,
    );
  });
}
