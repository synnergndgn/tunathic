import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/bpm_tap/domain/bpm_tap_engine.dart';

void main() {
  const engine = BpmTapEngine();

  group('BpmTapEngine', () {
    test('requires more than one interval for an estimate', () {
      var state = engine.recordTap(const BpmTapState(), Duration.zero);
      state = engine.recordTap(state, const Duration(seconds: 1));

      expect(state.tapCount, 2);
      expect(state.intervals, hasLength(1));
      expect(state.bpm, isNull);
    });

    for (final entry in <(int, Duration)>[
      (60, Duration(seconds: 1)),
      (120, Duration(milliseconds: 500)),
      (180, Duration(microseconds: 333333)),
    ]) {
      test('estimates stable ${entry.$1} BPM tapping', () {
        final state = _tapAtInterval(engine, entry.$2, tapCount: 6);

        expect(state.bpm, entry.$1);
        expect(state.tapCount, 6);
      });
    }

    test('uses only the latest eight intervals', () {
      final intervals = [
        ...List.filled(8, const Duration(milliseconds: 500)),
        ...List.filled(8, const Duration(seconds: 1)),
      ];

      expect(engine.estimateBpm(intervals), 60);
    });

    test('starts a new session after inactivity', () {
      var state = engine.recordTap(const BpmTapState(), Duration.zero);
      state = engine.recordTap(state, const Duration(seconds: 3));

      expect(state.tapCount, 1);
      expect(state.intervals, isEmpty);
      expect(state.bpm, isNull);
      expect(state.lastEvent, BpmTapEvent.sessionReset);
    });

    test('ignores intervals outside the 30 to 300 BPM range', () {
      var state = engine.recordTap(const BpmTapState(), Duration.zero);
      state = engine.recordTap(state, const Duration(milliseconds: 100));

      expect(state.tapCount, 1);
      expect(state.lastTapTimestamp, Duration.zero);
      expect(state.lastEvent, BpmTapEvent.ignored);

      state = engine.recordTap(state, const Duration(milliseconds: 500));
      final acceptedTimestamp = state.lastTapTimestamp;
      state = engine.recordTap(state, const Duration(milliseconds: 2700));

      expect(state.tapCount, 2);
      expect(state.lastTapTimestamp, acceptedTimestamp);
      expect(state.lastEvent, BpmTapEvent.ignored);
    });

    test('resists an isolated valid-range timing spike', () {
      final intervals = [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 200),
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 500),
      ];

      expect(engine.estimateBpm(intervals), 120);
    });

    test('reset clears the entire session', () {
      final active = _tapAtInterval(
        engine,
        const Duration(milliseconds: 500),
        tapCount: 4,
      );
      final reset = engine.reset();

      expect(active.bpm, 120);
      expect(reset.tapCount, 0);
      expect(reset.bpm, isNull);
      expect(reset.intervals, isEmpty);
      expect(reset.lastTapTimestamp, isNull);
      expect(reset.lastInterval, isNull);
      expect(reset.lastEvent, BpmTapEvent.idle);
    });
  });
}

BpmTapState _tapAtInterval(
  BpmTapEngine engine,
  Duration interval, {
  required int tapCount,
}) {
  var timestamp = Duration.zero;
  var state = engine.recordTap(const BpmTapState(), timestamp);
  for (var tap = 1; tap < tapCount; tap++) {
    timestamp += interval;
    state = engine.recordTap(state, timestamp);
  }
  return state;
}
