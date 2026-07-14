enum BpmTapEvent { idle, started, accepted, ignored, sessionReset }

final class BpmTapConfig {
  const BpmTapConfig({
    this.minimumBpm = 30,
    this.maximumBpm = 300,
    this.rollingIntervalCount = 8,
    this.minimumIntervalsForEstimate = 2,
    this.inactivityTimeout = const Duration(seconds: 3),
    this.outlierTolerance = 0.20,
  }) : assert(minimumBpm > 0),
       assert(maximumBpm > minimumBpm),
       assert(rollingIntervalCount >= minimumIntervalsForEstimate),
       assert(minimumIntervalsForEstimate >= 2),
       assert(outlierTolerance > 0 && outlierTolerance < 1);

  final int minimumBpm;
  final int maximumBpm;
  final int rollingIntervalCount;
  final int minimumIntervalsForEstimate;
  final Duration inactivityTimeout;
  final double outlierTolerance;

  Duration get minimumInterval =>
      Duration(microseconds: Duration.microsecondsPerMinute ~/ maximumBpm);

  Duration get maximumInterval =>
      Duration(microseconds: Duration.microsecondsPerMinute ~/ minimumBpm);
}

final class BpmTapState {
  const BpmTapState({
    this.tapCount = 0,
    this.bpm,
    this.intervals = const [],
    this.lastTapTimestamp,
    this.lastInterval,
    this.lastEvent = BpmTapEvent.idle,
  });

  final int tapCount;
  final int? bpm;
  final List<Duration> intervals;
  final Duration? lastTapTimestamp;
  final Duration? lastInterval;
  final BpmTapEvent lastEvent;
}

final class BpmTapEngine {
  const BpmTapEngine({this.config = const BpmTapConfig()});

  final BpmTapConfig config;

  BpmTapState recordTap(BpmTapState state, Duration timestamp) {
    final previousTimestamp = state.lastTapTimestamp;
    if (previousTimestamp == null) {
      return _startSession(timestamp, BpmTapEvent.started);
    }

    final interval = timestamp - previousTimestamp;
    if (interval >= config.inactivityTimeout) {
      return _startSession(timestamp, BpmTapEvent.sessionReset);
    }

    if (interval < config.minimumInterval ||
        interval > config.maximumInterval) {
      return BpmTapState(
        tapCount: state.tapCount,
        bpm: state.bpm,
        intervals: state.intervals,
        lastTapTimestamp: state.lastTapTimestamp,
        lastInterval: state.lastInterval,
        lastEvent: BpmTapEvent.ignored,
      );
    }

    final intervals = [...state.intervals, interval];
    if (intervals.length > config.rollingIntervalCount) {
      intervals.removeRange(0, intervals.length - config.rollingIntervalCount);
    }
    final immutableIntervals = List<Duration>.unmodifiable(intervals);

    return BpmTapState(
      tapCount: state.tapCount + 1,
      bpm: estimateBpm(immutableIntervals),
      intervals: immutableIntervals,
      lastTapTimestamp: timestamp,
      lastInterval: interval,
      lastEvent: BpmTapEvent.accepted,
    );
  }

  BpmTapState reset({BpmTapEvent lastEvent = BpmTapEvent.idle}) {
    return BpmTapState(lastEvent: lastEvent);
  }

  int? estimateBpm(List<Duration> intervals) {
    if (intervals.length < config.minimumIntervalsForEstimate) return null;

    final window = intervals.length <= config.rollingIntervalCount
        ? intervals
        : intervals.sublist(intervals.length - config.rollingIntervalCount);
    final sortedMicroseconds =
        window.map((interval) => interval.inMicroseconds).toList()..sort();
    final median = _median(sortedMicroseconds);

    final retained = window.length < 3
        ? sortedMicroseconds
        : sortedMicroseconds.where((value) {
            final deviation = (value - median).abs() / median;
            return deviation <= config.outlierTolerance;
          }).toList();
    final robustValues = retained.length >= 2
        ? retained
        : <int>[median.round()];
    final averageMicroseconds =
        robustValues.reduce((total, value) => total + value) /
        robustValues.length;

    return (Duration.microsecondsPerMinute / averageMicroseconds).round();
  }

  BpmTapState _startSession(Duration timestamp, BpmTapEvent event) {
    return BpmTapState(
      tapCount: 1,
      lastTapTimestamp: timestamp,
      lastEvent: event,
    );
  }

  double _median(List<int> sortedValues) {
    final middle = sortedValues.length ~/ 2;
    if (sortedValues.length.isOdd) return sortedValues[middle].toDouble();
    return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
  }
}
