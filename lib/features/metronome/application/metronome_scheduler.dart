import 'dart:async';

abstract interface class MetronomeScheduler {
  bool get isRunning;

  void start({required Duration interval, required void Function() onBeat});

  void updateInterval(Duration interval);

  void stop();

  void dispose();
}

final class AnchoredMetronomeScheduler implements MetronomeScheduler {
  Timer? _timer;
  final Stopwatch _clock = Stopwatch();
  Duration _interval = Duration.zero;
  Duration _nextTarget = Duration.zero;
  void Function()? _onBeat;

  @override
  bool get isRunning => _timer != null || _clock.isRunning;

  @override
  void start({required Duration interval, required void Function() onBeat}) {
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
    _interval = interval;
    if (!isRunning) return;
    _timer?.cancel();
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
    _onBeat?.call();
    _nextTarget += _interval;

    // Skip missed targets after a long stall instead of emitting a burst.
    while (_nextTarget <= _clock.elapsed) {
      _nextTarget += _interval;
    }
    _scheduleNext();
  }

  void _scheduleNext() {
    final delay = _nextTarget - _clock.elapsed;
    _timer = Timer(delay.isNegative ? Duration.zero : delay, _fireAndSchedule);
  }
}
