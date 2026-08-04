import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/repertoire/application/repertoire_controller.dart';
import 'package:tunathic/features/repertoire/application/repertoire_repository.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';

import '../support/fakes.dart';

void main() {
  group('RepertoireRepository', () {
    test('restores stored songs', () async {
      final store = MemoryPreferencesStore({
        RepertoireRepository.songsKey: jsonEncode([
          const Song(
            id: 'song-1',
            title: 'Placeholder title',
            content: '[C]a placeholder line',
          ).toJson(),
        ]),
      });

      final songs = await RepertoireRepository(store, RecordingLogger()).load();

      expect(songs.single.id, 'song-1');
      expect(songs.single.content, '[C]a placeholder line');
    });

    test('reports unreadable storage instead of failing', () async {
      final logger = RecordingLogger();
      final store = MemoryPreferencesStore({
        RepertoireRepository.songsKey: 'not json',
      });

      expect(await RepertoireRepository(store, logger).load(), isEmpty);
      expect(logger.errorMessages, isNotEmpty);
    });

    test('skips unusable entries but keeps the rest', () async {
      final store = MemoryPreferencesStore({
        RepertoireRepository.songsKey: jsonEncode([
          {'title': 'Missing an id'},
          {'id': 'song-2', 'title': 'Kept'},
        ]),
      });

      final songs = await RepertoireRepository(store, RecordingLogger()).load();

      expect(songs.single.id, 'song-2');
    });
  });

  group('RepertoireController', () {
    test('converts a pasted chart and stores it as ChordPro', () async {
      final store = MemoryPreferencesStore();
      final container = _container(store);

      await container.read(repertoireProvider.future);
      await container
          .read(repertoireProvider.notifier)
          .create(
            title: 'Placeholder title',
            artist: 'Placeholder artist',
            content: 'C         G\nthis line has words below',
          );

      final songs = container.read(repertoireProvider).value!;
      expect(songs.single.content, '[C]this line [G]has words below');
      expect(
        store.values[RepertoireRepository.songsKey],
        contains('[C]this line [G]has words below'),
      );
    });

    test('keeps the list sorted by title', () async {
      final container = _container(MemoryPreferencesStore());
      final controller = container.read(repertoireProvider.notifier);
      await container.read(repertoireProvider.future);

      await controller.create(title: 'Second placeholder');
      await controller.create(title: 'First placeholder');

      expect(
        container.read(repertoireProvider).value!.map((song) => song.title),
        ['First placeholder', 'Second placeholder'],
      );
    });

    test('persists transposition and scroll speed per song', () async {
      final store = MemoryPreferencesStore();
      final container = _container(store);
      final controller = container.read(repertoireProvider.notifier);
      await container.read(repertoireProvider.future);
      final song = await controller.create(title: 'Placeholder title');

      await controller.setTranspose(song.id, 3);
      await controller.setScrollSpeedLevel(song.id, 8);

      final stored = await RepertoireRepository(
        store,
        RecordingLogger(),
      ).load();
      expect(stored.single.transpose, 3);
      expect(stored.single.scrollSpeedLevel, 8);
    });

    test('clamps transposition to the supported range', () async {
      final container = _container(MemoryPreferencesStore());
      final controller = container.read(repertoireProvider.notifier);
      await container.read(repertoireProvider.future);
      final song = await controller.create(title: 'Placeholder title');

      await controller.setTranspose(song.id, 40);

      expect(controller.songById(song.id)!.transpose, Song.maxTranspose);
    });

    test('deletes a song from state and storage', () async {
      final store = MemoryPreferencesStore();
      final container = _container(store);
      final controller = container.read(repertoireProvider.notifier);
      await container.read(repertoireProvider.future);
      final song = await controller.create(title: 'Placeholder title');

      await controller.delete(song.id);

      expect(container.read(repertoireProvider).value, isEmpty);
      expect(store.values[RepertoireRepository.songsKey], '[]');
    });
  });
}

ProviderContainer _container(MemoryPreferencesStore store) {
  var nextId = 0;
  final container = ProviderContainer(
    overrides: [
      preferencesStoreProvider.overrideWithValue(store),
      songIdFactoryProvider.overrideWithValue(() => 'song-${++nextId}'),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
