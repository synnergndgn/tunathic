import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

final class MemoryPreferencesStore implements PreferencesStore {
  MemoryPreferencesStore([Map<String, String>? values]) : values = {...?values};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

final class RecordingLogger implements AppLogger {
  final List<String> debugMessages = [];
  final List<String> errorMessages = [];

  @override
  void debug(String message) => debugMessages.add(message);

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    errorMessages.add(message);
  }
}
