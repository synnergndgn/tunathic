import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/tuner_audio/audio/record_tuner_audio_input.dart';
import 'package:tunathic/features/tuner_audio/audio/tuner_audio_input.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_frame.dart';
import 'package:tunathic/features/tuner_audio/domain/audio_input_configuration.dart';
import 'package:tunathic/features/tuner_audio/domain/pcm16_converter.dart';
import 'package:tunathic/features/tuner_audio/domain/signal_statistics.dart';
import 'package:tunathic/features/tuner_pitch/domain/pitch_detector_configuration.dart';
import 'package:tunathic/features/tuner_pitch/dsp/yin_pitch_detector.dart';
import 'package:tunathic/features/tuner_realtime/application/realtime_pitch_pipeline.dart';
import 'package:tunathic/features/tuner_realtime/domain/realtime_pitch_configuration.dart';

enum TunerCaptureStatus {
  idle,
  requestingPermission,
  starting,
  capturing,
  stopping,
  error,
}

enum TunerPermissionStatus { notRequested, granted, denied }

enum TunerCaptureFailure {
  permissionDenied,
  unsupportedConfiguration,
  startFailed,
  streamFailed,
  analysisFailed,
  stopFailed,
}

enum TunerCaptureStopReason { user, lifecycle, navigation, streamError }

final class TunerAudioState {
  const TunerAudioState({
    this.status = TunerCaptureStatus.idle,
    this.permissionStatus = TunerPermissionStatus.notRequested,
    this.requestedConfiguration = const AudioInputConfiguration(),
    this.reportedFormat,
    this.statistics = const SignalStatistics.empty(),
    this.realtime = const RealtimePitchSnapshot(
      status: RealtimePitchStatus.stopped,
      sampleRate: null,
      rawEstimate: null,
      stabilizedPitch: null,
      diagnostics: RealtimePitchDiagnostics.empty(),
    ),
    this.failure,
  });

  final TunerCaptureStatus status;
  final TunerPermissionStatus permissionStatus;
  final AudioInputConfiguration requestedConfiguration;
  final AudioStreamFormat? reportedFormat;
  final SignalStatistics statistics;
  final RealtimePitchSnapshot realtime;
  final TunerCaptureFailure? failure;

  RealtimePitchStatus get analysisStatus {
    if (permissionStatus == TunerPermissionStatus.denied) {
      return RealtimePitchStatus.permissionDenied;
    }
    if (failure == TunerCaptureFailure.analysisFailed) {
      return RealtimePitchStatus.analysisError;
    }
    if (failure != null) return RealtimePitchStatus.captureError;
    return realtime.status;
  }

  bool get isBusy => switch (status) {
    TunerCaptureStatus.requestingPermission ||
    TunerCaptureStatus.starting ||
    TunerCaptureStatus.stopping => true,
    _ => false,
  };

  bool get canStop => switch (status) {
    TunerCaptureStatus.requestingPermission ||
    TunerCaptureStatus.starting ||
    TunerCaptureStatus.capturing => true,
    _ => false,
  };

