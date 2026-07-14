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
    this.failure,
  });

  final TunerCaptureStatus status;
  final TunerPermissionStatus permissionStatus;
  final AudioInputConfiguration requestedConfiguration;
  final AudioStreamFormat? reportedFormat;
  final SignalStatistics statistics;
  final TunerCaptureFailure? failure;

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

final tunerAudioProvider =
    NotifierProvider.autoDispose<TunerAudioController, TunerAudioState>(
      TunerAudioController.new,
    );

final class TunerAudioController extends Notifier<TunerAudioState> {
  static const uiUpdateInterval = Duration(milliseconds: 100);

  late final TunerAudioInput _audioInput;
  late final StopMetronomeBeforeCapture _stopMetronome;
  late final AppLogger _logger;
  SignalStatisticsAccumulator _statistics = SignalStatisticsAccumulator();
  StreamSubscription<AudioFrame>? _frameSubscription;
  StreamSubscription<AudioStreamFormat>? _formatSubscription;
  Future<void>? _cleanupFuture;
  Duration? _lastPublishedAt;
  int _operationVersion = 0;
  bool _isDisposed = false;
  bool _expectingStreamEnd = false;

  @override
  TunerAudioState build() {
    _audioInput = ref.read(tunerAudioInputFactoryProvider)();
    _stopMetronome = ref.read(stopMetronomeBeforeCaptureProvider);
    _logger = ref.read(appLoggerProvider);
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
    _debugLog('Tuner audio stop reason=${reason.name}');
    try {
      await _cleanupCapture();
      if (_isCurrent(operation)) {
        final statistics = _statistics.snapshot();
        state = state.copyWith(
          status: TunerCaptureStatus.idle,
          statistics: statistics,
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
    _debugLog(
      'Tuner audio stop reason=${TunerCaptureStopReason.navigation.name}',
    );
    unawaited(_disposeResources());
  }

  void _onFrame(AudioFrame frame) {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
    _statistics.addFrame(frame);
    final lastPublishedAt = _lastPublishedAt;
    if (lastPublishedAt == null ||
        frame.arrivalTime - lastPublishedAt >= uiUpdateInterval) {
      _lastPublishedAt = frame.arrivalTime;
      final statistics = _statistics.snapshot();
      state = state.copyWith(statistics: statistics);
      if (statistics.frameCount % 100 == 0) {
        _logFrameDiagnostics(statistics);
      }
    }
  }

  void _onFormatChanged(AudioStreamFormat format) {
    if (_isDisposed || state.status != TunerCaptureStatus.capturing) return;
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
    _debugLog(
      'Tuner audio stopped frames=${statistics.frameCount} '
      'samples=${statistics.samplesReceived} '
      'malformed=${statistics.malformedFrameCount} '
      'averageFrameSamples=${statistics.averageFrameSamples.toStringAsFixed(1)} '
      'averageArrivalMs='
      '${(statistics.averageArrivalInterval.inMicroseconds / 1000).toStringAsFixed(2)}',
    );
  }
}
