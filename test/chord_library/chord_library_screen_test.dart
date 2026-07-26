import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('dashboard opens the available Chord Library', (tester) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chord Library'));
    await tester.pumpAndSettle();

    expect(find.byType(ChordLibraryScreen), findsOneWidget);
    expect(find.byKey(const Key('chordSymbol')), findsOneWidget);
    expect(find.text('C  ·  E  ·  G'), findsOneWidget);
    expect(find.byKey(const Key('chordDiagramCanvas')), findsOneWidget);
  });

  testWidgets('root and quality browsing updates symbol, tones, and shapes', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('root-Bb')));
    await tester.pump();
    expect(find.text('Bb'), findsWidgets);
    expect(find.text('Bb  ·  D  ·  F'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chordQualitySelector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minor 7 · Seventh chords').last);
    await tester.pumpAndSettle();

    expect(find.text('Bbm7'), findsOneWidget);
    expect(find.text('Bb  ·  Db  ·  F  ·  Ab'), findsOneWidget);
    expect(find.byKey(const Key('chordDiagramCanvas')), findsOneWidget);
  });

  testWidgets('alternate guitar shape selection replaces the diagram', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('diagram-c-major-open')), findsOneWidget);
    await tester.tap(find.byKey(const Key('shapeChoice-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('diagram-c-major-open')), findsNothing);
    expect(
      find.byKey(const ValueKey('diagram-c-major-e-shape-8')),
      findsOneWidget,
    );
    expect(find.text('Starting fret 8'), findsWidgets);
  });

  testWidgets(
    'exact local search selects supported chords and rejects others',
    (tester) async {
      _setSurface(tester, 600, 1200);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('chordSearchField')), 'F#m');
      await tester.tap(find.byKey(const Key('submitChordSearch')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('chordSymbol'))).data,
        'F#m',
      );
      expect(find.text('F#  ·  A  ·  C#'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('chordSearchField')),
        'C7alt',
      );
      await tester.tap(find.byKey(const Key('submitChordSearch')));
      await tester.pump();
      expect(
        find.text('Enter a supported chord symbol such as Cmaj7 or F#m.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'previously uncovered minor-major seventh now has a validated shape',
    (tester) async {
      _setSurface(tester, 600, 1200);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chordSearchField')),
        'Cm(maj7)',
      );
      await tester.tap(find.byKey(const Key('submitChordSearch')));
      await tester.pump();

      expect(
        tester.widget<Text>(find.byKey(const Key('chordSymbol'))).data,
        'Cm(maj7)',
      );
      expect(find.text('C  ·  Eb  ·  G  ·  B'), findsOneWidget);
      expect(find.byKey(const Key('noChordShapeTitle')), findsNothing);
      expect(find.byKey(const Key('chordDiagramCanvas')), findsOneWidget);
    },
  );

  testWidgets('exact search covers representative extended chord symbols', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    const examples = {
      'Ebmaj9': 'Ebmaj9',
      'C#m7b5': 'C#m7b5',
      'Bb13': 'Bb13',
      'F#mMaj7': 'F#m(maj7)',
      'Ab9': 'Ab9',
      'Dm11': 'Dm11',
    };
    for (final entry in examples.entries) {
      await tester.enterText(
        find.byKey(const Key('chordSearchField')),
        entry.key,
      );
      await tester.tap(find.byKey(const Key('submitChordSearch')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('chordSymbol'))).data,
        entry.value,
      );
      expect(find.byKey(const Key('chordDiagramCanvas')), findsOneWidget);
      expect(find.byKey(const Key('noChordShapeTitle')), findsNothing);
    }
  });

  testWidgets('high-position extension and barre metadata render', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chordSearchField')), 'Ebmaj9');
    await tester.tap(find.byKey(const Key('submitChordSearch')));
    await tester.pump();

    expect(find.text('Starting fret 11'), findsWidgets);
    expect(find.textContaining('Barre at fret 11'), findsOneWidget);
    expect(find.textContaining('Intermediate'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('intentional omissions are visible and included in semantics', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chordSearchField')), 'C7');
    await tester.tap(find.byKey(const Key('submitChordSearch')));
    await tester.pump();

    expect(find.text('Intentionally omitted: P5.'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('C7 guitar chord diagram.*omitted: P5')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Turkish localizes controls, quality names, and fingering', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp(locale: const Locale('tr')));
    await tester.pumpAndSettle();

    expect(find.text('Akor Kütüphanesi'), findsOneWidget);
    expect(find.text('Kök nota'), findsOneWidget);
    expect(find.text('Akor niteliği'), findsOneWidget);
    expect(find.text('Akor sesleri'), findsOneWidget);
    expect(find.textContaining('Açık pozisyon'), findsWidgets);
    expect(find.textContaining('Kalın Mi teli:'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('chordSearchField')), 'C7');
    await tester.tap(find.byKey(const Key('submitChordSearch')));
    await tester.pump();
    expect(find.text('Bilinçli olarak atlanan sesler: P5.'), findsOneWidget);
  });

  testWidgets('diagram exposes one useful screen-reader description', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        RegExp(
          'C guitar chord diagram.*Low E string muted.*'
          'A string fret 3, finger 3.*High E string open',
        ),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('light and dark themes render the project-owned diagram', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_screenApp(themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chordDiagramCanvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  const widths = [360.0, 412.0, 600.0, 900.0, 1280.0];
  for (final width in widths) {
    testWidgets('layout remains usable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      _setSurface(tester, width, 1200);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('fingeringDetails')),
        300,
        scrollable: _screenScrollable(),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chordDiagramCanvas')), findsOneWidget);
      expect(find.byKey(const Key('fingeringDetails')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('narrow two-times text layout remains scrollable', (
    tester,
  ) async {
    _setSurface(tester, 360, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('fingeringDetails')),
      250,
      scrollable: _screenScrollable(),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fingeringDetails')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _fullApp() {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(const AppSettings()),
    ],
    child: const TunathicApp(),
  );
}

Widget _screenApp({
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: const ChordLibraryScreen(),
  );
}

void _setSurface(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Finder _screenScrollable() => find
    .descendant(
      of: find.byKey(const Key('chordLibraryScroll')),
      matching: find.byType(Scrollable),
    )
    .first;
