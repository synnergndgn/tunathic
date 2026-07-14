// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tunathic';

  @override
  String get tagline => 'Tune. Train. Create.';

  @override
  String get dashboardTitle => 'Guitar toolkit';

  @override
  String get dashboardIntro =>
      'Everything you need for focused practice, in one place.';

  @override
  String get practiceSection => 'Practice';

  @override
  String get theoryReferenceSection => 'Theory and Reference';

  @override
  String get trainingSection => 'Training';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTooltip => 'Open settings';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get interactionTitle => 'Interaction';

  @override
  String get hapticFeedbackTitle => 'Haptic feedback';

  @override
  String get hapticFeedbackDescription =>
      'Use subtle vibration for meaningful taps and selections.';

  @override
  String get applicationTitle => 'Application';

  @override
  String get aboutTunathic => 'About Tunathic';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get versionLabel => 'Version';

  @override
  String get productFullName => 'Tunathic – Guitar Toolkit';

  @override
  String get aboutProductDescription =>
      'A focused, offline-first toolkit for guitar practice, timing, and music theory.';

  @override
  String get publisherLabel => 'Publisher';

  @override
  String get copyrightNotice => '© 2026 GUNDEV. All rights reserved.';

  @override
  String get availableToolsTitle => 'Available tools';

  @override
  String get plannedToolsTitle => 'Planned tools';

  @override
  String get privacySummary =>
      'Tunathic is designed to keep the current practice experience private and local to your device.';

  @override
  String get privacyBpmTitle => 'Practice sessions stay temporary';

  @override
  String get privacyBpmDescription =>
      'BPM Tap sessions remain in memory and are cleared when the session ends. They are not uploaded.';

  @override
  String get privacyLocalTitle => 'Preferences stay on this device';

  @override
  String get privacyLocalDescription =>
      'Theme, language, haptic, and Metronome settings are stored locally on this device.';

  @override
  String get privacyMicrophoneTitle => 'Microphone prototype stays local';

  @override
  String get privacyMicrophoneDescription =>
      'Microphone access is used only while the Tuner Audio Prototype is actively capturing. Raw audio is processed locally, never saved or uploaded, and capture stops when you leave the screen or the app enters the background.';

  @override
  String get privacyNoCollectionTitle =>
      'No accounts, ads, analytics, or backend';

  @override
  String get privacyNoCollectionDescription =>
      'The current app requires no account, includes no advertising or analytics, has no Tunathic backend, and sends no app data to GUNDEV servers.';

  @override
  String get privacyFutureChanges =>
      'This privacy information must be reviewed before production tuner, recording, advertising, analytics, account, cloud, or backend features are released.';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get openTool => 'Open tool';

  @override
  String comingSoonDescription(String toolName) {
    return '$toolName is planned for a future milestone.';
  }

  @override
  String get backToDashboard => 'Back to dashboard';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundDescription =>
      'That page is not available in Tunathic.';

  @override
  String get unexpectedErrorTitle => 'Something went wrong';

  @override
  String get unexpectedErrorDescription =>
      'Tunathic could not show this screen. Please return to the dashboard and try again.';

  @override
  String get guitarTuner => 'Guitar Tuner';

  @override
  String get metronome => 'Metronome';

  @override
  String get startMetronome => 'Start';

  @override
  String get stopMetronome => 'Stop';

  @override
  String get tempo => 'Tempo';

  @override
  String get beatsPerMinute => 'Beats per minute';

  @override
  String tempoValue(int bpm) {
    return '$bpm beats per minute';
  }

  @override
  String get decreaseTempo => 'Decrease tempo';

  @override
  String get increaseTempo => 'Increase tempo';

  @override
  String get timeSignature => 'Time signature';

  @override
  String get currentBeat => 'Current beat';

  @override
  String currentBeatValue(int beat, int total) {
    return 'Current beat: $beat of $total';
  }

  @override
  String get metronomeStopped => 'Stopped';

  @override
  String get preparingAudio => 'Preparing audio';

  @override
  String get sound => 'Sound';

  @override
  String get accentFirstBeat => 'Accent first beat';

  @override
  String volumePercent(int percent) {
    return '$percent% volume';
  }

  @override
  String get openBpmTapForMetronome => 'Open BPM Tap';

  @override
  String get applyBpmTapResult => 'Apply BPM Tap result';

  @override
  String bpmTapApplied(int bpm) {
    return 'Applied $bpm BPM to the metronome.';
  }

  @override
  String get metronomeGuidance =>
      'Choose a tempo and time signature, then start. The first beat is accented when accent is enabled.';

  @override
  String get audioUnavailableTitle => 'Metronome audio unavailable';

  @override
  String get audioUnavailableDescription =>
      'Tunathic stopped the metronome because audio could not be prepared or played.';

  @override
  String get retryAudio => 'Retry audio';

  @override
  String get currentAccentedBeat => 'current accented beat';

  @override
  String get currentBeatDetail => 'current beat';

  @override
  String get accentedBeat => 'accented first beat';

  @override
  String get inactiveBeat => 'inactive beat';

  @override
  String beatIndicatorSemantics(int beat, String details) {
    return 'Beat $beat, $details';
  }

  @override
  String get bpmTap => 'BPM Tap';

  @override
  String get bpmLabel => 'BPM';

  @override
  String get tapToBegin => 'Tap to begin';

  @override
  String get keepTapping => 'Keep tapping';

  @override
  String get bpmEstimateReady => 'Tempo detected. Keep tapping to refine it.';

  @override
  String get reset => 'Reset';

  @override
  String get sessionReset =>
      'Session reset after inactivity. Tap to begin again.';

  @override
  String get invalidTapIgnored =>
      'That tap was outside the valid tempo range and was ignored.';

  @override
  String get bpmTapGuidance =>
      'Tap steadily with the beat. The latest taps keep the reading responsive.';

  @override
  String get noRecentInterval => 'Waiting for an interval';

  @override
  String tapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taps',
      one: '1 tap',
      zero: 'No taps',
    );
    return '$_temp0';
  }

  @override
  String recentInterval(int milliseconds) {
    return '$milliseconds ms since last tap';
  }

  @override
  String tapSurfaceSemantics(String status, int count, String bpm) {
    return '$status. $count accepted taps. $bpm BPM.';
  }

  @override
  String get chordLibrary => 'Chord Library';

  @override
  String get scaleLibrary => 'Scale Library';

  @override
  String get circleOfFifths => 'Circle of Fifths';

  @override
  String get intervalTrainer => 'Interval Trainer';

  @override
  String get earTraining => 'Ear Training';

  @override
  String get chordFinder => 'Chord Finder';

  @override
  String get capoCalculator => 'Capo Calculator';

  @override
  String get tunerAudioPrototypeTitle => 'Tuner Audio Prototype';

  @override
  String get tunerAudioPrototypeWarning =>
      'Technical prototype only. This validates microphone input and is not a working guitar tuner.';

  @override
  String get microphonePermissionLabel => 'Microphone permission';

  @override
  String get microphonePermissionNotRequested => 'Not requested';

  @override
  String get microphonePermissionGranted => 'Granted';

  @override
  String get microphonePermissionDenied => 'Denied';

  @override
  String get startCapture => 'Start capture';

  @override
  String get stopCapture => 'Stop capture';

  @override
  String get captureStatusLabel => 'Capture status';

  @override
  String get captureStatusIdle => 'Stopped';

  @override
  String get captureStatusRequestingPermission => 'Requesting permission';

  @override
  String get captureStatusStarting => 'Starting microphone';

  @override
  String get captureStatusCapturing => 'Capturing';

  @override
  String get captureStatusStopping => 'Stopping';

  @override
  String get captureStatusError => 'Capture error';

  @override
  String get requestedSampleRateLabel => 'Requested sample rate';

  @override
  String get reportedSampleRateLabel => 'Reported sample rate';

  @override
  String get reportedSampleRateUnavailable =>
      'Not reported by the audio backend';

  @override
  String sampleRateValue(int sampleRate) {
    return '$sampleRate Hz';
  }

  @override
  String get channelCountLabel => 'Channels';

  @override
  String channelCountValue(int channelCount) {
    return '$channelCount (mono)';
  }

  @override
  String get pcmEncodingLabel => 'Encoding';

  @override
  String get pcm16LittleEndian => 'Signed PCM16, little-endian';

  @override
  String get signalStatisticsTitle => 'Signal statistics';

  @override
  String get inputLevelLabel => 'Input level';

  @override
  String get peakAmplitudeLabel => 'Peak amplitude';

  @override
  String get rmsAmplitudeLabel => 'RMS amplitude';

  @override
  String get dbfsLabel => 'dBFS';

  @override
  String get silenceDbfs => '−∞ dBFS';

  @override
  String dbfsValue(String value) {
    return '$value dBFS';
  }

  @override
  String get framesReceivedLabel => 'Frames received';

  @override
  String get samplesReceivedLabel => 'Samples received';

  @override
  String get streamDurationLabel => 'Stream duration';

  @override
  String durationSecondsValue(String value) {
    return '$value s';
  }

  @override
  String get observedFrameSizesLabel => 'Observed frame sizes';

  @override
  String frameSizesValue(int minimum, int maximum, String average) {
    return '$minimum–$maximum samples; $average average';
  }

  @override
  String get frameArrivalRateLabel => 'Approximate frame arrival rate';

  @override
  String framesPerSecondValue(String value) {
    return '$value frames/s';
  }

  @override
  String get malformedFramesLabel => 'Malformed frames';

  @override
  String get prototypePrivacyTitle => 'Private by design';

  @override
  String get prototypePrivacyDescription =>
      'Audio is processed only in memory on this device. Raw microphone data and signal statistics are not saved or transmitted.';

  @override
  String get prototypeLifecycleTitle => 'Foreground capture only';

  @override
  String get prototypeLifecycleDescription =>
      'Capture stops when you leave this screen, background or hide the app, or lock the screen. It never restarts automatically.';

  @override
  String get permissionDeniedMessage =>
      'Microphone access was denied. Start again only if you want to retry; Tunathic will not open system settings automatically.';

  @override
  String get unsupportedAudioMessage =>
      'This device did not accept the prototype PCM audio configuration.';

  @override
  String get audioStartFailedMessage =>
      'Tunathic could not start microphone capture. You can try again.';

  @override
  String get audioStreamFailedMessage =>
      'Microphone capture stopped because the audio stream failed. You can try again.';

  @override
  String get audioStopFailedMessage =>
      'Tunathic could not finish releasing the microphone cleanly. You can try again.';
}
