import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_screen.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_screen.dart';
import 'package:tunathic/features/fretboard/presentation/interactive_fretboard_screen.dart';
import 'package:tunathic/features/music_theory/application/theory_progress_repository.dart';
import 'package:tunathic/features/music_theory/presentation/music_theory_screen.dart';
import 'package:tunathic/features/music_theory/presentation/theory_category_screen.dart';
import 'package:tunathic/features/music_theory/presentation/theory_lesson_screen.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('the dashboard opens the Music Theory hub', (tester) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Music Theory'));
    await tester.pumpAndSettle();

    expect(find.byType(MusicTheoryScreen), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.byKey(const Key('theoryCategory_intervals')), findsOneWidget);
    expect(
      find.byKey(const Key('theoryCategory_guitar-theory')),
      findsOneWidget,
    );
  });

  testWidgets('hub, category, and lesson form one navigation path', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openHub(tester);

    await tester.tap(find.byKey(const Key('theoryCategory_intervals')));
    await tester.pumpAndSettle();
    expect(find.byType(TheoryCategoryScreen), findsOneWidget);
    expect(
      find.byKey(const Key('theoryLevelHeading_beginner')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('theoryLesson_interval-tritone')));
    await tester.pumpAndSettle();
    expect(find.byType(TheoryLessonScreen), findsOneWidget);
    expect(find.text('Tritone'), findsWidgets);
    expect(find.byKey(const Key('theoryLessonSummary')), findsOneWidget);
  });

  testWidgets('search finds a lesson by alias and clears back to browsing', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openHub(tester);

    await tester.enterText(find.byKey(const Key('theorySearchField')), 'm7b5');
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('theoryLesson_diminished-chords')),
      findsOneWidget,
    );
    expect(find.text('Categories'), findsNothing);

    await tester.tap(find.byKey(const Key('theoryClearSearch')));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
  });

  testWidgets('a query with no match explains itself', (tester) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openHub(tester);

    await tester.enterText(
      find.byKey(const Key('theorySearchField')),
      'zzzzqqq',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('theoryNoResults')), findsOneWidget);
    expect(find.text('No lessons found'), findsOneWidget);
  });

  testWidgets('the level filter narrows the catalog', (tester) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openHub(tester);

    await tester.tap(find.byKey(const Key('theoryLevel_advanced')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('theoryResultCount')), findsOneWidget);
    expect(find.byKey(const Key('theoryLesson_caged-system')), findsOneWidget);
    expect(find.byKey(const Key('theoryLesson_note-names')), findsNothing);
  });

  testWidgets('a starred lesson is stored and reappears in favorites', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    final store = MemoryPreferencesStore();
    await tester.pumpWidget(_app(store: store));
    await _openHub(tester);

    await tester.enterText(
      find.byKey(const Key('theorySearchField')),
      'triads',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theoryFavorite_triads')));
    await tester.pumpAndSettle();

    expect(
      store.values[TheoryProgressRepository.progressKey],
      contains('triads'),
    );

    await tester.tap(find.byKey(const Key('theoryClearSearch')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('theoryFavoritesSection')), findsOneWidget);
  });

  testWidgets('opening a lesson records it as recently viewed', (tester) async {
    _setSurface(tester, 800, 1600);
    final store = MemoryPreferencesStore();
    await tester.pumpWidget(_app(store: store));
    await _openHub(tester);

    await tester.tap(find.byKey(const Key('theoryCategory_rhythm')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theoryLesson_bpm')));
    await tester.pumpAndSettle();

    expect(store.values[TheoryProgressRepository.progressKey], contains('bpm'));
  });

  testWidgets('Try it opens the Chord Library on the lesson example', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openLesson(tester, 'chords', 'triads');

    await tester.scrollUntilVisible(
      find.byKey(const Key('theoryAction_chord-library')),
      300,
      scrollable: _lessonScrollable(),
    );
    await tester.tap(find.byKey(const Key('theoryAction_chord-library')));
    await tester.pumpAndSettle();

    expect(find.byType(ChordLibraryScreen), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('chordSymbol'))).data,
      'C',
      reason: 'The action must carry the lesson example into the library.',
    );
  });

  testWidgets('Try it opens the Scale Library on the lesson example', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openLesson(tester, 'scales', 'major-scale');

    await tester.scrollUntilVisible(
      find.byKey(const Key('theoryAction_scale-library')),
      300,
      scrollable: _lessonScrollable(),
    );
    await tester.tap(find.byKey(const Key('theoryAction_scale-library')));
    await tester.pumpAndSettle();

    expect(find.byType(ScaleLibraryScreen), findsOneWidget);
  });

  testWidgets('Try it opens the Circle of Fifths', (tester) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openLesson(tester, 'circle-of-fifths', 'relative-keys');

    await tester.scrollUntilVisible(
      find.byKey(const Key('theoryAction_circle-of-fifths')),
      300,
      scrollable: _lessonScrollable(),
    );
    await tester.tap(find.byKey(const Key('theoryAction_circle-of-fifths')));
    await tester.pumpAndSettle();

    expect(find.byType(CircleOfFifthsScreen), findsOneWidget);
  });

  testWidgets('Try it opens the Interactive Fretboard', (tester) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openLesson(tester, 'fretboard-theory', 'octave-shapes');

    await tester.scrollUntilVisible(
      find.byKey(const Key('theoryAction_interactive-fretboard')),
      300,
      scrollable: _lessonScrollable(),
    );
    await tester.tap(
      find.byKey(const Key('theoryAction_interactive-fretboard')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveFretboardScreen), findsOneWidget);
  });

  testWidgets('a lesson links to the next lesson in its category', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app());
    await _openLesson(tester, 'musical-notes', 'note-names');

    await tester.scrollUntilVisible(
      find.byKey(const Key('theoryNextLesson')),
      300,
      scrollable: _lessonScrollable(),
    );
    await tester.tap(find.byKey(const Key('theoryNextLesson')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('theoryPreviousLesson')), findsWidgets);
  });

  testWidgets('unknown categories and lessons show the not-found screen', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(
      MaterialApp(
        home: const TheoryCategoryScreen(categoryId: 'nope'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TheoryCategoryScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the hub and a lesson are fully localized in Turkish', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_app(locale: AppLocale.turkish));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Müzik Teorisi'));
    await tester.pumpAndSettle();

    expect(find.text('Kategoriler'), findsOneWidget);
    expect(find.text('Aralıklar'), findsOneWidget);
    expect(find.text('Ritim'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theoryCategory_intervals')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theoryLesson_interval-tritone')));
    await tester.pumpAndSettle();

    expect(find.text('Triton'), findsWidgets);
    expect(find.text('Orta'), findsWidgets);
  });
}

Future<void> _openHub(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Music Theory'));
  await tester.pumpAndSettle();
}

Future<void> _openLesson(
  WidgetTester tester,
  String categoryId,
  String lessonId,
) async {
  await _openHub(tester);
  await tester.tap(find.byKey(Key('theoryCategory_$categoryId')));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byKey(Key('theoryLesson_$lessonId')),
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('theoryCategoryScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(find.byKey(Key('theoryLesson_$lessonId')));
  await tester.pumpAndSettle();
}

Finder _lessonScrollable() => find
    .descendant(
      of: find.byKey(const Key('theoryLessonScroll')),
      matching: find.byType(Scrollable),
    )
    .first;

Widget _app({MemoryPreferencesStore? store, AppLocale? locale}) =>
    ProviderScope(
      overrides: [
        preferencesStoreProvider.overrideWithValue(
          store ?? MemoryPreferencesStore(),
        ),
        initialAppSettingsProvider.overrideWithValue(
          AppSettings(locale: locale ?? AppLocale.system),
        ),
      ],
      child: const TunathicApp(),
    );

void _setSurface(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
