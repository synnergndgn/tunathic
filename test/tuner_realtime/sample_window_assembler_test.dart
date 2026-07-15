import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner_realtime/domain/sample_window_assembler.dart';

void main() {
  test('validates frame and hop configuration', () {
    expect(
      () => SampleWindowAssembler(frameSize: 0, hopSize: 1),
      throwsArgumentError,
    );
    expect(
      () => SampleWindowAssembler(frameSize: 4, hopSize: 0),
      throwsArgumentError,
    );
    expect(
      () => SampleWindowAssembler(frameSize: 4, hopSize: 5),
      throwsArgumentError,
    );
  });

  test('assembles exact 4096 sample frame', () {
    final assembler = SampleWindowAssembler(frameSize: 4096, hopSize: 1024);
    final input = _sequence(0, 4096);

    final frames = assembler.add(input);

    expect(frames, hasLength(1));
    expect(frames.single, orderedEquals(input));
    expect(assembler.diagnostics.bufferedSamples, 4096);
  });

  test('supports arbitrary chunk boundaries without gaps or duplicates', () {
    final assembler = SampleWindowAssembler(frameSize: 4096, hopSize: 1024);
    final frames = <Float32List>[];
    frames.addAll(assembler.add(_sequence(0, 317)));
    frames.addAll(assembler.add(_sequence(317, 1700)));
    frames.addAll(assembler.add(_sequence(2017, 3079)));
    frames.addAll(assembler.add(_sequence(5096, 1048)));

    expect(frames, hasLength(3));
    expect(frames[0], orderedEquals(_sequence(0, 4096)));
    expect(frames[1], orderedEquals(_sequence(1024, 4096)));
    expect(frames[2], orderedEquals(_sequence(2048, 4096)));
  });

  test('emits several overlapping frames from one large chunk', () {
    final assembler = SampleWindowAssembler(frameSize: 8, hopSize: 2);

    final frames = assembler.add(_sequence(0, 14));

    expect(frames, hasLength(4));
    expect(frames[0], orderedEquals(_sequence(0, 8)));
    expect(frames[1], orderedEquals(_sequence(2, 8)));
    expect(frames[2], orderedEquals(_sequence(4, 8)));
    expect(frames[3], orderedEquals(_sequence(6, 8)));
  });

  test('retains partial samples and resets cleanly', () {
    final assembler = SampleWindowAssembler(frameSize: 8, hopSize: 2);
    expect(assembler.add(_sequence(0, 5)), isEmpty);
    expect(assembler.diagnostics.bufferedSamples, 5);

    assembler.reset();
    final frames = assembler.add(_sequence(100, 8));

    expect(frames.single, orderedEquals(_sequence(100, 8)));
    expect(assembler.diagnostics.resetCount, 1);
  });

  test('memory remains bounded at one frame', () {
    final assembler = SampleWindowAssembler(frameSize: 4096, hopSize: 1024);

    final frames = assembler.add(_sequence(0, 20000));

    expect(frames, hasLength(16));
    expect(assembler.diagnostics.maximumBufferedSamples, 4096);
    expect(assembler.diagnostics.bufferedSamples, 4096);
    expect(assembler.diagnostics.totalSamplesReceived, 20000);
    expect(assembler.diagnostics.samplesDropped, 0);
  });
}

Float32List _sequence(int start, int length) => Float32List.fromList(
  List<double>.generate(length, (index) => (start + index).toDouble()),
);
