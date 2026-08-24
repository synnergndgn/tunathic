import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/application/tuner_preferences.dart';
import 'package:tunathic/features/tuner/domain/chromatic_tuner_engine.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/presentation/guitar_tuner_screen.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';
import 'package:tunathic/l10n/app_localizations.dart';

void main() {
  testWidgets('quiet and no-signal states stay visually neutral', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.waitingForSignal, capturing: true)),
    );

    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('No signal'), findsNothing);
    expect(find.textContaining('Play one note'), findsNothing);
    expect(find.byKey(const Key('stopGuitarTuner')), findsNothing);

    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.noSignal, capturing: true)),
    );
    await tester.pump();

    expect(find.textContaining('No signal'), findsNothing);
    expect(find.byKey(const Key('tunerDetectedOctave')), findsNothing);
    expect(find.byKey(const Key('tunerCentsIndicator')), findsOneWidget);
  });

  testWidgets('permission failure remains visible and retryable', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      _app(
        _state(signal: TunerSignalState.permissionDenied),
        onResume: () => retried = true,
      ),
    );

    await _reveal(tester, find.text('Microphone permission required'));
    expect(find.text('Microphone permission required'), findsOneWidget);
    expect(find.byKey(const Key('retryGuitarTunerMicrophone')), findsOneWidget);
    await tester.tap(find.byKey(const Key('retryGuitarTunerMicrophone')));
    expect(retried, isTrue);
  });

  testWidgets('stable pitch shows note, cents and frequency', (tester) async {
    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          pitch: _pitch(110, 'A', 2),
          target: TuningPresets.standard.stringAt(5),
          cents: 0,
          accuracy: TunerAccuracy.inTune,
          direction: TunerDirection.inTune,
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('+0 cents'), findsOneWidget);
    expect(find.text('110.0 Hz'), findsOneWidget);
    expect(find.byKey(const Key('stopGuitarTuner')), findsNothing);
  });

  testWidgets('top control only exposes automatic and manual modes', (
    tester,
  ) async {
    TunerMode? selectedMode;
    await tester.pumpWidget(
      _app(
        _state(mode: TunerMode.automatic),
        onMode: (mode) => selectedMode = mode,
      ),
    );

    expect(find.byKey(const Key('tunerAutoManualToggle')), findsOneWidget);
    expect(find.text('Automatic'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('Chromatic'), findsNothing);
    await tester.tap(find.byKey(const Key('tunerManualMode')));
    expect(selectedMode, TunerMode.manual);
  });

  testWidgets('manual mode exposes a compact target-string selector', (
    tester,
  ) async {
    int? selectedString;
    await tester.pumpWidget(
      _app(
        _state(mode: TunerMode.manual),
        onString: (position) => selectedString = position,
      ),
    );

    await _reveal(tester, find.byKey(const Key('tunerString3')));
    await tester.tap(find.byKey(const Key('tunerString3')));
    expect(selectedString, 3);
  });

  testWidgets('chromatic mode hides target and preset controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _state(
          mode: TunerMode.chromatic,
          signal: TunerSignalState.stablePitch,
          capturing: true,
          pitch: _pitch(329.63, 'E', 4),
          cents: -7,
          accuracy: TunerAccuracy.near,
          direction: TunerDirection.flat,
        ),
      ),
    );

    expect(find.text('E'), findsOneWidget);
    expect(find.text('329.6 Hz'), findsOneWidget);
    expect(find.byKey(const Key('tunerString3')), findsNothing);
    expect(find.text('Target pending'), findsNothing);
  });

  testWidgets('settings action is always available', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      _app(_state(), onOpenSettings: () => opened = true),
    );

    await tester.tap(find.byKey(const Key('openTuningSettings')));
    expect(opened, isTrue);
  });

  testWidgets('production controls are localized in Turkish', (tester) async {
    await tester.pumpWidget(
      _app(_state(mode: TunerMode.manual), locale: const Locale('tr')),
    );

    expect(find.text('Gitar Akort Cihazı'), findsOneWidget);
    expect(find.text('Otomatik'), findsOneWidget);
    expect(find.text('Manuel'), findsOneWidget);
    await _reveal(tester, find.text('Hedef tel'));
    expect(find.text('Hedef tel'), findsOneWidget);
  });

  testWidgets('narrow large-text layout remains scrollable without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          pitch: _pitch(116.54, 'A#', 2),
          target: TuningPresets.standard.stringAt(5),
          cents: 99,
          accuracy: TunerAccuracy.out,
          direction: TunerDirection.sharp,
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    expect(find.byKey(const Key('guitarTunerScroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('semantics expose note, target, cents and frequency', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          pitch: _pitch(109.6, 'A', 2),
          target: TuningPresets.standard.stringAt(5),
          cents: -6.3,
          accuracy: TunerAccuracy.near,
          direction: TunerDirection.flat,
        ),
      ),
    );

    expect(find.bySemanticsLabel('Detected note A, octave 2'), findsOneWidget);
    expect(find.bySemanticsLabel('6 cents Flat'), findsWidgets);
    expect(find.bySemanticsLabel('Frequency 109.6 hertz'), findsOneWidget);
    expect(find.bySemanticsLabel('Tuning to A2, string 5'), findsOneWidget);
    semantics.dispose();
  });
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('guitarTunerScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pump();
}

Widget _app(
  GuitarTunerState state, {
  Locale locale = const Locale('en'),
  ValueChanged<TunerMode>? onMode,
  ValueChanged<int>? onString,
  VoidCallback? onResume,
  VoidCallback? onOpenSettings,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: GuitarTunerView(
      state: state,
      onResume: onResume ?? () {},
      onModeChanged: onMode ?? (_) {},
      onStringSelected: onString ?? (_) {},
      onOpenSettings: onOpenSettings ?? () {},
    ),
  );
}

GuitarTunerState _state({
  TunerSignalState signal = TunerSignalState.stopped,
  bool capturing = false,
  TunerMode mode = TunerMode.automatic,
  TuningPreset preset = TuningPresets.standard,
  TuningStringTarget? target,
  StabilizedPitch? pitch,
  double? cents,
  TunerAccuracy? accuracy,
  TunerDirection? direction,
}) {
  final settings = TunerPreferencesState(
    presetId: preset.id,
    mode: mode,
    manualStringPosition: target?.stringPosition ?? 6,
  );
  return GuitarTunerState(
    audio: TunerAudioState(
      status: capturing
          ? TunerCaptureStatus.capturing
          : TunerCaptureStatus.idle,
    ),
    settings: settings,
    preset: preset,
    signalState: signal,
    target: target,
    pitch: pitch,
    note: ChromaticTunerEngine.resolve(pitch?.frequencyHz),
    cents: cents,
    accuracy: accuracy,
    direction: direction,
    settingsLoaded: true,
  );
}

StabilizedPitch _pitch(double frequency, String noteName, int octave) =>
    StabilizedPitch(
      frequencyHz: frequency,
      continuousMidi: 45,
      midiNote: 45,
      noteName: noteName,
      octave: octave,
      centsDeviation: 0,
      confidence: 0.98,
    );
