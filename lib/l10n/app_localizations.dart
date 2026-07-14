import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tunathic'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Tune. Train. Create.'**
  String get tagline;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Guitar toolkit'**
  String get dashboardTitle;

  /// No description provided for @dashboardIntro.
  ///
  /// In en, this message translates to:
  /// **'Everything you need for focused practice, in one place.'**
  String get dashboardIntro;

  /// No description provided for @practiceSection.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceSection;

  /// No description provided for @theoryReferenceSection.
  ///
  /// In en, this message translates to:
  /// **'Theory and Reference'**
  String get theoryReferenceSection;

  /// No description provided for @trainingSection.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingSection;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settingsTooltip;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @themeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @interactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get interactionTitle;

  /// No description provided for @hapticFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedbackTitle;

  /// No description provided for @hapticFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Use subtle vibration for meaningful taps and selections.'**
  String get hapticFeedbackDescription;

  /// No description provided for @applicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get applicationTitle;

  /// No description provided for @aboutTunathic.
  ///
  /// In en, this message translates to:
  /// **'About Tunathic'**
  String get aboutTunathic;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @productFullName.
  ///
  /// In en, this message translates to:
  /// **'Tunathic – Guitar Toolkit'**
  String get productFullName;

  /// No description provided for @aboutProductDescription.
  ///
  /// In en, this message translates to:
  /// **'A focused, offline-first toolkit for guitar practice, timing, and music theory.'**
  String get aboutProductDescription;

  /// No description provided for @publisherLabel.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisherLabel;

  /// No description provided for @copyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© 2026 GUNDEV. All rights reserved.'**
  String get copyrightNotice;

  /// No description provided for @availableToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available tools'**
  String get availableToolsTitle;

  /// No description provided for @plannedToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Planned tools'**
  String get plannedToolsTitle;

  /// No description provided for @privacySummary.
  ///
  /// In en, this message translates to:
  /// **'Tunathic is designed to keep the current practice experience private and local to your device.'**
  String get privacySummary;

  /// No description provided for @privacyBpmTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice sessions stay temporary'**
  String get privacyBpmTitle;

  /// No description provided for @privacyBpmDescription.
  ///
  /// In en, this message translates to:
  /// **'BPM Tap sessions remain in memory and are cleared when the session ends. They are not uploaded.'**
  String get privacyBpmDescription;

  /// No description provided for @privacyLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences stay on this device'**
  String get privacyLocalTitle;

  /// No description provided for @privacyLocalDescription.
  ///
  /// In en, this message translates to:
  /// **'Theme, language, haptic, and Metronome settings are stored locally on this device.'**
  String get privacyLocalDescription;

  /// No description provided for @privacyMicrophoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone prototype stays local'**
  String get privacyMicrophoneTitle;

  /// No description provided for @privacyMicrophoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is used only while the Tuner Audio Prototype is actively capturing. Raw audio is processed locally, never saved or uploaded, and capture stops when you leave the screen or the app enters the background.'**
  String get privacyMicrophoneDescription;

  /// No description provided for @privacyNoCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts, ads, analytics, or backend'**
  String get privacyNoCollectionTitle;

  /// No description provided for @privacyNoCollectionDescription.
  ///
  /// In en, this message translates to:
  /// **'The current app requires no account, includes no advertising or analytics, has no Tunathic backend, and sends no app data to GUNDEV servers.'**
  String get privacyNoCollectionDescription;

  /// No description provided for @privacyFutureChanges.
  ///
  /// In en, this message translates to:
  /// **'This privacy information must be reviewed before production tuner, recording, advertising, analytics, account, cloud, or backend features are released.'**
  String get privacyFutureChanges;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @openTool.
  ///
  /// In en, this message translates to:
  /// **'Open tool'**
  String get openTool;

  /// No description provided for @comingSoonDescription.
  ///
  /// In en, this message translates to:
  /// **'{toolName} is planned for a future milestone.'**
  String comingSoonDescription(String toolName);

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get backToDashboard;

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'That page is not available in Tunathic.'**
  String get pageNotFoundDescription;

  /// No description provided for @unexpectedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get unexpectedErrorTitle;

  /// No description provided for @unexpectedErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Tunathic could not show this screen. Please return to the dashboard and try again.'**
  String get unexpectedErrorDescription;

  /// No description provided for @guitarTuner.
  ///
  /// In en, this message translates to:
  /// **'Guitar Tuner'**
  String get guitarTuner;

  /// No description provided for @metronome.
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get metronome;

  /// No description provided for @startMetronome.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startMetronome;

  /// No description provided for @stopMetronome.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopMetronome;

  /// No description provided for @tempo.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get tempo;

  /// No description provided for @beatsPerMinute.
  ///
  /// In en, this message translates to:
  /// **'Beats per minute'**
  String get beatsPerMinute;

  /// No description provided for @tempoValue.
  ///
  /// In en, this message translates to:
  /// **'{bpm} beats per minute'**
  String tempoValue(int bpm);

  /// No description provided for @decreaseTempo.
  ///
  /// In en, this message translates to:
  /// **'Decrease tempo'**
  String get decreaseTempo;

  /// No description provided for @increaseTempo.
  ///
  /// In en, this message translates to:
  /// **'Increase tempo'**
  String get increaseTempo;

  /// No description provided for @timeSignature.
  ///
  /// In en, this message translates to:
  /// **'Time signature'**
  String get timeSignature;

  /// No description provided for @currentBeat.
  ///
  /// In en, this message translates to:
  /// **'Current beat'**
  String get currentBeat;

  /// No description provided for @currentBeatValue.
  ///
  /// In en, this message translates to:
  /// **'Current beat: {beat} of {total}'**
  String currentBeatValue(int beat, int total);

  /// No description provided for @metronomeStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get metronomeStopped;

  /// No description provided for @preparingAudio.
  ///
  /// In en, this message translates to:
  /// **'Preparing audio'**
  String get preparingAudio;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @accentFirstBeat.
  ///
  /// In en, this message translates to:
  /// **'Accent first beat'**
  String get accentFirstBeat;

  /// No description provided for @volumePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% volume'**
  String volumePercent(int percent);

  /// No description provided for @openBpmTapForMetronome.
  ///
  /// In en, this message translates to:
  /// **'Open BPM Tap'**
  String get openBpmTapForMetronome;

  /// No description provided for @applyBpmTapResult.
  ///
  /// In en, this message translates to:
  /// **'Apply BPM Tap result'**
  String get applyBpmTapResult;

  /// No description provided for @bpmTapApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied {bpm} BPM to the metronome.'**
  String bpmTapApplied(int bpm);

  /// No description provided for @metronomeGuidance.
  ///
  /// In en, this message translates to:
  /// **'Choose a tempo and time signature, then start. The first beat is accented when accent is enabled.'**
  String get metronomeGuidance;

  /// No description provided for @audioUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Metronome audio unavailable'**
  String get audioUnavailableTitle;

  /// No description provided for @audioUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Tunathic stopped the metronome because audio could not be prepared or played.'**
  String get audioUnavailableDescription;

  /// No description provided for @retryAudio.
  ///
  /// In en, this message translates to:
  /// **'Retry audio'**
  String get retryAudio;

  /// No description provided for @currentAccentedBeat.
  ///
  /// In en, this message translates to:
  /// **'current accented beat'**
  String get currentAccentedBeat;

  /// No description provided for @currentBeatDetail.
  ///
  /// In en, this message translates to:
  /// **'current beat'**
  String get currentBeatDetail;

  /// No description provided for @accentedBeat.
  ///
  /// In en, this message translates to:
  /// **'accented first beat'**
  String get accentedBeat;

  /// No description provided for @inactiveBeat.
  ///
  /// In en, this message translates to:
  /// **'inactive beat'**
  String get inactiveBeat;

  /// No description provided for @beatIndicatorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Beat {beat}, {details}'**
  String beatIndicatorSemantics(int beat, String details);

  /// No description provided for @bpmTap.
  ///
  /// In en, this message translates to:
  /// **'BPM Tap'**
  String get bpmTap;

  /// No description provided for @bpmLabel.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpmLabel;

  /// No description provided for @tapToBegin.
  ///
  /// In en, this message translates to:
  /// **'Tap to begin'**
  String get tapToBegin;

  /// No description provided for @keepTapping.
  ///
  /// In en, this message translates to:
  /// **'Keep tapping'**
  String get keepTapping;

  /// No description provided for @bpmEstimateReady.
  ///
  /// In en, this message translates to:
  /// **'Tempo detected. Keep tapping to refine it.'**
  String get bpmEstimateReady;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @sessionReset.
  ///
  /// In en, this message translates to:
  /// **'Session reset after inactivity. Tap to begin again.'**
  String get sessionReset;

  /// No description provided for @invalidTapIgnored.
  ///
  /// In en, this message translates to:
  /// **'That tap was outside the valid tempo range and was ignored.'**
  String get invalidTapIgnored;

  /// No description provided for @bpmTapGuidance.
  ///
  /// In en, this message translates to:
  /// **'Tap steadily with the beat. The latest taps keep the reading responsive.'**
  String get bpmTapGuidance;

  /// No description provided for @noRecentInterval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an interval'**
  String get noRecentInterval;

  /// No description provided for @tapCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No taps} =1{1 tap} other{{count} taps}}'**
  String tapCount(int count);

  /// No description provided for @recentInterval.
  ///
  /// In en, this message translates to:
  /// **'{milliseconds} ms since last tap'**
  String recentInterval(int milliseconds);

  /// No description provided for @tapSurfaceSemantics.
  ///
  /// In en, this message translates to:
  /// **'{status}. {count} accepted taps. {bpm} BPM.'**
  String tapSurfaceSemantics(String status, int count, String bpm);

  /// No description provided for @chordLibrary.
  ///
  /// In en, this message translates to:
  /// **'Chord Library'**
  String get chordLibrary;

  /// No description provided for @scaleLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scale Library'**
  String get scaleLibrary;

  /// No description provided for @circleOfFifths.
  ///
  /// In en, this message translates to:
  /// **'Circle of Fifths'**
  String get circleOfFifths;

  /// No description provided for @intervalTrainer.
  ///
  /// In en, this message translates to:
  /// **'Interval Trainer'**
  String get intervalTrainer;

  /// No description provided for @earTraining.
  ///
  /// In en, this message translates to:
  /// **'Ear Training'**
  String get earTraining;

  /// No description provided for @chordFinder.
  ///
  /// In en, this message translates to:
  /// **'Chord Finder'**
  String get chordFinder;

  /// No description provided for @capoCalculator.
  ///
  /// In en, this message translates to:
  /// **'Capo Calculator'**
  String get capoCalculator;

  /// No description provided for @tunerAudioPrototypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tuner Audio Prototype'**
  String get tunerAudioPrototypeTitle;

  /// No description provided for @tunerAudioPrototypeWarning.
  ///
  /// In en, this message translates to:
  /// **'Technical prototype only. This validates microphone input and is not a working guitar tuner.'**
  String get tunerAudioPrototypeWarning;

  /// No description provided for @microphonePermissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission'**
  String get microphonePermissionLabel;

  /// No description provided for @microphonePermissionNotRequested.
  ///
  /// In en, this message translates to:
  /// **'Not requested'**
  String get microphonePermissionNotRequested;

  /// No description provided for @microphonePermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get microphonePermissionGranted;

  /// No description provided for @microphonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get microphonePermissionDenied;

  /// No description provided for @startCapture.
  ///
  /// In en, this message translates to:
  /// **'Start capture'**
  String get startCapture;

  /// No description provided for @stopCapture.
  ///
  /// In en, this message translates to:
  /// **'Stop capture'**
  String get stopCapture;

  /// No description provided for @captureStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Capture status'**
  String get captureStatusLabel;

  /// No description provided for @captureStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get captureStatusIdle;

  /// No description provided for @captureStatusRequestingPermission.
  ///
  /// In en, this message translates to:
  /// **'Requesting permission'**
  String get captureStatusRequestingPermission;

  /// No description provided for @captureStatusStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting microphone'**
  String get captureStatusStarting;

  /// No description provided for @captureStatusCapturing.
  ///
  /// In en, this message translates to:
  /// **'Capturing'**
  String get captureStatusCapturing;

  /// No description provided for @captureStatusStopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping'**
  String get captureStatusStopping;

  /// No description provided for @captureStatusError.
  ///
  /// In en, this message translates to:
  /// **'Capture error'**
  String get captureStatusError;

  /// No description provided for @requestedSampleRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested sample rate'**
  String get requestedSampleRateLabel;

  /// No description provided for @reportedSampleRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported sample rate'**
  String get reportedSampleRateLabel;

  /// No description provided for @reportedSampleRateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not reported by the audio backend'**
  String get reportedSampleRateUnavailable;

  /// No description provided for @sampleRateValue.
  ///
  /// In en, this message translates to:
  /// **'{sampleRate} Hz'**
  String sampleRateValue(int sampleRate);

  /// No description provided for @channelCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channelCountLabel;

  /// No description provided for @channelCountValue.
  ///
  /// In en, this message translates to:
  /// **'{channelCount} (mono)'**
  String channelCountValue(int channelCount);

  /// No description provided for @pcmEncodingLabel.
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get pcmEncodingLabel;

  /// No description provided for @pcm16LittleEndian.
  ///
  /// In en, this message translates to:
  /// **'Signed PCM16, little-endian'**
  String get pcm16LittleEndian;

  /// No description provided for @signalStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Signal statistics'**
  String get signalStatisticsTitle;

  /// No description provided for @inputLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Input level'**
  String get inputLevelLabel;

  /// No description provided for @peakAmplitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak amplitude'**
  String get peakAmplitudeLabel;

  /// No description provided for @rmsAmplitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'RMS amplitude'**
  String get rmsAmplitudeLabel;

  /// No description provided for @dbfsLabel.
  ///
  /// In en, this message translates to:
  /// **'dBFS'**
  String get dbfsLabel;

  /// No description provided for @silenceDbfs.
  ///
  /// In en, this message translates to:
  /// **'−∞ dBFS'**
  String get silenceDbfs;

  /// No description provided for @dbfsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} dBFS'**
  String dbfsValue(String value);

  /// No description provided for @framesReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Frames received'**
  String get framesReceivedLabel;

  /// No description provided for @samplesReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Samples received'**
  String get samplesReceivedLabel;

  /// No description provided for @streamDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Stream duration'**
  String get streamDurationLabel;

  /// No description provided for @durationSecondsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String durationSecondsValue(String value);

  /// No description provided for @observedFrameSizesLabel.
  ///
  /// In en, this message translates to:
  /// **'Observed frame sizes'**
  String get observedFrameSizesLabel;

  /// No description provided for @frameSizesValue.
  ///
  /// In en, this message translates to:
  /// **'{minimum}–{maximum} samples; {average} average'**
  String frameSizesValue(int minimum, int maximum, String average);

  /// No description provided for @frameArrivalRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Approximate frame arrival rate'**
  String get frameArrivalRateLabel;

  /// No description provided for @framesPerSecondValue.
  ///
  /// In en, this message translates to:
  /// **'{value} frames/s'**
  String framesPerSecondValue(String value);

  /// No description provided for @malformedFramesLabel.
  ///
  /// In en, this message translates to:
  /// **'Malformed frames'**
  String get malformedFramesLabel;

  /// No description provided for @prototypePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get prototypePrivacyTitle;

  /// No description provided for @prototypePrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Audio is processed only in memory on this device. Raw microphone data and signal statistics are not saved or transmitted.'**
  String get prototypePrivacyDescription;

  /// No description provided for @prototypeLifecycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Foreground capture only'**
  String get prototypeLifecycleTitle;

  /// No description provided for @prototypeLifecycleDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture stops when you leave this screen, background or hide the app, or lock the screen. It never restarts automatically.'**
  String get prototypeLifecycleDescription;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was denied. Start again only if you want to retry; Tunathic will not open system settings automatically.'**
  String get permissionDeniedMessage;

  /// No description provided for @unsupportedAudioMessage.
  ///
  /// In en, this message translates to:
  /// **'This device did not accept the prototype PCM audio configuration.'**
  String get unsupportedAudioMessage;

  /// No description provided for @audioStartFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Tunathic could not start microphone capture. You can try again.'**
  String get audioStartFailedMessage;

  /// No description provided for @audioStreamFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone capture stopped because the audio stream failed. You can try again.'**
  String get audioStreamFailedMessage;

  /// No description provided for @audioStopFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Tunathic could not finish releasing the microphone cleanly. You can try again.'**
  String get audioStopFailedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
