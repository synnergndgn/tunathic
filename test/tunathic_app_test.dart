import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';

import 'support/fakes.dart';
import 'support/tuner_audio_fakes.dart';

void main() {
  testWidgets(
    'dashboard groups every tool and emphasizes the two available tools',
    (tester) async {
      _useTallSurface(tester);
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.text('Guitar toolkit'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Theory and Reference'), findsOneWidget);
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Guitar Tuner'), findsOneWidget);
      expect(find.text('Capo Calculator'), findsOneWidget);
      expect(find.text('Open tool'), findsNWidgets(2));
      expect(find.text('Coming Soon'), findsNWidgets(8));
    },
  );

  testWidgets('tuner card opens the clearly labeled audio prototype', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();

    expect(find.text('Tuner Audio Prototype'), findsOneWidget);
    expect(find.textContaining('not a working guitar tuner'), findsOneWidget);
  });

  testWidgets('Turkish is available as an application locale', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      _testApp(settings: const AppSettings(locale: AppLocale.turkish)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gitar araç seti'), findsOneWidget);
    expect(find.text('Pratik'), findsOneWidget);
    expect(find.text('Teori ve Başvuru'), findsOneWidget);
    expect(find.text('Eğitim'), findsOneWidget);
    expect(find.text('Gitar Akort Cihazı'), findsOneWidget);
    expect(find.text('Aracı aç'), findsNWidgets(2));
    expect(find.text('Yakında'), findsNWidgets(8));
  });
}

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _testApp({AppSettings settings = const AppSettings()}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(settings),
      tunerAudioInputFactoryProvider.overrideWithValue(FakeTunerAudioInput.new),
    ],
    child: const TunathicApp(),
  );
}
