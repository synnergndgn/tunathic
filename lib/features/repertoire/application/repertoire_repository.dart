import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';

final repertoireRepositoryProvider = Provider<RepertoireRepository>(
  (ref) => RepertoireRepository(
    ref.watch(preferencesStoreProvider),
    ref.watch(appLoggerProvider),
  ),
);

/// Stores the user's songs locally as a JSON list.
///
/// The repertoire is plain text authored on this device, so it stays in the
/// same preference storage as the rest of the app and never leaves it.
final class RepertoireRepository {
  RepertoireRepository(this._store, this._logger);

  static const songsKey = 'repertoire.songs';

  final PreferencesStore _store;
  final AppLogger _logger;

  Future<List<Song>> load() async {
    try {
      final stored = await _store.getString(songsKey);
      if (stored == null || stored.isEmpty) return const [];

      final decoded = jsonDecode(stored);
      if (decoded is! List) return const [];

      final songs = <Song>[];
      for (final entry in decoded) {
        final song = Song.fromJson(entry);
        if (song != null) songs.add(song);
      }
      return songs;
    } on Object catch (error, stackTrace) {
      _logger.error('Could not load the repertoire', error, stackTrace);
      return const [];
    }
  }

  Future<void> save(List<Song> songs) async {
    try {
      await _store.setString(
        songsKey,
        jsonEncode([for (final song in songs) song.toJson()]),
      );
    } on Object catch (error, stackTrace) {
      _logger.error('Could not save the repertoire', error, stackTrace);
    }
  }
}
