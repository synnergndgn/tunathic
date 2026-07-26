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
  String get privacyMicrophoneTitle => 'Mikrofon perde analizi yerel kalır';

  @override
  String get privacyMicrophoneDescription =>
      'Mikrofon erişimi yalnızca Gerçek Zamanlı Perde Tanılaması etkinken kullanılır. Ham ses ve perde tahminleri geçici ve yerel kalır, kaydedilmez veya yüklenmez; ekrandan ayrıldığınızda ya da uygulama arka plana geçtiğinde durur.';

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
  String get chordLibraryIntro =>
      'Akorları müzik teorisinden oluşturun ve doğrulanmış gitar şekillerini çevrimdışı inceleyin.';

  @override
  String get chordSearchLabel => 'Akor arama';

  @override
  String get chordSearchHint => 'C, Cm, Cmaj7, F#m veya Bb7 deneyin';

  @override
  String get searchAction => 'Ara';

  @override
  String get unsupportedChordSearch =>
      'Cmaj7 veya F#m gibi desteklenen bir akor sembolü girin.';

  @override
  String get rootNoteLabel => 'Kök nota';

  @override
  String get chordQualityLabel => 'Akor niteliği';

  @override
  String get chordSymbolLabel => 'Akor sembolü';

  @override
  String get chordTonesLabel => 'Akor sesleri';

  @override
  String get guitarShapesLabel => 'Gitar şekilleri';

  @override
  String get primaryShapeLabel => 'Seçili şekil';

  @override
  String get alternateShapesLabel => 'Kullanılabilir şekiller';

  @override
  String get fingeringLabel => 'Parmak yerleşimi';

  @override
  String get noChordShapeTitle => 'Doğrulanmış gitar şekli yok';

  @override
  String get noChordShapeDescription =>
      'Akor kuramsal olarak geçerli, ancak bu çevrimdışı kütüphanede henüz doğrulanmış bir şekli bulunmuyor.';

  @override
  String startingFretValue(int fret) {
    return 'Başlangıç perdesi $fret';
  }

  @override
  String get openPositionShape => 'Açık pozisyon';

  @override
  String get movableEShape => 'Hareketli Mi şekli';

  @override
  String get movableAShape => 'Hareketli La şekli';

  @override
  String get compactShape => 'Kompakt çevrim';

  @override
  String get beginnerDifficulty => 'Başlangıç';

  @override
  String get intermediateDifficulty => 'Orta';

  @override
  String get triadCategory => 'Üç sesli akorlar';

  @override
  String get seventhChordCategory => 'Yedili akorlar';

  @override
  String get extendedChordCategory => 'Genişletilmiş akorlar';

  @override
  String get qualityMajor => 'Majör';

  @override
  String get qualityMinor => 'Minör';

  @override
  String get qualityDiminished => 'Eksiltilmiş';

  @override
  String get qualityAugmented => 'Artırılmış';

  @override
  String get qualitySus2 => 'Asılı 2';

  @override
  String get qualitySus4 => 'Asılı 4';

  @override
  String get qualityMajor7 => 'Majör 7';

  @override
  String get qualityDominant7 => 'Dominant 7';

  @override
  String get qualityMinor7 => 'Minör 7';

  @override
  String get qualityMinorMajor7 => 'Minör majör 7';

  @override
  String get qualityDiminished7 => 'Eksiltilmiş 7';

  @override
  String get qualityHalfDiminished7 => 'Yarı eksiltilmiş (m7b5)';

  @override
  String get quality6 => 'Majör 6';

  @override
  String get qualityMinor6 => 'Minör 6';

  @override
  String get qualityAdd9 => 'Ek 9';

  @override
  String get qualityMinorAdd9 => 'Minör ek 9';

  @override
  String get quality9 => 'Dominant 9';

  @override
  String get qualityMajor9 => 'Majör 9';

  @override
  String get qualityMinor9 => 'Minör 9';

  @override
  String get quality11 => 'Dominant 11';

  @override
  String get qualityMinor11 => 'Minör 11';

  @override
  String get quality13 => 'Dominant 13';

  @override
  String get lowEString => 'Kalın Mi teli';

  @override
  String get aString => 'La teli';

  @override
  String get dString => 'Re teli';

  @override
  String get gString => 'Sol teli';

  @override
  String get bString => 'Si teli';

  @override
  String get highEString => 'İnce Mi teli';

  @override
  String get mutedMarker => 'Susturulmuş';

  @override
  String get openMarker => 'Açık';

  @override
  String fretOnlyValue(int fret) {
    return '$fret. perde';
  }

  @override
  String fretAndFingerValue(int fret, int finger) {
    return '$fret. perde, $finger. parmak';
  }

  @override
  String guitarStringMutedDescription(String stringName) {
    return '$stringName susturulmuş.';
  }

  @override
  String guitarStringOpenDescription(String stringName) {
    return '$stringName açık.';
  }

  @override
  String guitarStringFrettedDescription(String stringName, int fret) {
    return '$stringName $fret. perde.';
  }

  @override
  String guitarStringFingerDescription(
    String stringName,
    int fret,
    int finger,
  ) {
    return '$stringName $fret. perde, $finger. parmak.';
  }

  @override
  String barreDescription(
    int fret,
    String fromString,
    String toString,
    int finger,
  ) {
    return '$fret. perdede $fromString ile $toString arasında $finger. parmakla bare.';
  }

  @override
  String chordDiagramSemantics(String chordSymbol, String details) {
    return '$chordSymbol gitar akor diyagramı. $details';
  }

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
  String get tunerAudioPrototypeTitle => 'Gerçek Zamanlı Perde Tanılaması';

  @override
  String get tunerAudioPrototypeWarning =>
      'Yalnızca geliştirme tanılaması. Bu ekran değerlendirme için canlı perde analizini bağlar; nihai Gitar Akort Cihazı değildir.';

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
      'Ses ve geçici perde tanılamaları yalnızca bu cihazın belleğinde işlenir. Ham mikrofon verileri, perde geçmişi ve istatistikler kaydedilmez veya iletilmez.';

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

  @override
  String get pitchAnalysisTitle => 'Gerçek zamanlı perde analizi';

  @override
  String get pitchAnalysisStatusLabel => 'Analiz durumu';

  @override
  String get pitchStatusStopped => 'Durduruldu';

  @override
  String get pitchStatusWaitingForSamples => 'Yeterli örnek bekleniyor';

  @override
  String get pitchStatusAnalyzing => 'Analiz ediliyor';

  @override
  String get pitchStatusStable => 'Kararlı perde';

  @override
  String get pitchStatusUnstable => 'Kararsız sinyal';

  @override
  String get pitchStatusNoSignal => 'Güvenilir sinyal yok';

  @override
  String get pitchStatusPermissionDenied => 'Mikrofon izni reddedildi';

  @override
  String get pitchStatusCaptureError => 'Yakalama hatası';

  @override
  String get pitchStatusAnalysisError => 'Analiz hatası';

  @override
  String get detectorExecutionModeLabel => 'Dedektör yürütmesi';

  @override
  String get bufferedSamplesLabel => 'Tampondaki örnekler';

  @override
  String get framesAssembledLabel => 'Birleştirilen analiz çerçeveleri';

  @override
  String get framesAnalyzedLabel => 'Analiz edilen çerçeveler';

  @override
  String get framesReplacedLabel => 'Değiştirilen bekleyen çerçeveler';

  @override
  String get framesDroppedLabel => 'Atılan analiz çerçeveleri';

  @override
  String get averageDetectorDurationLabel => 'Ortalama dedektör süresi';

  @override
  String get maximumDetectorDurationLabel => 'En yüksek dedektör süresi';

  @override
  String millisecondsValue(String value) {
    return '$value ms';
  }

  @override
  String get rawPitchTitle => 'Ham dedektör sonucu';

  @override
  String get stabilizedPitchTitle => 'Kararlı sonuç';

  @override
  String get detectedFrequencyLabel => 'Algılanan frekans';

  @override
  String get pitchConfidenceLabel => 'Güven';

  @override
  String get detectedNoteLabel => 'Algılanan nota';

  @override
  String get centsDeviationLabel => 'Cent sapması';

  @override
  String frequencyHzValue(String value) {
    return '$value Hz';
  }

  @override
  String centsValue(String value) {
    return '$value cent';
  }

  @override
  String get pitchUnavailable => '—';

  @override
  String get pitchAnalysisFailedMessage =>
      'Dedektör başarısız olduğu için canlı perde analizi durdu. Yeniden deneyebilirsiniz.';

  @override
  String get tuningPresetLabel => 'Akort düzeni';

  @override
  String get automaticMode => 'Otomatik';

  @override
  String get manualMode => 'Manuel';

  @override
  String get targetStringLabel => 'Hedef tel';

  @override
  String get flatLabel => 'Pes';

  @override
  String get sharpLabel => 'Tiz';

  @override
  String get inTuneLabel => 'Akortta';

  @override
  String get noSignal => 'Sinyal yok';

  @override
  String get startTuning => 'Akordu başlat';

  @override
  String get stopTuning => 'Akordu durdur';

  @override
  String get retryMicrophone => 'Mikrofonu yeniden dene';

  @override
  String get openTunerDiagnostics => 'Akort tanılamasını aç';

  @override
  String get tuningStandard => 'Standart';

  @override
  String get tuningDropD => 'Drop D';

  @override
  String get tuningHalfStepDown => 'Yarım Ses Pes';

  @override
  String get tuningFullStepDown => 'Tam Ses Pes';

  @override
  String get tuningDadgad => 'DADGAD';

  @override
  String get tuningOpenG => 'Açık Sol';

  @override
  String get tuningOpenD => 'Açık Re';

  @override
  String get noDetectedNote => 'Algılanan nota yok';

  @override
  String get frequencyUnavailable => 'Frekans kullanılamıyor';

  @override
  String get frequencyUnavailableSemantics => 'Frekans kullanılamıyor';

  @override
  String get centsUnavailableSemantics => 'Cent sapması kullanılamıyor';

  @override
  String signedCentsValue(String value) {
    return '$value cent';
  }

  @override
  String frequencyHertzValue(String value) {
    return '$value Hz';
  }

  @override
  String detectedNoteSemantics(String note, int octave) {
    return 'Algılanan nota $note, oktav $octave';
  }

  @override
  String targetStringSemantics(int position, String note) {
    return 'Hedef tel $position, $note';
  }

  @override
  String tunerModeSemantics(String mode) {
    return 'Akort modu: $mode';
  }

  @override
  String centsDirectionSemantics(int value, String direction) {
    return '$value cent $direction';
  }

  @override
  String frequencySemantics(String value) {
    return 'Frekans $value hertz';
  }

  @override
  String get tunerStoppedMessage =>
      'Akort etmeye hazır olduğunuzda Başlat\'a dokunun.';

  @override
  String get tunerRequestingPermissionMessage => 'Mikrofon izni isteniyor.';

  @override
  String get tunerListeningMessage => 'Mikrofon başlatılıyor.';

  @override
  String get tunerWaitingForSignalMessage => 'Dinleniyor. Tek bir tele vurun.';

  @override
  String get tunerUnstableSignalMessage =>
      'Sinyal kararsız. Tek bir telin temizce çalmasına izin verin.';

  @override
  String get tunerStablePitchMessage => 'Perde algılandı.';

  @override
  String get tunerNoSignalMessage =>
      'Güvenilir sinyal yok. Tek bir tele vurun.';

  @override
  String get tunerPermissionDeniedMessage =>
      'Akort için mikrofon izni gereklidir.';

  @override
  String get tunerMicrophoneUnavailableMessage =>
      'Mikrofon kullanılamıyor. Yeniden deneyin.';

  @override
  String get tunerProcessingErrorMessage =>
      'Perde işleme durdu. Yeniden deneyin.';
}
