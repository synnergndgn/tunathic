import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';

import 'support/fakes.dart';

void main() {
  testWidgets(
    'dashboard lists BPM Tap as available and other tools as coming soon',
    (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.text('Guitar toolkit'), findsOneWidget);
      expect(find.text('Guitar Tuner'), findsOneWidget);
      expect(find.text('Capo Calculator'), findsOneWidget);
      expect(find.text('Open tool'), findsOneWidget);
      expect(find.text('Coming Soon'), findsNWidgets(9));
    },
  );

  testWidgets('tool card opens its placeholder route', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();

    expect(find.text('Guitar Tuner'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);
    expect(
      find.text('Guitar Tuner is planned for a future milestone.'),
      findsOneWidget,
    );
  });

  testWidgets('Turkish is available as an application locale', (tester) async {
    await tester.pumpWidget(
      _testApp(settings: const AppSettings(locale: AppLocale.turkish)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gitar araç seti'), findsOneWidget);
    expect(find.text('Gitar Akort Cihazı'), findsOneWidget);
    expect(find.text('Aracı aç'), findsOneWidget);
    expect(find.text('Yakında'), findsNWidgets(9));
  });
}

Widget _testApp({AppSettings settings = const AppSettings()}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(settings),
    ],
    child: const TunathicApp(),
  );
}
