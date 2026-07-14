import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/metronome/domain/beat_sequence.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

void main() {
  const sequence = BeatSequence();

  group('BeatSequence', () {
    for (final signature in MetronomeTimeSignature.values) {
      test('${signature.id} progresses and wraps at the measure boundary', () {
        final config = MetronomeConfig(timeSignature: signature);
        var currentBeat = 0;
        final beats = <int>[];

        for (var index = 0; index <= signature.beatsPerMeasure; index++) {
          final beat = sequence.nextBeat(currentBeat, config);
          beats.add(beat.number);
          currentBeat = beat.number;
        }

        expect(beats, [
          ...List.generate(signature.beatsPerMeasure, (index) => index + 1),
          1,
        ]);
      });
    }

    test('accents only the first beat when enabled', () {
      const config = MetronomeConfig();

      expect(sequence.nextBeat(0, config).isAccented, isTrue);
      expect(sequence.nextBeat(1, config).isAccented, isFalse);
    });

    test('disables first-beat accent when configured off', () {
      const config = MetronomeConfig(accentEnabled: false);

      expect(sequence.nextBeat(0, config).isAccented, isFalse);
    });
  });

  group('MetronomeConfig', () {
    for (final entry in <(int, Duration)>[
      (60, Duration(seconds: 1)),
      (120, Duration(milliseconds: 500)),
      (240, Duration(milliseconds: 250)),
    ]) {
      test('calculates 4/4 duration at ${entry.$1} BPM', () {
        expect(MetronomeConfig(bpm: entry.$1).beatDuration, entry.$2);
      });
    }

    for (final entry in <(int, Duration)>[
      (60, Duration(milliseconds: 500)),
      (120, Duration(milliseconds: 250)),
      (240, Duration(milliseconds: 125)),
    ]) {
      test('calculates denominator-aware 6/8 duration at ${entry.$1} BPM', () {
        expect(
          MetronomeConfig(
            bpm: entry.$1,
            timeSignature: MetronomeTimeSignature.sixEight,
          ).beatDuration,
          entry.$2,
        );
      });
    }

    test('clamps BPM to the supported range', () {
      expect(MetronomeConfig.clampBpm(5), 20);
      expect(MetronomeConfig.clampBpm(120), 120);
      expect(MetronomeConfig.clampBpm(500), 300);
    });

    test('models 6/8 as six eighth-note clicks with quarter-note BPM', () {
      const signature = MetronomeTimeSignature.sixEight;

      expect(signature.beatsPerMeasure, 6);
      expect(signature.beatUnit, 8);
    });

    test('6/8 wraps after six clicks and accents the next first beat', () {
      const config = MetronomeConfig(
        timeSignature: MetronomeTimeSignature.sixEight,
      );
      var currentBeat = 0;
      final beats = <MetronomeBeat>[];

      for (var index = 0; index < 7; index++) {
        final beat = sequence.nextBeat(currentBeat, config);
        beats.add(beat);
        currentBeat = beat.number;
      }

      expect(beats.map((beat) => beat.number), [1, 2, 3, 4, 5, 6, 1]);
      expect(beats.map((beat) => beat.isAccented), [
        true,
        false,
        false,
        false,
        false,
        false,
        true,
      ]);
    });
  });
}
