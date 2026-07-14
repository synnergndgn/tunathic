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
}
