import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

/// Storage for the concert-pitch reference.
///
/// It is kept apart from the rest of the tuner preferences because the
/// reference outlives the tuner screen: Settings edits it too, and every tool
/// that names a note reads it.
final class TuningReferencePreferences {
  TuningReferencePreferences(this._store);

  static const referenceKey = 'tuner.referenceA4';

  final PreferencesStore _store;

  /// A missing, malformed or out-of-range stored value reads back as
  /// [TuningReference.standard].
  Future<TuningReference> load() async =>
      TuningReference.parse(await _store.getString(referenceKey));

  Future<void> save(TuningReference reference) =>
      _store.setString(referenceKey, reference.storageValue);
}

Future<TuningReference> loadInitialTuningReference(
  PreferencesStore store,
  AppLogger logger,
) async {
  try {
    return await TuningReferencePreferences(store).load();
  } on Object catch (error, stackTrace) {
    logger.error('Could not load tuning reference', error, stackTrace);
    return TuningReference.standard;
  }
}
