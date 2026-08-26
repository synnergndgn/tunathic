import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

void main() {
  group('MetronomeConfig', () {
    for (final entry in <(int, Duration)>[
      (40, Duration(milliseconds: 1500)),
      (60, Duration(seconds: 1)),
      (90, Duration(microseconds: 666667)),
      (120, Duration(milliseconds: 500)),
      (160, Duration(milliseconds: 375)),
      (200, Duration(milliseconds: 300)),
      (300, Duration(milliseconds: 200)),
    ]) {
      test('calculates 4/4 duration at ${entry.$1} BPM', () {
        expect(MetronomeConfig(bpm: entry.$1).beatDuration, entry.$2);
      });
    }

    for (final entry in <(int, Duration)>[
      (40, Duration(milliseconds: 750)),
      (60, Duration(milliseconds: 500)),
      (90, Duration(microseconds: 333333)),
      (120, Duration(milliseconds: 250)),
      (160, Duration(microseconds: 187500)),
      (200, Duration(milliseconds: 150)),
      (300, Duration(milliseconds: 100)),
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

    test('every supported signature has a stable persisted identifier', () {
      expect(MetronomeTimeSignature.values.map((signature) => signature.id), [
        '2/4',
        '3/4',
        '4/4',
        '6/8',
      ]);
    });
  });
}
