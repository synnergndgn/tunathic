import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tunathic/features/tuner_pitch/domain/pitch_detector.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';
import 'package:tunathic/features/tuner_realtime/domain/realtime_pitch_configuration.dart';
import 'package:tunathic/features/tuner_realtime/domain/sample_window_assembler.dart';

enum RealtimePitchStatus {
  stopped,
  waitingForSamples,
  analyzing,
  stablePitch,
  unstableSignal,
  noSignal,
  permissionDenied,
  captureError,
  analysisError,
}

abstract interface class PitchDetectionExecutor {
  String get modeLabel;

  Future<PitchEstimate> analyze(Float32List samples, int sampleRate);
}

final class MainIsolatePitchDetectionExecutor
    implements PitchDetectionExecutor {
  const MainIsolatePitchDetectionExecutor(this.detector);

  final PitchDetector detector;

  @override
  String get modeLabel => 'main-isolate';

  @override
  Future<PitchEstimate> analyze(Float32List samples, int sampleRate) =>
      Future<PitchEstimate>(
        () => detector.detect(samples, sampleRate: sampleRate),
      );
}

abstract interface class RealtimeDeadline {
  void cancel();
}

typedef RealtimeDeadlineFactory =
    RealtimeDeadline Function(Duration delay, void Function() callback);
typedef MonotonicTimeReader = Duration Function();

final class RealtimePitchDiagnostics {
  const RealtimePitchDiagnostics({
    required this.samplesReceived,
    required this.bufferedSamples,
    required this.maximumBufferedSamples,
    required this.framesAssembled,
    required this.framesAnalyzed,
    required this.pendingFramesReplaced,
    required this.framesDropped,
    required this.sampleRateResets,
    required this.staleResultClears,
    required this.stabilizerNoteChanges,
    required this.averageDetectorDuration,
    required this.maximumDetectorDuration,
    required this.averageAnalysisInterval,
    required this.executionMode,
  });

  const RealtimePitchDiagnostics.empty({this.executionMode = 'main-isolate'})
    : samplesReceived = 0,
      bufferedSamples = 0,
      maximumBufferedSamples = 0,
      framesAssembled = 0,
      framesAnalyzed = 0,
      pendingFramesReplaced = 0,
      framesDropped = 0,
      sampleRateResets = 0,
      staleResultClears = 0,
      stabilizerNoteChanges = 0,
      averageDetectorDuration = Duration.zero,
      maximumDetectorDuration = Duration.zero,
      averageAnalysisInterval = Duration.zero;

  final int samplesReceived;
  final int bufferedSamples;
  final int maximumBufferedSamples;
  final int framesAssembled;
  final int framesAnalyzed;
  final int pendingFramesReplaced;
  final int framesDropped;
  final int sampleRateResets;
  final int staleResultClears;
  final int stabilizerNoteChanges;
  final Duration averageDetectorDuration;
  final Duration maximumDetectorDuration;
  final Duration averageAnalysisInterval;
  final String executionMode;
}

final class RealtimePitchSnapshot {
  const RealtimePitchSnapshot({
    required this.status,
    required this.sampleRate,
    required this.rawEstimate,
    required this.stabilizedPitch,
    required this.diagnostics,
  });

  factory RealtimePitchSnapshot.stopped({String mode = 'main-isolate'}) =>
      RealtimePitchSnapshot(
        status: RealtimePitchStatus.stopped,
        sampleRate: null,
        rawEstimate: null,
        stabilizedPitch: null,
        diagnostics: RealtimePitchDiagnostics.empty(executionMode: mode),
      );

  final RealtimePitchStatus status;
  final int? sampleRate;
  final PitchEstimate? rawEstimate;
  final StabilizedPitch? stabilizedPitch;
  final RealtimePitchDiagnostics diagnostics;
}

final class RealtimePitchPipeline {
  RealtimePitchPipeline({
    required PitchDetectionExecutor executor,
    required this._monotonicTime,
    required this._onSnapshot,
    required this._onError,
    RealtimePitchConfiguration configuration =
        const RealtimePitchConfiguration(),
    RealtimeDeadlineFactory? deadlineFactory,
  }) : _executor = executor,
       configuration = configuration,
       _deadlineFactory = deadlineFactory ?? _timerDeadline,
       _assembler = SampleWindowAssembler(
         frameSize: configuration.frameSize,
         hopSize: configuration.hopSize,
       ),
       _stabilizer = PitchStabilizer(configuration: configuration),
       _snapshot = RealtimePitchSnapshot.stopped(mode: executor.modeLabel);

