import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/app.dart';
import 'package:tunathic/app/settings/app_settings.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/bpm_tap/presentation/bpm_tap_controller.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('dashboard BPM Tap interaction estimates and resets tempo', (
    tester,
  ) async {
    var elapsed = Duration.zero;
    final haptics = FakeHapticFeedbackOutput();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
          bpmTapElapsedTimeProvider.overrideWithValue(() => elapsed),
          hapticFeedbackOutputProvider.overrideWithValue(haptics),
        ],
        child: const TunathicApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('BPM Tap'));
    await tester.pumpAndSettle();

    expect(find.text('Tap to begin'), findsNWidgets(2));
    expect(find.text('No taps'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();
    elapsed = const Duration(milliseconds: 500);
    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();
    elapsed = const Duration(seconds: 1);
    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();

    expect(find.text('120'), findsOneWidget);
    expect(find.text('3 taps'), findsOneWidget);
    expect(find.text('500 ms since last tap'), findsOneWidget);
    expect(haptics.lightImpactCount, 3);

    await tester.tap(find.byKey(const Key('bpmTapReset')));
    await tester.pump();

    expect(find.text('—'), findsOneWidget);
    expect(find.text('No taps'), findsOneWidget);
    // One selection opens the tool and one resets its active session.
    expect(haptics.selectionCount, 2);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('active session resets after inactivity', (tester) async {
    var elapsed = Duration.zero;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStoreProvider.overrideWithValue(MemoryPreferencesStore()),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
          bpmTapElapsedTimeProvider.overrideWithValue(() => elapsed),
        ],
        child: const TunathicApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('BPM Tap'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bpmTapSurface')));
    await tester.pump();

    elapsed = const Duration(seconds: 3);
    await tester.pump(const Duration(seconds: 3));

    expect(
      find.text('Session reset after inactivity. Tap to begin again.'),
      findsOneWidget,
    );
    expect(find.text('No taps'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
