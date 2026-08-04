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
  /// **'Tunathic is designed as an offline guitar toolkit. Its current tools do not send your app data to GUNDEV or other third parties.'**
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
  /// **'Theme, language, haptic, Metronome, and Guitar Tuner preferences are stored locally on this device. Chord, scale, fretboard, and Circle of Fifths content is bundled with the app.'**
  String get privacyLocalDescription;

  /// No description provided for @privacyMicrophoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone pitch analysis stays local'**
  String get privacyMicrophoneTitle;

  /// No description provided for @privacyMicrophoneDescription.
  ///
  /// In en, this message translates to:
  /// **'The Guitar Tuner uses microphone access only after you start it. Raw audio and pitch estimates are processed transiently on this device, are never saved or uploaded, and stop when you leave the tuner or the app enters the background.'**
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
  /// **'Tunathic does not store microphone recordings, create accounts, show ads, run analytics, sell data, or share app data. This information will be updated if the app\'s behavior changes.'**
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

  /// No description provided for @chordLibraryIntro.
  ///
  /// In en, this message translates to:
  /// **'Build chords from music theory and explore validated guitar shapes offline.'**
  String get chordLibraryIntro;

  /// No description provided for @chordSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Chord search'**
  String get chordSearchLabel;

  /// No description provided for @chordSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Try C, Cm, Cmaj7, F#m, or Bb7'**
  String get chordSearchHint;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @unsupportedChordSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter a supported chord symbol such as Cmaj7 or F#m.'**
  String get unsupportedChordSearch;

  /// No description provided for @rootNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Root note'**
  String get rootNoteLabel;

  /// No description provided for @chordQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Chord quality'**
  String get chordQualityLabel;

  /// No description provided for @chordSymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Chord symbol'**
  String get chordSymbolLabel;

  /// No description provided for @chordTonesLabel.
  ///
  /// In en, this message translates to:
  /// **'Chord tones'**
  String get chordTonesLabel;

  /// No description provided for @guitarShapesLabel.
  ///
  /// In en, this message translates to:
  /// **'Guitar shapes'**
  String get guitarShapesLabel;

  /// No description provided for @primaryShapeLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected shape'**
  String get primaryShapeLabel;

  /// No description provided for @alternateShapesLabel.
  ///
  /// In en, this message translates to:
  /// **'Available shapes'**
  String get alternateShapesLabel;

  /// No description provided for @fingeringLabel.
  ///
  /// In en, this message translates to:
  /// **'Fingering'**
  String get fingeringLabel;

  /// No description provided for @noChordShapeTitle.
  ///
  /// In en, this message translates to:
  /// **'No curated guitar shape'**
  String get noChordShapeTitle;

  /// No description provided for @noChordShapeDescription.
  ///
  /// In en, this message translates to:
  /// **'The chord is theoretically valid, but this offline library does not currently include a verified shape for it.'**
  String get noChordShapeDescription;

  /// No description provided for @startingFretValue.
  ///
  /// In en, this message translates to:
  /// **'Starting fret {fret}'**
  String startingFretValue(int fret);

  /// No description provided for @openPositionShape.
  ///
  /// In en, this message translates to:
  /// **'Open position'**
  String get openPositionShape;

  /// No description provided for @movableEShape.
  ///
  /// In en, this message translates to:
  /// **'Movable E shape'**
  String get movableEShape;

  /// No description provided for @movableAShape.
  ///
  /// In en, this message translates to:
  /// **'Movable A shape'**
  String get movableAShape;

  /// No description provided for @compactShape.
  ///
  /// In en, this message translates to:
  /// **'Compact voicing'**
  String get compactShape;

  /// No description provided for @beginnerDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginnerDifficulty;

  /// No description provided for @intermediateDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediateDifficulty;

  /// No description provided for @advancedDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedDifficulty;

  /// No description provided for @omittedTonesDescription.
  ///
  /// In en, this message translates to:
  /// **'Intentionally omitted: {tones}.'**
  String omittedTonesDescription(String tones);

  /// No description provided for @rootlessVoicingDescription.
  ///
  /// In en, this message translates to:
  /// **'Rootless voicing.'**
  String get rootlessVoicingDescription;

  /// No description provided for @triadCategory.
  ///
  /// In en, this message translates to:
  /// **'Triads'**
  String get triadCategory;

  /// No description provided for @seventhChordCategory.
  ///
  /// In en, this message translates to:
  /// **'Seventh chords'**
  String get seventhChordCategory;

  /// No description provided for @extendedChordCategory.
  ///
  /// In en, this message translates to:
  /// **'Extended chords'**
  String get extendedChordCategory;

  /// No description provided for @qualityMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get qualityMajor;

  /// No description provided for @qualityMinor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get qualityMinor;

  /// No description provided for @qualityDiminished.
  ///
  /// In en, this message translates to:
  /// **'Diminished'**
  String get qualityDiminished;

  /// No description provided for @qualityAugmented.
  ///
  /// In en, this message translates to:
  /// **'Augmented'**
  String get qualityAugmented;

  /// No description provided for @qualitySus2.
  ///
  /// In en, this message translates to:
  /// **'Suspended 2'**
  String get qualitySus2;

  /// No description provided for @qualitySus4.
  ///
  /// In en, this message translates to:
  /// **'Suspended 4'**
  String get qualitySus4;

  /// No description provided for @qualityMajor7.
  ///
  /// In en, this message translates to:
  /// **'Major 7'**
  String get qualityMajor7;

  /// No description provided for @qualityDominant7.
  ///
  /// In en, this message translates to:
  /// **'Dominant 7'**
  String get qualityDominant7;

  /// No description provided for @qualityMinor7.
  ///
  /// In en, this message translates to:
  /// **'Minor 7'**
  String get qualityMinor7;

  /// No description provided for @qualityMinorMajor7.
  ///
  /// In en, this message translates to:
  /// **'Minor major 7'**
  String get qualityMinorMajor7;

  /// No description provided for @qualityDiminished7.
  ///
  /// In en, this message translates to:
  /// **'Diminished 7'**
  String get qualityDiminished7;

  /// No description provided for @qualityHalfDiminished7.
  ///
  /// In en, this message translates to:
  /// **'Half-diminished (m7b5)'**
  String get qualityHalfDiminished7;

  /// No description provided for @quality6.
  ///
  /// In en, this message translates to:
  /// **'Major 6'**
  String get quality6;

  /// No description provided for @qualityMinor6.
  ///
  /// In en, this message translates to:
  /// **'Minor 6'**
  String get qualityMinor6;

  /// No description provided for @qualityAdd9.
  ///
  /// In en, this message translates to:
  /// **'Add 9'**
  String get qualityAdd9;

  /// No description provided for @qualityMinorAdd9.
  ///
  /// In en, this message translates to:
  /// **'Minor add 9'**
  String get qualityMinorAdd9;

  /// No description provided for @quality9.
  ///
  /// In en, this message translates to:
  /// **'Dominant 9'**
  String get quality9;

  /// No description provided for @qualityMajor9.
  ///
  /// In en, this message translates to:
  /// **'Major 9'**
  String get qualityMajor9;

  /// No description provided for @qualityMinor9.
  ///
  /// In en, this message translates to:
  /// **'Minor 9'**
  String get qualityMinor9;

  /// No description provided for @quality11.
  ///
  /// In en, this message translates to:
  /// **'Dominant 11'**
  String get quality11;

  /// No description provided for @qualityMinor11.
  ///
  /// In en, this message translates to:
  /// **'Minor 11'**
  String get qualityMinor11;

  /// No description provided for @quality13.
  ///
  /// In en, this message translates to:
  /// **'Dominant 13'**
  String get quality13;

  /// No description provided for @lowEString.
  ///
  /// In en, this message translates to:
  /// **'Low E string'**
  String get lowEString;

  /// No description provided for @aString.
  ///
  /// In en, this message translates to:
  /// **'A string'**
  String get aString;

  /// No description provided for @dString.
  ///
  /// In en, this message translates to:
  /// **'D string'**
  String get dString;

  /// No description provided for @gString.
  ///
  /// In en, this message translates to:
  /// **'G string'**
  String get gString;

  /// No description provided for @bString.
  ///
  /// In en, this message translates to:
  /// **'B string'**
  String get bString;

  /// No description provided for @highEString.
  ///
  /// In en, this message translates to:
  /// **'High E string'**
  String get highEString;

  /// No description provided for @mutedMarker.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get mutedMarker;

  /// No description provided for @openMarker.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openMarker;

  /// No description provided for @fretOnlyValue.
  ///
  /// In en, this message translates to:
  /// **'Fret {fret}'**
  String fretOnlyValue(int fret);

  /// No description provided for @fretAndFingerValue.
  ///
  /// In en, this message translates to:
  /// **'Fret {fret}, finger {finger}'**
  String fretAndFingerValue(int fret, int finger);

  /// No description provided for @guitarStringMutedDescription.
  ///
  /// In en, this message translates to:
  /// **'{stringName} muted.'**
  String guitarStringMutedDescription(String stringName);

  /// No description provided for @guitarStringOpenDescription.
  ///
  /// In en, this message translates to:
  /// **'{stringName} open.'**
  String guitarStringOpenDescription(String stringName);

  /// No description provided for @guitarStringFrettedDescription.
  ///
  /// In en, this message translates to:
  /// **'{stringName} fret {fret}.'**
  String guitarStringFrettedDescription(String stringName, int fret);

  /// No description provided for @guitarStringFingerDescription.
  ///
  /// In en, this message translates to:
  /// **'{stringName} fret {fret}, finger {finger}.'**
  String guitarStringFingerDescription(String stringName, int fret, int finger);

  /// No description provided for @barreDescription.
  ///
  /// In en, this message translates to:
  /// **'Barre at fret {fret}, from {fromString} through {toString}, finger {finger}.'**
  String barreDescription(
    int fret,
    String fromString,
    String toString,
    int finger,
  );

  /// No description provided for @chordDiagramSemantics.
  ///
  /// In en, this message translates to:
  /// **'{chordSymbol} guitar chord diagram. {details}'**
  String chordDiagramSemantics(String chordSymbol, String details);

  /// No description provided for @scaleLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scale Library'**
  String get scaleLibrary;

  /// No description provided for @scaleLibraryIntro.
  ///
  /// In en, this message translates to:
  /// **'Build scales from reusable music theory and explore their notes, degree formulas, and relationships offline.'**
  String get scaleLibraryIntro;

  /// No description provided for @scaleSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Scale search'**
  String get scaleSearchLabel;

  /// No description provided for @scaleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Try C major, F# minor, D Dorian, or A minor pentatonic'**
  String get scaleSearchHint;

  /// No description provided for @unsupportedScaleSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter an exact supported scale such as C major or D Dorian.'**
  String get unsupportedScaleSearch;

  /// No description provided for @scaleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get scaleTypeLabel;

  /// No description provided for @scaleNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get scaleNotesLabel;

  /// No description provided for @scaleFormulaLabel.
  ///
  /// In en, this message translates to:
  /// **'Degree formula'**
  String get scaleFormulaLabel;

  /// No description provided for @scaleCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get scaleCategoryLabel;

  /// No description provided for @scaleAliasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Also known as'**
  String get scaleAliasesLabel;

  /// No description provided for @scaleRelationshipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get scaleRelationshipsLabel;

  /// No description provided for @relativeMinorLabel.
  ///
  /// In en, this message translates to:
  /// **'Relative minor'**
  String get relativeMinorLabel;

  /// No description provided for @relativeMajorLabel.
  ///
  /// In en, this message translates to:
  /// **'Relative major'**
  String get relativeMajorLabel;

  /// No description provided for @parentMajorLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent major'**
  String get parentMajorLabel;

  /// No description provided for @modeDegreeValue.
  ///
  /// In en, this message translates to:
  /// **'Mode {degree} of the parent major scale'**
  String modeDegreeValue(int degree);

  /// No description provided for @ascendingMelodicMinorNote.
  ///
  /// In en, this message translates to:
  /// **'The melodic minor formula shown is the ascending form.'**
  String get ascendingMelodicMinorNote;

  /// No description provided for @scaleSummarySemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}. Notes: {notes}. Degree formula: {formula}.'**
  String scaleSummarySemantics(String name, String notes, String formula);

  /// No description provided for @scaleMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get scaleMajor;

  /// No description provided for @scaleNaturalMinor.
  ///
  /// In en, this message translates to:
  /// **'Natural Minor'**
  String get scaleNaturalMinor;

  /// No description provided for @scaleHarmonicMinor.
  ///
  /// In en, this message translates to:
  /// **'Harmonic Minor'**
  String get scaleHarmonicMinor;

  /// No description provided for @scaleMelodicMinor.
  ///
  /// In en, this message translates to:
  /// **'Melodic Minor'**
  String get scaleMelodicMinor;

  /// No description provided for @scaleDorian.
  ///
  /// In en, this message translates to:
  /// **'Dorian'**
  String get scaleDorian;

  /// No description provided for @scalePhrygian.
  ///
  /// In en, this message translates to:
  /// **'Phrygian'**
  String get scalePhrygian;

  /// No description provided for @scaleLydian.
  ///
  /// In en, this message translates to:
  /// **'Lydian'**
  String get scaleLydian;

  /// No description provided for @scaleMixolydian.
  ///
  /// In en, this message translates to:
  /// **'Mixolydian'**
  String get scaleMixolydian;

  /// No description provided for @scaleLocrian.
  ///
  /// In en, this message translates to:
  /// **'Locrian'**
  String get scaleLocrian;

  /// No description provided for @scaleMajorPentatonic.
  ///
  /// In en, this message translates to:
  /// **'Major Pentatonic'**
  String get scaleMajorPentatonic;

  /// No description provided for @scaleMinorPentatonic.
  ///
  /// In en, this message translates to:
  /// **'Minor Pentatonic'**
  String get scaleMinorPentatonic;

  /// No description provided for @scaleBlues.
  ///
  /// In en, this message translates to:
  /// **'Blues'**
  String get scaleBlues;

  /// No description provided for @scaleCategoryMajorMinor.
  ///
  /// In en, this message translates to:
  /// **'Major / Minor'**
  String get scaleCategoryMajorMinor;

  /// No description provided for @scaleCategoryModes.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get scaleCategoryModes;

  /// No description provided for @scaleCategoryPentatonicBlues.
  ///
  /// In en, this message translates to:
  /// **'Pentatonic / Blues'**
  String get scaleCategoryPentatonicBlues;

  /// No description provided for @scaleCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get scaleCategoryOther;

  /// No description provided for @scaleAliasIonian.
  ///
  /// In en, this message translates to:
  /// **'Ionian'**
  String get scaleAliasIonian;

  /// No description provided for @scaleAliasAeolian.
  ///
  /// In en, this message translates to:
  /// **'Aeolian'**
  String get scaleAliasAeolian;

  /// No description provided for @degreeOneSpoken.
  ///
  /// In en, this message translates to:
  /// **'one'**
  String get degreeOneSpoken;

  /// No description provided for @degreeFlatTwoSpoken.
  ///
  /// In en, this message translates to:
  /// **'flat two'**
  String get degreeFlatTwoSpoken;

  /// No description provided for @degreeTwoSpoken.
  ///
  /// In en, this message translates to:
  /// **'two'**
  String get degreeTwoSpoken;

  /// No description provided for @degreeFlatThreeSpoken.
  ///
  /// In en, this message translates to:
  /// **'flat three'**
  String get degreeFlatThreeSpoken;

  /// No description provided for @degreeThreeSpoken.
  ///
  /// In en, this message translates to:
  /// **'three'**
  String get degreeThreeSpoken;

  /// No description provided for @degreeFourSpoken.
  ///
  /// In en, this message translates to:
  /// **'four'**
  String get degreeFourSpoken;

  /// No description provided for @degreeSharpFourSpoken.
  ///
  /// In en, this message translates to:
  /// **'sharp four'**
  String get degreeSharpFourSpoken;

  /// No description provided for @degreeFlatFiveSpoken.
  ///
  /// In en, this message translates to:
  /// **'flat five'**
  String get degreeFlatFiveSpoken;

  /// No description provided for @degreeFiveSpoken.
  ///
  /// In en, this message translates to:
  /// **'five'**
  String get degreeFiveSpoken;

  /// No description provided for @degreeFlatSixSpoken.
  ///
  /// In en, this message translates to:
  /// **'flat six'**
  String get degreeFlatSixSpoken;

  /// No description provided for @degreeSixSpoken.
  ///
  /// In en, this message translates to:
  /// **'six'**
  String get degreeSixSpoken;

  /// No description provided for @degreeFlatSevenSpoken.
  ///
  /// In en, this message translates to:
  /// **'flat seven'**
  String get degreeFlatSevenSpoken;

  /// No description provided for @degreeSevenSpoken.
  ///
  /// In en, this message translates to:
  /// **'seven'**
  String get degreeSevenSpoken;

  /// No description provided for @interactiveFretboard.
  ///
  /// In en, this message translates to:
  /// **'Interactive Fretboard'**
  String get interactiveFretboard;

  /// No description provided for @fretboardIntro.
  ///
  /// In en, this message translates to:
  /// **'Explore chord tones and scale notes across a standard-tuned guitar neck.'**
  String get fretboardIntro;

  /// No description provided for @fretboardModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get fretboardModeLabel;

  /// No description provided for @chordMode.
  ///
  /// In en, this message translates to:
  /// **'Chord'**
  String get chordMode;

  /// No description provided for @scaleMode.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get scaleMode;

  /// No description provided for @displayModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get displayModeLabel;

  /// No description provided for @noteNames.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get noteNames;

  /// No description provided for @degreesIntervals.
  ///
  /// In en, this message translates to:
  /// **'Degrees / intervals'**
  String get degreesIntervals;

  /// No description provided for @visibleFretRange.
  ///
  /// In en, this message translates to:
  /// **'Visible fret range'**
  String get visibleFretRange;

  /// No description provided for @fretRangeValue.
  ///
  /// In en, this message translates to:
  /// **'0–{fret}'**
  String fretRangeValue(int fret);

  /// No description provided for @fretboardOrientationHint.
  ///
  /// In en, this message translates to:
  /// **'High E is shown at the top; low E is shown at the bottom. Scroll horizontally to see later frets.'**
  String get fretboardOrientationHint;

  /// No description provided for @fretboardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name} fretboard, frets zero through {fret}. Root notes {root} highlighted. High E is at the top and low E is at the bottom.'**
  String fretboardSemantics(String name, int fret, String root);

  /// No description provided for @selectedPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get selectedPositionTitle;

  /// No description provided for @selectedNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get selectedNoteLabel;

  /// No description provided for @degreeIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Degree / interval'**
  String get degreeIntervalLabel;

  /// No description provided for @stringLabel.
  ///
  /// In en, this message translates to:
  /// **'String'**
  String get stringLabel;

  /// No description provided for @fretLabel.
  ///
  /// In en, this message translates to:
  /// **'Fret'**
  String get fretLabel;

  /// No description provided for @tapHighlightedNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a highlighted note for pitch, string, fret, and relationship details.'**
  String get tapHighlightedNoteHint;

  /// No description provided for @viewOnFretboard.
  ///
  /// In en, this message translates to:
  /// **'View on Fretboard'**
  String get viewOnFretboard;

  /// No description provided for @circleOfFifths.
  ///
  /// In en, this message translates to:
  /// **'Circle of Fifths'**
  String get circleOfFifths;

  /// No description provided for @circleOfFifthsIntro.
  ///
  /// In en, this message translates to:
  /// **'Explore key signatures, relative keys, neighboring fifths and fourths, and diatonic harmony offline.'**
  String get circleOfFifthsIntro;

  /// No description provided for @keyMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get keyMajor;

  /// No description provided for @keyMinor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get keyMinor;

  /// No description provided for @parallelMajorLabel.
  ///
  /// In en, this message translates to:
  /// **'Parallel major'**
  String get parallelMajorLabel;

  /// No description provided for @parallelMinorLabel.
  ///
  /// In en, this message translates to:
  /// **'Parallel minor'**
  String get parallelMinorLabel;

  /// No description provided for @keySignatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Key signature'**
  String get keySignatureLabel;

  /// No description provided for @alteredNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Altered notes'**
  String get alteredNotesLabel;

  /// No description provided for @enharmonicEquivalentLabel.
  ///
  /// In en, this message translates to:
  /// **'Enharmonic equivalent'**
  String get enharmonicEquivalentLabel;

  /// No description provided for @sharpCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sharp} other{{count} sharps}}'**
  String sharpCount(int count);

  /// No description provided for @flatCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 flat} other{{count} flats}}'**
  String flatCount(int count);

  /// No description provided for @noSharpsOrFlats.
  ///
  /// In en, this message translates to:
  /// **'No sharps or flats'**
  String get noSharpsOrFlats;

  /// No description provided for @fifthNeighborLabel.
  ///
  /// In en, this message translates to:
  /// **'Fifth'**
  String get fifthNeighborLabel;

  /// No description provided for @fourthNeighborLabel.
  ///
  /// In en, this message translates to:
  /// **'Fourth'**
  String get fourthNeighborLabel;

  /// No description provided for @diatonicChordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Diatonic chords'**
  String get diatonicChordsLabel;

  /// No description provided for @triadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Triads'**
  String get triadsLabel;

  /// No description provided for @seventhChordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seventh chords'**
  String get seventhChordsLabel;

  /// No description provided for @viewScale.
  ///
  /// In en, this message translates to:
  /// **'View Scale'**
  String get viewScale;

  /// No description provided for @circleOrientationHint.
  ///
  /// In en, this message translates to:
  /// **'C major is at 12 o\'clock. Move clockwise by fifths and counter-clockwise by fourths.'**
  String get circleOrientationHint;

  /// No description provided for @circleLargeTextOrder.
  ///
  /// In en, this message translates to:
  /// **'Circle order'**
  String get circleLargeTextOrder;

  /// No description provided for @selectedKeyIndicator.
  ///
  /// In en, this message translates to:
  /// **'Selected key'**
  String get selectedKeyIndicator;

  /// No description provided for @relativeKeyIndicator.
  ///
  /// In en, this message translates to:
  /// **'Relative key'**
  String get relativeKeyIndicator;

  /// No description provided for @fifthNeighborIndicator.
  ///
  /// In en, this message translates to:
  /// **'Clockwise fifth neighbor'**
  String get fifthNeighborIndicator;

  /// No description provided for @fourthNeighborIndicator.
  ///
  /// In en, this message translates to:
  /// **'Counter-clockwise fourth neighbor'**
  String get fourthNeighborIndicator;

  /// No description provided for @tapChordHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a chord to open it in Chord Library.'**
  String get tapChordHint;

  /// No description provided for @relationshipUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available in the supported key-signature range'**
  String get relationshipUnavailable;

  /// No description provided for @circleSemantics.
  ///
  /// In en, this message translates to:
  /// **'Circle of Fifths. {selected} selected. Relative key {relative}. Clockwise neighbor {fifth}. Counter-clockwise neighbor {fourth}.'**
  String circleSemantics(
    String selected,
    String relative,
    String fifth,
    String fourth,
  );

  /// No description provided for @circleKeySemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}. {relationship}.'**
  String circleKeySemantics(String name, String relationship);

  /// No description provided for @keySignatureSemantics.
  ///
  /// In en, this message translates to:
  /// **'{description}. Altered notes: {notes}.'**
  String keySignatureSemantics(String description, String notes);

  /// No description provided for @diatonicChordSemantics.
  ///
  /// In en, this message translates to:
  /// **'{roman}, {chord}. Opens Chord Library.'**
  String diatonicChordSemantics(String roman, String chord);

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
  /// **'Real-Time Pitch Diagnostic'**
  String get tunerAudioPrototypeTitle;

  /// No description provided for @tunerAudioPrototypeWarning.
  ///
  /// In en, this message translates to:
  /// **'Development diagnostic only. This connects live pitch analysis for evaluation and is not the final Guitar Tuner.'**
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
  /// **'Audio and transient pitch diagnostics are processed only in memory on this device. Raw microphone data, pitch history, and statistics are not saved or transmitted.'**
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

  /// No description provided for @pitchAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time pitch analysis'**
  String get pitchAnalysisTitle;

  /// No description provided for @pitchAnalysisStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis state'**
  String get pitchAnalysisStatusLabel;

  /// No description provided for @pitchStatusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get pitchStatusStopped;

  /// No description provided for @pitchStatusWaitingForSamples.
  ///
  /// In en, this message translates to:
  /// **'Waiting for enough samples'**
  String get pitchStatusWaitingForSamples;

  /// No description provided for @pitchStatusAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get pitchStatusAnalyzing;

  /// No description provided for @pitchStatusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable pitch'**
  String get pitchStatusStable;

  /// No description provided for @pitchStatusUnstable.
  ///
  /// In en, this message translates to:
  /// **'Unstable signal'**
  String get pitchStatusUnstable;

  /// No description provided for @pitchStatusNoSignal.
  ///
  /// In en, this message translates to:
  /// **'No reliable signal'**
  String get pitchStatusNoSignal;

  /// No description provided for @pitchStatusPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get pitchStatusPermissionDenied;

  /// No description provided for @pitchStatusCaptureError.
  ///
  /// In en, this message translates to:
  /// **'Capture error'**
  String get pitchStatusCaptureError;

  /// No description provided for @pitchStatusAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'Analysis error'**
  String get pitchStatusAnalysisError;

  /// No description provided for @detectorExecutionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Detector execution'**
  String get detectorExecutionModeLabel;

  /// No description provided for @bufferedSamplesLabel.
  ///
  /// In en, this message translates to:
  /// **'Buffered samples'**
  String get bufferedSamplesLabel;

  /// No description provided for @framesAssembledLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis frames assembled'**
  String get framesAssembledLabel;

  /// No description provided for @framesAnalyzedLabel.
  ///
  /// In en, this message translates to:
  /// **'Frames analyzed'**
  String get framesAnalyzedLabel;

  /// No description provided for @framesReplacedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending frames replaced'**
  String get framesReplacedLabel;

  /// No description provided for @framesDroppedLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis frames dropped'**
  String get framesDroppedLabel;

  /// No description provided for @averageDetectorDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Average detector duration'**
  String get averageDetectorDurationLabel;

  /// No description provided for @maximumDetectorDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum detector duration'**
  String get maximumDetectorDurationLabel;

  /// No description provided for @millisecondsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String millisecondsValue(String value);

  /// No description provided for @rawPitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Raw detector result'**
  String get rawPitchTitle;

  /// No description provided for @stabilizedPitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Stabilized result'**
  String get stabilizedPitchTitle;

  /// No description provided for @detectedFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected frequency'**
  String get detectedFrequencyLabel;

  /// No description provided for @pitchConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get pitchConfidenceLabel;

  /// No description provided for @detectedNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected note'**
  String get detectedNoteLabel;

  /// No description provided for @centsDeviationLabel.
  ///
  /// In en, this message translates to:
  /// **'Cents deviation'**
  String get centsDeviationLabel;

  /// No description provided for @frequencyHzValue.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String frequencyHzValue(String value);

  /// No description provided for @centsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} cents'**
  String centsValue(String value);

  /// No description provided for @pitchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get pitchUnavailable;

  /// No description provided for @pitchAnalysisFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Live pitch analysis stopped because the detector failed. You can try again.'**
  String get pitchAnalysisFailedMessage;

  /// No description provided for @tuningPresetLabel.
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get tuningPresetLabel;

  /// No description provided for @automaticMode.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automaticMode;

  /// No description provided for @manualMode.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manualMode;

  /// No description provided for @targetStringLabel.
  ///
  /// In en, this message translates to:
  /// **'Target string'**
  String get targetStringLabel;

  /// No description provided for @flatLabel.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flatLabel;

  /// No description provided for @sharpLabel.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get sharpLabel;

  /// No description provided for @inTuneLabel.
  ///
  /// In en, this message translates to:
  /// **'In tune'**
  String get inTuneLabel;

  /// No description provided for @noSignal.
  ///
  /// In en, this message translates to:
  /// **'No signal'**
  String get noSignal;

  /// No description provided for @startTuning.
  ///
  /// In en, this message translates to:
  /// **'Start tuning'**
  String get startTuning;

  /// No description provided for @stopTuning.
  ///
  /// In en, this message translates to:
  /// **'Stop tuning'**
  String get stopTuning;

  /// No description provided for @retryMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Try microphone again'**
  String get retryMicrophone;

  /// No description provided for @openTunerDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Open tuner diagnostics'**
  String get openTunerDiagnostics;

  /// No description provided for @tuningStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get tuningStandard;

  /// No description provided for @tuningDropD.
  ///
  /// In en, this message translates to:
  /// **'Drop D'**
  String get tuningDropD;

  /// No description provided for @tuningHalfStepDown.
  ///
  /// In en, this message translates to:
  /// **'Half Step Down'**
  String get tuningHalfStepDown;

  /// No description provided for @tuningFullStepDown.
  ///
  /// In en, this message translates to:
  /// **'Full Step Down'**
  String get tuningFullStepDown;

  /// No description provided for @tuningDadgad.
  ///
  /// In en, this message translates to:
  /// **'DADGAD'**
  String get tuningDadgad;

  /// No description provided for @tuningOpenG.
  ///
  /// In en, this message translates to:
  /// **'Open G'**
  String get tuningOpenG;

  /// No description provided for @tuningOpenD.
  ///
  /// In en, this message translates to:
  /// **'Open D'**
  String get tuningOpenD;

  /// No description provided for @noDetectedNote.
  ///
  /// In en, this message translates to:
  /// **'No detected note'**
  String get noDetectedNote;

  /// No description provided for @frequencyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Frequency unavailable'**
  String get frequencyUnavailable;

  /// No description provided for @frequencyUnavailableSemantics.
  ///
  /// In en, this message translates to:
  /// **'Frequency unavailable'**
  String get frequencyUnavailableSemantics;

  /// No description provided for @centsUnavailableSemantics.
  ///
  /// In en, this message translates to:
  /// **'Cents offset unavailable'**
  String get centsUnavailableSemantics;

  /// No description provided for @signedCentsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} cents'**
  String signedCentsValue(String value);

  /// No description provided for @frequencyHertzValue.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String frequencyHertzValue(String value);

  /// No description provided for @detectedNoteSemantics.
  ///
  /// In en, this message translates to:
  /// **'Detected note {note}, octave {octave}'**
  String detectedNoteSemantics(String note, int octave);

  /// No description provided for @targetStringSemantics.
  ///
  /// In en, this message translates to:
  /// **'Target string {position}, {note}'**
  String targetStringSemantics(int position, String note);

  /// No description provided for @tunerModeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Tuner mode: {mode}'**
  String tunerModeSemantics(String mode);

  /// No description provided for @centsDirectionSemantics.
  ///
  /// In en, this message translates to:
  /// **'{value} cents {direction}'**
  String centsDirectionSemantics(int value, String direction);

  /// No description provided for @frequencySemantics.
  ///
  /// In en, this message translates to:
  /// **'Frequency {value} hertz'**
  String frequencySemantics(String value);

  /// No description provided for @tunerStoppedMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap Start when you are ready to tune.'**
  String get tunerStoppedMessage;

  /// No description provided for @tunerRequestingPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Requesting microphone permission.'**
  String get tunerRequestingPermissionMessage;

  /// No description provided for @tunerListeningMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone is starting.'**
  String get tunerListeningMessage;

  /// No description provided for @tunerWaitingForSignalMessage.
  ///
  /// In en, this message translates to:
  /// **'Listening. Play one string.'**
  String get tunerWaitingForSignalMessage;

  /// No description provided for @tunerUnstableSignalMessage.
  ///
  /// In en, this message translates to:
  /// **'Signal is unstable. Let one string ring clearly.'**
  String get tunerUnstableSignalMessage;

  /// No description provided for @tunerStablePitchMessage.
  ///
  /// In en, this message translates to:
  /// **'Pitch detected.'**
  String get tunerStablePitchMessage;

  /// No description provided for @tunerNoSignalMessage.
  ///
  /// In en, this message translates to:
  /// **'No reliable signal. Play one string.'**
  String get tunerNoSignalMessage;

  /// No description provided for @tunerPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed to tune.'**
  String get tunerPermissionDeniedMessage;

  /// No description provided for @tunerMicrophoneUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The microphone is unavailable. Try again.'**
  String get tunerMicrophoneUnavailableMessage;

  /// No description provided for @tunerProcessingErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Pitch processing stopped. Try again.'**
  String get tunerProcessingErrorMessage;

  /// No description provided for @intervalMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get intervalMode;

  /// No description provided for @identifyInterval.
  ///
  /// In en, this message translates to:
  /// **'Identify Interval'**
  String get identifyInterval;

  /// No description provided for @findTargetNote.
  ///
  /// In en, this message translates to:
  /// **'Find Target Note'**
  String get findTargetNote;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @intervalIdentifyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which interval is shown?'**
  String get intervalIdentifyPrompt;

  /// No description provided for @intervalFindTargetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select the target note.'**
  String get intervalFindTargetPrompt;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'{count} answered'**
  String questionsAnswered(int count);

  /// No description provided for @accuracyValue.
  ///
  /// In en, this message translates to:
  /// **'Accuracy {percent}%'**
  String accuracyValue(int percent);

  /// No description provided for @streakValue.
  ///
  /// In en, this message translates to:
  /// **'Streak {count}'**
  String streakValue(int count);

  /// No description provided for @bestStreakValue.
  ///
  /// In en, this message translates to:
  /// **'Best streak {count}'**
  String bestStreakValue(int count);

  /// No description provided for @intervalQuestionSemantics.
  ///
  /// In en, this message translates to:
  /// **'Notes {root} to {target}, {direction}'**
  String intervalQuestionSemantics(
    String root,
    String target,
    String direction,
  );

  /// No description provided for @intervalAnswerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Answer {answer}'**
  String intervalAnswerSemantics(String answer);

  /// No description provided for @intervalCorrectFeedback.
  ///
  /// In en, this message translates to:
  /// **'{root} to {target} is {interval}: {semitones} semitones.'**
  String intervalCorrectFeedback(
    String root,
    String target,
    String interval,
    int semitones,
  );

  /// No description provided for @intervalIncorrectFeedback.
  ///
  /// In en, this message translates to:
  /// **'The correct answer is {answer}. {root} to {target} is {interval}: {semitones} semitones.'**
  String intervalIncorrectFeedback(
    String answer,
    String root,
    String target,
    String interval,
    int semitones,
  );

  /// No description provided for @intervalSessionSemantics.
  ///
  /// In en, this message translates to:
  /// **'Session: {answered} answered, {correct} correct, {accuracy}% accuracy, current streak {streak}, best streak {bestStreak}'**
  String intervalSessionSemantics(
    int answered,
    int correct,
    int accuracy,
    int streak,
    int bestStreak,
  );

  /// No description provided for @intervalPerfectUnison.
  ///
  /// In en, this message translates to:
  /// **'Perfect Unison'**
  String get intervalPerfectUnison;

  /// No description provided for @intervalMinorSecond.
  ///
  /// In en, this message translates to:
  /// **'Minor 2nd'**
  String get intervalMinorSecond;

  /// No description provided for @intervalMajorSecond.
  ///
  /// In en, this message translates to:
  /// **'Major 2nd'**
  String get intervalMajorSecond;

  /// No description provided for @intervalMinorThird.
  ///
  /// In en, this message translates to:
  /// **'Minor 3rd'**
  String get intervalMinorThird;

  /// No description provided for @intervalMajorThird.
  ///
  /// In en, this message translates to:
  /// **'Major 3rd'**
  String get intervalMajorThird;

  /// No description provided for @intervalPerfectFourth.
  ///
  /// In en, this message translates to:
  /// **'Perfect 4th'**
  String get intervalPerfectFourth;

  /// No description provided for @intervalAugmentedFourth.
  ///
  /// In en, this message translates to:
  /// **'Tritone (Augmented 4th)'**
  String get intervalAugmentedFourth;

  /// No description provided for @intervalDiminishedFifth.
  ///
  /// In en, this message translates to:
  /// **'Tritone (Diminished 5th)'**
  String get intervalDiminishedFifth;

  /// No description provided for @intervalPerfectFifth.
  ///
  /// In en, this message translates to:
  /// **'Perfect 5th'**
  String get intervalPerfectFifth;

  /// No description provided for @intervalMinorSixth.
  ///
  /// In en, this message translates to:
  /// **'Minor 6th'**
  String get intervalMinorSixth;

  /// No description provided for @intervalMajorSixth.
  ///
  /// In en, this message translates to:
  /// **'Major 6th'**
  String get intervalMajorSixth;

  /// No description provided for @intervalMinorSeventh.
  ///
  /// In en, this message translates to:
  /// **'Minor 7th'**
  String get intervalMinorSeventh;

  /// No description provided for @intervalMajorSeventh.
  ///
  /// In en, this message translates to:
  /// **'Major 7th'**
  String get intervalMajorSeventh;

  /// No description provided for @intervalPerfectOctave.
  ///
  /// In en, this message translates to:
  /// **'Perfect Octave'**
  String get intervalPerfectOctave;

  /// No description provided for @repertoire.
  ///
  /// In en, this message translates to:
  /// **'Repertoire'**
  String get repertoire;

  /// No description provided for @repertoireEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No songs yet'**
  String get repertoireEmptyTitle;

  /// No description provided for @repertoireEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add lyrics with their chords, then transpose them and let the sheet scroll while both hands stay on the guitar.'**
  String get repertoireEmptyDescription;

  /// No description provided for @addSong.
  ///
  /// In en, this message translates to:
  /// **'Add song'**
  String get addSong;

  /// No description provided for @newSongTitle.
  ///
  /// In en, this message translates to:
  /// **'New song'**
  String get newSongTitle;

  /// No description provided for @editSongTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit song'**
  String get editSongTitle;

  /// No description provided for @editSong.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editSong;

  /// No description provided for @songTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get songTitleLabel;

  /// No description provided for @songArtistLabel.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get songArtistLabel;

  /// No description provided for @songContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Lyrics and chords'**
  String get songContentLabel;

  /// No description provided for @songContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write each chord in square brackets before the syllable it lands on: [Am]lyric. Charts with chords above the lyrics are converted when you save.'**
  String get songContentHint;

  /// No description provided for @songTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get songTitleRequired;

  /// No description provided for @saveSong.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveSong;

  /// No description provided for @deleteSong.
  ///
  /// In en, this message translates to:
  /// **'Delete song'**
  String get deleteSong;

  /// No description provided for @deleteSongPrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete {songTitle}? Songs are stored only on this device and cannot be recovered.'**
  String deleteSongPrompt(String songTitle);

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @chartConverted.
  ///
  /// In en, this message translates to:
  /// **'Chords above the lyrics were converted automatically.'**
  String get chartConverted;

  /// No description provided for @searchSongs.
  ///
  /// In en, this message translates to:
  /// **'Search songs'**
  String get searchSongs;

  /// No description provided for @noMatchingSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs match your search.'**
  String get noMatchingSongs;

  /// No description provided for @emptySongContent.
  ///
  /// In en, this message translates to:
  /// **'This song has no lyrics yet. Use Edit to add them.'**
  String get emptySongContent;

  /// No description provided for @transposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transpose'**
  String get transposeLabel;

  /// No description provided for @transposeDown.
  ///
  /// In en, this message translates to:
  /// **'Transpose down one semitone'**
  String get transposeDown;

  /// No description provided for @transposeUp.
  ///
  /// In en, this message translates to:
  /// **'Transpose up one semitone'**
  String get transposeUp;

  /// No description provided for @transposeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to the written key'**
  String get transposeReset;

  /// No description provided for @transposeSemitones.
  ///
  /// In en, this message translates to:
  /// **'Transposed {value} semitones'**
  String transposeSemitones(int value);

  /// No description provided for @accidentalStyle.
  ///
  /// In en, this message translates to:
  /// **'Accidentals'**
  String get accidentalStyle;

  /// No description provided for @accidentalAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get accidentalAuto;

  /// No description provided for @accidentalSharps.
  ///
  /// In en, this message translates to:
  /// **'Sharps'**
  String get accidentalSharps;

  /// No description provided for @accidentalFlats.
  ///
  /// In en, this message translates to:
  /// **'Flats'**
  String get accidentalFlats;

  /// No description provided for @autoScroll.
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll'**
  String get autoScroll;

  /// No description provided for @startAutoScroll.
  ///
  /// In en, this message translates to:
  /// **'Start auto-scroll'**
  String get startAutoScroll;

  /// No description provided for @stopAutoScroll.
  ///
  /// In en, this message translates to:
  /// **'Stop auto-scroll'**
  String get stopAutoScroll;

  /// No description provided for @scrollSpeed.
  ///
  /// In en, this message translates to:
  /// **'Scroll speed'**
  String get scrollSpeed;

  /// No description provided for @scrollSpeedValue.
  ///
  /// In en, this message translates to:
  /// **'Speed {level} of {max}'**
  String scrollSpeedValue(int level, int max);

  /// No description provided for @songChordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Chords'**
  String get songChordsLabel;

  /// No description provided for @editChords.
  ///
  /// In en, this message translates to:
  /// **'Edit chords'**
  String get editChords;

  /// No description provided for @doneEditingChords.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneEditingChords;

  /// No description provided for @editChordsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a word to put a chord on it, or tap a chord to change or remove it.'**
  String get editChordsHint;

  /// No description provided for @chordPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Chord on \"{word}\"'**
  String chordPickerTitle(String word);

  /// No description provided for @chordPickerRoot.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get chordPickerRoot;

  /// No description provided for @chordPickerQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get chordPickerQuality;

  /// No description provided for @chordsUsedInSong.
  ///
  /// In en, this message translates to:
  /// **'Used in this song'**
  String get chordsUsedInSong;

  /// No description provided for @removeChord.
  ///
  /// In en, this message translates to:
  /// **'Remove chord'**
  String get removeChord;

  /// No description provided for @placeChordOn.
  ///
  /// In en, this message translates to:
  /// **'Put a chord on {word}'**
  String placeChordOn(String word);

  /// No description provided for @changeChordOn.
  ///
  /// In en, this message translates to:
  /// **'Change the {chord} chord on {word}'**
  String changeChordOn(String chord, String word);

  /// No description provided for @privacyRepertoireTitle.
  ///
  /// In en, this message translates to:
  /// **'Your songs stay on this device'**
  String get privacyRepertoireTitle;

  /// No description provided for @privacyRepertoireDescription.
  ///
  /// In en, this message translates to:
  /// **'Songs you add to the Repertoire, including their lyrics, chords, and transposition settings, are stored locally on this device. They are not uploaded, sent to GUNDEV, or shared.'**
  String get privacyRepertoireDescription;
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