  final RealtimePitchConfiguration configuration;
  final PitchDetectionExecutor _executor;
  final MonotonicTimeReader _monotonicTime;
  final void Function(RealtimePitchSnapshot snapshot) _onSnapshot;
  final void Function(Object error, StackTrace stackTrace) _onError;
  final RealtimeDeadlineFactory _deadlineFactory;
  final SampleWindowAssembler _assembler;
  final PitchStabilizer _stabilizer;

  RealtimePitchSnapshot _snapshot;
  _AnalysisFrame? _pendingFrame;
  RealtimeDeadline? _staleDeadline;
  int? _sampleRate;
  int _generation = 0;
  int _framesAnalyzed = 0;
  int _pendingFramesReplaced = 0;
  int _framesDropped = 0;
  int _sampleRateResets = 0;
  int _staleResultClears = 0;
  int _stabilizerNoteChanges = 0;
  int _detectorDurationMicros = 0;
  int _maximumDetectorMicros = 0;
  int _completedAnalyses = 0;
  Duration? _lastAnalysisStartedAt;
  int _analysisIntervalMicros = 0;
  int _analysisIntervalCount = 0;
  bool _running = false;
  bool _analysisActive = false;

  RealtimePitchSnapshot get snapshot => _snapshot;

  void startSession({
    required int sampleRate,
    required int minimumFrameLength,
  }) {
    configuration.validateFrameRequirement(minimumFrameLength);
    _generation++;
    _running = true;
    _sampleRate = sampleRate;
    _pendingFrame = null;
    _staleDeadline?.cancel();
    _staleDeadline = null;
    _assembler.reset(clearDiagnostics: true);
    _stabilizer.reset();
    _framesAnalyzed = 0;
    _pendingFramesReplaced = 0;
    _framesDropped = 0;
    _sampleRateResets = 0;
    _staleResultClears = 0;
    _stabilizerNoteChanges = 0;
    _detectorDurationMicros = 0;
    _maximumDetectorMicros = 0;
    _completedAnalyses = 0;
    _lastAnalysisStartedAt = null;
    _analysisIntervalMicros = 0;
    _analysisIntervalCount = 0;
    _publish(
      status: RealtimePitchStatus.waitingForSamples,
      rawEstimate: null,
      stabilizedPitch: null,
    );
  }

  void updateSampleRate({
    required int sampleRate,
    required int minimumFrameLength,
  }) {
    if (!_running || sampleRate == _sampleRate) return;
    configuration.validateFrameRequirement(minimumFrameLength);
    _generation++;
    _sampleRate = sampleRate;
    if (_pendingFrame != null) {
      _pendingFrame = null;
      _framesDropped++;
    }
    _assembler.recordDroppedSamples(_assembler.diagnostics.bufferedSamples);
    _assembler.reset();
    _stabilizer.reset();
    _staleDeadline?.cancel();
    _staleDeadline = null;
    _sampleRateResets++;
    _publish(
      status: RealtimePitchStatus.waitingForSamples,
      rawEstimate: null,
      stabilizedPitch: null,
    );
  }

  void addSamples(Float32List samples, {required int sampleRate}) {
    if (!_running || samples.isEmpty) return;
    if (sampleRate != _sampleRate) {
      throw StateError('Sample rate must be updated before adding samples.');
    }
    for (final frame in _assembler.add(samples)) {
      _submit(_AnalysisFrame(samples: frame, sampleRate: sampleRate));
    }
    _publishCurrentDiagnostics();
  }

  void stop() {
    if (!_running && _snapshot.status == RealtimePitchStatus.stopped) return;
    _running = false;
    _generation++;
    if (_pendingFrame != null) _framesDropped++;
    _pendingFrame = null;
    _assembler.recordDroppedSamples(_assembler.diagnostics.bufferedSamples);
    _assembler.reset();
    _stabilizer.reset();
    _staleDeadline?.cancel();
    _staleDeadline = null;
    _publish(
      status: RealtimePitchStatus.stopped,
      rawEstimate: null,
      stabilizedPitch: null,
    );
  }

  void _submit(_AnalysisFrame frame) {
    if (_analysisActive) {
      if (_pendingFrame != null) {
        _pendingFramesReplaced++;
        _framesDropped++;
      }
      _pendingFrame = frame;
      return;
    }
    _startAnalysis(frame);
  }

  void _startAnalysis(_AnalysisFrame frame) {
    _analysisActive = true;
    _framesAnalyzed++;
    final generation = _generation;
    final startedAt = _monotonicTime();
    final previousStartedAt = _lastAnalysisStartedAt;
    if (previousStartedAt != null && startedAt >= previousStartedAt) {
      _analysisIntervalMicros += (startedAt - previousStartedAt).inMicroseconds;
      _analysisIntervalCount++;
    }
    _lastAnalysisStartedAt = startedAt;
    _publishCurrentDiagnostics(
      status: _snapshot.status == RealtimePitchStatus.waitingForSamples
          ? RealtimePitchStatus.analyzing
          : _snapshot.status,
    );
    unawaited(_performAnalysis(frame, generation, startedAt));
  }

