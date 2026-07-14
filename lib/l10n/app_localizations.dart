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
