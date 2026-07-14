import 'package:tunathic/features/metronome/domain/metronome_config.dart';

final class MetronomeBeat {
  const MetronomeBeat({required this.number, required this.isAccented});

  final int number;
  final bool isAccented;
}

final class BeatSequence {
  const BeatSequence();

  MetronomeBeat nextBeat(int currentBeat, MetronomeConfig config) {
    final beatCount = config.timeSignature.beatsPerMeasure;
    final number = currentBeat < 1 || currentBeat >= beatCount
        ? 1
        : currentBeat + 1;
    return MetronomeBeat(
      number: number,
      isAccented: config.accentEnabled && number == 1,
    );
  }
}
