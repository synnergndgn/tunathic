import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tunathic/core/logging/app_logger.dart';

final class ApplicationInfo {
  const ApplicationInfo({required this.version, required this.buildNumber});

  const ApplicationInfo.unavailable() : version = '—', buildNumber = '';

  final String version;
  final String buildNumber;

  String get displayVersion =>
      buildNumber.isEmpty ? version : '$version+$buildNumber';
}

abstract interface class ApplicationInfoLoader {
  Future<ApplicationInfo> load();
}

final class PackageApplicationInfoLoader implements ApplicationInfoLoader {
  @override
  Future<ApplicationInfo> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return ApplicationInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}

final initialApplicationInfoProvider = Provider<ApplicationInfo>(
  (ref) => const ApplicationInfo.unavailable(),
);

Future<ApplicationInfo> loadInitialApplicationInfo(
  ApplicationInfoLoader loader,
  AppLogger logger,
) async {
  try {
    return await loader.load();
  } on Object catch (error, stackTrace) {
    logger.error(
      'Could not load application package information',
      error,
      stackTrace,
    );
    return const ApplicationInfo.unavailable();
  }
}
