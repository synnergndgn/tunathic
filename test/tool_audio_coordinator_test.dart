import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/audio/tool_audio_coordinator.dart';

void main() {
  test('latest metronome acquisition owns delayed tuner release', () async {
    final coordinator = ToolAudioCoordinator();
    final tunerRelease = Completer<void>();
    coordinator.registerTuner(() => tunerRelease.future);

    final oldAcquisition = coordinator.acquireMetronome();
    final newAcquisition = coordinator.acquireMetronome();
    tunerRelease.complete();

    final oldLease = await oldAcquisition;
    final newLease = await newAcquisition;

    expect(coordinator.isCurrent(oldLease), isFalse);
    expect(coordinator.isCurrent(newLease), isTrue);
    expect(coordinator.owner, AudioToolOwner.metronome);
  });

  test('stale release cannot clear newer ownership', () async {
    final coordinator = ToolAudioCoordinator();
    final firstLease = await coordinator.acquireMetronome();
    coordinator.release(firstLease);
    final replacementLease = await coordinator.acquireMetronome();

    coordinator.release(firstLease);

    expect(coordinator.isCurrent(replacementLease), isTrue);
    expect(coordinator.owner, AudioToolOwner.metronome);
  });

  test('tuner acquisition invalidates active metronome ownership', () async {
    final coordinator = ToolAudioCoordinator();
    var metronomeReleaseCount = 0;
    coordinator.registerMetronome(() async {
      metronomeReleaseCount++;
    });
    final metronomeLease = await coordinator.acquireMetronome();

    await coordinator.releaseMetronome();

    expect(metronomeReleaseCount, 1);
    expect(coordinator.isCurrent(metronomeLease), isFalse);
    expect(coordinator.owner, AudioToolOwner.tuner);
  });
}
