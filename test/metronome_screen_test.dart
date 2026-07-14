import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_controller.dart';
import 'package:tunathic/features/metronome/application/metronome_controller.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

import 'support/fakes.dart';
import 'support/metronome_fakes.dart';

void main() {
  testWidgets('dashboard metronome controls start, adjust, select, and reset', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final audio = FakeMetronomeAudioOutput();
    final scheduler = FakeMetronomeScheduler();
    await tester.pumpWidget(_testApp(audio: audio, scheduler: scheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('metronomeBpm')), findsOneWidget);
    expect(find.bySemanticsLabel('120 beats per minute'), findsWidgets);
    expect(find.byTooltip('Decrease tempo'), findsOneWidget);
    expect(find.byTooltip('Increase tempo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('incrementTempo')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('metronomeBpm'))).data,
      '121',
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('metronomeStartStop')),
      220,
      scrollable: _scrollableInside('metronomeScroll'),
    );
    expect(find.text('Start'), findsOneWidget);
    expect(find.bySemanticsLabel('Start'), findsWidgets);

    await tester.tap(find.byKey(const Key('metronomeStartStop')));
    await tester.pumpAndSettle();
    expect(find.text('Stop'), findsOneWidget);

    scheduler.fire();
    await tester.pump();
    expect(audio.plays.single.accented, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const Key('signature-3/4')),
      180,
      scrollable: _scrollableInside('metronomeScroll'),
    );
    await tester.tap(find.byKey(const Key('signature-3/4')));
    await tester.pump();
    final threeFour = tester.widget<ChoiceChip>(
      find.byKey(const Key('signature-3/4')),
    );
    expect(threeFour.selected, isTrue);

    await tester.tap(find.byKey(const Key('metronomeReset')));
    await tester.pumpAndSettle();

    final fourFour = tester.widget<ChoiceChip>(
      find.byKey(const Key('signature-4/4')),
    );
    expect(fourFour.selected, isTrue);
    expect(scheduler.isRunning, isFalse);

    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('metronome renders in Turkish on a scaled phone layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      _testApp(
        audio: FakeMetronomeAudioOutput(),
        scheduler: FakeMetronomeScheduler(),
        settings: const AppSettings(locale: AppLocale.turkish),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      _scrollableInside('dashboardScroll'),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metronom'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Tempoyu azalt'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('metronomeStartStop')),
      220,
      scrollable: _scrollableInside('metronomeScroll'),
    );
    expect(find.text('Başlat'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('BPM Tap result is returned and applied to the metronome', (
    tester,
  ) async {
    var elapsed = Duration.zero;
    await tester.pumpWidget(
      _testApp(
        audio: FakeMetronomeAudioOutput(),
        scheduler: FakeMetronomeScheduler(),
        initialConfig: const MetronomeConfig(bpm: 90),
        elapsedTime: () => elapsed,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('openBpmTapFromMetronome')),
      220,
      scrollable: _scrollableInside('metronomeScroll'),
    );
    await tester.tap(find.byKey(const Key('openBpmTapFromMetronome')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();
    elapsed = const Duration(milliseconds: 500);
    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();
    elapsed = const Duration(seconds: 1);
    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();

    expect(find.text('120'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('applyBpmTapResult')),
      160,
      scrollable: _scrollableInside('bpmTapScroll'),
    );
    await tester.tap(find.byKey(const Key('applyBpmTapResult')));
    await tester.pumpAndSettle();

    await tester.drag(
      _scrollableInside('metronomeScroll'),
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('metronomeBpm'))).data,
      '120',
    );
    expect(find.text('Applied 120 BPM to the metronome.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('navigating back stops and releases a running metronome', (
    tester,
  ) async {
    final audio = FakeMetronomeAudioOutput();
    final scheduler = FakeMetronomeScheduler();
    await tester.pumpWidget(_testApp(audio: audio, scheduler: scheduler));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metronome'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('metronomeStartStop')),
      220,
      scrollable: _scrollableInside('metronomeScroll'),
    );
    await tester.tap(find.byKey(const Key('metronomeStartStop')));
    await tester.pumpAndSettle();
    expect(scheduler.isRunning, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(scheduler.isRunning, isFalse);
    expect(audio.disposeCount, greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox());
  });
}

Finder _scrollableInside(String key) => find
    .descendant(of: find.byKey(Key(key)), matching: find.byType(Scrollable))
    .first;

Widget _testApp({
  required FakeMetronomeAudioOutput audio,
  required FakeMetronomeScheduler scheduler,
  AppSettings settings = const AppSettings(),
  MetronomeConfig initialConfig = const MetronomeConfig(),
  Duration Function()? elapsedTime,
}) {
  return ProviderScope(
    overrides: [
      preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
      initialAppSettingsProvider.overrideWithValue(settings),
      initialMetronomeConfigProvider.overrideWithValue(initialConfig),
      metronomeAudioOutputProvider.overrideWithValue(audio),
      metronomeSchedulerProvider.overrideWithValue(scheduler),
      if (elapsedTime != null)
        bpmTapElapsedTimeProvider.overrideWithValue(elapsedTime),
    ],
    child: const TunathicApp(),
  );
}
