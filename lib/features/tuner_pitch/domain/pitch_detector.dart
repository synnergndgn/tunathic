import 'dart:typed_data';

import 'package:tunathic/features/tuner_pitch/domain/pitch_estimate.dart';

abstract interface class PitchDetector {
  PitchEstimate detect(Float32List samples, {required int sampleRate});
}
