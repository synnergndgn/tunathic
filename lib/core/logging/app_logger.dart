import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppLogger {
  void debug(String message);

  void error(String message, [Object? error, StackTrace? stackTrace]);
}

final appLoggerProvider = Provider<AppLogger>((ref) => DebugAppLogger());

final class DebugAppLogger implements AppLogger {
  @override
  void debug(String message) {
    developer.log(message, name: 'Tunathic');
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'Tunathic',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
