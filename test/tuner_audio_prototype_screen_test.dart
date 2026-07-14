import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner_audio/audio/tuner_audio_input.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';

import 'support/fakes.dart';
import 'support/tuner_audio_fakes.dart';

void main() {
  testWidgets('shows a clear prototype warning and privacy explanation', (
    tester,
  ) async {
    final audioInput = FakeTunerAudioInput();
    await tester.pumpWidget(_testApp(audioInput));
    await _openPrototype(tester);

    expect(find.text('Tuner Audio Prototype'), findsOneWidget);
    expect(
      find.text(
        'Technical prototype only. This validates microphone input and is not '
        'a working guitar tuner.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Private by design'),
      300,
      scrollable: _scrollableInside('tunerAudioScroll'),
    );
    expect(find.text('Private by design'), findsOneWidget);
    expect(find.textContaining('Raw microphone data'), findsOneWidget);
    expect(find.textContaining('Detected note'), findsNothing);
    expect(find.textContaining('Detected frequency'), findsNothing);
    expect(find.byKey(const Key('tunerNeedle')), findsNothing);
  });

  testWidgets('shows friendly permission-denied UI with explicit retry', (
    tester,
  ) async {
    final audioInput = FakeTunerAudioInput()
      ..permission = MicrophonePermissionResult.denied;
    await tester.pumpWidget(_testApp(audioInput));
    await _openPrototype(tester);

    await tester.tap(find.byKey(const Key('startTunerAudioCapture')));
    await tester.pumpAndSettle();

    expect(find.text('Denied'), findsOneWidget);
    expect(find.textContaining('Start again only if you want'), findsOneWidget);
    expect(find.byKey(const Key('startTunerAudioCapture')), findsOneWidget);
    expect(audioInput.startCount, 0);
  });

  testWidgets('start, statistics, and stop render from fake PCM frames', (
    tester,
  ) async {
    final audioInput = FakeTunerAudioInput();
    await tester.pumpWidget(_testApp(audioInput));
    await _openPrototype(tester);

    await tester.tap(find.byKey(const Key('startTunerAudioCapture')));
    await tester.pumpAndSettle();
    expect(find.text('Capturing'), findsOneWidget);

    audioInput.emitSamples([0.5, -0.5], arrivalTime: Duration.zero);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('tunerFramesValue')),
      240,
      scrollable: _scrollableInside('tunerAudioScroll'),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('tunerFramesValue')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('tunerSamplesValue')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(find.text('-6.0 dBFS'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('stopTunerAudioCapture')),
      -240,
      scrollable: _scrollableInside('tunerAudioScroll'),
    );
    await tester.ensureVisible(find.byKey(const Key('stopTunerAudioCapture')));
    await tester.pumpAndSettle();
    final stopButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('stopTunerAudioCapture')),
    );
    expect(stopButton.onPressed, isNotNull);
    await tester.runAsync(() async {
      stopButton.onPressed!();
      for (var index = 0; index < 8 && audioInput.stopCount == 0; index++) {
        await Future<void>.delayed(Duration.zero);
      }
    });
    await tester.pump();
    expect(audioInput.stopCount, 1);
    final startButton = tester.widget<FilledButton>(
      find.byKey(const Key('startTunerAudioCapture')),
    );
    expect(startButton.onPressed, isNotNull);
  });

  testWidgets('prototype content is localized in Turkish', (tester) async {
    final audioInput = FakeTunerAudioInput();
    await tester.pumpWidget(
      _testApp(
        audioInput,
        settings: const AppSettings(locale: AppLocale.turkish),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gitar Akort Cihazı'));
    await tester.pumpAndSettle();

    expect(find.text('Akort Ses Prototipi'), findsOneWidget);
    expect(find.text('Yakalamayı başlat'), findsOneWidget);
    expect(find.text('Mikrofon izni'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Gizlilik odaklı'),
      300,
      scrollable: _scrollableInside('tunerAudioScroll'),
    );
    expect(find.text('Gizlilik odaklı'), findsOneWidget);
  });

  testWidgets('narrow large-text layout remains scrollable without overflow', (
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

    final audioInput = FakeTunerAudioInput();
    await tester.pumpWidget(_testApp(audioInput));
    await tester.pumpAndSettle();
    await tester.drag(
      _scrollableInside('dashboardScroll'),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guitar Tuner'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Foreground capture only'),
      500,
      scrollable: _scrollableInside('tunerAudioScroll'),
      maxScrolls: 20,
    );
    expect(find.text('Foreground capture only'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openPrototype(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Guitar Tuner'));
  await tester.pumpAndSettle();
}

Finder _scrollableInside(String key) => find
    .descendant(of: find.byKey(Key(key)), matching: find.byType(Scrollable))
    .first;

Widget _testApp(
  FakeTunerAudioInput audioInput, {
  AppSettings settings = const AppSettings(),
}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(settings),
      tunerAudioInputFactoryProvider.overrideWithValue(() => audioInput),
      stopMetronomeBeforeCaptureProvider.overrideWithValue(() async {}),
      hapticFeedbackOutputProvider.overrideWithValue(
        FakeHapticFeedbackOutput(),
      ),
    ],
    child: const TunathicApp(),
  );
}
