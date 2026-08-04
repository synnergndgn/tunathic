import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the display on while a screen needs to stay readable hands-free.
abstract interface class ScreenWakeLock {
  Future<void> enable();

  Future<void> disable();
}

final screenWakeLockProvider = Provider<ScreenWakeLock>(
  (ref) => PluginScreenWakeLock(ref.watch(appLoggerProvider)),
);

/// The only place the wakelock plugin is called.
///
/// On Android this sets `FLAG_KEEP_SCREEN_ON`, which needs no permission and
/// applies only while Tunathic is in the foreground. A failure is logged and
/// swallowed: losing the wake lock must never take down the screen using it.
final class PluginScreenWakeLock implements ScreenWakeLock {
  PluginScreenWakeLock(this._logger);

  final AppLogger _logger;

  @override
  Future<void> enable() =>
      _guard(() => WakelockPlus.enable(), 'Could not keep the screen awake');

  @override
  Future<void> disable() => _guard(
    () => WakelockPlus.disable(),
    'Could not release the screen wake lock',
  );

  Future<void> _guard(Future<void> Function() action, String message) async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      _logger.error(message, error, stackTrace);
    }
  }
}
