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
  String get practiceSection => 'Pratik';

  @override
  String get theoryReferenceSection => 'Teori ve Başvuru';

  @override
  String get trainingSection => 'Eğitim';

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
  String get interactionTitle => 'Etkileşim';

  @override
  String get hapticFeedbackTitle => 'Dokunsal geri bildirim';

  @override
  String get hapticFeedbackDescription =>
      'Anlamlı dokunuşlar ve seçimler için hafif titreşim kullan.';

  @override
  String get applicationTitle => 'Uygulama';

  @override
  String get aboutTunathic => 'Tunathic Hakkında';

  @override
  String get privacyTitle => 'Gizlilik';

  @override
  String get openSourceLicenses => 'Açık kaynak lisansları';

  @override
  String get versionLabel => 'Sürüm';

  @override
  String get productFullName => 'Tunathic – Gitar Araç Seti';

  @override
  String get aboutProductDescription =>
      'Gitar pratiği, tempo ve müzik teorisi için odaklı, çevrimdışı öncelikli bir araç seti.';

  @override
  String get publisherLabel => 'Yayıncı';

  @override
  String get copyrightNotice => '© 2026 GUNDEV. Tüm hakları saklıdır.';

  @override
  String get availableToolsTitle => 'Kullanılabilir araçlar';

  @override
  String get plannedToolsTitle => 'Planlanan araçlar';

  @override
  String get privacySummary =>
      'Tunathic, mevcut pratik deneyimini özel ve cihazında yerel tutacak şekilde tasarlanmıştır.';

  @override
  String get privacyBpmTitle => 'Pratik oturumları geçicidir';

  @override
  String get privacyBpmDescription =>
      'BPM Dokunma oturumları bellekte kalır ve oturum sona erdiğinde temizlenir. Karşıya yüklenmez.';

  @override
  String get privacyLocalTitle => 'Tercihler bu cihazda kalır';

  @override
  String get privacyLocalDescription =>
      'Tema, dil, dokunsal geri bildirim ve Metronom ayarları bu cihazda yerel olarak saklanır.';

  @override
  String get privacyMicrophoneTitle => 'Mikrofon prototipi yerel kalır';

  @override
  String get privacyMicrophoneDescription =>
      'Mikrofon erişimi yalnızca Akort Ses Prototipi etkin olarak yakalama yaparken kullanılır. Ham ses cihazda işlenir, kaydedilmez veya yüklenmez; ekrandan ayrıldığınızda ya da uygulama arka plana geçtiğinde yakalama durur.';

  @override
  String get privacyNoCollectionTitle =>
      'Hesap, reklam, analiz veya sunucu yok';

  @override
  String get privacyNoCollectionDescription =>
      'Mevcut uygulama hesap gerektirmez; reklam veya analiz içermez, Tunathic sunucusu yoktur ve GUNDEV sunucularına uygulama verisi göndermez.';

  @override
  String get privacyFutureChanges =>
      'Üretim akort cihazı, kayıt, reklam, analiz, hesap, bulut veya sunucu özellikleri yayınlanmadan önce bu gizlilik bilgileri gözden geçirilmelidir.';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get openTool => 'Aracı aç';

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
  String get startMetronome => 'Başlat';

  @override
  String get stopMetronome => 'Durdur';

  @override
  String get tempo => 'Tempo';

  @override
  String get beatsPerMinute => 'Dakikadaki vuruş';

  @override
  String tempoValue(int bpm) {
    return 'Dakikada $bpm vuruş';
  }

  @override
  String get decreaseTempo => 'Tempoyu azalt';

  @override
  String get increaseTempo => 'Tempoyu artır';

  @override
  String get timeSignature => 'Ölçü birimi';

  @override
  String get currentBeat => 'Geçerli vuruş';

  @override
  String currentBeatValue(int beat, int total) {
    return 'Geçerli vuruş: $beat/$total';
  }

  @override
  String get metronomeStopped => 'Durduruldu';

  @override
  String get preparingAudio => 'Ses hazırlanıyor';

  @override
  String get sound => 'Ses';

  @override
  String get accentFirstBeat => 'İlk vuruşu vurgula';

  @override
  String volumePercent(int percent) {
    return '%$percent ses düzeyi';
  }

  @override
  String get openBpmTapForMetronome => 'BPM Dokunuşu\'nu aç';

  @override
  String get applyBpmTapResult => 'BPM Dokunuşu sonucunu uygula';

  @override
  String bpmTapApplied(int bpm) {
    return '$bpm BPM metronoma uygulandı.';
  }

  @override
  String get metronomeGuidance =>
      'Tempo ve ölçü birimini seçip başlat. Vurgu açıksa ilk vuruş farklı çalar.';

  @override
  String get audioUnavailableTitle => 'Metronom sesi kullanılamıyor';

  @override
  String get audioUnavailableDescription =>
      'Ses hazırlanamadığı veya çalınamadığı için Tunathic metronomu durdurdu.';

  @override
  String get retryAudio => 'Sesi yeniden dene';

  @override
  String get currentAccentedBeat => 'geçerli vurgulu vuruş';

  @override
  String get currentBeatDetail => 'geçerli vuruş';

  @override
  String get accentedBeat => 'vurgulu ilk vuruş';

  @override
  String get inactiveBeat => 'etkin olmayan vuruş';

  @override
  String beatIndicatorSemantics(int beat, String details) {
    return '$beat. vuruş, $details';
  }

  @override
  String get bpmTap => 'BPM Dokunuşu';

  @override
  String get bpmLabel => 'BPM';

  @override
  String get tapToBegin => 'Başlamak için dokun';

  @override
  String get keepTapping => 'Dokunmaya devam et';

  @override
  String get bpmEstimateReady =>
      'Tempo algılandı. Sonucu iyileştirmek için dokunmaya devam et.';

  @override
  String get reset => 'Sıfırla';

  @override
  String get sessionReset =>
      'Oturum hareketsizlik nedeniyle sıfırlandı. Yeniden başlamak için dokun.';

  @override
  String get invalidTapIgnored =>
      'Bu dokunuş geçerli tempo aralığının dışındaydı ve yok sayıldı.';

  @override
  String get bpmTapGuidance =>
      'Ritimle birlikte düzenli dokun. Son dokunuşlar sonucu güncel tutar.';

  @override
  String get noRecentInterval => 'Aralık bekleniyor';

  @override
  String tapCount(int count) {
    return '$count dokunuş';
  }

  @override
  String recentInterval(int milliseconds) {
    return 'Son dokunuştan beri $milliseconds ms';
  }

  @override
  String tapSurfaceSemantics(String status, int count, String bpm) {
    return '$status. $count geçerli dokunuş. $bpm BPM.';
  }

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

  @override
  String get tunerAudioPrototypeTitle => 'Akort Ses Prototipi';

  @override
  String get tunerAudioPrototypeWarning =>
      'Yalnızca teknik prototip. Bu ekran mikrofon girişini doğrular; çalışan bir gitar akort cihazı değildir.';

  @override
  String get microphonePermissionLabel => 'Mikrofon izni';

  @override
  String get microphonePermissionNotRequested => 'İstenmedi';

  @override
  String get microphonePermissionGranted => 'Verildi';

  @override
  String get microphonePermissionDenied => 'Reddedildi';

  @override
  String get startCapture => 'Yakalamayı başlat';

  @override
  String get stopCapture => 'Yakalamayı durdur';

  @override
  String get captureStatusLabel => 'Yakalama durumu';

  @override
  String get captureStatusIdle => 'Durduruldu';

  @override
  String get captureStatusRequestingPermission => 'İzin isteniyor';

  @override
  String get captureStatusStarting => 'Mikrofon başlatılıyor';

  @override
  String get captureStatusCapturing => 'Yakalanıyor';

  @override
  String get captureStatusStopping => 'Durduruluyor';

  @override
  String get captureStatusError => 'Yakalama hatası';

  @override
  String get requestedSampleRateLabel => 'İstenen örnekleme hızı';

  @override
  String get reportedSampleRateLabel => 'Bildirilen örnekleme hızı';

  @override
  String get reportedSampleRateUnavailable =>
      'Ses altyapısı tarafından bildirilmedi';

  @override
  String sampleRateValue(int sampleRate) {
    return '$sampleRate Hz';
  }

  @override
  String get channelCountLabel => 'Kanallar';

  @override
  String channelCountValue(int channelCount) {
    return '$channelCount (mono)';
  }

  @override
  String get pcmEncodingLabel => 'Kodlama';

  @override
  String get pcm16LittleEndian => 'İşaretli PCM16, little-endian';

  @override
  String get signalStatisticsTitle => 'Sinyal istatistikleri';

  @override
  String get inputLevelLabel => 'Giriş seviyesi';

  @override
  String get peakAmplitudeLabel => 'Tepe genliği';

  @override
  String get rmsAmplitudeLabel => 'RMS genliği';

  @override
  String get dbfsLabel => 'dBFS';

  @override
  String get silenceDbfs => '−∞ dBFS';

  @override
  String dbfsValue(String value) {
    return '$value dBFS';
  }

  @override
  String get framesReceivedLabel => 'Alınan çerçeveler';

  @override
  String get samplesReceivedLabel => 'Alınan örnekler';

  @override
  String get streamDurationLabel => 'Akış süresi';

  @override
  String durationSecondsValue(String value) {
    return '$value sn';
  }

  @override
  String get observedFrameSizesLabel => 'Gözlenen çerçeve boyutları';

  @override
  String frameSizesValue(int minimum, int maximum, String average) {
    return '$minimum–$maximum örnek; ortalama $average';
  }

  @override
  String get frameArrivalRateLabel => 'Yaklaşık çerçeve geliş hızı';

  @override
  String framesPerSecondValue(String value) {
    return '$value çerçeve/sn';
  }

  @override
  String get malformedFramesLabel => 'Hatalı çerçeveler';

  @override
  String get prototypePrivacyTitle => 'Gizlilik odaklı';

  @override
  String get prototypePrivacyDescription =>
      'Ses yalnızca bu cihazın belleğinde işlenir. Ham mikrofon verileri ve sinyal istatistikleri kaydedilmez veya iletilmez.';

  @override
  String get prototypeLifecycleTitle => 'Yalnızca ön planda yakalama';

  @override
  String get prototypeLifecycleDescription =>
      'Bu ekrandan ayrıldığınızda, uygulamayı arka plana aldığınızda veya gizlediğinizde ya da ekranı kilitlediğinizde yakalama durur. Otomatik olarak yeniden başlamaz.';

  @override
  String get permissionDeniedMessage =>
      'Mikrofon erişimi reddedildi. Yalnızca yeniden denemek istiyorsanız tekrar başlatın; Tunathic sistem ayarlarını otomatik açmaz.';

  @override
  String get unsupportedAudioMessage =>
      'Bu cihaz prototip PCM ses yapılandırmasını kabul etmedi.';

  @override
  String get audioStartFailedMessage =>
      'Tunathic mikrofon yakalamayı başlatamadı. Yeniden deneyebilirsiniz.';

  @override
  String get audioStreamFailedMessage =>
      'Ses akışı başarısız olduğu için mikrofon yakalama durdu. Yeniden deneyebilirsiniz.';

  @override
  String get audioStopFailedMessage =>
      'Tunathic mikrofonu temiz biçimde serbest bırakamadı. Yeniden deneyebilirsiniz.';
}