  Future<void> _performAnalysis(
    _AnalysisFrame frame,
    int generation,
    Duration startedAt,
  ) async {
    try {
      final estimate = await _executor.analyze(frame.samples, frame.sampleRate);
      final duration = _monotonicTime() - startedAt;
      _detectorDurationMicros += duration.inMicroseconds;
      _completedAnalyses++;
      _maximumDetectorMicros = math.max(
        _maximumDetectorMicros,
        duration.inMicroseconds,
      );
      if (_running && generation == _generation) {
        _acceptEstimate(estimate, generation);
      }
    } on Object catch (error, stackTrace) {
      if (_running && generation == _generation) {
        _publish(
          status: RealtimePitchStatus.analysisError,
          rawEstimate: null,
          stabilizedPitch: null,
        );
        _onError(error, stackTrace);
      }
    } finally {
      _analysisActive = false;
      final pending = _pendingFrame;
      _pendingFrame = null;
      if (_running && pending != null) _startAnalysis(pending);
    }
  }

  void _acceptEstimate(PitchEstimate estimate, int generation) {
    final stabilized = _stabilizer.add(estimate);
    if (stabilized.noteChanged) _stabilizerNoteChanges++;
    if (estimate.isDetected) {
      _scheduleStaleDeadline(generation);
    }
    final status = estimate.isDetected && stabilized.pitch != null
        ? RealtimePitchStatus.stablePitch
        : stabilized.pitch != null
        ? RealtimePitchStatus.unstableSignal
        : RealtimePitchStatus.noSignal;
    _publish(
      status: status,
      rawEstimate: estimate,
      stabilizedPitch: stabilized.pitch,
    );
  }

  void _scheduleStaleDeadline(int generation) {
    _staleDeadline?.cancel();
    _staleDeadline = _deadlineFactory(configuration.staleTimeout, () {
      if (!_running || generation != _generation) return;
      _stabilizer.reset();
      _staleResultClears++;
      _publish(
        status: RealtimePitchStatus.noSignal,
        rawEstimate: null,
        stabilizedPitch: null,
      );
    });
  }

  void _publishCurrentDiagnostics({RealtimePitchStatus? status}) {
    _publish(
      status: status ?? _snapshot.status,
      rawEstimate: _snapshot.rawEstimate,
      stabilizedPitch: _snapshot.stabilizedPitch,
    );
  }

  void _publish({
    required RealtimePitchStatus status,
    required PitchEstimate? rawEstimate,
    required StabilizedPitch? stabilizedPitch,
  }) {
    final window = _assembler.diagnostics;
    _snapshot = RealtimePitchSnapshot(
      status: status,
      sampleRate: _sampleRate,
      rawEstimate: rawEstimate,
      stabilizedPitch: stabilizedPitch,
      diagnostics: RealtimePitchDiagnostics(
        samplesReceived: window.totalSamplesReceived,
        bufferedSamples: window.bufferedSamples,
        maximumBufferedSamples: window.maximumBufferedSamples,
        framesAssembled: window.framesEmitted,
        framesAnalyzed: _framesAnalyzed,
        pendingFramesReplaced: _pendingFramesReplaced,
        framesDropped: _framesDropped,
        sampleRateResets: _sampleRateResets,
        staleResultClears: _staleResultClears,
        stabilizerNoteChanges: _stabilizerNoteChanges,
        averageDetectorDuration: _completedAnalyses == 0
            ? Duration.zero
            : Duration(
                microseconds: _detectorDurationMicros ~/ _completedAnalyses,
              ),
        maximumDetectorDuration: Duration(microseconds: _maximumDetectorMicros),
        averageAnalysisInterval: _analysisIntervalCount == 0
            ? Duration.zero
            : Duration(
                microseconds: _analysisIntervalMicros ~/ _analysisIntervalCount,
              ),
        executionMode: _executor.modeLabel,
      ),
    );
    _onSnapshot(_snapshot);
  }

  static RealtimeDeadline _timerDeadline(
    Duration delay,
    void Function() callback,
  ) => _TimerDeadline(Timer(delay, callback));
}

final class _AnalysisFrame {
  const _AnalysisFrame({required this.samples, required this.sampleRate});

  final Float32List samples;
  final int sampleRate;
}

final class _TimerDeadline implements RealtimeDeadline {
  const _TimerDeadline(this.timer);

  final Timer timer;

  @override
  void cancel() => timer.cancel();
}