  TunerAudioState copyWith({
    TunerCaptureStatus? status,
    TunerPermissionStatus? permissionStatus,
    AudioStreamFormat? reportedFormat,
    SignalStatistics? statistics,
    RealtimePitchSnapshot? realtime,
    TunerCaptureFailure? failure,
    bool clearFailure = false,
    bool clearReportedFormat = false,
  }) {
    return TunerAudioState(
      status: status ?? this.status,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      requestedConfiguration: requestedConfiguration,
      reportedFormat: clearReportedFormat
          ? null
          : reportedFormat ?? this.reportedFormat,
      statistics: statistics ?? this.statistics,
      realtime: realtime ?? this.realtime,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

typedef TunerAudioInputFactory = TunerAudioInput Function();
typedef StopMetronomeBeforeCapture = Future<void> Function();

final tunerAudioInputFactoryProvider = Provider<TunerAudioInputFactory>(
  (ref) => RecordTunerAudioInput.new,
);

final stopMetronomeBeforeCaptureProvider = Provider<StopMetronomeBeforeCapture>(
  (ref) => ref.read(metronomeProvider.notifier).releaseAudio,
);

final pitchDetectionExecutorProvider = Provider<PitchDetectionExecutor>(
  (ref) => MainIsolatePitchDetectionExecutor(YinPitchDetector()),
);

final tunerRealtimeClockProvider = Provider<MonotonicTimeReader>((ref) {
  final stopwatch = Stopwatch()..start();
  ref.onDispose(stopwatch.stop);
  return () => stopwatch.elapsed;
});

final tunerRealtimeConfigurationProvider = Provider<RealtimePitchConfiguration>(
  (ref) => const RealtimePitchConfiguration(),
);

final tunerAudioProvider =
    NotifierProvider.autoDispose<TunerAudioController, TunerAudioState>(
      TunerAudioController.new,
    );

final class TunerAudioController extends Notifier<TunerAudioState> {
  static const uiUpdateInterval = Duration(milliseconds: 100);

  late final TunerAudioInput _audioInput;
  late final StopMetronomeBeforeCapture _stopMetronome;
  late final AppLogger _logger;
  late final MonotonicTimeReader _realtimeClock;
  late final RealtimePitchConfiguration _realtimeConfiguration;
  late final PitchDetectorConfiguration _pitchConfiguration;
  late final RealtimePitchPipeline _pitchPipeline;
  late RealtimePitchSnapshot _latestRealtimeSnapshot;
  SignalStatisticsAccumulator _statistics = SignalStatisticsAccumulator();
  StreamSubscription<AudioFrame>? _frameSubscription;
  StreamSubscription<AudioStreamFormat>? _formatSubscription;
  Future<void>? _cleanupFuture;
  Duration? _lastPublishedAt;
  Duration? _lastRealtimePublishedAt;
  Duration? _firstRealtimePublishedAt;
  int _realtimePublicationCount = 0;
  int _operationVersion = 0;
  bool _isDisposed = false;
  bool _expectingStreamEnd = false;

  @override
  TunerAudioState build() {
    _audioInput = ref.read(tunerAudioInputFactoryProvider)();
    _stopMetronome = ref.read(stopMetronomeBeforeCaptureProvider);
    _logger = ref.read(appLoggerProvider);
    _realtimeClock = ref.read(tunerRealtimeClockProvider);
    _realtimeConfiguration = ref.read(tunerRealtimeConfigurationProvider);
    _pitchConfiguration = PitchDetectorConfiguration();
    _latestRealtimeSnapshot = RealtimePitchSnapshot.stopped(
      mode: ref.read(pitchDetectionExecutorProvider).modeLabel,
    );
    _pitchPipeline = RealtimePitchPipeline(
      executor: ref.read(pitchDetectionExecutorProvider),
      monotonicTime: _realtimeClock,
      configuration: _realtimeConfiguration,
      onSnapshot: _onRealtimeSnapshot,
      onError: _onAnalysisError,
    );
    ref.onDispose(releaseForNavigation);
    return const TunerAudioState();
  }

  Future<void> start() async {
    if (_isDisposed ||
        state.canStop ||
        state.status == TunerCaptureStatus.stopping) {
      return;
    }
    final operation = ++_operationVersion;
    state = state.copyWith(
      status: TunerCaptureStatus.requestingPermission,
      clearFailure: true,
      clearReportedFormat: true,
      statistics: const SignalStatistics.empty(),
      realtime: _latestRealtimeSnapshot,
    );

    try {
      final permission = await _audioInput.requestPermission();
      if (!_isCurrent(operation)) return;
      _debugLog('Tuner audio permission result=${permission.name}');
      if (permission == MicrophonePermissionResult.denied) {
        state = state.copyWith(
          status: TunerCaptureStatus.idle,
          permissionStatus: TunerPermissionStatus.denied,
          failure: TunerCaptureFailure.permissionDenied,
        );
        return;
      }

      state = state.copyWith(
        status: TunerCaptureStatus.starting,
        permissionStatus: TunerPermissionStatus.granted,
        clearFailure: true,
      );
      await _stopMetronome();
      if (!_isCurrent(operation)) return;

      final configuration = state.requestedConfiguration;
      _debugLog(
        'Tuner audio start requestedRate=${configuration.sampleRate} '
        'channels=${configuration.channelCount} encoding=pcm16le',
      );
      final session = await _audioInput.start(configuration);
      if (!_isCurrent(operation)) {
        await _audioInput.stop();
        return;
      }

      _statistics = SignalStatisticsAccumulator();
      _lastPublishedAt = null;
      _expectingStreamEnd = false;
      final sampleRate =
          session.reportedFormat?.sampleRate ?? configuration.sampleRate;
      _pitchPipeline.startSession(
        sampleRate: sampleRate,
        minimumFrameLength: _pitchConfiguration.minimumFrameLength(sampleRate),
      );
      _lastRealtimePublishedAt = null;
      _firstRealtimePublishedAt = null;
      _realtimePublicationCount = 0;
      _formatSubscription = session.configurationChanges.listen(
        _onFormatChanged,
        onError: (Object error, StackTrace stackTrace) {
          unawaited(_handleStreamError(error, stackTrace));
        },
      );
      _frameSubscription = session.frames.listen(
        _onFrame,
        onError: (Object error, StackTrace stackTrace) {
          if (error is MalformedPcm16FrameException) {
            _handleMalformedFrame(error);
            return;
          }
          unawaited(_handleStreamError(error, stackTrace));
        },
        onDone: _handleStreamDone,
      );
      state = state.copyWith(
        status: TunerCaptureStatus.capturing,
        reportedFormat: session.reportedFormat,
        clearFailure: true,
      );
    } on UnsupportedAudioConfigurationException catch (error, stackTrace) {
      await _handleStartFailure(
        operation,
        TunerCaptureFailure.unsupportedConfiguration,
        error,
        stackTrace,
      );
    } on Object catch (error, stackTrace) {
      await _handleStartFailure(
        operation,
        TunerCaptureFailure.startFailed,
        error,
        stackTrace,
      );
    }
  }

  Future<void> stop({
    TunerCaptureStopReason reason = TunerCaptureStopReason.user,
  }) async {
    if (_isDisposed) return;
    if (!state.canStop &&
        _frameSubscription == null &&
        _formatSubscription == null) {
      return;
    }
    final operation = ++_operationVersion;
    state = state.copyWith(status: TunerCaptureStatus.stopping);
    _pitchPipeline.stop();
    _debugLog('Tuner audio stop reason=${reason.name}');
    try {
      await _cleanupCapture();
      if (_isCurrent(operation)) {
        final statistics = _statistics.snapshot();
        state = state.copyWith(
          status: TunerCaptureStatus.idle,
          statistics: statistics,
          realtime: _latestRealtimeSnapshot,
          clearFailure: true,
        );
        _logFinalDiagnostics(statistics);
      }
    } on Object catch (error, stackTrace) {
      _logger.error('Could not stop tuner audio capture', error, stackTrace);
      if (_isCurrent(operation)) {
        state = state.copyWith(
          status: TunerCaptureStatus.error,
          statistics: _statistics.snapshot(),
          failure: TunerCaptureFailure.stopFailed,
        );
      }
    }
  }

  Future<void> handleLifecycle({required bool isForeground}) async {
    if (!isForeground) {
      await stop(reason: TunerCaptureStopReason.lifecycle);
    }
  }

  void releaseForNavigation() {
    if (_isDisposed) return;
    _isDisposed = true;
    _operationVersion++;
    _pitchPipeline.stop();
    _debugLog(
      'Tuner audio stop reason=${TunerCaptureStopReason.navigation.name}',
    );
    unawaited(_disposeResources());
  }

  void _onFrame(AudioFrame frame) {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
    _statistics.addFrame(frame);
    final sampleRate = frame.format.sampleRate;
    if (_pitchPipeline.snapshot.sampleRate != sampleRate) {
      _pitchPipeline.updateSampleRate(
        sampleRate: sampleRate,
        minimumFrameLength: _pitchConfiguration.minimumFrameLength(sampleRate),
      );
    }
    _pitchPipeline.addSamples(frame.samples, sampleRate: sampleRate);
    final lastPublishedAt = _lastPublishedAt;
    if (lastPublishedAt == null ||
        frame.arrivalTime - lastPublishedAt >= uiUpdateInterval) {
      _lastPublishedAt = frame.arrivalTime;
      final statistics = _statistics.snapshot();
      state = state.copyWith(
        statistics: statistics,
        realtime: _latestRealtimeSnapshot,
      );
      if (statistics.frameCount % 100 == 0) {
        _logFrameDiagnostics(statistics);
      }
    }
  }

  void _onFormatChanged(AudioStreamFormat format) {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
    if (format.sampleRate <= 0) {
      _onAnalysisError(
        ArgumentError.value(format.sampleRate, 'sampleRate'),
        StackTrace.current,
      );
      return;
    }
    _pitchPipeline.updateSampleRate(
      sampleRate: format.sampleRate,
      minimumFrameLength: _pitchConfiguration.minimumFrameLength(
        format.sampleRate,
      ),
    );
    state = state.copyWith(reportedFormat: format);
    _debugLog(
      'Tuner audio reportedRate=${format.sampleRate} '
      'channels=${format.channelCount} encoding=pcm16le',
    );
  }

  void _handleMalformedFrame(MalformedPcm16FrameException error) {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
    _statistics.recordMalformedFrame();
    state = state.copyWith(statistics: _statistics.snapshot());
    _debugLog(
      'Tuner audio malformedFrameBytes=${error.byteLength} '
      'malformedCount=${state.statistics.malformedFrameCount}',
    );
  }

  void _handleStreamDone() {
    if (_isDisposed || _expectingStreamEnd) return;
    if (state.status == TunerCaptureStatus.capturing) {
      unawaited(
        _handleStreamError(
          StateError('Microphone stream ended unexpectedly'),
          StackTrace.current,
        ),
      );
    }
  }

  Future<void> _handleStreamError(Object error, StackTrace stackTrace) async {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
    final operation = ++_operationVersion;
    _pitchPipeline.stop();
    _logger.error('Tuner audio stream failed', error, stackTrace);
    try {
      await _cleanupCapture();
    } on Object catch (stopError, stopStackTrace) {
      _logger.error(
        'Could not clean up failed tuner audio stream',
        stopError,
        stopStackTrace,
      );
    }
    if (_isCurrent(operation)) {
      state = state.copyWith(
        status: TunerCaptureStatus.error,
        statistics: _statistics.snapshot(),
        failure: TunerCaptureFailure.streamFailed,
      );
    }
  }

  Future<void> _handleStartFailure(
    int operation,
    TunerCaptureFailure failure,
    Object error,
    StackTrace stackTrace,
  ) async {
    _pitchPipeline.stop();
    _logger.error('Could not start tuner audio capture', error, stackTrace);
    try {
      await _cleanupCapture();
    } on Object catch (stopError, stopStackTrace) {
      _logger.error(
        'Could not clean up failed tuner audio start',
        stopError,
        stopStackTrace,
      );
    }
    if (_isCurrent(operation)) {
      state = state.copyWith(
        status: TunerCaptureStatus.error,
        failure: failure,
      );
    }
  }

  Future<void> _cleanupCapture() {
    final existingCleanup = _cleanupFuture;
    if (existingCleanup != null) return existingCleanup;
    final cleanup = _performCleanup();
    _cleanupFuture = cleanup;
    return cleanup.whenComplete(() {
      if (identical(_cleanupFuture, cleanup)) _cleanupFuture = null;
    });
  }

  Future<void> _performCleanup() async {
    _expectingStreamEnd = true;
    final frameSubscription = _frameSubscription;
    final formatSubscription = _formatSubscription;
    _frameSubscription = null;
    _formatSubscription = null;
    await Future.wait([
      if (frameSubscription != null) frameSubscription.cancel(),
      if (formatSubscription != null) formatSubscription.cancel(),
    ]);
    await _audioInput.stop();
  }

  Future<void> _disposeResources() async {
    _pitchPipeline.stop();
    try {
      await _cleanupCapture();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Could not stop tuner audio during route disposal',
        error,
        stackTrace,
      );
    }
    try {
      await _audioInput.dispose();
    } on Object catch (error, stackTrace) {
      _logger.error('Could not dispose tuner audio input', error, stackTrace);
    }
  }

  bool _isCurrent(int operation) =>
      !_isDisposed && operation == _operationVersion;

  void _debugLog(String message) {
    if (kDebugMode) _logger.debug(message);
  }

  void _onRealtimeSnapshot(RealtimePitchSnapshot snapshot) {
    _latestRealtimeSnapshot = snapshot;
    if (_isDisposed) return;
    final now = _realtimeClock();
    final lastPublished = _lastRealtimePublishedAt;
    final important =
        snapshot.status != state.realtime.status ||
        snapshot.stabilizedPitch?.midiNote !=
            state.realtime.stabilizedPitch?.midiNote ||
        snapshot.status == RealtimePitchStatus.stopped ||
        snapshot.status == RealtimePitchStatus.analysisError;
    if (important ||
        lastPublished == null ||
        now - lastPublished >= _realtimeConfiguration.uiPublicationInterval) {
      _lastRealtimePublishedAt = now;
      _firstRealtimePublishedAt ??= now;
      _realtimePublicationCount++;
      state = state.copyWith(realtime: snapshot);
    }
  }

  void _onAnalysisError(Object error, StackTrace stackTrace) {
    if (_isDisposed) return;
    _logger.error('Tuner pitch analysis failed', error, stackTrace);
    unawaited(_handleAnalysisFailure());
  }

  Future<void> _handleAnalysisFailure() async {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
    final operation = ++_operationVersion;
    _pitchPipeline.stop();
    try {
      await _cleanupCapture();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Could not clean up failed tuner pitch analysis',
        error,
        stackTrace,
      );
    }
    if (_isCurrent(operation)) {
      state = state.copyWith(
        status: TunerCaptureStatus.error,
        statistics: _statistics.snapshot(),
        realtime: _latestRealtimeSnapshot,
        failure: TunerCaptureFailure.analysisFailed,
      );
    }
  }

  void _logFrameDiagnostics(SignalStatistics statistics) {
    _debugLog(
      'Tuner audio frames=${statistics.frameCount} '
      'malformed=${statistics.malformedFrameCount} '
      'averageFrameSamples=${statistics.averageFrameSamples.toStringAsFixed(1)} '
      'averageArrivalMs='
      '${(statistics.averageArrivalInterval.inMicroseconds / 1000).toStringAsFixed(2)}',
    );
  }

  void _logFinalDiagnostics(SignalStatistics statistics) {
    final firstPublication = _firstRealtimePublishedAt;
    final lastPublication = _lastRealtimePublishedAt;
    final averageUiPublicationMicros =
        firstPublication == null ||
            lastPublication == null ||
            _realtimePublicationCount < 2
        ? 0
        : (lastPublication - firstPublication).inMicroseconds ~/
              (_realtimePublicationCount - 1);
    _debugLog(
      'Tuner audio stopped frames=${statistics.frameCount} '
      'samples=${statistics.samplesReceived} '
      'malformed=${statistics.malformedFrameCount} '
      'averageFrameSamples=${statistics.averageFrameSamples.toStringAsFixed(1)} '
      'averageArrivalMs='
      '${(statistics.averageArrivalInterval.inMicroseconds / 1000).toStringAsFixed(2)} '
      'assembled=${_latestRealtimeSnapshot.diagnostics.framesAssembled} '
      'analyzed=${_latestRealtimeSnapshot.diagnostics.framesAnalyzed} '
      'replaced=${_latestRealtimeSnapshot.diagnostics.pendingFramesReplaced} '
      'dropped=${_latestRealtimeSnapshot.diagnostics.framesDropped} '
      'detectorAverageUs='
      '${_latestRealtimeSnapshot.diagnostics.averageDetectorDuration.inMicroseconds} '
      'detectorMaxUs='
      '${_latestRealtimeSnapshot.diagnostics.maximumDetectorDuration.inMicroseconds} '
      'analysisAverageIntervalUs='
      '${_latestRealtimeSnapshot.diagnostics.averageAnalysisInterval.inMicroseconds} '
      'sampleRateResets='
      '${_latestRealtimeSnapshot.diagnostics.sampleRateResets} '
      'staleClears=${_latestRealtimeSnapshot.diagnostics.staleResultClears} '
      'noteChanges='
      '${_latestRealtimeSnapshot.diagnostics.stabilizerNoteChanges} '
      'uiPublications=$_realtimePublicationCount '
      'uiAverageIntervalUs=$averageUiPublicationMicros',
    );
  }
}
