import 'dart:math' as math;

import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

/// How accidentals are spelled in the readout.
///
/// Only [sharp] is offered in the UI today; the flat table is here so that
/// adding the preference later is a wiring change, not a maths change.
enum NoteSpelling { sharp, flat }

/// A frequency resolved into a note against a [TuningReference].
final class ChromaticPitch {
  const ChromaticPitch({
    required this.frequencyHz,
    required this.continuousMidi,
    required this.midiNote,
    required this.noteName,
    required this.octave,
    required this.cents,
  });

  /// The frequency this reading came from.
  final double frequencyHz;

  /// The unrounded MIDI position, kept so callers can measure drift without
  /// recomputing the logarithm.
  final double continuousMidi;

  final int midiNote;
  final String noteName;
  final int octave;

  /// Deviation from [midiNote]: negative is flat, positive is sharp.
  final double cents;

  /// `E4`, `C#3`.
  String get displayName => '$noteName$octave';

  @override
  String toString() =>
      'ChromaticPitch($displayName, ${cents.toStringAsFixed(1)} cents)';
}

/// Frequency to note, measured against a tuning reference.
///
/// The whole conversion lives here rather than in a widget so it can be tested
/// against a table of frequencies, and so every tuner mode names a note the
/// same way.
abstract final class ChromaticTunerEngine {
  /// Roughly C0. Below this a reading is room rumble, not a played note.
  static const lowestFrequencyHz = 16.0;

  /// Roughly B8, past the top of any instrument this app tunes.
  static const highestFrequencyHz = 8000.0;

  static const lowestMidiNote = 0;
  static const highestMidiNote = 127;

  /// MIDI note 69 is A4, the note the reference frequency names.
  static const referenceMidiNote = 69;

  static const semitonesPerOctave = 12;

  static const sharpNames = <String>[
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

  static const flatNames = <String>[
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  static List<String> namesFor(NoteSpelling spelling) => switch (spelling) {
    NoteSpelling.sharp => sharpNames,
    NoteSpelling.flat => flatNames,
  };

  /// Resolves [frequencyHz] to the nearest note.
  ///
  /// Returns null — rather than throwing or inventing a note — for anything
  /// that cannot be one: a missing reading, NaN, infinity, zero, a negative
  /// frequency, or a frequency outside the instrument range. Callers can pass
  /// a raw detector value straight in.
  static ChromaticPitch? resolve(
    double? frequencyHz, {
    TuningReference reference = TuningReference.standard,
    NoteSpelling spelling = NoteSpelling.sharp,
  }) {
    if (frequencyHz == null || !frequencyHz.isFinite) return null;
    if (frequencyHz < lowestFrequencyHz || frequencyHz > highestFrequencyHz) {
      return null;
    }

    final continuousMidi =
        referenceMidiNote +
        semitonesPerOctave *
            math.log(frequencyHz / reference.a4FrequencyHz) /
            math.ln2;
    if (!continuousMidi.isFinite) return null;

    final midiNote = continuousMidi.round();
    if (midiNote < lowestMidiNote || midiNote > highestMidiNote) return null;

    final names = namesFor(spelling);
    return ChromaticPitch(
      frequencyHz: frequencyHz,
      continuousMidi: continuousMidi,
      midiNote: midiNote,
      noteName: names[midiNote % semitonesPerOctave],
      octave: midiNote ~/ semitonesPerOctave - 1,
      cents: (continuousMidi - midiNote) * 100,
    );
  }
}
