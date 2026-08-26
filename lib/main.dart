import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/bootstrap.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/metronome/application/metronome_preferences.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_controller.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerNativeLicenses();

  final logger = DebugAppLogger();
  final preferencesStore = SharedPreferencesStore();
  final initialSettings = await loadInitialSettings(preferencesStore, logger);
  final initialMetronomeConfig = await loadInitialMetronomeConfig(
    preferencesStore,
    logger,
  );
  final initialApplicationInfo = await loadInitialApplicationInfo(
    PackageApplicationInfoLoader(),
    logger,
  );
  final initialTuningReference = await loadInitialTuningReference(
    preferencesStore,
    logger,
  );

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
        initialApplicationInfoProvider.overrideWithValue(
          initialApplicationInfo,
        ),
        initialMetronomeConfigProvider.overrideWithValue(
          initialMetronomeConfig,
        ),
        initialTuningReferenceProvider.overrideWithValue(
          initialTuningReference,
        ),
      ],
      child: const TunathicApp(),
    ),
  );
}
