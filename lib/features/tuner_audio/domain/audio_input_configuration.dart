enum AudioSampleEncoding { signedPcm16LittleEndian }

final class AudioInputConfiguration {
  const AudioInputConfiguration({
    this.sampleRate = 48000,
    this.channelCount = 1,
    this.encoding = AudioSampleEncoding.signedPcm16LittleEndian,
  });

  final int sampleRate;
  final int channelCount;
  final AudioSampleEncoding encoding;

  AudioStreamFormat get requestedFormat => AudioStreamFormat(
    sampleRate: sampleRate,
    channelCount: channelCount,
    encoding: encoding,
    isReportedByBackend: false,
  );
}

final class AudioStreamFormat {
  const AudioStreamFormat({
    required this.sampleRate,
    required this.channelCount,
    required this.encoding,
    required this.isReportedByBackend,
  });

  final int sampleRate;
  final int channelCount;
  final AudioSampleEncoding encoding;
  final bool isReportedByBackend;
}
