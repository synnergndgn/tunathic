import 'dart:async';

final class MetronomeTick {
  const MetronomeTick({
    required this.intendedDeadline,
    required this.callbackTime,
    required this.lateness,
    required this.skippedDeadlines,
  });

  final Duration intendedDeadline;
  final Duration callbackTime;
  final Duration lateness;
  final int skippedDeadlines;
}

abstract interface class MetronomeScheduler {
  bool get isRunning;

  void start({
    required Duration interval,
    required void Function(MetronomeTick tick) onBeat,
  });

  void updateInterval(Duration interval);

  void stop();

  void dispose();
}

abstract interface class MetronomeClock {
  Duration get elapsed;
  bool get isRunning;

  void reset();
  void start();
  void stop();
}

abstract interface class MetronomeTimer {
  void cancel();
}

typedef MetronomeTimerFactory =
    MetronomeTimer Function(Duration delay, void Function() callback);

final class AnchoredMetronomeScheduler implements MetronomeScheduler {
  AnchoredMetronomeScheduler({
    MetronomeClock? clock,
    MetronomeTimerFactory? timerFactory,
  }) : _clock = clock ?? _StopwatchMetronomeClock(),
       _timerFactory = timerFactory ?? _createTimer;

  final MetronomeClock _clock;
  final MetronomeTimerFactory _timerFactory;
  MetronomeTimer? _timer;
  Duration _interval = Duration.zero;
  Duration _nextTarget = Duration.zero;
  void Function(MetronomeTick tick)? _onBeat;

  @override
  bool get isRunning => _clock.isRunning;

  @override
  void start({
    required Duration interval,
    required void Function(MetronomeTick tick) onBeat,
  }) {
    assert(interval > Duration.zero);
    stop();
    _interval = interval;
    _onBeat = onBeat;
    _clock
      ..reset()
      ..start();
    _nextTarget = Duration.zero;
    _fireAndSchedule();
  }

  @override
  void updateInterval(Duration interval) {
    assert(interval > Duration.zero);
    _interval = interval;
    if (!isRunning) return;

    _timer?.cancel();
    _timer = null;
    _clock
      ..reset()
      ..start();
    _nextTarget = interval;
    _scheduleNext();
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _clock.stop();
    _onBeat = null;
    _nextTarget = Duration.zero;
  }

  @override
  void dispose() => stop();

  void _fireAndSchedule() {
    if (!_clock.isRunning) return;
    _timer = null;

    final intendedDeadline = _nextTarget;
    final callbackTime = _clock.elapsed;
    final rawLateness = callbackTime - intendedDeadline;
    final lateness = rawLateness.isNegative ? Duration.zero : rawLateness;

    _nextTarget = intendedDeadline + _interval;
    var skippedDeadlines = 0;
    while (_nextTarget <= callbackTime) {
      _nextTarget += _interval;
      skippedDeadlines++;
    }

    // Arm the next deadline before state or audio work can occupy this isolate.
    _scheduleNext();
    _onBeat?.call(
      MetronomeTick(
        intendedDeadline: intendedDeadline,
        callbackTime: callbackTime,
        lateness: lateness,
        skippedDeadlines: skippedDeadlines,
      ),
    );
  }

  void _scheduleNext() {
    final delay = _nextTarget - _clock.elapsed;
    _timer = _timerFactory(
      delay.isNegative ? Duration.zero : delay,
      _fireAndSchedule,
    );
  }

  static MetronomeTimer _createTimer(
    Duration delay,
    void Function() callback,
  ) => _DartMetronomeTimer(delay, callback);
}

final class _StopwatchMetronomeClock implements MetronomeClock {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  Duration get elapsed => _stopwatch.elapsed;

  @override
  bool get isRunning => _stopwatch.isRunning;

  @override
  void reset() => _stopwatch.reset();

  @override
  void start() => _stopwatch.start();

  @override
  void stop() => _stopwatch.stop();
}

final class _DartMetronomeTimer implements MetronomeTimer {
  _DartMetronomeTimer(Duration delay, void Function() callback)
    : _timer = Timer(delay, callback);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
