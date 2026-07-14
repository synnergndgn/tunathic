import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_controller.dart';

void main() {
  test('controller reads elapsed time and owns reset behavior', () {
    var elapsed = Duration.zero;
    final container = ProviderContainer(
      overrides: [bpmTapElapsedTimeProvider.overrideWithValue(() => elapsed)],
    );
    addTearDown(container.dispose);

    final controller = container.read(bpmTapProvider.notifier);
    controller.tap();
    elapsed = const Duration(milliseconds: 500);
    controller.tap();
    elapsed = const Duration(seconds: 1);
    controller.tap();

    expect(container.read(bpmTapProvider).bpm, 120);
    expect(container.read(bpmTapProvider).tapCount, 3);

    controller.reset();

    expect(container.read(bpmTapProvider).bpm, isNull);
    expect(container.read(bpmTapProvider).tapCount, 0);
  });
}
