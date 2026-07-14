import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/app/settings/app_settings.dart';

abstract interface class HapticFeedbackOutput {
  Future<void> selection();

  Future<void> lightImpact();
}

final class SystemHapticFeedbackOutput implements HapticFeedbackOutput {
  @override
  Future<void> selection() => HapticFeedback.selectionClick();

  @override
  Future<void> lightImpact() => HapticFeedback.lightImpact();
}

final hapticFeedbackOutputProvider = Provider<HapticFeedbackOutput>(
  (ref) => SystemHapticFeedbackOutput(),
);

final appHapticsProvider = Provider<AppHaptics>(
  (ref) => AppHaptics(
    isEnabled: () => ref.read(appSettingsProvider).hapticsEnabled,
    output: ref.read(hapticFeedbackOutputProvider),
  ),
);

final class AppHaptics {
  const AppHaptics({required this.isEnabled, required this.output});

  final bool Function() isEnabled;
  final HapticFeedbackOutput output;

  Future<void> selection() async {
    if (isEnabled()) await output.selection();
  }

  Future<void> lightImpact() async {
    if (isEnabled()) await output.lightImpact();
  }
}
