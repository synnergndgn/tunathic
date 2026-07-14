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
  String get comingSoon => 'Coming Soon';

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
  String get bpmTap => 'BPM Tap';

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
}
