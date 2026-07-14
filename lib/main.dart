import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/bootstrap.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = DebugAppLogger();
  final preferencesStore = SharedPreferencesStore();
  final initialSettings = await loadInitialSettings(preferencesStore, logger);

  FlutterError.onError = (details) {
    logger.error(
      'Uncaught Flutter framework error',
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught platform error', error, stack);
    return true;
  };
  ErrorWidget.builder = buildFriendlyErrorWidget;

  runApp(
    ProviderScope(
      overrides: [
        appLoggerProvider.overrideWithValue(logger),
        preferencesStoreProvider.overrideWithValue(preferencesStore),
        initialAppSettingsProvider.overrideWithValue(initialSettings),
      ],
      child: const TunathicApp(),
    ),
  );
}
