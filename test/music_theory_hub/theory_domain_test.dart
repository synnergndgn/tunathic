import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/features/music_theory/domain/interval_shape.dart';
import 'package:tunathic/features/music_theory/domain/theory_block.dart';
import 'package:tunathic/features/music_theory/domain/theory_interval_facts.dart';
import 'package:tunathic/features/music_theory/domain/theory_library.dart';
import 'package:tunathic/features/music_theory/domain/theory_progress.dart';

void main() {
  group('interval shapes', () {
    test('a shape spans the interval it claims to show', () {
      const tuning = GuitarTuning.standard;
      for (final interval in TheoryInterval.values) {
        final shape = IntervalShapes.findFrom(interval: interval);
        if (shape == null) continue;
        final rootMidi =
            tuning.strings[shape.rootStringIndex].openMidiNote + shape.rootFret;
        final targetMidi =
            tuning.strings[shape.targetStringIndex].openMidiNote +
            shape.targetFret;
        expect(
          targetMidi - rootMidi,
          interval.semitones,
          reason: '${interval.id} shape does not span its own distance',
        );
      }
    });

    test('shapes stay inside a comfortable reach', () {
      for (final interval in TheoryInterval.values) {
        final shape = IntervalShapes.findFrom(interval: interval);
        if (shape == null) continue;
        expect(
          shape.fretSpan.abs(),
          lessThanOrEqualTo(IntervalShapes.maximumReach),
        );
        expect(shape.lowestFret, greaterThanOrEqualTo(0));
      }
    });

    test('a perfect fifth is the familiar one string over, two frets up', () {
      final shape = IntervalShapes.findFrom(
        interval: TheoryInterval.perfectFifth,
        rootStringIndex: 0,
        rootFret: 5,
      )!;
      expect(shape.stringSpan, 1);
      expect(shape.fretSpan, 2);
    });

    test('an octave from the low E crosses two strings and two frets', () {
      final shape = IntervalShapes.findFrom(
        interval: TheoryInterval.octave,
        rootStringIndex: 0,
        rootFret: 5,
      )!;
      expect(shape.stringSpan, 2);
      expect(shape.fretSpan, 2);
    });

    test('a unison stays put', () {
      final shape = IntervalShapes.findFrom(
        interval: TheoryInterval.perfectUnison,
        rootStringIndex: 1,
        rootFret: 5,
      )!;
      expect(shape.stringSpan, 0);
      expect(shape.fretSpan, 0);
    });

    test('out of range requests return nothing rather than a bad shape', () {
      expect(
        IntervalShapes.findFrom(
          interval: TheoryInterval.perfectFifth,
          rootStringIndex: 9,
        ),
        isNull,
      );
      expect(
        IntervalShapes.findFrom(
          interval: TheoryInterval.perfectFifth,
          rootFret: -1,
        ),
        isNull,
      );
    });
  });

  group('interval facts', () {
    test('quality is derived from the interval itself', () {
      expect(
        TheoryInterval.perfectFifth.quality,
        TheoryIntervalQuality.perfect,
      );
      expect(TheoryInterval.minorThird.quality, TheoryIntervalQuality.minor);
      expect(TheoryInterval.majorSixth.quality, TheoryIntervalQuality.major);
      expect(
        TheoryInterval.augmentedFourth.quality,
        TheoryIntervalQuality.augmented,
      );
      expect(
        TheoryInterval.diminishedFifth.quality,
        TheoryIntervalQuality.diminished,
      );
    });

    test('name and quality identifiers follow the interval identifier', () {
      expect(TheoryInterval.minorSeventh.nameId, 'intervalName.minor-seventh');
      expect(TheoryInterval.minorSeventh.qualityId, 'intervalQuality.minor');
    });
  });

  group('worked examples run the shared engine', () {
    test('a scale example spells its own notes', () {
      const block = TheoryScaleExample(
        root: SpelledPitchClass(
          letter: NoteLetter.f,
          accidental: Accidental.natural,
        ),
        definition: ScaleDefinition.major,
      );
      expect(block.scale.tones.map((tone) => tone.symbol), [
        'F',
        'G',
        'A',
        'Bb',
        'C',
        'D',
        'E',
      ]);
    });

    test('a chord example spells its own notes', () {
      const block = TheoryChordExample(
        root: SpelledPitchClass(
          letter: NoteLetter.g,
          accidental: Accidental.natural,
        ),
        quality: ChordQuality.dominantSeventh,
      );
      expect(block.chord.symbol, 'G7');
      expect(block.chord.tones.map((tone) => tone.symbol), [
        'G',
        'B',
        'D',
        'F',
      ]);
    });

    test('an interval profile spells its target from the root', () {
      const block = TheoryIntervalProfile(
        interval: TheoryInterval.minorThird,
        root: SpelledPitchClass(
          letter: NoteLetter.a,
          accidental: Accidental.natural,
        ),
      );
      expect(block.target.symbol, 'C');
    });

    test('a diatonic table produces the Roman numerals of its key', () {
      const block = TheoryDiatonicTable(
        key: MusicalKey(
          tonic: SpelledPitchClass(
            letter: NoteLetter.c,
            accidental: Accidental.natural,
          ),
          tonality: KeyTonality.major,
        ),
      );
      expect(block.chords.map((chord) => chord.romanNumeral.symbol), [
        'I',
        'ii',
        'iii',
        'IV',
        'V',
        'vi',
        'vii°',
      ]);
    });

    test('a fretboard diagram projects the chord it names', () {
      const block = TheoryFretboardDiagram.chord(
        root: SpelledPitchClass(
          letter: NoteLetter.c,
          accidental: Accidental.natural,
        ),
        quality: ChordQuality.major,
      );
      expect(
        block.projection.relations.values.map(
          (relation) => relation.pitch.symbol,
        ),
        containsAll(<String>['C', 'E', 'G']),
      );
    });
  });

  group('progress', () {
    test('a favourite toggles on and off', () {
      const progress = TheoryProgress.empty;
      final added = progress.toggleFavorite('triads');
      expect(added.isFavorite('triads'), isTrue);
      expect(added.toggleFavorite('triads').isFavorite('triads'), isFalse);
    });

    test('recent reading is most recent first and free of duplicates', () {
      final progress = TheoryProgress.empty
          .markViewed('triads')
          .markViewed('modes')
          .markViewed('triads');
      expect(progress.recentIds, ['triads', 'modes']);
    });

    test('recent reading is capped', () {
      var progress = TheoryProgress.empty;
      for (var index = 0; index < TheoryProgress.maximumRecent + 5; index++) {
        progress = progress.markViewed('lesson-$index');
      }
      expect(progress.recentIds, hasLength(TheoryProgress.maximumRecent));
      expect(
        progress.recentIds.first,
        'lesson-${TheoryProgress.maximumRecent + 4}',
      );
    });

    test('unknown lesson identifiers are pruned', () {
      final progress = const TheoryProgress(
        favoriteIds: ['triads', 'retired-lesson'],
        recentIds: ['modes', 'retired-lesson'],
      ).prunedTo(TheoryLibrary.lessonIds);
      expect(progress.favoriteIds, ['triads']);
      expect(progress.recentIds, ['modes']);
    });

    test('stored progress survives a round trip', () {
      const progress = TheoryProgress(
        favoriteIds: ['triads'],
        recentIds: ['modes', 'triads'],
      );
      final restored = TheoryProgress.fromJson(progress.toJson())!;
      expect(restored.favoriteIds, progress.favoriteIds);
      expect(restored.recentIds, progress.recentIds);
    });

    test('malformed stored progress is rejected instead of crashing', () {
      expect(TheoryProgress.fromJson('not a map'), isNull);
      expect(TheoryProgress.fromJson(null), isNull);
      final partial = TheoryProgress.fromJson({
        'favorites': ['triads', 42, ''],
        'recent': 'wrong type',
      })!;
      expect(partial.favoriteIds, ['triads']);
      expect(partial.recentIds, isEmpty);
    });
  });
}
