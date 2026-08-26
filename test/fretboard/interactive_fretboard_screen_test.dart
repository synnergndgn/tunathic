import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/fretboard/domain/fretboard_route_state.dart';
import 'package:tunathic/features/fretboard/presentation/interactive_fretboard_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('dashboard opens Interactive Fretboard with direct defaults', (
    tester,
  ) async {
    _setSurface(tester, 600, 1800);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Interactive Fretboard'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveFretboardScreen), findsOneWidget);
    expect(_selectionName(tester), 'C');
    expect(
      find.byKey(const Key('fretboardChordQualitySelector')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('interactiveFretboardCanvas')), findsOneWidget);
  });

  testWidgets(
    'mode, root, definition, and display changes update immediately',
    (tester) async {
      _setSurface(tester, 600, 1500);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('fretboardModeSelector')),
          matching: find.text('Scale'),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('fretboardScaleSelector')), findsOneWidget);

      await tester.tap(find.byKey(const Key('fretboardRoot-Bb')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('fretboardScaleSelector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Minor Pentatonic · Pentatonic / Blues').last);
      await tester.pumpAndSettle();

      expect(_selectionName(tester), 'Bb Minor Pentatonic');

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('fretboardDisplayModeSelector')),
          matching: find.text('Degrees / intervals'),
        ),
      );
      await tester.pump();
      final painter = tester.widget<CustomPaint>(
        find.byKey(const Key('interactiveFretboardCanvas')),
      );
      expect(painter.painter.toString(), isNotEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('12 and 24 fret ranges resize a horizontally scrollable neck', (
    tester,
  ) async {
    _setSurface(tester, 360, 1000);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('fretRangeSelector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0–12').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('interactiveFretboardCanvas')),
      300,
      scrollable: _screenScrollable(),
    );
    expect(
      tester.getSize(find.byKey(const Key('interactiveFretboardCanvas'))).width,
      720,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('fretRangeSelector')),
      -300,
      scrollable: _screenScrollable(),
    );
    await tester.tap(find.byKey(const Key('fretRangeSelector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0–24').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('interactiveFretboardCanvas')),
      300,
      scrollable: _screenScrollable(),
    );
    expect(
      tester.getSize(find.byKey(const Key('interactiveFretboardCanvas'))).width,
      1344,
    );

    await tester.drag(
      find.byKey(const Key('fretboardHorizontalScroll')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('fretboardHorizontalScroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('tapping a highlighted note reveals lightweight details', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('interactiveFretboardCanvas')),
      300,
      scrollable: _screenScrollable(),
    );
    await tester.pumpAndSettle();
    final topLeft = tester.getTopLeft(
      find.byKey(const Key('interactiveFretboardCanvas')),
    );
    // High E open position in the documented player-facing orientation.
    await tester.tapAt(topLeft + const Offset(70, 58));
    await tester.pump();

    expect(find.byKey(const Key('selectedFretPosition')), findsOneWidget);
    expect(find.textContaining('E4'), findsOneWidget);
    expect(find.textContaining('High E string'), findsOneWidget);
  });

  testWidgets('Chord Library opens a prefilled theory projection', (
    tester,
  ) async {
    _setSurface(tester, 600, 1800);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chord Library'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chordSearchField')), 'F#m7');
    await tester.tap(find.byKey(const Key('submitChordSearch')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('chordViewOnFretboard')));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveFretboardScreen), findsOneWidget);
    expect(_selectionName(tester), 'F#m7');
    expect(
      find.byKey(const Key('fretboardChordQualitySelector')),
      findsOneWidget,
    );
  });

  testWidgets('Scale Library opens a prefilled theory projection', (
    tester,
  ) async {
    _setSurface(tester, 600, 1800);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scale Library'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('scaleSearchField')),
      'A minor pentatonic',
    );
    await tester.tap(find.byKey(const Key('submitScaleSearch')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('scaleViewOnFretboard')));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveFretboardScreen), findsOneWidget);
    expect(_selectionName(tester), 'A Minor Pentatonic');
    expect(find.byKey(const Key('fretboardScaleSelector')), findsOneWidget);
  });

  testWidgets('English and Turkish localize controls and accessibility', (
    tester,
  ) async {
    _setSurface(tester, 600, 1200);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();
    expect(find.text('Interactive Fretboard'), findsOneWidget);
    expect(find.text('Degrees / intervals'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'C fretboard, frets zero through 15. Root notes C highlighted. '
        'High E is at the top and low E is at the bottom.',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(_screenApp(locale: const Locale('tr')));
    await tester.pumpAndSettle();
    expect(find.text('Etkileşimli Klavye'), findsOneWidget);
    expect(find.text('Dereceler / aralıklar'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('light and dark themes render the custom fretboard', (
    tester,
  ) async {
    _setSurface(tester, 900, 1200);
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_screenApp(themeMode: mode));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('interactiveFretboardCanvas')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  for (final width in [360.0, 412.0, 600.0, 900.0, 1280.0]) {
    testWidgets('layout remains usable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      _setSurface(tester, width, 1500);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('interactiveFretboardCanvas')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('narrow large-text layout remains scrollable', (tester) async {
    _setSurface(tester, 360, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('interactiveFretboardCanvas')),
      300,
      scrollable: _screenScrollable(),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('interactiveFretboardCanvas')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

String? _selectionName(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('fretboardSelectionName'))).data;

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
  FretboardRouteState state = const FretboardRouteState(),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: InteractiveFretboardScreen(initialState: state),
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
      of: find.byKey(const Key('interactiveFretboardScroll')),
      matching: find.byType(Scrollable),
    )
    .first;
