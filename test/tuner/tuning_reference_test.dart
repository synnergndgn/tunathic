import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

void main() {
  test('concert pitch is the default', () {
    expect(TuningReference.standard.a4FrequencyHz, 440);
    expect(TuningReference.standard.label, '440');
  });

  test('accepts every whole hertz across the supported range', () {
    for (var hz = 430; hz <= 450; hz++) {
      final reference = TuningReference.tryFrom(hz);
      expect(reference, isNotNull, reason: '$hz Hz should be selectable');
      expect(reference!.a4FrequencyHz, hz);
    }
  });

  test('rejects values outside the supported range', () {
    expect(TuningReference.tryFrom(429), isNull);
    expect(TuningReference.tryFrom(451), isNull);
    expect(TuningReference.tryFrom(0), isNull);
    expect(TuningReference.tryFrom(-440), isNull);
    expect(TuningReference.tryFrom(null), isNull);
    expect(TuningReference.tryFrom(double.nan), isNull);
    expect(TuningReference.tryFrom(double.infinity), isNull);
    expect(TuningReference.tryFrom(double.negativeInfinity), isNull);
  });

  test('resolve falls back to concert pitch instead of throwing', () {
    for (final unusable in <num?>[
      null,
      0,
      -1,
      429,
      451,
      double.nan,
      double.infinity,
    ]) {
      expect(
        TuningReference.resolve(unusable),
        TuningReference.standard,
        reason: '$unusable should fall back to 440 Hz',
      );
    }
    expect(TuningReference.resolve(432).a4FrequencyHz, 432);
  });

  test('parse survives a corrupt stored preference', () {
    expect(TuningReference.parse('432').a4FrequencyHz, 432);
    expect(TuningReference.parse(' 441 ').a4FrequencyHz, 441);
    expect(TuningReference.parse(null), TuningReference.standard);
    expect(TuningReference.parse(''), TuningReference.standard);
    expect(TuningReference.parse('four forty'), TuningReference.standard);
    expect(TuningReference.parse('NaN'), TuningReference.standard);
    expect(TuningReference.parse('1e9'), TuningReference.standard);
  });

  test('stepping stops at the ends of the range', () {
    final lowest = TuningReference.resolve(TuningReference.minimumHz);
    final highest = TuningReference.resolve(TuningReference.maximumHz);

    expect(lowest.canDecrease, isFalse);
    expect(lowest.stepped(-1), lowest);
    expect(lowest.stepped(1).a4FrequencyHz, 431);
    expect(highest.canIncrease, isFalse);
    expect(highest.stepped(1), highest);
    expect(highest.stepped(-1).a4FrequencyHz, 449);
    expect(TuningReference.standard.stepped(-10).a4FrequencyHz, 430);
    expect(TuningReference.standard.stepped(100), highest);
  });

  test('round trips through storage', () {
    for (var hz = 430; hz <= 450; hz++) {
      final reference = TuningReference.resolve(hz);
      expect(TuningReference.parse(reference.storageValue), reference);
    }
  });
}
