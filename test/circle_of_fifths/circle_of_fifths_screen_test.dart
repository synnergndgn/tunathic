import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/chord_library/presentation/chord_library_screen.dart';
import 'package:tunathic/features/circle_of_fifths/presentation/circle_of_fifths_screen.dart';
import 'package:tunathic/features/fretboard/presentation/interactive_fretboard_screen.dart';
import 'package:tunathic/features/scale_library/presentation/scale_library_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('dashboard opens Circle of Fifths with C Major defaults', (
    tester,
  ) async {
    _setSurface(tester, 600, 1600);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Circle of Fifths'));
    await tester.pumpAndSettle();

    expect(find.byType(CircleOfFifthsScreen), findsOneWidget);
    expect(_keyText(tester, 'selectedKeyName'), 'C Major');
    expect(_keyText(tester, 'keySignatureDescription'), 'No sharps or flats');
    expect(_chordText(tester, 'triad-1'), contains('I'));
    expect(_chordText(tester, 'triad-1'), contains('C'));
    expect(_chordText(tester, 'seventh-7'), contains('viiø7'));
    expect(_chordText(tester, 'seventh-7'), contains('Bm7b5'));
  });

  testWidgets('major selection updates signature, relationships, and harmony', (
    tester,
  ) async {
    _setSurface(tester, 600, 1600);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('circleMajor-2')));
    await tester.pump();

    expect(_keyText(tester, 'selectedKeyName'), 'D Major');
    expect(_keyText(tester, 'keySignatureDescription'), '2 sharps');
    expect(_keyText(tester, 'alteredNotes'), 'F# · C#');
    expect(_relationshipText(tester, 'relativeKey'), contains('B Minor'));
    expect(_relationshipText(tester, 'fifthNeighbor'), contains('A Major'));
    expect(_relationshipText(tester, 'fourthNeighbor'), contains('G Major'));
    expect(_chordText(tester, 'triad-7'), contains('C#dim'));
  });

  testWidgets('minor selection derives natural-minor details immediately', (
    tester,
  ) async {
    _setSurface(tester, 600, 1600);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('circleMinor-0')));
    await tester.pump();

    expect(_keyText(tester, 'selectedKeyName'), 'A Minor');
    expect(_relationshipText(tester, 'relativeKey'), contains('C Major'));
    expect(_relationshipText(tester, 'parallelKey'), contains('A Major'));
    expect(_chordText(tester, 'triad-2'), contains('Bdim'));
    expect(_chordText(tester, 'seventh-2'), contains('iiø7'));
    expect(_chordText(tester, 'seventh-2'), contains('Bm7b5'));
  });

  testWidgets('relationship controls move naturally around the circle', (
    tester,
  ) async {
    _setSurface(tester, 600, 1600);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('fifthNeighbor')));
    await tester.pump();
    expect(_keyText(tester, 'selectedKeyName'), 'G Major');

    await tester.tap(find.byKey(const Key('fourthNeighbor')));
    await tester.pump();
    expect(_keyText(tester, 'selectedKeyName'), 'C Major');

    await tester.tap(find.byKey(const Key('relativeKey')));
    await tester.pump();
    expect(_keyText(tester, 'selectedKeyName'), 'A Minor');
  });

  testWidgets(
    'enharmonic circle position preserves F sharp and G flat context',
    (tester) async {
      _setSurface(tester, 600, 1600);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('circleMajor-6')));
      await tester.pump();
      expect(_keyText(tester, 'selectedKeyName'), 'F# Major');
      expect(_keyText(tester, 'keySignatureDescription'), '6 sharps');

      await tester.tap(find.byKey(const Key('enharmonicKeyAction')));
      await tester.pump();
      expect(_keyText(tester, 'selectedKeyName'), 'Gb Major');
      expect(_keyText(tester, 'keySignatureDescription'), '6 flats');
      expect(_keyText(tester, 'alteredNotes'), 'Bb · Eb · Ab · Db · Gb · Cb');
    },
  );

  testWidgets('View Scale opens a preconfigured Scale Library', (tester) async {
    _setSurface(tester, 900, 1600);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Circle of Fifths'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('circleMinor-0')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('circleViewScale')));
    await tester.pumpAndSettle();

    expect(find.byType(ScaleLibraryScreen), findsOneWidget);
    expect(_keyText(tester, 'scaleName'), 'A Natural Minor');
  });

  testWidgets('diatonic chord opens a preconfigured Chord Library', (
    tester,
  ) async {
    _setSurface(tester, 900, 1600);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Circle of Fifths'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('triad-2')));
    await tester.tap(find.byKey(const Key('triad-2')));
    await tester.pumpAndSettle();

    expect(find.byType(ChordLibraryScreen), findsOneWidget);
    expect(_keyText(tester, 'chordSymbol'), 'Dm');
  });

  testWidgets('View on Fretboard opens selected key in Scale mode', (
    tester,
  ) async {
    _setSurface(tester, 900, 1600);
    await tester.pumpWidget(_fullApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Circle of Fifths'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('circleMajor-1')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('circleViewFretboard')));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveFretboardScreen), findsOneWidget);
    expect(find.text('G Major'), findsWidgets);
  });

  testWidgets('English and Turkish localize key and harmony descriptions', (
    tester,
  ) async {
    _setSurface(tester, 600, 1600);
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();
    expect(find.text('Key signature'), findsOneWidget);
    expect(find.text('Diatonic chords'), findsOneWidget);
    expect(find.text('View Scale'), findsOneWidget);

    await tester.pumpWidget(_screenApp(locale: const Locale('tr')));
    await tester.pumpAndSettle();
    expect(find.text('Beşliler Çemberi'), findsOneWidget);
    expect(_keyText(tester, 'selectedKeyName'), 'C Majör');
    expect(find.text('Ton işaretleri'), findsOneWidget);
    expect(find.text('Diyatonik akorlar'), findsOneWidget);
    expect(find.text('Gamı Gör'), findsOneWidget);
  });

  testWidgets('circle exposes combined and interactive key semantics', (
    tester,
  ) async {
    _setSurface(tester, 600, 1600);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Circle of Fifths. C Major selected. Relative key A Minor. '
        'Clockwise neighbor G Major. Counter-clockwise neighbor F Major.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('C. Selected key.'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byKey(const Key('keySignatureCard')))
          .attributedLabel
          .string,
      'No sharps or flats. Altered notes: No sharps or flats.',
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('triad-2')))
          .attributedLabel
          .string,
      'ii, Dm. Opens Chord Library.',
    );
    semantics.dispose();
  });

  testWidgets('light and dark themes render the custom circle', (tester) async {
    _setSurface(tester, 900, 1600);
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_screenApp(themeMode: mode));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('circleVisualization')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  for (final width in [360.0, 412.0, 600.0, 900.0, 1280.0]) {
    testWidgets('layout remains usable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      _setSurface(tester, width, 1600);
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('circleVisualization')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('seventh-7')),
        300,
        scrollable: _screenScrollable(),
      );
      expect(find.byKey(const Key('seventh-7')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('two-times text switches to an accessible ordered layout', (
    tester,
  ) async {
    _setSurface(tester, 360, 1200);
    await tester.pumpWidget(_screenApp(textScaleFactor: 2));
    await tester.pumpAndSettle();

    await tester.drag(_screenScrollable(), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('circleAccessibleOrder')), findsOneWidget);
    expect(find.byKey(const Key('circleVisualization')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const Key('circleMinor-11')),
      300,
      scrollable: _screenScrollable(),
    );
    expect(find.byKey(const Key('circleMinor-11')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

String? _keyText(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data;

String _relationshipText(WidgetTester tester, String key) {
  final text = tester.widget<Text>(
    find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
  );
  return text.textSpan!.toPlainText();
}

String _chordText(WidgetTester tester, String key) => tester
    .widgetList<Text>(
      find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
    )
    .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
    .join(' ');

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
  double textScaleFactor = 1,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    builder: textScaleFactor == 1
        ? null
        : (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
            child: child!,
          ),
    home: const CircleOfFifthsScreen(),
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
      of: find.byKey(const Key('circleOfFifthsScroll')),
      matching: find.byType(Scrollable),
    )
    .first;
