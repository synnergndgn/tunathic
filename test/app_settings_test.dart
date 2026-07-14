import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

import 'support/fakes.dart';

void main() {
  group('AppSettingsPreferences', () {
    test('loads saved theme and locale values', () async {
      final store = MemoryPreferencesStore({
        'settings.themeMode': 'dark',
        'settings.locale': 'tr',
        'settings.hapticsEnabled': 'false',
      });

      final settings = await AppSettingsPreferences(store).load();

      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.locale, AppLocale.turkish);
      expect(settings.hapticsEnabled, isFalse);
    });

    test('falls back safely when values are unknown', () async {
      final store = MemoryPreferencesStore({
        'settings.themeMode': 'sepia',
        'settings.locale': 'de',
      });

      final settings = await AppSettingsPreferences(store).load();

      expect(settings, const AppSettings());
      expect(settings.hapticsEnabled, isTrue);
    });
  });

  test('settings controller persists theme and locale changes', () async {
    final store = MemoryPreferencesStore();
    final container = ProviderContainer(
      overrides: [
        preferencesStoreProvider.overrideWithValue(store),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(appSettingsProvider.notifier);
    await controller.setThemeMode(ThemeMode.dark);
    await controller.setLocale(AppLocale.turkish);
    await controller.setHapticsEnabled(false);

    expect(container.read(appSettingsProvider).themeMode, ThemeMode.dark);
    expect(container.read(appSettingsProvider).locale, AppLocale.turkish);
    expect(container.read(appSettingsProvider).hapticsEnabled, isFalse);
    expect(store.values['settings.themeMode'], 'dark');
    expect(store.values['settings.locale'], 'tr');
    expect(store.values['settings.hapticsEnabled'], 'false');

    await controller.setLocale(AppLocale.system);
    expect(store.values.containsKey('settings.locale'), isFalse);
  });
}
