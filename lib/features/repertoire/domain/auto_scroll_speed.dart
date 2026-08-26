import 'package:tunathic/features/repertoire/domain/song.dart';

/// Maps the auto-scroll speed level a performer selects to a scroll rate.
///
/// Hands-free scrolling has to stay slow and even, so the level is a plain
/// linear rate rather than an acceleration curve.
abstract final class AutoScrollSpeed {
  static const pixelsPerSecondPerLevel = 8.0;

  static double pixelsPerSecond(int level) =>
      Song.clampScrollSpeedLevel(level) * pixelsPerSecondPerLevel;

  /// The scroll offset after [elapsed] at [level], clamped to [maxOffset].
  static double advance({
    required double offset,
    required Duration elapsed,
    required int level,
    required double maxOffset,
  }) {
    final moved =
        offset +
        pixelsPerSecond(level) *
            elapsed.inMicroseconds /
            Duration.microsecondsPerSecond;
    if (moved < 0) return 0;
    return moved > maxOffset ? maxOffset : moved;
  }
}
