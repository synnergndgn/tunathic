import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';

void main() {
  group('Diatonic triads', () {
    final cases =
        <String, ({List<String> symbols, List<ChordQuality> qualities})>{
          'C major': (
            symbols: ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim'],
            qualities: _majorTriads,
          ),
          'G major': (
            symbols: ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F#dim'],
            qualities: _majorTriads,
          ),
          'F major': (
            symbols: ['F', 'Gm', 'Am', 'Bb', 'C', 'Dm', 'Edim'],
            qualities: _majorTriads,
          ),
          'Bb major': (
            symbols: ['Bb', 'Cm', 'Dm', 'Eb', 'F', 'Gm', 'Adim'],
            qualities: _majorTriads,
          ),
          'A minor': (
            symbols: ['Am', 'Bdim', 'C', 'Dm', 'Em', 'F', 'G'],
            qualities: _minorTriads,
          ),
          'E minor': (
            symbols: ['Em', 'F#dim', 'G', 'Am', 'Bm', 'C', 'D'],
            qualities: _minorTriads,
          ),
          'D minor': (
            symbols: ['Dm', 'Edim', 'F', 'Gm', 'Am', 'Bb', 'C'],
            qualities: _minorTriads,
          ),
        };

    for (final entry in cases.entries) {
      test('derives ${entry.key} from scale degrees', () {
        final harmony = DiatonicHarmonyConstructor.construct(
          _keyFromName(entry.key),
        );
        expect(
          harmony.triads.map((entry) => entry.chord.symbol),
          entry.value.symbols,
        );
        expect(
          harmony.triads.map((entry) => entry.chord.quality),
          entry.value.qualities,
        );
      });
    }
  });

  group('Diatonic seventh chords', () {
    test('derives all seven C Major seventh chords', () {
      final chords = DiatonicHarmonyConstructor.construct(
        _keyFromName('C major'),
      ).seventhChords;
      expect(chords.map((entry) => entry.chord.symbol), [
        'Cmaj7',
        'Dm7',
        'Em7',
        'Fmaj7',
        'G7',
        'Am7',
        'Bm7b5',
      ]);
      expect(chords.map((entry) => entry.romanNumeral.symbol), [
        'Imaj7',
        'ii7',
        'iii7',
        'IVmaj7',
        'V7',
        'vi7',
        'viiø7',
      ]);
    });

    test('derives F Major spelling and half-diminished leading tone', () {
      final chords = DiatonicHarmonyConstructor.construct(
        _keyFromName('F major'),
      ).seventhChords;
      expect(chords.map((entry) => entry.chord.symbol), [
        'Fmaj7',
        'Gm7',
        'Am7',
        'Bbmaj7',
        'C7',
        'Dm7',
        'Em7b5',
      ]);
    });

    test('derives natural-minor sevenths from the actual scale', () {
      final chords = DiatonicHarmonyConstructor.construct(
        _keyFromName('A minor'),
      ).seventhChords;
      expect(chords.map((entry) => entry.chord.symbol), [
        'Am7',
        'Bm7b5',
        'Cmaj7',
        'Dm7',
        'Em7',
        'Fmaj7',
        'G7',
      ]);
      expect(chords.map((entry) => entry.romanNumeral.symbol), [
        'i7',
        'iiø7',
        'IIImaj7',
        'iv7',
        'v7',
        'VImaj7',
        'VII7',
      ]);
      expect(chords[1].chord.quality, ChordQuality.halfDiminishedSeventh);
    });
  });

  group('RomanNumeral', () {
    test('captures degree, case, quality markers, and seventh suffixes', () {
      const major = RomanNumeral(
        degree: 1,
        quality: ChordQuality.major,
        isSeventh: false,
      );
      const minor = RomanNumeral(
        degree: 2,
        quality: ChordQuality.minor,
        isSeventh: false,
      );
      const diminished = RomanNumeral(
        degree: 7,
        quality: ChordQuality.diminished,
        isSeventh: false,
      );
      const halfDiminished = RomanNumeral(
        degree: 7,
        quality: ChordQuality.halfDiminishedSeventh,
        isSeventh: true,
      );
      const majorSeventh = RomanNumeral(
        degree: 4,
        quality: ChordQuality.majorSeventh,
        isSeventh: true,
      );
      const dominant = RomanNumeral(
        degree: 5,
        quality: ChordQuality.dominantSeventh,
        isSeventh: true,
      );

      expect(major.degree, 1);
      expect(major.isUppercase, isTrue);
      expect(major.symbol, 'I');
      expect(minor.isUppercase, isFalse);
      expect(minor.symbol, 'ii');
      expect(diminished.isDiminished, isTrue);
      expect(diminished.symbol, 'vii°');
      expect(halfDiminished.isHalfDiminished, isTrue);
      expect(halfDiminished.symbol, 'viiø7');
      expect(majorSeventh.symbol, 'IVmaj7');
      expect(dominant.symbol, 'V7');
    });
  });
}

const _majorTriads = [
  ChordQuality.major,
  ChordQuality.minor,
  ChordQuality.minor,
  ChordQuality.major,
  ChordQuality.major,
  ChordQuality.minor,
  ChordQuality.diminished,
];

const _minorTriads = [
  ChordQuality.minor,
  ChordQuality.diminished,
  ChordQuality.major,
  ChordQuality.minor,
  ChordQuality.minor,
  ChordQuality.major,
  ChordQuality.major,
];

MusicalKey _keyFromName(String name) {
  final parts = name.split(' ');
  return MusicalKey(
    tonic: SpelledPitchClass.tryParse(parts.first)!,
    tonality: parts.last == 'major'
        ? KeyTonality.major
        : KeyTonality.naturalMinor,
    preferredSpelling: parts.first.contains('b')
        ? SpellingPreference.flats
        : SpellingPreference.contextual,
  );
}
