import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';
import 'package:tunathic/features/tuner_realtime/application/realtime_pitch_pipeline.dart';
import 'package:tunathic/l10n/app_localizations.dart';

final class TunerAudioPrototypeScreen extends ConsumerStatefulWidget {
  const TunerAudioPrototypeScreen({super.key});

  @override
  ConsumerState<TunerAudioPrototypeScreen> createState() =>
      _TunerAudioPrototypeScreenState();
}

final class _TunerAudioPrototypeScreenState
    extends ConsumerState<TunerAudioPrototypeScreen>
    with WidgetsBindingObserver {
  TunerAudioController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller != null) {
      unawaited(
        controller.handleLifecycle(
          isForeground: state == AppLifecycleState.resumed,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.releaseForNavigation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(tunerAudioProvider);
    final controller = ref.read(tunerAudioProvider.notifier);
    _controller = controller;
    final haptics = ref.read(appHapticsProvider);
    final statistics = state.statistics;
    final requested = state.requestedConfiguration;
    final reported = state.reportedFormat;
    final realtime = state.realtime;
    final diagnostics = realtime.diagnostics;
    final rawPitch = realtime.rawEstimate;
    final stablePitch = realtime.stabilizedPitch;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.tunerAudioPrototypeTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              key: const Key('tunerAudioScroll'),
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                _NoticeCard(
                  icon: Icons.science_outlined,
                  text: localizations.tunerAudioPrototypeWarning,
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.captureStatusLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MetricRow(
                        label: localizations.microphonePermissionLabel,
                        value: _permissionLabel(localizations, state),
                      ),
                      _MetricRow(
                        label: localizations.captureStatusLabel,
                        value: _statusLabel(localizations, state),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          FilledButton.icon(
                            key: const Key('startTunerAudioCapture'),
                            onPressed:
                                state.status == TunerCaptureStatus.capturing ||
                                    state.isBusy
                                ? null
                                : () {
                                    unawaited(haptics.lightImpact());
                                    unawaited(controller.start());
                                  },
                            icon: const Icon(Icons.mic_outlined),
                            label: Text(localizations.startCapture),
                          ),
                          OutlinedButton.icon(
                            key: const Key('stopTunerAudioCapture'),
                            onPressed: state.canStop
                                ? () {
                                    unawaited(haptics.selection());
                                    unawaited(controller.stop());
                                  }
                                : null,
                            icon: const Icon(Icons.stop_outlined),
                            label: Text(localizations.stopCapture),
                          ),
                        ],
                      ),
                      if (state.failure case final failure?) ...[
                        const SizedBox(height: AppSpacing.medium),
                        _InlineFailure(
                          message: _failureMessage(localizations, failure),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.pcmEncodingLabel,
                  child: Column(
                    children: [
                      _MetricRow(
                        label: localizations.requestedSampleRateLabel,
                        value: localizations.sampleRateValue(
                          requested.sampleRate,
                        ),
                      ),
                      _MetricRow(
                        label: localizations.reportedSampleRateLabel,
                        value: reported == null
                            ? localizations.reportedSampleRateUnavailable
                            : localizations.sampleRateValue(
                                reported.sampleRate,
                              ),
                      ),
                      _MetricRow(
                        label: localizations.channelCountLabel,
                        value: localizations.channelCountValue(
                          reported?.channelCount ?? requested.channelCount,
                        ),
                      ),
                      _MetricRow(
                        label: localizations.pcmEncodingLabel,
                        value: localizations.pcm16LittleEndian,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.pitchAnalysisTitle,
                  child: Column(
                    children: [
                      _MetricRow(
                        key: const Key('tunerAnalysisStatus'),
                        label: localizations.pitchAnalysisStatusLabel,
                        value: _analysisStatusLabel(localizations, state),
                      ),
                      _MetricRow(
                        label: localizations.detectorExecutionModeLabel,
                        value: diagnostics.executionMode,
                      ),
                      _MetricRow(
                        label: localizations.bufferedSamplesLabel,
                        value: diagnostics.bufferedSamples.toString(),
                      ),
                      _MetricRow(
                        key: const Key('tunerFramesAssembled'),
                        label: localizations.framesAssembledLabel,
                        value: diagnostics.framesAssembled.toString(),
                      ),
                      _MetricRow(
                        key: const Key('tunerFramesAnalyzed'),
                        label: localizations.framesAnalyzedLabel,
                        value: diagnostics.framesAnalyzed.toString(),
                      ),
                      _MetricRow(
                        label: localizations.framesReplacedLabel,
                        value: diagnostics.pendingFramesReplaced.toString(),
                      ),
                      _MetricRow(
                        label: localizations.framesDroppedLabel,
                        value: diagnostics.framesDropped.toString(),
                      ),
                      _MetricRow(
                        label: localizations.averageDetectorDurationLabel,
                        value: localizations.millisecondsValue(
                          (diagnostics.averageDetectorDuration.inMicroseconds /
                                  1000)
                              .toStringAsFixed(2),
                        ),
                      ),
                      _MetricRow(
                        label: localizations.maximumDetectorDurationLabel,
                        value: localizations.millisecondsValue(
                          (diagnostics.maximumDetectorDuration.inMicroseconds /
                                  1000)
                              .toStringAsFixed(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.rawPitchTitle,
                  child: Column(
                    children: [
                      _MetricRow(
                        key: const Key('tunerRawFrequency'),
                        label: localizations.detectedFrequencyLabel,
                        value: rawPitch?.frequencyHz == null
                            ? localizations.pitchUnavailable
                            : localizations.frequencyHzValue(
                                rawPitch!.frequencyHz!.toStringAsFixed(2),
                              ),
                      ),
                      _MetricRow(
                        label: localizations.pitchConfidenceLabel,
                        value: rawPitch == null
                            ? localizations.pitchUnavailable
                            : rawPitch.confidence.toStringAsFixed(3),
                      ),
                      _MetricRow(
                        label: localizations.detectedNoteLabel,
                        value: rawPitch?.noteName == null
                            ? localizations.pitchUnavailable
                            : '${rawPitch!.noteName}${rawPitch.octave}',
                      ),
                      _MetricRow(
                        label: localizations.centsDeviationLabel,
                        value: rawPitch?.centsDeviation == null
                            ? localizations.pitchUnavailable
                            : localizations.centsValue(
                                rawPitch!.centsDeviation!.toStringAsFixed(1),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.stabilizedPitchTitle,
                  child: Column(
                    children: [
                      _MetricRow(
                        key: const Key('tunerStabilizedNote'),
                        label: localizations.detectedNoteLabel,
                        value: stablePitch == null
                            ? localizations.pitchUnavailable
                            : '${stablePitch.noteName}${stablePitch.octave}',
                      ),
                      _MetricRow(
                        label: localizations.detectedFrequencyLabel,
                        value: stablePitch == null
                            ? localizations.pitchUnavailable
                            : localizations.frequencyHzValue(
                                stablePitch.frequencyHz.toStringAsFixed(2),
                              ),
                      ),
                      _MetricRow(
                        label: localizations.centsDeviationLabel,
                        value: stablePitch == null
                            ? localizations.pitchUnavailable
                            : localizations.centsValue(
                                stablePitch.centsDeviation.toStringAsFixed(1),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _SectionCard(
                  title: localizations.signalStatisticsTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localizations.inputLevelLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Semantics(
                        label: localizations.inputLevelLabel,
                        value: statistics.latestLevel.peak.toStringAsFixed(3),
                        child: LinearProgressIndicator(
                          key: const Key('tunerInputLevel'),
                          value: statistics.latestLevel.peak.clamp(0, 1),
                          minHeight: AppSpacing.small,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      _MetricRow(
                        label: localizations.peakAmplitudeLabel,
                        value: statistics.latestLevel.peak.toStringAsFixed(3),
                      ),
                      _MetricRow(
                        label: localizations.rmsAmplitudeLabel,
                        value: statistics.latestLevel.rms.toStringAsFixed(3),
                      ),
                      _MetricRow(
                        label: localizations.dbfsLabel,
                        value: statistics.latestLevel.dbfs.isFinite
                            ? localizations.dbfsValue(
                                statistics.latestLevel.dbfs.toStringAsFixed(1),
                              )
                            : localizations.silenceDbfs,
                      ),
                      _MetricRow(
                        key: const Key('tunerFramesValue'),
                        label: localizations.framesReceivedLabel,
                        value: statistics.frameCount.toString(),
                      ),
                      _MetricRow(
                        key: const Key('tunerSamplesValue'),
                        label: localizations.samplesReceivedLabel,
                        value: statistics.samplesReceived.toString(),
                      ),
                      _MetricRow(
                        label: localizations.streamDurationLabel,
                        value: localizations.durationSecondsValue(
                          (statistics.streamDuration.inMilliseconds / 1000)
                              .toStringAsFixed(2),
                        ),
                      ),
                      _MetricRow(
                        label: localizations.observedFrameSizesLabel,
                        value: localizations.frameSizesValue(
                          statistics.minimumFrameSamples,
                          statistics.maximumFrameSamples,
                          statistics.averageFrameSamples.toStringAsFixed(1),
                        ),
                      ),
                      _MetricRow(
                        label: localizations.frameArrivalRateLabel,
                        value: localizations.framesPerSecondValue(
                          statistics.framesPerSecond.toStringAsFixed(1),
                        ),
                      ),
                      _MetricRow(
                        label: localizations.malformedFramesLabel,
                        value: statistics.malformedFrameCount.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                _InfoCard(
                  icon: Icons.privacy_tip_outlined,
                  title: localizations.prototypePrivacyTitle,
                  description: localizations.prototypePrivacyDescription,
                ),
                const SizedBox(height: AppSpacing.medium),
                _InfoCard(
                  icon: Icons.visibility_outlined,
                  title: localizations.prototypeLifecycleTitle,
                  description: localizations.prototypeLifecycleDescription,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _permissionLabel(
    AppLocalizations localizations,
    TunerAudioState state,
  ) => switch (state.permissionStatus) {
    TunerPermissionStatus.notRequested =>
      localizations.microphonePermissionNotRequested,
    TunerPermissionStatus.granted => localizations.microphonePermissionGranted,
    TunerPermissionStatus.denied => localizations.microphonePermissionDenied,
  };

  String _statusLabel(AppLocalizations localizations, TunerAudioState state) =>
      switch (state.status) {
        TunerCaptureStatus.idle => localizations.captureStatusIdle,
        TunerCaptureStatus.requestingPermission =>
          localizations.captureStatusRequestingPermission,
        TunerCaptureStatus.starting => localizations.captureStatusStarting,
        TunerCaptureStatus.capturing => localizations.captureStatusCapturing,
        TunerCaptureStatus.stopping => localizations.captureStatusStopping,
        TunerCaptureStatus.error => localizations.captureStatusError,
      };

  String _analysisStatusLabel(
    AppLocalizations localizations,
    TunerAudioState state,
  ) => switch (state.analysisStatus) {
    RealtimePitchStatus.stopped => localizations.pitchStatusStopped,
    RealtimePitchStatus.waitingForSamples =>
      localizations.pitchStatusWaitingForSamples,
    RealtimePitchStatus.analyzing => localizations.pitchStatusAnalyzing,
    RealtimePitchStatus.stablePitch => localizations.pitchStatusStable,
    RealtimePitchStatus.unstableSignal => localizations.pitchStatusUnstable,
    RealtimePitchStatus.noSignal => localizations.pitchStatusNoSignal,
    RealtimePitchStatus.permissionDenied =>
      localizations.pitchStatusPermissionDenied,
    RealtimePitchStatus.captureError => localizations.pitchStatusCaptureError,
    RealtimePitchStatus.analysisError => localizations.pitchStatusAnalysisError,
  };

  String _failureMessage(
    AppLocalizations localizations,
    TunerCaptureFailure failure,
  ) => switch (failure) {
    TunerCaptureFailure.permissionDenied =>
      localizations.permissionDeniedMessage,
    TunerCaptureFailure.unsupportedConfiguration =>
      localizations.unsupportedAudioMessage,
    TunerCaptureFailure.startFailed => localizations.audioStartFailedMessage,
    TunerCaptureFailure.streamFailed => localizations.audioStreamFailedMessage,
    TunerCaptureFailure.analysisFailed =>
      localizations.pitchAnalysisFailedMessage,
    TunerCaptureFailure.stopFailed => localizations.audioStopFailedMessage,
  };
}

final class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.onSecondaryContainer),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: colors.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: AppSpacing.medium),
            child,
          ],
        ),
      ),
    );
  }
}

final class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.medium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

final class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: Text(description),
        ),
      ),
    );
  }
}

final class _InlineFailure extends StatelessWidget {
  const _InlineFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: AppRadii.smallBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Text(
            message,
            style: TextStyle(color: colors.onErrorContainer),
          ),
        ),
      ),
    );
  }
}
