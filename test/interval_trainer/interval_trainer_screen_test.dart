import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/interval_trainer/presentation/interval_trainer_controller.dart';
import 'package:tunathic/features/interval_trainer/presentation/interval_trainer_screen.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('dashboard opens Interval Trainer and records only one answer', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await _openTrainer(tester, 'Interval Trainer');
    await tester.pumpAndSettle();

    expect(find.byType(IntervalTrainerScreen), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(IntervalTrainerScreen)),
    );
    final answer = container
        .read(intervalTrainerProvider)
        .session
        .question
        .correctAnswer;
    final answerFinder = find.byKey(Key('intervalAnswer_$answer'));
    await _scrollTrainerUntilVisible(tester, answerFinder);
    await tester.tap(answerFinder);
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsOneWidget);
    expect(
      container.read(intervalTrainerProvider).session.questionsAnswered,
      1,
    );
    await tester.tap(find.byKey(Key('intervalAnswer_$answer')));
    await tester.pumpAndSettle();
    expect(
      container.read(intervalTrainerProvider).session.questionsAnswered,
      1,
    );

    await tester.tap(find.byKey(const Key('intervalNext')));
    await tester.pumpAndSettle();
    expect(
      container.read(intervalTrainerProvider).session.questionsAnswered,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('works in Turkish, dark mode, and narrow 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      _testApp(
        settings: const AppSettings(
          locale: AppLocale.turkish,
          themeMode: ThemeMode.dark,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _openTrainer(tester, 'Aralık Eğitimi');
    await tester.pumpAndSettle();

    expect(find.text('Aralığı Tanı'), findsOneWidget);
    await _scrollTrainerUntilVisible(
      tester,
      find.bySemanticsLabel(RegExp('Notalar')),
    );
    expect(find.bySemanticsLabel(RegExp('Notalar')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [412.0, 600.0, 900.0, 1280.0]) {
    testWidgets('remains usable at $width logical pixels', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();
      await _openTrainer(tester, 'Interval Trainer');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('intervalPrompt')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _testApp({AppSettings settings = const AppSettings()}) => ProviderScope(
  overrides: [
    preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
    initialAppSettingsProvider.overrideWithValue(settings),
    initialApplicationInfoProvider.overrideWithValue(
      const ApplicationInfo(version: '9.8.7', buildNumber: '42'),
    ),
    hapticFeedbackOutputProvider.overrideWithValue(FakeHapticFeedbackOutput()),
  ],
  child: const TunathicApp(),
);

Future<void> _openTrainer(WidgetTester tester, String title) async {
  await tester.scrollUntilVisible(
    find.text(title),
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('dashboardScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.drag(
    find
        .descendant(
          of: find.byKey(const Key('dashboardScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
    const Offset(0, -180),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _scrollTrainerUntilVisible(WidgetTester tester, Finder finder) =>
    tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('intervalTrainerScroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
