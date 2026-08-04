import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/core/screen/screen_wake_lock.dart';
import 'package:tunathic/features/repertoire/application/repertoire_controller.dart';
import 'package:tunathic/features/repertoire/application/repertoire_repository.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';
import 'package:tunathic/features/repertoire/presentation/song_view_screen.dart';

import '../support/fakes.dart';

const _shortSong = Song(
  id: 'song-1',
  title: 'Placeholder title',
  artist: 'Placeholder artist',
  content: '[C]a placeholder line [G]with two chords',
);

void main() {
  testWidgets('transposes the chart up and down and stores the choice', (
    tester,
  ) async {
    _useTallSurface(tester);
    final store = _storeWith([_shortSong]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    expect(_chordSummary(tester), 'Chords: C  G');

    await tester.tap(find.byKey(const Key('transposeUp')));
    await tester.pumpAndSettle();

    // C up one semitone reads as Db, so the whole chart switches to flats.
    expect(find.byKey(const Key('transposeValue')), findsOneWidget);
    expect(_transposeValue(tester), '+1');
    expect(_chordSummary(tester), 'Chords: Db  Ab');

    await tester.tap(find.byKey(const Key('transposeDown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transposeDown')));
    await tester.pumpAndSettle();

    expect(_transposeValue(tester), '-1');
    expect(_chordSummary(tester), 'Chords: B  F#');
    expect(
      store.values[RepertoireRepository.songsKey],
      contains('"transpose":-1'),
    );

    await tester.tap(find.byKey(const Key('transposeReset')));
    await tester.pumpAndSettle();

    expect(_transposeValue(tester), '0');
    expect(_chordSummary(tester), 'Chords: C  G');
  });

  testWidgets('honours an explicit accidental choice', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_testApp(_storeWith([_shortSong])));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('transposeUp')));
    await tester.pumpAndSettle();
    expect(_chordSummary(tester), 'Chords: Db  Ab');

    await tester.tap(find.text('Sharps'));
    await tester.pumpAndSettle();

    expect(_chordSummary(tester), 'Chords: C#  G#');
  });

  testWidgets('auto-scroll advances the sheet and can be stopped', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      _testApp(
        _storeWith([
          Song(
            id: 'song-1',
            title: 'Placeholder title',
            content: List.generate(
              80,
              (index) => '[C]placeholder line number $index',
            ).join('\n'),
          ),
        ]),
      ),
    );
    await _openSong(tester);

    expect(_scrollOffset(tester), 0);

    await tester.tap(find.byKey(const Key('autoScrollToggle')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // The default level 3 moves 24 logical pixels per second.
    final scrolled = _scrollOffset(tester);
    expect(scrolled, greaterThan(20));

    await tester.tap(find.byKey(const Key('autoScrollToggle')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(_scrollOffset(tester), scrolled);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a faster level scrolls further in the same time', (
    tester,
  ) async {
    _useTallSurface(tester);
    final store = _storeWith([
      Song(
        id: 'song-1',
        title: 'Placeholder title',
        scrollSpeedLevel: 10,
        content: List.generate(
          80,
          (index) => '[C]placeholder line number $index',
        ).join('\n'),
      ),
    ]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('autoScrollToggle')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Level 10 moves 80 logical pixels per second.
    expect(_scrollOffset(tester), greaterThan(70));

    await tester.tap(find.byKey(const Key('autoScrollToggle')));
    await tester.pumpAndSettle();
  });

  testWidgets('places a chord on a tapped word', (tester) async {
    _useTallSurface(tester);
    final store = _storeWith([
      const Song(
        id: 'song-1',
        title: 'Placeholder title',
        content: 'first placeholder line\nsecond placeholder line',
      ),
    ]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('toggleChordEditing')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a word to put a chord on it'),
      findsOneWidget,
    );

    await tester.tap(_word('second'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chordPickerScroll')), findsOneWidget);
    await tester.tap(find.byKey(const Key('chordPickerRoot-G')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerQuality-m')));
    await tester.pumpAndSettle();

    expect(
      store.values[RepertoireRepository.songsKey],
      contains(r'first placeholder line\n[Gm]second placeholder line'),
    );
    expect(_chordSummary(tester), 'Chords: Gm');
  });

  testWidgets('places chords where there are no lyrics', (tester) async {
    _useTallSurface(tester);
    final store = _storeWith([
      const Song(
        id: 'song-1',
        title: 'Placeholder title',
        content: 'first placeholder line\n\nsecond placeholder line',
      ),
    ]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('toggleChordEditing')));
    await tester.pumpAndSettle();

    // An empty line is where an intro or instrumental break belongs.
    await tester.tap(find.byKey(const Key('addChordOnEmptyLine')));
    await tester.pumpAndSettle();
    await _pickChord(tester, root: 'G', quality: 'm');

    expect(
      store.values[RepertoireRepository.songsKey],
      contains(r'first placeholder line\n[Gm]\nsecond placeholder line'),
    );

    // The instrumental line takes further chords, separated in the text.
    await tester.tap(find.byKey(const Key('addChordAtLineEnd')).at(1));
    await tester.pumpAndSettle();
    await _pickChord(tester, root: 'F', quality: '');

    expect(store.values[RepertoireRepository.songsKey], contains(r'[Gm] [F]'));

    // A chord standing on its own can still be removed.
    await tester.tap(_word('Gm'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerRemove')));
    await tester.pumpAndSettle();

    expect(store.values[RepertoireRepository.songsKey], contains(r'\n [F]\n'));
  });

  testWidgets('places a chord after the last word of a line', (tester) async {
    _useTallSurface(tester);
    final store = _storeWith([
      const Song(
        id: 'song-1',
        title: 'Placeholder title',
        content: 'first placeholder line',
      ),
    ]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('toggleChordEditing')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addChordAtLineEnd')).first);
    await tester.pumpAndSettle();
    await _pickChord(tester, root: 'A', quality: '');

    expect(
      store.values[RepertoireRepository.songsKey],
      contains('first placeholder line[A]'),
    );
  });

  testWidgets('removes a chord from a tapped word', (tester) async {
    _useTallSurface(tester);
    final store = _storeWith([
      const Song(
        id: 'song-1',
        title: 'Placeholder title',
        content: '[Am]first placeholder line',
      ),
    ]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('toggleChordEditing')));
    await tester.pumpAndSettle();
    await tester.tap(_word('first'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerRemove')));
    await tester.pumpAndSettle();

    expect(
      store.values[RepertoireRepository.songsKey],
      contains('"content":"first placeholder line"'),
    );
  });

  testWidgets('writes a picked chord back in the written key', (tester) async {
    _useTallSurface(tester);
    final store = _storeWith([
      const Song(
        id: 'song-1',
        title: 'Placeholder title',
        content: '[C]first placeholder line',
      ),
    ]);
    await tester.pumpWidget(_testApp(store));
    await _openSong(tester);

    await tester.tap(find.byKey(const Key('transposeUp')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transposeUp')));
    await tester.pumpAndSettle();
    expect(_chordSummary(tester), 'Chords: D');

    await tester.tap(find.byKey(const Key('toggleChordEditing')));
    await tester.pumpAndSettle();
    await tester.tap(_word('line'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerRoot-A')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chordPickerQuality-')));
    await tester.pumpAndSettle();

    // The performer picked the A they can see at +2, so G is stored.
    expect(
      store.values[RepertoireRepository.songsKey],
      contains(r'[C]first placeholder [G]line'),
    );
    expect(_chordSummary(tester), 'Chords: D  A');
  });

  testWidgets('keeps the screen awake only while the sheet is open', (
    tester,
  ) async {
    _useTallSurface(tester);
    final wakeLock = FakeScreenWakeLock();
    await tester.pumpWidget(
      _testApp(_storeWith([_shortSong]), wakeLock: wakeLock),
    );
    await _openSong(tester);

    expect(wakeLock.isEnabled, isTrue);
    expect(wakeLock.enableCount, 1);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(wakeLock.isEnabled, isFalse);
    expect(wakeLock.disableCount, 1);
  });

  testWidgets('works in Turkish with 2x text', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      _testApp(
        _storeWith([_shortSong]),
        settings: const AppSettings(locale: AppLocale.turkish),
        textScale: 2,
      ),
    );
    await _openSong(tester, toolLabel: 'Repertuar');

    expect(find.text('Transpoze'), findsOneWidget);
    expect(find.text('Otomatik kaydırma'), findsOneWidget);
    expect(find.byTooltip('Otomatik kaydırmayı başlat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pickChord(
  WidgetTester tester, {
  required String root,
  required String quality,
}) async {
  await tester.tap(find.byKey(Key('chordPickerRoot-$root')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('chordPickerQuality-$quality')));
  await tester.pumpAndSettle();
}

Finder _word(String word) => find.byWidgetPredicate(
  (widget) => widget is Text && widget.data?.trim() == word,
);

String _chordSummary(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('songChordSummary'))).data!;

String _transposeValue(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('transposeValue'))).data!;

double _scrollOffset(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('songSheetScroll')),
        matching: find.byType(Scrollable),
      ),
    )
    .position
    .pixels;

MemoryPreferencesStore _storeWith(List<Song> songs) => MemoryPreferencesStore({
  RepertoireRepository.songsKey: jsonEncode([
    for (final song in songs) song.toJson(),
  ]),
});

Widget _testApp(
  MemoryPreferencesStore store, {
  AppSettings settings = const AppSettings(),
  double textScale = 1,
  ScreenWakeLock? wakeLock,
}) => ProviderScope(
  overrides: [
    preferencesStoreProvider.overrideWithValue(store),
    initialAppSettingsProvider.overrideWithValue(settings),
    hapticFeedbackOutputProvider.overrideWithValue(FakeHapticFeedbackOutput()),
    screenWakeLockProvider.overrideWithValue(wakeLock ?? FakeScreenWakeLock()),
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

Future<void> _openSong(
  WidgetTester tester, {
  String toolLabel = 'Repertoire',
}) async {
  await tester.pumpAndSettle();
  final repertoire = find.text(toolLabel).hitTestable().first;
  await tester.ensureVisible(repertoire);
  await tester.pumpAndSettle();
  await tester.tap(repertoire);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Placeholder title'));
  await tester.pumpAndSettle();
  expect(find.byType(SongViewScreen), findsOneWidget);
}
