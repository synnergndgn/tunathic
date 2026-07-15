import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

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

      final firstToolCard = tester.getSize(find.byType(Card).first);
      expect(firstToolCard.width, closeTo(layout.cardWidth, 0.1));
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

      await tester.scrollUntilVisible(
        find.byKey(const Key('settingsVersion')),
        240,
        scrollable: _scrollableInside('settingsScroll'),
      );
      expect(find.text('9.8.7+42'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settingsAbout')));
      await tester.pumpAndSettle();
      expect(find.text('Tunathic – Guitar Toolkit'), findsOneWidget);
      expect(find.byKey(const Key('aboutVersion')), findsOneWidget);
      expect(find.text('Version: 9.8.7+42'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('aboutPrivacy')),
        220,
        scrollable: _scrollableInside('aboutScroll'),
      );
      await tester.tap(find.byKey(const Key('aboutPrivacy')));
      await tester.pumpAndSettle();
      expect(find.text('Privacy'), findsOneWidget);
      expect(
        find.text('Microphone pitch analysis stays local'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('No accounts, ads, analytics, or backend'),
        220,
        scrollable: _scrollableInside('privacyScroll'),
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settingsLicenses')),
      240,
      scrollable: _scrollableInside('settingsScroll'),
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
    await tester.drag(
      _scrollableInside('settingsScroll'),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('settingsAbout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settingsAbout')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (var index = 0; index < 3; index++) {
      await tester.drag(
        _scrollableInside('aboutScroll'),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.byKey(const Key('aboutPrivacy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aboutPrivacy')));
    await tester.pumpAndSettle();
    expect(find.text('Privacy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _scrollableInside(String key) => find
    .descendant(of: find.byKey(Key(key)), matching: find.byType(Scrollable))
    .first;

Widget _testApp() {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
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
