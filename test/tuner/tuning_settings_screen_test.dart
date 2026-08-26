import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/tuner/application/guitar_tuner_controller.dart';
import 'package:tunathic/features/tuner/application/tuning_reference_controller.dart';
import 'package:tunathic/features/tuner/domain/tuning.dart';
import 'package:tunathic/features/tuner/presentation/tuning_settings_screen.dart';
import 'package:tunathic/features/tuner_audio/presentation/tuner_audio_controller.dart';
import 'package:tunathic/l10n/app_localizations.dart';

import '../support/fakes.dart';
import '../support/tuner_audio_fakes.dart';

void main() {
  testWidgets('settings owns tuning system and A4 controls', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tunerAudioInputFactoryProvider.overrideWithValue(
          FakeTunerAudioInput.new,
        ),
        pitchDetectionExecutorProvider.overrideWithValue(
          FakePitchDetectionExecutor(),
        ),
        preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
        hapticFeedbackOutputProvider.overrideWithValue(
          FakeHapticFeedbackOutput(),
        ),
        appLoggerProvider.overrideWithValue(RecordingLogger()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: const TuningSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tuning settings'), findsOneWidget);
    expect(find.text('Tuning system'), findsOneWidget);
    expect(find.byKey(const Key('tuningSystemChromatic')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tuningSystemChromatic')));
    await tester.pump();
    expect(container.read(guitarTunerProvider).isChromatic, isTrue);

    await _reveal(tester, find.byKey(const Key('tuningSystem-open-g')));
    await tester.tap(find.byKey(const Key('tuningSystem-open-g')));
    await tester.pumpAndSettle();
    final selected = container.read(guitarTunerProvider);
    expect(selected.settings.presetId, TuningPresetId.openG);
    expect(selected.settings.mode, TunerMode.automatic);

    await _reveal(tester, find.byKey(const Key('tunerReferenceIncrease')));
    await tester.tap(find.byKey(const Key('tunerReferenceIncrease')));
    await tester.pump();
    expect(container.read(tuningReferenceProvider).a4FrequencyHz, 441);
  });
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('tuningSettingsScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pump();
}
