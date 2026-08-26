/// The concert-pitch reference every note and cents calculation is measured
/// against.
///
/// This is a value object rather than a bare double on purpose: there is no
/// way to hand the tuner engine a reference it cannot tune to. Either the
/// value is inside the supported range, or construction rejects it and the
/// caller falls back to [standard]. That is what keeps a corrupt stored
/// preference from reaching the maths.
///
/// The frequency is held as a double even though the picker only offers whole
/// hertz, so that adding half-hertz steps later needs no migration of values
/// already written to disk.
final class TuningReference {
  const TuningReference._(this.a4FrequencyHz);

  /// The lowest reference the tuner accepts.
  static const minimumHz = 430.0;

  /// The highest reference the tuner accepts.
  static const maximumHz = 450.0;

  /// Concert pitch, and the fallback for anything unusable.
  static const defaultHz = 440.0;

  /// The distance between two neighbouring selectable references.
  static const stepHz = 1.0;

  /// A4 = 440 Hz.
  static const standard = TuningReference._(defaultHz);

  /// A4 in hertz.
  final double a4FrequencyHz;

  static bool isSupported(num? frequencyHz) {
    if (frequencyHz == null) return false;
    final value = frequencyHz.toDouble();
    return value.isFinite && value >= minimumHz && value <= maximumHz;
  }

  /// Null when [frequencyHz] is missing, not finite, or outside the range.
  static TuningReference? tryFrom(num? frequencyHz) => isSupported(frequencyHz)
      ? TuningReference._(frequencyHz!.toDouble())
      : null;

  /// Never throws. Null, NaN, infinity, zero and out-of-range values all
  /// become [standard].
  static TuningReference resolve(num? frequencyHz) =>
      tryFrom(frequencyHz) ?? standard;

  /// Reads a stored preference. Unparseable text falls back to [standard].
  static TuningReference parse(String? stored) =>
      resolve(double.tryParse(stored?.trim() ?? ''));

  bool get canDecrease => a4FrequencyHz > minimumHz;

  bool get canIncrease => a4FrequencyHz < maximumHz;

  /// Moves [steps] whole steps, stopping at the ends of the range.
  TuningReference stepped(int steps) =>
      resolve((a4FrequencyHz + steps * stepHz).clamp(minimumHz, maximumHz));

  /// How the value is printed. Whole hertz stay whole.
  String get label => a4FrequencyHz == a4FrequencyHz.roundToDouble()
      ? a4FrequencyHz.toStringAsFixed(0)
      : a4FrequencyHz.toStringAsFixed(1);

  /// How the value is written to preferences.
  String get storageValue => a4FrequencyHz.toString();

  @override
  bool operator ==(Object other) =>
      other is TuningReference && other.a4FrequencyHz == a4FrequencyHz;

  @override
  int get hashCode => a4FrequencyHz.hashCode;

  @override
  String toString() => 'TuningReference(${label}Hz)';
}
