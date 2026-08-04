import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/repertoire/application/repertoire_controller.dart';
import 'package:tunathic/features/repertoire/application/repertoire_repository.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';
import 'package:tunathic/features/repertoire/presentation/repertoire_screen.dart';
import 'package:tunathic/features/repertoire/presentation/song_view_screen.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('dashboard opens an empty Repertoire', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_testApp(MemoryPreferencesStore()));
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertoire');

    expect(find.byType(RepertoireScreen), findsOneWidget);
    expect(find.text('No songs yet'), findsOneWidget);
    expect(find.byKey(const Key('addFirstSong')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds a song from a pasted chart and lists it', (tester) async {
    _useTallSurface(tester);
    final store = MemoryPreferencesStore();
    await tester.pumpWidget(_testApp(store));
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertoire');

    await tester.tap(find.byKey(const Key('addFirstSong')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('songTitleField')),
      'Placeholder title',
    );
    await tester.enterText(
      find.byKey(const Key('songArtistField')),
      'Placeholder artist',
    );
    await tester.enterText(
      find.byKey(const Key('songContentField')),
      'C         G\nthis line has words below',
    );
    await tester.tap(find.byKey(const Key('saveSong')));
    await tester.pumpAndSettle();

    expect(
      find.text('Chords above the lyrics were converted automatically.'),
      findsOneWidget,
    );
    expect(
      store.values[RepertoireRepository.songsKey],
      contains('[C]this line [G]has words below'),
    );

    // Saving a new song hands straight over to chord placement.
    expect(find.byType(SongViewScreen), findsOneWidget);
    expect(find.byKey(const Key('doneEditingChords')), findsOneWidget);

    // A pasted chart stays editable: its chords can be changed afterwards.
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerRoot-A')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerQuality-m')));
    await tester.pumpAndSettle();

    expect(
      store.values[RepertoireRepository.songsKey],
      contains('[Am]this line [G]has words below'),
    );

    // Let the snackbar time out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // The editor is out of the stack, so back reaches the list.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(RepertoireScreen), findsOneWidget);
    expect(find.text('Placeholder title'), findsOneWidget);
    expect(find.text('Placeholder artist'), findsOneWidget);
  });

  testWidgets('a song saved without lyrics returns to the list', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_testApp(MemoryPreferencesStore()));
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertoire');

    await tester.tap(find.byKey(const Key('addFirstSong')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('songTitleField')),
      'Placeholder title',
    );
    await tester.tap(find.byKey(const Key('saveSong')));
    await tester.pumpAndSettle();

    expect(find.byType(RepertoireScreen), findsOneWidget);
    expect(find.text('Placeholder title'), findsOneWidget);
  });

  testWidgets('refuses to save a song without a title', (tester) async {
    _useTallSurface(tester);
    final store = MemoryPreferencesStore();
    await tester.pumpWidget(_testApp(store));
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertoire');

    await tester.tap(find.byKey(const Key('addFirstSong')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveSong')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a title.'), findsOneWidget);
    expect(store.values[RepertoireRepository.songsKey], isNull);
  });

  testWidgets('searches the stored songs', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      _testApp(
        _storeWith([
          const Song(id: 'song-1', title: 'Alpha placeholder'),
          const Song(
            id: 'song-2',
            title: 'Beta placeholder',
            artist: 'Second artist',
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertoire');

    expect(find.text('Alpha placeholder'), findsOneWidget);
    expect(find.text('Beta placeholder'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('songSearchField')), 'second');
    await tester.pumpAndSettle();

    expect(find.text('Alpha placeholder'), findsNothing);
    expect(find.text('Beta placeholder'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('songSearchField')), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No songs match your search.'), findsOneWidget);
  });

  testWidgets('deletes a song from the editor', (tester) async {
    _useTallSurface(tester);
    final store = _storeWith([
      const Song(id: 'song-1', title: 'Placeholder title'),
    ]);
    await tester.pumpWidget(_testApp(store));
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertoire');

    await tester.tap(find.text('Placeholder title'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editSong')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteSong')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteSong')));
    await tester.pumpAndSettle();

    expect(find.byType(RepertoireScreen), findsOneWidget);
    expect(find.text('No songs yet'), findsOneWidget);
    expect(store.values[RepertoireRepository.songsKey], '[]');
  });

  testWidgets('works in Turkish with 2x text', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      _testApp(
        _storeWith([const Song(id: 'song-1', title: 'Placeholder title')]),
        settings: const AppSettings(locale: AppLocale.turkish),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await _openRepertoire(tester, 'Repertuar');

    expect(find.text('Şarkı ara'), findsOneWidget);
    expect(find.text('Şarkı ekle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

MemoryPreferencesStore _storeWith(List<Song> songs) => MemoryPreferencesStore({
  RepertoireRepository.songsKey: jsonEncode([
    for (final song in songs) song.toJson(),
  ]),
});

Widget _testApp(
  MemoryPreferencesStore store, {
  AppSettings settings = const AppSettings(),
  double textScale = 1,
}) => ProviderScope(
  overrides: [
    preferencesStoreProvider.overrideWithValue(store),
    initialAppSettingsProvider.overrideWithValue(settings),
    hapticFeedbackOutputProvider.overrideWithValue(FakeHapticFeedbackOutput()),
    songIdFactoryProvider.overrideWithValue(() => 'song-new'),
  ],
  child: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: const TunathicApp(),
  ),
);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _openRepertoire(WidgetTester tester, String title) async {
  final finder = find.text(title);
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('dashboardScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
