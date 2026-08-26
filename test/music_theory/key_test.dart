import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';

void main() {
  group('CircleOfFifths', () {
    test(
      'contains twelve ascending-fifth positions with conventional labels',
      () {
        expect(CircleOfFifths.positions, hasLength(12));
        expect(
          CircleOfFifths.positions.map(
            (position) => position.major.tonic.symbol,
          ),
          ['C', 'G', 'D', 'A', 'E', 'B', 'F#', 'Db', 'Ab', 'Eb', 'Bb', 'F'],
        );
        expect(
          CircleOfFifths.positions.map(
            (position) => position.relativeMinor.tonic.symbol,
          ),
          ['A', 'E', 'B', 'F#', 'C#', 'G#', 'D#', 'Bb', 'F', 'C', 'G', 'D'],
        );

        for (var index = 0; index < CircleOfFifths.positions.length; index++) {
          final current = CircleOfFifths.positions[index];
          final clockwise = CircleOfFifths.clockwiseFrom(current);
          final counterClockwise = CircleOfFifths.counterClockwiseFrom(current);
          expect(
            clockwise.major.tonic.pitchClass,
            current.major.tonic.pitchClass.transpose(7),
          );
          expect(
            counterClockwise.major.tonic.pitchClass,
            current.major.tonic.pitchClass.transpose(5),
          );
        }
      },
    );

    test('wraps clockwise and counter-clockwise', () {
      expect(
        CircleOfFifths.clockwiseFrom(CircleOfFifths.positions.last).index,
        0,
      );
      expect(
        CircleOfFifths.counterClockwiseFrom(
          CircleOfFifths.positions.first,
        ).index,
        11,
      );
    });

    test('groups enharmonic spellings under one pitch-class position', () {
      final tritone = CircleOfFifths.positions[6];
      final next = CircleOfFifths.positions[7];
      expect(tritone.major.tonic.symbol, 'F#');
      expect(tritone.alternateMajor?.tonic.symbol, 'Gb');
      expect(
        tritone.major.tonic.pitchClass,
        tritone.alternateMajor?.tonic.pitchClass,
      );
      expect(next.major.tonic.symbol, 'Db');
      expect(next.alternateMajor?.tonic.symbol, 'C#');
      expect(
        next.major.tonic.pitchClass,
        next.alternateMajor?.tonic.pitchClass,
      );
      expect(
        CircleOfFifths.positionFor(
          _major('Gb', preference: SpellingPreference.flats),
        ).index,
        6,
      );
    });
  });

  group('Key relationships', () {
    test('derives fifths and fourths with contextual spelling', () {
      expect(KeyRelationships.perfectFifthAbove(_pitch('C')).symbol, 'G');
      expect(KeyRelationships.perfectFifthAbove(_pitch('Bb')).symbol, 'F');
      expect(KeyRelationships.perfectFourthAbove(_pitch('C')).symbol, 'F');
      expect(KeyRelationships.perfectFourthAbove(_pitch('F#')).symbol, 'B');
    });

    test('derives relative major and minor without a root table', () {
      for (final pair in {
        'C': 'A',
        'G': 'E',
        'D': 'B',
        'F': 'D',
        'Bb': 'G',
        'Eb': 'C',
      }.entries) {
        final major = _major(pair.key);
        expect(major.relativeKey.tonic.symbol, pair.value);
        expect(major.relativeKey.tonality, KeyTonality.naturalMinor);
        expect(major.relativeKey.relativeKey.tonic, major.tonic);
      }
    });

    test('derives parallel keys when their signatures are representable', () {
      final cMajor = _major('C');
      expect(cMajor.parallelKey, _minor('C'));
      expect(cMajor.parallelKey?.parallelKey, cMajor);
      expect(_minor('D#').parallelKey, isNull);
    });

    test('returns deterministic neighboring keys for major and minor', () {
      expect(CircleOfFifths.clockwiseNeighbor(_major('C')), _major('G'));
      expect(
        CircleOfFifths.counterClockwiseNeighbor(_major('C')).tonic.symbol,
        'F',
      );
      expect(CircleOfFifths.clockwiseNeighbor(_minor('A')).tonic.symbol, 'E');
      expect(
        CircleOfFifths.counterClockwiseNeighbor(_minor('A')).tonic.symbol,
        'D',
      );
    });
  });

  group('KeySignatures', () {
    final cases = <String, ({int fifths, List<String> notes})>{
      'C major': (fifths: 0, notes: []),
      'G major': (fifths: 1, notes: ['F#']),
      'D major': (fifths: 2, notes: ['F#', 'C#']),
      'A major': (fifths: 3, notes: ['F#', 'C#', 'G#']),
      'E major': (fifths: 4, notes: ['F#', 'C#', 'G#', 'D#']),
      'F major': (fifths: -1, notes: ['Bb']),
      'Bb major': (fifths: -2, notes: ['Bb', 'Eb']),
      'Eb major': (fifths: -3, notes: ['Bb', 'Eb', 'Ab']),
      'Ab major': (fifths: -4, notes: ['Bb', 'Eb', 'Ab', 'Db']),
      'A minor': (fifths: 0, notes: []),
      'E minor': (fifths: 1, notes: ['F#']),
      'D minor': (fifths: -1, notes: ['Bb']),
      'C minor': (fifths: -3, notes: ['Bb', 'Eb', 'Ab']),
    };

    for (final entry in cases.entries) {
      test('${entry.key} has the canonical ordered signature', () {
        final parts = entry.key.split(' ');
        final key = parts.last == 'major'
            ? _major(parts.first)
            : _minor(parts.first);
        final signature = key.keySignature;
        expect(signature.fifths, entry.value.fifths);
        expect(signature.accidentalCount, entry.value.fifths.abs());
        expect(
          signature.alteredNotes.map((note) => note.symbol),
          entry.value.notes,
        );
        expect(
          signature.accidental,
          entry.value.fifths > 0
              ? KeySignatureAccidental.sharp
              : entry.value.fifths < 0
              ? KeySignatureAccidental.flat
              : KeySignatureAccidental.none,
        );
      });
    }

    test('supports canonical enharmonic boundaries independently', () {
      expect(_major('F#').keySignature.fifths, 6);
      expect(_major('Gb').keySignature.fifths, -6);
      expect(_major('C#').keySignature.fifths, 7);
      expect(_major('F#').tonic.pitchClass, _major('Gb').tonic.pitchClass);
    });

    test('relative minor shares the major signature', () {
      for (final position in CircleOfFifths.positions) {
        expect(
          position.relativeMinor.keySignature.fifths,
          position.major.keySignature.fifths,
        );
      }
    });
  });
}

MusicalKey _major(
  String tonic, {
  SpellingPreference preference = SpellingPreference.contextual,
}) => MusicalKey(
  tonic: _pitch(tonic),
  tonality: KeyTonality.major,
  preferredSpelling: preference,
);

MusicalKey _minor(
  String tonic, {
  SpellingPreference preference = SpellingPreference.contextual,
}) => MusicalKey(
  tonic: _pitch(tonic),
  tonality: KeyTonality.naturalMinor,
  preferredSpelling: preference,
);

SpelledPitchClass _pitch(String symbol) => SpelledPitchClass.tryParse(symbol)!;
