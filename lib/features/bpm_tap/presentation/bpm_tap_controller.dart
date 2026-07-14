import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/features/bpm_tap/domain/bpm_tap_engine.dart';

typedef ElapsedTimeReader = Duration Function();

final bpmTapConfigProvider = Provider<BpmTapConfig>(
  (ref) => const BpmTapConfig(),
);

final bpmTapElapsedTimeProvider = Provider<ElapsedTimeReader>((ref) {
  final stopwatch = Stopwatch()..start();
  ref.onDispose(stopwatch.stop);
  return () => stopwatch.elapsed;
});

final bpmTapProvider = NotifierProvider<BpmTapController, BpmTapState>(
  BpmTapController.new,
);

final class BpmTapController extends Notifier<BpmTapState> {
  Timer? _inactivityTimer;
  late final BpmTapEngine _engine;
  late final ElapsedTimeReader _elapsedTime;

  @override
  BpmTapState build() {
    _engine = BpmTapEngine(config: ref.read(bpmTapConfigProvider));
    _elapsedTime = ref.read(bpmTapElapsedTimeProvider);
    ref.onDispose(() => _inactivityTimer?.cancel());
    return _engine.reset();
  }

  void tap() {
    state = _engine.recordTap(state, _elapsedTime());
    _scheduleInactivityReset();
  }

  void reset() {
    _inactivityTimer?.cancel();
    state = _engine.reset();
  }

  void _scheduleInactivityReset() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_engine.config.inactivityTimeout, () {
      state = _engine.reset(lastEvent: BpmTapEvent.sessionReset);
    });
  }
}
