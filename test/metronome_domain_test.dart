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
      (300, Duration(milliseconds: 200)),
    ]) {
      test('calculates beat duration at ${entry.$1} BPM', () {
        expect(MetronomeConfig(bpm: entry.$1).beatDuration, entry.$2);
      });
    }

    test('clamps BPM to the supported range', () {
      expect(MetronomeConfig.clampBpm(5), 20);
      expect(MetronomeConfig.clampBpm(120), 120);
      expect(MetronomeConfig.clampBpm(500), 300);
    });

    test('models 6/8 as six eighth-note pulses', () {
      const signature = MetronomeTimeSignature.sixEight;

      expect(signature.beatsPerMeasure, 6);
      expect(signature.beatUnit, 8);
    });
  });
}
