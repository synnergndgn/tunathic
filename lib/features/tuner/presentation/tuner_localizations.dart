import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/l10n/app_localizations.dart';

extension TunerLocalizations on AppLocalizations {
  String tuningPresetName(TuningPresetId preset) => switch (preset) {
    TuningPresetId.standard => tuningStandard,
    TuningPresetId.dropD => tuningDropD,
    TuningPresetId.halfStepDown => tuningHalfStepDown,
    TuningPresetId.fullStepDown => tuningFullStepDown,
    TuningPresetId.dadgad => tuningDadgad,
    TuningPresetId.openG => tuningOpenG,
    TuningPresetId.openD => tuningOpenD,
  };
}
