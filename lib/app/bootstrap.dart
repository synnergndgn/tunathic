import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/shared/widgets/friendly_error_view.dart';

Future<AppSettings> loadInitialSettings(
  PreferencesStore store,
  AppLogger logger,
) async {
  try {
    return await AppSettingsPreferences(store).load();
  } on Object catch (error, stackTrace) {
    logger.error('Could not load application preferences', error, stackTrace);
    return const AppSettings();
  }
}

Widget buildFriendlyErrorWidget(FlutterErrorDetails details) {
  return const Material(child: FriendlyErrorView());
}

void registerNativeLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/licenses/oboe.txt');
    yield LicenseEntryWithLineBreaks(const ['Oboe'], license);
  });
}
