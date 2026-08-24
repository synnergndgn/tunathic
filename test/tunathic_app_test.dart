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
  testWidgets('dashboard groups available tools and hides future tools', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Guitar toolkit'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Theory and Reference'), findsOneWidget);
    expect(find.text('Training'), findsNothing);
    expect(find.text('Guitar Tuner'), findsOneWidget);
    expect(find.text('Interactive Fretboard'), findsOneWidget);
    expect(find.text('Circle of Fifths'), findsOneWidget);
    expect(find.text('Music Theory'), findsOneWidget);
    expect(find.text('Repertoire'), findsOneWidget);
    expect(find.text('Capo Calculator'), findsNothing);
    expect(find.text('Chord Finder'), findsNothing);
    expect(find.text('Ear Training'), findsNothing);
    // The learning hub describes itself instead of reporting availability.
    expect(
      find.text('Learn music theory from beginner to advanced.'),
      findsOneWidget,
    );
    // The tuner leads with "Start tuning", the three practice tools on the
    // dock carry no caption, and the learning hub describes itself.
    expect(find.text('Open tool'), findsNWidgets(4));
    expect(find.text('Coming Soon'), findsNothing);
  });

  testWidgets('tuner card opens the production Guitar Tuner', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();

    expect(find.text('Guitar Tuner'), findsOneWidget);
    // Opening the tuner is the request to listen; transport controls stay out
    // of the focused instrument surface.
    expect(find.byKey(const Key('startGuitarTuner')), findsNothing);
    expect(find.byKey(const Key('stopGuitarTuner')), findsNothing);
    expect(find.byKey(const Key('openTuningSettings')), findsOneWidget);

    await tester.tap(find.byKey(const Key('openTuningSettings')));
    await tester.pumpAndSettle();
    expect(find.text('Tuning settings'), findsOneWidget);
    expect(find.text('Real-Time Pitch Diagnostic'), findsNothing);
  });

  testWidgets('the tuner listens on arrival and releases the microphone on '
      'the way out', (tester) async {
    final audioInput = FakeTunerAudioInput();
    await tester.pumpWidget(_testApp(audioInput: audioInput));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();
    expect(audioInput.startCount, 1, reason: 'exactly one capture session');

    await tester.pageBack();
    await tester.pumpAndSettle();
    // Closing the microphone is the tail of the provider teardown, and it
    // finishes outside the fake clock.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(audioInput.stopCount, greaterThan(0));

    // Coming back opens one new session rather than stacking a second.
    await tester.tap(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();
    expect(audioInput.startCount, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('future tools remain hidden from the dashboard', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Guitar toolkit'), findsOneWidget);
    expect(find.text('Ear Training'), findsNothing);
    expect(find.text('Chord Finder'), findsNothing);
    expect(find.text('Capo Calculator'), findsNothing);
    expect(find.text('Coming Soon'), findsNothing);
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
    expect(find.text('Eğitim'), findsNothing);
    expect(find.text('Gitar Akort Cihazı'), findsOneWidget);
    expect(find.text('Etkileşimli Klavye'), findsOneWidget);
    expect(find.text('Beşliler Çemberi'), findsOneWidget);
    expect(find.text('Müzik Teorisi'), findsOneWidget);
    expect(find.text('Repertuar'), findsOneWidget);
    expect(
      find.text('Müzik teorisini başlangıçtan ileri seviyeye öğren.'),
      findsOneWidget,
    );
    expect(find.text('Aracı aç'), findsNWidgets(4));
    expect(find.text('Yakında'), findsNothing);
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

Widget _testApp({
  AppSettings settings = const AppSettings(),
  FakeTunerAudioInput? audioInput,
}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(settings),
      tunerAudioInputFactoryProvider.overrideWithValue(
        () => audioInput ?? FakeTunerAudioInput(),
      ),
    ],
    child: const TunathicApp(),
  );
}
