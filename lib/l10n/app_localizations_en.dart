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
      'Theme, language, haptic, and Metronome settings are stored locally. Tunathic does not request microphone permission and does not record or upload audio.';

  @override
  String get privacyNoCollectionTitle =>
      'No accounts, ads, analytics, or backend';

  @override
  String get privacyNoCollectionDescription =>
      'The current app requires no account, includes no advertising or analytics, has no Tunathic backend, and sends no app data to GUNDEV servers.';

  @override
  String get privacyFutureChanges =>
      'This privacy information must be updated before microphone, advertising, analytics, account, cloud, or backend features are released.';

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
}
