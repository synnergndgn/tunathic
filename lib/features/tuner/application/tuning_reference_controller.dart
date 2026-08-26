import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_preferences.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

/// Seeded at startup from disk so the first frame of the tuner already uses
/// the player's reference instead of flashing 440 Hz.
final initialTuningReferenceProvider = Provider<TuningReference>(
  (ref) => TuningReference.standard,
);

/// The app-wide concert-pitch reference.
///
/// Not auto-disposed: Settings and the tuner screen edit the same value, and
/// it must survive leaving either of them.
final tuningReferenceProvider =
    NotifierProvider<TuningReferenceController, TuningReference>(
      TuningReferenceController.new,
    );

final class TuningReferenceController extends Notifier<TuningReference> {
  late final TuningReferencePreferences _preferences;
  late final AppLogger _logger;

  @override
  TuningReference build() {
    _preferences = TuningReferencePreferences(
      ref.read(preferencesStoreProvider),
    );
    _logger = ref.read(appLoggerProvider);
    return ref.read(initialTuningReferenceProvider);
  }

  Future<void> setReference(TuningReference reference) async {
    if (state == reference) return;
    state = reference;
    try {
      await _preferences.save(reference);
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save tuning reference', error, stackTrace);
    }
  }

  /// Moves the reference by whole steps, stopping at the ends of the range.
  Future<void> stepReference(int steps) => setReference(state.stepped(steps));
}
