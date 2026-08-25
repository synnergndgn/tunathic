import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/app_info/application_info.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tools/tool_definition.dart';

import 'support/fakes.dart';

/// Every screen, on the narrowest phone the app supports, at double text size.
///
/// A `RenderFlex` overflow throws during a widget test, so reaching a screen
/// and finding no exception is the assertion. Each destination also has to
/// still expose its scroll view: a screen that fits by clipping its content is
/// a worse failure than one that overflows loudly, and only the scroll view
/// proves the content stayed reachable.
///
/// 320x700 is deliberate. It is the smallest width in the dashboard layout
/// table plus the shortest viewport a 16:9 phone gives after system chrome, so
/// anything that survives here survives the store's device range.
///
/// Both locales run, because Turkish is where this breaks first: its tool
/// names and section labels are the longest strings the app ships.
void main() {
  const destinations = <({ToolDefinition tool, String scrollKey})>[
    (tool: ToolDefinition.guitarTuner, scrollKey: 'guitarTunerScroll'),
    (tool: ToolDefinition.metronome, scrollKey: 'metronomeScroll'),
    (tool: ToolDefinition.bpmTap, scrollKey: 'bpmTapScroll'),
    (tool: ToolDefinition.musicTheory, scrollKey: 'musicTheoryScroll'),
    (tool: ToolDefinition.chordLibrary, scrollKey: 'chordLibraryScroll'),
    (tool: ToolDefinition.scaleLibrary, scrollKey: 'scaleLibraryScroll'),
    (
      tool: ToolDefinition.interactiveFretboard,
      scrollKey: 'interactiveFretboardScroll',
    ),
    (tool: ToolDefinition.circleOfFifths, scrollKey: 'circleOfFifthsScroll'),
  ];

  for (final locale in AppLocale.values.where((l) => l != AppLocale.system)) {
    for (final destination in destinations) {
      testWidgets(
        '${destination.tool.id} stays scrollable at 320 px, double text, '
        '${locale.languageCode}',
        (tester) async {
          _useNarrowLargeText(tester);

          await tester.pumpWidget(_testApp(locale: locale));
          await tester.pumpAndSettle();

          await _reveal(
            tester,
            find.byKey(Key('dashboardTool-${destination.tool.id}')),
            'dashboardScroll',
          );
          await tester.tap(
            find.byKey(Key('dashboardTool-${destination.tool.id}')),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(Key(destination.scrollKey)), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'the dashboard itself stays scrollable at 320 px, double text, Turkish',
    (tester) async {
      _useNarrowLargeText(tester);

      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboardScroll')), findsOneWidget);
      // The last tool in the list has to still be reachable, not clipped off.
      await _reveal(
        tester,
        find.byKey(const Key('dashboardTool-circle-of-fifths')),
        'dashboardScroll',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'repertoire shows its empty state at 320 px, double text, Turkish',
    (tester) async {
      _useNarrowLargeText(tester);

      await tester.pumpWidget(_testApp(locale: AppLocale.turkish));
      await tester.pumpAndSettle();

      await _reveal(
        tester,
        find.byKey(const Key('dashboardTool-repertoire')),
        'dashboardScroll',
      );
      await tester.tap(find.byKey(const Key('dashboardTool-repertoire')));
      await tester.pumpAndSettle();

      // With no songs there is no list to scroll, so the empty state's own call
      // to action is what has to survive the layout.
      expect(find.byKey(const Key('addSong')), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('settings survives 320 px, double text, Turkish', (tester) async {
    _useNarrowLargeText(tester);

    await tester.pumpWidget(_testApp(locale: AppLocale.turkish));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsScroll')), findsOneWidget);
    await _reveal(
      tester,
      find.byKey(const Key('settingsVersion')),
      'settingsScroll',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tuning settings survives 320 px, double text, Turkish', (
    tester,
  ) async {
    _useNarrowLargeText(tester);

    await tester.pumpWidget(_testApp(locale: AppLocale.turkish));
    await tester.pumpAndSettle();

    await _reveal(
      tester,
      find.byKey(const Key('dashboardTool-guitar-tuner')),
      'dashboardScroll',
    );
    await tester.tap(find.byKey(const Key('dashboardTool-guitar-tuner')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openTuningSettings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tuningSettingsScroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _useNarrowLargeText(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 700);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _reveal(
  WidgetTester tester,
  Finder finder,
  String scrollKey,
) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byKey(Key(scrollKey)),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Widget _testApp({AppLocale locale = AppLocale.english}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(AppSettings(locale: locale)),
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
