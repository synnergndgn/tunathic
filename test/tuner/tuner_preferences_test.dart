import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/tuner/application/tuner_preferences.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';

import '../support/fakes.dart';

void main() {
  test('loads and saves tuner-only preferences', () async {
    final store = MemoryPreferencesStore({
      TunerPreferences.presetKey: 'dadgad',
      TunerPreferences.modeKey: 'manual',
      TunerPreferences.manualStringKey: '3',
    });
    final preferences = TunerPreferences(store);

    final loaded = await preferences.load();
    expect(loaded.presetId, TuningPresetId.dadgad);
    expect(loaded.mode, TunerMode.manual);
    expect(loaded.manualStringPosition, 3);

    await preferences.save(
      const TunerPreferencesState(
        presetId: TuningPresetId.openD,
        mode: TunerMode.automatic,
        manualStringPosition: 2,
      ),
    );
    expect(store.values[TunerPreferences.presetKey], 'open-d');
    expect(store.values[TunerPreferences.modeKey], 'automatic');
    expect(store.values[TunerPreferences.manualStringKey], '2');
  });

  test('invalid persisted values safely use defaults', () async {
    final preferences = TunerPreferences(
      MemoryPreferencesStore({
        TunerPreferences.presetKey: 'unknown',
        TunerPreferences.modeKey: 'broken',
        TunerPreferences.manualStringKey: '99',
      }),
    );

    final loaded = await preferences.load();

    expect(loaded.presetId, TuningPresetId.standard);
    expect(loaded.mode, TunerMode.automatic);
    expect(loaded.manualStringPosition, 6);
  });
}
