import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const _sampleRate = 44100;

void main() {
  final outputDirectory = Directory('assets/audio')
    ..createSync(recursive: true);
  _writeClick(
    File('${outputDirectory.path}/metronome_regular.wav'),
    frequency: 1150,
    durationSeconds: 0.04,
    amplitude: 0.58,
    harmonicMix: 0.08,
  );
  _writeClick(
    File('${outputDirectory.path}/metronome_accent.wav'),
    frequency: 1780,
    durationSeconds: 0.055,
    amplitude: 0.78,
    harmonicMix: 0.22,
  );
}

void _writeClick(
  File file, {
  required double frequency,
  required double durationSeconds,
  required double amplitude,
  required double harmonicMix,
}) {
  final sampleCount = (_sampleRate * durationSeconds).round();
  final pcmBytes = sampleCount * 2;
  final data = ByteData(44 + pcmBytes);

  _writeAscii(data, 0, 'RIFF');
  data.setUint32(4, 36 + pcmBytes, Endian.little);
  _writeAscii(data, 8, 'WAVE');
  _writeAscii(data, 12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, _sampleRate, Endian.little);
  data.setUint32(28, _sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  _writeAscii(data, 36, 'data');
  data.setUint32(40, pcmBytes, Endian.little);

  for (var index = 0; index < sampleCount; index++) {
    final time = index / _sampleRate;
    final attack = min(1.0, time / 0.0015);
    final decay = exp(-time * 82);
    final fundamental = sin(2 * pi * frequency * time);
    final harmonic = sin(pi * frequency * time);
    final mixed = (fundamental + harmonicMix * harmonic) / (1 + harmonicMix);
    final sample = (mixed * attack * decay * amplitude * 32767).round();
    data.setInt16(44 + index * 2, sample, Endian.little);
  }

  file.writeAsBytesSync(data.buffer.asUint8List(), flush: true);
}

void _writeAscii(ByteData data, int offset, String value) {
  for (var index = 0; index < value.length; index++) {
    data.setUint8(offset + index, value.codeUnitAt(index));
  }
}
