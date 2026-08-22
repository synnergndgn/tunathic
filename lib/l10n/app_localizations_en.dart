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
  String get settingsAudioSection => 'Audio and tuning';

  @override
  String get referencePitchLabel => 'Reference pitch';

  @override
  String get referencePitchRangeNote =>
      'Every tool tunes to this reference. 430–450 Hz, in 1 Hz steps.';

  @override
  String get microphoneUsageLabel => 'Microphone';

  @override
  String get microphoneUsageValue => 'Tuner only';

  @override
  String get microphoneUsageDescription =>
      'Requested when you open the tuner, released when you leave it. Nothing is recorded.';

  @override
  String get aboutManifesto =>
      'Built for musicians who need fast, clean and reliable tuning.';

  @override
  String get availableToolsTitle => 'Available tools';

  @override
  String get plannedToolsTitle => 'Planned tools';

  @override
  String get privacySummary =>
      'Tunathic is designed as an offline guitar toolkit. Its current tools do not send your app data to GUNDEV or other third parties.';

  @override
  String get privacyBpmTitle => 'Practice sessions stay temporary';

  @override
  String get privacyBpmDescription =>
      'BPM Tap sessions remain in memory and are cleared when the session ends. They are not uploaded.';

  @override
  String get privacyLocalTitle => 'Preferences stay on this device';

  @override
  String get privacyLocalDescription =>
      'Theme, language, haptic, Metronome, and Guitar Tuner preferences are stored locally on this device, together with the Music Theory lessons you star or open. Chord, scale, fretboard, Circle of Fifths, and Music Theory content is bundled with the app.';

  @override
  String get privacyMicrophoneTitle => 'Microphone pitch analysis stays local';

  @override
  String get privacyMicrophoneDescription =>
      'The Guitar Tuner uses microphone access only while it is open, starting when you enter the screen. Raw audio and pitch estimates are processed transiently on this device, are never saved or uploaded, and stop when you leave the tuner or the app enters the background.';

  @override
  String get privacyNoCollectionTitle =>
      'No accounts, ads, analytics, or backend';

  @override
  String get privacyNoCollectionDescription =>
      'The current app requires no account, includes no advertising or analytics, has no Tunathic backend, and sends no app data to GUNDEV servers.';

  @override
  String get privacyFutureChanges =>
      'Tunathic does not store microphone recordings, create accounts, show ads, run analytics, sell data, or share app data. This information will be updated if the app\'s behavior changes.';

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
  String get advancedDifficulty => 'Advanced';

  @override
  String omittedTonesDescription(String tones) {
    return 'Intentionally omitted: $tones.';
  }

  @override
  String get rootlessVoicingDescription => 'Rootless voicing.';

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
  String get scaleLibraryIntro =>
      'Build scales from reusable music theory and explore their notes, degree formulas, and relationships offline.';

  @override
  String get scaleSearchLabel => 'Scale search';

  @override
  String get scaleSearchHint =>
      'Try C major, F# minor, D Dorian, or A minor pentatonic';

  @override
  String get unsupportedScaleSearch =>
      'Enter an exact supported scale such as C major or D Dorian.';

  @override
  String get scaleTypeLabel => 'Scale';

  @override
  String get scaleNotesLabel => 'Notes';

  @override
  String get scaleFormulaLabel => 'Degree formula';

  @override
  String get scaleCategoryLabel => 'Category';

  @override
  String get scaleAliasesLabel => 'Also known as';

  @override
  String get scaleRelationshipsLabel => 'Relationships';

  @override
  String get relativeMinorLabel => 'Relative minor';

  @override
  String get relativeMajorLabel => 'Relative major';

  @override
  String get parentMajorLabel => 'Parent major';

  @override
  String modeDegreeValue(int degree) {
    return 'Mode $degree of the parent major scale';
  }

  @override
  String get ascendingMelodicMinorNote =>
      'The melodic minor formula shown is the ascending form.';

  @override
  String scaleSummarySemantics(String name, String notes, String formula) {
    return '$name. Notes: $notes. Degree formula: $formula.';
  }

  @override
  String get scaleMajor => 'Major';

  @override
  String get scaleNaturalMinor => 'Natural Minor';

  @override
  String get scaleHarmonicMinor => 'Harmonic Minor';

  @override
  String get scaleMelodicMinor => 'Melodic Minor';

  @override
  String get scaleDorian => 'Dorian';

  @override
  String get scalePhrygian => 'Phrygian';

  @override
  String get scaleLydian => 'Lydian';

  @override
  String get scaleMixolydian => 'Mixolydian';

  @override
  String get scaleLocrian => 'Locrian';

  @override
  String get scaleMajorPentatonic => 'Major Pentatonic';

  @override
  String get scaleMinorPentatonic => 'Minor Pentatonic';

  @override
  String get scaleBlues => 'Blues';

  @override
  String get scaleCategoryMajorMinor => 'Major / Minor';

  @override
  String get scaleCategoryModes => 'Modes';

  @override
  String get scaleCategoryPentatonicBlues => 'Pentatonic / Blues';

  @override
  String get scaleCategoryOther => 'Other';

  @override
  String get scaleAliasIonian => 'Ionian';

  @override
  String get scaleAliasAeolian => 'Aeolian';

  @override
  String get degreeOneSpoken => 'one';

  @override
  String get degreeFlatTwoSpoken => 'flat two';

  @override
  String get degreeTwoSpoken => 'two';

  @override
  String get degreeFlatThreeSpoken => 'flat three';

  @override
  String get degreeThreeSpoken => 'three';

  @override
  String get degreeFourSpoken => 'four';

  @override
  String get degreeSharpFourSpoken => 'sharp four';

  @override
  String get degreeFlatFiveSpoken => 'flat five';

  @override
  String get degreeFiveSpoken => 'five';

  @override
  String get degreeFlatSixSpoken => 'flat six';

  @override
  String get degreeSixSpoken => 'six';

  @override
  String get degreeFlatSevenSpoken => 'flat seven';

  @override
  String get degreeSevenSpoken => 'seven';

  @override
  String get interactiveFretboard => 'Interactive Fretboard';

  @override
  String get fretboardIntro =>
      'Explore chord tones and scale notes across a standard-tuned guitar neck.';

  @override
  String get fretboardModeLabel => 'Content';

  @override
  String get chordMode => 'Chord';

  @override
  String get scaleMode => 'Scale';

  @override
  String get displayModeLabel => 'Labels';

  @override
  String get noteNames => 'Notes';

  @override
  String get degreesIntervals => 'Degrees / intervals';

  @override
  String get visibleFretRange => 'Visible fret range';

  @override
  String fretRangeValue(int fret) {
    return '0–$fret';
  }

  @override
  String get fretboardOrientationHint =>
      'High E is shown at the top; low E is shown at the bottom. Scroll horizontally to see later frets.';

  @override
  String fretboardSemantics(String name, int fret, String root) {
    return '$name fretboard, frets zero through $fret. Root notes $root highlighted. High E is at the top and low E is at the bottom.';
  }

  @override
  String get selectedPositionTitle => 'Selected position';

  @override
  String get selectedNoteLabel => 'Note';

  @override
  String get degreeIntervalLabel => 'Degree / interval';

  @override
  String get stringLabel => 'String';

  @override
  String get fretLabel => 'Fret';

  @override
  String get tapHighlightedNoteHint =>
      'Tap a highlighted note for pitch, string, fret, and relationship details.';

  @override
  String get viewOnFretboard => 'View on Fretboard';

  @override
  String get circleOfFifths => 'Circle of Fifths';

  @override
  String get circleOfFifthsIntro =>
      'Explore key signatures, relative keys, neighboring fifths and fourths, and diatonic harmony offline.';

  @override
  String get keyMajor => 'Major';

  @override
  String get keyMinor => 'Minor';

  @override
  String get parallelMajorLabel => 'Parallel major';

  @override
  String get parallelMinorLabel => 'Parallel minor';

  @override
  String get keySignatureLabel => 'Key signature';

  @override
  String get alteredNotesLabel => 'Altered notes';

  @override
  String get enharmonicEquivalentLabel => 'Enharmonic equivalent';

  @override
  String sharpCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sharps',
      one: '1 sharp',
    );
    return '$_temp0';
  }

  @override
  String flatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flats',
      one: '1 flat',
    );
    return '$_temp0';
  }

  @override
  String get noSharpsOrFlats => 'No sharps or flats';

  @override
  String get fifthNeighborLabel => 'Fifth';

  @override
  String get fourthNeighborLabel => 'Fourth';

  @override
  String get diatonicChordsLabel => 'Diatonic chords';

  @override
  String get triadsLabel => 'Triads';

  @override
  String get seventhChordsLabel => 'Seventh chords';

  @override
  String get viewScale => 'View Scale';

  @override
  String get circleOrientationHint =>
      'C major is at 12 o\'clock. Move clockwise by fifths and counter-clockwise by fourths.';

  @override
  String get circleLargeTextOrder => 'Circle order';

  @override
  String get selectedKeyIndicator => 'Selected key';

  @override
  String get relativeKeyIndicator => 'Relative key';

  @override
  String get fifthNeighborIndicator => 'Clockwise fifth neighbor';

  @override
  String get fourthNeighborIndicator => 'Counter-clockwise fourth neighbor';

  @override
  String get tapChordHint => 'Tap a chord to open it in Chord Library.';

  @override
  String get relationshipUnavailable =>
      'Not available in the supported key-signature range';

  @override
  String circleSemantics(
    String selected,
    String relative,
    String fifth,
    String fourth,
  ) {
    return 'Circle of Fifths. $selected selected. Relative key $relative. Clockwise neighbor $fifth. Counter-clockwise neighbor $fourth.';
  }

  @override
  String circleKeySemantics(String name, String relationship) {
    return '$name. $relationship.';
  }

  @override
  String keySignatureSemantics(String description, String notes) {
    return '$description. Altered notes: $notes.';
  }

  @override
  String diatonicChordSemantics(String roman, String chord) {
    return '$roman, $chord. Opens Chord Library.';
  }

  @override
  String get musicTheory => 'Music Theory';

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
  String get chromaticMode => 'Chromatic';

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
  String get resumeTuning => 'Resume listening';

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
  String get tunerStoppedMessage => 'Listening paused.';

  @override
  String get tunerRequestingPermissionMessage =>
      'Requesting microphone permission.';

  @override
  String get tunerListeningMessage => 'Microphone is starting.';

  @override
  String get tunerWaitingForSignalMessage => 'Listening… Play one note.';

  @override
  String get tunerUnstableSignalMessage => 'Listening… no stable pitch yet.';

  @override
  String get tunerStablePitchMessage => 'Pitch detected.';

  @override
  String get tunerNoSignalMessage => 'No reliable signal. Play one note.';

  @override
  String get tunerPermissionDeniedMessage => 'Microphone permission required.';

  @override
  String get tunerMicrophoneUnavailableMessage =>
      'The microphone is unavailable. Try again.';

  @override
  String get tunerProcessingErrorMessage =>
      'Pitch processing stopped. Try again.';

  @override
  String get tunerModeLabel => 'Detection';

  @override
  String get tunerAutomaticTargetHint =>
      'Tunathic picks the closest string while you play. Switch to Manual to lock one.';

  @override
  String get tunerChromaticTargetHint =>
      'Any note you play is named against your reference pitch. No tuning preset is used.';

  @override
  String get tunerChromaticTargetLabel => 'Chromatic';

  @override
  String get tunerTargetPending => 'Waiting for a string';

  @override
  String tunerActiveTargetSemantics(String note, int position) {
    return 'Tuning to $note, string $position';
  }

  @override
  String referencePitchValue(String value) {
    return 'A4 = $value Hz';
  }

  @override
  String referencePitchSemantics(String value) {
    return 'Reference pitch A4, $value hertz';
  }

  @override
  String get decreaseReferencePitch => 'Lower the reference pitch';

  @override
  String get increaseReferencePitch => 'Raise the reference pitch';

  @override
  String get resetReferencePitch => 'Reset to A4 = 440 Hz';

  @override
  String get tunerMicrophonePermissionTitle => 'Microphone permission required';

  @override
  String get tunerMicrophoneUnavailableTitle => 'Microphone unavailable';

  @override
  String get tunerProcessingErrorTitle => 'Pitch analysis stopped';

  @override
  String get tunerNoSignalTitle => 'No signal detected';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get musicTheoryTagline =>
      'Learn music theory from beginner to advanced.';

  @override
  String get theoryHubIntro =>
      'Nine categories, from single notes to guitar-specific theory. Everything works offline.';

  @override
  String get theorySearchHint => 'Search lessons, intervals, and chords';

  @override
  String get theorySearchLabel => 'Search lessons';

  @override
  String get theoryClearSearch => 'Clear search';

  @override
  String get theoryLevelLabel => 'Level';

  @override
  String get theoryLevelAll => 'All';

  @override
  String get theoryCategoriesTitle => 'Categories';

  @override
  String get theoryFavorites => 'Favorites';

  @override
  String get theoryFavoritesEmpty => 'Star a lesson to keep it here.';

  @override
  String get theoryRecentlyViewed => 'Recently viewed';

  @override
  String get theoryAddFavorite => 'Add to favorites';

  @override
  String get theoryRemoveFavorite => 'Remove from favorites';

  @override
  String get theoryTryIt => 'Try it';

  @override
  String get theoryNextLesson => 'Next lesson';

  @override
  String get theoryPreviousLesson => 'Previous lesson';

  @override
  String theoryLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String theoryResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons found',
      one: '1 lesson found',
      zero: 'No lessons found',
    );
    return '$_temp0';
  }

  @override
  String theoryNoResults(String query) {
    return 'No lessons match “$query”.';
  }

  @override
  String get theoryNoResultsHint =>
      'Try a note name, an interval such as m3, or a chord symbol.';

  @override
  String get theoryOpenInChordLibrary => 'Open in Chord Library';

  @override
  String get theoryOpenInScaleLibrary => 'Open in Scale Library';

  @override
  String get theoryOpenCircle => 'Open Circle';

  @override
  String get theoryOpenInteractiveFretboard => 'Open Interactive Fretboard';

  @override
  String get theoryOpenMetronome => 'Open Metronome';

  @override
  String get theoryOpenBpmTap => 'Open BPM Tap';

  @override
  String get theoryOpenGuitarTuner => 'Open Guitar Tuner';

  @override
  String get theoryNotesLabel => 'Notes';

  @override
  String get theoryFormulaLabel => 'Formula';

  @override
  String get theorySemitonesLabel => 'Semitones';

  @override
  String get theoryQualityLabel => 'Quality';

  @override
  String get theoryShorthandLabel => 'Shorthand';

  @override
  String get theoryAlsoSpelledLabel => 'Also spelled';

  @override
  String get theoryGuitarShapeLabel => 'Guitar shape';

  @override
  String get theoryFretboardLabel => 'On the fretboard';

  @override
  String get theoryOpenStringsLabel => 'Open strings';

  @override
  String get theoryNoteValuesLabel => 'Note values';

  @override
  String get theoryKeySignaturesLabel => 'Key signatures';

  @override
  String theoryDiatonicChordsLabel(String key) {
    return 'Chords in $key';
  }

  @override
  String theoryBeatsValue(String beats) {
    return '$beats beats';
  }

  @override
  String theoryFretRangeLabel(int first, int last) {
    return 'Frets $first–$last';
  }

  @override
  String theoryStringFret(String string, int fret) {
    return 'String $string, fret $fret';
  }

  @override
  String theoryIntervalShapeSemantics(
    String interval,
    String rootString,
    int rootFret,
    String targetString,
    int targetFret,
  ) {
    return '$interval shape: root on string $rootString at fret $rootFret, target on string $targetString at fret $targetFret.';
  }

  @override
  String theoryFretboardSemantics(
    String subject,
    int first,
    int last,
    String notes,
  ) {
    return 'Fretboard diagram for $subject, frets $first to $last. $notes';
  }

  @override
  String theoryLessonSemantics(String title, String level, String summary) {
    return '$title, $level. $summary';
  }

  @override
  String theoryCategorySemantics(
    String name,
    String count,
    String description,
  ) {
    return '$name, $count. $description';
  }

  @override
  String get theoryCategoryMusicalNotes => 'Musical Notes';

  @override
  String get theoryCategoryMusicalNotesDescription =>
      'Note names, sharps, flats, enharmonics, octaves, and pitch notation.';

  @override
  String get theoryCategoryIntervals => 'Intervals';

  @override
  String get theoryCategoryIntervalsDescription =>
      'Every distance inside the octave, its sound, and its shape on the guitar.';

  @override
  String get theoryCategoryChords => 'Chords';

  @override
  String get theoryCategoryChordsDescription =>
      'Triads, sevenths, suspensions, extensions, inversions, and voicings.';

  @override
  String get theoryCategoryScales => 'Scales';

  @override
  String get theoryCategoryScalesDescription =>
      'Major, minor, pentatonic, blues, and the seven modes.';

  @override
  String get theoryCategoryCircleOfFifths => 'Circle of Fifths';

  @override
  String get theoryCategoryCircleOfFifthsDescription =>
      'Key signatures, relative and parallel keys, and modulation.';

  @override
  String get theoryCategoryFretboardTheory => 'Fretboard Theory';

  @override
  String get theoryCategoryFretboardTheoryDescription =>
      'Note locations, octave and interval shapes, movable patterns, and CAGED.';

  @override
  String get theoryCategoryRhythm => 'Rhythm';

  @override
  String get theoryCategoryRhythmDescription =>
      'Tempo, note values, rests, dots, triplets, swing, and time signatures.';

  @override
  String get theoryCategoryHarmony => 'Harmony';

  @override
  String get theoryCategoryHarmonyDescription =>
      'Tonic, dominant, subdominant, cadences, and Roman numerals.';

  @override
  String get theoryCategoryGuitarTheory => 'Guitar Theory';

  @override
  String get theoryCategoryGuitarTheoryDescription =>
      'Tunings, capo, transposition, chord building, and scale positions.';

  @override
  String get repertoire => 'Repertoire';

  @override
  String get repertoireEmptyTitle => 'No songs yet';

  @override
  String get repertoireEmptyDescription =>
      'Add lyrics with their chords, then transpose them and let the sheet scroll while both hands stay on the guitar.';

  @override
  String get addSong => 'Add song';

  @override
  String get newSongTitle => 'New song';

  @override
  String get editSongTitle => 'Edit song';

  @override
  String get editSong => 'Edit';

  @override
  String get songTitleLabel => 'Title';

  @override
  String get songArtistLabel => 'Artist';

  @override
  String get songContentLabel => 'Lyrics';

  @override
  String get songContentHint =>
      'Just the lyrics is enough. After saving you can tap any word to put a chord on it. Pasted charts with chords above the lyrics, and [Am] brackets, also work.';

  @override
  String get songTitleRequired => 'Enter a title.';

  @override
  String get saveSong => 'Save';

  @override
  String get deleteSong => 'Delete song';

  @override
  String deleteSongPrompt(String songTitle) {
    return 'Delete $songTitle? Songs are stored only on this device and cannot be recovered.';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get chartConverted =>
      'Chords above the lyrics were converted automatically.';

  @override
  String get searchSongs => 'Search songs';

  @override
  String get noMatchingSongs => 'No songs match your search.';

  @override
  String get emptySongContent =>
      'This song has no lyrics yet. Use Edit to add them.';

  @override
  String get transposeLabel => 'Transpose';

  @override
  String get transposeDown => 'Transpose down one semitone';

  @override
  String get transposeUp => 'Transpose up one semitone';

  @override
  String get transposeReset => 'Reset to the written key';

  @override
  String transposeSemitones(int value) {
    return 'Transposed $value semitones';
  }

  @override
  String get accidentalStyle => 'Accidentals';

  @override
  String get accidentalAuto => 'Auto';

  @override
  String get accidentalSharps => 'Sharps';

  @override
  String get accidentalFlats => 'Flats';

  @override
  String get autoScroll => 'Auto-scroll';

  @override
  String get startAutoScroll => 'Start auto-scroll';

  @override
  String get stopAutoScroll => 'Stop auto-scroll';

  @override
  String get scrollSpeed => 'Scroll speed';

  @override
  String scrollSpeedValue(int level, int max) {
    return 'Speed $level of $max';
  }

  @override
  String get songChordsLabel => 'Chords';

  @override
  String get editChords => 'Edit chords';

  @override
  String get doneEditingChords => 'Done';

  @override
  String get editChordsHint =>
      'Tap a word to put a chord on it, or tap a chord to change or remove it. Use + for a chord with no word under it, such as an intro or an instrumental break.';

  @override
  String get addChordAtLineEnd =>
      'Add a chord after the last word of this line';

  @override
  String get addChordOnEmptyLine => 'Add a chord on this empty line';

  @override
  String changeChord(String chord) {
    return 'Change the $chord chord';
  }

  @override
  String get chordPickerTitleNoWord => 'Chord';

  @override
  String chordPickerTitle(String word) {
    return 'Chord on \"$word\"';
  }

  @override
  String get chordPickerRoot => 'Root';

  @override
  String get chordPickerQuality => 'Quality';

  @override
  String get chordsUsedInSong => 'Used in this song';

  @override
  String get removeChord => 'Remove chord';

  @override
  String placeChordOn(String word) {
    return 'Put a chord on $word';
  }

  @override
  String changeChordOn(String chord, String word) {
    return 'Change the $chord chord on $word';
  }

  @override
  String get privacyRepertoireTitle => 'Your songs stay on this device';

  @override
  String get privacyRepertoireDescription =>
      'Songs you add to the Repertoire, including their lyrics, chords, and transposition settings, are stored locally on this device. They are not uploaded, sent to GUNDEV, or shared.';
}
