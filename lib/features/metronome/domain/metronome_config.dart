enum MetronomeTimeSignature {
  twoFour('2/4', 2, 4),
  threeFour('3/4', 3, 4),
  fourFour('4/4', 4, 4),
  sixEight('6/8', 6, 8);

  const MetronomeTimeSignature(this.id, this.beatsPerMeasure, this.beatUnit);

  final String id;
  final int beatsPerMeasure;
  final int beatUnit;

  static MetronomeTimeSignature fromId(String? id) {
    return values.firstWhere(
      (signature) => signature.id == id,
      orElse: () => MetronomeTimeSignature.fourFour,
    );
  }
}

final class MetronomeConfig {
  const MetronomeConfig({
    this.bpm = defaultBpm,
    this.timeSignature = MetronomeTimeSignature.fourFour,
    this.accentEnabled = true,
    this.volume = defaultVolume,
  }) : assert(bpm >= minimumBpm && bpm <= maximumBpm),
       assert(volume >= 0 && volume <= 1);

  static const minimumBpm = 20;
  static const maximumBpm = 300;
  static const defaultBpm = 120;
  static const defaultVolume = 0.65;

  final int bpm;
  final MetronomeTimeSignature timeSignature;
  final bool accentEnabled;
  final double volume;

  Duration get beatDuration =>
      Duration(microseconds: (Duration.microsecondsPerMinute / bpm).round());

  MetronomeConfig copyWith({
    int? bpm,
    MetronomeTimeSignature? timeSignature,
    bool? accentEnabled,
    double? volume,
  }) {
    return MetronomeConfig(
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      accentEnabled: accentEnabled ?? this.accentEnabled,
      volume: volume ?? this.volume,
    );
  }

  static int clampBpm(int bpm) => bpm.clamp(minimumBpm, maximumBpm);

  @override
  bool operator ==(Object other) {
    return other is MetronomeConfig &&
        other.bpm == bpm &&
        other.timeSignature == timeSignature &&
        other.accentEnabled == accentEnabled &&
        other.volume == volume;
  }

  @override
  int get hashCode => Object.hash(bpm, timeSignature, accentEnabled, volume);
}
