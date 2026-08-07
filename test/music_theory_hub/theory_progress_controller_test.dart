import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_controller.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_repository.dart';

import '../support/fakes.dart';

void main() {
  ProviderContainer container(MemoryPreferencesStore store) {
    final result = ProviderContainer(
      overrides: [
        preferencesStoreProvider.overrideWithValue(store),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
      ],
    );
    addTearDown(result.dispose);
    return result;
  }

  test('a fresh install starts with nothing stored', () async {
    final store = MemoryPreferencesStore();
    final progress = await container(store).read(theoryProgressProvider.future);

    expect(progress.favoriteIds, isEmpty);
    expect(progress.recentIds, isEmpty);
  });

  test('favourites and recent reading persist locally', () async {
    final store = MemoryPreferencesStore();
    final ref = container(store);
    await ref.read(theoryProgressProvider.future);
    final controller = ref.read(theoryProgressProvider.notifier);

    await controller.toggleFavorite('triads');
    await controller.markViewed('modes');

    final stored = jsonDecode(
      store.values[TheoryProgressRepository.progressKey]!,
    );
    expect(stored['favorites'], ['triads']);
    expect(stored['recent'], ['modes']);
  });

  test('stored progress is restored on the next launch', () async {
    final store = MemoryPreferencesStore({
      TheoryProgressRepository.progressKey: jsonEncode({
        'favorites': ['triads'],
        'recent': ['modes'],
      }),
    });

    final progress = await container(store).read(theoryProgressProvider.future);
    expect(progress.favoriteIds, ['triads']);
    expect(progress.recentIds, ['modes']);
  });

  test('progress referring to retired lessons is dropped on load', () async {
    final store = MemoryPreferencesStore({
      TheoryProgressRepository.progressKey: jsonEncode({
        'favorites': ['triads', 'interval-trainer'],
        'recent': ['interval-trainer'],
      }),
    });

    final progress = await container(store).read(theoryProgressProvider.future);
    expect(progress.favoriteIds, ['triads']);
    expect(progress.recentIds, isEmpty);
  });

  test('corrupted storage falls back to an empty hub', () async {
    final store = MemoryPreferencesStore({
      TheoryProgressRepository.progressKey: 'not json',
    });

    final progress = await container(store).read(theoryProgressProvider.future);
    expect(progress.favoriteIds, isEmpty);
  });

  test('re-opening the current lesson does not rewrite storage', () async {
    final store = MemoryPreferencesStore();
    final ref = container(store);
    await ref.read(theoryProgressProvider.future);
    final controller = ref.read(theoryProgressProvider.notifier);

    await controller.markViewed('modes');
    final first = store.values[TheoryProgressRepository.progressKey];
    store.values.remove(TheoryProgressRepository.progressKey);

    await controller.markViewed('modes');
    expect(store.values[TheoryProgressRepository.progressKey], isNull);
    expect(first, isNotNull);
  });
}
