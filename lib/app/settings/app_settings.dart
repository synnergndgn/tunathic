import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

enum AppLocale {
  system(null),
  english('en'),
  turkish('tr');

  const AppLocale(this.languageCode);

  final String? languageCode;

  Locale? get locale => switch (languageCode) {
    final code? => Locale(code),
    null => null,
  };

  static AppLocale fromLanguageCode(String? code) {
    return AppLocale.values.firstWhere(
      (value) => value.languageCode == code,
      orElse: () => AppLocale.system,
    );
  }
}

@immutable
final class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = AppLocale.system,
    this.hapticsEnabled = true,
  });

  final ThemeMode themeMode;
  final AppLocale locale;
  final bool hapticsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLocale? locale,
    bool? hapticsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.locale == locale &&
        other.hapticsEnabled == hapticsEnabled;
  }

  @override
  int get hashCode => Object.hash(themeMode, locale, hapticsEnabled);
}

final class AppSettingsPreferences {
  AppSettingsPreferences(this._store);

  static const _themeModeKey = 'settings.themeMode';
  static const _localeKey = 'settings.locale';
  static const _hapticsEnabledKey = 'settings.hapticsEnabled';

  final PreferencesStore _store;

  Future<AppSettings> load() async {
    final values = await Future.wait([
      _store.getString(_themeModeKey),
      _store.getString(_localeKey),
      _store.getString(_hapticsEnabledKey),
    ]);
    return AppSettings(
      themeMode: _themeModeFromName(values[0]),
      locale: AppLocale.fromLanguageCode(values[1]),
      hapticsEnabled: values[2] != 'false',
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _store.setString(_themeModeKey, mode.name);

  Future<void> saveLocale(AppLocale locale) async {
    final code = locale.languageCode;
    if (code == null) {
      await _store.remove(_localeKey);
      return;
    }
    await _store.setString(_localeKey, code);
  }

  Future<void> saveHapticsEnabled(bool enabled) =>
      _store.setString(_hapticsEnabledKey, enabled.toString());

  ThemeMode _themeModeFromName(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

final initialAppSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

final class AppSettingsController extends Notifier<AppSettings> {
  late final AppSettingsPreferences _preferences;
  late final AppLogger _logger;

  @override
  AppSettings build() {
    _preferences = AppSettingsPreferences(ref.read(preferencesStoreProvider));
    _logger = ref.read(appLoggerProvider);
    return ref.read(initialAppSettingsProvider);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    try {
      await _preferences.saveThemeMode(mode);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save theme preference', error, stackTrace);
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    if (state.locale == locale) return;
    state = state.copyWith(locale: locale);
    try {
      await _preferences.saveLocale(locale);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save locale preference', error, stackTrace);
    }
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    if (state.hapticsEnabled == enabled) return;
    state = state.copyWith(hapticsEnabled: enabled);
    try {
      await _preferences.saveHapticsEnabled(enabled);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save haptic preference', error, stackTrace);
    }
  }
}
