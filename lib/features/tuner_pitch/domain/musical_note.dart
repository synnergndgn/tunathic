import 'dart:math' as math;

final class MusicalNote {
  const MusicalNote({
    required this.midiNote,
    required this.noteName,
    required this.octave,
    required this.centsDeviation,
  });

  final int midiNote;
  final String noteName;
  final int octave;
  final double centsDeviation;
}

abstract final class MusicalNoteConverter {
  static const _sharpNoteNames = [
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

  static MusicalNote? fromFrequency(
    double frequencyHz, {
    double referenceFrequencyHz = 440,
  }) {
    if (!frequencyHz.isFinite || frequencyHz <= 0) {
      throw ArgumentError.value(
        frequencyHz,
        'frequencyHz',
        'Must be finite and greater than zero.',
      );
    }
    if (!referenceFrequencyHz.isFinite || referenceFrequencyHz <= 0) {
      throw ArgumentError.value(
        referenceFrequencyHz,
        'referenceFrequencyHz',
        'Must be finite and greater than zero.',
      );
    }

    final continuousMidi =
        69 + 12 * (math.log(frequencyHz / referenceFrequencyHz) / math.ln2);
    final nearestMidi = continuousMidi.round();
    if (nearestMidi < 0 || nearestMidi > 127) return null;

    final noteClass = nearestMidi % _sharpNoteNames.length;
    return MusicalNote(
      midiNote: nearestMidi,
      noteName: _sharpNoteNames[noteClass],
      octave: nearestMidi ~/ _sharpNoteNames.length - 1,
      centsDeviation: (continuousMidi - nearestMidi) * 100,
    );
  }
}
