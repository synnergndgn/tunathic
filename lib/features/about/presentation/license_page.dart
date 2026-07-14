import 'package:flutter/material.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/l10n/app_localizations.dart';

void showTunathicLicensePage(
  BuildContext context,
  ApplicationInfo applicationInfo,
) {
  final localizations = AppLocalizations.of(context);
  showLicensePage(
    context: context,
    applicationName: localizations.productFullName,
    applicationVersion: applicationInfo.displayVersion,
    applicationLegalese: localizations.copyrightNotice,
  );
}
