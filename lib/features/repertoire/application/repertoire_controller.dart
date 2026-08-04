import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/features/repertoire/application/repertoire_repository.dart';
import 'package:tunathic/features/repertoire/domain/chord_sheet_importer.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';

/// Generates identifiers for new songs. Overridden in tests for stable ids.
final songIdFactoryProvider = Provider<String Function()>(
  (ref) =>
      () => 'song-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
);

final repertoireProvider =
    AsyncNotifierProvider<RepertoireController, List<Song>>(
      RepertoireController.new,
    );

/// Owns the stored song list and every mutation the UI can trigger.
final class RepertoireController extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() async =>
      _sorted(await ref.watch(repertoireRepositoryProvider).load());

  Future<Song> create({
    required String title,
    String artist = '',
    String content = '',
  }) async {
    final song = Song(
      id: ref.read(songIdFactoryProvider)(),
      title: title.trim(),
      artist: artist.trim(),
      content: ChordSheetImporter.normalize(content),
      updatedAt: DateTime.now(),
    );
    await _commit([..._current, song]);
    return song;
  }

  Future<void> updateDetails({
    required String id,
    required String title,
    required String artist,
    required String content,
  }) => _replace(
    id,
    (song) => song.copyWith(
      title: title.trim(),
      artist: artist.trim(),
      content: ChordSheetImporter.normalize(content),
      updatedAt: DateTime.now(),
    ),
  );

  Future<void> setTranspose(String id, int semitones) =>
      _replace(id, (song) => song.copyWith(transpose: semitones));

  Future<void> setScrollSpeedLevel(String id, int level) =>
      _replace(id, (song) => song.copyWith(scrollSpeedLevel: level));

  Future<void> delete(String id) async =>
      _commit(_current.where((song) => song.id != id).toList());

  Song? songById(String id) {
    for (final song in _current) {
      if (song.id == id) return song;
    }
    return null;
  }

  List<Song> get _current => state.value ?? const [];

  Future<void> _replace(String id, Song Function(Song song) transform) async {
    final songs = [
      for (final song in _current) song.id == id ? transform(song) : song,
    ];
    await _commit(songs);
  }

  Future<void> _commit(List<Song> songs) async {
    final ordered = _sorted(songs);
    state = AsyncData(ordered);
    await ref.read(repertoireRepositoryProvider).save(ordered);
  }

  static List<Song> _sorted(List<Song> songs) {
    final ordered = [...songs]
      ..sort(
        (first, second) =>
            first.title.toLowerCase().compareTo(second.title.toLowerCase()),
      );
    return ordered;
  }
}
