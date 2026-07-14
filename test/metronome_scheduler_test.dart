import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/metronome/application/metronome_scheduler.dart';

void main() {
  const interval = Duration(milliseconds: 500);
  late FakeMetronomeClock clock;
  late FakeMetronomeTimers timers;
  late AnchoredMetronomeScheduler scheduler;
  late List<MetronomeTick> ticks;

  setUp(() {
    clock = FakeMetronomeClock();
    timers = FakeMetronomeTimers();
    scheduler = AnchoredMetronomeScheduler(
      clock: clock,
      timerFactory: timers.create,
    );
    ticks = [];
  });

  void start() => scheduler.start(interval: interval, onBeat: ticks.add);

  test('fires the first beat immediately and later beats on deadline', () {
    start();

    expect(ticks.single.intendedDeadline, Duration.zero);
    expect(ticks.single.callbackTime, Duration.zero);
    expect(ticks.single.lateness, Duration.zero);
    expect(timers.singleActive.delay, interval);

    clock.advance(interval);
    timers.fireActive();

    expect(ticks.last.intendedDeadline, interval);
    expect(ticks.last.callbackTime, interval);
    expect(ticks.last.lateness, Duration.zero);
    expect(ticks.last.skippedDeadlines, 0);
  });

  test('a mildly late callback keeps the original future deadline', () {
    start();

    clock.advance(const Duration(milliseconds: 600));
    timers.fireActive();

    expect(ticks.last.intendedDeadline, interval);
    expect(ticks.last.lateness, const Duration(milliseconds: 100));
    expect(ticks.last.skippedDeadlines, 0);
    expect(timers.singleActive.delay, const Duration(milliseconds: 400));

    clock.advance(const Duration(milliseconds: 400));
    timers.fireActive();

    expect(ticks.last.intendedDeadline, const Duration(seconds: 1));
    expect(ticks.last.callbackTime, const Duration(seconds: 1));
    expect(ticks.last.lateness, Duration.zero);
  });

  test('a callback delayed beyond one interval skips missed deadlines', () {
    start();

    clock.advance(const Duration(milliseconds: 1300));
    timers.fireActive();

    expect(ticks, hasLength(2));
    expect(ticks.last.intendedDeadline, interval);
    expect(ticks.last.lateness, const Duration(milliseconds: 800));
    expect(ticks.last.skippedDeadlines, 1);
    expect(timers.singleActive.delay, const Duration(milliseconds: 200));
  });

  test('a delayed callback never creates a catch-up burst', () {
    start();

    clock.advance(const Duration(seconds: 3));
    timers.fireActive();

    expect(ticks, hasLength(2));
    expect(ticks.last.skippedDeadlines, 5);
    expect(timers.activeCount, 1);
    expect(timers.singleActive.delay, interval);
  });

  test('tempo changes cancel the old timer and re-anchor safely', () {
    start();
    final oldTimer = timers.singleActive;
    clock.advance(const Duration(milliseconds: 200));

    scheduler.updateInterval(const Duration(milliseconds: 400));

    expect(oldTimer.isActive, isFalse);
    expect(clock.elapsed, Duration.zero);
    expect(timers.activeCount, 1);
    expect(timers.singleActive.delay, const Duration(milliseconds: 400));

    clock.advance(const Duration(milliseconds: 400));
    timers.fireActive();
    expect(ticks.last.intendedDeadline, const Duration(milliseconds: 400));
    expect(ticks.last.callbackTime, const Duration(milliseconds: 400));
  });

  test('rapid stop and start leaves only one live timer', () {
    start();
    final oldTimer = timers.singleActive;

    scheduler.stop();
    scheduler.start(interval: interval, onBeat: ticks.add);

    expect(oldTimer.isActive, isFalse);
    expect(timers.activeCount, 1);
    expect(ticks, hasLength(2));
    oldTimer.fire();
    expect(ticks, hasLength(2));
  });
}

final class FakeMetronomeClock implements MetronomeClock {
  @override
  Duration elapsed = Duration.zero;

  @override
  bool isRunning = false;

  void advance(Duration duration) {
    if (isRunning) elapsed += duration;
  }

  @override
  void reset() => elapsed = Duration.zero;

  @override
  void start() => isRunning = true;

  @override
  void stop() => isRunning = false;
}

final class FakeMetronomeTimers {
  final List<FakeMetronomeTimer> timers = [];

  int get activeCount => timers.where((timer) => timer.isActive).length;

  FakeMetronomeTimer get singleActive =>
      timers.where((timer) => timer.isActive).single;

  MetronomeTimer create(Duration delay, void Function() callback) {
    final timer = FakeMetronomeTimer(delay, callback);
    timers.add(timer);
    return timer;
  }

  void fireActive() => singleActive.fire();
}

final class FakeMetronomeTimer implements MetronomeTimer {
  FakeMetronomeTimer(this.delay, this._callback);

  final Duration delay;
  final void Function() _callback;

  bool isActive = true;

  @override
  void cancel() => isActive = false;

  void fire() {
    if (!isActive) return;
    isActive = false;
    _callback();
  }
}
