import 'package:tunathic/core/music_theory/music_theory.dart';
import 'package:tunathic/l10n/app_localizations.dart';

extension CircleOfFifthsLocalizations on AppLocalizations {
  String keyTonalityName(KeyTonality tonality) => switch (tonality) {
    KeyTonality.major => keyMajor,
    KeyTonality.naturalMinor => keyMinor,
  };

  String keyName(MusicalKey key) =>
      '${key.tonic.symbol} ${keyTonalityName(key.tonality)}';

  String relativeLabel(KeyTonality tonality) =>
      tonality == KeyTonality.major ? relativeMinorLabel : relativeMajorLabel;

  String parallelLabel(KeyTonality tonality) =>
      tonality == KeyTonality.major ? parallelMinorLabel : parallelMajorLabel;

  String keySignatureDescription(KeySignature signature) =>
      switch (signature.accidental) {
        KeySignatureAccidental.none => noSharpsOrFlats,
        KeySignatureAccidental.sharp => sharpCount(signature.accidentalCount),
        KeySignatureAccidental.flat => flatCount(signature.accidentalCount),
      };

  String circlePositionMajorLabel(CirclePosition position) {
    final alternate = position.alternateMajor;
    return alternate == null
        ? position.major.tonic.symbol
        : '${position.major.tonic.symbol} / ${alternate.tonic.symbol}';
  }

  String circlePositionMinorLabel(CirclePosition position) {
    final alternate = position.alternateRelativeMinor;
    return alternate == null
        ? position.relativeMinor.tonic.symbol
        : '${position.relativeMinor.tonic.symbol} / ${alternate.tonic.symbol}';
  }
}
