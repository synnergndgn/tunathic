import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

void main() {
  test('defines all required six-string presets', () {
    expect(TuningPresets.all.map((preset) => preset.id), {
      TuningPresetId.standard,
      TuningPresetId.dropD,
      TuningPresetId.halfStepDown,
      TuningPresetId.fullStepDown,
      TuningPresetId.dadgad,
      TuningPresetId.openG,
      TuningPresetId.openD,
    });
    expect(
      TuningPresets.all.every((preset) => preset.strings.length == 6),
      isTrue,
    );
  });

  test('standard and Drop D targets use the expected MIDI notes', () {
    expect(TuningPresets.standard.strings.map((target) => target.midiNote), [
      40,
      45,
      50,
      55,
      59,
      64,
    ]);
    expect(TuningPresets.dropD.strings.map((target) => target.midiNote), [
      38,
      45,
      50,
      55,
      59,
      64,
    ]);
  });

  test('alternate tuning targets match their documented notes', () {
    expect(
      TuningPresets.halfStepDown.strings.map((target) => target.displayName),
      ['D#2', 'G#2', 'C#3', 'F#3', 'A#3', 'D#4'],
    );
    expect(
      TuningPresets.fullStepDown.strings.map((target) => target.displayName),
      ['D2', 'G2', 'C3', 'F3', 'A3', 'D4'],
    );
    expect(TuningPresets.dadgad.strings.map((target) => target.displayName), [
      'D2',
      'A2',
      'D3',
      'G3',
      'A3',
      'D4',
    ]);
    expect(TuningPresets.openG.strings.map((target) => target.displayName), [
      'D2',
      'G2',
      'D3',
      'G3',
      'B3',
      'D4',
    ]);
    expect(TuningPresets.openD.strings.map((target) => target.displayName), [
      'D2',
      'A2',
      'D3',
      'F#3',
      'A3',
      'D4',
    ]);
  });

  test('target frequency derives from MIDI at A4 equals 440', () {
    expect(TunerPitchMath.frequencyForMidi(69), 440);
    expect(TuningPresets.standard.stringAt(5).frequencyHz, closeTo(110, 1e-9));
    expect(
      TuningPresets.standard.stringAt(6).frequencyHz,
      closeTo(82.406889, 1e-6),
    );
  });

  test('cents calculation is signed and never clamped', () {
    expect(TunerPitchMath.centsBetween(440, 440), closeTo(0, 1e-9));
    expect(
      TunerPitchMath.centsBetween(TunerPitchMath.frequencyForMidi(70), 440),
      closeTo(100, 1e-9),
    );
    expect(TunerPitchMath.centsBetween(220, 440), closeTo(-1200, 1e-9));
  });

  test('cents calculation safely rejects invalid values', () {
    expect(TunerPitchMath.centsBetween(null, 440), isNull);
    expect(TunerPitchMath.centsBetween(0, 440), isNull);
    expect(TunerPitchMath.centsBetween(double.nan, 440), isNull);
    expect(TunerPitchMath.centsBetween(440, double.infinity), isNull);
  });

  test('central thresholds classify direction and accuracy', () {
    const configuration = TunerUiConfiguration();
    expect(configuration.accuracyFor(-5), TunerAccuracy.inTune);
    expect(configuration.accuracyFor(5), TunerAccuracy.inTune);
    expect(configuration.accuracyFor(12), TunerAccuracy.near);
    expect(configuration.accuracyFor(16), TunerAccuracy.out);
    expect(configuration.directionFor(-6), TunerDirection.flat);
    expect(configuration.directionFor(5), TunerDirection.inTune);
    expect(configuration.directionFor(6), TunerDirection.sharp);
  });
}
