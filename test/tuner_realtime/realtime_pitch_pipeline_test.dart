import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_pitch/domain/musical_note.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';
import 'package:tunathic/features/tuner_realtime/application/realtime_pitch_pipeline.dart';
import 'package:tunathic/features/tuner_realtime/domain/realtime_pitch_configuration.dart';

void main() {
  late _ControlledExecutor executor;
  late _FakeClock clock;
  late _FakeDeadlineScheduler deadlines;
  late List<RealtimePitchSnapshot> snapshots;
  late List<Object> errors;
  late RealtimePitchPipeline pipeline;

  setUp(() {
    executor = _ControlledExecutor();
    clock = _FakeClock();
    deadlines = _FakeDeadlineScheduler();
    snapshots = [];
    errors = [];
    pipeline = RealtimePitchPipeline(
      executor: executor,
      monotonicTime: clock.read,
      configuration: const RealtimePitchConfiguration(
        frameSize: 4,
        hopSize: 2,
        staleTimeout: Duration(milliseconds: 300),
      ),
      deadlineFactory: deadlines.schedule,
      onSnapshot: snapshots.add,
      onError: (error, _) => errors.add(error),
    );
  });

  test('keeps one active analysis and only the newest pending frame', () async {
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(0, 10), sampleRate: 48000);

    expect(executor.requests, hasLength(1));
    expect(executor.maximumActive, 1);
    expect(pipeline.snapshot.diagnostics.pendingFramesReplaced, 2);
    expect(pipeline.snapshot.diagnostics.framesDropped, 2);

    executor.complete(0, _estimate(440));
    await _flushMicrotasks();
    expect(executor.requests, hasLength(2));
    expect(executor.requests[1].samples, orderedEquals(_sequence(6, 4)));

    executor.complete(1, _estimate(440));
    await _flushMicrotasks();
    expect(executor.maximumActive, 1);
    expect(pipeline.snapshot.diagnostics.framesAnalyzed, 2);
  });

  test('stop clears pending work and ignores a late result', () async {
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(0, 8), sampleRate: 48000);
    pipeline.stop();

    executor.complete(0, _estimate(440));
    await _flushMicrotasks();

    expect(pipeline.snapshot.status, RealtimePitchStatus.stopped);
    expect(pipeline.snapshot.stabilizedPitch, isNull);
    expect(executor.requests, hasLength(1));
  });

  test('old-session result is ignored after restart', () async {
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(0, 4), sampleRate: 48000);
    pipeline.stop();
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(100, 4), sampleRate: 48000);

    executor.complete(0, _estimate(110));
    await _flushMicrotasks();
    expect(executor.requests, hasLength(2));
    expect(pipeline.snapshot.stabilizedPitch, isNull);

    executor.complete(1, _estimate(220));
    await _flushMicrotasks();
    expect(pipeline.snapshot.stabilizedPitch?.frequencyHz, closeTo(220, 0.1));
  });

  test('sample-rate change resets partial samples and smoothing', () async {
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(0, 2), sampleRate: 48000);

    pipeline.updateSampleRate(sampleRate: 44100, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(100, 4), sampleRate: 44100);

    expect(executor.requests.single.sampleRate, 44100);
    expect(executor.requests.single.samples, orderedEquals(_sequence(100, 4)));
    expect(pipeline.snapshot.diagnostics.sampleRateResets, 1);
  });

  test('stale deadline clears the last stable pitch', () async {
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(0, 4), sampleRate: 48000);
    executor.complete(0, _estimate(329.63));
    await _flushMicrotasks();
    expect(pipeline.snapshot.stabilizedPitch, isNotNull);

    deadlines.fireLatest();

    expect(pipeline.snapshot.status, RealtimePitchStatus.noSignal);
    expect(pipeline.snapshot.stabilizedPitch, isNull);
    expect(pipeline.snapshot.diagnostics.staleResultClears, 1);
  });

  test('detector failure is exposed without starting another queue', () async {
    pipeline.startSession(sampleRate: 48000, minimumFrameLength: 4);
    pipeline.addSamples(_sequence(0, 6), sampleRate: 48000);
    executor.completeError(0, StateError('detector failed'));
    await _flushMicrotasks();

    expect(errors, hasLength(1));
    expect(
      snapshots.any((item) => item.status == RealtimePitchStatus.analysisError),
      isTrue,
    );
    expect(executor.maximumActive, 1);
  });

  test('rejects frames that do not satisfy detector minimum', () {
    expect(
      () => pipeline.startSession(sampleRate: 48000, minimumFrameLength: 5),
      throwsArgumentError,
    );
  });
}

final class _ControlledExecutor implements PitchDetectionExecutor {
  final List<_Request> requests = [];
  int active = 0;
  int maximumActive = 0;

  @override
  String get modeLabel => 'fake-main-isolate';

  @override
  Future<PitchEstimate> analyze(Float32List samples, int sampleRate) {
    final completer = Completer<PitchEstimate>();
    requests.add(
      _Request(samples: samples, sampleRate: sampleRate, completer: completer),
    );
    active++;
    if (active > maximumActive) maximumActive = active;
    return completer.future.whenComplete(() => active--);
  }

  void complete(int index, PitchEstimate estimate) {
    requests[index].completer.complete(estimate);
  }

  void completeError(int index, Object error) {
    requests[index].completer.completeError(error, StackTrace.current);
  }
}

final class _Request {
  const _Request({
    required this.samples,
    required this.sampleRate,
    required this.completer,
  });

  final Float32List samples;
  final int sampleRate;
  final Completer<PitchEstimate> completer;
}

final class _FakeClock {
  Duration elapsed = Duration.zero;
  Duration read() => elapsed;
}

final class _FakeDeadlineScheduler {
  final List<_FakeDeadline> deadlines = [];

  RealtimeDeadline schedule(Duration _, void Function() callback) {
    final deadline = _FakeDeadline(callback);
    deadlines.add(deadline);
    return deadline;
  }

  void fireLatest() => deadlines.last.fire();
}

final class _FakeDeadline implements RealtimeDeadline {
  _FakeDeadline(this.callback);

  final void Function() callback;
  bool canceled = false;

  void fire() {
    if (!canceled) callback();
  }

  @override
  void cancel() => canceled = true;
}

PitchEstimate _estimate(double frequency) {
  final note = MusicalNoteConverter.fromFrequency(frequency)!;
  return PitchEstimate.detected(
    frequencyHz: frequency,
    confidence: 0.95,
    midiNote: note.midiNote,
    noteName: note.noteName,
    octave: note.octave,
    centsDeviation: note.centsDeviation,
    periodSamples: 48000 / frequency,
  );
}

Float32List _sequence(int start, int length) => Float32List.fromList(
  List<double>.generate(length, (index) => (start + index).toDouble()),
);

Future<void> _flushMicrotasks() async {
  for (var index = 0; index < 8; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}
