import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner/domain/chromatic_tuner_engine.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

void main() {
  test('names the reference frequency A4 with no deviation', () {
    final resolved = ChromaticTunerEngine.resolve(440);

    expect(resolved, isNotNull);
    expect(resolved!.displayName, 'A4');
    expect(resolved.midiNote, 69);
    expect(resolved.cents, closeTo(0, 0.001));
  });

  test('a shifted reference renames its own frequency A4', () {
    final reference = TuningReference.resolve(432);

    final resolved = ChromaticTunerEngine.resolve(432, reference: reference);

    expect(resolved!.displayName, 'A4');
    expect(resolved.cents, closeTo(0, 0.001));
  });

  test('octaves of the reference stay in tune', () {
    for (final frequency in [110.0, 220.0, 880.0, 1760.0]) {
      final resolved = ChromaticTunerEngine.resolve(frequency)!;
      expect(resolved.noteName, 'A');
      expect(resolved.cents, closeTo(0, 0.001), reason: '$frequency Hz');
    }
    expect(ChromaticTunerEngine.resolve(220)!.displayName, 'A3');
    expect(ChromaticTunerEngine.resolve(880)!.displayName, 'A5');
  });

  test('names notes across the chromatic scale', () {
    final expected = {
      261.63: 'C4',
      277.18: 'C#4',
      293.66: 'D4',
      311.13: 'D#4',
      329.63: 'E4',
      349.23: 'F4',
      369.99: 'F#4',
      392.00: 'G4',
      415.30: 'G#4',
      466.16: 'A#4',
      493.88: 'B4',
      82.41: 'E2',
    };

    for (final entry in expected.entries) {
      final resolved = ChromaticTunerEngine.resolve(entry.key)!;
      expect(resolved.displayName, entry.value, reason: '${entry.key} Hz');
      // Equal-temperament tables are rounded to two decimals, so the reading
      // is expected to land within a couple of cents, not exactly on zero.
      expect(resolved.cents.abs(), lessThan(2), reason: '${entry.key} Hz');
    }
  });

  test('reports the direction a string is off by', () {
    final flat = ChromaticTunerEngine.resolve(438)!;
    final sharp = ChromaticTunerEngine.resolve(442)!;

    expect(flat.displayName, 'A4');
    expect(flat.cents, lessThan(0));
    expect(flat.cents, closeTo(-7.9, 0.2));
    expect(sharp.displayName, 'A4');
    expect(sharp.cents, greaterThan(0));
    expect(sharp.cents, closeTo(7.9, 0.2));
  });

  test('a shifted reference moves every note it names', () {
    final reference = TuningReference.resolve(432);

    // 440 Hz is a touch sharp of A4 once A4 has been redefined as 432 Hz.
    final resolved = ChromaticTunerEngine.resolve(440, reference: reference)!;

    expect(resolved.displayName, 'A4');
    expect(resolved.cents, closeTo(31.8, 0.2));
  });

  test('unusable frequencies resolve to nothing rather than throwing', () {
    for (final unusable in <double?>[
      null,
      0,
      -1,
      -440,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      0.0001,
      100000,
    ]) {
      expect(
        ChromaticTunerEngine.resolve(unusable),
        isNull,
        reason: '$unusable should not name a note',
      );
    }
  });

  test('the instrument range is inclusive at both ends', () {
    expect(
      ChromaticTunerEngine.resolve(ChromaticTunerEngine.lowestFrequencyHz),
      isNotNull,
    );
    expect(
      ChromaticTunerEngine.resolve(ChromaticTunerEngine.highestFrequencyHz),
      isNotNull,
    );
    expect(
      ChromaticTunerEngine.resolve(
        ChromaticTunerEngine.lowestFrequencyHz - 0.01,
      ),
      isNull,
    );
  });

  test('every resolved note stays inside MIDI range at any reference', () {
    for (var hz = 430; hz <= 450; hz++) {
      final reference = TuningReference.resolve(hz);
      for (final frequency in [16.0, 100.0, 440.0, 2000.0, 8000.0]) {
        final resolved = ChromaticTunerEngine.resolve(
          frequency,
          reference: reference,
        );
        if (resolved == null) continue;
        expect(resolved.midiNote, inInclusiveRange(0, 127));
        expect(resolved.cents.abs(), lessThanOrEqualTo(50.001));
      }
    }
  });

  test('flat spelling is available for a future preference', () {
    final sharp = ChromaticTunerEngine.resolve(277.18)!;
    final flat = ChromaticTunerEngine.resolve(
      277.18,
      spelling: NoteSpelling.flat,
    )!;

    expect(sharp.displayName, 'C#4');
    expect(flat.displayName, 'Db4');
    expect(flat.midiNote, sharp.midiNote);
    expect(flat.cents, sharp.cents);
  });
}
