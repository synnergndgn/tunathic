import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner/domain/tuner_target_selector.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';

void main() {
  late TunerTargetSelector selector;

  setUp(() {
    selector = TunerTargetSelector();
  });

  test('selects the nearest valid target', () {
    expect(
      selector.select(_pitch(110), TuningPresets.standard)?.displayName,
      'A2',
    );
  });

  test('requires sustained evidence before switching strings', () {
    selector.select(_pitch(110), TuningPresets.standard);

    expect(
      selector.select(_pitch(146.832384), TuningPresets.standard)?.displayName,
      'A2',
    );
    expect(
      selector.select(_pitch(146.832384), TuningPresets.standard)?.displayName,
      'D3',
    );
  });

  test('retains current target inside the hysteresis margin', () {
    final a2 = TuningPresets.standard.stringAt(5).frequencyHz;
    selector.select(_pitch(a2), TuningPresets.standard);
    final justPastMidpoint = a2 * math.pow(2, 260 / 1200);

    for (var index = 0; index < 4; index++) {
      selector.select(_pitch(justPastMidpoint), TuningPresets.standard);
    }

    expect(selector.current?.displayName, 'A2');
  });

  test('ignores one isolated octave-like target jump', () {
    selector.select(
      _pitch(TuningPresets.standard.stringAt(6).frequencyHz),
      TuningPresets.standard,
    );

    selector.select(
      _pitch(TunerPitchMath.frequencyForMidi(52)),
      TuningPresets.standard,
    );

    expect(selector.current?.displayName, 'E2');
  });

  test('clears automatic target after sustained no-pitch', () {
    selector.select(_pitch(110), TuningPresets.standard);

    for (var index = 0; index < 7; index++) {
      expect(selector.recordNoPitch(), isNotNull);
    }
    expect(selector.recordNoPitch(), isNull);
  });

  test('avoids a misleading target when signal is far from every string', () {
    final betweenAAndD = (110 * math.pow(2, 250 / 1200)).toDouble();

    expect(
      selector.select(_pitch(betweenAAndD), TuningPresets.standard),
      isNull,
    );
  });

  test('reset and tuning change do not leak the old target', () {
    selector.select(_pitch(82.406889), TuningPresets.standard);
    selector.reset();

    expect(selector.current, isNull);
    expect(
      selector.select(_pitch(73.416192), TuningPresets.dropD)?.displayName,
      'D2',
    );
  });
}

StabilizedPitch _pitch(double frequency) {
  final continuousMidi = 69 + 12 * math.log(frequency / 440) / math.ln2;
  final midi = continuousMidi.round();
  const names = [
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
  return StabilizedPitch(
    frequencyHz: frequency,
    continuousMidi: continuousMidi,
    midiNote: midi,
    noteName: names[midi % 12],
    octave: midi ~/ 12 - 1,
    centsDeviation: (continuousMidi - midi) * 100,
    confidence: 0.98,
  );
}
