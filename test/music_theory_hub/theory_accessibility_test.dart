import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/features/music_theory/presentation/music_theory_screen.dart';
import 'package:tunathic/features/music_theory/presentation/theory_category_screen.dart';
import 'package:tunathic/features/music_theory/presentation/theory_lesson_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('category cards describe themselves in one sentence', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_screen(const MusicTheoryScreen()));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Intervals, 14 lessons. Every distance inside the octave, its sound, '
        'and its shape on the guitar.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('lesson tiles announce title, level, and summary', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _screen(const TheoryCategoryScreen(categoryId: 'chords')),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Triads, Beginner. Three notes, a root with a third and a fifth above '
        'it, make a chord.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('a guitar shape is described rather than left as a drawing', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _screen(const TheoryLessonScreen(lessonId: 'interval-perfect-fifth')),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        RegExp('Perfect 5th shape: root on string A2 at fret 5'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('a fretboard diagram is described rather than left silent', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _screen(const TheoryLessonScreen(lessonId: 'triads')),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Fretboard diagram for C, frets 0 to 5')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('note rows are announced as one list, not as loose fragments', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _screen(const TheoryLessonScreen(lessonId: 'major-scale')),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('Notes: C, D, E, F, G, A, B')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('favourite buttons expose a tooltip that reflects their state', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(
      _screen(const TheoryLessonScreen(lessonId: 'triads')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('theoryFavorite_triads')))
          .tooltip,
      'Add to favorites',
    );
    await tester.tap(find.byKey(const Key('theoryFavorite_triads')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('theoryFavorite_triads')))
          .tooltip,
      'Remove from favorites',
    );
  });

  testWidgets('interactive targets meet the minimum touch size', (
    tester,
  ) async {
    _setSurface(tester, 800, 1600);
    await tester.pumpWidget(_screen(const MusicTheoryScreen()));
    await tester.pumpAndSettle();

    for (final element
        in find.byKey(const Key('theoryCategory_intervals')).evaluate()) {
      final size = element.size!;
      expect(size.height, greaterThanOrEqualTo(48));
    }
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('doubled text still renders every lesson section', (
    tester,
  ) async {
    _setSurface(tester, 400, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _screen(const TheoryLessonScreen(lessonId: 'time-signatures')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('theoryLessonSummary')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const Key('theoryLessonScroll')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('light and dark themes both render the hub', (tester) async {
    _setSurface(tester, 800, 1600);
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        _screen(const MusicTheoryScreen(), themeMode: mode),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MusicTheoryScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

Widget _screen(Widget home, {ThemeMode themeMode = ThemeMode.light}) =>
    ProviderScope(
      overrides: [
        preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: home,
      ),
    );

void _setSurface(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
