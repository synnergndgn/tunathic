import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

final class TunerPreferencesState {
  const TunerPreferencesState({
    this.presetId = TuningPresetId.standard,
    this.mode = TunerMode.automatic,
    this.manualStringPosition = 6,
  });

  final TuningPresetId presetId;
  final TunerMode mode;
  final int manualStringPosition;

  TunerPreferencesState copyWith({
    TuningPresetId? presetId,
    TunerMode? mode,
    int? manualStringPosition,
  }) => TunerPreferencesState(
    presetId: presetId ?? this.presetId,
    mode: mode ?? this.mode,
    manualStringPosition: manualStringPosition ?? this.manualStringPosition,
  );
}

final class TunerPreferences {
  TunerPreferences(this._store);

  static const presetKey = 'tuner.preset';
  static const modeKey = 'tuner.mode';
  static const manualStringKey = 'tuner.manualString';

  final PreferencesStore _store;

  Future<TunerPreferencesState> load() async {
    final values = await Future.wait([
      _store.getString(presetKey),
      _store.getString(modeKey),
      _store.getString(manualStringKey),
    ]);
    final parsedString = int.tryParse(values[2] ?? '');
    return TunerPreferencesState(
      presetId: TuningPresetId.fromId(values[0]),
      mode: TunerMode.fromId(values[1]),
      manualStringPosition:
          parsedString != null && parsedString >= 1 && parsedString <= 6
          ? parsedString
          : 6,
    );
  }

  Future<void> save(TunerPreferencesState state) => Future.wait([
    _store.setString(presetKey, state.presetId.id),
    _store.setString(modeKey, state.mode.id),
    _store.setString(manualStringKey, state.manualStringPosition.toString()),
  ]);
}
