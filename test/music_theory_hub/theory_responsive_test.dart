import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/music_theory/presentation/music_theory_screen.dart';
import 'package:tunathic/features/music_theory/presentation/theory_category_screen.dart';
import 'package:tunathic/features/music_theory/presentation/theory_lesson_screen.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';

void main() {
  const widths = [360.0, 412.0, 600.0, 900.0, 1280.0];

  for (final width in widths) {
    testWidgets('the hub is usable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      _setSurface(tester, width, 1200);
      await tester.pumpWidget(_screen(const MusicTheoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('theorySearchField')), findsOneWidget);
      expect(find.byKey(const Key('theoryLevelFilter')), findsOneWidget);
      expect(
        find.byKey(const Key('theoryCategory_musical-notes')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a lesson is readable at ${width.toInt()} logical pixels', (
      tester,
    ) async {
      _setSurface(tester, width, 1200);
      await tester.pumpWidget(
        _screen(const TheoryLessonScreen(lessonId: 'caged-system')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('theoryLessonSummary')), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('theoryLessonScroll')),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a tablet width lays categories out in more than one column', (
    tester,
  ) async {
    _setSurface(tester, 1280, 1200);
    await tester.pumpWidget(_screen(const MusicTheoryScreen()));
    await tester.pumpAndSettle();

    final first = tester.getTopLeft(
      find.byKey(const Key('theoryCategory_musical-notes')),
    );
    final second = tester.getTopLeft(
      find.byKey(const Key('theoryCategory_intervals')),
    );
    expect(
      second.dx,
      greaterThan(first.dx),
      reason: 'Wide layouts must not stack every card in one column.',
    );
  });

  testWidgets('a phone width stacks categories in one column', (tester) async {
    _setSurface(tester, 360, 1200);
    await tester.pumpWidget(_screen(const MusicTheoryScreen()));
    await tester.pumpAndSettle();

    final first = tester.getTopLeft(
      find.byKey(const Key('theoryCategory_musical-notes')),
    );
    final second = tester.getTopLeft(
      find.byKey(const Key('theoryCategory_intervals')),
    );
    expect(second.dx, first.dx);
    expect(second.dy, greaterThan(first.dy));
  });

  testWidgets('a wide fretboard diagram scrolls instead of overflowing', (
    tester,
  ) async {
    _setSurface(tester, 360, 900);
    await tester.pumpWidget(
      _screen(const TheoryLessonScreen(lessonId: 'caged-system')),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('theoryLessonScroll')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a category list survives a narrow surface with large text', (
    tester,
  ) async {
    _setSurface(tester, 320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _screen(const TheoryCategoryScreen(categoryId: 'rhythm')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('theoryLesson_bpm')), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('theoryCategoryScroll')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Widget _screen(Widget home) => ProviderScope(
  overrides: [
    preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
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
