// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Tunathic';

  @override
  String get tagline => 'Akort Et. Çalış. Üret.';

  @override
  String get dashboardTitle => 'Gitar araç seti';

  @override
  String get dashboardIntro =>
      'Odaklı bir çalışma için ihtiyacınız olan her şey bir arada.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsTooltip => 'Ayarları aç';

  @override
  String get appearanceTitle => 'Görünüm';

  @override
  String get themeModeLabel => 'Tema modu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get comingSoon => 'Yakında';

  @override
  String comingSoonDescription(String toolName) {
    return '$toolName gelecek bir aşama için planlandı.';
  }

  @override
  String get backToDashboard => 'Ana ekrana dön';

  @override
  String get pageNotFoundTitle => 'Sayfa bulunamadı';

  @override
  String get pageNotFoundDescription => 'Bu sayfa Tunathic\'te mevcut değil.';

  @override
  String get unexpectedErrorTitle => 'Bir sorun oluştu';

  @override
  String get unexpectedErrorDescription =>
      'Tunathic bu ekranı gösteremedi. Lütfen ana ekrana dönüp tekrar deneyin.';

  @override
  String get guitarTuner => 'Gitar Akort Cihazı';

  @override
  String get metronome => 'Metronom';

  @override
  String get bpmTap => 'BPM Dokunuşu';

  @override
  String get chordLibrary => 'Akor Kütüphanesi';

  @override
  String get scaleLibrary => 'Gam Kütüphanesi';

  @override
  String get circleOfFifths => 'Beşliler Çemberi';

  @override
  String get intervalTrainer => 'Aralık Eğitimi';

  @override
  String get earTraining => 'Kulak Eğitimi';

  @override
  String get chordFinder => 'Akor Bulucu';

  @override
  String get capoCalculator => 'Kapo Hesaplayıcı';
}
