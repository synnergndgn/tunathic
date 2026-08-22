import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_preferences.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';

import 'support/fakes.dart';

void main() {
  const dashboardLayouts = <({double width, double cardWidth})>[
    (width: 360, cardWidth: 328),
    (width: 412, cardWidth: 380),
    (width: 600, cardWidth: 276),
    (width: 900, cardWidth: 278.67),
    (width: 1280, cardWidth: 280),
  ];

  for (final layout in dashboardLayouts) {
    testWidgets('dashboard adapts at ${layout.width.toInt()} logical pixels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(layout.width, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      final firstToolModule = tester.getSize(
        find.byKey(const Key('dashboardTool-music-theory')),
      );
      expect(firstToolModule.width, closeTo(layout.cardWidth, 0.1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Settings displays injected version and opens About and Privacy',
    (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('openSettings')));
      await tester.pumpAndSettle();

      await _reveal(
        tester,
        find.byKey(const Key('settingsVersion')),
        'settingsScroll',
      );
      expect(find.text('9.8.7+42'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settingsAbout')));
      await tester.pumpAndSettle();
      expect(find.text('Tunathic – Guitar Toolkit'), findsOneWidget);
      await _reveal(
        tester,
        find.byKey(const Key('aboutVersion')),
        'aboutScroll',
      );
      expect(find.byKey(const Key('aboutVersion')), findsOneWidget);
      expect(find.text('9.8.7+42'), findsOneWidget);

      await _reveal(
        tester,
        find.byKey(const Key('aboutPrivacy')),
        'aboutScroll',
      );
      await tester.tap(find.byKey(const Key('aboutPrivacy')));
      await tester.pumpAndSettle();
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Your songs stay on this device'), findsOneWidget);
      await _reveal(
        tester,
        find.text('Microphone pitch analysis stays local'),
        'privacyScroll',
      );
      expect(
        find.text('Microphone pitch analysis stays local'),
        findsOneWidget,
      );
      await _reveal(
        tester,
        find.text('No accounts, ads, analytics, or backend'),
        'privacyScroll',
      );
      expect(
        find.text('No accounts, ads, analytics, or backend'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Settings opens Flutter standard license page', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();
    await _reveal(
      tester,
      find.byKey(const Key('settingsLicenses')),
      'settingsScroll',
    );

    await tester.tap(find.byKey(const Key('settingsLicenses')));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.text('Tunathic – Guitar Toolkit'), findsOneWidget);
  });

  testWidgets('About and Privacy remain usable on narrow large-text layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();
    await _reveal(
      tester,
      find.byKey(const Key('settingsAbout')),
      'settingsScroll',
    );
    await tester.tap(find.byKey(const Key('settingsAbout')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await _reveal(tester, find.byKey(const Key('aboutPrivacy')), 'aboutScroll');
    await tester.tap(find.byKey(const Key('aboutPrivacy')));
    await tester.pumpAndSettle();
    expect(find.text('Privacy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings edits the reference pitch and stores it', (
    tester,
  ) async {
    final store = MemoryPreferencesStore();
    await tester.pumpWidget(_testApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();

    await _reveal(
      tester,
      find.byKey(const Key('tunerReferenceSelector')),
      'settingsScroll',
    );
    expect(find.text('A4 = 440 Hz'), findsWidgets);

    await tester.tap(find.byKey(const Key('tunerReferenceDecrease')));
    await tester.pumpAndSettle();

    expect(find.text('A4 = 439 Hz'), findsWidgets);
    expect(
      store.values[TuningReferencePreferences.referenceKey],
      isNotNull,
      reason: 'the choice has to survive a restart',
    );
    expect(
      TuningReference.parse(
        store.values[TuningReferencePreferences.referenceKey],
      ).a4FrequencyHz,
      439,
    );

    await tester.tap(find.byKey(const Key('tunerReferenceReset')));
    await tester.pumpAndSettle();

    expect(find.text('A4 = 440 Hz'), findsWidgets);
    expect(
      TuningReference.parse(
        store.values[TuningReferencePreferences.referenceKey],
      ),
      TuningReference.standard,
    );
  });
}

/// Scrolls [finder] into view and settles, so a following tap hits the widget
/// where it actually ended up.
Future<void> _reveal(
  WidgetTester tester,
  Finder finder,
  String scrollKey,
) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: _scrollableInside(scrollKey),
  );
  await tester.pumpAndSettle();
}

Finder _scrollableInside(String key) => find
    .descendant(of: find.byKey(Key(key)), matching: find.byType(Scrollable))
    .first;

Widget _testApp({MemoryPreferencesStore? store}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(
        store ?? MemoryPreferencesStore(),
      ),
      initialAppSettingsProvider.overrideWithValue(const AppSettings()),
      initialApplicationInfoProvider.overrideWithValue(
        const ApplicationInfo(version: '9.8.7', buildNumber: '42'),
      ),
      hapticFeedbackOutputProvider.overrideWithValue(
        FakeHapticFeedbackOutput(),
      ),
    ],
    child: const TunathicApp(),
  );
}
