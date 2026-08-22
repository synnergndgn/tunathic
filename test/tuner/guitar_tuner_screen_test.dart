import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/application/tuner_preferences.dart';
import 'package:tunathic/features/tuner/domain/chromatic_tuner_engine.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/domain/tuning_reference.dart';
import 'package:tunathic/features/tuner/presentation/guitar_tuner_screen.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';
import 'package:tunathic/features/tuner_realtime/domain/pitch_stabilizer.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';

void main() {
  testWidgets('stopped screen is production-facing and has no diagnostics', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_state()));

    expect(find.text('Guitar Tuner'), findsOneWidget);
    await _reveal(tester, find.text('Listening paused.'));
    expect(find.text('Listening paused.'), findsOneWidget);
    expect(find.text('Raw detector result'), findsNothing);
    expect(find.text('Frames analyzed'), findsNothing);
    expect(find.text('Development diagnostic only.'), findsNothing);
  });

  testWidgets('there is no start button, and no resume button either', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.waitingForSignal, capturing: true)),
    );

    // Listening begins on its own, so while it runs the only transport
    // control is the one that ends it.
    expect(find.byKey(const Key('startGuitarTuner')), findsNothing);
    expect(find.byKey(const Key('retryGuitarTunerMicrophone')), findsNothing);
    expect(find.byKey(const Key('stopGuitarTuner')), findsOneWidget);

    // Stopped for an ordinary reason, the tuner picks itself back up rather
    // than asking, so the dock has nothing to offer and disappears.
    await tester.pumpWidget(_app(_state()));
    await tester.pump();
    expect(find.byKey(const Key('startGuitarTuner')), findsNothing);
    expect(find.byKey(const Key('stopGuitarTuner')), findsNothing);
    expect(find.byKey(const Key('retryGuitarTunerMicrophone')), findsNothing);
    expect(find.text('Resume listening'), findsNothing);
  });

  testWidgets('a refused microphone still keeps its retry', (tester) async {
    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.permissionDenied)),
    );

    expect(find.byKey(const Key('retryGuitarTunerMicrophone')), findsOneWidget);

    // The dock is the one control that survives the resume button, so its
    // Turkish label is checked here rather than in the localization sweep.
    await tester.pumpWidget(
      _app(
        _state(signal: TunerSignalState.permissionDenied),
        locale: const Locale('tr'),
      ),
    );
    await tester.pump();
    expect(find.text('Mikrofonu yeniden dene'), findsOneWidget);
  });

  testWidgets('a refused microphone explains itself and offers a retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.permissionDenied)),
    );

    expect(find.text('Try microphone again'), findsOneWidget);
    await _reveal(tester, find.text('Microphone permission required'));
    expect(find.text('Microphone permission required'), findsOneWidget);
  });

  testWidgets('listening and no-signal states never invent a note', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.waitingForSignal, capturing: true)),
    );
    // The readout leads the screen, so it is checked before scrolling away
    // from it to reach the signal message.
    expect(find.text('—'), findsWidgets);
    await _reveal(tester, find.text('Listening… Play one note.'));
    expect(find.text('Listening… Play one note.'), findsOneWidget);

    await tester.pumpWidget(
      _app(_state(signal: TunerSignalState.noSignal, capturing: true)),
    );
    await tester.pump();
    await _reveal(tester, find.text('No reliable signal. Play one note.'));
    expect(find.text('No reliable signal. Play one note.'), findsOneWidget);
    expect(find.byKey(const Key('tunerDetectedOctave')), findsNothing);
  });

  testWidgets('stable note shows note, octave, frequency and in-tune state', (
    tester,
  ) async {
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
    await _reveal(tester, find.byKey(const Key('tunerCentsValue')));
    expect(find.text('+0 cents'), findsOneWidget);
    expect(find.text('110.0 Hz'), findsOneWidget);
    expect(find.text('In tune'), findsOneWidget);
    expect(find.byKey(const Key('stopGuitarTuner')), findsOneWidget);
  });

  testWidgets('flat and sharp direction are readable without color', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          pitch: _pitch(109.4, 'A', 2),
          target: TuningPresets.standard.stringAt(5),
          cents: -9.5,
          accuracy: TunerAccuracy.near,
          direction: TunerDirection.flat,
        ),
      ),
    );
    await _reveal(tester, find.byKey(const Key('tunerCentsValue')));
    expect(find.text('-10 cents'), findsOneWidget);
    expect(find.text('Flat'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          pitch: _pitch(111, 'A', 2),
          target: TuningPresets.standard.stringAt(5),
          cents: 15.7,
          accuracy: TunerAccuracy.out,
          direction: TunerDirection.sharp,
        ),
      ),
    );
    await tester.pump();
    await _reveal(tester, find.byKey(const Key('tunerCentsValue')));
    expect(find.text('+16 cents'), findsOneWidget);
    expect(find.text('Sharp'), findsOneWidget);
  });

  testWidgets('preset, mode, and manual string controls invoke callbacks', (
    tester,
  ) async {
    TuningPresetId? selectedPreset;
    TunerMode? selectedMode;
    int? selectedString;
    await tester.pumpWidget(
      _app(
        _state(mode: TunerMode.manual),
        onPreset: (value) => selectedPreset = value,
        onMode: (value) => selectedMode = value,
        onString: (value) => selectedString = value,
      ),
    );

    await _reveal(tester, find.byKey(const Key('tunerString3')));
    await tester.tap(find.byKey(const Key('tunerString3')));
    await tester.pump();
    expect(selectedString, 3);

    await _reveal(tester, find.text('Automatic'));
    await tester.tap(find.text('Automatic'));
    await tester.pump();
    expect(selectedMode, TunerMode.automatic);

    await _reveal(tester, find.byType(DropdownButtonFormField<TuningPresetId>));
    await tester.tap(find.byType(DropdownButtonFormField<TuningPresetId>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DADGAD').last);
    await tester.pumpAndSettle();
    expect(selectedPreset, TuningPresetId.dadgad);
  });

  testWidgets('production tuner is fully localized in Turkish', (tester) async {
    await tester.pumpWidget(
      _app(_state(mode: TunerMode.manual), locale: const Locale('tr')),
    );

    expect(find.text('Gitar Akort Cihazı'), findsOneWidget);

    await _reveal(tester, find.byKey(const Key('tunerModeSelector')));
    expect(find.text('Otomatik'), findsOneWidget);
    expect(find.text('Manuel'), findsOneWidget);
    expect(find.text('Kromatik'), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('tunerReferenceSelector')));
    expect(find.text('Referans perde'), findsWidgets);
    await _reveal(tester, find.text('Akort düzeni'));
    expect(find.text('Akort düzeni'), findsWidgets);
    await _reveal(tester, find.text('Hedef tel'));
    expect(find.text('Hedef tel'), findsOneWidget);
  });

  testWidgets('chromatic mode drops the preset and names any note', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          mode: TunerMode.chromatic,
          pitch: _pitch(329.63, 'E', 4),
          cents: -7,
          accuracy: TunerAccuracy.near,
          direction: TunerDirection.flat,
        ),
      ),
    );

    expect(find.text('E'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Chromatic'), findsWidgets);
    expect(find.text('329.6 Hz'), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('tunerCentsValue')));
    expect(find.text('-7 cents'), findsOneWidget);

    // No preset can apply when any note is fair game.
    expect(find.byType(DropdownButtonFormField<TuningPresetId>), findsNothing);
    expect(find.byKey(const Key('tunerString3')), findsNothing);
  });

  testWidgets('the reference selector reads and edits the reference', (
    tester,
  ) async {
    final changes = <TuningReference>[];
    await tester.pumpWidget(
      _app(
        _state(reference: TuningReference.resolve(432)),
        onReference: changes.add,
      ),
    );

    await _reveal(tester, find.byKey(const Key('tunerReferenceValue')));
    expect(find.text('A4 = 432 Hz'), findsWidgets);

    await tester.tap(find.byKey(const Key('tunerReferenceIncrease')));
    await tester.pump();
    expect(changes.single.a4FrequencyHz, 433);

    await tester.tap(find.byKey(const Key('tunerReferenceDecrease')));
    await tester.pump();
    expect(changes.last.a4FrequencyHz, 431);

    await _reveal(tester, find.byKey(const Key('tunerReferenceReset')));
    await tester.tap(find.byKey(const Key('tunerReferenceReset')));
    await tester.pump();
    expect(changes.last, TuningReference.standard);
  });

  testWidgets('the reference selector cannot leave its range', (tester) async {
    final changes = <TuningReference>[];
    await tester.pumpWidget(
      _app(
        _state(reference: TuningReference.resolve(TuningReference.minimumHz)),
        onReference: changes.add,
      ),
    );

    await _reveal(tester, find.byKey(const Key('tunerReferenceDecrease')));
    final decrease = tester.widget<SkeuoButton>(
      find.byKey(const Key('tunerReferenceDecrease')),
    );
    expect(decrease.onPressed, isNull);

    await tester.pumpWidget(
      _app(
        _state(reference: TuningReference.resolve(TuningReference.maximumHz)),
        onReference: changes.add,
      ),
    );
    await tester.pump();
    await _reveal(tester, find.byKey(const Key('tunerReferenceIncrease')));
    final increase = tester.widget<SkeuoButton>(
      find.byKey(const Key('tunerReferenceIncrease')),
    );
    expect(increase.onPressed, isNull);
    expect(changes, isEmpty);
  });

  testWidgets('a shifted reference renames the note under the same pitch', (
    tester,
  ) async {
    // 440 Hz is A4 at concert pitch and still A4 — but sharp — at 432 Hz.
    await tester.pumpWidget(
      _app(
        _state(
          signal: TunerSignalState.stablePitch,
          capturing: true,
          mode: TunerMode.chromatic,
          pitch: _pitch(440, 'A', 4),
          reference: TuningReference.resolve(432),
          cents: 31.8,
          accuracy: TunerAccuracy.out,
          direction: TunerDirection.sharp,
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('A4 = 432 Hz'), findsWidgets);
    await _reveal(tester, find.byKey(const Key('tunerCentsValue')));
    expect(find.text('+32 cents'), findsOneWidget);
  });

  testWidgets('light and dark themes render the same tuner hierarchy', (
    tester,
  ) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(_app(_state(), themeMode: mode));
      expect(find.byKey(const Key('tunerCentsIndicator')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
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

  testWidgets('semantics expose complete note, target, cents and frequency', (
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
    await _reveal(tester, find.byKey(const Key('tunerString5')));
    expect(find.bySemanticsLabel('Target string 5, A2'), findsOneWidget);
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
  ThemeMode themeMode = ThemeMode.light,
  ValueChanged<TunerMode>? onMode,
  ValueChanged<TuningPresetId>? onPreset,
  ValueChanged<int>? onString,
  ValueChanged<TuningReference>? onReference,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: GuitarTunerView(
      state: state,
      onResume: () {},
      onStop: () {},
      onModeChanged: onMode ?? (_) {},
      onPresetChanged: onPreset ?? (_) {},
      onStringSelected: onString ?? (_) {},
      onReferenceChanged: onReference ?? (_) {},
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
  TuningReference reference = TuningReference.standard,
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
    reference: reference,
    target: target,
    pitch: pitch,
    note: ChromaticTunerEngine.resolve(
      pitch?.frequencyHz,
      reference: reference,
    ),
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
