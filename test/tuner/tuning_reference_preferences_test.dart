import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_controller.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_preferences.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

import '../support/fakes.dart';

void main() {
  test('saves and reloads the chosen reference', () async {
    final store = MemoryPreferencesStore();
    final preferences = TuningReferencePreferences(store);

    await preferences.save(TuningReference.resolve(432));

    expect(store.values[TuningReferencePreferences.referenceKey], isNotNull);
    expect((await preferences.load()).a4FrequencyHz, 432);
  });

  test('a corrupt stored reference reads back as concert pitch', () async {
    for (final stored in ['', 'nonsense', '0', '-440', '429', '451', 'NaN']) {
      final preferences = TuningReferencePreferences(
        MemoryPreferencesStore({
          TuningReferencePreferences.referenceKey: stored,
        }),
      );

      expect(
        await preferences.load(),
        TuningReference.standard,
        reason: '"$stored" should fall back to 440 Hz',
      );
    }
  });

  test('a missing preference reads back as concert pitch', () async {
    final preferences = TuningReferencePreferences(MemoryPreferencesStore());

    expect(await preferences.load(), TuningReference.standard);
  });

  test('a failing store is reported and does not break startup', () async {
    final logger = RecordingLogger();

    final reference = await loadInitialTuningReference(
      _FailingPreferencesStore(),
      logger,
    );

    expect(reference, TuningReference.standard);
    expect(logger.errorMessages, isNotEmpty);
  });

  test('the controller persists a change and clamps a bad one', () async {
    final store = MemoryPreferencesStore();
    final container = ProviderContainer(
      overrides: [
        preferencesStoreProvider.overrideWithValue(store),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(tuningReferenceProvider.notifier);
    expect(container.read(tuningReferenceProvider), TuningReference.standard);

    await controller.setReference(TuningReference.resolve(441));
    expect(container.read(tuningReferenceProvider).a4FrequencyHz, 441);
    expect(store.values[TuningReferencePreferences.referenceKey], '441.0');

    // Nothing outside the range can reach the state, whatever a caller asks
    // for.
    await controller.setReference(TuningReference.resolve(9999));
    expect(container.read(tuningReferenceProvider), TuningReference.standard);
  });

  test('the controller starts from the value loaded at launch', () {
    final container = ProviderContainer(
      overrides: [
        preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
        initialTuningReferenceProvider.overrideWithValue(
          TuningReference.resolve(438),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(tuningReferenceProvider).a4FrequencyHz, 438);
  });

  test('stepping walks the range one hertz at a time', () async {
    final container = ProviderContainer(
      overrides: [
        preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(tuningReferenceProvider.notifier);

    await controller.stepReference(-1);
    expect(container.read(tuningReferenceProvider).a4FrequencyHz, 439);

    await controller.stepReference(2);
    expect(container.read(tuningReferenceProvider).a4FrequencyHz, 441);
  });
}

final class _FailingPreferencesStore implements PreferencesStore {
  @override
  Future<String?> getString(String key) async =>
      throw StateError('preferences unavailable');

  @override
  Future<void> remove(String key) async {}

  @override
  Future<void> setString(String key, String value) async {}
}
