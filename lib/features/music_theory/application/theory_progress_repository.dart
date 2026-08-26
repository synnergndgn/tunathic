import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/music_theory/domain/theory_progress.dart';

final theoryProgressRepositoryProvider = Provider<TheoryProgressRepository>(
  (ref) => TheoryProgressRepository(
    ref.watch(preferencesStoreProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// Stores starred and recently read lessons locally as JSON.
///
/// Only lesson identifiers are written. Nothing about the reader is stored,
/// and nothing leaves the device.
final class TheoryProgressRepository {
  TheoryProgressRepository(this._store, this._logger);

  static const progressKey = 'musicTheory.progress';

  final PreferencesStore _store;
  final AppLogger _logger;

  Future<TheoryProgress> load() async {
    try {
      final stored = await _store.getString(progressKey);
      if (stored == null || stored.isEmpty) return TheoryProgress.empty;
      return TheoryProgress.fromJson(jsonDecode(stored)) ??
          TheoryProgress.empty;
    } on Object catch (error, stackTrace) {
      _logger.error('Could not load Music Theory progress', error, stackTrace);
      return TheoryProgress.empty;
    }
  }

  Future<void> save(TheoryProgress progress) async {
    try {
      await _store.setString(progressKey, jsonEncode(progress.toJson()));
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save Music Theory progress', error, stackTrace);
    }
  }
}
