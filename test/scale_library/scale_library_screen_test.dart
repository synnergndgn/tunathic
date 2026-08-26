import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('dashboard opens the available Scale Library', (tester) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scale Library'));
    await tester.pumpAndSettle();

    expect(find.byType(ScaleLibraryScreen), findsOneWidget);
    expect(_keyText(tester, 'scaleName'), 'C Major');
    expect(find.byKey(const Key('scaleNotes')), findsOneWidget);
    expect(find.byKey(const Key('scaleFormula')), findsOneWidget);
  });

  testWidgets('root and scale browsing update names, notes, and formulas', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('scaleRoot-Bb')));
    await tester.pump();
    expect(_keyText(tester, 'scaleName'), 'Bb Major');
    expect(find.text('Eb'), findsWidgets);

    await tester.tap(find.byKey(const Key('scaleTypeSelector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Natural Minor · Major / Minor').last);
    await tester.pumpAndSettle();

    expect(_keyText(tester, 'scaleName'), 'Bb Natural Minor');
    expect(find.text('Db'), findsWidgets);
    expect(find.text('Ab'), findsWidgets);
    expect(find.text('b3'), findsOneWidget);
    expect(find.text('b6'), findsOneWidget);
    expect(find.text('b7'), findsOneWidget);
  });

  testWidgets('modal search shows parent major and structural mode degree', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await _search(tester, 'D Dorian');

    expect(_keyText(tester, 'scaleName'), 'D Dorian');
    expect(find.text('C'), findsWidgets);
    expect(find.text('Parent major: C Major'), findsOneWidget);
    expect(find.text('Mode 2 of the parent major scale'), findsOneWidget);
  });

  testWidgets('relative key relationship updates from the selected root', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    expect(find.text('Relative minor: A Natural Minor'), findsOneWidget);
    await _search(tester, 'A natural minor');
    expect(find.text('Relative major: C Major'), findsOneWidget);
  });

  testWidgets('exact local search preserves spelling and rejects fuzzy input', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await _search(tester, 'F# minor');
    expect(_keyText(tester, 'scaleName'), 'F# Natural Minor');
    expect(find.text('C#'), findsWidgets);

    await _search(tester, 'best scale for C');
    expect(
      find.text('Enter an exact supported scale such as C major or D Dorian.'),
      findsOneWidget,
    );
  });

  testWidgets('Turkish localizes scale names, controls, and relationships', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp(locale: const Locale('tr')));
    await tester.pumpAndSettle();

    expect(find.text('Gam Kütüphanesi'), findsOneWidget);
    expect(find.text('Kök nota'), findsOneWidget);
    expect(find.text('Gam'), findsOneWidget);
    expect(_keyText(tester, 'scaleName'), 'C Majör');
    expect(find.text('İlgili minör: A Doğal Minör'), findsOneWidget);

    await _search(tester, 'D doryen');
    expect(_keyText(tester, 'scaleName'), 'D Doryen');
    expect(find.text('Ana majör: C Majör'), findsOneWidget);
  });

  testWidgets('summary exposes one meaningful screen-reader description', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'C Major. Notes: C, E, F, G, A, B, D. '
        'Degree formula: one, two, three, four, five, six, seven.',
      ),
      findsNothing,
      reason: 'Semantics must preserve the displayed scale order.',
    );
    expect(
      find.bySemanticsLabel(
        'C Major. Notes: C, D, E, F, G, A, B. '
        'Degree formula: one, two, three, four, five, six, seven.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('light and dark themes render the scale reference', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_screenApp(themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('scaleNotes')), findsOneWidget);
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
        find.byKey(const Key('scaleRelationships')),
        250,
        scrollable: _screenScrollable(),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('scaleNotes')), findsOneWidget);
      expect(find.byKey(const Key('scaleRelationships')), findsOneWidget);
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
      find.byKey(const Key('scaleRelationships')),
      250,
      scrollable: _screenScrollable(),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scaleRelationships')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byKey(const Key('scaleSearchField')), query);
  await tester.tap(find.byKey(const Key('submitScaleSearch')));
  await tester.pumpAndSettle();
}

String? _keyText(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data;

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
    home: const ScaleLibraryScreen(),
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
      of: find.byKey(const Key('scaleLibraryScroll')),
      matching: find.byType(Scrollable),
    )
    .first;
