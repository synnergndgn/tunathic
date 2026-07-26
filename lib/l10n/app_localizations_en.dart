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
  String get privacyMicrophoneTitle => 'Microphone pitch analysis stays local';

  @override
  String get privacyMicrophoneDescription =>
      'Microphone access is used only while the Real-Time Pitch Diagnostic is active. Raw audio and pitch estimates remain transient and local, are never saved or uploaded, and stop when you leave the screen or the app enters the background.';

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
  String get chordLibraryIntro =>
      'Build chords from music theory and explore validated guitar shapes offline.';

  @override
  String get chordSearchLabel => 'Chord search';

  @override
  String get chordSearchHint => 'Try C, Cm, Cmaj7, F#m, or Bb7';

  @override
  String get searchAction => 'Search';

  @override
  String get unsupportedChordSearch =>
      'Enter a supported chord symbol such as Cmaj7 or F#m.';

  @override
  String get rootNoteLabel => 'Root note';

  @override
  String get chordQualityLabel => 'Chord quality';

  @override
  String get chordSymbolLabel => 'Chord symbol';

  @override
  String get chordTonesLabel => 'Chord tones';

  @override
  String get guitarShapesLabel => 'Guitar shapes';

  @override
  String get primaryShapeLabel => 'Selected shape';

  @override
  String get alternateShapesLabel => 'Available shapes';

  @override
  String get fingeringLabel => 'Fingering';

  @override
  String get noChordShapeTitle => 'No curated guitar shape';

  @override
  String get noChordShapeDescription =>
      'The chord is theoretically valid, but this offline library does not currently include a verified shape for it.';

  @override
  String startingFretValue(int fret) {
    return 'Starting fret $fret';
  }

  @override
  String get openPositionShape => 'Open position';

  @override
  String get movableEShape => 'Movable E shape';

  @override
  String get movableAShape => 'Movable A shape';

  @override
  String get compactShape => 'Compact voicing';

  @override
  String get beginnerDifficulty => 'Beginner';

  @override
  String get intermediateDifficulty => 'Intermediate';

  @override
  String get triadCategory => 'Triads';

  @override
  String get seventhChordCategory => 'Seventh chords';

  @override
  String get extendedChordCategory => 'Extended chords';

  @override
  String get qualityMajor => 'Major';

  @override
  String get qualityMinor => 'Minor';

  @override
  String get qualityDiminished => 'Diminished';

  @override
  String get qualityAugmented => 'Augmented';

  @override
  String get qualitySus2 => 'Suspended 2';

  @override
  String get qualitySus4 => 'Suspended 4';

  @override
  String get qualityMajor7 => 'Major 7';

  @override
  String get qualityDominant7 => 'Dominant 7';

  @override
  String get qualityMinor7 => 'Minor 7';

  @override
  String get qualityMinorMajor7 => 'Minor major 7';

  @override
  String get qualityDiminished7 => 'Diminished 7';

  @override
  String get qualityHalfDiminished7 => 'Half-diminished (m7b5)';

  @override
  String get quality6 => 'Major 6';

  @override
  String get qualityMinor6 => 'Minor 6';

  @override
  String get qualityAdd9 => 'Add 9';

  @override
  String get qualityMinorAdd9 => 'Minor add 9';

  @override
  String get quality9 => 'Dominant 9';

  @override
  String get qualityMajor9 => 'Major 9';

  @override
  String get qualityMinor9 => 'Minor 9';

  @override
  String get quality11 => 'Dominant 11';

  @override
  String get qualityMinor11 => 'Minor 11';

  @override
  String get quality13 => 'Dominant 13';

  @override
  String get lowEString => 'Low E string';

  @override
  String get aString => 'A string';

  @override
  String get dString => 'D string';

  @override
  String get gString => 'G string';

  @override
  String get bString => 'B string';

  @override
  String get highEString => 'High E string';

  @override
  String get mutedMarker => 'Muted';

  @override
  String get openMarker => 'Open';

  @override
  String fretOnlyValue(int fret) {
    return 'Fret $fret';
  }

  @override
  String fretAndFingerValue(int fret, int finger) {
    return 'Fret $fret, finger $finger';
  }

  @override
  String guitarStringMutedDescription(String stringName) {
    return '$stringName muted.';
  }

  @override
  String guitarStringOpenDescription(String stringName) {
    return '$stringName open.';
  }

  @override
  String guitarStringFrettedDescription(String stringName, int fret) {
    return '$stringName fret $fret.';
  }

  @override
  String guitarStringFingerDescription(
    String stringName,
    int fret,
    int finger,
  ) {
    return '$stringName fret $fret, finger $finger.';
  }

  @override
  String barreDescription(
    int fret,
    String fromString,
    String toString,
    int finger,
  ) {
    return 'Barre at fret $fret, from $fromString through $toString, finger $finger.';
  }

  @override
  String chordDiagramSemantics(String chordSymbol, String details) {
    return '$chordSymbol guitar chord diagram. $details';
  }

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
  String get tunerAudioPrototypeTitle => 'Real-Time Pitch Diagnostic';

  @override
  String get tunerAudioPrototypeWarning =>
      'Development diagnostic only. This connects live pitch analysis for evaluation and is not the final Guitar Tuner.';

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
      'Audio and transient pitch diagnostics are processed only in memory on this device. Raw microphone data, pitch history, and statistics are not saved or transmitted.';

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

  @override
  String get pitchAnalysisTitle => 'Real-time pitch analysis';

  @override
  String get pitchAnalysisStatusLabel => 'Analysis state';

  @override
  String get pitchStatusStopped => 'Stopped';

  @override
  String get pitchStatusWaitingForSamples => 'Waiting for enough samples';

  @override
  String get pitchStatusAnalyzing => 'Analyzing';

  @override
  String get pitchStatusStable => 'Stable pitch';

  @override
  String get pitchStatusUnstable => 'Unstable signal';

  @override
  String get pitchStatusNoSignal => 'No reliable signal';

  @override
  String get pitchStatusPermissionDenied => 'Microphone permission denied';

  @override
  String get pitchStatusCaptureError => 'Capture error';

  @override
  String get pitchStatusAnalysisError => 'Analysis error';

  @override
  String get detectorExecutionModeLabel => 'Detector execution';

  @override
  String get bufferedSamplesLabel => 'Buffered samples';

  @override
  String get framesAssembledLabel => 'Analysis frames assembled';

  @override
  String get framesAnalyzedLabel => 'Frames analyzed';

  @override
  String get framesReplacedLabel => 'Pending frames replaced';

  @override
  String get framesDroppedLabel => 'Analysis frames dropped';

  @override
  String get averageDetectorDurationLabel => 'Average detector duration';

  @override
  String get maximumDetectorDurationLabel => 'Maximum detector duration';

  @override
  String millisecondsValue(String value) {
    return '$value ms';
  }

  @override
  String get rawPitchTitle => 'Raw detector result';

  @override
  String get stabilizedPitchTitle => 'Stabilized result';

  @override
  String get detectedFrequencyLabel => 'Detected frequency';

  @override
  String get pitchConfidenceLabel => 'Confidence';

  @override
  String get detectedNoteLabel => 'Detected note';

  @override
  String get centsDeviationLabel => 'Cents deviation';

  @override
  String frequencyHzValue(String value) {
    return '$value Hz';
  }

  @override
  String centsValue(String value) {
    return '$value cents';
  }

  @override
  String get pitchUnavailable => '—';

  @override
  String get pitchAnalysisFailedMessage =>
      'Live pitch analysis stopped because the detector failed. You can try again.';

  @override
  String get tuningPresetLabel => 'Tuning';

  @override
  String get automaticMode => 'Automatic';

  @override
  String get manualMode => 'Manual';

  @override
  String get targetStringLabel => 'Target string';

  @override
  String get flatLabel => 'Flat';

  @override
  String get sharpLabel => 'Sharp';

  @override
  String get inTuneLabel => 'In tune';

  @override
  String get noSignal => 'No signal';

  @override
  String get startTuning => 'Start tuning';

  @override
  String get stopTuning => 'Stop tuning';

  @override
  String get retryMicrophone => 'Try microphone again';

  @override
  String get openTunerDiagnostics => 'Open tuner diagnostics';

  @override
  String get tuningStandard => 'Standard';

  @override
  String get tuningDropD => 'Drop D';

  @override
  String get tuningHalfStepDown => 'Half Step Down';

  @override
  String get tuningFullStepDown => 'Full Step Down';

  @override
  String get tuningDadgad => 'DADGAD';

  @override
  String get tuningOpenG => 'Open G';

  @override
  String get tuningOpenD => 'Open D';

  @override
  String get noDetectedNote => 'No detected note';

  @override
  String get frequencyUnavailable => 'Frequency unavailable';

  @override
  String get frequencyUnavailableSemantics => 'Frequency unavailable';

  @override
  String get centsUnavailableSemantics => 'Cents offset unavailable';

  @override
  String signedCentsValue(String value) {
    return '$value cents';
  }

  @override
  String frequencyHertzValue(String value) {
    return '$value Hz';
  }

  @override
  String detectedNoteSemantics(String note, int octave) {
    return 'Detected note $note, octave $octave';
  }

  @override
  String targetStringSemantics(int position, String note) {
    return 'Target string $position, $note';
  }

  @override
  String tunerModeSemantics(String mode) {
    return 'Tuner mode: $mode';
  }

  @override
  String centsDirectionSemantics(int value, String direction) {
    return '$value cents $direction';
  }

  @override
  String frequencySemantics(String value) {
    return 'Frequency $value hertz';
  }

  @override
  String get tunerStoppedMessage => 'Tap Start when you are ready to tune.';

  @override
  String get tunerRequestingPermissionMessage =>
      'Requesting microphone permission.';

  @override
  String get tunerListeningMessage => 'Microphone is starting.';

  @override
  String get tunerWaitingForSignalMessage => 'Listening. Play one string.';

  @override
  String get tunerUnstableSignalMessage =>
      'Signal is unstable. Let one string ring clearly.';

  @override
  String get tunerStablePitchMessage => 'Pitch detected.';

  @override
  String get tunerNoSignalMessage => 'No reliable signal. Play one string.';

  @override
  String get tunerPermissionDeniedMessage =>
      'Microphone permission is needed to tune.';

  @override
  String get tunerMicrophoneUnavailableMessage =>
      'The microphone is unavailable. Try again.';

  @override
  String get tunerProcessingErrorMessage =>
      'Pitch processing stopped. Try again.';
}
